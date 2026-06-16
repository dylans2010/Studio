import Foundation

struct AIConfiguration: Codable {
    var provider: AIProvider = .openai
    var apiKey: String = ""
    var baseURL: String = ""
    var selectedModel: AIModel? = nil
}

class AIService {
    static let shared = AIService()

    private init() {}

    func callLLM(prompt: String, systemPrompt: String = "You are a helpful assistant.", config: AIConfiguration) async throws -> String {
        guard let model = config.selectedModel, !config.apiKey.isEmpty else {
            throw NSError(domain: "AIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "AI not configured"])
        }

        let baseURL = config.baseURL.isEmpty ? config.provider.defaultBaseURL : config.baseURL
        let request = try buildRequest(for: config, prompt: prompt, systemPrompt: systemPrompt, baseURL: baseURL)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown Error"
            throw NSError(domain: "AIService", code: 2, userInfo: [NSLocalizedDescriptionKey: "API Request Failed: \(errorMsg)"])
        }

        return try parseResponse(for: config.provider, data: data)
    }

    private func buildRequest(for config: AIConfiguration, prompt: String, systemPrompt: String, baseURL: String) throws -> URLRequest {
        let modelID = config.selectedModel?.id ?? ""
        var request: URLRequest

        switch config.provider {
        case .openai, .openrouter, .custom:
            let url = URL(string: baseURL + "/chat/completions")!
            request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: Any] = [
                "model": modelID,
                "messages": [
                    ["role": "system", "content": systemPrompt],
                    ["role": "user", "content": prompt]
                ]
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

        case .claude:
            let url = URL(string: baseURL + "/messages")!
            request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(config.apiKey, forHTTPHeaderField: "x-api-key")
            request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: Any] = [
                "model": modelID,
                "max_tokens": 4096,
                "system": systemPrompt,
                "messages": [
                    ["role": "user", "content": prompt]
                ]
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

        case .gemini:
            // Gemini uses a specific model path in the URL
            let cleanModelID = modelID.replacingOccurrences(of: "models/", with: "")
            let url = URL(string: baseURL + "/models/\(cleanModelID):generateContent?key=\(config.apiKey)")!
            request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: Any] = [
                "contents": [
                    ["role": "user", "parts": [["text": systemPrompt + "\n\n" + prompt]]]
                ]
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        return request
    }

    private func parseResponse(for provider: AIProvider, data: Data) throws -> String {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        switch provider {
        case .openai, .openrouter, .custom:
            let choices = json?["choices"] as? [[String: Any]]
            let message = choices?.first?["message"] as? [String: Any]
            return message?["content"] as? String ?? ""

        case .claude:
            let content = json?["content"] as? [[String: Any]]
            return content?.first?["text"] as? String ?? ""

        case .gemini:
            let candidates = json?["candidates"] as? [[String: Any]]
            let content = candidates?.first?["content"] as? [String: Any]
            let parts = content?["parts"] as? [[String: Any]]
            return parts?.first?["text"] as? String ?? ""
        }
    }

    func summarize(_ text: String, config: AIConfiguration) async throws -> String {
        return try await callLLM(prompt: "Summarize the following text concisely:\n\n\(text)", config: config)
    }

    func rewrite(_ text: String, tone: String, config: AIConfiguration) async throws -> String {
        return try await callLLM(prompt: "Rewrite the following text in a \(tone) tone. ONLY return the rewritten text:\n\n\(text)", config: config)
    }

    func translate(_ text: String, targetLanguage: String, config: AIConfiguration) async throws -> String {
        return try await callLLM(prompt: "Translate the following text to \(targetLanguage). ONLY return the translation:\n\n\(text)", config: config)
    }

    func getSuggestions(for context: String, config: AIConfiguration) async throws -> [String] {
        let response = try await callLLM(prompt: "Given this context: '\(context)', provide 3 short action suggestions (3-5 words each) as a comma-separated list. ONLY return the list.", config: config)
        return response.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
}
