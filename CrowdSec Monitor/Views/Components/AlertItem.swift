import SwiftUI

struct AlertItem: View {
    let scenario: String
    let countryCode: String?
    let creationDate: Date?
    
    init(scenario: String, countryCode: String?, creationDate: Date?) {
        self.scenario = scenario
        self.countryCode = countryCode
        self.creationDate = creationDate
    }
        
    var body: some View {
        let scenarioParts = parseScenario(scenario)
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(scenarioParts.namespace)
                    .foregroundStyle(Color.gray)
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(scenarioParts.name)
                    .font(.callout)
                    .fontWeight(.medium)
                if let countryCode = countryCode {
                    CountryFlag(countryCode: countryCode)
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                        .fontWeight(.semibold)
                }
                    
            }
            Spacer()
            if let creationDate = creationDate {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(creationDate.toRelativeDayString())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.gray)
                    Text(creationDate.toTimeString())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    List {
        AlertItem(
            scenario: "crowdsecurity/ssh-bf",
            countryCode: "US",
            creationDate: Date().addingTimeInterval(-3600 * 5)
        )
    }
}
