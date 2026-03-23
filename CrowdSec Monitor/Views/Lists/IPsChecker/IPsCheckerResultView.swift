import SwiftUI

struct IPsCheckerResultView: View {
    init() {}

    @Environment(IPsCheckerViewModel.self) private var viewModel
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading...")
            case .success(let data):
                List {
                    Section(viewModel.selectedListType == .allowlist ? "IP addresses in allowlists" : "IP addresses in blocklists") {
                        ForEach(data.results, id: \.self) { result in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(result.ip)
                                    .font(.headline)
                                Group {
                                    if let allowlist = result.allowlist {
                                        Text("Allowlist: \(allowlist)")
                                    }
                                    else if let blocklist = result.blocklist {
                                        Text("Blocklist: \(blocklist)")
                                    }
                                    else {
                                        Text(viewModel.selectedListType == .allowlist ? "This IP is not in any allowlist" : "This IP is not in any blocklist")
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                                .font(.subheadline)
                            }
                        }
                    }
                }
            case .failure:
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.circle",
                    description: Text("An error occured when fetching the data")
                )
            }
        }
        .transition(.opacity)
        .navigationTitle("Check IP addresses")
        .navigationBarTitleDisplayMode(.inline)
    }
}
