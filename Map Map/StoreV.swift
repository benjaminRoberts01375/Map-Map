//
//  StoreV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/21/24.
//

import StoreKit
import SwiftUI

struct StoreV: View {
    @Environment(\.dismiss) var dismiss
    @State var price = ""
    @State var presentNotAbleToRestorePurchases: Bool = false
    @State var purchased: Bool = false
    
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
                ScrollView {
                    VStack(spacing: 25) {
                        BulletPointV(
                            icon: "location.north.line.fill",
                            color: .red,
                            title: "GPS Maps",
                            description: "Create custom maps with GPS, and get real-time stats about your hike."
                        )
                        BulletPointV(
                            icon: "arrow.triangle.branch",
                            color: .brown,
                            title: "Trail Division",
                            description: "Divide your GPS Map into branches to match the trails."
                        )
                        BulletPointV(
                            icon: "app.badge.checkmark",
                            color: .accentColor,
                            title: "Future Development",
                            description: "Help fund future development, and get features beyond BYO map."
                        )
                    }
                    .padding(.horizontal)
                }
                Spacer()
                if !AppStore.canMakePayments {
                    Text("Device Cannot Make Payments")
                        .fontWeight(.bold)
                        .frame(height: 50)
                        .bigButton(backgroundColor: .blue.opacity(0.5), minWidth: 300)
                }
                else if purchased {
                    Text("Thank You!")
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
                            case .success(let verificationResult):
                                purchased = true
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
            LinearGradient(
                colors: [.white, .accentColor.opacity(0.75)],
                startPoint: UnitPoint(x: 0, y: UnitPoint.bottom.y * 0.75),
                endPoint: UnitPoint(x: 0, y: UnitPoint.bottom.y * 0.45)
            )
            .ignoresSafeArea()
        }
        .task { await getProductPrice() }
        .task { await checkIfPurchased() }
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
    
    func checkIfPurchased() async {
        let products = try? await Product.products(for: [Product.kExplorer])
        guard let product = products?.first else { return }
        let purchased = await product.latestTransaction
        await MainActor.run { self.purchased = purchased != nil }
    }
    
    func doubleCheckPurchased() async {
        for await update in Transaction.updates {
            guard let productID = try? update.payloadValue.productID else { continue }
            if productID == Product.kExplorer {
                await MainActor.run { purchased = true }
            }
        }
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) { StoreV() }
}

fileprivate struct MapMapExplorerTitleV: View {
    var body: some View {
        VStack {
            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .accessibilityHidden(true)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(radius: 10)
            Text("Map Map")
                .font(.system(size: 70).bold())
            Text("- Explorer -")
                .font(.system(size: 50).bold())
                .scaleEffect(x: 0.9)

        }
    }
}

fileprivate struct BulletPointV: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    private let size: CGFloat = 35
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .padding(.horizontal)
                .foregroundStyle(color)
                .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(title)
                    .bold()
                Text(description)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

extension Product { static let kExplorer: String = "explorer_one_time" }
