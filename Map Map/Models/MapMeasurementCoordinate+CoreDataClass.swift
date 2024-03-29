//
//  MapMeasurementCoordinate+CoreDataClass.swift
//  
//
//  Created by Ben Roberts on 12/22/23.
//
//

import CoreData
import MapKit

@objc(MapMeasurementCoordinate)
public class MapMeasurementCoordinate: NSManagedObject {
    /// All available neighbors to this MapMeasurementCoordinate as an array.
    public var unwrappedNeighbors: [MapMeasurementCoordinate] { self.neighbors?.allObjects as? [MapMeasurementCoordinate] ?? [] }
    /// CLLocationCoordinate2D formatting for this MapMeasurementCoordinate.
    public var coordinates: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude) }
        set(update) {
            self.latitude = update.latitude
            self.longitude = update.longitude
        }
    }
    /// clLocation formatting for this MapMeasurementCoordinate.
    public var clLocation: CLLocation { CLLocation(latitude: latitude, longitude: longitude) }
    
    public convenience init(coordinate: CLLocationCoordinate2D, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}
