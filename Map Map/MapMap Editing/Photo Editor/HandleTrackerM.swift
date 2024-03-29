//
//  HandleTrackerM.swift
//  Map Map
//
//  Created by Ben Roberts on 2/7/24.
//

import SwiftUI

@Observable
final class HandleTrackerM {
    /// Corners generated by an automatic corner generator.
    public var autoCorners: CropCornersStorage?
    /// Current position of the corners that does not account for rotation,
    public var stockCorners: CropCornersStorage
    /// Current orientation of the corners
    public var orientation: Orientation = .standard
    /// Current position of corners when accounting for rotation.
    public var rotatedStockCorners: CropCornersStorage {
        switch orientation {
        case .standard: return stockCorners
        case .down: return stockCorners.rotateDown()
        case .left: return stockCorners.rotateLeft()
        case .right: return stockCorners.rotateRight()
        }
    }
    /// Corners generated by an automatic corner generator after they have bee
    public var rotatedAutoCorners: CropCornersStorage? {
        guard let autoCorners = autoCorners
        else { return nil }
        switch orientation {
        case .standard: return autoCorners
        case .down: return autoCorners.rotateDown()
        case .left: return autoCorners.rotateLeft()
        case .right: return autoCorners.rotateRight()
        }
    }
    
    init(stockCorners: CropCornersStorage) {
        self.stockCorners = stockCorners
    }
}

public enum Orientation: Int16 {
    case standard = 0
    case right = 1
    case down = 2
    case left = 3
}
