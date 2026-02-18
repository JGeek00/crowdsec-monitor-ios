import SwiftUI
import Combine

struct DecisionTimer: View {
    private let expirationDate: Date?
    
    init(expirationDate: Date?) {
        self.expirationDate = expirationDate
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
        Group {
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
        }
        .onAppear {
            currentTime = Date()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            currentTime = Date()
        }
    }
}

#Preview {
    DecisionTimer(expirationDate: Calendar.current.date(byAdding: .minute, value: 5, to: Date()))
}
