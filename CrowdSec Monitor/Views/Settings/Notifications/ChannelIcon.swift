import SwiftUI

/// Maps a provider `icon` name to an image, with a generic fallback for
/// providers the app does not know yet.
struct ChannelIcon: View {
    let icon: String

    init(_ icon: String) {
        self.icon = icon
    }

    var body: some View {
        switch icon {
        case "ntfy":
            Image("ntfy")
                .resizable()
                .scaledToFit()
        case "email":
            Image(systemName: "envelope")
        default:
            Image(systemName: "bell")
        }
    }
}
