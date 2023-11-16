//
//  HandleTrackerM.swift
//  Map Map
//
//  Created by Ben Roberts on 11/12/23.
//

import SwiftUI

@Observable
final class HandleTrackerM {
    var corners: FourCornersStorage
    let initialCorners: FourCornersStorage
    
    init(corners: FourCorners) {
        let corners = FourCornersStorage(corners: corners)
        self.corners = corners
        self.initialCorners = corners
    }
    
    init(width: CGFloat, height: CGFloat) {
        let corners = FourCornersStorage(
            topLeading: .zero,
            topTrailing: CGSize(width: width, height: .zero),
            bottomLeading: CGSize(width: .zero, height: height),
            bottomTrailing: CGSize(width: width, height: height)
        )
        self.corners = corners
        self.initialCorners = corners
    }
}
