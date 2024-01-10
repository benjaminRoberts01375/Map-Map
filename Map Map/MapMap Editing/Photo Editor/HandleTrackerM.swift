//
//  HandleTrackerM.swift
//  Map Map
//
//  Created by Ben Roberts on 11/12/23.
//

import SwiftUI

/// Contain data about handles.
@Observable
final class HandleTrackerM {
    /// Current corners.
    var corners: FourCornersStorage
    /// Initial corners.
    let initialCorners: FourCornersStorage
    
    /// Create a handle tracker from a FourCorners.
    /// - Parameter corners: Corners from a MapMap.
    init(corners: FourCorners) {
        let corners = FourCornersStorage(corners: corners)
        self.corners = corners
        self.initialCorners = corners
    }
    
    /// Create a handle tracker from a FourCornersStorage.
    /// - Parameter corners: Setup corners.
    init(corners: FourCornersStorage) {
        self.corners = corners
        self.initialCorners = corners
    }
}
