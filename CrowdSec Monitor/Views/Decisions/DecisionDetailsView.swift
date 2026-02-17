import SwiftUI

struct DecisionDetailsView: View {
    let decisionId: Int
    
    @State private var viewModel: DecisionDetailsViewModel
    
    init(decisionId: Int) {
        self.decisionId = decisionId
        _viewModel = State(wrappedValue: DecisionDetailsViewModel(decisionId: decisionId))
    }
    
    @State private var showSafariScenario = false
    @State private var geocodedLocation: Enums.LoadingState<String> = .loading
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading...")
            case .success(let data):
                content(data)
            case .failure:
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.circle",
                    description: Text("An error occured when fetching the data")
                )
            }
        }
        .navigationTitle("Decision #\(String(decisionId))")
        .task(id: decisionId) {
            await viewModel.fetchData()
        }
        .onChange(of: decisionId) { _, newValue in
            viewModel.updateDecisionId(decisionId: decisionId)
        }
    }
    
    @ViewBuilder
    func content(_ data: DecisionItemResponse) -> some View {
        List {
            
        }
        .task {
            let res = await reverseGeocode(lat: data.source.latitude, lon: data.source.longitude)
            if let res = res {
                geocodedLocation = .success(res)
            }
            else {
                geocodedLocation = .failure(NSError())
            }
        }
        .refreshable {
            await viewModel.fetchData()
        }
    }
    
    @ViewBuilder
    func normalRow(title: String, value: String) -> some View {
        HStack {
            Text(verbatim: title)
            Spacer()
            Text(verbatim: value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }
}
