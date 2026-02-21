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
    
    enum Theme: String {
        case system
        case light
        case dark
    }
    
    enum TabViewTabs: String {
        case dashboard
        case alerts
        case decisions
        case settings
    }
    
    enum LoadingState<T> {
        case loading
        case success(T)
        case failure(Error)
        
        var isLoading: Bool {
            if case .loading = self {
                return true
            }
            return false
        }
        
        var data: T? {
            if case .success(let data) = self {
                return data
            }
            return nil
        }
        
        var error: Error? {
            if case .failure(let error) = self {
                return error
            }
            return nil
        }
    }
    
    enum DashboardBoxSummaryType: String {
        case alerts
        case decisions
    }
    
    enum DashboardItemType: String {
        case country
        case ipOwner
        case scenary
        case target
    }
    
    enum DecisionType: String, Codable, CaseIterable {
        case ban = "ban"
        case captcha = "captcha"
    }
    
    enum DecisionDuration: String, CaseIterable {
        case oneHour = "1h"
        case fourHours = "4h"
        case twelveHours = "12h"
        case oneDay = "24h"
        case threeDays = "72h"
        case oneWeek = "168h"
        case oneMonth = "720h"
        
        var displayName: String {
            switch self {
            case .oneHour:
                return "1 hora"
            case .fourHours:
                return "4 horas"
            case .twelveHours:
                return "12 horas"
            case .oneDay:
                return "1 día"
            case .threeDays:
                return "3 días"
            case .oneWeek:
                return "1 semana"
            case .oneMonth:
                return "1 mes"
            }
        }
    }
}

extension Enums.LoadingState: Equatable where T: Equatable {
    static func == (lhs: Enums.LoadingState<T>, rhs: Enums.LoadingState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.success(let lhsData), .success(let rhsData)):
            return lhsData == rhsData
        case (.failure, .failure):
            return true
        default:
            return false
        }
    }
}
