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
    var unwrappedCoordinates: [GPSMapCoordinate] {
        return self.coordinates?.array as? [GPSMapCoordinate] ?? []
    }
    
    /// Track how this GPS map is being edited.
    public enum EditingState: Int16 {
        case settingUp = 0
        case tracking = 1
        case editing = 2
        case viewing = 3
    }
    
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
        // Add new coordinate
        let newCoordinate = GPSMapCoordinate(location: clLocation, moc: moc)
        if let lastCoordinate = self.unwrappedCoordinates.last { // Coordinates exist
            lastCoordinate.addToNeighbors(newCoordinate)
            self.distance += Int32(clLocation.distance(from: lastCoordinate.clLocation)) // Cache increase in distance.
            if truncAlt > self.heightMax { self.heightMax = truncAlt }
            else if truncAlt < self.heightMin { self.heightMin = truncAlt }
        }
        else { // No previous coordinates available
            self.heightMax = truncAlt
            self.heightMin = truncAlt
        }
        self.addToCoordinates(newCoordinate)
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
