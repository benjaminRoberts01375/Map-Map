//
//  NSManagedObjectContextE.swift
//  Map Map
//
//  Created by Ben Roberts on 1/3/24.
//

import CoreData

extension String {
    /// Core data case where an entity is inserted.
    public static var inserted: String = "inserted"
    /// Core data case where an entity is deleted.
    public static var deleted: String = "deleted"
    /// Core data case where an a MOC is invalidated.
    public static var invalidatedAll: String = "invalidatedAll"
    /// Core data case where there has been an update.
    public static var update: String = "updated"
}
