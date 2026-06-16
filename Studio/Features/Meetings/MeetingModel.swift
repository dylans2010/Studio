import Foundation

struct Meeting: Identifiable, Codable {
    var id = UUID()
    var title: String
    var date: Date
    var transcript: String?
    var summary: String?
    var participants: [String]
}

struct ChannelMessage: Identifiable, Codable {
    var id = UUID()
    var sender: String
    var content: String
    var timestamp: Date = Date()
}
