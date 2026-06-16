import SwiftUI

struct PresentationView: View {
    @StateObject private var viewModel = PresentationViewModel()
    @EnvironmentObject var aiContext: AIContext
    @State private var topic: String = ""

    var body: some View {
        HSplitView {
            VStack {
                List(viewModel.presentation.slides, selection: $viewModel.selectedSlideId) { slide in
                    Text(slide.title)
                        .tag(slide.id)
                }
                .listStyle(.sidebar)

                Spacer()

                VStack(spacing: 8) {
                    TextField("Topic for AI...", text: $topic)
                        .textFieldStyle(.roundedBorder)
                    Button(action: { viewModel.generateDeck(from: topic, config: aiContext.config) }) {
                        if viewModel.isGenerating {
                            ProgressView().controlSize(.small)
                        } else {
                            Text("Generate Deck")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(topic.isEmpty || aiContext.config.selectedModel == nil)
                }
                .padding()
            }
            .frame(minWidth: 200, maxWidth: 300)

            if let slide = viewModel.presentation.slides.first(where: { $0.id == viewModel.selectedSlideId }) {
                SlideDetailView(slide: slide)
            } else {
                Text("Select a slide")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(viewModel.presentation.title)
    }
}
