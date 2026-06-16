import SwiftUI

struct AISidePanel: View {
    @EnvironmentObject var aiContext: AIContext

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("AI Assistant")
                .font(.headline)
                .padding(.bottom, 5)

            if aiContext.isProcessing {
                HStack {
                    ProgressView().controlSize(.small)
                    Text("AI is thinking...")
                        .font(.caption)
                }
            }

            if !aiContext.suggestions.isEmpty {
                Text("Suggestions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                ForEach(aiContext.suggestions, id: \.self) { suggestion in
                    Button(action: {
                        Task {
                            _ = await aiContext.performAction(suggestion, on: aiContext.activeContext)
                        }
                    }) {
                        Text(suggestion)
                            .font(.caption)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()

            Text("Recent Actions")
                .font(.subheadline)
                .foregroundColor(.secondary)

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(aiContext.history.reversed(), id: \.self) { item in
                        Text(item)
                            .font(.caption2)
                            .padding(6)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .frame(width: 250)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
