import SwiftUI

struct ChannelsListView: View {
    @Environment(NotificationChannelsListViewModel.self) private var viewModel

    @Binding var editingChannel: UserNotificationChannel?
    @Binding var showWizard: Bool

    var body: some View {
        @Bindable var viewModel = viewModel
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            case .success(let items):
                content(items)
            case .failure:
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.circle",
                    description: Text("An error occurred when fetching the data")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .transition(.opacity)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add channel", systemImage: "plus") {
                    editingChannel = nil
                    showWizard = true
                }
            }
        }
        .task {
            await viewModel.initialFetch()
        }
        .refreshable {
            await viewModel.refresh()
        }
        .alert("Error", isPresented: $viewModel.errorDelete) {
            Button("OK", role: .cancel) {
                viewModel.errorDelete = false
            }
        } message: {
            Text("The channel could not be deleted. Try again later.")
        }
        .alert("Channel in use", isPresented: $viewModel.channelInUse) {
            Button("OK", role: .cancel) {
                viewModel.channelInUse = false
            }
        } message: {
            Text("This channel is used by one or more notifications. Remove it from them before deleting it.")
        }
    }

    @ViewBuilder
    func content(_ items: [UserNotificationChannel]) -> some View {
        if items.isEmpty {
            ContentUnavailableView(
                "No channels",
                systemImage: "antenna.radiowaves.left.and.right",
                description: Text("Create your first notification channel with the + button")
            )
        } else {
            List(items) { channel in
                NavigationLink {
                    ChannelDetailsView(channel, providers: viewModel.providers) { _ in
                        Task {
                            await viewModel.refresh()
                        }
                    }
                } label: {
                    ChannelListItem(channel: channel)
                }
            }
            .animation(.default, value: items)
        }
    }
}
