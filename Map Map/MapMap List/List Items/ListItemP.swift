//
//  ListItemP.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import MapKit
import SwiftUI

protocol ListItem: ObservableObject {
    var displayName: String { get }
    var thumbnail: any View { get }
    var shown: Bool { get }
    var coordinates: CLLocationCoordinate2D { get }
}
