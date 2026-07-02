import Foundation

public final class SharingProbe: Probe {
    public let type: ProbeType = .sharing
    private let runner: ProcessRunner

    public init(runner: ProcessRunner = ProcessRunner()) {
        self.runner = runner
    }

    public func run() async throws -> ProbeResult {
        do {
            var lines: [String] = []

            let remoteLogin = try await runner.run(executable: "/usr/sbin/systemsetup", args: ["-getremotelogin"])
            lines.append("Remote Login: \(remoteLogin.stdout.trimmingCharacters(in: .whitespacesAndNewlines))")

            let ard = try await runner.runBash("/usr/sbin/AppleRemoteDesktop 2>/dev/null; /bin/launchctl list | grep -i screensharing 2>/dev/null || true")
            if ard.succeeded {
                let val = ard.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
                if !val.isEmpty { lines.append("Remote Management/Screen Sharing: \(val)") }
            }

            let launchDaemons = try await runner.runBash("/bin/launchctl list 2>/dev/null | grep -iE '(ssh|screensharing|ard|vnc|smb|afp)' || true")
            if launchDaemons.succeeded {
                let val = launchDaemons.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
                if !val.isEmpty {
                    lines.append("Sharing launch services:")
                    for entry in val.split(separator: "\n") {
                        lines.append("  \(entry)")
                    }
                }
            }

            return ProbeResult(probe: type, success: true, value: lines.joined(separator: "\n"))
        } catch {
            return ProbeResult(probe: type, success: false, error: error.localizedDescription)
        }
    }
}
