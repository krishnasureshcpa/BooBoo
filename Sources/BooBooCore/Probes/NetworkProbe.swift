import Foundation

public final class NetworkProbe: Probe {
    public let type: ProbeType = .network
    private let runner: ProcessRunner

    public init(runner: ProcessRunner = ProcessRunner()) {
        self.runner = runner
    }

    public func run() async throws -> ProbeResult {
        do {
            var lines: [String] = []

            let fw = try await runner.run(executable: "/usr/libexec/ApplicationFirewall/socketfilterfw", args: ["--getglobalstate"])
            lines.append("Firewall: \(fw.stdout.trimmingCharacters(in: .whitespacesAndNewlines))")

            let stealth = try await runner.run(executable: "/usr/libexec/ApplicationFirewall/socketfilterfw", args: ["--getstealthmode"])
            lines.append("Stealth: \(stealth.stdout.trimmingCharacters(in: .whitespacesAndNewlines))")

            let lsof = try await runner.runBash("lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null | awk 'NR>1{print $1, $3, $9}' | sort -u | head -30 || true")
            if !lsof.stdout.isEmpty {
                lines.append("Listening ports:")
                for entry in lsof.stdout.split(separator: "\n") {
                    lines.append("  \(entry)")
                }
            }

            return ProbeResult(probe: type, success: true, value: lines.joined(separator: "\n"))
        } catch {
            return ProbeResult(probe: type, success: false, error: error.localizedDescription)
        }
    }
}
