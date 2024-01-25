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

@objc(Drawing)
public class Drawing: NSManagedObject {
    var pkDrawing: PKDrawing? {
        get {
            if let data = self.drawingData {
                do { return try PKDrawing(data: data) }
                catch { return nil }
            }
            else { return nil }
        }
        set(newValue) {
            if self.mapMap == nil { return }
            if let updatedData = newValue?.dataRepresentation() { self.drawingData = updatedData }
        }
    }
    
    var mapMapSize: CGSize {
        get { CGSize(width: self.mapMapWidth, height: self.mapMapHeight) }
        set(newValue) {
            self.mapMapWidth = newValue.width
            self.mapMapHeight = newValue.height
        }
    }
    
    convenience init(context moc: NSManagedObjectContext, mapMap: MapMap, drawingData: Data) {
        self.init(context: moc)
        mapMap.drawing = self
        self.drawingData = drawingData
    }
}
