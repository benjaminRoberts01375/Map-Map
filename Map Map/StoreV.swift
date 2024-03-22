//
//  StoreV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/21/24.
//

import SwiftUI

struct StoreV: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.clear
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "x.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.gray)
                        .frame(width: 40)
                        .padding()
                        .accessibilityLabel("Close Map Map Explorer buy page.")
                }
            }
            VStack {
                MapMapExplorerTitleV()
                    .padding(20)
                ScrollView {
                    VStack(spacing: 25) {
                        BulletPointV(
                            icon: "location.north.line.fill",
                            color: .red,
                            title: "GPS Maps",
                            description: "Create custom maps with GPS and get real-time stats about your hike."
                        )
                        BulletPointV(
                            icon: "arrow.triangle.branch",
                            color: .brown,
                            title: "Trail Division",
                            description: "Divide your GPS Map into branches to match the trails."
                        )
                        BulletPointV(
                            icon: "app.badge.checkmark",
                            color: .accentColor,
                            title: "Future Development",
                            description: "Help fund future development, and get features beyond BYO map."
                        )
                    }
                    .padding(.horizontal)
                }
                Spacer()
                Button {
                    
                } label: {
                    Text("Become an Explorer $0.99")
                        .fontWeight(.bold)
                        .frame(height: 50)
                        .bigButton(backgroundColor: .blue, minWidth: 300)
                }
                
                Button {
                    
                } label: {
                    Text("Restore Purchases...")
                        .foregroundStyle(.blue)
                }
                .padding()
            }
        }
        .background {
            LinearGradient(
                colors: [.white, .accentColor.opacity(0.75)],
                startPoint: UnitPoint(x: 0, y: UnitPoint.bottom.y * 0.75),
                endPoint: UnitPoint(x: 0, y: UnitPoint.bottom.y * 0.45)
            )
            .ignoresSafeArea()
        }
        .onAppear {
            
        }
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) { StoreV() }
}

fileprivate struct MapMapExplorerTitleV: View {
    var body: some View {
        VStack {
            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .accessibilityHidden(true)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(radius: 10)
            Text("Map Map")
                .font(.system(size: 70).bold())
            Text("- Explorer -")
                .font(.system(size: 50).bold())
                .scaleEffect(x: 0.9)

        }
    }
}

fileprivate struct BulletPointV: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    private let size: CGFloat = 35
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .padding(.horizontal)
                .foregroundStyle(color)
                .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(title)
                    .bold()
                Text(description)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}
