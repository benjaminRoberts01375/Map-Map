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

extension StoreV {
    struct HorizontalStoreV: View {
        /// Dismiss function to hide this view.
        @Environment(\.dismiss) var dismiss
        /// Current user coloring
        @Environment(\.colorScheme) var colorScheme
        /// Alert presentation tracker.
        @Binding var viewModel: ViewModel
        /// Track if this package was purchased.
        @Binding var purchased: Bool
        
        var body: some View {
            VStack {
                HStack(alignment: .top) {
                    MapMapExplorerTitleV()
                        .background {
                            if purchased {
                                Color.clear
                                    .onAppear { viewModel.confettiCounter += 1 }
                                    .confettiCannon(counter: $viewModel.confettiCounter, radius: 700, repetitions: 1000, repetitionInterval: 1)
                            }
                        }
                    BulletPointListV()
                    
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
                Spacer()
                HStack {
                    Button {
                        Task { await viewModel.restorePurchases() }
                    } label: {
                        Text("Restore Purchases...")
                            .foregroundStyle(.blue)
                            .opacity(purchased ? 0 : 1)
                    }
                    Spacer()
                    PurchaseButtonV(purchased: $purchased)
                }
                .padding(.horizontal, 30)
            }
        }
    }
    
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
                                    .confettiCannon(counter: $viewModel.confettiCounter, radius: 700, repetitions: 1000, repetitionInterval: 1)
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
    
    @Observable
    final class ViewModel {
        /// Alert presentation tracker.
        var presentNotAbleToRestorePurchases: Bool = false
        /// Confetti controller.
        var confettiCounter: Int = 0
        
        /// Restore purchases if not activated.
        func restorePurchases() async {
            do { try await AppStore.sync() }
            catch {
                self.presentNotAbleToRestorePurchases = true
                print(error.localizedDescription)
            }
        }
        
        /// Catch if a purchase happened that wasn't previously caught.
        func doubleCheckPurchased() async -> Bool {
            for await update in Transaction.updates {
                guard let productID = try? update.payloadValue.productID else { continue }
                if productID == Product.kExplorer {
                    return true
                }
            }
            return false
        }
    }
}
