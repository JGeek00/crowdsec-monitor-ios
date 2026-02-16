import SwiftUI

struct ListRowWithIconEntry: View {
    var systemIcon: String?
    var assetIcon: String?
    var iconColor: Color
    var textColor: Color
    var label: String.LocalizationValue
    
    init(systemIcon: String, iconColor: Color, textColor: Color = .foreground, label: String.LocalizationValue) {
        self.systemIcon = systemIcon
        self.assetIcon = nil
        self.textColor = textColor
        self.iconColor = iconColor
        self.label = label
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
        }
        .foregroundStyle(textColor)
    }
}

#Preview {
    List {
        ListRowWithIconEntry(systemIcon: "gear", iconColor: .blue, label: "Settings")
    }
}
