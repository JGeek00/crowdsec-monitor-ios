import SwiftUI

struct AlertItem: View {
    let scenario: String
    let countryCode: String
    let creationDate: Date?
    
    init(scenario: String, countryCode: String, creationDate: Date?) {
        self.scenario = scenario
        self.countryCode = countryCode
        self.creationDate = creationDate
    }
    
    var body: some View {
        let scenarioSplit = scenario.split(separator: "/")
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(scenarioSplit[0])
                    .foregroundStyle(Color.gray)
                    .font(.system(size: 12))
                    .fontWeight(.semibold)
                Text(scenarioSplit[1])
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                CountryFlag(countryCode: countryCode)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gray)
                    .fontWeight(.semibold)
                    
            }
            Spacer()
            if let creationDate = creationDate {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(creationDate.toRelativeDayString())
                        .font(.system(size: 12))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.gray)
                    Text(creationDate.toTimeString())
                        .font(.system(size: 14))
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
