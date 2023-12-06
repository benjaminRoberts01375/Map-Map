//
//  Map_MapApp.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import MapKit
import SwiftUI

@main
struct Map_MapApp: App {
    @StateObject private var dataController = DataController()
    @State private var mapDetails = BackgroundMapDetailsM()
    @State private var positions = ScreenSpacePositionsM()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environment(mapDetails)
                .environment(positions)
        }
    }
}
