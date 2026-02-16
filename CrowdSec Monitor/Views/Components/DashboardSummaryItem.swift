import SwiftUI

struct DashboardSummaryItem: View {
    var type: Enums.DashboardBoxSummaryType
    var value: Int
    
    init(type: Enums.DashboardBoxSummaryType, value: Int) {
        self.type = type
        self.value = value
    }
    
    var body: some View {
        let icon = {
            switch type {
            case .alerts:
                return "exclamationmark.triangle.fill"
            case .decisions:
                return "shield.fill"
            }
        }()
        
        let title = {
            switch type {
            case .alerts:
                return String(localized: "Alerts last 24 hours")
            case .decisions:
                return String(localized: "Active decisions")
            }
        }()
        
        let color = {
            switch type {
            case .alerts:
                return Color.orange
            case .decisions:
                return Color.red
            }
        }()
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .frame(width: 36, height: 36)
                    .foregroundStyle(Color.white)
                    .background(color)
                    .clipShape(Circle())
                Spacer()
                Text(verbatim: "\(value)")
                    .font(.system(size: 22))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.foreground)
            }
            Text(title)
                .fontWeight(.bold)
                .foregroundStyle(Color.gray)
                .font(.system(size: 14))
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.listItemBackground)
        .clipShape(.rect(cornerRadius: 20))
    }
}

#Preview {
    List {
        Section {} header: {
            HStack(spacing: 16) {
                DashboardSummaryItem(type: .alerts, value: 152)
                DashboardSummaryItem(type: .decisions, value: 6)
            }
        }
    }
}
