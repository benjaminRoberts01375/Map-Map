//
//  CameraV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/7/23.
//

import SwiftUI

struct CameraView: View {
    @State var cameraVM = CameraVM()

    var body: some View {
        VStack {
            ZStack {
                if let livePreview = cameraVM.livePreview {
                    Image(uiImage: livePreview)
                        .resizable()
                        .scaledToFit()
                }
                
                Button("Capture") {
                    cameraVM.capturePhoto()
                }
            }
            if let output = cameraVM.finalPhoto {
                Image(uiImage: output)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }
        }
        .onAppear {
            cameraVM.startSession()
        }
        .onDisappear {
            cameraVM.endSession()
        }
    }
}
