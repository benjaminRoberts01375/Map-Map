//
//  CameraV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/11/23.
//

import SwiftUI

struct CameraV: View {
    @State private var image: UIImage?
    
    var body: some View {
        if image != nil { CameraReviewV(photoPassthrough: $image) }
        else { CameraPreviewV(photoPassthrough: $image) }
    }
}
