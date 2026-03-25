import Foundation
import StoreKit

@MainActor
func requestAppReview() {
    let firstLaunchDate: Double? = UserDefaults.shared.double(forKey: StorageKeys.appFirstLaunched)
    let hasRequestedReview: Bool? = UserDefaults.shared.bool(forKey: StorageKeys.hasRequestedReview)
    
    let currentDate = Date().timeIntervalSince1970
            
    if firstLaunchDate == 0 {
        UserDefaults.shared.setValue(currentDate, forKey: StorageKeys.appFirstLaunched)
    } else {
        let oneDay: TimeInterval = 24 * 60 * 60
        guard let firstLaunchDate = firstLaunchDate else { return }
        if (currentDate - firstLaunchDate) >= oneDay && hasRequestedReview != true {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                #if os(iOS)
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                SKStoreReviewController.requestReview(in: windowScene)
                UserDefaults.shared.setValue(true, forKey: StorageKeys.hasRequestedReview)
                #endif
            }
        }
    }
}
