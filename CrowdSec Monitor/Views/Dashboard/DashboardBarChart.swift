import SwiftUI
import Charts

struct DashboardBarChart: View {
    let activityHistory: [ActivityHistory]
    
    init(activityHistory: [ActivityHistory]) {
        self.activityHistory = activityHistory
    }
    
    @State private var selectedDate: String?
    @State private var plotWidth: CGFloat = 0
    
    var body: some View {
        VStack {
            HStack {
                Text("Activity History")
                    .fontWeight(.semibold)
                    .font(.system(size: 16))
            }
            Chart {
                ForEach(activityHistory) { item in
                    let dateString = item.date.toDateFromYYYYMMDD()?.toShortDateString() ?? item.date
                    
                    BarMark(
                        x: .value("Date", dateString),
                        y: .value("Amount", item.amountDecisions)
                    )
                    .foregroundStyle(.blue)
                    .position(by: .value("Type", "Decisions"))
                    
                    if item.amountAlerts > item.amountDecisions {
                        BarMark(
                            x: .value("Date", dateString),
                            y: .value("Amount", item.amountAlerts - item.amountDecisions)
                        )
                        .foregroundStyle(.orange)
                        .position(by: .value("Type", "Other Alerts"))
                    }
                }
                
                if let selectedDate {
                    RuleMark(x: .value("Date", selectedDate))
                        .lineStyle(.init(lineWidth: 2, dash: [4, 4]))
                        .foregroundStyle(Color.gray.opacity(0.5))
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel {
                        if let date = value.as(String.self) {
                            Text(date)
                                .font(.caption)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXSelection(value: $selectedDate)
            .chartLegend(position: .bottom, alignment: .center)
            .animation(.easeOut, value: self.activityHistory)
            .frame(height: 200)
            .padding()
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    ZStack(alignment: .top) {
                        Rectangle()
                            .fill(.clear)
                        
                        if let selectedDate,
                           let selectedItem = activityHistory.first(where: {
                               ($0.date.toDateFromYYYYMMDD()?.toShortDateString() ?? $0.date) == selectedDate
                           }),
                           let xPosition = chartProxy.position(forX: selectedDate) {
                            
                            VStack(spacing: 4) {
                                Text("Alerts: \(selectedItem.amountAlerts)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                if selectedItem.amountDecisions > 0 {
                                    Text("Decisions: \(selectedItem.amountDecisions)")
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .condition { view in
                                if #available(iOS 26.0, *) {
                                    view
                                        .glassEffect()
                                } else {
                                    view
                                        .background(Color(.systemBackground))
                                        .cornerRadius(8)
                                }
                            }
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .offset(x: xPosition - geometry.size.width / 2 + 30, y: -40)
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                            .animation(.easeOut(duration: 0.2), value: selectedDate)
                        }
                    }
                }
            }
            
            HStack {
                Circle()
                    .foregroundStyle(Color.blue)
                    .frame(width: 12, height: 12)
                Text("Decisions")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.gray)
                    .fontWeight(.semibold)
            }
            .frame(alignment: .leading)
        }
    }
}

#Preview {
    DashboardBarChart( activityHistory: [
        ActivityHistory(date: "2026-02-09", amountAlerts: 11, amountDecisions: 11),
        ActivityHistory(date: "2026-02-10", amountAlerts: 12, amountDecisions: 12),
        ActivityHistory(date: "2026-02-11", amountAlerts: 24, amountDecisions: 24),
        ActivityHistory(date: "2026-02-12", amountAlerts: 19, amountDecisions: 19),
        ActivityHistory(date: "2026-02-13", amountAlerts: 18, amountDecisions: 18),
        ActivityHistory(date: "2026-02-14", amountAlerts: 15, amountDecisions: 15),
    ])
}
