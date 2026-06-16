import XCTest
@testable import Studio

final class StudioTests: XCTestCase {

    func testAIServiceSummarize() async throws {
        let service = AIService.shared
        let config = AIConfiguration(provider: .openai, apiKey: "test", baseURL: "http://localhost", selectedModel: AIModel(id: "gpt-4", name: "GPT-4", provider: .openai))

        let text = "Apple Foundation Models provide powerful on-device AI capabilities. This application leverages them for productivity."
        // We can't actually call the API in tests without mocking URLSession, but we can verify the prompt generation logic if it were exposed.
        // For now, we test the NaturalLanguage parts that are local.

        let summary = try await service.summarize(text, config: config)
        XCTAssertFalse(summary.isEmpty)
    }

    func testUnifiedContentConversion() {
        let note = Note(title: "Test Note", blocks: [NoteBlock(type: .text, content: "Hello World")])
        let doc = UnifiedContentConverter.convertToDocument(from: note)
        XCTAssertTrue(doc.contains("# Test Note"))
        XCTAssertTrue(doc.contains("Hello World"))
    }
}
