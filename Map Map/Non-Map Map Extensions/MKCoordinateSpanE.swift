//
//  Span.swift
//  Map Map
//
//  Created by Ben Roberts on 3/17/24.
//

import MapKit

extension MKCoordinateSpan {
    static func * (span: MKCoordinateSpan, scalar: CGFloat) -> MKCoordinateSpan {
        return MKCoordinateSpan(
            latitudeDelta: span.latitudeDelta * CLLocationDegrees(scalar),
            longitudeDelta: span.longitudeDelta * CLLocationDegrees(scalar)
        )
    }
}
