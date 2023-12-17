//
//  LabeledLine.swift
//  Map Map
//
//  Created by Ben Roberts on 12/16/23.
//

import SwiftUI

struct LabeledLineV: View {
    let startingPos: CGSize
    let endingPos: CGSize
    var distance: Measurement<UnitLength>
    
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
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Line(startingPos: startingPos, endingPos: endingPos)
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .shadow(radius: 2)
                switch lineOrientation {
                case .leftVertical:
                    Text(generateMeasurementText())
                        .mapLabel()
                        .position(lineOrigin, alignment: .trailing)
                case .rightVertical:
                    Text(generateMeasurementText())
                        .mapLabel()
                        .position(lineOrigin, alignment: .leading)
                case .topHorizontal:
                    Text(generateMeasurementText())
                        .mapLabel()
                        .position(lineOrigin, alignment: .bottom)
                case .bottomHorizontal:
                    Text(generateMeasurementText())
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
        let lineWidth = abs(startingPos.width - endingPos.width)
        let lineHeight = abs(startingPos.height - endingPos.height)
        let lineHorizontalCenter = (startingPos.width + endingPos.width) / 2
        let lineVerticalCenter = (startingPos.height + endingPos.height) / 2
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
    private func generateMeasurementText() -> String {
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
                let formattedDistance = String(format: singleDecimal, distance.converted(to: .meters).value)
                return "\(formattedDistance) km"
            }
            else {
                let formattedDistance = String(format: noDecimal, distance.converted(to: .meters).value)
                return "\(formattedDistance) m"
            }
        }
    }
}
