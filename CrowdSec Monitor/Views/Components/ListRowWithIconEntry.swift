import SwiftUI

struct ListRowWithIconEntry: View {
    var systemIcon: String?
    var assetIcon: String?
    var iconColor: Color
    var textColor: Color
    var label: String.LocalizationValue
    var badge: Int?
    
    init(systemIcon: String, iconColor: Color, textColor: Color = .foreground, label: String.LocalizationValue, badge: Int? = nil) {
        self.systemIcon = systemIcon
        self.assetIcon = nil
        self.textColor = textColor
        self.iconColor = iconColor
        self.label = label
        self.badge = badge
    }
    
    init(assetIcon: String, iconColor: Color, textColor: Color = .foreground, label: String.LocalizationValue) {
        self.systemIcon = nil
        self.assetIcon = assetIcon
        self.iconColor = iconColor
        self.textColor = textColor
        self.label = label
    }
    
    var body: some View {
        HStack {
            if systemIcon != nil {
                Image(systemName: systemIcon!)
                    .foregroundStyle(Color.white)
                    .frame(width: 28, height: 28)
                    .font(.system(size: 18))
                    .background(iconColor)
                    .cornerRadius(6)
            }
            if assetIcon != nil {
                Group {
                    Image(assetIcon!)
                        .resizable()
                        .frame(width: 18, height: 18)
                }
                .foregroundStyle(Color.black)
                .frame(width: 28, height: 28)
                .font(.system(size: 18))
                .background(iconColor)
                .cornerRadius(6)
            }
            Text(String(localized: label))
                .padding(.leading, 8)
            if let badge = badge {
                Spacer()
                Text(verbatim: "\(badge)")
                    .foregroundStyle(.white)
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                    .padding(.horizontal, 4)
                    .condition(transform: { view in
                        if badge < 10 {
                            view.background(Circle().fill(Color.red).frame(width: 20, height: 20))
                        }
                        else {
                            view.background(Capsule().fill(Color.red).frame(height: 20))
                        }
                    })
            }
        }
        .foregroundStyle(textColor)
    }
}

#Preview {
    List {
        ListRowWithIconEntry(systemIcon: "gear", iconColor: .blue, label: "Settings")
    }
}

#Preview("With badge") {
    List {
        ListRowWithIconEntry(systemIcon: "gear", iconColor: .blue, label: "Settings", badge: 5)
    }
}

