import SwiftUI
import Combine

struct DecisionTimer: View {
    private let expirationDate: Date?
    
    init(expirationDate: Date?) {
        self.expirationDate = expirationDate
    }
    
    @SharedAppStorage(StorageKeys.disableDecisionTimerAnimation) private var disableDecisionTimerAnimation: Bool = Defaults.disableDecisionTimerAnimation
    
    @State private var currentTime = Date()
    @State private var remainingTime: [Int]? = nil
    
    func calculateRemainingTime() {
        if let expirationDate = expirationDate {
            let timeInterval = expirationDate.timeIntervalSince(currentTime)
            
            if timeInterval < 1 {
                if disableDecisionTimerAnimation == true {
                    remainingTime = nil
                }
                else {
                    withAnimation {
                        remainingTime = nil
                    }
                }
                return
            }
            
            let totalSeconds = Int(timeInterval)
            let days = totalSeconds / 86400
            let hours = (totalSeconds % 86400) / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60
            
            if disableDecisionTimerAnimation == true {
                remainingTime = [days, hours, minutes, seconds]
            }
            else {
                withAnimation {
                    remainingTime = [days, hours, minutes, seconds]
                }
            }
        }
    }
    
    var body: some View {
        Group {
            HStack(spacing: 6) {
                Image(systemName: remainingTime == nil ? "clock.badge.xmark" : "clock")
                HStack(spacing: 4) {
                    if let remainingTime = remainingTime {
                        if remainingTime[0] > 0 {
                            Text(verbatim: "\(remainingTime[0])d")
                        }
                        if remainingTime[1] > 0 {
                            Text(verbatim: "\(remainingTime[1])h")
                        }
                        if remainingTime[2] > 0 {
                            Text(verbatim: "\(remainingTime[2])m")
                        }
                        if remainingTime[3] > 0 {
                            Text(verbatim: "\(remainingTime[3])s")
                        }
                    }
                    else {
                        Text("Expired")
                    }
                }
            }
            .contentTransition(.numericText())
            .fontWeight(.semibold)
            .foregroundColor(remainingTime == nil ? .gray : .green)
        }
        .onAppear {
            currentTime = Date()
            calculateRemainingTime()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            currentTime = Date()
            calculateRemainingTime()
        }
    }
}

#Preview("5 minutes") {
    DecisionTimer(expirationDate: Calendar.current.date(byAdding: .minute, value: 5, to: Date()))
}

#Preview("10 seconds") {
    DecisionTimer(expirationDate: Calendar.current.date(byAdding: .second, value: 10, to: Date()))
}
