import SwiftUI

struct DashboardItem: View {
    let itemType: Enums.DashboardItemType
    let label: String
    let amount: Int
    
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
                Spacer()
                Text("\(amount)")
            }
        case .scenary:
            let splitted = label.split(separator: "/")
            HStack {
                VStack(alignment: .leading) {
                    Text(verbatim: String(splitted[0]))
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gray)
                    Text(verbatim: String(splitted[1]))
                }
                Spacer()
                Text("\(amount)")
            }
        case .target:
            HStack {
                Text(verbatim: label)
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

