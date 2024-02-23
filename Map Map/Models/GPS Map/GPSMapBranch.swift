//
//  GPSMapBranch+CoreDataClass.swift
//  
//
//  Created by Ben Roberts on 2/22/24.
//
//

import CoreData
import MapKit
import SwiftUI

@objc(GPSMapBranch)
public class GPSMapBranch: NSManagedObject {
    var unwrappedConnections: [GPSMapCoordinateConnection] {
        return (self.connections?.array as? [GPSMapCoordinateConnection] ?? []).filter { $0.end != nil }
    }
    
    /// Background color of the Marker.
    var branchColor: Color {
        get {
            if let color = self.color {
                return Color(red: color.red, green: color.green, blue: color.blue)
            }
            else {
                guard let moc = self.managedObjectContext else { return Color.red }
                let defaultColor = GPSMapConnectionColor(moc: moc)
                self.color = defaultColor
                return Color(red: defaultColor.red, green: defaultColor.green, blue: defaultColor.blue)
            }
        }
        set(newValue) {
            if let moc = self.managedObjectContext {
                var red: CGFloat = 0.0
                var green: CGFloat = 0.0
                var blue: CGFloat = 0.0
                var alpha: CGFloat = 0.0
                _ = UIColor(newValue).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                self.color = GPSMapConnectionColor(r: red, g: green, b: blue, moc: moc)
            }
        }
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

extension GPSMapBranch {
    convenience init(moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.color = GPSMapConnectionColor(moc: moc)
    }
}
