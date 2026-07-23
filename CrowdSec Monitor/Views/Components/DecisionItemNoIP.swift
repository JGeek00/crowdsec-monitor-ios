import SwiftUI

struct DecisionItemNoIP: View {
    let decisionId: Int
    let scenario: String
    let expirationDate: Date?
    let createdAt: Date?
    let decisionType: String
    
    init(decisionId: Int, scenario: String, expirationDate: Date?, createdAt: Date?, decisionType: String) {
        self.decisionId = decisionId
        self.scenario = scenario
        self.expirationDate = expirationDate
        self.createdAt = createdAt
        self.decisionType = decisionType
    }
        
    var body: some View {
        let decType = {
            if decisionType == "ban" {
                return DecisionTypeChip(label: "Ban", color: .red, systemImage: "hand.raised.fill", inverse: true)
            }
            else if decisionType == "captcha" {
                return DecisionTypeChip(label: "Captcha", color: .orange, systemImage: "puzzlepiece.fill", inverse: true)
            }
            else {
                return DecisionTypeChip(label: decisionType.capitalized, color: .blue, systemImage: "shield.fill", inverse: true)
            }
        }
        
        let scenarioParts = parseScenario(scenario)
        let scenarioName: String = scenarioParts.name.isEmpty ? scenarioParts.namespace : scenarioParts.name

        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(verbatim: scenarioName)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                if let createdAt {
                    Text(DateFormatter.ddMMMyyyyHHmmss.string(from: createdAt))
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                }
            }
            .padding(.trailing, 6)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                decType()
                    .font(.system(size: 14))
                DecisionTimer(expirationDate: expirationDate)
                    .font(.system(size: 12))
            }
        }
    }
}

#Preview {
    List {
        DecisionItemNoIP(decisionId: 1, scenario: "crowdsecurity/http-probing", expirationDate: Date().addingTimeInterval(-3600), createdAt: Date(), decisionType: "ban")
        DecisionItemNoIP(decisionId: 2, scenario: "crowdsecurity/http-probing", expirationDate: Date().addingTimeInterval(45), createdAt: Date(), decisionType: "captcha")
        DecisionItemNoIP(decisionId: 3, scenario: "crowdsecurity/http-probing", expirationDate: Date().addingTimeInterval(3665), createdAt: Date(), decisionType: "throttling")
        DecisionItemNoIP(decisionId: 4, scenario: "crowdsecurity/http-probing", expirationDate: Date().addingTimeInterval(90125), createdAt: Date(), decisionType: "ban")
    }
}
