//
//  MapMeasurement+CoreDataClass.swift
//  
//
//  Created by Ben Roberts on 12/15/23.
//
//

import CoreData
import Foundation
import MapKit

@objc(MapMeasurement)
public class MapMeasurement: NSManagedObject {
    /// Format starting coordinates as CLLocationCoordinate2D.
    var startingCoordinates: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: self.startingLatitude, longitude: self.startingLongitude) }
        set(newCoords) {
            self.startingLatitude = newCoords.latitude
            self.startingLongitude = newCoords.longitude
        }
    }
    
    /// Format ending coordinates as CLLocationCoordinate2D.
    var endingCoordinates: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: self.endingLatitude, longitude: self.endingLongitude) }
        set(newCoords) {
            self.endingLatitude = newCoords.latitude
            self.endingLongitude = newCoords.longitude
        }
    }
}
