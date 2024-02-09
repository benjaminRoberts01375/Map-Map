//
//  GPSMap+CoreDataClass.swift
//  
//
//  Created by Ben Roberts on 2/9/24.
//
//

import CoreData
import Foundation

@objc(GPSMap)
public class GPSMap: NSManagedObject { }

public extension GPSMap {
    /// Create a GPS Map correctly.
    /// - Parameter moc: Managed Object Context to insert this GPS map into.
    convenience init(moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.isEditing = true
    }
}
