//
//  DataController.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import CoreData
import SwiftUI

/// Generates and manages a Managed Object Context
class DataController: ObservableObject {
    /// Core Data container.
    let container = NSPersistentContainer(name: "Map_Map")
    
    init() {
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data Error: \(error.localizedDescription)")
            }
        }
    }
}
