import SwiftUI

struct ContentView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(OnboardingViewModel.self) private var onboardingViewModel
    
    var body: some View {
        @Bindable var bindableOnboarding = onboardingViewModel
        
        Group {
            if let apiClient = authViewModel.apiClient {
                if #available(iOS 26.0, *) {
                    TabView {
                        Tab {
                            DashboardView()
                                .environment(DashboardViewModel(apiClient))
                        } label: {
                            Label("Dashboard", systemImage: "house.fill")
                        }
                        
                        Tab {
                            SettingsView()
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
                else {
                    TabView {
                        DashboardView()
                            .tabItem {
                                Label("Dashboard", systemImage: "house.fill")
                            }
                            .tag(Enums.TabViewTabs.dashboard)
                        SettingsView()
                            .tabItem {
                                Label("Settings", systemImage: "gear")
                            }
                            .tag(Enums.TabViewTabs.settings)
                    }
                }
               
            }
        }
        .fullScreenCover(isPresented: $bindableOnboarding.showOnboarding, content: {
            OnboardingView()
        })
    }
}
