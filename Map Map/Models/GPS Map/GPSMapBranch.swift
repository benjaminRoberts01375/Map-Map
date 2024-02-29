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
}

extension GPSMapBranch {
    convenience init(name: String = "Default", moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.name = name
        self.color = GPSMapConnectionColor(moc: moc)
    }
}
