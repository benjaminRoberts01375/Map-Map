//
//  UserIconV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/27/23.
//

import SwiftUI

struct PingingUserIconV: View {
    var body: some View {
        ZStack {
            PingingV()
            MapUserIcon()
                .frame(width: 24, height: 24)
        }
    }
}

/// Icon to represent the user.
struct MapUserIcon: View {
    var body: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .foregroundStyle(.white, .blue)
            .accessibilityLabel("Your current location")
    }
}

struct PingingV: View {
    /// Starting scale of animation,
    @State var scale: CGFloat = 0.1
    /// Starting opacity of animation
    @State var opacity: CGFloat = 0.5
    
    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 100, height: 100)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                let baseAnimation = Animation.easeInOut(duration: 3)
                let repeated = baseAnimation.repeatForever(autoreverses: false)
                
                withAnimation(repeated) {
                    scale = 1
                    opacity = 0
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PingingUserIconV()
    }
}
