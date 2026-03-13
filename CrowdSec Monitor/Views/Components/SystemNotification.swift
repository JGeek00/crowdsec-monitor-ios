import SwiftUI

struct SystemNotification: View {
    let icon: String
    let title: String
    let subtitle: String?
    let color: Color?
    
    init(icon: String, title: String, subtitle: String?, color: Color? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .fontWeight(.semibold)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.medium)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                }
            }
        }
        .foregroundStyle(color ?? Color.foreground)
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .condition { view in
            if #available(iOS 26.0, *) {
                view.glassEffect()
            }
            else {
                view.background(Material.regular)
            }
        }
    }
}

#Preview {
    SystemNotification(icon: "checkmark", title: "Checkmark demo", subtitle: "This is a subtitle", color: .green)
}
