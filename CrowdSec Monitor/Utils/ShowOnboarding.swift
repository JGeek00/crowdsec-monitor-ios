import Foundation

func showOnboardingIfNeeded() {
    let onboardingCompleted = UserDefaults.shared.bool(forKey: StorageKeys.onboardingCompleted)
    let hasServers = ServersManagerViewModel.shared.servers.isEmpty == false
    if !onboardingCompleted && !hasServers {
        OnboardingViewModel.shared.openOnboarding()
    }
    else if !onboardingCompleted && hasServers {
        UserDefaults.shared.set(true, forKey: StorageKeys.onboardingCompleted)
    }
}
