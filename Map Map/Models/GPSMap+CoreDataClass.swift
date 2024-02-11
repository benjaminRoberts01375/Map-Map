//
//  GPSMap+CoreDataClass.swift
//  
//
//  Created by Ben Roberts on 2/9/24.
//
//

import CoreData
import Foundation

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
}

public extension GPSMap {
    /// Create a GPS Map correctly.
    /// - Parameter moc: Managed Object Context to insert this GPS map into.
    convenience init(moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.unwrappedEditing = .settingUp
    }
}
