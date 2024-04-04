//
//  PurchaseButtonV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/22/24.
//

import StoreKit
import SwiftUI

extension StoreV {
    /// Handle switching out the button type depending on device and app status.
    struct PurchaseButtonV: View {
        /// Track if the Explorer package has been purchased
        @Environment(Store.self) var store
        /// Price of the explorer package.
        @State var price: String = ""
        
        var body: some View {
            if store.purchasedExplorer {
                Text("Thank You!")
                    .fontWeight(.bold)
                    .frame(height: 50)
                    .bigButton(backgroundColor: .blue.opacity(0.5), minWidth: 300)
            }
//            else if AppStore.canMakePayments {
//                Text("Device Cannot Make Payments")
//                    .fontWeight(.bold)
//                    .frame(height: 50)
//                    .bigButton(backgroundColor: .blue.opacity(0.5), minWidth: 300)
//            }
            else {
                Button {
                    Task {
                        let products = try await Product.products(for: ["explorer_one_time"])
                        guard let product = products.first else { return }
                        let result = try await product.purchase()
                        switch result {
                        case .success: await MainActor.run { store.purchasedExplorer = true }
                        default: break
                        }
                    }
                } label: {
                    Text("Become an Explorer" + price)
                        .fontWeight(.bold)
                        .frame(height: 50)
                        .bigButton(backgroundColor: .blue, minWidth: 300)
                }
                .task { await getProductPrice() }
            }
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
    }
}
