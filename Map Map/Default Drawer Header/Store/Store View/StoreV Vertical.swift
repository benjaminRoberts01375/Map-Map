//
//  VerticalStoreV.swift
//  Map Map
//
//  Created by Ben Roberts on 4/4/24.
//

import SwiftUI

extension StoreV {
    struct VerticalStoreV: View {
        /// Dismiss function to hide this view.
        @Environment(\.dismiss) var dismiss
        /// Current user coloring
        @Environment(\.colorScheme) var colorScheme
        /// Alert presentation tracker.
        @Binding var viewModel: ViewModel
        /// Track if this package was purchased.
        @Binding var purchased: Bool
        
        var body: some View {
            ZStack(alignment: .top) {
                Color.clear
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.gray)
                            .frame(width: 40)
                            .padding()
                            .accessibilityLabel("Close Map Map Explorer buy page.")
                    }
                }
                VStack {
                    MapMapExplorerTitleV()
                        .padding(20)
                        .background {
                            if purchased {
                                Color.clear
                                    .onAppear { viewModel.confettiCounter += 1 }
                                    .confettiCannon(
                                        counter: $viewModel.confettiCounter,
                                        radius: 900,
                                        repetitions: 1000,
                                        repetitionInterval: 1
                                    )
                            }
                        }
                    BulletPointListV()
                    Spacer()
                    PurchaseButtonV(purchased: $purchased)
                    Button {
                        Task { await viewModel.restorePurchases() }
                    } label: {
                        Text("Restore Purchases...")
                            .foregroundStyle(.blue)
                            .opacity(purchased ? 0 : 1)
                    }
                    
                    .padding()
                    .disabled(purchased)
                }
            }
        }
    }
}
