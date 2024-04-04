//
//  StoreVM.swift
//  Map Map
//
//  Created by Ben Roberts on 4/4/24.
//

import StoreKit
import SwiftUI

extension StoreV {
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
    }
}
