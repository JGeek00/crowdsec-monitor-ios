import SwiftUI

struct DecisionItem: View {
    let decisionId: Int
    let scenario: String
    let ipAddress: String
    let expirationDate: Date?
    let countryCode: String?
    let decisionType: String
    
    init(decisionId: Int, scenario: String, ipAddress: String, expirationDate: Date?, countryCode: String?, decisionType: String) {
        self.decisionId = decisionId
        self.scenario = scenario
        self.ipAddress = ipAddress
        self.expirationDate = expirationDate
        self.countryCode = countryCode
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
        
        let scenarioSplit = scenario.split(separator: "/")
        
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: String(scenarioSplit[1]))
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(verbatim: ipAddress)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                if let country = countryCode {
                    CountryFlag(countryCode: country)
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                        .foregroundStyle(.gray)
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
        DecisionItem(decisionId: 1, scenario: "crowdsecurity/http-probing", ipAddress: "192.168.0.1", expirationDate: Date().addingTimeInterval(-3600), countryCode: "US", decisionType: "ban")
        DecisionItem(decisionId: 2, scenario: "crowdsecurity/http-probing", ipAddress: "192.168.100.1", expirationDate: Date().addingTimeInterval(45), countryCode: "ES", decisionType: "captcha")
        DecisionItem(decisionId: 3, scenario: "crowdsecurity/http-probing", ipAddress: "192.168.200.1", expirationDate: Date().addingTimeInterval(3665), countryCode: "IT", decisionType: "throttling")
        DecisionItem(decisionId: 4, scenario: "crowdsecurity/http-probing", ipAddress: "10.0.0.1", expirationDate: Date().addingTimeInterval(90125), countryCode: "FR", decisionType: "ban")
    }
}
