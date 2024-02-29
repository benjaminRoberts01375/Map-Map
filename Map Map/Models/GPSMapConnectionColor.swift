//
//  GPSMapConnectionColor+CoreDataClass.swift
//  
//
//  Created by Ben Roberts on 2/20/24.
//
//

import CoreData
import SwiftUI

@objc(GPSMapConnectionColor)
public class GPSMapConnectionColor: NSManagedObject { 
    static let defaultRed = 0.26
    static let defaultGreen = 0.48
    static let defaultBlue = 0.92
    
    static var defaultColor = Color(
        red: GPSMapConnectionColor.defaultRed,
        green: GPSMapConnectionColor.defaultGreen,
        blue: GPSMapConnectionColor.defaultBlue
    )
}

extension GPSMapConnectionColor {
    convenience init(
        r red: Double = GPSMapConnectionColor.defaultRed,
        g green: Double = GPSMapConnectionColor.defaultGreen,
        b blue: Double = GPSMapConnectionColor.defaultBlue,
        moc: NSManagedObjectContext
    ) {
        self.init(context: moc)
        self.red = red
        self.green = green
        self.blue = blue
    }
}
