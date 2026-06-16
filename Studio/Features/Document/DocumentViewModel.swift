import SwiftUI
import Combine

class DocumentViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var title: String = "Untitled Document"
    @Published var isSaving: Bool = false

    func assistWriting(with config: AIConfiguration) {
        Task {
            let suggestion = try? await AIService.shared.rewrite(content, tone: "Professional", config: config)
            if let suggestion = suggestion {
                await MainActor.run {
                    self.content = suggestion
                }
            }
        }
    }
}
