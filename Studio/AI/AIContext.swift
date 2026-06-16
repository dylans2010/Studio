import SwiftUI
import Combine

/// Manages the persistent AI context and shared state across the application.
class AIContext: ObservableObject {
    @Published var activeContext: String = ""
    @Published var suggestions: [String] = []
    @Published var isProcessing: Bool = false
    @Published var history: [String] = []
    @Published var config: AIConfiguration = AIConfiguration()

    func updateContext(_ text: String) {
        activeContext = text
        fetchSuggestions()
    }

    func fetchSuggestions() {
        guard config.selectedModel != nil else { return }
        Task {
            do {
                let newSuggestions = try await AIService.shared.getSuggestions(for: activeContext, config: config)
                await MainActor.run {
                    self.suggestions = newSuggestions
                }
            } catch {
                print("Error fetching suggestions: \(error)")
            }
        }
    }

    func performAction(_ action: String, on text: String) async -> String {
        await MainActor.run { isProcessing = true }
        defer { Task { @MainActor in isProcessing = false } }

        do {
            let result: String
            if action.contains("Summarize") {
                result = try await AIService.shared.summarize(text, config: config)
            } else if action.contains("Translate") {
                result = try await AIService.shared.translate(text, targetLanguage: "Spanish", config: config)
            } else if action.contains("Rewrite") {
                result = try await AIService.shared.rewrite(text, tone: "Professional", config: config)
            } else {
                result = try await AIService.shared.callLLM(prompt: action + " on this text: " + text, config: config)
            }

            await MainActor.run {
                history.append(result)
            }
            return result
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
}
