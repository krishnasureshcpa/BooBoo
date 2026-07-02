import Foundation

public final class ApplicationProbe: Probe {
    public let type: ProbeType = .application
    private let runner: ProcessRunner

    public init(runner: ProcessRunner = ProcessRunner()) {
        self.runner = runner
    }

    public func run() async throws -> ProbeResult {
        do {
            var lines: [String] = []

            let gatekeeper = try await runner.run(executable: "/usr/sbin/spctl", args: ["--status"])
            let gk = gatekeeper.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            lines.append("Gatekeeper: \(gk)")

            let quarantine = try await runner.runBash("defaults read /Library/Preferences/com.apple.LaunchServices 2>/dev/null | grep -i quarantine || echo 'default'")
            lines.append("Quarantine: \(quarantine.stdout.trimmingCharacters(in: .whitespacesAndNewlines))")

            let xprotect = try await runner.runBash("ls /System/Library/CoreServices/XProtect.bundle/Contents/Resources/ 2>/dev/null | head -5 || echo 'not found'")
            let xp = xprotect.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            lines.append("XProtect: \(xp)")

            let xprotectVersion = try await runner.runBash("/usr/bin/defaults read /System/Library/CoreServices/XProtect.bundle/Contents/Info.plist CFBundleVersion 2>/dev/null || true")
            if xprotectVersion.succeeded {
                let ver = xprotectVersion.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
                lines.append("XProtect version: \(ver)")
            }

            let mrt = try await runner.runBash("/usr/bin/defaults read /Library/Preferences/com.apple.mrt.plist LastUpdated 2>/dev/null || true")
            if mrt.succeeded {
                let val = mrt.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
                lines.append("MRT last updated: \(val)")
            }

            return ProbeResult(probe: type, success: true, value: lines.joined(separator: "\n"))
        } catch {
            return ProbeResult(probe: type, success: false, error: error.localizedDescription)
        }
    }
}
