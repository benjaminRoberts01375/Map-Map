//
//  CornersM.swift
//  Map Map
//
//  Created by Ben Roberts on 11/16/23.
//

import Foundation

@Observable
final class FourCornersStorage {
    var topLeading: CGSize
    var topTrailing: CGSize
    var bottomLeading: CGSize
    var bottomTrailing: CGSize
    
    init(topLeading: CGSize, topTrailing: CGSize, bottomLeading: CGSize, bottomTrailing: CGSize) {
        self.topLeading = topLeading
        self.topTrailing = topTrailing
        self.bottomLeading = bottomLeading
        self.bottomTrailing = bottomTrailing
    }
    
    init(corners: FourCorners) {
        self.topLeading = corners.topLeading
        self.topTrailing = corners.topTrailing
        self.bottomLeading = corners.bottomLeading
        self.bottomTrailing = corners.bottomTrailing
    }
}
