import Foundation

public final class PasswordProbe: Probe {
    public let type: ProbeType = .password
    private let runner: ProcessRunner

    public init(runner: ProcessRunner = ProcessRunner()) {
        self.runner = runner
    }

    public func run() async throws -> ProbeResult {
        do {
            var lines: [String] = []

            let pwpolicy = try await runner.run(executable: "/usr/bin/pwpolicy", args: ["getaccountpolicies"])
            if pwpolicy.succeeded {
                let trimmed = pwpolicy.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    let policies = trimmed.split(separator: "\n").filter { $0.contains("policy") || $0.contains("minLength") || $0.contains("maxFailed") }
                    if policies.isEmpty {
                        lines.append("Policy data available (\(trimmed.count) chars)")
                    } else {
                        lines.append(contentsOf: policies.map { String($0) })
                    }
                } else {
                    lines.append("No explicit password policies set")
                }
            } else {
                lines.append("Password policies: not accessible (\(pwpolicy.stderr.trimmingCharacters(in: .whitespacesAndNewlines)))")
            }

            let keychainTimeout = try? await runner.runBash("security show-keychain-info ~/Library/Keychains/login.keychain-db 2>&1 | grep -i timeout || true")
            if let kc = keychainTimeout, kc.succeeded {
                let val = kc.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
                lines.append("Keychain timeout: \(val.isEmpty ? "not set" : val)")
            } else {
                lines.append("Keychain timeout: not determined")
            }

            return ProbeResult(probe: type, success: true, value: lines.joined(separator: "\n"))
        } catch {
            return ProbeResult(probe: type, success: false, error: error.localizedDescription)
        }
    }
}
