//
//  Drawing+CoreDataClass.swift
//  
//
//  Created by Ben Roberts on 1/21/24.
//
//

import CoreData
import Foundation
import PencilKit

@objc(MapMapImageDrawing)
public class MapMapImageDrawing: NSManagedObject {
    var pkDrawing: PKDrawing? {
        get {
            if let data = self.drawingData {
                do { return try PKDrawing(data: data) }
                catch { return nil }
            }
            else { return nil }
        }
        set(newValue) {
            if self.mapMapImage == nil { return }
            if let updatedData = newValue?.dataRepresentation() { self.drawingData = updatedData }
        }
    }
    
    convenience init(context moc: NSManagedObjectContext, mapMapImage: MapMapImage, drawingData: Data) {
        self.init(context: moc)
        self.drawingData = drawingData
        self.mapMapImage = mapMapImage
    }
}
