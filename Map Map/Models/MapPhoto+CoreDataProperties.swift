//
//  MapPhoto+CoreDataProperties.swift
//  Map Map
//
//  Created by Ben Roberts on 10/21/23.
//
//

import Foundation
import CoreData


extension MapMap {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MapMap> {
        return NSFetchRequest<MapMap>(entityName: "MapPhoto")
    }

    @NSManaged public var isEditing: Bool
    @NSManaged public var mapMapLatitude: NSDecimalNumber?
    @NSManaged public var mapMapLongitude: NSDecimalNumber?
    @NSManaged public var mapMapRawImage: Data?
    @NSManaged public var mapMapName: String?
    @NSManaged public var mapMapRawThumbnail: Data?
    @NSManaged public var mapMapScale: NSDecimalNumber?
    @NSManaged public var mapMapRotation: NSDecimalNumber?

}

extension MapMap : Identifiable {

}
