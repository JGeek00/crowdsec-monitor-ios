import UIKit
import SwiftUI
import OSLog

@MainActor
@Observable
class AppIconManager {
    static let shared = AppIconManager()
    
    var appIcon: AppIcon
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppIconManager")
    
    /// Initializes the model with the current state of the app's icon.
    init() {
        let iconName = UIApplication.shared.alternateIconName
        
        if let iconName, let icon = AppIcon(rawValue: iconName) {
            appIcon = icon
        } else {
            appIcon = Defaults.appIcon
        }
    }
    
    /// Change the app icon.
    func setAlternateAppIcon(icon: AppIcon) {
        // Set the icon name to nil to use the primary icon.
        let iconName: String? = (icon != Defaults.appIcon) ? icon.rawValue : nil
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error {
                self.logger.error("Failed request to update the app’s icon: \(error)")
            }
        }
        
        appIcon = icon
    }
}
