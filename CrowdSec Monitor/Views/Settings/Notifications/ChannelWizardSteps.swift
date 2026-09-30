import SwiftUI

struct ChannelWizardIntroStep: View {
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "info.square")
                        .font(.system(size: 40))
                    Text("A notification channel defines how the backend delivers a notification: through ntfy or by email. Configure the provider access once here, then pick one or more channels in each notification.")
                        .font(.headline)
                }
                .foregroundStyle(Color.secondary)
                .listRowBackground(Color.listBackground)
            }
        }
    }
}

struct ChannelWizardProviderStep: View {
    @Bindable var viewModel: ChannelFormViewModel

    private var rows: [[NotificationProvider]] {
        stride(from: 0, to: viewModel.providers.count, by: 2).map { start in
            Array(viewModel.providers[start..<min(start + 2, viewModel.providers.count)])
        }
    }

    var body: some View {
        Form {
            if viewModel.providers.isEmpty {
                Section {
                    Text("No providers available")
                        .foregroundStyle(Color.secondary)
                }
            } else {
                Section("Choose the provider for this channel.") {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        HStack(spacing: 12) {
                            ForEach(row) { provider in
                                providerButton(provider)
                            }
                            if row.count == 1 {
                                Spacer()
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .listRowBackground(Color.clear)
            }
        }
        .task {
            if viewModel.providers.isEmpty {
                await viewModel.loadProviders()
            }
        }
    }

    @ViewBuilder
    private func providerButton(_ provider: NotificationProvider) -> some View {
        let selected = viewModel.providerType == provider.type
        Button {
            viewModel.selectProvider(provider.type)
        } label: {
            VStack(spacing: 8) {
                ChannelIcon(provider.icon)
                    .font(.largeTitle)
                    .frame(width: 44, height: 44)
                Text(LocalizedStringKey(provider.labelKey))
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, minHeight: 110)
            .foregroundStyle(selected ? Color.accentColor : Color.primary)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? Color.accentColor : Color.gray.opacity(0.4), lineWidth: selected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
