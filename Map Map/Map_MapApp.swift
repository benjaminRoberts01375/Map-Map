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
    @StateObject private var dataController = DataController()
    @State private var mapDetails = BackgroundMapDetailsM()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environment(mapDetails)
        }
    }
}
