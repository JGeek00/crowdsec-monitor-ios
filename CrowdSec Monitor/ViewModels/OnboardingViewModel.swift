import Foundation
import SwiftUI
import Network

@MainActor
@Observable
class OnboardingViewModel {
    static let shared = OnboardingViewModel()
    
    var showOnboarding: Bool = false
    var selectedTab: Int = 0
    
    var connectionMethod: Enums.ConnectionMethod = .http
    var ipDomain: String = ""
    var port: String = ""
    var path: String = ""
    var authMethod: Enums.AuthMethod = .none
    var basicUser: String = ""
    var basicPassword: String = ""
    var bearerToken: String = ""
    
    var connecting: Bool = false
    
    var invalidValuesAlert: Bool = false
    var invalidValuesMessage: String = ""
    
    var connectionErrorAlert: Bool = false
    var connectionErrorMessage: String = ""
    
    private init() {}
    
    init(
        showOnboarding: Bool = false,
        selectedTab: Int = 0,
    ) {
        self.showOnboarding = showOnboarding
        self.selectedTab = selectedTab
    }
    
    var isFormValid: Bool {
        guard !ipDomain.isEmpty else { return false }
        
        if authMethod == .basic {
            return !basicUser.isEmpty && !basicPassword.isEmpty
        } else if authMethod == .bearer {
            return !bearerToken.isEmpty
        }
        
        return true
    }
    
    
    func checkValues() -> Bool {
        invalidValuesAlert = false
        invalidValuesMessage = ""
        
        if ipDomain.isEmpty {
            invalidValuesAlert = true
            invalidValuesMessage = String(localized: "IP/Domain field is required")
            return false
        }
        
        if (try? RegExps.domain.wholeMatch(in: ipDomain)) == nil && IPv4Address(ipDomain) == nil && IPv6Address(ipDomain) == nil {
            invalidValuesAlert = true
            invalidValuesMessage = String(localized: "IP/Domain value is not valid")
            return false
        }
        
        if !port.isEmpty {
            if let portNumber = Int32(port) {
                if portNumber <= 0 || portNumber > 65535 {
                    invalidValuesAlert = true
                    invalidValuesMessage = String(localized: "Port must be between 1 and 65535")
                    return false
                }
            } else {
                invalidValuesAlert = true
                invalidValuesMessage = String(localized: "Port must be a valid number")
                return false
            }
        }
        
        if authMethod == .basic {
            if basicUser.isEmpty {
                invalidValuesAlert = true
                invalidValuesMessage = String(localized: "Username is required for basic authentication")
                return false
            }
            if basicPassword.isEmpty {
                invalidValuesAlert = true
                invalidValuesMessage = String(localized: "Password is required for basic authentication")
                return false
            }
        } else if authMethod == .bearer {
            if bearerToken.isEmpty {
                invalidValuesAlert = true
                invalidValuesMessage = String(localized: "Token is required for Bearer authentication")
                return false
            }
        }
        
        return true
    }
    
    func openOnboarding() {
        reset()
        showOnboarding = true
    }
    
    func connect() {
        Task {
            await startConnection()
        }
    }
    
    private func startConnection() async {
        guard checkValues() else { return }
        
        connecting = true
        connectionErrorAlert = false
        connectionErrorMessage = ""
        
        do {
            let portValue = port.isEmpty ? nil : Int32(port)
            let pathValue = path.isEmpty ? nil : path
            let authMethodValue = authMethod == .none ? nil : authMethod.rawValue
            let basicUserValue = authMethod == .basic ? basicUser : nil
            let basicPasswordValue = authMethod == .basic ? basicPassword : nil
            let bearerTokenValue = authMethod == .bearer ? bearerToken : nil
            
            let testClient = HttpClient(
                connectionMethod: connectionMethod.rawValue,
                ipDomain: ipDomain,
                port: portValue,
                path: pathValue,
                authMethod: authMethodValue,
                basicUser: basicUserValue,
                basicPassword: basicPasswordValue,
                bearerToken: bearerTokenValue
            )
            
            let healthResponse: HttpResponse<ApiStatusResponse> = try await testClient.get(endpoint: "/api/v1/status")
            
            guard healthResponse.successful == true else {
                connectionErrorAlert = true
                connectionErrorMessage = String(localized: "Connection was not successful")
                connecting = false
                return
            }
            
            try await AuthViewModel.shared.saveServer(
                connectionMethod: connectionMethod,
                ipDomain: ipDomain,
                port: portValue,
                path: pathValue,
                authMethod: authMethod,
                basicUser: basicUserValue,
                basicPassword: basicPasswordValue,
                bearerToken: bearerTokenValue
            )
            
            showOnboarding = false
            connecting = false
            
        } catch let error as HttpClientError {
            connectionErrorAlert = true
            switch error {
            case .unauthorized:
                connectionErrorMessage = String(localized: "Invalid credentials. Please verify your username, password, or token.")
            case .httpError(let statusCode):
                connectionErrorMessage = String(localized: "Server error: code \(statusCode)")
            case .invalidResponse:
                connectionErrorMessage = String(localized: "Invalid server response")
            case .decodingError:
                connectionErrorMessage = String(localized: "Error interpreting server response")
            case .networkError(let networkError):
                connectionErrorMessage = String(localized: "Network error: \(networkError.localizedDescription)")
            }
            connecting = false
        } catch {
            connectionErrorAlert = true
            connectionErrorMessage = String(localized: "Could not connect to server: \(error.localizedDescription)")
            connecting = false
        }
    }
    
    func reset() {
        selectedTab = 0
        
        connectionMethod = .http
        ipDomain = ""
        port = ""
        path = ""
        authMethod = .none
        basicUser = ""
        basicPassword = ""
        bearerToken = ""
        
        invalidValuesAlert = false
        invalidValuesMessage = ""
        
        connectionErrorAlert = false
        connectionErrorMessage = ""

        connecting = false
    }
}
