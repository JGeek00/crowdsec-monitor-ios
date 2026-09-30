import SwiftUI

struct ChannelWizardIntroStep: View {
    var body: some View {
        Form {
            Section {
                FormInfoBox(label: String(localized: "A notification channel defines how the backend delivers a notification: through ntfy or by email. Configure the provider access once here, then pick one or more channels in each notification."))
            }
        }
    }
}

struct ChannelWizardProviderStep: View {
    @Bindable var viewModel: ChannelFormViewModel

    var body: some View {
        Form {
            Section {
                HStack(spacing: 12) {
                    providerButton(type: .email, title: "Email")
                    providerButton(type: .ntfy, title: "ntfy")
                }
                .listRowBackground(Color.clear)
            } header: {
                Text("Choose the provider for this channel.")
            }
        }
    }

    @ViewBuilder
    private func providerIcon(type: NotificationChannelType) -> some View {
        switch type {
        case .email:
            Image(systemName: "envelope")
                .font(.largeTitle)
        case .ntfy:
            Image("ntfy")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
        }
    }

    @ViewBuilder
    private func providerButton(type: NotificationChannelType, title: String) -> some View {
        let selected = viewModel.provider == type
        Button {
            viewModel.provider = type
        } label: {
            VStack(spacing: 8) {
                providerIcon(type: type)
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, minHeight: 110)
            .foregroundStyle(selected ? Color.accentColor : Color.primary)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? Color.accentColor : Color.gray.opacity(0.4), lineWidth: selected ? 2 : 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
