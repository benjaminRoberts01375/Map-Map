//
//  MapListV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import SwiftUI

struct MapList: View {
    @FetchRequest(sortDescriptors: []) var maps: FetchedResults<MapPhoto>
    
    var body: some View {
        ForEach(maps) { photo in
            MapListItem(photo: photo)
        }
    }
}
