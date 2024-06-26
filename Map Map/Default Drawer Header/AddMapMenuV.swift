//
//  AddMapMenuV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/22/24.
//

import SwiftUI

extension DefaultDrawerHeaderV {
    /// Dedicated view for holding buttons for importing files/data.
    struct AddMapMenuV: View {
        /// Current Core Data managed object context.
        @Environment(\.managedObjectContext) private var moc
        
        @Environment(Store.self) private var store
        
        @Binding var viewModel: DefaultDrawerHeaderV.ViewModel
        
        var body: some View {
            Button(
                action: { viewModel.cameraPresented = true },
                label: { Label("Camera", systemImage: "camera.fill") }
            )
            Button(
                action: { viewModel.photosPickerPresented = true },
                label: {
                    Label("Photo Library", systemImage: "photo.on.rectangle.angled")
                        .symbolRenderingMode(.hierarchical)
                }
            )
            Button(
                action: { viewModel.filePickerPresented = true },
                label: { Label("Files", systemImage: "folder.fill") }
            )
            if store.purchasedExplorer {
                Button {
                    viewModel.locationsHandler.requestAlwaysLocation()
                    _ = GPSMap(moc: moc)
                } label: {
                    Label("GPS", systemImage: "point.bottomleft.filled.forward.to.point.topright.scurvepath")
                }
            }
            else {
                Button(
                    action: { store.explorerStorePresented = true },
                    label: { Label("GPS", systemImage: "dollarsign") }
                )
            }
        }
    }
}
