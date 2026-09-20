import Foundation

func showOnboardingIfNeeded() {
    let onboardingCompleted = UserDefaults.shared.bool(forKey: StorageKeys.onboardingCompleted)
    let hasServers = RepositoriesContainer.shared.serversManagerRepository.servers.isEmpty == false
    showOnboardingIfNeeded(onboardingCompleted: onboardingCompleted, hasServers: hasServers)
}

/// Parameterized variant of the onboarding decision, so it can be exercised in
/// tests without depending on the host app's persisted state (the app-group
/// UserDefaults and the CoreData store of the simulator it runs on).
func showOnboardingIfNeeded(onboardingCompleted: Bool, hasServers: Bool) {
    if !onboardingCompleted && !hasServers {
        NotificationCenter.default.post(name: .shouldShowOnboarding, object: nil)
    }
    else if !onboardingCompleted && hasServers {
        UserDefaults.shared.set(true, forKey: StorageKeys.onboardingCompleted)
    }
}
