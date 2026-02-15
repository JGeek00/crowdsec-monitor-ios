import SwiftUI

struct CloseButton: View {
    var onClose: () -> Void
    
    var body: some View {
        if #available(iOS 26, *) {
            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
            }
        }
        else {
            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .fontWeight(.semibold)
                    .foregroundColor(Color.foreground.opacity(0.5))
            }
            .buttonStyle(BorderedButtonStyle())
            .clipShape(Circle())
        }
    }
}

#Preview {
    CloseButton() {}
}
