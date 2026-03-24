import SwiftUI

struct BlocklistsIPsCheckerResultView: View {
    init() {}

    @Environment(IPsCheckerViewModel.self) private var viewModel
    
    var body: some View {
        Group {
            switch viewModel.stateBlocklists {
            case .loading:
                ProgressView("Loading...")
            case .success(let data):
                List {
                    Section("IP addresses in blocklists") {
                        ForEach(data.results, id: \.self) { result in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(result.ip)
                                    .font(.headline)
                                Group {
                                    if !result.blocklists.isEmpty {
                                        let joined = result.blocklists.joined(separator: ", ")
                                        Text("Blocklists: \(joined)")
                                    }
                                    else {
                                        Text("This IP is not in any blocklist")
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
