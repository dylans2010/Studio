import SwiftUI

struct DocumentView: View {
    @StateObject private var viewModel = DocumentViewModel()
    @EnvironmentObject var aiContext: AIContext

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Document Title", text: $viewModel.title)
                    .font(.title2)
                    .textFieldStyle(.plain)

                Spacer()

                Button(action: viewModel.assistWriting) {
                    Label("AI Assist", systemImage: "wand.and.stars")
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            TextEditor(text: $viewModel.content)
                .font(.body)
                .padding()
                .onChange(of: viewModel.content) { newValue in
                    aiContext.updateContext(newValue)
                }
        }
        .navigationTitle(viewModel.title)
    }
}
