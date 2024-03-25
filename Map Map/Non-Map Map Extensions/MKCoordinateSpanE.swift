//
//  Span.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import MapKit

extension MKCoordinateSpan {
    /// Allow multiplying a MKCoordinateSpan by some scalar.
    /// - Parameters:
    ///   - span: Span to multiply
    ///   - scalar: Scale to multiply by.
    /// - Returns: Multiplied span
    static func * (span: MKCoordinateSpan, scalar: CGFloat) -> MKCoordinateSpan {
        return MKCoordinateSpan(
            latitudeDelta: span.latitudeDelta * CLLocationDegrees(scalar),
            longitudeDelta: span.longitudeDelta * CLLocationDegrees(scalar)
        )
    }
}
