import SwiftUI

struct MeetingDetailView: View {
    let meeting: Meeting
    @ObservedObject var viewModel: MeetingsViewModel
    @EnvironmentObject var aiContext: AIContext

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(meeting.title)
                    .font(.largeTitle)

                HStack {
                    Image(systemName: "person.2")
                    Text(meeting.participants.joined(separator: ", "))
                }
                .foregroundColor(.secondary)

                Divider()

                Text("AI Summary")
                    .font(.headline)

                if let summary = meeting.summary {
                    Text(summary)
                        .padding()
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(8)
                } else if viewModel.isSummarizing {
                    ProgressView("AI is analyzing transcript...")
                } else {
                    Button("Generate Summary") {
                        viewModel.generateSummary(for: meeting.id, config: aiContext.config)
                    }
                    .buttonStyle(.bordered)
                    .disabled(aiContext.config.selectedModel == nil)
                }

                Text("Transcript")
                    .font(.headline)
                Text(meeting.transcript ?? "No transcript available.")
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}
