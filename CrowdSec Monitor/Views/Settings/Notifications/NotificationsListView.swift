import SwiftUI

struct NotificationsListView: View {
    @Environment(NotificationsListViewModel.self) private var viewModel

    @Binding var editingNotification: UserNotification?
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
                Button("Add notification", systemImage: "plus") {
                    editingNotification = nil
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
        .alert("Error", isPresented: $viewModel.errorToggle) {
            Button("OK", role: .cancel) {
                viewModel.errorToggle = false
            }
        } message: {
            Text("The notification could not be enabled or disabled. Try again later.")
        }
        .alert("Error", isPresented: $viewModel.errorDelete) {
            Button("OK", role: .cancel) {
                viewModel.errorDelete = false
            }
        } message: {
            Text("The notification could not be deleted. Try again later.")
        }
    }

    @ViewBuilder
    func content(_ items: [UserNotification]) -> some View {
        if items.isEmpty {
            ContentUnavailableView(
                "No notifications",
                systemImage: "bell",
                description: Text("Create your first notification with the + button")
            )
        } else {
            List(items) { notification in
                NotificationListItem(
                    notification,
                    editingNotification: $editingNotification,
                    showWizard: $showWizard
                )
            }
            .animation(.default, value: items)
        }
    }
}
