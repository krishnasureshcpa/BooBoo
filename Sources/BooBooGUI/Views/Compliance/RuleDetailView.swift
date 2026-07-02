import SwiftUI
import BooBooCore

struct RuleDetailView: View {
    @Environment(AppState.self) private var state
    let rule: Rule

    @State private var showConfirm = false
    @State private var showResult = false
    @State private var fixSucceeded = false
    @State private var fixMessage = ""

    private var result: CheckResult? { state.result(for: rule.id) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BooSpacing.large) {
                headerSection
                infoSection
                statusSection
                descriptionSection
                if rule.remediation != nil {
                    fixButton
                }
                if !fixMessage.isEmpty {
                    fixResultBanner
                }
            }
            .padding(BooSpacing.xlarge)
        }
        .background(Color.booBackground)
        .alert("Apply Fix", isPresented: $showConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Apply") {
                Task { await performFix() }
            }
        } message: {
            Text(rule.remediation?.description ?? "Apply the recommended fix?")
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: BooSpacing.xsmall) {
            Text(rule.id)
                .font(.booCaption)
                .foregroundColor(.booTextTertiary)
                .monospaced()

            Text(rule.title)
                .font(.booLargeTitle)
                .foregroundColor(.booTextPrimary)

            HStack(spacing: BooSpacing.small) {
                SeverityLabel(severity: rule.severity)
                Text(categoryLabel(for: rule.category))
                    .font(.booCaption)
                    .foregroundColor(.booTextSecondary)
            }
        }
    }

    private var infoSection: some View {
        HStack(spacing: BooSpacing.medium) {
            VStack(alignment: .leading, spacing: BooSpacing.xsmall) {
                Text("Probe")
                    .font(.booCaption)
                    .foregroundColor(.booTextTertiary)
                Text(rule.probe.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.booCallout)
                    .foregroundColor(.booTextPrimary)
            }

            VStack(alignment: .leading, spacing: BooSpacing.xsmall) {
                Text("Framework")
                    .font(.booCaption)
                    .foregroundColor(.booTextTertiary)
                Text(rule.frameworks.first ?? "None")
                    .font(.booCallout)
                    .foregroundColor(.booTextPrimary)
            }

            VStack(alignment: .leading, spacing: BooSpacing.xsmall) {
                Text("Platform")
                    .font(.booCaption)
                    .foregroundColor(.booTextTertiary)
                Text(rule.platforms.first ?? "None")
                    .font(.booCallout)
                    .foregroundColor(.booTextPrimary)
            }
        }
        .padding(BooSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: BooRadius.card)
                .fill(Color.booBackgroundElevated)
        )
    }

    private var statusSection: some View {
        HStack(spacing: BooSpacing.small) {
            Circle()
                .fill(result.map { statusColor($0.status) } ?? Color.booTextTertiary)
                .frame(width: 12, height: 12)

            Text(result.map { statusLabel($0.status) } ?? "Not checked")
                .font(.booHeadline)
                .foregroundColor(.booTextPrimary)

            Spacer()

            if let r = result, r.status == .failed {
                Text(r.message)
                    .font(.booCaption)
                    .foregroundColor(.booTextTertiary)
                    .lineLimit(1)
            }
        }
        .padding(BooSpacing.medium)
        .background(RoundedRectangle(cornerRadius: BooRadius.card).fill(Color.booBackgroundElevated))
        .overlay(
            RoundedRectangle(cornerRadius: BooRadius.card)
                .stroke((result.map { statusColor($0.status) } ?? Color.booTextTertiary).opacity(0.3), lineWidth: 1)
        )
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: BooSpacing.medium) {
            VStack(alignment: .leading, spacing: BooSpacing.small) {
                Text("Description")
                    .font(.booHeadline)
                    .foregroundColor(.booTextPrimary)
                Text(rule.description)
                    .font(.booBody)
                    .foregroundColor(.booTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: BooSpacing.small) {
                Text("Rationale")
                    .font(.booHeadline)
                    .foregroundColor(.booTextPrimary)
                Text(rule.rationale)
                    .font(.booBody)
                    .foregroundColor(.booTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var fixButton: some View {
        Button(action: { showConfirm = true }) {
            Label("Fix", systemImage: "wrench.and.screwdriver")
                .font(.booHeadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BooSpacing.small)
        }
        .buttonStyle(.borderedProminent)
        .tint(.booAccent)
        .disabled(state.isFixing)
        .keyboardShortcut("f", modifiers: .command)
    }

    private var fixResultBanner: some View {
        HStack(spacing: BooSpacing.small) {
            Image(systemName: fixSucceeded ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(fixSucceeded ? .booSuccess : .booDanger)
            Text(fixMessage.isEmpty ? "Unknown result" : fixMessage)
                .font(.booCallout)
                .foregroundColor(.booTextSecondary)
        }
        .padding(BooSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BooRadius.card)
                .fill((fixSucceeded ? Color.booSuccess : Color.booDanger).opacity(0.1))
        )
    }

    @MainActor
    private func performFix() async {
        fixSucceeded = await state.fixRule(rule)
        fixMessage = fixSucceeded
            ? "Fix applied successfully."
            : (state.fixResults[rule.id]?.message ?? "Fix could not be completed.")
    }

    private func statusColor(_ status: CheckStatus) -> Color {
        switch status {
        case .passed, .remediated: return .booSuccess
        case .failed: return .booDanger
        case .error: return .booWarning
        case .skipped: return .booTextTertiary
        }
    }

    private func statusLabel(_ status: CheckStatus) -> String {
        switch status {
        case .passed: return "Passed"
        case .failed: return "Failed"
        case .error: return "Error"
        case .skipped: return "Skipped"
        case .remediated: return "Remediated"
        }
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
        case .systemHardening: return "System Hardening"
        case .applicationSecurity: return "Application Security"
        case .fileIntegrity: return "File Integrity"
        }
    }
}
