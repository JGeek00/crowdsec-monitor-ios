import SwiftUI

struct ServerInformationSection: View {
    @Environment(ServerStatusViewModel.self) private var serverStatusViewModel
    @Environment(AuthViewModel.self) private var authViewModel
    
    init() {}
    
    @State private var showApiPackageBrowser = false

    var body: some View {
        if authViewModel.hasServerConfigured == true {
            Section("Information") {
                HStack {
                    Text("LAPI status")
                    Spacer()
                    Group {
                        switch serverStatusViewModel.status {
                        case .loading:
                            ProgressView()
                        case .success(let data):
                            if data.csLapi.lapiConnected == true {
                                online()
                            }
                            else {
                                offline()
                            }
                        case .failure:
                           offline()
                        }
                    }
                }
                HStack {
                    Text("API version")
                    Spacer()
                    Group {
                        switch serverStatusViewModel.status {
                        case .loading:
                            ProgressView()
                        case .success(let data):
                            Text(verbatim: data.csMonitorAPI.version)
                        case .failure:
                            Text(verbatim: "N/A")
                        }
                    }
                }
                if let newVersion = serverStatusViewModel.status.data?.csMonitorAPI.newVersionAvailable {
                    Button {
                        showApiPackageBrowser = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.circle")
                            Spacer()
                                .frame(width: 6)
                            Text("New version available")
                            Spacer()
                            Text(verbatim: newVersion)
                        }
                    }
                    .foregroundStyle(Color.green)
                    .fontWeight(.semibold)
                    .safariView(isPresented: $showApiPackageBrowser, urlString: URLs.apiPackageUrl)
                }
            }
        }
    }
    
    @ViewBuilder
    func online() -> some View {
        HStack {
            Image(systemName: "checkmark")
            Spacer()
                .frame(width: 8)
            Text("Online")
        }
        .foregroundStyle(Color.green)
    }
    
    @ViewBuilder
    func offline() -> some View {
        HStack {
            Image(systemName: "xmark")
            Spacer()
                .frame(width: 8)
            Text("Offline")
        }
        .foregroundStyle(Color.red)
    }
}
