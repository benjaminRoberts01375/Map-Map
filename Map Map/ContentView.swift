//
//  ContentView.swift
//  Map Map
//
//  Created by Ben Roberts on 9/13/23.
//

import Bottom_Drawer
import CoreData
import SwiftUI

struct ContentView: View {
    let blurAmount: CGFloat = 10
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                MapMap()
                    .ignoresSafeArea()
                BlurView()
                    .frame(width: geo.size.width, height: geo.safeAreaInsets.top)
                    .blur(radius: blurAmount)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
                BottomDrawer(
                    verticalDetents: [.small, .medium, .large],
                    horizontalDetents: [.left, .right],
                    header: {
                        HStack {
                            Text("Your Maps")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding([.leading])
                            Spacer()
                        }
                    },
                    content: {
                        MapsViewer()
                            .padding(.horizontal)
                    }
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
