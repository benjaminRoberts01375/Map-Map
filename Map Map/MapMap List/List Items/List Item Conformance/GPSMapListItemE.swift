//
//  GPSMapE.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import SwiftUI

extension GPSMap: ListItem {
    var displayName: String { self.name ?? GPSMap.defaultName }
    var thumbnail: any View {
        Image(systemName: "point.bottomleft.forward.to.point.topright.scurvepath.fill")
            .resizable()
            .scaledToFit()
            .padding(30)
    }
}
