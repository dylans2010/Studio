import Foundation

struct TranslationItem: Identifiable, Codable {
    var id = UUID()
    var sourceText: String
    var translatedText: String?
    var targetLanguage: String
    var timestamp: Date = Date()
}
