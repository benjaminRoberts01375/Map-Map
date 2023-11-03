//
//  FourCorners+CoreDataClass.swift
//  Map Map
//
//  Created by Ben Roberts on 10/31/23.
//
//

import Foundation
import CoreData

@objc(FourCorners)
public class FourCorners: NSManagedObject {
    
}

extension FourCorners {
    convenience public init(
        topLeading: CGSize,
        topTrailing: CGSize,
        bottomLeading: CGSize,
        bottomTrailing: CGSize,
        insertInto context: NSManagedObjectContext
    ) {
        self.init(context: context)
        self.topLeading = topLeading
        self.topTrailing = topTrailing
        self.bottomLeading = bottomLeading
        self.bottomTrailing = bottomTrailing
    }
}
