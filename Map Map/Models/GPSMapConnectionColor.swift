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
    /// Default 0 to 1 red value.
    public static let defaultRed = 0.26
    /// Default 0 to 1 green value.
    public static let defaultGreen = 0.48
    /// Default 0 to 1 blue value.
    public static let defaultBlue = 0.92
    /// Default SwiftUI color
    public static var defaultColor = Color(
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
