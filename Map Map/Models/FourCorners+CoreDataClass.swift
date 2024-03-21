//
//  FourCorners+CoreDataClass.swift
//  Map Map
//
//  Created by Ben Roberts on 10/31/23.
//
//

import CoreData
import Foundation

/// Four corners that a MapMap is cropped on.
@objc(MapMapImageCropCorners)
public class MapMapImageCropCorners: NSManagedObject { }

extension MapMapImageCropCorners {
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
    
    /// Convenience variable for getting and setting the bottom leading corner as a CGSize.
    public var bottomLeading: CGSize {
        get { return NSCoder.cgSize(for: rawBottomLeading ?? "") }
        set(update) { rawBottomLeading = NSCoder.string(for: update) }
    }
    
    /// Convenience variable for getting and setting the bottom trailing corner as a CGSize.
    public var bottomTrailing: CGSize {
        get { return NSCoder.cgSize(for: rawBottomTrailing ?? "") }
        set(update) { rawBottomTrailing = NSCoder.string(for: update) }
    }
    
    /// Convenience variable for getting and setting the top leading corner as a CGSize.
    public var topLeading: CGSize {
        get { return NSCoder.cgSize(for: rawTopLeading ?? "") }
        set(update) { rawTopLeading = NSCoder.string(for: update) }
    }
    
    /// Convenience variable for getting and setting the top trailing corner as a CGSize.
    public var topTrailing: CGSize {
        get { return NSCoder.cgSize(for: rawTopTrailing ?? "") }
        set(update) { rawTopTrailing = NSCoder.string(for: update) }
    }
}
