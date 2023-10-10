//
//  MapEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//

import PhotosUI
import SwiftUI

struct MapsEditor: View {
    @Environment(\.managedObjectContext) var moc // For adding and removing
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors: []) var processedPhotos: FetchedResults<MapPhoto>
    @State var keyboardIsPresent: Bool = false
    
    var body: some View {
        VStack {
            TabView {
                ForEach(processedPhotos) { photo in
                    if photo.isEditing { MapEditor(photo: photo) }
                }
            }
            .tabViewStyle(.page)
            .statusBarHidden()
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                keyboardIsPresent = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardIsPresent = false
            }
            .animation(.easeInOut, value: keyboardIsPresent)
            .submitLabel(.done)
            if !keyboardIsPresent {
                DoneButton(
                    enabled: !keyboardIsPresent,
                    action: {
                        for map in processedPhotos {
                            map.markComplete()
                        }
                        do { try moc.save() }
                        catch { return }
                        dismiss()
                    }
                )
                .padding(.bottom, 20)
            }
        }
        .background(.black)
    }
}
