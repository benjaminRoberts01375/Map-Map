//
//  FourCorners+CoreDataClass.swift
//  Map Map
//
//  Created by Ben Roberts on 10/31/23.
//
//

import CoreData
import Foundation

@objc(FourCorners)
public class FourCorners: NSManagedObject { }

extension FourCorners {
    /// Create a FourCorners with the data populated
    /// - Parameters:
    ///   - topLeading: Top leading corner of the four corners.
    ///   - topTrailing: Bottom trailing corner of the four corners.
    ///   - bottomLeading: Bottom leading corner of the four corners.
    ///   - bottomTrailing: Bottom trailing corner of the four corners.
    ///   - context: Core Data managed object context to store the FourCorners into.
    public convenience init(
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
