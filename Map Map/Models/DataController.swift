//
//  DataController.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import CoreData
import SwiftUI

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "Map_Map")
    
    init() {
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data Error: \(error.localizedDescription)")
            }
        }
    }
}
