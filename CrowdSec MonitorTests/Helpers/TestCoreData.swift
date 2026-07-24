import CoreData

/// Provides in-memory Core Data containers and seeded `CSServer` instances
/// for Repository and Integration tests, avoiding persistent-store pollution (REQ-020).
enum TestCoreData {
    /// Build an in-memory `NSPersistentContainer` for the `CrowdSec_Monitor`
    /// data model. Store URL is `/dev/null` so nothing is written to disk.
    static func makeContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "CrowdSec_Monitor")
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            precondition(error == nil, "Failed to load in-memory store: \(error!.localizedDescription)")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }

    /// Create a `CSServer` test instance in the given context with defaults.
    /// Override any parameter to create variant servers (port=0, path=nil, etc.).
    static func makeServer(
        in context: NSManagedObjectContext,
        id: UUID = UUID(),
        name: String = "Server 0",
        domain: String = "api.example.com",
        http: String = "https",
        port: Int32 = 8080,
        path: String? = "/api/v1",
        authMethod: String = "bearer",
        basicUser: String? = nil,
        basicPassword: String? = nil,
        bearerToken: String = "test_token",
        isDefaultServer: Bool? = nil
    ) -> NSManagedObject {
        let server = NSEntityDescription.insertNewObject(forEntityName: "CSServer", into: context)
        server.setValue(id, forKey: "id")
        server.setValue(name, forKey: "name_stored")
        server.setValue(domain, forKey: "domain")
        server.setValue(http, forKey: "http")
        server.setValue(port, forKey: "port")
        server.setValue(path, forKey: "path")
        server.setValue(authMethod, forKey: "authMethod")
        server.setValue(basicUser, forKey: "basicUser")
        server.setValue(basicPassword, forKey: "basicPassword")
        server.setValue(bearerToken, forKey: "bearerToken")
        if let isDefault = isDefaultServer {
            server.setValue(NSNumber(value: isDefault), forKey: "defaultServer")
        }
        try? context.save()
        return server
    }
}
