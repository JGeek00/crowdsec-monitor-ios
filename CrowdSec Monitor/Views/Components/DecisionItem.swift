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
    
    @State private var currentTime = Date()
    
    private var timeRemaining: String? {
        if let expirationDate = expirationDate {
            let timeInterval = expirationDate.timeIntervalSince(currentTime)
            
            if timeInterval <= 0 {
                return String(localized: "Expired")
            }
            
            let totalSeconds = Int(timeInterval)
            let days = totalSeconds / 86400
            let hours = (totalSeconds % 86400) / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60
            
            var components: [String] = []
            
            if days > 0 {
                components.append("\(days)d")
            }
            if hours > 0 {
                components.append("\(hours)h")
            }
            if minutes > 0 {
                components.append("\(minutes)m")
            }
            if seconds > 0 || components.isEmpty {
                components.append("\(seconds)s")
            }
            
            return components.joined(separator: " ")
        }
        return nil
    }
    
    private var isExpired: Bool? {
        if let expirationDate = expirationDate {
            return expirationDate.timeIntervalSince(currentTime) <= 0
        }
        else {
            return nil
        }
    }
    
    var body: some View {
        let decType = {
            if decisionType == "ban" {
                return decisionTypeChip(label: "Ban", color: .red, systemImage: "hand.raised.fill")
            }
            else if decisionType == "captcha" {
                return decisionTypeChip(label: "Captcha", color: .orange, systemImage: "puzzlepiece.fill")
            }
            else {
                return decisionTypeChip(label: decisionType.capitalized, color: .blue, systemImage: "shield.fill")
            }
        }
        
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(verbatim: ipAddress)
                    .fontWeight(.semibold)
                if let isExpired = isExpired, let timeRemaining = timeRemaining {
                    HStack(spacing: 10) {
                        Image(systemName: isExpired ? "clock.badge.xmark" : "clock")
                            .font(.system(size: 14))
                        Text(verbatim: timeRemaining)
                            .font(.system(size: 14))
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(isExpired ? .gray : .green)
                }
                if let country = countryCode {
                    CountryFlag(countryCode: country)
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                }
            }
            Spacer()
            decType()
                
        }
        .onAppear {
            currentTime = Date()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            currentTime = Date()
        }
    }
    
    @ViewBuilder
    func decisionTypeChip(label: String, color: Color, systemImage: String?) -> some View {
        HStack(spacing: 6) {
            if let image = systemImage {
                Image(systemName: image)
            }
            Text(verbatim: label)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(color)
        .fontWeight(.semibold)
        .foregroundStyle(Color.white)
        .clipShape(.rect(cornerRadius: 20))
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
