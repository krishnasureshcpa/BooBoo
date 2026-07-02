import Foundation

public final class SoftwareUpdateProbe: Probe {
    public let type: ProbeType = .softwareUpdate
    private let runner: ProcessRunner

    public init(runner: ProcessRunner = ProcessRunner()) {
        self.runner = runner
    }

    public func run() async throws -> ProbeResult {
        do {
            let domain = "/Library/Preferences/com.apple.SoftwareUpdate"
            var lines: [String] = []

            let keys = [
                "AutomaticCheckEnabled",
                "AutomaticDownload",
                "AutomaticallyInstallMacOSUpdates",
                "ConfigDataInstall",
                "CriticalUpdateInstall",
            ]

            for key in keys {
                if let val = try await runner.readPlist(domain: domain, key: key) {
                    lines.append("\(key): \(val)")
                } else {
                    lines.append("\(key): not set")
                }
            }

            let lastCheck = try? await runner.runBash("defaults read \(domain) LastFullSuccessfulDate 2>/dev/null || true")
            if let lc = lastCheck, lc.succeeded {
                let val = lc.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
                lines.append("LastSuccessfulCheck: \(val)")
            }

            return ProbeResult(probe: type, success: true, value: lines.joined(separator: "\n"))
        } catch {
            return ProbeResult(probe: type, success: false, error: error.localizedDescription)
        }
    }
}
