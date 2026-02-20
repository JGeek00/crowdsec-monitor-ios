import SwiftUI

struct AlertDetailsView: View {
    let alertId: Int
    let allowNavigateDecision: Bool
    
    @State private var viewModel: AlertDetailsViewModel
    
    init(alertId: Int, allowNavigateDecision: Bool = true) {
        self.alertId = alertId
        self.allowNavigateDecision = allowNavigateDecision
        _viewModel = State(wrappedValue: AlertDetailsViewModel(alertId: alertId))
    }
    
    @State private var showSafariScenario = false
    @State private var geocodedLocation: Enums.LoadingState<String> = .loading
    @State private var errorExpireDecision = false
    
    func handleDecisionExpire(_ decisionId: Int) {
        Task {
            let result = await viewModel.handleDecisionExpire(decisionId: decisionId)
            if result == false {
                errorExpireDecision = true
            }
        }
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
        .navigationTitle("Alert #\(String(alertId))")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: alertId) { _, newValue in
            viewModel.updateAlertId(alertId: newValue)
        }
    }
    
    @ViewBuilder
    func content(_ data: AlertDetailsResponse) -> some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    Image(systemName: "info")
                        .foregroundStyle(Color.white)
                        .fontWeight(.bold)
                        .font(.system(size: 28))
                        .frame(width: 50, height: 50)
                        .condition { view in
                            if #available(iOS 26.0, *) {
                                view
                                    .glassEffect(.regular.tint(.blue), in: .rect(cornerRadius: 12))
                            }
                            else {
                                view
                                    .background(Color.blue)
                                    .clipShape(.rect(cornerRadius: 8))
                            }
                        }
                    Spacer()
                        .frame(height: 12)
                    Text("Message")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                    Spacer()
                        .frame(height: 4)
                    Text(verbatim: data.message)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.gray)
                }
            }
            
            Section("Scenario") {
                let scenarioSplit = data.scenario.split(separator: "/")
                Button {
                    showSafariScenario = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(scenarioSplit[0])
                                .font(.system(size: 14))
                                .foregroundStyle(Color.gray)
                            Text(scenarioSplit[1])
                                .fontWeight(.medium)
                        }
                        Spacer()
                        Image(systemName: "macwindow.and.cursorarrow")
                            .foregroundStyle(Color.primary)
                    }
                }
                .foregroundStyle(Color.foreground)
                .safariView(isPresented: $showSafariScenario, url: URL(string: URLs.crowdsecHubScenario(scenario: data.scenario)))
                if data.scenarioVersion != "" {
                    normalRow(title: String(localized: "Version"), value: data.scenarioVersion)
                }
                normalRow(title: String(localized: "Capacity"), value: String(data.capacity))
                normalRow(title: String(localized: "Leakspeed"), value: data.leakspeed)
            }
            
            Section("Origin") {
                normalRow(title: String(localized: "IP address"), value: data.source.value)
                if let country = data.source.cn {
                    HStack {
                        Text("Country")
                        Spacer()
                        CountryFlag(countryCode: country)
                            .foregroundStyle(.secondary)
                    }
                }
                if data.source.latitude != nil && data.source.longitude != nil {
                    HStack {
                        Text("Location")
                        Spacer()
                        Group {
                            switch geocodedLocation {
                            case .loading:
                                ProgressView()
                            case .success(let data):
                                Text(verbatim: data)
                                    .multilineTextAlignment(.trailing)
                            case .failure:
                                Text(verbatim: "N/A")
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                if let ipOwner =  data.source.asName {
                    normalRow(title: String(localized: "IP owner"), value: ipOwner)
                }
            }
            
            if !data.decisions.isEmpty {
                Section("Decisions") {
                    ForEach(data.decisions, id: \.id) { decision in
                        if allowNavigateDecision == true {
                            NavigationLink {
                                DecisionDetailsView(decisionId: decision.id, allowNavigateAlert: false)
                            } label: {
                                DecisionItem(decisionId: decision.id, ipAddress: decision.value, expirationDate: decision.expiration, countryCode: nil, decisionType: decision.type) { decisionId in
                                    handleDecisionExpire(decisionId)
                                }
                            }
                        }
                        else {
                            DecisionItem(decisionId: decision.id, ipAddress: decision.value, expirationDate: decision.expiration, countryCode: nil, decisionType: decision.type) { decisionId in
                                handleDecisionExpire(decisionId)
                            }
                        }
                    }
                }
            }
            
            if !data.events.isEmpty {
                Section("Events") {
                    ForEach(Array(data.events.enumerated()), id: \.offset) { index, event in
                        EventItem(data: event.meta.map({ EventItemDataElement(key: $0.key, value: $0.value) }))
                    }
                }
            }
        }
        .task {
            if let latitude = data.source.latitude, let longitude = data.source.longitude {
                let res = await reverseGeocode(lat: latitude, lon: longitude)
                if let res = res {
                    geocodedLocation = .success(res)
                }
                else {
                    geocodedLocation = .failure(NSError())
                }
            }
        }
        .refreshable {
            await viewModel.fetchData()
        }
        .alert("Error expiring decision", isPresented: $errorExpireDecision) {
            Button("OK") {
                errorExpireDecision = false
            }
        } message: {
            Text("An error occurred while making the decision expired. Please try again.")
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
