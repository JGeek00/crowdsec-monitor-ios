import SwiftUI

struct AlertDetailsView: View {
    let alertId: Int
    
    @State private var viewModel: AlertDetailsViewModel
    
    init(alertId: Int) {
        self.alertId = alertId
        _viewModel = State(wrappedValue: AlertDetailsViewModel(alertId: alertId))
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
        .navigationTitle("Alert #\(String(alertId))")
        .task(id: alertId) {
            await viewModel.fetchData()
        }
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
                                .fontWeight(.medium)
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
                normalRow(title: String(localized: "Version"), value: data.scenarioVersion)
                normalRow(title: String(localized: "Capacity"), value: String(data.capacity))
                normalRow(title: String(localized: "Leakspeed"), value: data.leakspeed)
            }
            
            Section("Origin") {
                normalRow(title: String(localized: "IP address"), value: data.source.ip)
                HStack {
                    Text("Country")
                    Spacer()
                    CountryFlag(countryCode: data.source.cn)
                        .fontWeight(.medium)
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
                    .fontWeight(.medium)
                }
                normalRow(title: String(localized: "IP owner"), value: data.source.asName)
            }
            
            Section("Decisions") {
                ForEach(data.decisions, id: \.id) { decision in
                    DecisionItem(decisionId: decision.id, ipAddress: decision.value, expirationDate: decision.expiration, countryCode: nil, decisionType: decision.type)
                }
            }
            
            Section("Events") {
                ForEach(Array(data.events.enumerated()), id: \.offset) { index, event in
                    EventItem(data: event.meta.map({ EventItemDataElement(key: $0.key, value: $0.value) }))
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
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }
}
