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
    @StateObject private var mapDetails = MapDetailsM()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(mapDetails)
                .task {
                    let locationManager = CLLocationManager()
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    if locationManager.authorizationStatus == .notDetermined { locationManager.requestWhenInUseAuthorization() }
                }
        }
    }
}
