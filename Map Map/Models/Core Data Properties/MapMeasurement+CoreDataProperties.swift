//
//  MapMeasurement+CoreDataProperties.swift
//  
//
//  Created by Ben Roberts on 12/15/23.
//
//

import Foundation
import CoreData


extension MapMeasurement {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MapMeasurement> {
        return NSFetchRequest<MapMeasurement>(entityName: "MapMeasurement")
    }

    @NSManaged public var startingLongitude: Double
    @NSManaged public var startingLatitude: Double
    @NSManaged public var endingLongitude: Double
    @NSManaged public var endingLatitude: Double
    @NSManaged public var isEditing: Bool

}

extension MapMeasurement: Identifiable { }
