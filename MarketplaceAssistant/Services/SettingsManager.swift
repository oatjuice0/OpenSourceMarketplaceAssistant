import Foundation

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private let apiKeyKeychainKey = "apiKey"
    private let apiProviderKey = "apiProvider"

    enum APIProvider: String, CaseIterable {
        case openai = "OpenAI"
        case anthropic = "Anthropic"
    }

    @Published var apiProvider: APIProvider {
        didSet {
            UserDefaults.standard.set(apiProvider.rawValue, forKey: apiProviderKey)
        }
    }

    var apiKey: String {
        get { KeychainHelper.load(key: apiKeyKeychainKey) ?? "" }
        set {
            objectWillChange.send()
            if newValue.isEmpty {
                KeychainHelper.delete(key: apiKeyKeychainKey)
            } else {
                KeychainHelper.save(key: apiKeyKeychainKey, value: newValue)
            }
        }
    }

    var hasAPIKey: Bool { !apiKey.isEmpty }

    private init() {
        let raw = UserDefaults.standard.string(forKey: apiProviderKey) ?? APIProvider.openai.rawValue
        self.apiProvider = APIProvider(rawValue: raw) ?? .openai
    }
}
