//
//  Marker+CoreDataClass.swift
//  Map Map
//
//  Created by Ben Roberts on 11/20/23.
//
//

import CoreData
import MapKit
import SwiftUI

@objc(Marker)
public class Marker: NSManagedObject {
    var correctedThumbnailImage: Image {
        return Image(systemName: self.thumbnailImage ?? "star.fill")
            .resizable()
    }
    
    var thumbnail: some View {
        get {
            Circle()
                .fill(.red)
                .overlay {
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.6)
                        .foregroundStyle(.white)
                }
                .ignoresSafeArea(.all)
        }
    }
    
    var coordinates: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        }
        set(value) {
            self.latitude = value.latitude
            self.longitude = value.longitude
        }
    }
}

extension Marker {
    convenience public init(coordinates: CLLocationCoordinate2D, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        self.coordinates = coordinates
        NotificationCenter.default.post(name: .addedMarker, object: nil, userInfo: ["marker":self])
    }
}
