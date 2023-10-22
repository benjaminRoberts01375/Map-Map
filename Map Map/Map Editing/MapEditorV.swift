//
//  MapEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/9/23.
//

import Bottom_Drawer
import SwiftUI

struct MapEditor: View {
    @ObservedObject var map: FetchedResults<MapPhoto>.Element
    @EnvironmentObject var mapDetails: MapDetailsM
    @Environment(\.managedObjectContext) var moc
    @State var workingName: String = ""
    @State var mapWidth: CGFloat = .zero
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                AnyView(map.getMap(.fullImage))
                    .frame(width: geo.size.width * 0.75, height: geo.size.height * 0.75)
                    .opacity(0.5)
                    .allowsHitTesting(false)
                    .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
                    .onChange(of: geo.size, initial: true) { _, update in
                        mapWidth = update.width
                    }
            }
            
            BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center]) {
                VStack {
                    TextField("\(Image(systemName: "pencil")) Map name", text: $workingName)
                        .padding(.all, 5)
                        .background(Color.gray.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: 205)
                    HStack {
                        Button(action: {
                            map.coordinates = mapDetails.position
                            map.rotation = NSDecimalNumber(value: mapDetails.rotation.degrees)
                            map.scale = NSDecimalNumber(value: mapWidth / mapDetails.scale)
                            map.mapName = workingName
                            map.isEditing = false
                            try? moc.save()
                        }) {
                            Text("Done")
                                .bigButton(backgroundColor: .blue)
                        }
                        Button(action: {
                            moc.delete(map)
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
        .onAppear { workingName = map.mapName ?? "Untitled Map" }
        .ignoresSafeArea()
    }
}