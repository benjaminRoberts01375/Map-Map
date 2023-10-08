//
//  Map_MapApp.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import SwiftUI

@main
struct Map_MapApp: App {
    @StateObject private var dataController = DataController()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
