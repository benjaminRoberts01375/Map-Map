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
    var correctedThumbnailImage: Image {
        if let thumbnailImage = thumbnailImage {
            return Image(systemName: thumbnailImage)
                .resizable()
        }
        else {
            self.thumbnailImage = "star.fill"
            return Image(systemName: "star.fill")
                .resizable()
        }
    }
    
    var thumbnail: some View {
        Circle()
            .fill(self.backgroundColor)
            .overlay {
                self.correctedThumbnailImage
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.6)
                    .foregroundStyle(self.forgroundColor)
            }
            .ignoresSafeArea(.all)
    }
    
    var coordinates: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude) }
        set(value) {
            self.latitude = value.latitude
            self.longitude = value.longitude
        }
    }
    
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
                UIColor(newValue).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                self.color = MarkerColor(red: red, green: green, blue: blue, insertInto: context)
            }
        }
    }
    
    var forgroundColor: Color {
        if let backgroundColorComponents = self.color,
           backgroundColorComponents.red * 0.299 +
            backgroundColorComponents.green * 0.587 +
            backgroundColorComponents.blue * 0.114 > 0.5 { // Is a light color
            return .black
        }
        return .white
    }
}

extension Marker {
    convenience public init(coordinates: CLLocationCoordinate2D, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        self.coordinates = coordinates
        NotificationCenter.default.post(name: .addedMarker, object: nil, userInfo: ["marker":self])
    }
}
