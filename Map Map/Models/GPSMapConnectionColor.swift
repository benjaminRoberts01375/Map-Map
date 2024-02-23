//
//  GPSMapConnectionColor+CoreDataClass.swift
//  
//
//  Created by Ben Roberts on 2/20/24.
//
//

import CoreData
import Foundation

@objc(GPSMapConnectionColor)
public class GPSMapConnectionColor: NSManagedObject { }

extension GPSMapConnectionColor {
    convenience init(r red: UInt8, g green: UInt8, b blue: UInt8, moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.red = Int16(red)
        self.green = Int16(green)
        self.blue = Int16(blue)
    }
}
