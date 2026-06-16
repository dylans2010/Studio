import Foundation

struct NoteBlock: Identifiable, Codable {
    var id = UUID()
    var type: BlockType
    var content: String

    enum BlockType: String, Codable, CaseIterable {
        case text
        case header
        case code
        case todo
    }
}

struct Note: Identifiable, Codable {
    var id = UUID()
    var title: String
    var blocks: [NoteBlock]
    var createdAt: Date = Date()
}
