//
//  HandleTrackerM.swift
//  Map Map
//
//  Created by Ben Roberts on 11/12/23.
//

import SwiftUI

@Observable
final class HandleTrackerM {
    var topLeadingPoint: CGSize
    var topTrailingPoint: CGSize
    var bottomLeadingPoint: CGSize
    var bottomTrailingPoint: CGSize
    
    init(corners: FourCorners) {
        self._topLeadingPoint = corners.topLeading
        self._topTrailingPoint = corners.topTrailing
        self._bottomLeadingPoint = corners.bottomLeading
        self._bottomTrailingPoint = corners.bottomTrailing
    }
    
    init(width: CGFloat, height: CGFloat) {
        self._topLeadingPoint = .zero
        self._topTrailingPoint = CGSize(width: width, height: .zero)
        self._bottomLeadingPoint = CGSize(width: .zero, height: height)
        self._bottomTrailingPoint = CGSize(width: width, height: height)
    }
}
