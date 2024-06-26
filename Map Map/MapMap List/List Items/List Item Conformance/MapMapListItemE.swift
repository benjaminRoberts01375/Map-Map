//
//  CompactMapListItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/23/23.
//

import SwiftUI

extension MapMap: ListItem {
    var displayName: String { 
        get { self.name ?? MapMap.defaultName }
        set { self.name = newValue == "" ? nil : newValue }
    }
    var thumbnail: any View { MapMapV(self, imageType: .thumbnail) }
}
