import Foundation

public final class TCCProbe: Probe {
    public let type: ProbeType = .tcc
    private let runner: ProcessRunner

    public init(runner: ProcessRunner = ProcessRunner()) {
        self.runner = runner
    }

    public func run() async throws -> ProbeResult {
        do {
            let dbPath = "/Library/Application Support/com.apple.TCC/TCC.db"
            var lines: [String] = []
            lines.append("TCC database at: \(dbPath)")

            if runner.fileExists(dbPath) {
                let output = try await runner.runBash("sqlite3 \"\(dbPath)\" \"SELECT service, client, auth_value FROM access WHERE auth_value != 0 LIMIT 20\" 2>/dev/null || true")
                let entries = output.stdout.split(separator: "\n").filter { !$0.isEmpty }
                lines.append("Service entries: \(entries.count)")
                for entry in entries.prefix(10) {
                    lines.append("  \(entry)")
                }
            } else {
                lines.append("TCC database not accessible — expected on macOS 15+")
            }

            let tccutilOutput = try await runner.runBash("tccutil --list 2>&1 || true")
            if !tccutilOutput.stdout.isEmpty {
                lines.append("tccutil entries: \(tccutilOutput.stdout.trimmingCharacters(in: .whitespacesAndNewlines))")
            }

            return ProbeResult(probe: type, success: true, value: lines.joined(separator: "\n"))
        } catch {
            return ProbeResult(probe: type, success: false, error: error.localizedDescription)
        }
    }
}
