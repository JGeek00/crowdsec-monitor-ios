import Foundation

extension Notification.Name {
    static let serverDidChange = Notification.Name("serverDidChange")
    static let repositoriesDidReset = Notification.Name("repositoriesDidReset")
    static let decisionsShouldRefresh = Notification.Name("decisionsShouldRefresh")
    static let alertsShouldRefresh = Notification.Name("alertsShouldRefresh")
    static let decisionShouldExpire = Notification.Name("decisionShouldExpire")
    static let shouldShowOnboarding = Notification.Name("shouldShowOnboarding")
}
