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
            if authViewModel.hasServerConfigured == true {
                Group {
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
                            } label: {
                                Label("Alerts", systemImage: "exclamationmark.triangle")
                            }
                            
                            Tab {
                                DecisionsListView()
                                    .environment(DecisionsListViewModel.shared)
                            } label: {
                                Label("Decisions", systemImage: "hammer")
                            }
                            
                            Tab {
                                ListsView()
                                    .environment(AllowlistsListViewModel.shared)
                                    .environment(BlocklistsListViewModel.shared)
                            } label: {
                                Label("Lists", systemImage: "shield")
                            }
                            
                            Tab {
                                SettingsView()
                            } label: {
                                Label("Settings", systemImage: "gear")
                            }
                            .badge(ServerStatusViewModel.shared.status.data?.csMonitorAPI.newVersionAvailable != nil ? 1 : 0)
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
                            
                            DecisionsListView()
                                .environment(DecisionsListViewModel.shared)
                                .tabItem {
                                    Label("Decisions", systemImage: "hammer")
                                }
                                .tag(Enums.TabViewTabs.decisions)
                            
                          
                            ListsView()
                                .environment(AllowlistsListViewModel.shared)
                                .environment(BlocklistsListViewModel.shared)
                                .tabItem {
                                    Label("Lists", systemImage: "shield")
                                }
                                .tag(Enums.TabViewTabs.lists)
                            
                            SettingsView()
                                .tabItem {
                                    Label("Settings", systemImage: "gear")
                                }
                                .tag(Enums.TabViewTabs.settings)
                                .badge(ServerStatusViewModel.shared.status.data?.csMonitorAPI.newVersionAvailable != nil ? 1 : 0)
                        }
                    }
                }
                .environment(ServerStatusViewModel.shared)
            }
            else {
                if #available(iOS 26.0, *) {
                    TabView {
                        Tab {
                            NoServersView()
                        } label: {
                            Label("Home", systemImage: "house")
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
                        NoServersView()
                            .tabItem {
                                Label("Home", systemImage: "house")
                            }
                            .tag(Enums.TabViewTabs.home)
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
        .onAppear {
            requestAppReview()
            showOnboardingIfNeeded()
        }
    }
}
