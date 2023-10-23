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
    let alignment: HorizontalAlignment
    
    var body: some View {
        VStack(alignment: alignment) {
            Text(photo.mapName ?? "Unknown name")
                .font(.title3)
                .padding(.vertical, 7)
            HStack {
                AnyView(photo.getMap(.thumbnail))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .frame(width: 100, height: 100)
                    .background(.thickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading) {
                    if let coordinates = photo.coordinates {
                        VStack(alignment: .leading) {
                            Text("Latitude: ")
                            Text("\(coordinates.latitude.wholeDegrees)º \(coordinates.latitude.minutes)' \(coordinates.latitude.seconds)'' ")
                                .fontWidth(.condensed)
                                .padding(.bottom, 5)
                            Text("Longitude: ")
                            Text("\(coordinates.longitude.wholeDegrees)º \(coordinates.longitude.minutes)' \(coordinates.longitude.seconds)'' ")
                                .fontWidth(.condensed)
                        }
                        .foregroundStyle(.secondary)
                    }
                    else {
                        Text("Unknown location")
                    }
                }
            }
            .padding(.bottom, 12)
        }
    }
}
