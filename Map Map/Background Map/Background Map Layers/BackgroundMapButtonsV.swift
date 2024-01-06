//
//  BackgroundMapButtonsV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/19/23.
//

import MapKit
import SwiftUI

/// Background Map button controls.
struct BackgroundMapButtonsV: View {
    /// All available MapMaps
    @FetchRequest(sortDescriptors: []) private var mapMaps: FetchedResults<MapMap>
    /// All available Markers
    @FetchRequest(sortDescriptors: []) private var markers: FetchedResults<Marker>
    /// Current Core Data managed object context.
    @Environment(\.managedObjectContext) private var moc
    /// Details about the background map.
    @Environment(BackgroundMapDetailsM.self) private var backgroundMapDetails
    /// Tracker for adding or removing markers.
    @State private var markerButton: MarkerButtonType = .add
    /// Coordinate display type.
    @Binding var displayType: LocationDisplayMode
    /// Current editor being used.
    @Binding var editor: Editor
    /// Size of parent view.
    let screenSize: CGSize
    /// Background map ID.
    let mapScope: Namespace.ID
    
    let mapContext: MapProxy
    
    /// Type for tracking adding or removing markers.
    enum MarkerButtonType: Equatable {
        /// Potentially add a Marker
        case add
        /// Potentially delete this Marker.
        case delete(Marker)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack {
                BackgroundMapHudV(rawDisplayType: $displayType)
                MapScaleView(scope: mapScope)
            }
            .padding(.trailing, BackgroundMapLayersV.minSafeAreaDistance)
            .background {
                BlurView()
                    .blur(radius: BackgroundMapLayersV.blurAmount)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            VStack {
                MapUserLocationButton(scope: mapScope)
                    .background(.thickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                switch markerButton {
                case .add:
                    Button {
                        addMarker()
                    } label: {
                        Image(systemName: "mappin.and.ellipse")
                            .accessibilityLabel("Add Marker Button")
                            .mapButton()
                    }
                case .delete(let marker):
                    Button {
                        moc.delete(marker)
                        try? moc.save()
                    } label: {
                        Image(systemName: "mappin.slash")
                            .accessibilityLabel("Remove Marker Button")
                            .mapButton()
                    }
                }
                
                Button {
                    editor = .measurement
                } label: {
                    Image(systemName: "ruler")
                        .accessibilityLabel("Edit Measurements Button")
                        .rotationEffect(Angle(degrees: -45))
                        .mapButton()
                }
            }
            .background {
                BlurView()
                    .blur(radius: BackgroundMapLayersV.blurAmount)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .animation(.easeInOut, value: markerButton)
        .mapScope(mapScope)
        .onChange(of: backgroundMapDetails.position) { checkOverMarker() }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
            checkOverMarker()
        }
    }
    
    func checkOverMarker() {
        for marker in markers {
            if let markerPos = mapContext.convert(marker.coordinates, to: .global) {
                let xComponent = abs(markerPos.x - screenSize.width / 2)
                let yComponent = abs(markerPos.y - screenSize.height / 2)
                let distance = sqrt(pow(xComponent, 2) + pow(yComponent, 2))
                if distance < BackgroundMapPointsV.iconSize / 2 {
                    markerButton = .delete(marker)
                    return
                }
            }
        }
        switch markerButton {
        case .add:
            break
        default:
            markerButton = .add
        }
    }
    
    func addMarker() {
        let newMarker = Marker(coordinates: backgroundMapDetails.position, insertInto: moc)
        if let overlappedMapMaps = MarkerEditorV.markerOverMapMaps(
            newMarker,
            backgroundMapDetails: backgroundMapDetails,
            mapContext: mapContext,
            mapMaps: mapMaps
        ) {
            for mapMap in overlappedMapMaps { newMarker.addToMapMap(mapMap) }
        }
        try? moc.save()
    }
}
