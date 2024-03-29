//
//  Map_MapApp.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import MapKit
import SwiftUI

@main
struct MapMapApp: App {
    /// Core data storage for environment.
    @StateObject private var dataController = DataController()
    /// Map details for environment.
    @State private var mapDetails = MapDetailsM()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environment(mapDetails)
        }
    }
}
