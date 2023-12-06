//
//  MapEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/9/23.
//

import Bottom_Drawer
import SwiftUI

struct MapMapEditor: View {
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    @Environment(BackgroundMapDetailsM.self) var backgroundMapDetails
    @Environment(\.managedObjectContext) var moc
    @State var workingName: String = ""
    @State var mapMapWidth: CGFloat = .zero
    @State var showingPhotoEditor = false
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                MapMapV(mapMap: mapMap, mapType: .fullImage)
                    .background {
                        GeometryReader { imageGeo in
                            Color.clear
                                .onChange(of: imageGeo.size, initial: true) { _, update in
                                    mapMapWidth = update.width
                                }
                        }
                    }
                    .frame(width: geo.size.width * 0.75, height: geo.size.height * 0.75)
                    .opacity(0.5)
                    .allowsHitTesting(false)
                    .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            }
            .ignoresSafeArea()
            
            BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center], shortCardSize: 350) { _ in
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
                            mapMap.mapMapScale = mapMapWidth / backgroundMapDetails.scale
                            mapMap.mapMapName = workingName
                            mapMap.mapDistance = 1 / backgroundMapDetails.scale
                            mapMap.isEditing = false
                            mapMap.isSetup = true
                            try? moc.save()
                        }) {
                            Text("Done")
                                .bigButton(backgroundColor: .blue)
                        }
                        Button(action: {
                            if mapMap.isSetup { moc.reset() }
                            else { moc.delete(mapMap) }
                        }) {
                            Text("Cancel")
                                .bigButton(backgroundColor: .gray)
                        }
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
            }
        }
        .onAppear { workingName = mapMap.mapMapName ?? "Untitled Map" }
        .fullScreenCover(isPresented: $showingPhotoEditor, content: {
            PhotoEditorV(mapMap: mapMap)
        })
    }
}
