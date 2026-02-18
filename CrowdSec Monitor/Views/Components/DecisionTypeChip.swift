import SwiftUI

struct DecisionTypeChip: View {
    let label: String
    let color: Color
    let systemImage: String?
    
    init(label: String, color: Color, systemImage: String?) {
        self.label = label
        self.color = color
        self.systemImage = systemImage
    }
    
    var body: some View {
        HStack(spacing: 6) {
            if let image = systemImage {
                Image(systemName: image)
            }
            Text(verbatim: label)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(color)
        .fontWeight(.semibold)
        .foregroundStyle(Color.white)
        .clipShape(.rect(cornerRadius: 20))
    }
}

#Preview {
    DecisionTypeChip(label: "Ban", color: .red, systemImage: "xmark.octagon.fill")
}
