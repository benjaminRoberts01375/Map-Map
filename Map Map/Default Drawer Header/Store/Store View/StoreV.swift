//
//  StoreV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/21/24.
//

import ConfettiSwiftUI
import StoreKit
import SwiftUI

struct StoreV: View {
    /// Dismiss function to hide this view.
    @Environment(\.dismiss) var dismiss
    /// Current user coloring
    @Environment(\.colorScheme) var colorScheme
    /// Alert presentation tracker.
    @State var viewModel: ViewModel = ViewModel()
    /// Track if this package was purchased.
    @Binding var purchased: Bool
    
    var body: some View {
        GeometryReader { geo in
            if geo.size.width > geo.size.height {
                HorizontalStoreV(viewModel: $viewModel, purchased: $purchased)
                    .padding()
            }
            else { VerticalStoreV(viewModel: $viewModel, purchased: $purchased) }
        }
        .background {
            switch colorScheme {
            case .dark:
                LinearGradient(
                    colors: [.black, .mapMapSecondary],
                    startPoint: UnitPoint(x: 0, y: UnitPoint.bottom.y * 0.85),
                    endPoint: UnitPoint(x: 0, y: UnitPoint.bottom.y * 0.25)
                )
                .ignoresSafeArea()
            default:
                LinearGradient(
                    colors: [.white, .mapMapPrimary.opacity(0.75)],
                    startPoint: UnitPoint(x: 0, y: UnitPoint.bottom.y * 0.75),
                    endPoint: UnitPoint(x: 0, y: UnitPoint.bottom.y * 0.45)
                )
                .ignoresSafeArea()
            }
        }
        .task { 
            let purchased = await viewModel.doubleCheckPurchased()
            await MainActor.run { self.purchased = purchased }
        }
        .inAppPurchaseFailed(isPresented: $viewModel.presentNotAbleToRestorePurchases)
        .animation(.easeOut, value: purchased)
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) { StoreV(purchased: .constant(true)) }
}
