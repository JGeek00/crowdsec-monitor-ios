import SwiftUI

struct DecisionTypeChip: View {
    let label: String
    let color: Color
    let systemImage: String?
    let inverse: Bool
    
    init(label: String, color: Color, systemImage: String?, inverse: Bool = false) {
        self.label = label
        self.color = color
        self.systemImage = systemImage
        self.inverse = inverse
    }
    
    var body: some View {
        HStack(spacing: 6) {
            if let image = systemImage {
                Image(systemName: image)
            }
            Text(verbatim: label)
        }
        .fontWeight(.semibold)
        .condition { view in
            if inverse == true {
                view
                    .foregroundStyle(color)
            }
            else {
                view
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color)
                    .foregroundStyle(Color.white)
                    .clipShape(.rect(cornerRadius: 20))
            }
        }
    }
}

#Preview {
    DecisionTypeChip(label: "Ban", color: .red, systemImage: "xmark.octagon.fill")
}
