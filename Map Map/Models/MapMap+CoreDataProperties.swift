//
//  MapMap+CoreDataProperties.swift
//  Map Map
//
//  Created by Ben Roberts on 11/3/23.
//
//

import Foundation
import CoreData


extension MapMap {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MapMap> {
        return NSFetchRequest<MapMap>(entityName: "MapMap")
    }

    @NSManaged public var isEditing: Bool
    @NSManaged public var isSetup: Bool
    @NSManaged public var mapDistance: Double
    @NSManaged public var mapMapEncodedThumbnail: Data?
    @NSManaged public var mapMapLatitude: Double
    @NSManaged public var mapMapLongitude: Double
    @NSManaged public var mapMapName: String?
    @NSManaged public var mapMapPerspectiveFixedEncodedImage: Data?
    @NSManaged public var mapMapRawEncodedImage: Data?
    @NSManaged public var mapMapRotation: Double
    @NSManaged public var mapMapScale: Double
    @NSManaged public var imageWidth: Double
    @NSManaged public var cropCorners: FourCorners?

}

extension MapMap : Identifiable {

}
