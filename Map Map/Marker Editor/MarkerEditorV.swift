//
//  MarkerEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/20/23.
//

import Bottom_Drawer
import MapKit
import SwiftUI

/// A one-stop-shop for editing details about a Marker.
struct MarkerEditorV: View {
    /// Track if the marker's angle should be saved.
    @State private var saveAngle: Bool
    /// Desired name for the Marker.
    @State private var workingName: String
    /// Track if the marker symbol picker is being shown.
    @State private var showingImagePicker: Bool = false
    /// Current Core Data managed object context.
    @Environment(\.managedObjectContext) private var moc
    /// Marker being edited.
    @ObservedObject var marker: FetchedResults<Marker>.Element
    /// Information about the background map being plotted on top of.
    @Environment(BackgroundMapDetailsM.self) private var backgroundMapDetails
    /// All available MapMaps
    @FetchRequest(sortDescriptors: []) var mapMaps: FetchedResults<MapMap>
    /// Map context for converting coordiantes to screen-space and back.
    let mapContext: MapProxy
    
    init(marker: FetchedResults<Marker>.Element, mapContext: MapProxy) {
        self.marker = marker
        if let name = marker.name { self._workingName = State(initialValue: name) }
        else { self._workingName = State(initialValue: "") }
        self._saveAngle = State(initialValue: marker.lockRotationAngleDouble != nil)
        self.mapContext = mapContext
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZStack(alignment: .topLeading) {
                    Button {
                        saveAngle.toggle()
                    } label: {
                        Image(systemName: saveAngle ? "lock.rotation" : "lock.open.rotation")
                            .opacity(saveAngle ? 1 : 0.75)
                            .mapButton()
                            .saturation(saveAngle ? 1 : 0)
                            .accessibilityLabel(saveAngle ? "Unlock marker rotation" : "Lock marker rotation")
                    }
                    Color.clear
                }
                .padding(.leading, max(BackgroundMapLayersV.minSafeAreaDistance, geo.safeAreaInsets.leading))
                .padding(.top, max(BackgroundMapLayersV.minSafeAreaDistance, geo.safeAreaInsets.top))
                MarkerV(marker: marker)
                    .allowsHitTesting(false)
                    .frame(width: BackgroundMapPointsV.iconSize, height: BackgroundMapPointsV.iconSize)
                BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center], shortCardSize: 350) { isShortCard in
                    VStack {
                        HStack {
                            TextField("Marker name", text: $workingName)
                                .padding(.all, 5)
                                .background(Color.gray.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(width: 205)
                            ColorPicker("", selection: $marker.backgroundColor, supportsOpacity: false)
                                .labelsHidden()
                            Button {
                                showingImagePicker.toggle()
                            } label: {
                                Circle()
                                    .fill(.gray)
                                    .frame(width: 32)
                                    .overlay {
                                        marker.renderedThumbnailImage
                                            .scaledToFit()
                                            .scaleEffect(0.6)
                                            .foregroundStyle(.white)
                                    }
                            }
                            .popover(isPresented: $showingImagePicker) {
                                MarkerSymbolPickerV(marker: marker)
                                    .frame(minWidth: 335, minHeight: 300, maxHeight: geo.size.height / 2)
                                    .presentationCompactAdaptation(.popover)
                            }
                        }
                        HStack {
                            Button(
                                action: { updateMarker() },
                                label: { Text("Done").bigButton(backgroundColor: .blue) }
                            )
                            Button { moc.reset() } label: { Text("Cancel").bigButton(backgroundColor: .gray) }
                        }
                    }
                    .padding(.bottom, isShortCard ? 0 : 10)
                }
                .safeAreaPadding(geo.safeAreaInsets)
            }
            .ignoresSafeArea()
        }
        .onAppear { backgroundMapDetails.preventFollowingUser() }
    }
    
    func determineMarkerOverlap() {
        if let overlappingMapMaps = MarkerEditorV.markerOverMapMaps(
            marker,
            backgroundMapDetails: backgroundMapDetails,
            mapContext: mapContext,
            mapMaps: mapMaps
        ) {
            // Remove current marker from all MapMaps
            for mapMap in marker.formattedMapMaps { mapMap.removeFromMarkers(marker) }
            // Add Marker to relevant MapMaps
            for mapMap in overlappingMapMaps { mapMap.addToMarkers(marker) }
        }
    }
    
    /// Determine all MapMaps that overlap a given Marker
    /// - Parameters:
    ///   - backgroundMapDetails: A struct holding information about the background map.
    ///   - mapContext: A `MapProxy` that is generated by a `MapReader` to allow for mapping of lat/long coordinates to screen-space.
    ///   - mapMaps: All available MapMaps.
    /// - Returns: If the Marker's position in screen-space was not found, then nil is returned.
    /// Otherwise, all available MapMaps are returned.
    public static func markerOverMapMaps(
        _ marker: Marker,
        backgroundMapDetails: BackgroundMapDetailsM,
        mapContext: MapProxy,
        mapMaps: FetchedResults<MapMap>
    ) -> [MapMap]? {
        guard let markerPosition = mapContext.convert(marker.coordinates, to: .global)
        else { return nil }
        let marker = MarkerEditorV.generateMarkerBoundingBox(markerPosition: markerPosition)
        var overlappingMapMaps: [MapMap] = []
        for mapMap in mapMaps {
            if let mapMapBounds = BackgroundMap.generateMapMapRotatedConvexHull(
                mapMap: mapMap,
                backgroundMapDetails: backgroundMapDetails,
                mapContext: mapContext
            )?.cgPath,
                mapMapBounds.intersects(marker) {
                overlappingMapMaps.append(mapMap)
            }
        }
        return overlappingMapMaps
    }
    
    /// Generate a Marker's bounding box
    /// - Parameter markerPosition: Center point of the bounding box.
    /// - Returns: A CGPath of a circle centered at the marker position.
    public static func generateMarkerBoundingBox(markerPosition: CGPoint) -> CGPath {
        return UIBezierPath(
            ovalIn: CGRect(
                origin: markerPosition,
                size: CGSize(
                    width: BackgroundMapPointsV.iconSize,
                    height: BackgroundMapPointsV.iconSize
                )
            )
        ).cgPath
    }
    
    /// Update the marker to the current status of the Marker Editor.
    private func updateMarker() {
        marker.isEditing = false
        marker.name = workingName
        marker.coordinates = backgroundMapDetails.region.center
        marker.lockRotationAngleDouble = saveAngle ? -backgroundMapDetails.mapCamera.heading : nil
        determineMarkerOverlap()
        try? moc.save()
    }
}
