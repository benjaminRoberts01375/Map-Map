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
}
