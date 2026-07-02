import SwiftUI
import BooBooCore

private let sampleRules: [Rule] = [
    Rule(id: "AUTH-001", title: "Require FileVault Encryption", category: .authentication,
         severity: .critical, description: "FileVault full-disk encryption must be enabled on all Mac startup volumes.",
         rationale: "FileVault protects data at rest. Without it, anyone with physical access can read all files.",
         frameworks: ["FileVault"], platforms: ["macOS"], probe: .system,
         check: CheckDefinition(op: .isEnabled, path: "/dev/disk1"),
         remediation: Remediation(action: .runCommand, command: "fdesetup enable", sudo: true,
                                  description: "Enable FileVault")),

    Rule(id: "AUTH-002", title: "Require Login Password", category: .authentication,
         severity: .high, description: "A password must be required to wake the computer from sleep or screen saver.",
         rationale: "Prevents unauthorized access when the user steps away from an unlocked session.",
         frameworks: ["Security"], platforms: ["macOS"], probe: .system,
         check: CheckDefinition(op: .isEnabled, path: "/Library/Preferences/com.apple.screensaver"),
         remediation: Remediation(action: .setPreference, command: "defaults -currentHost write com.apple.screensaver askForPassword -int 1",
                                  description: "Enable password on wake")),

    Rule(id: "AUTH-003", title: "Disable Automatic Login", category: .authentication,
         severity: .high, description: "Automatic login must be disabled to prevent unauthenticated system access.",
         rationale: "Automatic login bypasses authentication entirely, allowing anyone to access the system on reboot.",
         frameworks: ["Security"], platforms: ["macOS"], probe: .system,
         check: CheckDefinition(op: .notEquals, path: "/etc/kcpassword", args: ["exists"]),
         remediation: Remediation(action: .runCommand, command: "defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null",
                                  sudo: true, description: "Disable automatic login")),

    Rule(id: "FIREWALL-001", title: "Enable Application Firewall", category: .firewall,
         severity: .critical, description: "The built-in macOS application firewall must be enabled.",
         rationale: "The firewall blocks incoming network connections to unauthorized services.",
         frameworks: ["Security"], platforms: ["macOS"], probe: .firewall,
         check: CheckDefinition(op: .isEnabled, path: "/usr/libexec/ApplicationFirewall/socketfilterfw"),
         remediation: Remediation(action: .runCommand, command: "/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on",
                                  sudo: true, description: "Enable application firewall")),

    Rule(id: "FIREWALL-002", title: "Enable Stealth Mode", category: .firewall,
         severity: .medium, description: "Firewall stealth mode drops unsolicited packets without responding.",
         rationale: "Stealth mode prevents attackers from discovering the system through port scans.",
         frameworks: ["Security"], platforms: ["macOS"], probe: .firewall,
         check: CheckDefinition(op: .isEnabled, path: "/usr/libexec/ApplicationFirewall/socketfilterfw", args: ["--getstealthmode"]),
         remediation: Remediation(action: .runCommand, command: "/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on",
                                  sudo: true, description: "Enable stealth mode")),

    Rule(id: "ENCRYPT-001", title: "Check FileVault Encryption Status", category: .encryption,
         severity: .critical, description: "Verify that all startup volumes are encrypted with FileVault.",
         rationale: "Full-disk encryption ensures data confidentiality if the device is lost or stolen.",
         frameworks: ["FileVault"], platforms: ["macOS"], probe: .system,
         check: CheckDefinition(op: .equals, path: "/usr/bin/fdesetup", args: ["status"]),
         remediation: nil),

    Rule(id: "ENCRYPT-002", title: "Enable SSH Encryption Only", category: .encryption,
         severity: .medium, description: "SSH must be configured to use strong encryption ciphers only.",
         rationale: "Weak ciphers allow attackers to decrypt SSH traffic.",
         frameworks: ["SSH"], platforms: ["macOS"], probe: .network,
         check: CheckDefinition(op: .matches, path: "/etc/ssh/sshd_config", args: ["Ciphers"]),
         remediation: Remediation(action: .writeFile, command: "echo 'Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com' >> /etc/ssh/sshd_config",
                                  sudo: true, description: "Configure strong SSH ciphers")),

    Rule(id: "LOGGING-001", title: "Enable Security Auditing", category: .logging,
         severity: .high, description: "Security auditing via the auditd service must be enabled.",
         rationale: "Audit logs provide a record of security-relevant events for forensic analysis.",
         frameworks: ["Audit"], platforms: ["macOS"], probe: .system,
         check: CheckDefinition(op: .isEnabled, path: "/etc/security/audit_control"),
         remediation: Remediation(action: .enableService, command: "launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist",
                                  sudo: true, description: "Enable audit daemon")),

    Rule(id: "LOGGING-002", title: "Enable App Sandbox", category: .logging,
         severity: .medium, description: "Applications downloaded from outside the App Store should run in a sandbox.",
         rationale: "Sandboxing restricts application access to system resources, reducing blast radius.",
         frameworks: ["Sandbox"], platforms: ["macOS"], probe: .application,
         check: CheckDefinition(op: .isEnabled, path: "/Library/Preferences/com.apple.security"),
         remediation: nil),

    Rule(id: "UPDATES-001", title: "Enable Automatic Updates", category: .updates,
         severity: .high, description: "macOS automatic software updates must be enabled.",
         rationale: "Timely security patches fix known vulnerabilities before they can be exploited.",
         frameworks: ["Software Update"], platforms: ["macOS"], probe: .softwareUpdate,
         check: CheckDefinition(op: .isEnabled, path: "/Library/Preferences/com.apple.SoftwareUpdate"),
         remediation: Remediation(action: .runCommand, command: "softwareupdate --schedule on",
                                  sudo: true, description: "Enable automatic software updates")),

    Rule(id: "UPDATES-002", title: "Enable System Data Files Updates", category: .updates,
         severity: .medium, description: "Automatic updates for system data files and security definitions must be enabled.",
         rationale: "System data files include XProtect, MRT, and other built-in malware definitions.",
         frameworks: ["Software Update"], platforms: ["macOS"], probe: .softwareUpdate,
         check: CheckDefinition(op: .isEnabled, path: "/Library/Preferences/com.apple.SoftwareUpdate.plist", args: ["ConfigDataInstall"]),
         remediation: nil),

    Rule(id: "SHARING-001", title: "Disable Remote Login", category: .sharing,
         severity: .high, description: "SSH remote login should be disabled when not in active use.",
         rationale: "Remote login services increase the attack surface by exposing network-accessible authentication.",
         frameworks: ["SSH"], platforms: ["macOS"], probe: .sharing,
         check: CheckDefinition(op: .isDisabled, path: "/System/Library/LaunchDaemons/ssh.plist"),
         remediation: Remediation(action: .disableService, command: "launchctl unload -w /System/Library/LaunchDaemons/ssh.plist",
                                  sudo: true, description: "Disable remote login")),

    Rule(id: "HARDN-001", title: "Disable Guest Account", category: .systemHardening,
         severity: .high, description: "The guest account must be disabled to prevent anonymous system access.",
         rationale: "Guest accounts bypass authentication and leave no audit trail.",
         frameworks: ["Security"], platforms: ["macOS"], probe: .system,
         check: CheckDefinition(op: .isDisabled, path: "/var/db/dslocal/nodes/Default/users/Guest.plist"),
         remediation: Remediation(action: .runCommand, command: "defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool NO",
                                  sudo: true, description: "Disable guest account")),

    Rule(id: "HARDN-002", title: "Disable Root Login", category: .systemHardening,
         severity: .critical, description: "Direct root login via SSH must be disabled.",
         rationale: "Root login bypasses accountability. Administrators should use sudo instead.",
         frameworks: ["Security"], platforms: ["macOS"], probe: .system,
         check: CheckDefinition(op: .matches, path: "/etc/ssh/sshd_config", args: ["PermitRootLogin"]),
         remediation: Remediation(action: .writeFile, command: "echo 'PermitRootLogin no' >> /etc/ssh/sshd_config",
                                  sudo: true, description: "Disable root SSH login")),
]

