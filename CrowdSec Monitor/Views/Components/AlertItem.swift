import SwiftUI

struct AlertItem: View {
    let scenario: String
    let countryCode: String?
    let creationDate: Date?
    let handleAlertDelete: (() -> Void)?
    
    init(scenario: String, countryCode: String?, creationDate: Date?, handleAlertDelete: (() -> Void)? = nil) {
        self.scenario = scenario
        self.countryCode = countryCode
        self.creationDate = creationDate
        self.handleAlertDelete = handleAlertDelete
    }
    
    @State private var confirmationDeletePresented = false
    
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
                if let countryCode = countryCode {
                    CountryFlag(countryCode: countryCode)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gray)
                        .fontWeight(.semibold)
                }
                    
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
        .contextMenu {
            if handleAlertDelete != nil {
                Button("Delete alert", systemImage: "trash", role: .destructive) {
                    confirmationDeletePresented = true
                }
            }
        }
        .condition { view in
            if let action = handleAlertDelete {
                view
                    .alert("Delete alert", isPresented: $confirmationDeletePresented) {
                        Button("Cancel", role: .cancel) {
                            confirmationDeletePresented = false
                        }
                        Button("Delete", role: .destructive) {
                            action()
                        }
                    } message: {
                        Text("Are you sure you want to delete this alert? This action cannot be undone.")
                    }
            }
            else { view }
        }

    }
}

#Preview {
    List {
        AlertItem(
            scenario: "crowdsecurity/ssh-bf",
            countryCode: "US",
            creationDate: Date().addingTimeInterval(-3600 * 5)
        ) {}
    }
}
