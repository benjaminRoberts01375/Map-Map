//
//  MarkerEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/20/23.
//

import Bottom_Drawer
import SwiftUI

struct MarkerEditorV: View {
    @State var workingName: String = ""
    @State var showingImagePicker: Bool = false
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var marker: FetchedResults<Marker>.Element
    @EnvironmentObject var backgroundMapDetails: BackgroundMapDetailsM
    
    init(marker: FetchedResults<Marker>.Element) {
        self.marker = marker
        if let name = marker.name {
            self.workingName = name
        }
    }
    
    var body: some View {
        ZStack {
            marker.thumbnail
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
                        .popover(isPresented: $showingImagePicker) {
                            MarkerSymbolPickerV(marker: marker)
                        }
                        .presentationCompactAdaptation(.popover)
                    }
                    HStack {
                        Button {
                            marker.name = workingName
                            marker.coordinates = backgroundMapDetails.position
                            marker.isEditing = false
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
    }
}
