import SwiftUI

struct TranslateView: View {
    @StateObject private var viewModel = TranslateViewModel()
    @EnvironmentObject var aiContext: AIContext

    var body: some View {
        HSplitView {
            VStack(alignment: .leading) {
                Text("Source Text")
                    .font(.headline)
                TextEditor(text: $viewModel.sourceText)
                    .frame(minHeight: 200)
                    .border(Color.gray.opacity(0.2))
                    .onChange(of: viewModel.sourceText) { newValue in
                        aiContext.updateContext(newValue)
                    }

                HStack {
                    Picker("To:", selection: $viewModel.targetLanguage) {
                        Text("Spanish").tag("es")
                        Text("French").tag("fr")
                        Text("German").tag("de")
                        Text("Japanese").tag("ja")
                        Text("Chinese").tag("zh")
                    }
                    .frame(width: 150)

                    Button(action: { viewModel.translate(with: aiContext.config) }) {
                        if viewModel.isTranslating {
                            ProgressView().controlSize(.small)
                        } else {
                            Text("Translate")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.sourceText.isEmpty || viewModel.isTranslating || aiContext.config.selectedModel == nil)
                }
                .padding(.top)

                if aiContext.config.selectedModel == nil {
                    Text("Please configure AI in Settings to use translation.")
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Spacer()
            }
            .padding()
            .frame(minWidth: 300)

            VStack(alignment: .leading) {
                Text("History")
                    .font(.headline)
                    .padding([.top, .leading])

                List(viewModel.translationHistory) { item in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.sourceText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(item.translatedText ?? "")
                            .font(.body)
                            .textSelection(.enabled)
                    }
                    .padding(.vertical, 4)
                }
            }
            .frame(minWidth: 300)
        }
        .navigationTitle("Translate")
    }
}
