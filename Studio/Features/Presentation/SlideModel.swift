import Foundation

struct Slide: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var layout: LayoutType = .titleAndContent

    enum LayoutType: String, Codable {
        case titleOnly
        case titleAndContent
        case twoColumns
    }
}

struct Presentation: Identifiable, Codable {
    var id = UUID()
    var title: String
    var slides: [Slide]
}
