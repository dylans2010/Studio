import SwiftUI

@main
struct StudioApp: App {
    @StateObject private var aiContext = AIContext()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(aiContext)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            SidebarCommands()
        }
    }
}
