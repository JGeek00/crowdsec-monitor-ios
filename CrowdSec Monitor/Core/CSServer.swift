internal import CoreData

@objc(CSServer)
class CSServer: NSManagedObject {

    // MARK: - Non-optional attributes
    @NSManaged var authMethod: String
    @NSManaged var domain: String
    @NSManaged var http: String
    @NSManaged var id: UUID

    // MARK: - 'name' is new in v2, use private backing to expose as non-optional
    @NSManaged private var name_stored: String?
    var name: String {
        get { name_stored ?? "" }
        set { name_stored = newValue }
    }

    // MARK: - Optional attributes
    @NSManaged private var defaultServer: NSNumber?
    var isDefaultServer: Bool? {
        get { defaultServer?.boolValue }
        set { defaultServer = newValue.map { NSNumber(value: $0) } }
    }
    @NSManaged var basicPassword: String?
    @NSManaged var basicUser: String?
    @NSManaged var bearerToken: String?
    @NSManaged var path: String?
    @NSManaged var port: Int32

    // MARK: - Fetch request
    @nonobjc class func fetchRequest() -> NSFetchRequest<CSServer> {
        return NSFetchRequest<CSServer>(entityName: "CSServer")
    }
}
