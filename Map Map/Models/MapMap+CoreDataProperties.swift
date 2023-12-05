//
//  MapMap+CoreDataProperties.swift
//  Map Map
//
//  Created by Ben Roberts on 12/5/23.
//
//

import Foundation
import CoreData


extension MapMap {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MapMap> {
        return NSFetchRequest<MapMap>(entityName: "MapMap")
    }

    @NSManaged public var imageHeight: Double
    @NSManaged public var imageWidth: Double
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
    @NSManaged public var shown: Bool
    @NSManaged public var cropCorners: FourCorners?
    @NSManaged public var markers: NSSet?

}

// MARK: Generated accessors for markers
extension MapMap {

    @objc(addMarkersObject:)
    @NSManaged public func addToMarkers(_ value: Marker)

    @objc(removeMarkersObject:)
    @NSManaged public func removeFromMarkers(_ value: Marker)

    @objc(addMarkers:)
    @NSManaged public func addToMarkers(_ values: NSSet)

    @objc(removeMarkers:)
    @NSManaged public func removeFromMarkers(_ values: NSSet)

}

extension MapMap : Identifiable {

}
