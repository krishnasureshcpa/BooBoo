import SwiftUI
import BooBooCore

struct RuleListView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            filterBar
            ruleList
        }
        .background(Color.booBackground)
        .toolbar {
            ToolbarItem {
                Button("Scan") { Task { await state.runScan() } }
                    .disabled(state.isScanning)
            }
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: BooSpacing.small) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.booTextTertiary)
            TextField("Search rules...", text: Bindable(state).searchText)
                .textFieldStyle(.plain)
                .font(.booBody)
                .foregroundColor(.booTextPrimary)
            if !state.searchText.isEmpty {
                Button { state.searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.booTextTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(BooSpacing.medium)
        .background(Color.booBackgroundElevated)
    }

    // MARK: - Filters

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BooSpacing.small) {
                severityPills
                Divider().frame(height: 16).foregroundColor(.booBorder)
                categoryPills
                Divider().frame(height: 16).foregroundColor(.booBorder)
                Toggle(isOn: Bindable(state).showOnlyFailing) {
                    Text("Failing only")
                        .font(.booCaption)
                }
                .toggleStyle(.checkbox)
                .controlSize(.small)
            }
            .padding(.horizontal, BooSpacing.medium)
            .padding(.vertical, BooSpacing.xsmall)
        }
        .background(Color.booBackgroundElevated.opacity(0.6))
    }

    private var severityPills: some View {
        HStack(spacing: 4) {
            ForEach(Severity.allCases, id: \.self) { sev in
                Button {
                    if state.selectedSeverities.contains(sev) {
                        state.selectedSeverities.remove(sev)
                    } else {
                        state.selectedSeverities.insert(sev)
                    }
                } label: {
                    Text(sev.rawValue.capitalized)
                        .font(.booCaption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(state.selectedSeverities.contains(sev)
                            ? Color.booAccent.opacity(0.2)
                            : Color.booBackgroundHover)
                        .foregroundColor(state.selectedSeverities.contains(sev)
                            ? .booAccent : .booTextSecondary)
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var categoryPills: some View {
        HStack(spacing: 4) {
            ForEach(RuleCategory.allCases, id: \.self) { cat in
                Button {
                    if state.selectedCategories.contains(cat) {
                        state.selectedCategories.remove(cat)
                    } else {
                        state.selectedCategories.insert(cat)
                    }
                } label: {
                    Text(categoryLabel(for: cat))
                        .font(.booCaption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(state.selectedCategories.contains(cat)
                            ? Color.booAccent.opacity(0.2)
                            : Color.booBackgroundHover)
                        .foregroundColor(state.selectedCategories.contains(cat)
                            ? .booAccent : .booTextSecondary)
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - List

    private var ruleList: some View {
        Group {
            if state.filteredRules.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(state.groupedFilteredRules, id: \.0) { category, rules in
                        Section {
                            ForEach(rules) { rule in
                                NavigationLink {
                                    RuleDetailView(rule: rule)
                                } label: {
                                    RuleRow(rule: rule, result: state.result(for: rule.id))
                                }
                            }
                        } header: {
                            Text(categoryLabel(for: category))
                                .font(.booCaption)
                                .foregroundColor(.booTextTertiary)
                                .textCase(.uppercase)
                        }
                    }
                }
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: BooSpacing.medium) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(.booTextTertiary)
            Text("No rules match your filters")
                .font(.booHeadline)
                .foregroundColor(.booTextSecondary)
            if !state.searchText.isEmpty {
                Button("Clear search") { state.searchText = "" }
                    .buttonStyle(.plain)
                    .foregroundColor(.booAccent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func categoryLabel(for category: RuleCategory) -> String {
        switch category {
        case .authentication: return "Authentication"
        case .authorization: return "Authorization"
        case .logging: return "Logging"
        case .firewall: return "Firewall"
        case .encryption: return "Encryption"
        case .updates: return "Updates"
        case .sharing: return "Sharing"
        case .systemHardening: return "Hardening"
        case .applicationSecurity: return "App Security"
        case .fileIntegrity: return "File Integrity"
        }
    }
}

// MARK: - Row

private struct RuleRow: View {
    let rule: Rule
    let result: CheckResult?

    private var statusColor: Color {
        guard let r = result else { return .booTextTertiary }
        switch r.status {
        case .passed, .remediated: return .booSuccess
        case .failed: return .booDanger
        case .error: return .booWarning
        case .skipped: return .booTextTertiary
        }
    }

    var body: some View {
        HStack(spacing: BooSpacing.small) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(rule.title)
                    .font(.booBody)
                    .foregroundColor(.booTextPrimary)
                Text(rule.id)
                    .font(.booCaption)
                    .foregroundColor(.booTextTertiary)
            }

            Spacer()

            SeverityLabel(severity: rule.severity)
        }
        .padding(.vertical, 2)
    }
}
