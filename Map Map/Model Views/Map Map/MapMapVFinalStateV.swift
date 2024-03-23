//
//  RenderMapMapV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/23/24.
//

import SwiftUI

extension MapMapV {
    struct MapMapImageFailedV: View {
        var body: some View {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.yellow)
                .accessibilityLabel("Could not load Map Map")
        }
    }

    struct MapMapImageLoading: View {
        var body: some View {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
        }
    }

    struct MapMapImageSuccessful: View {
        let image: UIImage
        let name: String
        
        var body: some View {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .accessibilityLabel(name)
        }
    }
}
