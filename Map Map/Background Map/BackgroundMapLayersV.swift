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
                        Text("\(String(format: "%.4f", abs(backgroundMapDetails.position.latitude)))º ").fontWidth(.condensed) +
                        Text(backgroundMapDetails.position.latitude < 0 ? "S" : "N")
                        
                        Text("Longitude: ") +
                        Text("\(String(format: "%.4f", abs(backgroundMapDetails.position.longitude)))º ").fontWidth(.condensed) +
                        Text(backgroundMapDetails.position.longitude < 0 ? "W" : "E")
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
        print("Called")
        if backgroundMapDetails.userRotation.degrees.isBetween(min: 90, max: 270) {
            label = "S"
        }
        else {
            label = "N"
        }
        
        if backgroundMapDetails.userRotation.degrees.isBetween(min: 180, max: 360) {
            label += "W"
        }
        else {
            label += "E"
        }
        return label
    }
}
