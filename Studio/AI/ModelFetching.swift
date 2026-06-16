import Foundation

enum AIProvider: String, CaseIterable, Codable {
    case openai = "OpenAI"
    case openrouter = "OpenRouter"
    case gemini = "Gemini"
    case claude = "Claude"
    case custom = "Custom"

    var defaultBaseURL: String {
        switch self {
        case .openai: return "https://api.openai.com/v1"
        case .openrouter: return "https://openrouter.ai/api/v1"
        case .gemini: return "https://generativelanguage.googleapis.com/v1beta"
        case .claude: return "https://api.anthropic.com/v1"
        case .custom: return ""
        }
    }
}

struct AIModel: Identifiable, Codable {
    var id: String
    var name: String
    var provider: AIProvider
}

struct AIConfiguration: Codable {
    var provider: AIProvider = .openai
    var apiKey: String = ""
    var baseURL: String = ""
    var selectedModel: AIModel? = nil
}

struct ModelFetching {
    static func fetchModels(for provider: AIProvider, apiKey: String, baseURL: String? = nil) async throws -> [AIModel] {
        let base = (baseURL ?? provider.defaultBaseURL)
        let url: URL

        switch provider {
        case .openai, .openrouter, .custom:
            url = URL(string: base + "/models")!
        case .gemini:
            url = URL(string: base + "/models?key=\(apiKey)")!
        case .claude:
            // Anthropic doesn't have a public models list API in the same way, return static common models
            return [
                AIModel(id: "claude-3-5-sonnet-20240620", name: "Claude 3.5 Sonnet", provider: .claude),
                AIModel(id: "claude-3-opus-20240229", name: "Claude 3 Opus", provider: .claude)
            ]
        }

        var request = URLRequest(url: url)
        if provider != .gemini {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        if provider == .gemini {
            struct GeminiResponse: Codable {
                struct Model: Codable { let name: String }
                let models: [Model]
            }
            let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
            return decoded.models.map { AIModel(id: $0.name, name: $0.name.replacingOccurrences(of: "models/", with: ""), provider: .gemini) }
        } else {
            struct OpenAIResponse: Codable {
                struct Model: Codable { let id: String }
                let data: [Model]
            }
            let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            return decoded.data.map { AIModel(id: $0.id, name: $0.id, provider: provider) }
        }
    }
}
