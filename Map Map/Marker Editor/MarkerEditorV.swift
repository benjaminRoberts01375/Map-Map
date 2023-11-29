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
    
    var body: some View {
        ZStack {
            BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center], shortCardSize: 350) { _ in
                VStack {
                    HStack {
                        TextField("Marker name", text: $workingName)
                            .padding(.all, 5)
                            .background(Color.gray.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(width: 205)
                        Button {
                            showingImagePicker.toggle()
                        } label: {
                            Circle()
                                .fill(.gray)
                                .frame(width: 40)
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
