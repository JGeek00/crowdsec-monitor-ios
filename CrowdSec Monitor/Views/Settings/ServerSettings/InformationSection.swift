import SwiftUI

struct ServerInformationSection: View {
    @Environment(ServiceStatusViewModel.self) private var serviceStatusViewModel
    @Environment(ActiveServerViewModel.self) private var activeServerViewModel
    
    init() {}
    
    @State private var showApiPackageBrowser = false

    var body: some View {
        if activeServerViewModel.hasServerConfigured == true {
            Section("Information") {
                HStack {
                    Text("LAPI available")
                    Spacer()
                    Group {
                        switch serviceStatusViewModel.state {
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
                    Text("Bouncer available")
                    Spacer()
                    Group {
                        switch serviceStatusViewModel.state {
                        case .loading:
                            ProgressView()
                        case .success(let data):
                            if data.csBouncer.available == true {
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
                        switch serviceStatusViewModel.state {
                        case .loading:
                            ProgressView()
                        case .success(let data):
                            Text(verbatim: data.csMonitorAPI.version)
                        case .failure:
                            Text(verbatim: "N/A")
                        }
                    }
                }
                if let newVersion = serviceStatusViewModel.state.data?.csMonitorAPI.newVersionAvailable {
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
