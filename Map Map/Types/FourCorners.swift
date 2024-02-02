//
//  CornersM.swift
//  Map Map
//
//  Created by Ben Roberts on 11/16/23.
//

import Foundation

/// A class that mirrors the functionality of the FourCorners core data class.
@Observable
final class FourCornersStorage {
    /// A FourCornersStorage where every value is zero'ed.
    static var zero = FourCornersStorage(topLeading: .zero, topTrailing: .zero, bottomLeading: .zero, bottomTrailing: .zero)
    
    var topLeading: CGSize
    var topTrailing: CGSize
    var bottomLeading: CGSize
    var bottomTrailing: CGSize
    
    /// Allows for multiplying a FourCornersStorage by some CGSize
    /// - Parameters:
    ///   - storage: Base.
    ///   - scalar: Multiplier.
    static func *= (storage: FourCornersStorage, scalar: CGSize) {
        storage.topLeading *= scalar
        storage.topTrailing *= scalar
        storage.bottomLeading *= scalar
        storage.bottomTrailing *= scalar
    }
    
    init(topLeading: CGSize, topTrailing: CGSize, bottomLeading: CGSize, bottomTrailing: CGSize) {
        self.topLeading = topLeading
        self.topTrailing = topTrailing
        self.bottomLeading = bottomLeading
        self.bottomTrailing = bottomTrailing
    }
    
    init(fill: CGSize) {
        topLeading = .zero
        topTrailing = CGSize(width: fill.width, height: .zero)
        bottomLeading = CGSize(width: .zero, height: fill.height)
        bottomTrailing = fill
    }
    
    init(corners: FourCorners) {
        self.topLeading = corners.topLeading
        self.topTrailing = corners.topTrailing
        self.bottomLeading = corners.bottomLeading
        self.bottomTrailing = corners.bottomTrailing
    }
}
