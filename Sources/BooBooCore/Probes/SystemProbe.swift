import Foundation

public final class SystemProbe: Probe {
    public let type: ProbeType = .system
    private let runner: ProcessRunner

    public init(runner: ProcessRunner = ProcessRunner()) {
        self.runner = runner
    }

    public func run() async throws -> ProbeResult {
        do {
            let versionOutput = try await runner.run(executable: "/usr/bin/sw_vers", args: ["-productVersion"])
            let sipOutput = try await runner.run(executable: "/usr/bin/csrutil", args: ["status"])
            let fvOutput = try await runner.run(executable: "/usr/bin/fdesetup", args: ["status"])

            let macOSVersion = versionOutput.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            let sipStatus = sipOutput.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            let fileVault = fvOutput.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

            let value = """
macOS: \(macOSVersion)
SIP: \(sipStatus)
FileVault: \(fileVault)
"""
            return ProbeResult(probe: type, success: true, value: value)
        } catch {
            return ProbeResult(probe: type, success: false, error: error.localizedDescription)
        }
    }
}
