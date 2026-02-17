import SwiftUI

struct DashboardItem: View {
    let itemType: Enums.DashboardItemType
    let label: String
    let amount: Int
    
    init(itemType: Enums.DashboardItemType, label: String, amount: Int) {
        self.itemType = itemType
        self.label = label
        self.amount = amount
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        switch itemType {
        case .country:
            HStack {
                CountryFlag(countryCode: label)
                Spacer()
                Text("\(amount)")
            }
            
        case .ipOwner:
            HStack {
                Text(verbatim: label)
                    .condition { view in
                        if horizontalSizeClass == .regular {
                            view
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                Spacer()
                Text("\(amount)")
            }
        case .scenary:
            let splitted = label.split(separator: "/")
            HStack {
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
            }
        case .target:
            HStack {
                Text(verbatim: label)
                    .condition { view in
                        if horizontalSizeClass == .regular {
                            view
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                Spacer()
                Text("\(amount)")
            }
        }
    }
}

#Preview {
    DashboardItem(itemType: .country, label: "ES", amount: 6)
}
#Preview {
    DashboardItem(itemType: .ipOwner, label: "MICROSOFT", amount: 5)
}
#Preview {
    DashboardItem(itemType: .scenary, label: "crowdsec/bad-user-agent", amount: 12)
}
#Preview {
    DashboardItem(itemType: .target, label: "app.mydomain.com", amount: 8)
}

