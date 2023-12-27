//
//  MapMeasurementCoordinate+CoreDataProperties.swift
//  
//
//  Created by Ben Roberts on 12/22/23.
//
//

import Foundation
import CoreData


extension MapMeasurementCoordinate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MapMeasurementCoordinate> {
        return NSFetchRequest<MapMeasurementCoordinate>(entityName: "MapMeasurementCoordinate")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var neighbors: NSSet?

}

// MARK: Generated accessors for neighbors
extension MapMeasurementCoordinate {

    @objc(addNeighborsObject:)
    @NSManaged public func addToNeighbors(_ value: MapMeasurementCoordinate)

    @objc(removeNeighborsObject:)
    @NSManaged public func removeFromNeighbors(_ value: MapMeasurementCoordinate)

    @objc(addNeighbors:)
    @NSManaged public func addToNeighbors(_ values: NSSet)

    @objc(removeNeighbors:)
    @NSManaged public func removeFromNeighbors(_ values: NSSet)

}
