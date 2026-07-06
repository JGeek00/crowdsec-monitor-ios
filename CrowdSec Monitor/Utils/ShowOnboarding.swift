import Foundation

func showOnboardingIfNeeded() {
    let onboardingCompleted = UserDefaults.shared.bool(forKey: StorageKeys.onboardingCompleted)
    let hasServers = RepositoriesContainer.shared.serversManagerRepository.servers.isEmpty == false
    if !onboardingCompleted && !hasServers {
        NotificationCenter.default.post(name: .shouldShowOnboarding, object: nil)
    }
    else if !onboardingCompleted && hasServers {
        UserDefaults.shared.set(true, forKey: StorageKeys.onboardingCompleted)
    }
}
