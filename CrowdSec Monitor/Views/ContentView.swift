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
                            AlertsListView()
                                .environment(AlertsListViewModel(apiClient))
                        } label: {
                            Label("Alerts", systemImage: "exclamationmark.triangle")
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
                            .environment(DashboardViewModel(apiClient))
                            .tabItem {
                                Label("Dashboard", systemImage: "house.fill")
                            }
                            .tag(Enums.TabViewTabs.dashboard)
                        
                        AlertsListView()
                            .environment(AlertsListViewModel(apiClient))
                            .tabItem {
                                Label("Alerts", systemImage: "exclamationmark.triangle")
                            }
                            .tag(Enums.TabViewTabs.alerts)
                        
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
