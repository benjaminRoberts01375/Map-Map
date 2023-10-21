//
//  MapPhoto+CoreDataProperties.swift
//  Map Map
//
//  Created by Ben Roberts on 10/21/23.
//
//

import Foundation
import CoreData


extension MapPhoto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MapPhoto> {
        return NSFetchRequest<MapPhoto>(entityName: "MapPhoto")
    }

    @NSManaged public var isEditing: Bool
    @NSManaged public var latitude: NSDecimalNumber?
    @NSManaged public var longitude: NSDecimalNumber?
    @NSManaged public var map: Data?
    @NSManaged public var mapName: String?
    @NSManaged public var mapThumbnail: Data?
    @NSManaged public var scale: NSDecimalNumber?
    @NSManaged public var rotation: NSDecimalNumber?

}

extension MapPhoto : Identifiable {

}
