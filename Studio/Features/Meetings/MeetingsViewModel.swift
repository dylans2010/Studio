import SwiftUI
import Combine

class MeetingsViewModel: ObservableObject {
    @Published var meetings: [Meeting] = []
    @Published var selectedMeetingId: UUID?
    @Published var isSummarizing: Bool = false

    func scheduleMeeting() {
        let newMeeting = Meeting(title: "New Strategy Sync", date: Date(), transcript: "Participant 1: We need to scale the AI layer.\nParticipant 2: Agreed, but let's ensure privacy first.", participants: ["Alice", "Bob", "Me"])
        meetings.append(newMeeting)
        selectedMeetingId = newMeeting.id
    }

    func generateSummary(for meetingId: UUID, config: AIConfiguration) {
        guard let index = meetings.firstIndex(where: { $0.id == meetingId }) else { return }
        guard config.selectedModel != nil else { return }

        let transcript = meetings[index].transcript ?? ""
        isSummarizing = true

        Task {
            do {
                let summary = try await AIService.shared.summarize(transcript, config: config)
                await MainActor.run {
                    self.meetings[index].summary = summary
                    self.isSummarizing = false
                }
            } catch {
                print("Summary error: \(error)")
                await MainActor.run { self.isSummarizing = false }
            }
        }
    }
}
