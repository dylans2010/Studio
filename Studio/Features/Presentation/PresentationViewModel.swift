import SwiftUI
import Combine

class PresentationViewModel: ObservableObject {
    @Published var presentation: Presentation = Presentation(title: "New Presentation", slides: [Slide(title: "Welcome", content: "AI-Powered Deck")])
    @Published var selectedSlideId: UUID?
    @Published var isGenerating: Bool = false

    init() {
        selectedSlideId = presentation.slides.first?.id
    }

    func generateDeck(from topic: String, config: AIConfiguration) {
        guard config.selectedModel != nil else { return }
        isGenerating = true

        Task {
            do {
                let prompt = "Create a detailed outline for a 3-slide presentation about '\(topic)'. For each slide, provide a Title and a bulleted content list. Format as: Slide 1: [Title] | [Content] || Slide 2: ..."
                let response = try await AIService.shared.callLLM(prompt: prompt, config: config)

                let parts = response.components(separatedBy: "||")
                var newSlides: [Slide] = []

                for part in parts {
                    let slideParts = part.components(separatedBy: "|")
                    if slideParts.count >= 2 {
                        let title = slideParts[0].replacingOccurrences(of: "Slide [0-9]:", with: "", options: .regularExpression).trimmingCharacters(in: .whitespaces)
                        let content = slideParts[1].trimmingCharacters(in: .whitespaces)
                        newSlides.append(Slide(title: title, content: content))
                    }
                }

                await MainActor.run {
                    if !newSlides.isEmpty {
                        self.presentation.slides = newSlides
                        self.selectedSlideId = newSlides.first?.id
                    }
                    self.isGenerating = false
                }
            } catch {
                print("Generation error: \(error)")
                await MainActor.run { self.isGenerating = false }
            }
        }
    }
}
