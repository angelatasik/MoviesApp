import Foundation

enum Environment {
    enum Keys {
        static let baseURL = "API_BASE_URL"
        static let accessToken = "API_READ_ACCESS_TOKEN"
        static let environmentName = "ENVIRONMENT_NAME"
    }

    static var baseURL: String {
        value(for: Keys.baseURL)
    }

    static var accessToken: String {
        value(for: Keys.accessToken)
    }

    static var environmentName: String {
        value(for: Keys.environmentName)
    }

    static var isDevelopment: Bool {
        environmentName == "Development"
    }

    private static func value(for key: String) -> String {
        guard let value = Bundle.main.infoDictionary?[key] as? String else {
            fatalError("Missing environment key: \(key)")
        }
        return value
    }
}
