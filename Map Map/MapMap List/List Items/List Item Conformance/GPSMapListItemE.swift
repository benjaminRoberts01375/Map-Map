//
//  GPSMapE.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import SwiftUI

extension GPSMap: ListItem {
    var displayName: String { 
        get { self.name ?? GPSMap.defaultName }
        set { self.name = newValue == "" ? nil : newValue }
    }
    var thumbnail: any View {
        Image(systemName: "point.bottomleft.forward.to.point.topright.scurvepath.fill")
            .resizable()
            .scaledToFit()
            .padding(30)
    }
}
