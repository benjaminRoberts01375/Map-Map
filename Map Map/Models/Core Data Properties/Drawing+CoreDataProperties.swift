//
//  Drawing+CoreDataProperties.swift
//  
//
//  Created by Ben Roberts on 1/24/24.
//
//

import Foundation
import CoreData


extension Drawing {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Drawing> {
        return NSFetchRequest<Drawing>(entityName: "Drawing")
    }

    @NSManaged public var drawingData: Data?
    @NSManaged public var mapMapWidth: Double
    @NSManaged public var mapMapHeight: Double
    @NSManaged public var mapMap: MapMap?

}
