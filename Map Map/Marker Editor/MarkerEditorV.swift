//
//  MarkerEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/20/23.
//

import Bottom_Drawer
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
    /// Screen space positions for plotted objects.
    @Environment(ScreenSpacePositionsM.self) private var screenSpacePositions
    /// Marker being edited.
    @ObservedObject var marker: FetchedResults<Marker>.Element
    /// Information about the background map being plotted on top of.
    @Environment(BackgroundMapDetailsM.self) private var backgroundMapDetails
    
    init(marker: FetchedResults<Marker>.Element) {
        self.marker = marker
        if let name = marker.name { self._workingName = State(initialValue: name) }
        else { self._workingName = State(initialValue: "") }
        self._saveAngle = State(initialValue: marker.lockRotationAngleDouble != nil)
        NotificationCenter.default.post(name: .editingMarker, object: nil, userInfo: ["editing":true])
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
                            Button {
                                marker.isEditing = false
                                marker.name = workingName
                                marker.coordinates = backgroundMapDetails.position
                                marker.lockRotationAngleDouble = saveAngle ? backgroundMapDetails.rotation.degrees : nil
                                determineMarkerSSLocation(geo: geo)
                                determineMarkerOverlap()
                                try? moc.save()
                            } label: {
                                Text("Done")
                                    .bigButton(backgroundColor: .blue)
                            }
                            Button {
                                moc.reset()
                                guard let refetchedMarker = try? moc.existingObject(with: marker.objectID) as? Marker else { return }
                                NotificationCenter.default.post(
                                    name: .editedMarkerLocation,
                                    object: nil,
                                    userInfo: ["marker" : refetchedMarker]
                                )
                            } label: {
                                Text("Cancel")
                                    .bigButton(backgroundColor: .gray)
                            }
                        }
                    }
                    .padding(.bottom, isShortCard ? 0 : 10)
                }
                .safeAreaPadding(geo.safeAreaInsets)
            }
            .ignoresSafeArea()
            .onDisappear { NotificationCenter.default.post(name: .editingMarker, object: nil, userInfo: ["editing":false]) }
        }
    }
    
    func determineMarkerOverlap() {
        if let overlappingMapMaps =
            screenSpacePositions.markerOverMapMaps(marker, backgroundMapRotation: backgroundMapDetails.rotation) {
            // Remove current marker from all MapMaps
            for mapMap in marker.formattedMapMaps { mapMap.removeFromMarkers(marker) }
            // Add Marker to relevant MapMaps
            for mapMap in overlappingMapMaps { mapMap.addToMarkers(marker) }
        }
    }
    
    func determineMarkerSSLocation(geo: GeometryProxy) {
        screenSpacePositions.markerPositions[marker] = CGPoint(
            x: geo.size.width / 2,
            y: geo.size.height / 2 + geo.safeAreaInsets.top - 2
        )
    }
}
