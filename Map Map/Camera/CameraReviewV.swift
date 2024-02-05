//
//  CameraReviewV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/11/23.
//

import Bottom_Drawer
import SwiftUI

/// Review taken photo.
struct CameraReviewV: View {
    /// Managed Object Context to insert new MapMaps into.
    @Environment(\.managedObjectContext) private var moc
    /// Dismiss function for this view.
    @Environment(\.dismiss) private var dismiss
    /// Photo taken from camera.
    @Binding var photoPassthrough: UIImage?
    
    var body: some View {
        if let image = photoPassthrough {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .accessibilityLabel("Photo result from camera.")
                BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center]) { isShortCard in
                    HStack {
                        Button(action: {
                            guard let generatedImage = photoPassthrough else { return }
                            _ = MapMap(uiPhoto: generatedImage, moc: moc)
                            dismiss()
                        }, label: {
                            Text("Accept")
                                .bigButton(backgroundColor: .blue)
                        })
                        Button(action: {
                            photoPassthrough = nil
                        }, label: {
                            Text("Retake")
                                .bigButton(backgroundColor: .gray)
                        })
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("Cancel")
                                .bigButton(backgroundColor: .gray)
                        })
                    }
                    .padding(.bottom, isShortCard ? 0 : 10)
                }
            }
            .background(.black)
        }
    }
}
