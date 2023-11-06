//
//  ContentView.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import Bottom_Drawer
import CoreData
import SwiftUI

struct ContentView: View {
    @FetchRequest(sortDescriptors: []) var mapMaps: FetchedResults<MapMap>
    @Environment(\.managedObjectContext) var moc
    @State var editingMapMap: Bool = false
    let blurAmount: CGFloat = 10
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                BackgroundMap()
                    .ignoresSafeArea()
                BlurView()
                    .frame(width: geo.size.width, height: geo.safeAreaInsets.top)
                    .blur(radius: blurAmount)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
                if editingMapMap {
                    if let mapInProgress = mapMaps.first(where: { $0.isEditing }) {
                        MapMapEditor(mapMap: mapInProgress)
                    }
                    else { EmptyView().onAppear { editingMapMap = false } }
                }
                else {
                    BottomDrawer(
                        verticalDetents: [.medium, .large, .header],
                        horizontalDetents: [.left, .right],
                        shortCardSize: 315,
                        header: { _ in
                            HStack {
                                Text("Your Maps")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding([.leading])
                                Spacer()
                            }
                        },
                        content: { isShortCard in
                            MapMapsViewer(listMode: isShortCard ? .compact : .full)
                                .padding(.horizontal)
                        }
                    )
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { _ in
            editingMapMap = mapMaps.contains(where: { $0.isEditing })
        }
        .onAppear {
            for mapMap in mapMaps {
                if !mapMap.isSetup { moc.delete(mapMap) }
                else if mapMap.isEditing == true { mapMap.isEditing = false }
            }
            try? moc.save()
        }
    }
}

#Preview {
    ContentView()
}
