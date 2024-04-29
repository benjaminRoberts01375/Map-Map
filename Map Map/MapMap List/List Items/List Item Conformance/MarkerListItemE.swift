//
//  MarkerListItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/3/23.
//

import SwiftUI

extension Marker: ListItem {
    var displayName: String {
        get { self.name ?? Marker.defaultName }
        set { self.name = newValue == "" ? nil : newValue }
    }
    var thumbnail: any View { MarkerV(marker: self) }
}
