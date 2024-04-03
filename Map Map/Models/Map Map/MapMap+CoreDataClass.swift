//
//  MapPhoto+CoreDataClass.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//
//

import CoreData
import MapKit
import SwiftUI

/// What the app is all about. Stores the GPS coordinates, scale, and more to place an image on the map.
@objc(MapMap)
public class MapMap: NSManagedObject {
    // Default name for a MapMap when one is not available to display.
    static let defaultName: String = "New Map Map"
    
    /// Formatted coordinates of the MapMap.
    public var coordinate: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude) }
        set(coordinates) {
            self.latitude = coordinates.latitude
            self.longitude = coordinates.longitude
        }
    }
    
    /// Formatted Markers that are associated with this MapMap.
    var unwrappedMarkers: [Marker] {
        let markerSet = self.markers as? Set<Marker> ?? []
        return markerSet.sorted(by: { $0.latitude < $1.latitude })
    }
    
    var unwrappedMapMapImageContainers: [MapMapImageContainer] { self.mapMapImageContainers?.array as? [MapMapImageContainer] ?? [] }
    
    var originalImage: MapMapImage? { self.unwrappedMapMapImageContainers.first?.unwrappedImages.first }
    var activeImage: MapMapImage? { self.unwrappedMapMapImageContainers.first?.unwrappedImages.last }
}

// MARK: Photo inits
extension MapMap {
    /// A convenience initializer for creating a MapMap from a UIImage.
    /// - Parameters:
    ///   - uiImage: Photo to base MapMap off of.
    ///   - moc: Managed Object Context to save into.
    public convenience init(uiImage: UIImage, moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.addToMapMapImageContainers(MapMapImageContainer(uiImage: uiImage, moc: moc))
        self.isEditing = true
    }
}

extension MapMap: EditableDataBlock {
    func startEditing() {
        self.isEditing = true
        NotificationCenter.default.post(name: .kEditing, object: self)
    }

    func endEditing() {
        self.isEditing = false
        NotificationCenter.default.post(name: .kEditing, object: self)
    }
}
