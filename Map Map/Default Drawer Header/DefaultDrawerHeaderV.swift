//
//  DefaultDrawerHeaderV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/6/23.
//

import SwiftUI

/// Information and buttons to display in the header of the default bottom drawer.
struct DefaultDrawerHeaderV: View {
    /// Current Core Data managed object context.
    @Environment(\.managedObjectContext) private var moc
    /// View model holding logic and functions.
    @State var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        HStack {
            Text("Your Map Maps")
                .font(.title)
                .fontWeight(.bold)
                .padding([.leading])
            Menu {
                AddMapMenuV(viewModel: $viewModel)
                    .onAppear { AddMapMapTip().invalidate(reason: .actionPerformed) }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .resizable()
                    .accessibilityLabel("Add Map Map Button")
                    .frame(width: 22, height: 22)
            }
            .popoverTip(AddMapMapTip())
            Spacer()
        }
        .onChange(of: viewModel.rawPhotos) { _, updatedRawPhotos in
            Task {
                if updatedRawPhotos.isEmpty { return }
                for rawPhoto in updatedRawPhotos {
                    guard let photoData = try? await rawPhoto.loadTransferable(type: Data.self),
                          let uiImage = UIImage(data: photoData)?.fixOrientation()
                    else { continue }
                    await MainActor.run { _ = MapMap(uiImage: uiImage, moc: moc) }
                }
            }
            viewModel.rawPhotos = []
        }
        .unknownImageType(isPresented: $viewModel.alertManager.fileNotReadable)
        .noFilePermission(isPresented: $viewModel.alertManager.noFilePermission)
        .unableToReadPDF(isPresented: $viewModel.alertManager.unableToReadPDF)
        .unknownImageType(isPresented: $viewModel.alertManager.unknownImageType)
        .photosPicker(
            isPresented: $viewModel.photosPickerPresented,
            selection: $viewModel.rawPhotos,
            maxSelectionCount: 1,
            matching: .images
        )
        .fileImporter(isPresented: $viewModel.filePickerPresented, allowedContentTypes: [.png, .jpeg, .pdf]) { result in
            switch result {
            case .success(let url): viewModel.generateMapMapFromURL(url, moc: moc)
            case .failure: return
            }
        }
        .sheet(isPresented: $viewModel.cameraPresented) { CameraV() }
        .sheet(isPresented: $viewModel.storePresented) { StoreV(purchased: $viewModel.boughtExplorer) }
    }
}
