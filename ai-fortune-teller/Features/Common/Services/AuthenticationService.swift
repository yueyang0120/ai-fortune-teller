import Foundation

class AuthenticationService {
    static let shared = AuthenticationService()

    private init() {}

    func generateAuthHeaders() -> [String: String] {
        let apiKey = BackendConfig.geminiAPIKey
        return [
            "x-goog-api-key": apiKey,
            "Content-Type": "application/json"
        ]
    }
}
