import SwiftUI
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isSending: Bool = false

    func sendMessage(with config: AIConfiguration) {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard config.selectedModel != nil else { return }

        let userMessage = ChatMessage(role: .user, content: inputText)
        messages.append(userMessage)
        let context = inputText
        inputText = ""
        isSending = true

        Task {
            do {
                let response = try await AIService.shared.callLLM(prompt: context, config: config)
                await MainActor.run {
                    let assistantMessage = ChatMessage(role: .assistant, content: response)
                    messages.append(assistantMessage)
                    isSending = false
                }
            } catch {
                await MainActor.run {
                    messages.append(ChatMessage(role: .assistant, content: "Error: \(error.localizedDescription)"))
                    isSending = false
                }
            }
        }
    }
}
