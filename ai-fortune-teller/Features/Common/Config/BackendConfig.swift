import Foundation

enum AIProvider: String, CaseIterable, Identifiable {
    case gemini = "Gemini"
    case openAI = "OpenAI"
    case deepSeek = "DeepSeek"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .gemini: return "Gemini"
        case .openAI: return "GPT"
        case .deepSeek: return "DeepSeek"
        }
    }
}

enum BackendConfig {
    private static let selectedProviderKey = "selected_ai_provider"

    static var selectedProvider: AIProvider {
        get {
            if let storedValue = UserDefaults.standard.string(forKey: selectedProviderKey),
               let provider = AIProvider(rawValue: storedValue) {
                return provider
            }
            // Force default to Gemini if no valid selection exists
            return .gemini
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: selectedProviderKey)
        }
    }

    // MARK: - DeepSeek Configuration
    static var deepSeekAPIKey: String {
        if let envKey = ProcessInfo.processInfo.environment["DEEPSEEK_API_KEY"],
           !envKey.isEmpty {
            return envKey
        }

        if let plistKey = Bundle.main.object(forInfoDictionaryKey: "DEEPSEEK_API_KEY") as? String,
           !plistKey.isEmpty {
            return plistKey
        }

        return ""
    }

    static var deepSeekModel: String {
        if let envModel = ProcessInfo.processInfo.environment["DEEPSEEK_MODEL"],
           !envModel.isEmpty {
            return envModel
        }

        if let plistModel = Bundle.main.object(forInfoDictionaryKey: "DEEPSEEK_MODEL") as? String,
           !plistModel.isEmpty {
            return plistModel
        }

        return "deepseek-reasoner"
    }

    static var deepSeekEndpoint: String {
        // Standard DeepSeek API endpoint
        return "https://api.deepseek.com/chat/completions"
    }

    // MARK: - Gemini Configuration
    static var geminiAPIKey: String {
        // 优先从环境变量读取（最安全）
        if let envKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"],
           !envKey.isEmpty && envKey != "YOUR_GEMINI_API_KEY_HERE" {
            return envKey
        }

        // 然后从 Info.plist 读取（开发环境）
        if let plistKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String,
           !plistKey.isEmpty && plistKey != "YOUR_GEMINI_API_KEY_HERE" {
            return plistKey
        }

        // 如果都没有，返回空字符串并警告
        print("⚠️ Warning: GEMINI_API_KEY not configured")
        print("📝 Configure it in Info.plist or Environment Variables")
        return ""
    }

    static var geminiModel: String {
        // 优先从环境变量读取
        if let envModel = ProcessInfo.processInfo.environment["GEMINI_MODEL"],
           !envModel.isEmpty {
            return envModel
        }

        // 然后从 Info.plist 读取
        if let plistModel = Bundle.main.object(forInfoDictionaryKey: "GEMINI_MODEL") as? String,
           !plistModel.isEmpty {
            return plistModel
        }

        return "gemini-3.1-pro-preview"
    }

    static var geminiEndpoint: String {
        return "https://generativelanguage.googleapis.com/v1beta/models"
    }

    // MARK: - RAG File Search Configuration

    /// 紫微斗数知识库 Store Name
    static var fileSearchStoreName: String {
        // 优先从环境变量读取
        if let envStore = ProcessInfo.processInfo.environment["FILE_SEARCH_STORE_NAME"],
           !envStore.isEmpty {
            return envStore
        }

        // 然后从 Info.plist 读取
        if let plistStore = Bundle.main.object(forInfoDictionaryKey: "FILE_SEARCH_STORE_NAME") as? String,
           !plistStore.isEmpty {
            return plistStore
        }

        // 默认使用你刚创建的 Store
        return "fileSearchStores/ziweidoushuknowledgebase-hgze1uqldhrq"
    }

    /// 是否启用 RAG（知识库增强）
    private static let ragEnabledKey = "rag_enabled"

    static var isRAGEnabled: Bool {
        get {
            // 默认启用 RAG
            if UserDefaults.standard.object(forKey: ragEnabledKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: ragEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ragEnabledKey)
        }
    }

    // MARK: - OpenAI Configuration
    static var openAIAPIKey: String {

        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"],
           !envKey.isEmpty && envKey != "YOUR_OPENAI_API_KEY_HERE" {
            return envKey
        }

        // 然后从 Info.plist 读取（开发环境）
        if let plistKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String,
           !plistKey.isEmpty && plistKey != "YOUR_OPENAI_API_KEY_HERE" {
            return plistKey
        }

        // 如果都没有，返回空字符串并警告
        print("⚠️ Warning: OPENAI_API_KEY not configured")
        print("📝 Configure it in Info.plist or Environment Variables")
        return ""
    }

    static var openAIModel: String {
        // 优先从环境变量读取
        if let envModel = ProcessInfo.processInfo.environment["OPENAI_MODEL"],
           !envModel.isEmpty {
            return envModel
        }

        // 然后从 Info.plist 读取
        if let plistModel = Bundle.main.object(forInfoDictionaryKey: "OPENAI_MODEL") as? String,
           !plistModel.isEmpty {
            return plistModel
        }

        return "gpt-5.1"
    }

    static var openAIEndpoint: String {
        return "https://api.openai.com/v1/chat/completions"
    }

    static var openAIReasoningEffort: String {
        // 优先从环境变量读取
        if let envEffort = ProcessInfo.processInfo.environment["OPENAI_REASONING_EFFORT"],
           !envEffort.isEmpty {
            return envEffort
        }

        // 然后从 Info.plist 读取
        if let plistEffort = Bundle.main.object(forInfoDictionaryKey: "OPENAI_REASONING_EFFORT") as? String,
           !plistEffort.isEmpty {
            return plistEffort
        }

        return "high"
    }
}
