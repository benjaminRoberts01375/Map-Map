//
//  PositionAlignmentVModifier.swift
//  Map Map
//
//  Created by Ben Roberts on 12/15/23.
//

import SwiftUI

public struct PositionAlignmentVModifier: ViewModifier {
    @State var offset: CGFloat = .zero
    let alignment: Alignment
    let position: CGPoint
    
    public enum Alignment {
        case top
        case bottom
        case leading
        case trailing
    }
    
    public func body(content: Content) -> some View {
        
        GeometryReader { geo in
            switch alignment {
            case .top:
                content
                    .background {
                        GeometryReader { geo in
                            Color.clear
                                .onAppear { offset = geo.size.height }
                        }
                    }
                    .position(x: position.x, y: position.y - offset)
            case .bottom:
                content
                    .background {
                        GeometryReader { geo in
                            Color.clear
                                .onAppear { offset = geo.size.height }
                        }
                    }
                    .position(x: position.x, y: position.y + offset)
            case .leading:
                content
                    .background {
                        GeometryReader { geo in
                            Color.clear
                                .onAppear { offset = geo.size.width }
                        }
                    }
                    .position(x: position.x - offset, y: position.y)
            case .trailing:
                content
                    .background {
                        GeometryReader { geo in
                            Color.clear
                                .onAppear { offset = geo.size.width }
                        }
                    }
                    .position(x: position.x + offset, y: position.y)
            }
        }
    }
}

public extension View {
    /// Position a view with a specific alignment.
    /// - Parameters:
    ///   - position: Origin to place at.
    ///   - alignment: Alignment of the view around the origin.
    /// - Returns: Translated view.
    func position(_ position: CGPoint = .zero, alignment: PositionAlignmentVModifier.Alignment) -> some View {
        modifier(PositionAlignmentVModifier(alignment: alignment, position: position))
    }
}
