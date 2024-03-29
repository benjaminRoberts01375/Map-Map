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
    /// Default name to display for the GPSMap if a name is not available.
    static let defaultName: String = "New GPS Map"
    
    /// Center coordinate of this GPSMap
    var coordinate: CLLocationCoordinate2D {
        get { return CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude) }
        set(newValue) {
            self.centerLatitude = newValue.latitude
            self.centerLongitude = newValue.longitude
        }
    }
    
    /// A simple getter for GPS Map Coordinates.
    var unwrappedBranches: [GPSMapBranch] { self.branches?.array as? [GPSMapBranch] ?? [] }
    
    /// Get an array of all the available connections for this MapMap
    var unwrappedConnections: [GPSMapCoordinateConnection] { self.connections?.array as? [GPSMapCoordinateConnection] ?? [] }
    
    /// All connections that do not have an associated branch
    var unsortedConnections: [GPSMapCoordinateConnection] { unwrappedConnections.filter { $0.branch == nil } }
    
    /// Allow adding a new coordinate from a CLLocation.
    /// - Parameter clLocation: CLLocation to add to this GPSMap.
    /// - Returns: Created GPSMapCoordinate if successful.
    public func addNewCoordinate(clLocation: CLLocation) -> GPSMapCoordinate? {
        guard let moc = self.managedObjectContext
        else { return nil }
        let newCoordinate = GPSMapCoordinate(location: clLocation, moc: moc)
        if let lastCoordinate = self.unwrappedConnections.last?.end,
            let lastTimeStamp = lastCoordinate.timestamp { // Update the calculated time
            self.time += abs(lastTimeStamp.timeIntervalSince(newCoordinate.timestamp ?? .now))
        }
        let truncAlt = Int16(clLocation.altitude) // Track min/max altitude
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
            Task { await setCoordinateBounds() }
            return newCoordinate
        }
        
        self.heightMax = truncAlt
        self.heightMin = truncAlt
        // Create new connection with current as start
        self.addToConnections(GPSMapCoordinateConnection(start: newCoordinate, context: moc))
        self.coordinate = clLocation.coordinate
        self.objectWillChange.send()
        return newCoordinate
    }
    
    // Determine center point and lat, long delta to contain this GPS Map
    private func setCoordinateBounds() async {
        var topLongitude: Double = -180
        var bottomLongitude: Double = 180
        var leadingLatitude: Double = -180
        var trailingLatitude: Double = 180
        
        for connection in unwrappedConnections {
            guard let coordinate = connection.start else { continue }
            if coordinate.longitude > topLongitude { topLongitude = coordinate.longitude }
            if coordinate.latitude > leadingLatitude { leadingLatitude = coordinate.latitude }
            if coordinate.longitude < bottomLongitude { bottomLongitude = coordinate.longitude }
            if coordinate.latitude < trailingLatitude { trailingLatitude = coordinate.latitude }
        }
        await MainActor.run { [leadingLatitude, trailingLatitude, topLongitude, bottomLongitude] in
            self.coordinate = CLLocationCoordinate2D(
                latitude: (leadingLatitude + trailingLatitude) / 2,
                longitude: (topLongitude + bottomLongitude) / 2
            )
            self.latitudeDelta = leadingLatitude - trailingLatitude
            self.longitudeDelta = topLongitude - bottomLongitude
        }
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
