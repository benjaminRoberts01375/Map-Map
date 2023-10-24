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
    @EnvironmentObject var mapDetails: BackgroundMapDetailsM
    @Environment(\.managedObjectContext) var moc
    @State var workingName: String = ""
    @State var mapWidth: CGFloat = .zero
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                AnyView(mapMap.getMap(.fullImage))
                    .background {
                        GeometryReader { imageGeo in
                            Color.clear
                                .onChange(of: imageGeo.size, initial: true) { _, update in
                                    mapWidth = update.width
                                }
                        }
                    }
                    .frame(width: geo.size.width * 0.75, height: geo.size.height * 0.75)
                    .opacity(0.5)
                    .allowsHitTesting(false)
                    .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            }
            
            BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center]) { _ in
                VStack {
                    TextField("\(Image(systemName: "pencil")) Map name", text: $workingName)
                        .padding(.all, 5)
                        .background(Color.gray.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: 205)
                    HStack {
                        Button(action: {
                            mapMap.coordinates = mapDetails.position
                            mapMap.mapMapRotation = mapDetails.rotation.degrees
                            mapMap.mapMapScale = NSDecimalNumber(value: mapWidth / mapDetails.scale)
                            mapMap.mapMapName = workingName
                            mapMap.isEditing = false
                            try? moc.save()
                        }) {
                            Text("Done")
                                .bigButton(backgroundColor: .blue)
                        }
                        Button(action: {
                            moc.delete(mapMap)
                            try? moc.save()
                        }) {
                            Text("Cancel")
                                .bigButton(backgroundColor: .gray)
                        }
                    }
                    .padding(.bottom, 10)
                }
            }
        }
        .onAppear { workingName = mapMap.mapMapName ?? "Untitled Map" }
        .ignoresSafeArea()
    }
}
