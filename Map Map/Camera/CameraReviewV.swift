//
//  CameraReviewV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/11/23.
//

import Bottom_Drawer
import SwiftUI

struct CameraReviewV: View {
    @Environment(\.dismiss) var dismiss
    @Binding var photoPassthrough: UIImage?
    var body: some View {
        if let image = photoPassthrough {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center]) { _ in
                    HStack {
                        Button(action: {
                            print("Accept")
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
