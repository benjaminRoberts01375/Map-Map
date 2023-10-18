//
//  MapItemV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/10/23.
//

import SwiftUI

struct MapListItem: View {
    @ObservedObject var photo: FetchedResults<MapPhoto>.Element
    @EnvironmentObject var mapDetails: MapDetailsM
    
    var body: some View {
        HStack {
            AnyView(photo.getMap(.thumbnail))
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .frame(width: 100, height: 100)
                .background(.thickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.vertical)
            VStack(alignment: .leading) {
                if photo.isEditing { PlaceMap(photo: photo) }
                else if photo.longitude != 0 && photo.latitude != 0 { MapInfo(photo: photo) }
                else { InvokePlaceMap(photo: photo) }
            }
            Spacer(minLength: 0)
        }
    }
}
