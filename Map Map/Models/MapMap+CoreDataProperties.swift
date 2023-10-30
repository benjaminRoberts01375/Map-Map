//
//  MapMap+CoreDataProperties.swift
//  Map Map
//
//  Created by Ben Roberts on 10/28/23.
//
//

import Foundation
import CoreData


extension MapMap {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MapMap> {
        return NSFetchRequest<MapMap>(entityName: "MapMap")
    }

    @NSManaged public var isEditing: Bool
    @NSManaged public var mapDistance: Double
    @NSManaged public var mapMapLatitude: Double
    @NSManaged public var mapMapLongitude: Double
    @NSManaged public var mapMapName: String?
    @NSManaged public var mapMapEncodedImage: Data?
    @NSManaged public var mapMapEncodedThumbnail: Data?
    @NSManaged public var mapMapRotation: Double
    @NSManaged public var mapMapScale: Double
    @NSManaged public var isSetup: Bool

}

extension MapMap : Identifiable {

}
