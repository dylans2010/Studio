import SwiftUI

struct CommandBar: View {
    @State private var query: String = ""
    @EnvironmentObject var aiContext: AIContext
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Ask AI anything...", text: $query)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        Task {
                            _ = await aiContext.performAction(query, on: aiContext.activeContext)
                            isPresented = false
                            query = ""
                        }
                    }
            }
            .padding()

            if !query.isEmpty {
                Divider()
                List {
                    Text("Ask AI: \(query)")
                    Text("Search in Documents")
                    Text("Create a new meeting about \(query)")
                }
                .listStyle(.plain)
                .frame(height: 150)
            }
        }
        .frame(width: 500)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 20)
    }
}
