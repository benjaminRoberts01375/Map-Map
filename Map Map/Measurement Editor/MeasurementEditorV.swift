//
//  MeasurementEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/15/23.
//

import Bottom_Drawer
import MapKit
import SwiftUI

struct MeasurementEditorV: View {
    /// Measurement to edit.
    @ObservedObject var measurement: FetchedResults<MapMeasurement>.Element
    /// Managed object context the measurement is stored in.
    @Environment(\.managedObjectContext) private var moc
    /// Real-world distance between the start and end points.
    @State private var distance: Measurement<UnitLength> = Measurement(value: .zero, unit: .meters)
    /// Screen-space position of the measuring point.
    @State private var startingPos: CGSize = .zero
    /// Screen-space position of the ending point.
    @State private var endingPos: CGSize = .zero
    /// Determine the line's orientation.
    @State private var lineOrientation: Orientation = .leftVertical
    /// Screen-space position of the center of the line.
    @State private var lineOrigin: CGPoint = .zero
    /// Track if dragging is currently happening.
    @State private var isDragging: Bool = false
    /// Map proxy generated by a MapReader.
    var mapContext: MapProxy
    
    /// Basic orientation and positioning for a line
    enum Orientation {
        case leftVertical
        case rightVertical
        case topHorizontal
        case bottomHorizontal
    }
    
    /// Drag gesture for creating a line from scratch.
    var drawGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { update in
                if !isDragging {
                    startingPos = CGSize(cgPoint: update.startLocation)
                    isDragging = true
                }
                endingPos = CGSize(cgPoint: update.location)
            }
            .onEnded { _ in
                isDragging = false
            }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black
                    .opacity(0.5)
                    .ignoresSafeArea()
                    .gesture(drawGesture)
                if endingPos != startingPos {
                    ZStack {
                        Line(startingPos: startingPos, endingPos: endingPos)
                            .stroke(lineWidth: 5.0)
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                        switch lineOrientation {
                        case .leftVertical:
                            Text(generateMeasurementText())
                                .position(lineOrigin, alignment: .trailing)
                        case .rightVertical:
                            Text(generateMeasurementText())
                                .position(lineOrigin, alignment: .leading)
                        case .topHorizontal:
                            Text(generateMeasurementText())
                                .position(lineOrigin, alignment: .bottom)
                        case .bottomHorizontal:
                            Text(generateMeasurementText())
                                .position(lineOrigin, alignment: .top)
                        }
                        HandleV(position: $startingPos)
                        HandleV(position: $endingPos)
                    }
                    .ignoresSafeArea()
                }
                
                BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center], shortCardSize: 350) { _ in
                    Button {
                        try? moc.save()
                        measurement.isEditing = false
                    } label: {
                        Text("Done")
                            .bigButton(backgroundColor: .blue.opacity(isValidMeasurement() ? 1 : 0.5))
                    }
                    .disabled(!isValidMeasurement())
                }
            }
            .onChange(of: startingPos) {
                calculateDistance()
                calculateLineOrientation(canvasSize: geo.size)
            }
            .onChange(of: endingPos) {
                calculateDistance()
                calculateLineOrientation(canvasSize: geo.size)
            }
        }
    }
    
    /// Calculate the real-world distance based on screen-space positions.
    private func calculateDistance() {
        guard let startingCoord = mapContext.convert(CGPoint(size: startingPos), from: .global),
              let endingCoord = mapContext.convert(CGPoint(size: endingPos), from: .global)
        else { return }
        let startLoc = CLLocation(latitude: startingCoord.latitude, longitude: startingCoord.longitude)
        let endLoc = CLLocation(latitude: endingCoord.latitude, longitude: endingCoord.longitude)
        self.distance = Measurement(value: endLoc.distance(from: startLoc), unit: .meters)
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
    
    /// Check if the current measurement is valid.
    /// - Returns: True if valid, False if invalid.
    private func isValidMeasurement() -> Bool {
        if startingPos == endingPos { return false }
        return true
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
