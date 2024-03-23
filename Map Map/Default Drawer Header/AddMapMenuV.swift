//
//  AddMapMenuV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/22/24.
//

import SwiftUI

extension DefaultDrawerHeaderV {
    struct AddMapMenuV: View {
        /// Current Core Data managed object context.
        @Environment(\.managedObjectContext) private var moc
        
        @Binding var viewModel: DefaultDrawerHeaderV.ViewModel
        
        var body: some View {
            Button {
                viewModel.cameraPresented = true
            } label: {
                Label("Camera", systemImage: "camera.fill")
            }
            Button {
                viewModel.photosPickerPresented = true
            } label: {
                Label("Photo Library", systemImage: "photo.on.rectangle.angled")
                    .symbolRenderingMode(.hierarchical)
            }
            Button {
                viewModel.filePickerPresented = true
            } label: {
                Label("Files", systemImage: "folder.fill")
            }
            Button {
                viewModel.locationsHandler.requestAlwaysLocation()
                _ = GPSMap(moc: moc)
            } label: {
                Label("GPS", systemImage: "point.bottomleft.filled.forward.to.point.topright.scurvepath")
            }
        }
    }
}