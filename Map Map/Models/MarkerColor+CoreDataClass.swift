//
//  MarkerColor+CoreDataClass.swift
//  Map Map
//
//  Created by Ben Roberts on 11/28/23.
//
//

import Foundation
import CoreData

@objc(MarkerColor)
public class MarkerColor: NSManagedObject {

}

extension MarkerColor {
    convenience init(red: Double, green: Double, blue: Double, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        self.red = red
        self.green = green
        self.blue = blue
    }
}
