import SwiftUI
import CustomAlert

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
    @State private var errorDeleteAlert = false
    @State private var confirmationExpirePresented = false
    
    var body: some View {
        @Bindable var viewModel = viewModel
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
        .navigationTitle("Decision #\(String(decisionId))")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: decisionId) { _, newValue in
            viewModel.updateDecisionId(decisionId: decisionId)
        }
        .alert("Error delete alert", isPresented: $errorDeleteAlert) {
            Button("OK", role: .cancel) {
                errorDeleteAlert = false
            }
        } message: {
            Text("An error occured when trying to delete the alert. Please try again.")
        }
        .alert("Expire decision", isPresented: $confirmationExpirePresented) {
            Button(String(localized: "Cancel"), role: .cancel) {
                confirmationExpirePresented = false
            }
            Button(String(localized: "Expire"), role: .destructive) {
                viewModel.expireDecision()
            }
        } message: {
            Text("Are you sure you want to make this decision to expire now? This action cannot be undone.")
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
                normalRow(title: String(localized: "IP address"), value: data.source.value)
                if let ipOwner = data.source.asName {
                    normalRow(title: String(localized: "IP owner"), value: ipOwner)
                }
                if let country = data.source.cn {
                    HStack {
                        Text("Country")
                        Spacer()
                        CountryFlag(countryCode: country)
                            .foregroundStyle(.secondary)
                    }
                }
                if data.source.latitude != nil, data.source.longitude != nil {
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
            
            if let expirationDate = data.expiration.toDateFromISO8601(), expirationDate > Date() {
                Section {
                    Button(role: .destructive) {
                        confirmationExpirePresented = true
                    } label: {
                        Label("Expire decision", systemImage: "clock.badge.checkmark")
                            .foregroundStyle(.red)
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
