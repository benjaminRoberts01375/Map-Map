//
//  BackgroundMapLayersV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/17/23.
//

import SwiftUI

struct BackgroundMapLayersV: View {
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    let blurAmount: CGFloat = 10
    let stringFormat: String = "%.4f"
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                BackgroundMap()
                    .ignoresSafeArea()
                BlurView()
                    .frame(width: geo.size.width, height: geo.safeAreaInsets.top)
                    .blur(radius: blurAmount)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Latitude: ") + 
                        Text("\(String(format: stringFormat, abs(backgroundMapDetails.position.latitude)))º ").fontWidth(.condensed) +
                        Text(backgroundMapDetails.position.latitude < 0 ? "S" : "N")
                        
                        Text("Longitude: ") +
                        Text("\(String(format: stringFormat, abs(backgroundMapDetails.position.longitude)))º ").fontWidth(.condensed) +
                        Text(backgroundMapDetails.position.longitude < 0 ? "W" : "E")
                        
                        Text("Heading: ") +
                        Text("\(String(format: stringFormat, backgroundMapDetails.userRotation.degrees))º").fontWidth(.condensed) +
                        Text(determineHeadingLabel())
                    }
                }
                .padding(5)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 11))
                .padding(.top, 25)
                .padding(.leading)
            }
        }
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
