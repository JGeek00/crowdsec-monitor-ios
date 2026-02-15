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
            self.buttonStyle(.bordered)
        }
        #endif
    }
    
    @ViewBuilder
    func condition<Content: View>(@ViewBuilder transform: (Self) -> Content) -> some View {
        transform(self)
    }
}
