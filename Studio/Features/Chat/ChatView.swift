import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @EnvironmentObject var aiContext: AIContext

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastId = viewModel.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            HStack {
                TextField(aiContext.config.selectedModel == nil ? "Please configure AI in Settings..." : "Message AI...", text: $viewModel.inputText)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    .onSubmit {
                        viewModel.sendMessage(with: aiContext.config)
                    }
                    .disabled(aiContext.config.selectedModel == nil)

                Button(action: { viewModel.sendMessage(with: aiContext.config) }) {
                    Image(systemName: "paperplane.fill")
                        .padding(8)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.inputText.isEmpty || viewModel.isSending || aiContext.config.selectedModel == nil)
            }
            .padding()
        }
        .navigationTitle("AI Chat (\(aiContext.config.selectedModel?.name ?? "No Model"))")
    }
}
