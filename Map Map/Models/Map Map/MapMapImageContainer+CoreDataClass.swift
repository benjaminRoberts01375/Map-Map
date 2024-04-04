//
//  MapMapImageContainer.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import CoreData
import SwiftUI

@objc(MapMapImageContainer)
public class MapMapImageContainer: NSManagedObject {
    var unwrappedImages: [MapMapImage] { self.images?.array as? [MapMapImage] ?? [] }
    /// The Map Map Image to be considered the most relevant.
    var activeContainerImage: MapMapImage? { self.unwrappedImages.last }
}

public extension MapMapImageContainer {
    /// Create a new container from a UI Image
    /// - Parameters:
    ///   - uiImage: Image to create container from.
    ///   - moc: Managed Object Context to insert into
    convenience init(uiImage: UIImage, moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.addToImages(MapMapImage(uiImage: uiImage, moc: moc))
    }
}
