import Foundation
import SwiftUI
import Network

@MainActor
@Observable
class OnboardingViewModel {

    var showOnboarding: Bool = false
    var selectedTab: Int = 0

    init(
        showOnboarding: Bool = false,
        selectedTab: Int = 0,
    ) {
        self.showOnboarding = showOnboarding
        self.selectedTab = selectedTab
        NotificationCenter.default.addObserver(forName: .shouldShowOnboarding, object: nil, queue: .main) { [weak self] _ in
            self?.openOnboarding()
        }
    }
    
    func openOnboarding() {
        selectedTab = 0
        showOnboarding = true
    }
    
    func finishOnboarding() {
        UserDefaults.shared.set(true, forKey: StorageKeys.onboardingCompleted)
        showOnboarding = false
    }
}
