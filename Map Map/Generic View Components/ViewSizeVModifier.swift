//
//  ViewSizeVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 1/7/24.
//

import SwiftUI

fileprivate struct OnViewResizes: ViewModifier {
    /// Current size of the view.
    @State var size: CGSize = .zero
    /// Initial and update sizes.
    let todo: (CGSize, CGSize) -> Void
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { imageGeo in
                    Color.clear
                        .onChange(of: imageGeo.size, initial: true) { initial, update in
                            todo(initial, update)
                        }
                }
            }
    }
}

extension View {
    func onViewResizes(_ todo: @escaping (CGSize, CGSize) -> Void) -> some View {
        modifier(OnViewResizes(todo: todo))
    }
}
