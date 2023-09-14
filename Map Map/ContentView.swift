//
//  ContentView.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    let blurAmount: CGFloat = 10
    var body: some View {
        GeometryReader { geo in
            ZStack {
                MapMap()
                VStack {
                    BlurView()
                        .frame(width: geo.size.width + blurAmount * 2, height: geo.safeAreaInsets.top + blurAmount * 2)
                        .blur(radius: blurAmount)
                        .offset(x: -blurAmount, y: -blurAmount * 3)
                    Spacer()
                } // Top blur
                .allowsHitTesting(false)
            }
            .ignoresSafeArea()
        }
        .background(Color.black)
    }
}

#Preview {
    ContentView()
}
