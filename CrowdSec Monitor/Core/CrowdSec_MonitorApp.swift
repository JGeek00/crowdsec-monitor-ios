import SwiftUI
internal import CoreData

@main
struct CrowdSec_MonitorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(AuthViewModel.shared)
                .environment(OnboardingViewModel.shared)
                .environment(AppIconManager.shared)
        }
    }
}
