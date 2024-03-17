//
//  ListItemP.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import MapKit
import SwiftUI

protocol ListItem: ObservableObject, MapDisplayable {
    var displayName: String { get }
    var thumbnail: any View { get }
    var shown: Bool { get }
}
