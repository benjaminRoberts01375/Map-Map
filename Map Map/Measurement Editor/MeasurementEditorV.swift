//
//  MeasurementEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/15/23.
//

import Bottom_Drawer
import SwiftUI

struct MeasurementEditorV: View {
    /// Information about the map being plotted on top of.
    @Environment(MapDetailsM.self) var mapDetails
    /// All available Markers.
    @FetchRequest(sortDescriptors: []) var markers: FetchedResults<Marker>
    /// Measurement to edit.
    @FetchRequest(sortDescriptors: []) var measurements: FetchedResults<MapMeasurementCoordinate>
    /// Managed object context the measurement is stored in.
    @Environment(\.managedObjectContext) internal var moc
    /// View model to store back-end logic.
    @State var viewModel: ViewModel
    
    init(editing: Binding<Editor>) {
        self._viewModel = State(initialValue: ViewModel(editing: editing))
    }
    
    var drawGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { update in
                if !viewModel.isDragging {
                    preDrag(startLocation: CGSize(cgPoint: update.startLocation))
                }
                snapToAnything(dragPosition: CGSize(cgPoint: update.location))
                if let newDistance = calculateDistanceBetweenPoints() { viewModel.distance = newDistance}
            }
            .onEnded { _ in
                viewModel.isDragging = false
                if let startingMeasurement = viewModel.selectedMeasurement {
                    combineSnapStartMeasurement(startingMeasurement: startingMeasurement)
                }
                else { combineSnapStartMeasurement() }
            }
    }
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                Color.black
                    .opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { viewModel.selectedMeasurement = nil }
                    .accessibilityAddTraits(.isButton)
                    .gesture(drawGesture)
                if viewModel.endingPos != viewModel.startingPos {
                    ZStack {
                        Line(startingPos: viewModel.startingPos, endingPos: viewModel.endingPos)
                            .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                            .shadow(radius: 2)
                            .lineLabel(
                                startingPos: CGPoint(size: viewModel.startingPos),
                                endingPos: CGPoint(size: viewModel.endingPos), 
                                distance: viewModel.distance
                            )
                        if viewModel.selectedMeasurement == nil { HandleV(position: $viewModel.startingPos) }
                        HandleV(position: $viewModel.endingPos)
                    }
                    .ignoresSafeArea()
                }
                
                ForEach(measurements) { measurement in
                    Button {
                        viewModel.selectedMeasurement = measurement
                    } label: {
                        HandleV(
                            position: handlePositionBinding(for: measurement),
                            color: viewModel.selectedMeasurement == measurement ? Color.highlightBlue : HandleV.defaultColor,
                            deferPosition: true
                        )
                    }
                    .position(
                        x: viewModel.handlePositions[measurement]?.width ?? .zero,
                        y: viewModel.handlePositions[measurement]?.height ?? .zero
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
                                viewModel.editing = .nothing
                                cleanupMeasurements()
                                try? moc.save()
                            } label: {
                                Text("Done")
                                    .bigButton(backgroundColor: .blue)
                            }
                            
                            // Delete button
                            Button( action: {
                                guard let selectedMeasurement = viewModel.selectedMeasurement
                                else { return }
                                moc.delete(selectedMeasurement)
                                viewModel.selectedMeasurement = nil
                                try? moc.save()
                            }, label: {
                                Text("Delete")
                                    .bigButton(backgroundColor: .red.opacity(viewModel.selectedMeasurement != nil ? 1 : 0.5))
                            })
                            .disabled(viewModel.selectedMeasurement == nil)
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
            generateSSHandlePositions()
        }
    }
}
