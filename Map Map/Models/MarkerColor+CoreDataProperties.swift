//
//  MarkerColor+CoreDataProperties.swift
//  Map Map
//
//  Created by Ben Roberts on 11/28/23.
//
//

import CoreData
import Foundation

extension MarkerColor {

    /// Implement fetch request of all MarkerColors
    /// - Returns: This MarkerColor
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MarkerColor> {
        return NSFetchRequest<MarkerColor>(entityName: "MarkerColor")
    }
    
    /// 0 to 1 value of the amount of red within a color.
    @NSManaged public var red: Double
    /// 0 to 1 value of the amount of green within a color.
    @NSManaged public var green: Double
    /// 0 to 1 value of the amount of blue within a color.
    @NSManaged public var blue: Double
    /// An associated Marker
    @NSManaged public var marker: Marker?

}

extension MarkerColor : Identifiable {

}
