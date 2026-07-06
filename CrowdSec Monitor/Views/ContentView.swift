import SwiftUI

struct ContentView: View {
    @Environment(OnboardingViewModel.self) private var onboardingViewModel
    @State private var viewModel = ContentViewModel()
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    @Environment(\.scenePhase) private var scenePhase
    
    var hasServerConfigured: Bool {
        viewModel.hasServerConfigured
    }
    
    var hasNewVersion: Bool {
        viewModel.hasNewVersion
    }
    
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
            if hasServerConfigured {
                Group {
                    if #available(iOS 26.0, *) {
                        TabView {
                            Tab {
                                DashboardView()
                            } label: {
                                Label("Dashboard", systemImage: "house.fill")
                            }
                            
                            Tab {
                                AlertsListView()
                            } label: {
                                Label("Alerts", systemImage: "exclamationmark.triangle")
                            }
                            
                            Tab {
                                DecisionsListView()
                            } label: {
                                Label("Decisions", systemImage: "hammer")
                            }
                            
                            Tab {
                                ListsView()
                            } label: {
                                Label("Lists", systemImage: "shield")
                            }
                            
                            Tab {
                                SettingsView()
                            } label: {
                                Label("Settings", systemImage: "gear")
                            }
                            .badge(hasNewVersion ? 1 : 0)
                        }
                    }
                    else {
                        TabView {
                            DashboardView()
                                .tabItem {
                                    Label("Dashboard", systemImage: "house.fill")
                                }
                                .tag(Enums.TabViewTabs.dashboard)
                            
                            AlertsListView()
                                .tabItem {
                                    Label("Alerts", systemImage: "exclamationmark.triangle")
                                }
                                .tag(Enums.TabViewTabs.alerts)
                            
                            DecisionsListView()
                                .tabItem {
                                    Label("Decisions", systemImage: "hammer")
                                }
                                .tag(Enums.TabViewTabs.decisions)
                            
                  
                            ListsView()
                                .tabItem {
                                    Label("Lists", systemImage: "shield")
                                }
                                .tag(Enums.TabViewTabs.lists)
                            
                            SettingsView()
                                .tabItem {
                                    Label("Settings", systemImage: "gear")
                                }
                                .tag(Enums.TabViewTabs.settings)
                                .badge(hasNewVersion ? 1 : 0)
                        }
                    }
                }
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
        .onChange(of: scenePhase) { _, newPhase in
            guard hasServerConfigured else { return }
            switch newPhase {
            case .background:
                viewModel.closeWebSocket()
            case .active:
                viewModel.openWebSocket()
            default:
                break
            }
        }
        .onAppear {
            requestAppReview()
            showOnboardingIfNeeded()
        }
    }
}
