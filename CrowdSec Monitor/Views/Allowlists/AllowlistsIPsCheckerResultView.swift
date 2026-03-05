import SwiftUI

struct AllowlistsIPsCheckerResultView: View {
    init() {}

    @Environment(AllowlistsIPsCheckerViewModel.self) private var viewModel
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading...")
            case .success(let data):
                List {
                    Section("IP addresses in allowlists") {
                        ForEach(data.results, id: \.self) { result in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(result.ip)
                                    .font(.headline)
                                Group {
                                    if let allowlist = result.allowlist {
                                        Text("Allowlist: \(allowlist)")
                                    }
                                    else {
                                        Text("This IP is not in any allowlist")
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
