//
//  Marker+CoreDataProperties.swift
//  Map Map
//
//  Created by Ben Roberts on 11/29/23.
//
//

import Foundation
import CoreData


extension Marker {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Marker> {
        return NSFetchRequest<Marker>(entityName: "Marker")
    }

    @NSManaged public var isEditing: Bool
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var thumbnailImage: String?
    @NSManaged public var lockRotationAngle: NSDecimalNumber?
    @NSManaged public var color: MarkerColor?
    @NSManaged public var mapMap: NSSet?

}

// MARK: Generated accessors for mapMap
extension Marker {

    @objc(addMapMapObject:)
    @NSManaged public func addToMapMap(_ value: MapMap)

    @objc(removeMapMapObject:)
    @NSManaged public func removeFromMapMap(_ value: MapMap)

    @objc(addMapMap:)
    @NSManaged public func addToMapMap(_ values: NSSet)

    @objc(removeMapMap:)
    @NSManaged public func removeFromMapMap(_ values: NSSet)

}

extension Marker : Identifiable {

}
