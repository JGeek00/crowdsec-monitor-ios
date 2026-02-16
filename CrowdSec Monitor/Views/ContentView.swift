import SwiftUI

struct ContentView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(OnboardingViewModel.self) private var onboardingViewModel
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    
    func getColorScheme(theme: Enums.Theme) -> ColorScheme? {
        switch theme {
            case .system:
                return nil
            case .light:
                return ColorScheme.light
            case .dark:
                return ColorScheme.dark
        }
    }
    
    var body: some View {
        @Bindable var bindableOnboarding = onboardingViewModel
        
        Group {
            if authViewModel.apiClient != nil {
                if #available(iOS 26.0, *) {
                    TabView {
                        Tab {
                            DashboardView()
                                .environment(DashboardViewModel.shared)
                        } label: {
                            Label("Dashboard", systemImage: "house.fill")
                        }
                        
                        Tab {
                            AlertsListView()
                                .environment(AlertsListViewModel.shared)
                                .environment(AlertDetailsViewModel())

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
                            .environment(DashboardViewModel.shared)
                            .tabItem {
                                Label("Dashboard", systemImage: "house.fill")
                            }
                            .tag(Enums.TabViewTabs.dashboard)
                        
                        AlertsListView()
                            .environment(AlertsListViewModel.shared)
                            .tabItem {
                                Label("Alerts", systemImage: "exclamationmark.triangle")
                            }
                            .tag(Enums.TabViewTabs.alerts)
                            .environment(AlertDetailsViewModel())
                        
                        SettingsView()
                            .tabItem {
                                Label("Settings", systemImage: "gear")
                            }
                            .tag(Enums.TabViewTabs.settings)
                    }
                }
               
            }
        }
        .fontDesign(.rounded)
        .preferredColorScheme(getColorScheme(theme: theme))
        .fullScreenCover(isPresented: $bindableOnboarding.showOnboarding, content: {
            OnboardingView()
                .fontDesign(.rounded)
                .preferredColorScheme(getColorScheme(theme: theme))
        })
    }
}
