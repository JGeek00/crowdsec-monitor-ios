import SwiftUI

extension View {
    @ViewBuilder
    func prominentButton() -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
        #endif
    }
    
    @ViewBuilder
    func normalButton() -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(.borderless)
        }
        #endif
    }
    
    @ViewBuilder
    func condition<Content: View>(@ViewBuilder transform: (Self) -> Content) -> some View {
        transform(self)
    }
    
    @ViewBuilder
    func listContainerStyling() -> some View {
        self
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color.background)
            .cornerRadius(24)
    }
    
    @ViewBuilder
    func listItemStyling() -> some View {
        self
            .background(Color.background)
    }
    
    @ViewBuilder
    func listRowButton() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.background)
    }
}

struct PressableListRowModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isPressed ? Color.gray.opacity(0.3) : Color.clear)
            )
            .contentShape(Rectangle())
            .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            }, perform: {})
    }
}

extension View {
    func pressableListRow() -> some View {
        self.modifier(PressableListRowModifier())
    }
}
