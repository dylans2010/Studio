import SwiftUI
import Combine

class TranslateViewModel: ObservableObject {
    @Published var sourceText: String = ""
    @Published var targetLanguage: String = "es"
    @Published var translationHistory: [TranslationItem] = []
    @Published var isTranslating: Bool = false

    func translate(with config: AIConfiguration) {
        guard !sourceText.isEmpty else { return }
        isTranslating = true

        Task {
            do {
                let result = try await AIService.shared.translate(sourceText, targetLanguage: targetLanguage, config: config)

                await MainActor.run {
                    let item = TranslationItem(sourceText: sourceText, translatedText: result, targetLanguage: targetLanguage)
                    translationHistory.insert(item, at: 0)
                    isTranslating = false
                }
            } catch {
                print("Translation error: \(error)")
                await MainActor.run { isTranslating = false }
            }
        }
    }
}
