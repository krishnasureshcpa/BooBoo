import SwiftUI
import BooBooCore

enum SidebarTab: String, CaseIterable {
    case dashboard
    case compliance
    case about
    case settings
}

struct ContentView: View {
    @Environment(AppState.self) private var state
    @State private var selectedTab: SidebarTab? = .dashboard

    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 240, ideal: 240)
        } detail: {
            NavigationStack {
                detailContent
            }
        }
        .background(Color.booBackground)
    }

    @ViewBuilder
    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: BooSpacing.small) {
                Image(systemName: "ghost.fill")
                    .font(.title3)
                    .foregroundColor(.booAccent)
                Text("BooBoo")
                    .font(.booHeadline)
                    .foregroundColor(.booTextPrimary)
            }
            .padding(.horizontal, BooSpacing.medium)
            .padding(.top, BooSpacing.large)
            .padding(.bottom, BooSpacing.medium)

            Divider()
                .background(Color.booBorder)
                .padding(.bottom, BooSpacing.small)

            List(selection: $selectedTab) {
                NavigationLink(value: SidebarTab.dashboard) {
                    Label("Dashboard", systemImage: "square.grid.2x2")
                        .font(.booBody)
                        .foregroundColor(.booTextSecondary)
                }
                .keyboardShortcut("1", modifiers: .command)

                NavigationLink(value: SidebarTab.compliance) {
                    Label("Compliance", systemImage: "checkmark.shield")
                        .font(.booBody)
                        .foregroundColor(.booTextSecondary)
                }
                .keyboardShortcut("2", modifiers: .command)

                NavigationLink(value: SidebarTab.about) {
                    Label("About", systemImage: "info.circle")
                        .font(.booBody)
                        .foregroundColor(.booTextSecondary)
                }
                .keyboardShortcut("3", modifiers: .command)

                NavigationLink(value: SidebarTab.settings) {
                    Label("Settings", systemImage: "gearshape")
                        .font(.booBody)
                        .foregroundColor(.booTextSecondary)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
            .listStyle(.sidebar)
            .scrollDisabled(true)

            Spacer()

            Divider()
                .background(Color.booBorder)

            Button(action: { state.showAssistant.toggle() }) {
                Label("Assistant", systemImage: "questionmark.bubble")
                    .font(.booBody)
                    .foregroundColor(.booTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .keyboardShortcut("b", modifiers: [.command, .shift])
            .padding(.horizontal, BooSpacing.medium)
            .padding(.vertical, BooSpacing.small)
        }
        .background(Color.booBackgroundElevated)
        .sheet(isPresented: .init(
            get: { state.showAssistant },
            set: { state.showAssistant = $0 }
        )) {
            BooBooAssistantView()
                .environment(state)
                .frame(minWidth: 420, minHeight: 520)
        }
    }

    @ViewBuilder
    private var detailContent: some View {
        switch selectedTab {
        case .dashboard: DashboardView()
        case .compliance: RuleListView()
        case .about: AboutView()
        case .settings: SettingsView()
        case nil: DashboardView()
        }
    }
}
