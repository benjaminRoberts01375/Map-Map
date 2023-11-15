//
//  MapMapV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/15/23.
//

import SwiftUI

struct MapMapV: View {
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    
    var body: some View {
        AnyView(mapMap.getMap(.original))
    }
}