struct RuleListView: View {
    @State private var searchText = ""

    private var filteredRules: [Rule] {
        if searchText.isEmpty { return sampleRules }
        return sampleRules.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.id.localizedCaseInsensitiveContains(searchText) }
    }

    private var groupedRules: [(RuleCategory, [Rule])] {
        Dictionary(grouping: filteredRules, by: { $0.category })
            .sorted { $0.key.rawValue < $1.key.rawValue }
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            ruleList
        }
        .background(Color.booBackground)
    }

    private var searchBar: some View {
        HStack(spacing: BooSpacing.small) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.booTextTertiary)
            TextField("Search rules...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.booBody)
                .foregroundColor(.booTextPrimary)
        }
        .padding(BooSpacing.medium)
        .background(Color.booBackgroundElevated)
    }

    private var ruleList: some View {
        List {
            ForEach(groupedRules, id: \.0) { category, rules in
                Section {
                    ForEach(rules) { rule in
                        NavigationLink {
                            RuleDetailView(rule: rule)
                        } label: {
                            RuleRow(rule: rule)
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

private struct RuleRow: View {
    let rule: Rule

    var body: some View {
        HStack(spacing: BooSpacing.small) {
            StatusBadge(status: .unknown)
                .frame(width: 10, height: 10)

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
