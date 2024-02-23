//
//  GPSMapBranch+CoreDataClass.swift
//  
//
//  Created by Ben Roberts on 2/22/24.
//
//

import CoreData
import Foundation
import MapKit

@objc(GPSMapBranch)
public class GPSMapBranch: NSManagedObject {
    var unwrappedConnections: [GPSMapCoordinateConnection] {
        return (self.connections?.array as? [GPSMapCoordinateConnection] ?? []).filter { $0.end != nil }
    }
    
    public func addNewCoordinate(clLocation: CLLocation) -> GPSMapCoordinate? {
        guard let moc = self.managedObjectContext,
              let gpsMap = self.gpsMap
        else { return nil }
        let truncAlt = Int16(clLocation.altitude) // Track min/max altitude
        let newCoordinate = GPSMapCoordinate(location: clLocation, moc: moc)
        
        if let lastConnection = self.unwrappedConnections.last {
            if gpsMap.heightMax < truncAlt { gpsMap.heightMax = truncAlt }
            else if gpsMap.heightMin > truncAlt { gpsMap.heightMin = truncAlt }
            
            if let startCoordinate = lastConnection.end { // Create a new connection using previous end as new start
                self.addToConnections(GPSMapCoordinateConnection(start: startCoordinate, end: newCoordinate, context: moc))
                gpsMap.distance += Int32(clLocation.distance(from: startCoordinate.clLocation))
            }
            else if let startCoordinate = lastConnection.start { // Use the existing connection with current as new end
                lastConnection.end = newCoordinate
                gpsMap.distance += Int32(clLocation.distance(from: startCoordinate.clLocation))
            }
            return newCoordinate
        }
        
        gpsMap.heightMax = truncAlt
        gpsMap.heightMin = truncAlt
        // Create new connection with current as start
        self.addToConnections(GPSMapCoordinateConnection(start: newCoordinate, context: moc))
        return newCoordinate
    }
}
