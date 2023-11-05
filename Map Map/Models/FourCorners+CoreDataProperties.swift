//
//  FourCorners+CoreDataProperties.swift
//  Map Map
//
//  Created by Ben Roberts on 10/31/23.
//
//

import Foundation
import CoreData


extension FourCorners {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FourCorners> {
        return NSFetchRequest<FourCorners>(entityName: "FourCorners")
    }

    @NSManaged private var rawBottomLeading: String?
    @NSManaged private var rawBottomTrailing: String?
    @NSManaged private var rawTopLeading: String?
    @NSManaged private var rawTopTrailing: String?
    @NSManaged public var mapMap: MapMap?

    public var bottomLeading: CGSize {
        get { return NSCoder.cgSize(for: rawBottomLeading ?? "") }
        set(update) { rawBottomLeading = NSCoder.string(for: update) }
    }
    
    public var bottomTrailing: CGSize {
        get { return NSCoder.cgSize(for: rawBottomTrailing ?? "") }
        set(update) { rawBottomTrailing = NSCoder.string(for: update) }
    }
    
    public var topLeading: CGSize {
        get { return NSCoder.cgSize(for: rawTopLeading ?? "") }
        set(update) { rawTopLeading = NSCoder.string(for: update) }
    }
    
    public var topTrailing: CGSize {
        get { return NSCoder.cgSize(for: rawTopTrailing ?? "") }
        set(update) { rawTopTrailing = NSCoder.string(for: update) }
    }
}

extension FourCorners : Identifiable {

}
