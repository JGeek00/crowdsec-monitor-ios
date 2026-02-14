import Foundation

class Enums {
    enum ConnectionMethod: String {
        case http
        case https
    }
    
    enum AuthMethod: String {
        case none
        case basic
        case bearer
    }
    
    enum TabViewTabs: String {
        case dashboard
        case settings
    }
}
