//
//  GPSMapCoordinate+CoreDataClass.swift
//  
//
//  Created by Ben Roberts on 2/9/24.
//
//

import CoreData
import Foundation
import MapKit

@objc(GPSMapCoordinate)
public class GPSMapCoordinate: NSManagedObject { }

public extension GPSMapCoordinate {
    /// A convenience init for generating a GPSMapCoordinate from a clLocation.
    /// - Parameters:
    ///   - location: Location base.
    ///   - moc: Managed Object Context to store into.
    convenience init(location: CLLocation, moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.clLocation = location
        self.timestamp = .now
    }
    
    /// GPSMapCoordinate formatted as a clLocation
    private(set) var clLocation: CLLocation {
        get {
            CLLocation(
                coordinate: coordinates,
                altitude: self.altitude,
                horizontalAccuracy: self.horizontalAccuracy,
                verticalAccuracy: self.verticalAccuracy,
                course: self.course,
                speed: self.speed,
                timestamp: self.timestamp ?? .now
            )
        }
        set(newValue) {
            self.coordinates = newValue.coordinate
            self.altitude = newValue.altitude
            self.horizontalAccuracy = newValue.horizontalAccuracy
            self.verticalAccuracy = newValue.verticalAccuracy
            self.course = newValue.course
            self.speed = newValue.speed
            self.timestamp = newValue.timestamp
        }
    }
    
    /// GPSMapCoordinate formatted as a CLLocationCoordinate2D
    private(set) var coordinates: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)}
        set(newValue) {
            self.longitude = newValue.longitude
            self.latitude = newValue.latitude
        }
    }
}
