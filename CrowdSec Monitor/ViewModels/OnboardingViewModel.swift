import Foundation
import SwiftUI
import Network

@MainActor
@Observable
class OnboardingViewModel {
    static let shared = OnboardingViewModel()
    
    var showOnboarding: Bool = false
    var selectedTab: Int = 0

    private init() {}
    
    init(
        showOnboarding: Bool = false,
        selectedTab: Int = 0,
    ) {
        self.showOnboarding = showOnboarding
        self.selectedTab = selectedTab
    }
    
    func openOnboarding() {
        selectedTab = 0
        showOnboarding = true
    }
}
