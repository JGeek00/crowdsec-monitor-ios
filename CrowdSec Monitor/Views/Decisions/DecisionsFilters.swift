
import SwiftUI

struct DecisionsFilters: View {
    let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    @Environment(DecisionsListViewModel.self) private var viewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        NavigationStack {
            List {
                Toggle("Show only active decisions", isOn: Binding(
                    get: { viewModel.filters.onlyActive ?? false },
                    set: { viewModel.filters.onlyActive = $0 }
                ))
                Toggle("Hide active duplicated decisions", isOn: Binding(
                    get: { viewModel.filters.hideActiveDuplicated ?? false },
                    set: { viewModel.filters.hideActiveDuplicated = $0 }
                ))
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton(onClose: onClose)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if #available(iOS 26.0, *) {
                        Button("Apply", role: .confirm) {
                            onClose()
                            viewModel.applyFilters()
                        }
                    }
                    else {
                        Button("Apply") {
                            onClose()
                            viewModel.applyFilters()
                        }
                    }
                }
            }
        }
        .navigationTitle("Filters")
    }
}
