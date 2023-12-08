//
//  MapEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/9/23.
//

import Bottom_Drawer
import SwiftUI

/// One-stop-shop for editing MapMaps.
struct MapMapEditor: View {
    /// MapMap being edited.
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    /// Details about the background map being plotted on.
    @Environment(BackgroundMapDetailsM.self) private var backgroundMapDetails
    /// Current Managed Object Context.
    @Environment(\.managedObjectContext) private var moc
    /// All screen space positions for MapMaps, Markers, and the user location.
    @Environment(ScreenSpacePositionsM.self) private var screenSpacePositions
    /// Desired name for the current MapMap.
    @State private var workingName: String = ""
    /// Placement of the MapMap.
    @State private var mapMapPosition: CGRect = .zero
    /// Tracker for showing the photo (not MapMap) editor.
    @State private var showingPhotoEditor = false
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                MapMapV(mapMap: mapMap, mapType: .fullImage)
                    .background {
                        GeometryReader { imageGeo in
                            Color.clear
                                .onChange(of: imageGeo.size, initial: true) { _, update in
                                    mapMapPosition = CGRect(origin: CGPoint(size: geo.size / 2), size: update)
                                }
                        }
                    }
                    .frame(width: geo.size.width * 0.75, height: geo.size.height * 0.75)
                    .opacity(0.5)
                    .allowsHitTesting(false)
                    .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
                    .offset(y: -7)
            }
            .ignoresSafeArea()
            
            BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center], shortCardSize: 350) { isShortCard in
                VStack {
                    HStack {
                        TextField("Map Map name", text: $workingName)
                            .padding(.all, 5)
                            .background(Color.gray.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(width: 205)
                        Button(action: {
                            showingPhotoEditor = true
                        }, label: {
                            Image(systemName: "crop")
                                .padding(4)
                                .background(.gray)
                                .clipShape(Circle())
                        })
                        .buttonStyle(.plain)
                    }
                    HStack {
                        Button(action: {
                            mapMap.coordinates = backgroundMapDetails.position
                            mapMap.mapMapRotation = backgroundMapDetails.rotation.degrees
                            mapMap.mapMapScale = mapMapPosition.width / backgroundMapDetails.scale
                            mapMap.mapMapName = workingName
                            mapMap.mapDistance = 1 / backgroundMapDetails.scale
                            mapMap.isEditing = false
                            mapMap.isSetup = true
                            screenSpacePositions.mapMapPositions[mapMap] = mapMapPosition
                            if let overlappingMarkers = 
                                screenSpacePositions.mapMapOverMarkers(mapMap, backgroundMapRotation: backgroundMapDetails.rotation ) {
                                for marker in mapMap.formattedMarkers { mapMap.removeFromMarkers(marker) } // Remove MapMap from all Markers
                                for marker in overlappingMarkers { mapMap.addToMarkers(marker) } // Add MapMap to all
                            }
                            try? moc.save()
                        }, label: {
                            Text("Done")
                                .bigButton(backgroundColor: .blue)
                        })
                        Button(action: {
                            if mapMap.isSetup { moc.reset() }
                            else { moc.delete(mapMap) }
                        }, label: {
                            Text("Cancel")
                                .bigButton(backgroundColor: .gray)
                        })
                        if mapMap.isSetup {
                            Button( action: {
                                moc.delete(mapMap)
                                try? moc.save()
                            }, label: {
                                Text("Delete")
                            })
                            .bigButton(backgroundColor: .red)
                        }
                    }
                }
                .padding(.bottom, isShortCard ? 0 : 10)
            }
        }
        .onAppear { workingName = mapMap.mapMapName ?? "Untitled Map" }
        .fullScreenCover(isPresented: $showingPhotoEditor, content: {
            PhotoEditorV(mapMap: mapMap)
        })
    }
}
