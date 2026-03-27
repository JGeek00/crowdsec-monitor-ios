internal import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Example for previews
        let server = CSServer(context: viewContext)
        server.id = UUID()
        server.http = "https"
        server.domain = "api.example.com"
        server.port = 8080
        server.path = "/api/v1"
        server.authMethod = "bearer"
        server.bearerToken = "example_token"
        server.name = "Server 0"
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CrowdSec_Monitor")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Perform manual migration if needed before loading the store
            PersistenceController.migrateStoreIfNeeded(for: container)
        }
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Manual migration

    private static func migrateStoreIfNeeded(for container: NSPersistentContainer) {
        guard let storeURL = container.persistentStoreDescriptions.first?.url else { return }

        // Load the bundle that contains all model versions
        let bundle = Bundle.main
        guard let momdURL = bundle.url(forResource: "CrowdSec_Monitor", withExtension: "momd") else { return }
        let modelBundle = Bundle(url: momdURL) ?? bundle

        // Build the list of versioned model URLs in migration order
        let modelVersionNames = ["CrowdSec_Monitor", "CrowdSec_Monitor 2"]
        var modelURLs: [URL] = []
        for name in modelVersionNames {
            if let url = modelBundle.url(forResource: name, withExtension: "mom") {
                modelURLs.append(url)
            } else if let url = bundle.url(forResource: name, withExtension: "mom", subdirectory: "CrowdSec_Monitor.momd") {
                modelURLs.append(url)
            }
        }
        guard modelURLs.count == modelVersionNames.count else { return }

        // Check whether the current store metadata matches the destination model
        guard let storeMetadata = try? NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType, at: storeURL, options: nil
        ) else { return }

        let destinationModel = NSManagedObjectModel(contentsOf: modelURLs.last!)!
        if destinationModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: storeMetadata) {
            // Already at the latest version, nothing to do
            return
        }

        // Migrate step by step through each consecutive pair of model versions
        for i in 0..<(modelURLs.count - 1) {
            let sourceModelURL = modelURLs[i]
            let destModelURL   = modelURLs[i + 1]

            guard
                let sourceModel = NSManagedObjectModel(contentsOf: sourceModelURL),
                let destModel   = NSManagedObjectModel(contentsOf: destModelURL)
            else { continue }

            // Re-check if this step is still needed
            guard let currentMetadata = try? NSPersistentStoreCoordinator.metadataForPersistentStore(
                ofType: NSSQLiteStoreType, at: storeURL, options: nil
            ) else { continue }
            if destModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: currentMetadata) { continue }
            if !sourceModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: currentMetadata) { continue }

            // Build an inferred mapping model and attach our custom policy
            guard let mappingModel = try? NSMappingModel.inferredMappingModel(
                forSourceModel: sourceModel, destinationModel: destModel
            ) else { continue }

            // Attach CSServerMigrationPolicy to the CSServer entity mapping
            for entityMapping in mappingModel.entityMappings where entityMapping.sourceEntityName == "CSServer" {
                entityMapping.entityMigrationPolicyClassName = NSStringFromClass(CSServerMigrationPolicy.self)
            }

            let migrationManager = NSMigrationManager(
                sourceModel: sourceModel, destinationModel: destModel
            )

            // Migrate to a temporary file, then replace the original
            let tempURL = storeURL.deletingLastPathComponent()
                .appendingPathComponent("migration_tmp.sqlite")

            do {
                try migrationManager.migrateStore(
                    from: storeURL,
                    sourceType: NSSQLiteStoreType,
                    options: nil,
                    with: mappingModel,
                    toDestinationURL: tempURL,
                    destinationType: NSSQLiteStoreType,
                    destinationOptions: nil
                )
                // Replace original store with the migrated one
                let coordinator = NSPersistentStoreCoordinator(managedObjectModel: destModel)
                try coordinator.replacePersistentStore(
                    at: storeURL,
                    destinationOptions: nil,
                    withPersistentStoreFrom: tempURL,
                    sourceOptions: nil,
                    ofType: NSSQLiteStoreType
                )
                // Clean up temp files
                let fm = FileManager.default
                for ext in ["", "-shm", "-wal"] {
                    let url = tempURL.appendingPathExtension(ext.isEmpty ? "" : ext)
                    try? fm.removeItem(at: url)
                }
            } catch {
                print("CoreData migration error: \(error)")
            }
        }
    }
}
