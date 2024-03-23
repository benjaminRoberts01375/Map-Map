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
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State var price = ""
    @State var presentNotAbleToRestorePurchases: Bool = false
    @Binding var purchased: Bool
    @State var confettiCounter: Int = 0
    
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
                                .confettiCannon(counter: $confettiCounter, radius: 700, repetitions: 1000, repetitionInterval: 1)
                        }
                    }
                BulletPointListV()
                Spacer()
                if purchased {
                    Text("Thank You!")
                        .fontWeight(.bold)
                        .frame(height: 50)
                        .bigButton(backgroundColor: .blue.opacity(0.5), minWidth: 300)
                }
                else if AppStore.canMakePayments {
                    Text("Device Cannot Make Payments")
                        .fontWeight(.bold)
                        .frame(height: 50)
                        .bigButton(backgroundColor: .blue.opacity(0.5), minWidth: 300)
                }
                else {
                    Button {
                        Task {
                            let products = try await Product.products(for: ["explorer_one_time"])
                            guard let product = products.first else { return }
                            let result = try await product.purchase()
                            switch result {
                            case .success: await MainActor.run { self.purchased = true }
                            default: break
                            }
                        }
                    } label: {
                        Text("Become an Explorer" + price)
                            .fontWeight(.bold)
                            .frame(height: 50)
                            .bigButton(backgroundColor: .blue, minWidth: 300)
                    }
                }
                
                Button {
                    Task { await restorePurchases() }
                } label: {
                    Text("Restore Purchases...")
                        .foregroundStyle(.blue)
                }
                .padding()
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
        .task { await getProductPrice() }
        .task { await doubleCheckPurchased() }
        .inAppPurchaseFailed(isPresented: $presentNotAbleToRestorePurchases)
    }
    
    func getProductPrice() async {
        do {
            let productIds = [Product.kExplorer]
            let products = try await Product.products(for: productIds)
            guard let product = products.first else { return }
            await MainActor.run { price = " \(product.displayPrice)" }
        }
        catch {
            print(error.localizedDescription)
        }
     }
    
    func restorePurchases() async {
        do { try await AppStore.sync() }
        catch {
            self.presentNotAbleToRestorePurchases = true
            print(error.localizedDescription)
        }
    }
    
    func doubleCheckPurchased() async {
        for await update in Transaction.updates {
            guard let productID = try? update.payloadValue.productID else { continue }
            if productID == Product.kExplorer {
                await MainActor.run { self.purchased = true }
            }
        }
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) { StoreV(purchased: .constant(true)) }
}
