//
//  MarkerColor+CoreDataClass.swift
//  Map Map
//
//  Created by Ben Roberts on 11/28/23.
//
//

import CoreData
import Foundation

@objc(MarkerColor)
public class MarkerColor: NSManagedObject { }

extension MarkerColor {
    /// A convenience initializer for creating a MarkerColor with RGB values.
    /// - Parameters:
    ///   - red: 0 to 1 value for the amount of red in this color.
    ///   - green: 0 to 1 value for the amount of green in this color.
    ///   - blue: 0 to 1 value for the amount of blue in this color.
    ///   - context: Managed Object Context to store this Marker Color into
    public convenience init(red: Double, green: Double, blue: Double, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        self.red = red
        self.green = green
        self.blue = blue
    }
}
