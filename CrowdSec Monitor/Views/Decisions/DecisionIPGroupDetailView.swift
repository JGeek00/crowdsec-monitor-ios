import SwiftUI
import CustomAlert

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
        @Bindable var viewModel = viewModel

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
                        DecisionIPGroupDetailDecisionRow(
                            decision: decision,
                            onExpire: viewModel.expireDecision
                        )
                    }
                } header: {
                    HStack {
                        Text("Decisions")
                        if data.activeDecisions > 0 {
                            Spacer()
                            Text("\(data.activeDecisions) active decisions")
                                .font(.system(size: 12))
                                .foregroundStyle(.green)
                                .fontWeight(.medium)
                        }
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
        .customAlert(isPresented: $viewModel.processingExpireDecision) {
            HStack {
                Spacer()
                ProgressView()
                    .controlSize(.large)
                    .tint(Color.foreground)
                Spacer()
            }
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


fileprivate struct DecisionIPGroupDetailDecisionRow: View {
    let decision: DecisionsByIPDetailResponse_Decision
    let onExpire: (Int) async -> Bool

    @State private var errorDeleteDecision = false
    @State private var expireDecisionConfirmationAlert = false

    var body: some View {
        NavigationLink {
            AlertDetailsView(alertId: decision.alertId, allowNavigateDecision: false)
        } label: {
            DecisionItemNoIP(
                decisionId: decision.id,
                scenario: decision.scenario,
                expirationDate: decision.expiration.toDateFromISO8601(),
                createdAt: decision.crowdsecCreatedAt.toDateFromISO8601(),
                decisionType: decision.type
            )
        }
        .contextMenu {
            if let date = decision.expiration.toDateFromISO8601(), date > Date() {
                Button(String(localized: "Expire decision"), systemImage: "clock.badge.checkmark", role: .destructive) {
                    expireDecisionConfirmationAlert = true
                }
            }
        }
        .alert("Expire decision", isPresented: $expireDecisionConfirmationAlert) {
            Button(String(localized: "Cancel"), role: .cancel) {
                expireDecisionConfirmationAlert = false
            }
            Button(String(localized: "Expire"), role: .destructive) {
                Task {
                    let result = await onExpire(decision.id)
                    if !result {
                        errorDeleteDecision = true
                    }
                }
            }
        } message: {
            Text("Are you sure you want to make this decision to expire now? This action cannot be undone.")
        }
        .alert("Error expiring decision", isPresented: $errorDeleteDecision) {
            Button("OK") {
                errorDeleteDecision = false
            }
        } message: {
            Text("An error occurred while making the decision expired. Please try again.")
        }
    }
}
