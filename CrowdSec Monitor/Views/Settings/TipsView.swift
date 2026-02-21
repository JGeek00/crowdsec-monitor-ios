import SwiftUI
import StoreKit

struct TipsView: View {
    @Environment(TipsViewModel.self) private var tipsViewModel
    
    var body: some View {
        @Bindable var tipsViewModel = tipsViewModel
        Group {
            if tipsViewModel.products.isEmpty {
                ContentUnavailableView("Currently there are no options available", systemImage: "nosign")
            }
            else {
                List {
                    Section {
                        ForEach(tipsViewModel.products, id: \.self) { product in
                            item(product: product) {
                                tipsViewModel.purchase(product: product)
                            }
                        }
                    } header: {
                        Text("Hi! I'm the developer of CrowdSec Monitor.\nCrowdSec Monitor is free and I want it to remain free, but by offering this application on the App Store I run into some costs, such as Apple's developer license. I would appreciate a lot every donation to help me paying this costs.\nThank you.")
                            .padding(.bottom, 12)
                            .textCase(nil)
                    }
                }
            }
        }
        .navigationTitle("Tips")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if tipsViewModel.purchaseInProgress {
                    ProgressView()
                }
            }
        }
        .alert("Purchase failed or cancelled", isPresented: $tipsViewModel.failedPurchase) {} message: {
            Text("The purchase could not be completed. An error occured on the process or it has been cancelled by the user.")
        }.alert("Purchase completed successfully", isPresented: $tipsViewModel.successfulPurchase) {} message: {
            Text("The purchase has been completed. Thank you for contributing with the development and mantenience of this application.")
        }
        .background(Color.listBackground)
    }
    
    @ViewBuilder
    func item(product: SKProduct, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Text(product.localizedTitle)
                    .foregroundColor(.foreground)
                Spacer()
                if let currency = product.priceLocale.currency?.identifier {
                    Text(product.price.doubleValue, format: .currency(code: currency))
                }
                else {
                    Text(String(describing: "N/A"))
                }
            }
        }
        .disabled(tipsViewModel.purchaseInProgress)
    }
}
