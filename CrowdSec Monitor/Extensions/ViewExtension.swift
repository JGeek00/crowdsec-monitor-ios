import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

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
    
    /// Default button style before iOS 26, glass effect on iOS 26 and later.
    @ViewBuilder
    func glassButtonIfAvailable() -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self
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

    /// Resigns any first responder (closes the keyboard). Call before
    /// changing wizard steps or presenting a sheet, so a visible keyboard
    /// never stays open across steps nor interferes with sheet presentation.
    func dismissKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
        #endif
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
