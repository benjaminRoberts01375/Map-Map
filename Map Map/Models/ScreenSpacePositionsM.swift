//
//  ScreenSpacePositionsM.swift
//  Map Map
//
//  Created by Ben Roberts on 12/6/23.
//

import SwiftUI

@Observable
final class ScreenSpacePositionsM {
    public var markerPositions: [Marker : CGPoint] = [:]
    public var mapMapPositions: [MapMap : CGRect] = [:]
}
