import SwiftUI

struct MainView: View {
    @State private var selectedTab: Tab? = .notebook
    @State private var showCommandBar = false
    @EnvironmentObject var aiContext: AIContext

    enum Tab: String, CaseIterable {
        case chat = "Chat"
        case notebook = "Notebook"
        case document = "Document"
        case presentation = "Slides"
        case translate = "Translate"
        case meetings = "Meetings"

        var icon: String {
            switch self {
            case .chat: return "message"
            case .notebook: return "note.text"
            case .document: return "doc.text"
            case .presentation: return "rectangle.on.rectangle.angled"
            case .translate: return "character.book.closed"
            case .meetings: return "video"
            }
        }
    }

    var body: some View {
        ZStack {
            NavigationSplitView {
                List(Tab.allCases, id: \.self, selection: $selectedTab) { tab in
                    NavigationLink(value: tab) {
                        Label(tab.rawValue, systemImage: tab.icon)
                    }
                }
                .navigationTitle("Studio")
            } detail: {
                if let tab = selectedTab {
                    destinationView(for: tab)
                } else {
                    Text("Select a feature from the sidebar")
                }
            }

            HStack {
                Spacer()
                AISidePanel()
            }

            if showCommandBar {
                Color.black.opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { showCommandBar = false }

                CommandBar(isPresented: $showCommandBar)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: { showCommandBar.toggle() }) {
                    Label("Command Bar", systemImage: "command")
                }
                .keyboardShortcut("k", modifiers: .command)
            }

            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gear")
                }
            }
        }
    }

    @ViewBuilder
    func destinationView(for tab: Tab) -> some View {
        switch tab {
        case .chat: ChatView()
        case .notebook: NotebookView()
        case .document: DocumentView()
        case .presentation: PresentationView()
        case .translate: TranslateView()
        case .meetings: MeetingsView()
        }
    }
}
