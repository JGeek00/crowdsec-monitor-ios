import SwiftUI

struct DecisionIPGroupDetailView: View {
    let ip: String
    let onlyActive: Bool

    @State private var viewModel: DecisionIPGroupDetailViewModel
    @State private var geocodedLocation: Enums.LoadingState<String> = .loading
    @State private var showSafariScenario = false

    init(ip: String, onlyActive: Bool) {
        self.ip = ip
        self.onlyActive = onlyActive
        _viewModel = State(wrappedValue: DecisionIPGroupDetailViewModel(ip: ip, onlyActive: onlyActive))
    }

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
        .transition(.opacity)
        .navigationTitle(viewModel.state.data?.ip ?? ip)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func content(_ data: DecisionsByIPDetailResponse) -> some View {
        List {
            Section("Origin") {
                normalRow(title: String(localized: "IP address"), value: data.ip)

                if let range = data.range {
                    normalRow(title: String(localized: "Range"), value: range)
                }

                if let country = data.country {
                    HStack {
                        Text("Country")
                        Spacer()
                        CountryFlag(countryCode: country)
                            .foregroundStyle(.secondary)
                    }
                }

                if let owner = data.owner, !owner.isEmpty {
                    normalRow(title: String(localized: "Owner"), value: owner)
                }

                if data.latitude != nil, data.longitude != nil {
                    HStack {
                        Text("Location")
                        Spacer()
                        Group {
                            switch geocodedLocation {
                            case .loading:
                                ProgressView()
                            case .success(let location):
                                Text(verbatim: location)
                                    .multilineTextAlignment(.trailing)
                            case .failure:
                                Text(verbatim: "N/A")
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }

            if data.decisions.isEmpty == false {
                Section {
                    ForEach(data.decisions, id: \.id) { decision in
                        DecisionItem(
                            decisionId: decision.id,
                            scenario: decision.scenario,
                            ipAddress: decision.value,
                            expirationDate: decision.expiration.toDateFromISO8601(),
                            countryCode: data.country,
                            decisionType: decision.type
                        )
                    }
                } header: {
                    HStack {
                        Text("Decisions")
                        Spacer()
                        Text("\(data.activeDecisions) active decisions")
                            .font(.system(size: 12))
                    }
                }
            }
        }
        .task {
            if let latitude = data.latitude, let longitude = data.longitude {
                let res = await reverseGeocode(lat: latitude, lon: longitude)
                if let res {
                    geocodedLocation = .success(res)
                } else {
                    geocodedLocation = .failure(NSError())
                }
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
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}
