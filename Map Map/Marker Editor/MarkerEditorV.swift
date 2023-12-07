//
//  MarkerEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/20/23.
//

import Bottom_Drawer
import SwiftUI

struct MarkerEditorV: View {
    @State var saveAngle: Bool
    @State var workingName: String
    @State var showingImagePicker: Bool = false
    @Environment(\.managedObjectContext) var moc
    @Environment(ScreenSpacePositionsM.self) var screenSpacePositions
    @ObservedObject var marker: FetchedResults<Marker>.Element
    @Environment(BackgroundMapDetailsM.self) var backgroundMapDetails
    
    init(marker: FetchedResults<Marker>.Element) {
        self.marker = marker
        if let name = marker.name { self._workingName = State(initialValue: name) }
        else { self._workingName = State(initialValue: "") }
        self._saveAngle = State(initialValue: marker.lockRotationAngleDouble != nil)
        NotificationCenter.default.post(name: .editingMarker, object: nil, userInfo: ["editing":true])
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZStack(alignment: .topLeading) {
                    Button {
                        saveAngle.toggle()
                    } label: {
                        Image(systemName: saveAngle ? "lock.rotation" : "lock.open.rotation")
                            .opacity(saveAngle ? 1 : 0.75)
                            .mapButton()
                            .saturation(saveAngle ? 1 : 0)
                    }
                    Color.clear
                }
                .padding(.leading, 8)
                MarkerV(marker: marker)
                    .allowsHitTesting(false)
                    .frame(width: BackgroundMapPointsV.iconSize, height: BackgroundMapPointsV.iconSize)
                    .ignoresSafeArea()
                    .offset(y: -2)
                BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center], shortCardSize: 350) { _ in
                    VStack {
                        HStack {
                            TextField("Marker name", text: $workingName)
                                .padding(.all, 5)
                                .background(Color.gray.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(width: 205)
                            ColorPicker("", selection: $marker.backgroundColor, supportsOpacity: false)
                                .labelsHidden()
                            Button {
                                showingImagePicker.toggle()
                            } label: {
                                Circle()
                                    .fill(.gray)
                                    .frame(width: 32)
                                    .overlay {
                                        marker.correctedThumbnailImage
                                            .scaledToFit()
                                            .scaleEffect(0.6)
                                            .foregroundStyle(.white)
                                    }
                            }
                            .popover(isPresented: $showingImagePicker) { MarkerSymbolPickerV(marker: marker) }
                            .presentationCompactAdaptation(.popover)
                        }
                        HStack {
                            Button {
                                marker.isEditing = false
                                marker.name = workingName
                                marker.coordinates = backgroundMapDetails.position
                                marker.lockRotationAngleDouble = saveAngle ? backgroundMapDetails.rotation.degrees : nil
                                screenSpacePositions.markerPositions[marker] = CGPoint(
                                    x: geo.size.width / 2,
                                    y: geo.size.height / 2 + geo.safeAreaInsets.top - 2
                                )
                                if let overlappingMapMaps = screenSpacePositions.markerOverMapMaps(marker, backgroundMapRotation: backgroundMapDetails.rotation) {
                                    for mapMap in marker.formattedMapMaps { mapMap.removeFromMarkers(marker) } // Remove current marker from all MapMaps
                                    for mapMap in overlappingMapMaps { mapMap.addToMarkers(marker) } // Add Marker to relevant MapMaps
                                }
                                try? moc.save()
                            } label: {
                                Text("Done")
                                    .bigButton(backgroundColor: .blue)
                            }
                            Button {
                                moc.reset()
                            } label: {
                                Text("Cancel")
                                    .bigButton(backgroundColor: .gray)
                            }
                        }
                        
                    }
                }
            }
            .onDisappear { NotificationCenter.default.post(name: .editingMarker, object: nil, userInfo: ["editing":false]) }
        }
    }
}
