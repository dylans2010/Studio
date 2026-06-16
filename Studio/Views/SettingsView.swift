import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var aiContext: AIContext
    @State private var availableModels: [AIModel] = []
    @State private var isFetching = false

    var body: some View {
        Form {
            Section(header: Text("AI Provider")) {
                Picker("Provider", selection: $aiContext.config.provider) {
                    ForEach(AIProvider.allCases, id: \.self) { provider in
                        Text(provider.rawValue).tag(provider)
                    }
                }

                TextField("Base URL (Optional)", text: $aiContext.config.baseURL, prompt: Text(aiContext.config.provider.defaultBaseURL))

                SecureField("API Key", text: $aiContext.config.apiKey)
            }

            Section(header: Text("Model Selection")) {
                if isFetching {
                    HStack {
                        ProgressView().controlSize(.small)
                        Text("Fetching models...")
                    }
                } else {
                    Picker("Selected Model", selection: $aiContext.config.selectedModel) {
                        if aiContext.config.selectedModel == nil {
                            Text("None Selected").tag(nil as AIModel?)
                        }
                        ForEach(availableModels) { model in
                            Text(model.name).tag(model as AIModel?)
                        }
                    }

                    Button("Fetch Available Models") {
                        fetchModels()
                    }
                    .disabled(aiContext.config.apiKey.isEmpty)
                }
            }
        }
        .padding()
        .frame(width: 450, height: 400)
        .navigationTitle("Settings")
    }

    private func fetchModels() {
        isFetching = true
        Task {
            do {
                let models = try await ModelFetching.fetchModels(
                    for: aiContext.config.provider,
                    apiKey: aiContext.config.apiKey,
                    baseURL: aiContext.config.baseURL.isEmpty ? nil : aiContext.config.baseURL
                )
                await MainActor.run {
                    self.availableModels = models
                    self.isFetching = false
                }
            } catch {
                print("Failed to fetch models: \(error)")
                await MainActor.run { self.isFetching = false }
            }
        }
    }
}
