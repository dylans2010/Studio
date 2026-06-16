import Foundation

struct ChatMessage: Identifiable, Codable {
    var id = UUID()
    var role: Role
    var content: String
    var timestamp: Date = Date()

    enum Role: String, Codable {
        case user
        case assistant
        case system
    }
}
