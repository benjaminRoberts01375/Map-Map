//
//  CameraReviewV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/11/23.
//

import Bottom_Drawer
import SwiftUI

struct CameraReviewV: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.dismiss) private var dismiss
    @Binding var photoPassthrough: UIImage?
    
    var body: some View {
        if let image = photoPassthrough {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .accessibilityLabel("Photo result from camera.")
                BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center]) { _ in
                    HStack {
                        Button(action: {
                            guard let generatedImage = photoPassthrough else { return }
                            _ = MapMap(rawPhoto: generatedImage, insertInto: moc)
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
                }
            }
            .background(.black)
        }
    }
}
