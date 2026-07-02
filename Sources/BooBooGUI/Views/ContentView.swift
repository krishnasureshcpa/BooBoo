import SwiftUI
import BooBooCore

enum SidebarTab: String, CaseIterable {
    case dashboard
    case compliance
    case settings
}

struct ContentView: View {
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
                NavigationLink(value: SidebarTab.compliance) {
                    Label("Compliance", systemImage: "checkmark.shield")
                        .font(.booBody)
                        .foregroundColor(.booTextSecondary)
                }
                NavigationLink(value: SidebarTab.settings) {
                    Label("Settings", systemImage: "gearshape")
                        .font(.booBody)
                        .foregroundColor(.booTextSecondary)
                }
            }
            .listStyle(.sidebar)
            .scrollDisabled(true)

            Spacer()
        }
        .background(Color.booBackgroundElevated)
    }

    @ViewBuilder
    private var detailContent: some View {
        switch selectedTab {
        case .dashboard: DashboardView()
        case .compliance: RuleListView()
        case .settings: SettingsView()
        case nil: DashboardView()
        }
    }
}
