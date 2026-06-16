import SwiftUI
import Combine

class DocumentViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var title: String = "Untitled Document"
    @Published var isSaving: Bool = false

    func assistWriting() {
        Task {
            let suggestion = try? await AIService.shared.rewrite(content, tone: "Professional")
            if let suggestion = suggestion {
                await MainActor.run {
                    self.content = suggestion
                }
            }
        }
    }
}
