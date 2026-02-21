import SwiftUI
import Network

@MainActor
@Observable
class CreateDecisionFormViewModel {
    var ipAddress: String = ""
    var durationDays: Int = 0
    var durationHours: Int = 4
    var durationMinutes: Int = 0
    var type: Enums.DecisionType = .ban
    var reason: String = ""
    
    var invalidFieldsAlert: Bool = false
    var invalidFieldsAlertMessage: String = ""
    var errorCreatingDecisionAlert: Bool = false
    var creatingDecision: Bool = false
    
    /// Converts the duration components to a string format (e.g., "4h", "1d 2h 30m")
    var durationString: String {
        var components: [String] = []
        
        if durationDays > 0 {
            components.append("\(durationDays)d")
        }
        if durationHours > 0 {
            components.append("\(durationHours)h")
        }
        if durationMinutes > 0 {
            components.append("\(durationMinutes)m")
        }
        
        return components.joined()
    }
    
    func validateValues() -> Bool {
        if ipAddress.isEmpty {
            invalidFieldsAlertMessage = String(localized: "IP Address is required")
            invalidFieldsAlert = true
            return false
        }
        if IPv4Address(ipAddress) == nil && IPv6Address(ipAddress) == nil {
            invalidFieldsAlertMessage = String(localized: "IP Address is invalid")
            invalidFieldsAlert = true
            return false
        }
        if durationDays == 0 && durationHours == 0 && durationMinutes == 0 {
            invalidFieldsAlertMessage = String(localized: "Duration must be greater than 0")
            invalidFieldsAlert = true
            return false
        }
        if reason.isEmpty {
            invalidFieldsAlertMessage = String(localized: "Reason is required")
            invalidFieldsAlert = true
            return false
        }
        return true
    }
    
    func save() async -> Bool {
        let validValues = validateValues()
        if !validValues {
            return false
        }
        
        guard let apiClient = AuthViewModel.shared.apiClient else { return false }
        
        do {
            creatingDecision = true
            let body = CreateDecisionRequest(ip: ipAddress, duration: durationString, type: type, reason: reason)
            _ = try await apiClient.decisions.createDecision(body: body)
            await DecisionsListViewModel.shared.refreshDecisions()
            creatingDecision = false
            
            return true
        } catch {
            print(error.localizedDescription)
            errorCreatingDecisionAlert = true
            creatingDecision = false
            
            return false
        }
    }
}
