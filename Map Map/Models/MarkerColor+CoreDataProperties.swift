//
//  MarkerColor+CoreDataProperties.swift
//  Map Map
//
//  Created by Ben Roberts on 11/28/23.
//
//

import Foundation
import CoreData


extension MarkerColor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MarkerColor> {
        return NSFetchRequest<MarkerColor>(entityName: "MarkerColor")
    }

    @NSManaged public var red: Double
    @NSManaged public var green: Double
    @NSManaged public var blue: Double
    @NSManaged public var marker: Marker?

}

extension MarkerColor : Identifiable {

}
