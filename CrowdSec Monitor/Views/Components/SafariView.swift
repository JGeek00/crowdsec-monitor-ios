import SwiftUI
import SafariServices

/// A reusable SwiftUI wrapper for SFSafariViewController
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true
        
        let controller = SFSafariViewController(url: url, configuration: config)
        controller.preferredControlTintColor = .systemBlue
        controller.dismissButtonStyle = .close
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No update needed
    }
}

// MARK: - View Extension for easy presentation
extension View {
    /// Presents a Safari view in a fullscreen cover
    /// - Parameters:
    ///   - isPresented: Binding to control the presentation
    ///   - url: The URL to display
    func safariView(isPresented: Binding<Bool>, url: URL?) -> some View {
        fullScreenCover(isPresented: isPresented) {
            if let url = url {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
    
    /// Presents a Safari view in a fullscreen cover using a string URL
    /// - Parameters:
    ///   - isPresented: Binding to control the presentation
    ///   - urlString: The URL string to display
    func safariView(isPresented: Binding<Bool>, urlString: String?) -> some View {
        fullScreenCover(isPresented: isPresented) {
            if let urlString = urlString, let url = URL(string: urlString) {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
}
