//
//  GPSMapCoordinateConnection+CoreDataClass.swift
//  
//
//  Created by Ben Roberts on 2/19/24.
//
//

import CoreData
import Foundation

@objc(GPSMapCoordinateConnection)
public class GPSMapCoordinateConnection: NSManagedObject {
    var start: GPSMapCoordinate? { self.coordinates?.array.first as? GPSMapCoordinate }
    var end: GPSMapCoordinate? { self.coordinates?.array.last as? GPSMapCoordinate }

public extension GPSMapCoordinateConnection {
    /// Create a GPSMapCoordinateConnection from a starting and ending point.
    /// - Parameters:
    ///   - start: Starting point.
    ///   - end: Ending point.
    ///   - context: Managed Object Context.
    convenience init(start: GPSMapCoordinate, end: GPSMapCoordinate? = nil, context: NSManagedObjectContext) {
        self.init(context: context)
        self.addToCoordinates(start)
        if let end = end { self.addToCoordinates(end) }
    }
}
