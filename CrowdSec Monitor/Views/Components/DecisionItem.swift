import SwiftUI
import Combine

struct DecisionItem: View {
    let decisionId: Int
    let ipAddress: String
    let expirationDate: Date?
    let countryCode: String?
    let decisionType: String
    
    init(decisionId: Int, ipAddress: String, expirationDate: Date?, countryCode: String?, decisionType: String) {
        self.decisionId = decisionId
        self.ipAddress = ipAddress
        self.expirationDate = expirationDate
        self.countryCode = countryCode
        self.decisionType = decisionType
    }
    
    var body: some View {
        let decType = {
            if decisionType == "ban" {
                return DecisionTypeChip(label: "Ban", color: .red, systemImage: "hand.raised.fill")
            }
            else if decisionType == "captcha" {
                return DecisionTypeChip(label: "Captcha", color: .orange, systemImage: "puzzlepiece.fill")
            }
            else {
                return DecisionTypeChip(label: decisionType.capitalized, color: .blue, systemImage: "shield.fill")
            }
        }
        
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(verbatim: ipAddress)
                    .fontWeight(.semibold)
                DecisionTimer(expirationDate: expirationDate)
                if let country = countryCode {
                    CountryFlag(countryCode: country)
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                }
            }
            Spacer()
            decType()
        }
    }
}

#Preview {
    List {
        DecisionItem(decisionId: 1, ipAddress: "192.168.0.1", expirationDate: Date().addingTimeInterval(-3600), countryCode: "US", decisionType: "ban")
        DecisionItem(decisionId: 2, ipAddress: "192.168.100.1", expirationDate: Date().addingTimeInterval(45), countryCode: "ES", decisionType: "captcha")
        DecisionItem(decisionId: 3, ipAddress: "192.168.200.1", expirationDate: Date().addingTimeInterval(3665), countryCode: "IT", decisionType: "throttling")
        DecisionItem(decisionId: 4, ipAddress: "10.0.0.1", expirationDate: Date().addingTimeInterval(90125), countryCode: "FR", decisionType: "ban")
    }
}
