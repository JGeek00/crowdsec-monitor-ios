import SwiftUI

struct DecisionIPGroupItem: View {
    let group: DecisionsByIPResponse_Group
    
    init(group: DecisionsByIPResponse_Group) {
        self.group = group
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(verbatim: group.ip)
                    .fontWeight(.medium)
                Spacer()
                    .frame(height: 8)
                if let country = group.country {
                    CountryFlag(countryCode: country)
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text("\(group.totalDecisions) decisions")
                Group {
                    if group.activeDecisions > 0 {
                        Text("\(group.activeDecisions) active")
                            .foregroundStyle(.green)
                    }
                    else {
                        Text("No active")
                            .foregroundStyle(.gray)
                    }
                }
            }
            .fontWeight(.semibold)
            .font(.system(size: 14))
            .padding(.leading, 4)
        }
    }
}

#Preview {
    List {
        DecisionIPGroupItem(group: DecisionsByIPResponse_Group(
            ip: "192.168.1.45",
            country: "US",
            owner: nil,
            asNumber: nil,
            latitude: nil,
            longitude: nil,
            range: "192.168.1.0/24",
            activeDecisions: 3,
            totalDecisions: 7
        ))
        DecisionIPGroupItem(group: DecisionsByIPResponse_Group(
            ip: "192.168.1.45",
            country: "US",
            owner: nil,
            asNumber: nil,
            latitude: nil,
            longitude: nil,
            range: "192.168.1.0/24",
            activeDecisions: 0,
            totalDecisions: 7
        ))
    }
}
