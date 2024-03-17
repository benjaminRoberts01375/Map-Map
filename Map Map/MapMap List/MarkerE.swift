//
//  MarkerListItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/3/23.
//

import SwiftUI

extension Marker: ListItem {
    var displayName: String { self.name ?? Marker.defaultName }
    var thumbnail: any View { MarkerV(marker: self) }
}
