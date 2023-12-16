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
    @ObservedObject var measurement: FetchedResults<MapMeasurement>.Element
    @Environment(\.managedObjectContext) var moc
    @Environment(BackgroundMapDetailsM.self) var backgroundMapDetails
    @State var startingPos: CGSize = .zero
    @State var endingPos: CGSize = .zero
    @State var isDragging: Bool = false
    @State var distance: Measurement<UnitLength> = Measurement(value: .zero, unit: .meters)
    var mapContext: MapProxy
    
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
            Text("\(self.distance.converted(to: .feet).value)")
        }
        .onChange(of: startingPos) { calculateDistance() }
        .onChange(of: endingPos) { calculateDistance() }
    }
    
    func calculateDistance() {
        guard let startingCoord = mapContext.convert(CGPoint(size: startingPos), from: .global),
              let endingCoord = mapContext.convert(CGPoint(size: endingPos), from: .global)
        else { return }
        let startLoc = CLLocation(latitude: startingCoord.latitude, longitude: startingCoord.longitude)
        let endLoc = CLLocation(latitude: endingCoord.latitude, longitude: endingCoord.longitude)
        self.distance = Measurement(value: endLoc.distance(from: startLoc), unit: .meters)
    }
    
    func isValidMeasurement() -> Bool {
        if startingPos == endingPos { return false }
        return true
    }
}
