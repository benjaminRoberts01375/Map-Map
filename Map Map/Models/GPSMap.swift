//
//  GPSMap+CoreDataClass.swift
//  
//
//  Created by Ben Roberts on 2/9/24.
//
//

import CoreData
import Foundation
import MapKit

@objc(GPSMap)
public class GPSMap: NSManagedObject { 
    /// A simple getter for GPS Map Coordinates.
    var unwrappedBranches: [GPSMapBranch] {
        return self.branches?.array as? [GPSMapBranch] ?? []
    }
    
    /// Get an array of all the available connections for this MapMap
    var unwrappedConnections: [GPSMapCoordinateConnection] {
        return self.connections?.array as? [GPSMapCoordinateConnection] ?? []
    }
    
    /// All connections that do not have an associated branch
    var unsortedConnections: [GPSMapCoordinateConnection] {
        return unwrappedConnections.filter({ $0.branch == nil })
    }
    
    /// Allow adding a new coordinate from a CLLocation.
    /// - Parameter clLocation: CLLocation to add to this GPSMap.
    /// - Returns: Created GPSMapCoordinate if successful.
    public func addNewCoordinate(clLocation: CLLocation) -> GPSMapCoordinate? {
        guard let moc = self.managedObjectContext
        else { return nil }
        if let lastCoordinate = self.unwrappedConnections.last?.end,
            let lastTimeStamp = lastCoordinate.timestamp { // Update the calculated time
            self.time += clLocation.timestamp.timeIntervalSince(lastTimeStamp)
        }
        let truncAlt = Int16(clLocation.altitude) // Track min/max altitude
        let newCoordinate = GPSMapCoordinate(location: clLocation, moc: moc)
        if let lastConnection = self.unwrappedConnections.last {
            if self.heightMax < truncAlt { self.heightMax = truncAlt }
            else if self.heightMin > truncAlt { self.heightMin = truncAlt }
            
            if let startCoordinate = lastConnection.end { // Create a new connection using previous end as new start
                self.addToConnections(GPSMapCoordinateConnection(start: startCoordinate, end: newCoordinate, context: moc))
                self.distance += Int32(clLocation.distance(from: startCoordinate.clLocation))
            }
            else if let startCoordinate = lastConnection.start { // Use the existing connection with current as new end
                lastConnection.end = newCoordinate
                self.distance += Int32(clLocation.distance(from: startCoordinate.clLocation))
            }
            else { return nil } // Something went horribly wrong to end up here >:(
            return newCoordinate
        }
        
        self.heightMax = truncAlt
        self.heightMin = truncAlt
        // Create new connection with current as start
        self.addToConnections(GPSMapCoordinateConnection(start: newCoordinate, context: moc))
        self.objectWillChange.send()
        return newCoordinate
    }
}

public extension GPSMap {
    /// Create a GPS Map correctly.
    /// - Parameter moc: Managed Object Context to insert this GPS map into.
    convenience init(moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.isEditing = true
    }
}
