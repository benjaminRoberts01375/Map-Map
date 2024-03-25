//
//  ListItemP.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import MapKit
import SwiftUI

protocol ListItem: ObservableObject, MapDisplayable {
    /// Display name of the item to put in the list.
    var displayName: String { get }
    /// View to render as a thumbnail.
    var thumbnail: any View { get }
    /// Track if the list item is shown.
    var shown: Bool { get }
}
