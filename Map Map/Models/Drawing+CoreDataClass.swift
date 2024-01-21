//
//  Drawing+CoreDataClass.swift
//  
//
//  Created by Ben Roberts on 1/21/24.
//
//

import Foundation
import CoreData

@objc(Drawing)
public class Drawing: NSManagedObject {
    convenience init(context moc: NSManagedObjectContext, mapMap: MapMap, drawingData: Data) {
        self.init(context: moc)
        mapMap.drawing = self
        self.drawingData = drawingData
    }
}
