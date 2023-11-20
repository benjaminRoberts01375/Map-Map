//
//  MapCenterV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/18/23.
//

import MapKit
import SwiftUI

struct BackgroundMapHudV: View {
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    @State private var displayType: locationDisplayMode = .degrees
    let stringFormat: String = "%.4f"
    
    private enum locationDisplayMode {
        case degrees
        case DMS
    }
    
    var tap: some Gesture {
       TapGesture()
            .onEnded { _ in
                switch displayType {
                case .degrees:
                    displayType = .DMS
                case .DMS:
                    displayType = .degrees
                }
            }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text("Latitude: ") +
                Text("\(generateDisplayCoordinates(degree: abs(backgroundMapDetails.position.latitude))) ").fontWidth(.condensed) +
                Text(backgroundMapDetails.position.latitude < 0 ? "S" : "N")
                
                Text("Longitude: ") +
                Text("\(generateDisplayCoordinates(degree: abs(backgroundMapDetails.position.longitude))) ").fontWidth(.condensed) +
                Text(backgroundMapDetails.position.longitude < 0 ? "W" : "E")
                
                Text("Heading: ") +
                Text("\(String(format: stringFormat, backgroundMapDetails.userRotation.degrees))º ").fontWidth(.condensed) +
                Text(determineHeadingLabel())
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 11))
        .contextMenu {
            Button {
                let placemark = MKPlacemark(coordinate: backgroundMapDetails.position)
                let mapItem = MKMapItem(placemark: placemark)
                print(backgroundMapDetails.span)
                let launchOptions: [String : Any] = [
                    MKLaunchOptionsMapCenterKey: backgroundMapDetails.position,
                    MKLaunchOptionsMapSpanKey: backgroundMapDetails.span
                ]
                mapItem.openInMaps(launchOptions: launchOptions)
            } label: {
                Label("Open in Maps", systemImage: "map.fill")
            }
        }
        .gesture(tap)
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
    
    private func generateDisplayCoordinates(degree: CLLocationDegrees) -> String {
        switch displayType {
        case .degrees:
            return "\(String(format: stringFormat, degree))º "
        case .DMS:
            return "\(degree.wholeDegrees)º \(degree.minutes)' \(degree.seconds)\" "
        }
    }
}

struct BackgroundMapHudV_Previews: PreviewProvider {
    static var previews: some View {
        let backgroundMapDetails = BackgroundMapDetailsM()
        
        return BackgroundMapHudV()
            .environmentObject(backgroundMapDetails)
    }
}
