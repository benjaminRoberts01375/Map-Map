//
//  MapListV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import SwiftUI

struct MapList: View {
    @FetchRequest(sortDescriptors: []) var maps: FetchedResults<MapPhoto>
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Your Maps")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom)
            VStack(spacing: 0) {
                ForEach(maps) { photo in
                    MapListItem(photo: photo)
                    Divider()
                }
            }
            .background(colorScheme == .dark ? Color.init(red: 0.2, green: 0.2, blue: 0.2) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}
