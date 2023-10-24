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
    @FetchRequest(sortDescriptors: []) var mapPhotos: FetchedResults<MapPhoto>
    @Environment(\.managedObjectContext) var moc
    @State var showSetup: Bool = false
    let blurAmount: CGFloat = 10
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                MapMap()
                    .ignoresSafeArea()
                BlurView()
                    .frame(width: geo.size.width, height: geo.safeAreaInsets.top)
                    .blur(radius: blurAmount)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
                if showSetup {
                    if let mapInProgress = mapPhotos.first(where: { $0.isEditing }) {
                        MapEditor(map: mapInProgress)
                    }
                    else { EmptyView().onAppear { showSetup = false } }
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
                            MapsViewer(listMode: isShortCard ? .compact : .full)
                                .padding(.horizontal)
                        }
                    )
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { _ in
            showSetup = mapPhotos.contains(where: { $0.isEditing })
        }
    }
}

#Preview {
    ContentView()
}
