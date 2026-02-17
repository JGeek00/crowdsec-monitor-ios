import SwiftUI

struct DashboardItem: View {
    let itemType: Enums.DashboardItemType
    let label: String
    let amount: Int
    let percentage: Double
    let color: Color?
    
    init(itemType: Enums.DashboardItemType, label: String, amount: Int, percentage: Double, color: Color? = nil) {
        self.itemType = itemType
        self.label = label
        self.amount = amount
        self.percentage = percentage
        self.color = color
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        switch itemType {
        case .country:
            HStack {
                colorCircle(color)
                CountryFlag(countryCode: label)
                Spacer()
                Text(verbatim: "\(amount)")
                percentageText(percentage)
            }
            
        case .ipOwner:
            HStack {
                colorCircle(color)
                Text(verbatim: label)
                    .condition { view in
                        if horizontalSizeClass == .regular {
                            view
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        else { view }
                    }
                Spacer()
                Text(verbatim: "\(amount)")
                percentageText(percentage)
            }
        case .scenary:
            let splitted = label.split(separator: "/")
            HStack {
                colorCircle(color)
                if horizontalSizeClass == .compact {
                    VStack(alignment: .leading) {
                        Text(verbatim: String(splitted[0]))
                            .font(.system(size: 14))
                            .foregroundStyle(Color.gray)
                        Text(verbatim: String(splitted[1]))
                    }
                } else {
                    HStack(alignment: .center) {
                        Text(verbatim: String(splitted[0]))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 1.8)
                            .background(Rectangle().fill(Color.gray).cornerRadius(20))
                        Spacer()
                            .frame(width: 12)
                        Text(verbatim: String(splitted[1]))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                Spacer()
                Text("\(amount)")
                percentageText(percentage)
            }
        case .target:
            HStack {
                colorCircle(color)
                Text(verbatim: label)
                    .condition { view in
                        if horizontalSizeClass == .regular {
                            view
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        else { view }
                    }
                Spacer()
                Text(verbatim: "\(amount)")
                percentageText(percentage)
            }
        }
    }
    
    @ViewBuilder
    func colorCircle(_ color: Color?) -> some View {
        if let color = color {
            HStack {
                Circle()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(color)
                Spacer()
                    .frame(width: 16)
            }
        }
    }
    
    @ViewBuilder
    func percentageText(_ value: Double) -> some View {
        Spacer()
            .frame(width: 4)
        Text(verbatim: "(\(Int(percentage*100.rounded()))%)")
            .foregroundStyle(.secondary)
            .font(.system(size: 14))
            .fontDesign(.monospaced)
    }
}

#Preview {
    DashboardItem(itemType: .country, label: "ES", amount: 6, percentage: 14.4)
}
#Preview {
    DashboardItem(itemType: .ipOwner, label: "MICROSOFT", amount: 5,percentage: 3.8)
}
#Preview {
    DashboardItem(itemType: .scenary, label: "crowdsec/bad-user-agent", amount: 12, percentage: 43.1)
}
#Preview {
    DashboardItem(itemType: .target, label: "app.mydomain.com", amount: 8, percentage: 22.6)
}

