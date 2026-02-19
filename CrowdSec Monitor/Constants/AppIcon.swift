import SwiftUI

enum AppIcon: String, CaseIterable, Identifiable {
    case purpleYellow = "AppIcon-PurpleYellow"
    case purple = "AppIcon-Purple"
    case yellow = "AppIcon-Yellow"
    
    var id: String { self.rawValue }
}
