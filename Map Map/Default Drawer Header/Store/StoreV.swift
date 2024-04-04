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
    @State var viewModel: ViewModel
    
    init(purchased: Binding<Bool>) { self._viewModel = State(initialValue: ViewModel(purchased: purchased)) }
    
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
                        if viewModel.purchased {
                            Color.clear
                                .onAppear { viewModel.confettiCounter += 1 }
                                .confettiCannon(counter: $viewModel.confettiCounter, radius: 700, repetitions: 1000, repetitionInterval: 1)
                        }
                    }
                BulletPointListV()
                Spacer()
                PurchaseButtonV(purchased: $viewModel.purchased)
                Button {
                    Task { await viewModel.restorePurchases() }
                } label: {
                    Text("Restore Purchases...")
                        .foregroundStyle(.blue)
                        .opacity(viewModel.purchased ? 0 : 1)
                }
                .padding()
                .disabled(viewModel.purchased)
            }
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
        .task { await viewModel.doubleCheckPurchased() }
        .inAppPurchaseFailed(isPresented: $viewModel.presentNotAbleToRestorePurchases)
        .animation(.easeOut, value: viewModel.purchased)
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) { StoreV(purchased: .constant(true)) }
}

extension StoreV {
    @Observable
    final class ViewModel {
        /// Alert presentation tracker.
        var presentNotAbleToRestorePurchases: Bool = false
        /// Track if this package was purchased.
        @ObservationIgnored
        @Binding var purchased: Bool
        /// Confetti controller.
        var confettiCounter: Int = 0
        
        init(purchased: Binding<Bool>) {
            self._purchased = purchased
        }
        
        /// Restore purchases if not activated.
        func restorePurchases() async {
            do { try await AppStore.sync() }
            catch {
                self.presentNotAbleToRestorePurchases = true
                print(error.localizedDescription)
            }
        }
        
        /// Catch if a purchase happened that wasn't previously caught.
        func doubleCheckPurchased() async {
            for await update in Transaction.updates {
                guard let productID = try? update.payloadValue.productID else { continue }
                if productID == Product.kExplorer {
                    await MainActor.run { self.purchased = true }
                }
            }
        }
    }
}
