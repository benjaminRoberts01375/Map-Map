//
//  HandleTrackerM.swift
//  Map Map
//
//  Created by Ben Roberts on 2/7/24.
//

import SwiftUI

@Observable
final class HandleTrackerM {
    var autoCorners: FourCornersStorage? = nil
    var stockCorners: FourCornersStorage
    var orientation: Orientation = .up
    var rotatedStockCorners: FourCornersStorage {
        switch orientation {
        case .up:
            return stockCorners
        case .down:
            return FourCornersStorage(topLeading: stockCorners.bottomTrailing, topTrailing: stockCorners.bottomLeading, bottomLeading: stockCorners.topTrailing, bottomTrailing: stockCorners.topLeading)
        case .left:
            return FourCornersStorage(topLeading: stockCorners.topTrailing, topTrailing: stockCorners.bottomTrailing, bottomLeading: stockCorners.topLeading, bottomTrailing: stockCorners.bottomLeading)
        case .right:
            return FourCornersStorage(topLeading: stockCorners.bottomLeading, topTrailing: stockCorners.topLeading, bottomLeading: stockCorners.bottomTrailing, bottomTrailing: stockCorners.topTrailing)
        }
    }
    var rotatedAutoCorners: FourCornersStorage? {
        guard let autoCorners = autoCorners
        else { return nil }
        switch orientation {
        case .up:
            return stockCorners
        case .down:
            return FourCornersStorage(topLeading: autoCorners.bottomTrailing, topTrailing: autoCorners.bottomLeading, bottomLeading: autoCorners.topTrailing, bottomTrailing: autoCorners.topLeading)
        case .left:
            return FourCornersStorage(topLeading: autoCorners.topTrailing, topTrailing: autoCorners.bottomTrailing, bottomLeading: autoCorners.topLeading, bottomTrailing: autoCorners.bottomLeading)
        case .right:
            return FourCornersStorage(topLeading: autoCorners.bottomLeading, topTrailing: autoCorners.topLeading, bottomLeading: autoCorners.bottomTrailing, bottomTrailing: autoCorners.topTrailing)
        }
    }
    
    init(stockCorners: FourCornersStorage) {
        self.stockCorners = stockCorners
    }
}

enum Orientation {
    case up
    case down
    case left
    case right
}
