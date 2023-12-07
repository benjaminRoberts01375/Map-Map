//
//  CameraV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/11/23.
//

import SwiftUI

/// Handle switching between the live camera and the camera output.
struct CameraV: View {
    /// Output from the camera
    @State private var image: UIImage?
    
    var body: some View {
        if image != nil { CameraReviewV(photoPassthrough: $image) }
        else { CameraPreviewV(photoPassthrough: $image) }
    }
}
