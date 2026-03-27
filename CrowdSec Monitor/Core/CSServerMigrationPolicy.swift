internal import CoreData

/// Custom migration policy for CSServer entity.
/// Assigns `name = "Server \(index)"` to existing rows when migrating
/// from the original model (without `name`) to version 2 (with `name`).
class CSServerMigrationPolicy: NSEntityMigrationPolicy {

    override func createDestinationInstances(
        forSource sourceInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        // Let Core Data create the destination instance with standard attribute mapping
        try super.createDestinationInstances(forSource: sourceInstance, in: mapping, manager: manager)

        // Retrieve the newly created destination instance
        guard let destinationInstance = manager
            .destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sourceInstance])
            .first else { return }

        // Derive a name from the `index` attribute (Int32)
        let index = sourceInstance.primitiveValue(forKey: "index") as? Int32 ?? 0
        destinationInstance.setValue("Server \(index)", forKey: "name_stored")
    }
}
