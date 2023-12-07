//
//  Marker+CoreDataProperties.swift
//  Map Map
//
//  Created by Ben Roberts on 12/5/23.
//
//

import CoreData
import Foundation

extension Marker {

    /// Implement fetch request of all Marker
    /// - Returns: This Marker
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Marker> {
        return NSFetchRequest<Marker>(entityName: "Marker")
    }
    
    /// Track to see if the current Marker is being edited.
    @NSManaged public var isEditing: Bool
    /// Latitude of the Marker.
    @NSManaged public var latitude: Double
    /// Optional rotation angle to lock the Marker to.
    @NSManaged public var lockRotationAngle: NSDecimalNumber?
    /// Longitude of the Marker.
    @NSManaged public var longitude: Double
    /// Name of the Marker,
    @NSManaged public var name: String?
    /// SFSymbol of the Marker.
    @NSManaged public var thumbnailImage: String?
    /// Tracker for showing or hiding this Marker from the background map.
    @NSManaged public var shown: Bool
    /// Color to display the Marker as.
    @NSManaged public var color: MarkerColor?
    /// Associated MapMaps to this Marke .
    @NSManaged public var mapMap: NSSet?

}

// MARK: Generated accessors for mapMap
extension Marker {

    /// Convenience function for associating this Marker to a single MapMap.
    /// - Parameter value: MapMap to associate to.
    @objc(addMapMapObject:)
    @NSManaged public func addToMapMap(_ value: MapMap)

    /// Convenience function for dissociating this Marker from a single MapMap.
    /// - Parameter value: MapMap to dissociate from.
    @objc(removeMapMapObject:)
    @NSManaged public func removeFromMapMap(_ value: MapMap)

    /// Convenience function for associating this Marker to multiple MapMaps.
    /// - Parameter value: MapMaps to associate to.
    @objc(addMapMap:)
    @NSManaged public func addToMapMap(_ values: NSSet)

    /// Convenience function for dissociating this Marker from multiple MapMaps.
    /// - Parameter value: MapMaps to dissociate from.
    @objc(removeMapMap:)
    @NSManaged public func removeFromMapMap(_ values: NSSet)

}

extension Marker : Identifiable {

}
