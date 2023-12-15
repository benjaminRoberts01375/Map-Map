//
//  FourCorners+CoreDataProperties.swift
//  Map Map
//
//  Created by Ben Roberts on 10/31/23.
//
//

import CoreData
import Foundation

extension FourCorners {
    
    /// Implement fetch request of all FourCorners
    /// - Returns: This four corners
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FourCorners> {
        return NSFetchRequest<FourCorners>(entityName: "FourCorners")
    }
    
    /// The bottom leading corner stored as a string in Core Data
    @NSManaged private var rawBottomLeading: String?
    /// The bottom trailing corner stored as a string in Core Data
    @NSManaged private var rawBottomTrailing: String?
    /// The top leading corner stored as a string in Core Data
    @NSManaged private var rawTopLeading: String?
    /// The top trailing corner stored as a string in Core Data
    @NSManaged private var rawTopTrailing: String?
    /// A corresponding map map within Core Data
    @NSManaged public var mapMap: MapMap?
    
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

extension FourCorners : Identifiable {

}
