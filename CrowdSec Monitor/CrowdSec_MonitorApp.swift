//
//  CrowdSec_MonitorApp.swift
//  CrowdSec Monitor
//
//  Created by Juan Gilsanz Polo on 14/2/26.
//

import SwiftUI
import CoreData

@main
struct CrowdSec_MonitorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
