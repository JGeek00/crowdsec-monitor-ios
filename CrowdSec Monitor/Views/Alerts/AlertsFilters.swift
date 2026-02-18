import SwiftUI

struct AlertsFilters: View {
    let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    @Environment(AlertsListViewModel.self) private var viewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        NavigationStack {
            List {
                NavigationLink {
                    MultiSelectFilter(options: viewModel.state.data?.filtering.scenarios ?? [], selected: viewModel.filters.scenarios) { values in
                        var newFilters = viewModel.filters
                        newFilters.scenarios = values
                        viewModel.updateFilters(newFilters)
                    }
                    .navigationTitle("Scenarios")
                } label: {
                    itemsSelectedLabel(label: "Scenarios", selected: viewModel.filters.scenarios.count)
                }
                NavigationLink {
                    MultiSelectFilter(options: viewModel.state.data?.filtering.ipOwners ?? [], selected: viewModel.filters.ipOwners) { values in
                        var newFilters = viewModel.filters
                        newFilters.ipOwners = values
                        viewModel.updateFilters(newFilters)
                    }
                    .navigationTitle("IP owners")
                } label: {
                    itemsSelectedLabel(label: "IP owners", selected: viewModel.filters.ipOwners.count)
                }
                NavigationLink {
                    MultiSelectFilter(options: viewModel.state.data?.filtering.countries ?? [], selected: viewModel.filters.countries, onChange: { values in
                        var newFilters = viewModel.filters
                        newFilters.countries = values
                        viewModel.updateFilters(newFilters)
                    }, customComponent: { value in
                        AnyView(CountryFlag(countryCode: value))
                    })
                    .navigationTitle("Countries")
                } label: {
                    itemsSelectedLabel(label: "Countries", selected: viewModel.filters.countries.count)
                }
                NavigationLink {
                    MultiSelectFilter(options: viewModel.state.data?.filtering.targets ?? [], selected: viewModel.filters.targets) { values in
                        var newFilters = viewModel.filters
                        newFilters.targets = values
                        viewModel.updateFilters(newFilters)
                    }
                    .navigationTitle("Targets")
                } label: {
                    itemsSelectedLabel(label: "Targets", selected: viewModel.filters.targets.count)
                }
            }
            .disabled(viewModel.state.data == nil)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton(onClose: onClose)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onClose()
                        viewModel.resetFilters()
                    } label: {
                        Label("Reset", systemImage: "eraser")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                     if #available(iOS 26.0, *) {
                         Button(role: .confirm) {
                             onClose()
                             viewModel.applyFilters()
                         } label: {
                             Label("Apply", systemImage: "checkmark")
                         }
                     }
                     else {
                         Button {
                             onClose()
                             viewModel.applyFilters()
                         } label: {
                             Label("Apply", systemImage: "checkmark")
                         }
                     }
                }
            }
        }
    }
    
    @ViewBuilder
    func itemsSelectedLabel(label: String.LocalizationValue, selected: Int) -> some View {
        VStack(alignment: .leading) {
            Text(String(localized: label))
            if selected > 0 {
                Spacer()
                    .frame(height: 4)
                Text("\(selected) selected")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
                    .fontWeight(.medium)
            }
        }
    }
}
