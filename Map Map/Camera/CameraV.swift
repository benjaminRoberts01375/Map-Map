//
//  CameraV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/11/23.
//

import SwiftUI

struct CameraV: View {
    @State var image: UIImage?
    
    var body: some View {
        if let _ = image {
            CameraReviewV(photoPassthrough: $image)
        }
        else {
            CameraPreviewV(photoPassthrough: $image)
        }
    }
}
