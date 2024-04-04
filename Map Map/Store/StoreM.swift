//
//  Store.swift
//  Map Map
//
//  Created by Ben Roberts on 4/4/24.
//

import StoreKit
import SwiftUI

public enum StoreError: Error {
    case failedVerification
}

@Observable
final class Store {
    /// Store if the user has purchased explorer.
    #if DEBUG
    var purchasedExplorer: Bool = true
    #elseif DEBUG
    var purchasedExplorer: Bool = false
    #endif
    /// Task to run in background to listen for purchases.
    private var updateListenerTask: Task<Void, Error>?
    /// Track if the store is currently being presented to the user.
    var explorerStorePresented = false
    
    init() { self.updateListenerTask = listenForTransactions() }
    
    deinit { self.updateListenerTask?.cancel() }
    
    /// Constantly check for the user making a purchase.
    /// - Returns: Task to run in the background.
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    // Deliver products to the user.
                    self.updateCustomerProductStatus(transaction: transaction)

                    // Always finish a transaction.
                    await transaction.finish()
                } catch {
                    // StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    /// Ensure that the IAP was actually purchased.
    /// - Parameter result: Wrapped transaction.
    /// - Returns: Unwrapped transaction.
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            // StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            // The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
    /// Check transaction against known available purchases.
    /// - Parameter transaction: Transaction to test.
    func updateCustomerProductStatus(transaction: StoreKit.Transaction) {
        switch transaction.productID {
        case "explorer_one_time": self.purchasedExplorer = true
        default: break
        }
    }
}
