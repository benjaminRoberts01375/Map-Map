//
//  LineLabelVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 12/17/23.
//

import SwiftUI

struct LineLabelVModifier: ViewModifier {
    let startingPos: CGPoint
    let endingPos: CGPoint
    let distance: Measurement<UnitLength>
    
    /// Determine the line's orientation.
    @State private var lineOrientation: Orientation = .leftVertical
    /// Screen-space position of the center of the line.
    @State private var lineOrigin: CGPoint = .zero
    
    /// Basic orientation and positioning for a line
    enum Orientation {
        case leftVertical
        case rightVertical
        case topHorizontal
        case bottomHorizontal
    }
    
    func body(content: Content) -> some View {
        GeometryReader { geo in
            ZStack {
                content
                switch lineOrientation {
                case .leftVertical:
                    Text(LineLabelVModifier.generateMeasurementText(distance: distance))
                        .mapLabel()
                        .position(lineOrigin, alignment: .trailing)
                case .rightVertical:
                    Text(LineLabelVModifier.generateMeasurementText(distance: distance))
                        .mapLabel()
                        .position(lineOrigin, alignment: .leading)
                case .topHorizontal:
                    Text(LineLabelVModifier.generateMeasurementText(distance: distance))
                        .mapLabel()
                        .position(lineOrigin, alignment: .bottom)
                case .bottomHorizontal:
                    Text(LineLabelVModifier.generateMeasurementText(distance: distance))
                        .mapLabel()
                        .position(lineOrigin, alignment: .top)
                }
            }
            .foregroundStyle(.white)
            .fontWeight(.heavy)
            .onChange(of: startingPos, initial: true) { calculateLineOrientation(canvasSize: geo.size) }
            .onChange(of: endingPos, initial: true) { calculateLineOrientation(canvasSize: geo.size) }
        }
    }
    /// Determine how the line is oriented and positioned on screen.
    /// - Parameter canvasSize: Dimensions of the screen.
    private func calculateLineOrientation(canvasSize: CGSize) {
        let lineWidth = abs(startingPos.x - endingPos.x)
        let lineHeight = abs(startingPos.y - endingPos.y)
        let lineHorizontalCenter = (startingPos.x + endingPos.x) / 2
        let lineVerticalCenter = (startingPos.y + endingPos.y) / 2
        self.lineOrigin = CGPoint(x: lineHorizontalCenter, y: lineVerticalCenter)
        
        if lineWidth > lineHeight { // Horizontal line
            self.lineOrientation = lineVerticalCenter >= canvasSize.height / 2 ? .bottomHorizontal : .topHorizontal
        }
        else { // Vertical line
            self.lineOrientation = lineHorizontalCenter >= canvasSize.width / 2 ? .rightVertical : .leftVertical
        }
    }
    
    /// Handle small/large distances across metric and imperial and format into a string.
    /// - Returns: Distance formatted into a human-readable string.
    public static func generateMeasurementText(distance: Measurement<UnitLength>) -> String {
        let singleDecimal = "%.1f"
        let noDecimal = "%.0f"
        
        if Locale.current.measurementSystem == .us { // Imperial
            if distance.value > 150 {
                let formattedDistance = String(format: singleDecimal, distance.converted(to: .miles).value)
                return "\(formattedDistance) mi"
            }
            else {
                let formattedDistance = String(format: noDecimal, distance.converted(to: .feet).value)
                return "\(formattedDistance) ft"
            }
        }
        else { // Metric
            if distance.value > 100 {
                let formattedDistance = String(format: singleDecimal, distance.converted(to: .kilometers).value)
                return "\(formattedDistance) km"
            }
            else {
                let formattedDistance = String(format: noDecimal, distance.converted(to: .meters).value)
                return "\(formattedDistance) m"
            }
        }
    }
}

extension View {
    func lineLabel(startingPos: CGPoint, endingPos: CGPoint, distance: Measurement<UnitLength>) -> some View {
        modifier(LineLabelVModifier(startingPos: startingPos, endingPos: endingPos, distance: distance))
    }
}
