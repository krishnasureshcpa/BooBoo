import SwiftUI

@main
struct BooBooApp: App {
    @State private var state = AppState()
    @State private var showWelcome = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(state)
                .preferredColorScheme(.dark)
                .sheet(isPresented: $showWelcome) {
                    WelcomeView()
                        .environment(state)
                }
                .task {
                    let defaultPath = Bundle.main.resourcePath.map { "\($0)/rules/cis-l1" }
                        ?? FileManager.default.currentDirectoryPath + "/rules/cis-l1"
                    state.loadRules(from: defaultPath)
                    showWelcome = !state.hasCompletedOnboarding
                }
                .onChange(of: state.hasCompletedOnboarding) { _, done in
                    if done { showWelcome = false }
                }
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About BooBoo") {
                    NSApplication.shared.orderFrontStandardAboutPanel(nil)
                }
            }
            CommandGroup(after: .windowList) {
                Button("BooBoo Assistant") {
                    state.showAssistant.toggle()
                }
                .keyboardShortcut("b", modifiers: [.command, .shift])
            }
        }
    }
}
