//
//  Marker+CoreDataClass.swift
//  Map Map
//
//  Created by Ben Roberts on 11/20/23.
//
//

import CoreData
import MapKit
import SwiftUI

@objc(Marker)
public class Marker: NSManagedObject {
    /// A default name to display when the marker's name is not available.
    static let defaultName: String = "New Marker"
    
    /// Handles rendering the thumbnail of this Marker.
    var renderedThumbnailImage: Image {
        if let thumbnailImage = thumbnailImage {
            return Image(systemName: thumbnailImage)
                .resizable()
        }
        self.thumbnailImage = "star.fill"
        return Image(systemName: "star.fill")
            .resizable()
    }
    
    /// Formats the coordinates of the Marker.
    var coordinate: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude) }
        set(value) {
            self.latitude = value.latitude
            self.longitude = value.longitude
        }
    }
    
    /// Background color of the Marker.
    var backgroundColor: Color {
        get {
            if let color = self.color {
                return Color(red: color.red, green: color.green, blue: color.blue)
            }
            else {
                guard let context = self.managedObjectContext else { return Color.red }
                let defaultColor = MarkerColor(red: 0.95, green: 0.30, blue: 0.30, insertInto: context)
                self.color = defaultColor
                return Color(red: defaultColor.red, green: defaultColor.green, blue: defaultColor.blue)
            }
        }
        set(newValue) {
            if let context = self.managedObjectContext {
                var red: CGFloat = 0.0
                var green: CGFloat = 0.0
                var blue: CGFloat = 0.0
                var alpha: CGFloat = 0.0
                _ = UIColor(newValue).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                self.color = MarkerColor(red: red, green: green, blue: blue, insertInto: context)
            }
        }
    }
    
    /// Optional rotation angle as a double instead of NSDecimalNumber.
    var lockRotationAngleDouble: Double? {
        get { return self.lockRotationAngle?.doubleValue }
        set(newValue) {
            if let newValue = newValue {
                self.lockRotationAngle = NSDecimalNumber(value: newValue)
            }
            else { self.lockRotationAngle = nil }
        }
    }
    
    /// All associated MapMaps with this Marker.
    var formattedMapMaps: [MapMap] {
        let mapMapSet = self.mapMap as? Set<MapMap> ?? []
        return mapMapSet.sorted(by: { $0.coordinate < $1.coordinate })
    }
}

extension Marker {
    /// A convenience initializer for creating a Marker from a set of coordinates.
    /// - Parameters:
    ///   - coordinates: Coordinates to center the Marker on.
    ///   - context: Managed Object Context to store the Marker into
    public convenience init(coordinate: CLLocationCoordinate2D, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        self.coordinate = coordinate
    }
}
