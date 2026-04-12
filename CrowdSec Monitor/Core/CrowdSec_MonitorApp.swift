import SwiftUI
internal import CoreData

@main
struct CrowdSec_MonitorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(ServersManagerViewModel.shared)
                .environment(ActiveServerViewModel.shared)
                .environment(OnboardingViewModel.shared)
                .environment(ServiceStatusViewModel.shared)
                .environment(AppIconManager.shared)
                .environment(TipsViewModel())
        }
    }
}
