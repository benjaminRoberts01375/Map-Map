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
    /// Information about the map being plotted on top of.
    @Environment(MapDetailsM.self) var mapDetails
    /// All available Markers.
    @FetchRequest(sortDescriptors: []) var markers: FetchedResults<Marker>
    /// Measurement to edit.
    @FetchRequest(sortDescriptors: []) var measurements: FetchedResults<MapMeasurementCoordinate>
    /// Managed object context the measurement is stored in.
    @Environment(\.managedObjectContext) private var moc
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                Color.black
                    .opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { selectedMeasurement = nil }
                    .accessibilityAddTraits(.isButton)
                    .gesture(drawGesture)
                if endingPos != startingPos {
                    ZStack {
                        Line(startingPos: startingPos, endingPos: endingPos)
                            .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                            .shadow(radius: 2)
                            .lineLabel(startingPos: CGPoint(size: startingPos), endingPos: CGPoint(size: endingPos), distance: distance)
                        if selectedMeasurement == nil { HandleV(position: $startingPos) }
                        HandleV(position: $endingPos)
                    }
                    .ignoresSafeArea()
                }
                
                ForEach(measurements) { measurement in
                    Button {
                        selectedMeasurement = measurement
                    } label: {
                        HandleV(
                            position: handlePositionBinding(for: measurement), 
                            color: selectedMeasurement == measurement ? Color.highlightBlue : HandleV.defaultColor,
                            deferPosition: true
                        )
                    }
                    .position(
                        x: handlePositions[measurement]?.width ?? .zero,
                        y: handlePositions[measurement]?.height ?? .zero
                    )
                }
                .ignoresSafeArea()
                
                BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center]) { _ in
                    VStack {
                        Text("Drag to measure.")
                            .foregroundStyle(.secondary)
                        HStack {
                            // Done button
                            Button {
                                editing = .nothing
                                cleanupMeasurements()
                                try? moc.save()
                            } label: {
                                Text("Done")
                                    .bigButton(backgroundColor: .blue)
                            }
                            
                            // Delete button
                            Button( action: {
                                guard let selectedMeasurement = selectedMeasurement
                                else { return }
                                moc.delete(selectedMeasurement)
                                self.selectedMeasurement = nil
                                try? moc.save()
                            }, label: {
                                Text("Delete")
                                    .bigButton(backgroundColor: .red.opacity(selectedMeasurement != nil ? 1 : 0.5))
                            })
                            .disabled(selectedMeasurement == nil)
                        }
                    }
                }
            }
        }
        .onAppear {
            generateSSHandlePositions()
            mapDetails.preventFollowingUser()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { _ in
            generateSSHandlePositions()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
            cleanupMeasurements()
        }
    }
}
