//
//  MarkerSymbolPickerButtonV.swift
//  Map Map
//
//  Created by Ben Roberts on 4/30/24.
//

import SwiftUI

extension MarkerDisplayableEditorV {
    struct SymbolPickerButtonV: View {
        @State var showingImagePicker: Bool = false
        @ObservedObject var marker: Marker
        let height: CGFloat
        
        var body: some View {
            Button {
                showingImagePicker.toggle()
            } label: {
                Circle()
                    .fill(.gray)
                    .frame(width: 32)
                    .overlay {
                        marker.renderedThumbnailImage
                            .scaledToFit()
                            .scaleEffect(0.6)
                            .foregroundStyle(.white)
                    }
            }
            .popover(isPresented: $showingImagePicker) {
                MarkerSymbolPickerV(marker: marker)
                    .frame(minWidth: 335, minHeight: 300, maxHeight: height / 2)
                    .presentationCompactAdaptation(.popover)
            }
        }
    }
}
