import Foundation

enum ContentFormat {
    case note
    case document
    case presentation
    case meeting
}

class UnifiedContentConverter {
    static func convertToDocument(from note: Note) -> String {
        var doc = "# \(note.title)\n\n"
        for block in note.blocks {
            doc += block.content + "\n\n"
        }
        return doc
    }

    static func convertToPresentation(from documentContent: String) -> Presentation {
        let lines = documentContent.components(separatedBy: .newlines)
        let title = lines.first ?? "Generated Presentation"
        let slides = lines.dropFirst().filter { !$0.isEmpty }.map { line in
            Slide(title: "Key Point", content: line)
        }
        return Presentation(title: title, slides: Array(slides.prefix(5)))
    }
}
