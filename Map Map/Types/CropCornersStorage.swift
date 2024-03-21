//
//  CropCornersStorage.swift
//  Map Map
//
//  Created by Ben Roberts on 11/16/23.
//

import Foundation

/// A class that mirrors the functionality of the FourCorners core data class.
@Observable
public final class CropCornersStorage: Equatable, CustomStringConvertible {
    public var description: String {
        return """
Top Leading: \(topLeading), Top Trailing: \(topTrailing),
Bottom Leading: \(bottomLeading), Bottom Trailing: \(bottomTrailing)
"""
    }
    
    /// A FourCornersStorage where every value is zero'ed.
    static var zero = CropCornersStorage(topLeading: .zero, topTrailing: .zero, bottomLeading: .zero, bottomTrailing: .zero)
    
    var topLeading: CGSize
    var topTrailing: CGSize
    var bottomLeading: CGSize
    var bottomTrailing: CGSize
    
    /// Returns a new FourCornersStorage that has been rounded.
    /// - Returns: Rounded FourCornersStorage.
    func round() -> CropCornersStorage {
        return CropCornersStorage(
            topLeading: topLeading.rounded(),
            topTrailing: topTrailing.rounded(),
            bottomLeading: bottomLeading.rounded(),
            bottomTrailing: bottomTrailing.rounded()
        )
    }
    
    /// Take the current handles, and rotate them leftwards.
    /// - Returns: Self that has been rotated.
    func rotateLeft() -> CropCornersStorage {
        return CropCornersStorage(
            topLeading: self.topTrailing,
            topTrailing: self.bottomTrailing,
            bottomLeading: self.topLeading,
            bottomTrailing: self.bottomLeading
        )
    }
    
    /// Takes the current handles, and rotate them rightwards.
    /// - Returns: Self that has been rotated.
    func rotateRight() -> CropCornersStorage {
        return CropCornersStorage(
            topLeading: self.bottomLeading,
            topTrailing: self.topLeading,
            bottomLeading: self.bottomTrailing,
            bottomTrailing: self.topTrailing
        )
    }
    
    /// Returns a copy of this FourCornersStorage that has been rotated.
    /// - Returns: Self that has been rotated.
    func rotateDown() -> CropCornersStorage {
        return CropCornersStorage(
            topLeading: self.bottomTrailing,
            topTrailing: self.bottomLeading,
            bottomLeading: self.topTrailing, 
            bottomTrailing: self.topLeading
        )
    }
    
    /// Allow simple copying of this class.
    /// - Returns: A copy of this class.
    func copy() -> CropCornersStorage {
        return CropCornersStorage(
            topLeading: topLeading,
            topTrailing: topTrailing,
            bottomLeading: bottomLeading,
            bottomTrailing: bottomTrailing
        )
    }
    
    /// Allows for multiplying a FourCornersStorage by some CGSize
    /// - Parameters:
    ///   - storage: Base.
    ///   - scalar: Multiplier.
    static func *= (storage: CropCornersStorage, scalar: CGSize) {
        storage.topLeading *= scalar
        storage.topTrailing *= scalar
        storage.bottomLeading *= scalar
        storage.bottomTrailing *= scalar
    }
    
    /// Allows for multiplying a FourCornersStorage by some CGFloat
    /// - Parameters:
    ///   - storage: Base.
    ///   - scalar: Multiplier.
    static func * (storage: CropCornersStorage, scalar: CGSize) -> CropCornersStorage {
        return CropCornersStorage(
            topLeading: storage.topLeading * scalar,
            topTrailing: storage.topTrailing * scalar,
            bottomLeading: storage.bottomLeading * scalar, 
            bottomTrailing: storage.bottomTrailing * scalar
        )
    }
    
    /// Allows for comparing a CGSize to a FourCornersStorage
    /// - Parameters:
    ///   - lhs: Base FourCornersStorage
    ///   - rhs: Comparing to.
    static func != (lhs: CropCornersStorage, rhs: CGSize) -> Bool {
        lhs.topLeading != .zero ||
        lhs.topTrailing != CGSize(width: rhs.width, height: .zero) ||
        lhs.bottomLeading != CGSize(width: .zero, height: rhs.height) ||
        lhs.bottomTrailing != rhs
    }
    
    /// Allows for comparing a FourCornersStorage to another.
    /// - Parameters:
    ///   - lhs: Left FourCornersStorage.
    ///   - rhs: Right FourCornersStorage.
    /// - Returns: Compared result.
    public static func == (lhs: CropCornersStorage, rhs: CropCornersStorage) -> Bool {
        return lhs.topLeading == rhs.topLeading &&
        lhs.topTrailing == rhs.topTrailing &&
        lhs.bottomLeading == rhs.bottomLeading &&
        lhs.bottomTrailing == rhs.bottomTrailing
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
    
    init(corners: CropCornersStorage) {
        self.topLeading = corners.topLeading
        self.topTrailing = corners.topTrailing
        self.bottomLeading = corners.bottomLeading
        self.bottomTrailing = corners.bottomTrailing
    }
    
    init(corners: MapMapImageCropCorners) {
        self.topLeading = corners.topLeading
        self.topTrailing = corners.topTrailing
        self.bottomLeading = corners.bottomLeading
        self.bottomTrailing = corners.bottomTrailing
    }
}
