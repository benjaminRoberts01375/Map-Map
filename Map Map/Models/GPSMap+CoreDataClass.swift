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
    var unwrappedConnections: [GPSMapCoordinateConnection] {
        return (self.connections?.array as? [GPSMapCoordinateConnection] ?? []).filter { $0.end != nil }
    }
    
    /// Track how this GPS map is being edited.
    public enum EditingState: Int16 {
        case settingUp = 0
        case tracking = 1
        case editing = 2
        case viewing = 3
    }
    
    /// Get the current editing state as an enum.
    var unwrappedEditing: EditingState {
        get { return EditingState(rawValue: self.editing) ?? .settingUp }
        set(newValue) { editing = newValue.rawValue }
    }
    
    /// Add a new coordinate to this GPS Map.
    /// - Parameter clLocation: Location to add.
    /// - Returns: Added GPSMapCoordinate if it was successful.
    public func addNewCoordinate(clLocation: CLLocation) -> GPSMapCoordinate? {
        guard let moc = self.managedObjectContext
        else { return nil }
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
            return newCoordinate
        }
        
        self.heightMax = truncAlt
        self.heightMin = truncAlt
        // Create new connection with current as start
        self.addToConnections(GPSMapCoordinateConnection(start: newCoordinate, context: moc))
        return newCoordinate
    }
}

public extension GPSMap {
    /// Create a GPS Map correctly.
    /// - Parameter moc: Managed Object Context to insert this GPS map into.
    convenience init(moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.unwrappedEditing = .settingUp
    }
}
