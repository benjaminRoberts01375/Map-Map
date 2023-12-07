//
//  MapCenterV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/18/23.
//

import MapKit
import SwiftUI

struct BackgroundMapHudV: View {
    @Environment(BackgroundMapDetailsM.self) private var backgroundMapDetails
    @Environment(\.locationDisplayMode) private var locationDisplayMode
    @Binding var rawDisplayType: LocationDisplayMode
    @State private var showHeading: Bool = false
    private let stringFormat: String = "%.4f"
    
    var tap: some Gesture {
       TapGesture()
            .onEnded { _ in
                backgroundMapDetails.setMapRotation(newRotation: 0)
            }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text("Latitude: ") +
                Text(locationDisplayMode.degreesToString(latitude: backgroundMapDetails.position.latitude))
                    .fontWidth(.condensed)
                
                Text("Longitude: ") +
                Text(locationDisplayMode.degreesToString(longitude: backgroundMapDetails.position.longitude))
                    .fontWidth(.condensed)
                if showHeading {
                    Text("Heading: ") +
                    Text("\(String(format: stringFormat, backgroundMapDetails.userRotation.degrees))º ").fontWidth(.condensed) +
                    Text(determineHeadingLabel())
                }
            }
            Spacer(minLength: 0)
        }
        .frame(width: 175)
        .padding([.leading, .vertical], 10)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 11))
        .contextMenu {
            Button {
                let placemark = MKPlacemark(coordinate: backgroundMapDetails.position)
                let mapItem = MKMapItem(placemark: placemark)
                let launchOptions: [String : Any] = [
                    MKLaunchOptionsMapCenterKey: backgroundMapDetails.position,
                    MKLaunchOptionsMapSpanKey: backgroundMapDetails.span
                ]
                mapItem.openInMaps(launchOptions: launchOptions)
            } label: {
                Label("Open in Maps", systemImage: "map.fill")
            }
            Button {
                switch rawDisplayType {
                case .degrees:
                    rawDisplayType = .DMS
                case .DMS:
                    rawDisplayType = .degrees
                }
            } label: {
                switch rawDisplayType {
                case .degrees:
                    Label("Show Degrees, Minutes, Seconds", systemImage: "clock.fill")
                case .DMS:
                    Label("Show Degrees", systemImage: "numbersign")
                }
            }

        }
        .onChange(of: backgroundMapDetails.rotation) { _, update in
            withAnimation {
                showHeading = update.degrees != .zero
            }
        }
        .gesture(tap)
        .animation(.easeInOut, value: rawDisplayType)
    }
    
    func determineHeadingLabel() -> String {
        var label = ""
        let shareOfThePie = 67.5
        let quarter: Double = 90
        if backgroundMapDetails.userRotation.degrees < shareOfThePie {
            label += "N"
        }
        else if backgroundMapDetails.userRotation.degrees.isBetween(min: quarter * 4 - shareOfThePie, max: quarter * 4 + shareOfThePie) {
            label += "N"
        }
        if backgroundMapDetails.userRotation.degrees.isBetween(min: quarter * 2 - shareOfThePie, max: quarter * 2 + shareOfThePie) {
            label += "S"
        }
        if backgroundMapDetails.userRotation.degrees.isBetween(min: quarter - shareOfThePie, max: quarter + shareOfThePie) {
            label += "E"
        }
        if backgroundMapDetails.userRotation.degrees.isBetween(min: quarter * 3 - shareOfThePie, max: quarter * 3 + shareOfThePie) {
            label += "W"
        }
        
        return label
    }
}

struct BackgroundMapHudV_Previews: PreviewProvider {
    static var previews: some View {
        let backgroundMapDetails = BackgroundMapDetailsM()
        return BackgroundMapHudV(rawDisplayType: .constant(LocationDisplayMode.degrees))
            .environment(backgroundMapDetails)
    }
}
