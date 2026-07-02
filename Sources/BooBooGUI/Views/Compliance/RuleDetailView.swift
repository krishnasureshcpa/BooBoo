import SwiftUI
import BooBooCore

@MainActor
class MockRemediation {
    static let shared = MockRemediation()

    func remediate(_ rule: Rule) async -> Bool {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        return true
    }
}

struct RuleDetailView: View {
    let rule: Rule
    @State private var showRemediationAlert = false
    @State private var isRemediating = false
    @State private var remediationSucceeded = false
    @State private var showResult = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BooSpacing.large) {
                headerSection
                infoSection
                descriptionSection
                statusSection
                if rule.remediation != nil {
                    fixButton
                }
            }
            .padding(BooSpacing.xlarge)
        }
        .background(Color.booBackground)
        .alert("Remediate Rule", isPresented: $showRemediationAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Apply Fix") {
                Task { await performRemediation() }
            }
        } message: {
            Text(rule.remediation?.description ?? "Apply the recommended fix for this rule?")
        }
        .alert(remediationSucceeded ? "Success" : "Failed", isPresented: $showResult) {
            Button("OK") { }
        } message: {
            Text(remediationSucceeded
                 ? "Remediation applied successfully."
                 : "Remediation could not be completed.")
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

    private var statusSection: some View {
        HStack(spacing: BooSpacing.small) {
            Circle()
                .fill(remediationSucceeded ? Color.booSuccess : Color.booWarning)
                .frame(width: 12, height: 12)

            Text(remediationSucceeded ? "Remediated" : "Needs Attention")
                .font(.booHeadline)
                .foregroundColor(.booTextPrimary)

            Spacer()
        }
        .padding(BooSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: BooRadius.card)
                .fill(Color.booBackgroundElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BooRadius.card)
                .stroke(remediationSucceeded ? Color.booSuccess.opacity(0.3) : Color.booWarning.opacity(0.3), lineWidth: 1)
        )
    }

    private var fixButton: some View {
        Button(action: { showRemediationAlert = true }) {
            Label("Fix", systemImage: "wrench.and.screwdriver")
                .font(.booHeadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BooSpacing.small)
        }
        .buttonStyle(.borderedProminent)
        .tint(.booAccent)
        .disabled(isRemediating)
    }

    private func performRemediation() async {
        isRemediating = true
        remediationSucceeded = await MockRemediation.shared.remediate(rule)
        isRemediating = false
        showResult = true
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
