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
    /// Track the current status of purchases.
    @Environment(Store.self) var store
    /// Alert presentation tracker.
    @State var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        GeometryReader { geo in
            if geo.size.width > geo.size.height {
                HorizontalStoreV(viewModel: $viewModel)
                    .padding()
            }
            else { VerticalStoreV(viewModel: $viewModel) }
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
        .inAppPurchaseFailed(isPresented: $viewModel.presentNotAbleToRestorePurchases)
        .animation(.easeOut, value: store.purchasedExplorer)
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) { StoreV() }
}
