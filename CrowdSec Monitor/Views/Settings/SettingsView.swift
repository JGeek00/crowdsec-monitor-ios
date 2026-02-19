import SwiftUI

struct SettingsView: View {
    
    @SharedAppStorage(StorageKeys.theme) private var theme: Enums.Theme = Defaults.theme
    
    @Environment(\.colorScheme) private var colorScheme
    
    @Environment(ServerStatusViewModel.self) private var serverStatusViewModel
    
    @State private var showBuildNumber = false
    @State private var crowdsecWebOpen = false
    @State private var myOtherAppsOpen = false
    @State private var appDetailsOpen = false
    
    var body: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        NavigationStack {
            List {
                Picker("Theme", selection: $theme) {
                    ListRowWithIconEntry(systemIcon: "iphone", iconColor: .green, label: "System defined")
                        .tag(Enums.Theme.system)
                    ListRowWithIconEntry(systemIcon: "sun.max.fill", iconColor: .orange, label: "Light")
                        .tag(Enums.Theme.light)
                    ListRowWithIconEntry(systemIcon: "moon.fill", iconColor: .indigo, label: "Dark")
                        .tag(Enums.Theme.dark)
                }
                .pickerStyle(.inline)
                
                Section("Configuration") {
                    NavigationLink {
                        AppSettingsView()
                    } label: {
                        ListRowWithIconEntry(systemIcon: "gear", iconColor: .blue, label: "Application settings")
                    }
                    NavigationLink {
                        ServerSettingsView()
                    } label: {
                        ListRowWithIconEntry(systemIcon: "server.rack", iconColor: .orange, label: "Server settings", badge: serverStatusViewModel.status.data?.csMonitorAPI.newVersionAvailable != nil ? 1 : nil)
                    }
                }
                
                Section {
                    // NavigationLink {
                    //     TipsView()
                    // } label: {
                    //     ListRowWithIconEntry(systemIcon: "dollarsign.circle.fill", iconColor: .green, label: "Give a tip to the developer")
                    // }
                    Button {
                        crowdsecWebOpen = true
                    } label: {
                        ListRowWithIconEntry(systemIcon: "globe", iconColor: .red, label: "CrowdSec website")
                    }
                    Button {
                        appDetailsOpen.toggle()
                    } label: {
                        ListRowWithIconEntry(systemIcon: "info.circle.fill", iconColor: .orange, label: "More information about the app")
                    }
                    Button {
                        myOtherAppsOpen.toggle()
                    } label: {
                        ListRowWithIconEntry(systemIcon: "app.gift", iconColor: .brown, label: "My other apps")
                    }
                    HStack {
                        ListRowWithIconEntry(systemIcon: "info.circle.fill", iconColor: .teal, label: "App version")
                        Spacer()
                        Text(showBuildNumber == true ? buildNumber : version)
                            .foregroundColor(Color.secondary)
                            .animation(.default, value: showBuildNumber)
                            .onTapGesture {
                                showBuildNumber.toggle()
                            }
                    }
                } header: {
                    Text("About the app")
                } footer: {
                    HStack {
                        Spacer()
                        Text("Created on 🇪🇸 by JGeek00")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 16))
                        Spacer()
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Settings")
            .safariView(isPresented: $crowdsecWebOpen, urlString: URLs.crowdsecWeb)
            // .safariView(isPresented: $appDetailsOpen, url: URLs.appDetailsPage)
            .safariView(isPresented: $myOtherAppsOpen, urlString: URLs.myOtherApps)
        }
    }
}
