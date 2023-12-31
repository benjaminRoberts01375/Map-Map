//
//  BlurView.swift
//  Map Map
//
//  Created by Ben Roberts on 9/14/23.
//

import SwiftUI

/// Effect view to blur on top of other views.
struct BlurView: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = UIBlurEffect() }
}
