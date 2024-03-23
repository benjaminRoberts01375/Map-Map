//
//  DeleteMapMapImageDrawingVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 3/23/24.
//

import SwiftUI

struct DeleteMapMapImageDrawingVModifier: ViewModifier {
    @Binding var isPresented: Bool
    var mapMapImage: MapMapImage?
    @Environment(\.managedObjectContext) var moc
    
    func body(content: Content) -> some View {
        content
            .alert(isPresented: $isPresented) {
                Alert(
                    title: Text("Map Map Drawing"),
                    message: Text("To change the shape of you Map Map, you must delete your drawing."),
                    primaryButton: .destructive(
                        Text("Delete and Crop"),
                        action: {
                            if let drawing = mapMapImage?.drawing { moc.delete(drawing) }
                            isPresented = false
                        }
                    ),
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
    }
}

extension View {
    func deleteMapMapImageDrawing(_ mapMapImage: MapMapImage?, isPresented: Binding<Bool>) -> some View {
        modifier(DeleteMapMapImageDrawingVModifier(isPresented: isPresented, mapMapImage: mapMapImage) )
    }
}
