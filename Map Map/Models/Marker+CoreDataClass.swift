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
    var coordinates: CLLocationCoordinate2D {
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
    
    /// Foreground color based on the background color.
    var forgroundColor: Color {
        if let backgroundColorComponents = self.color {
            return Marker.calculateForegroundColor(
                red: backgroundColorComponents.red,
                green: backgroundColorComponents.green,
                blue: backgroundColorComponents.blue
            )
        }
        return .white
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
        return mapMapSet.sorted(by: { $0.coordinates < $1.coordinates })
    }
    
    /// Determine what the foreground color of a Marker based on the provided RGB values.
    /// - Parameters:
    ///   - red: Red values 0 to 1.
    ///   - green: Green values 0 to 1.
    ///   - blue: Blue values 0 to 1.
    /// - Returns: Resulting visible color.
    static func calculateForegroundColor(red: Double, green: Double, blue: Double) -> Color {
        if red * 0.299 + green * 0.587 + blue * 0.114 > 0.5 { // Is a light color
            return .black
        }
        return .white
    }
    
    /// Determine what the foreground color of a Marker based on the provided color.
    /// - Parameter color: Color to base foreground color on.
    /// - Returns: Resulting visible color.
    static func calculateForgroundColor(color: Color) -> Color {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        _ = UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return Marker.calculateForegroundColor(red: red, green: green, blue: blue)
    }
}

extension Marker {
    /// A convenience initializer for creating a Marker from a set of coordinates.
    /// - Parameters:
    ///   - coordinates: Coordinates to center the Marker on.
    ///   - context: Managed Object Context to store the Marker into
    public convenience init(coordinates: CLLocationCoordinate2D, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        self.coordinates = coordinates
        NotificationCenter.default.post(name: .addedMarker, object: nil, userInfo: ["marker":self])
    }
}
