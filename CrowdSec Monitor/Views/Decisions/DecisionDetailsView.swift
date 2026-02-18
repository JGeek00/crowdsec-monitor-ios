import SwiftUI

struct DecisionDetailsView: View {
    let decisionId: Int
    let allowNavigateAlert: Bool
    
    @State private var viewModel: DecisionDetailsViewModel
    
    init(decisionId: Int, allowNavigateAlert: Bool = true) {
        self.decisionId = decisionId
        self.allowNavigateAlert = allowNavigateAlert
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
        let decType = {
            if data.type == "ban" {
                return DecisionTypeChip(label: "Ban", color: .red, systemImage: "hand.raised.fill")
            }
            else if data.type == "captcha" {
                return DecisionTypeChip(label: "Captcha", color: .orange, systemImage: "puzzlepiece.fill")
            }
            else {
                return DecisionTypeChip(label: data.type.capitalized, color: .blue, systemImage: "shield.fill")
            }
        }
        
        let scenarioSplit = data.scenario.split(separator: "/")
        
        List {
            Section("General information") {
                HStack {
                    Text("Type")
                    Spacer()
                    decType()
                }
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
                HStack {
                    Text("Remaining time")
                    Spacer()
                    DecisionTimer(expirationDate: data.expiration.toDateFromISO8601())
                }
            }
            
            Section("Origin") {
                normalRow(title: String(localized: "IP address"), value: data.source.ip)
                normalRow(title: String(localized: "IP owner"), value: data.source.asName)
                HStack {
                    Text("Country")
                    Spacer()
                    CountryFlag(countryCode: data.source.cn)
                        .foregroundStyle(.secondary)
                }
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
            
            Section("Alert") {
                if allowNavigateAlert == true {
                    NavigationLink {
                        AlertDetailsView(alertId: data.alertId, allowNavigateDecision: false)
                    } label: {
                        AlertItem(scenario: data.scenario, countryCode: data.source.cn, creationDate: data.crowdsecCreatedAt.toDateFromISO8601())
                    }
                }
                else {
                    AlertItem(scenario: data.scenario, countryCode: data.source.cn, creationDate: data.crowdsecCreatedAt.toDateFromISO8601())
                }
            }
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
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}
