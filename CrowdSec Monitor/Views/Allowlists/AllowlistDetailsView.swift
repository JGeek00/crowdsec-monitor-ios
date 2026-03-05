import SwiftUI

struct AllowlistDetailsView: View {
    let allowlistName: String
    
    init(allowlistName: String) {
        self.allowlistName = allowlistName
    }
    
    @Environment(AllowlistsListViewModel.self) private var viewModel
    
    var body: some View {
        let allowlist = viewModel.state.data?.data.first(where: { $0.name == allowlistName })
        Group {
            if let allowlist = allowlist {
                List(allowlist.items, id: \.self) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(verbatim: item.value)
                            .fontWeight(.medium)
                        if let created = item.createdAt.toDateFromISO8601() {
                            HStack(spacing: 8) {
                                Image(systemName: "clock.badge.checkmark")
                                Text("Created: \(created.formatted(date: .abbreviated, time: .shortened))")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        if let expiration = item.expiration?.toDateFromISO8601() {
                            HStack(spacing: 8) {
                                Image(systemName: "clock.badge.xmark")
                                Text("Expiration: \(expiration.formatted(date: .abbreviated, time: .shortened))")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            else {
                ContentUnavailableView("Allowlist not found", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle(allowlistName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
