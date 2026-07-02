import Foundation

public final class FirewallProbe: Probe {
    public let type: ProbeType = .firewall
    private let runner: ProcessRunner

    public init(runner: ProcessRunner = ProcessRunner()) {
        self.runner = runner
    }

    public func run() async throws -> ProbeResult {
        do {
            let fwPath = "/usr/libexec/ApplicationFirewall/socketfilterfw"

            let global = try await runner.run(executable: fwPath, args: ["--getglobalstate"])
            let globalState = global.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

            let stealth = try await runner.run(executable: fwPath, args: ["--getstealthmode"])
            let stealthState = stealth.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

            let signed = try await runner.run(executable: fwPath, args: ["--getallowsigned"])
            let signedState = signed.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

            let value = """
Global: \(globalState)
Stealth: \(stealthState)
Signed: \(signedState)
"""
            return ProbeResult(probe: type, success: true, value: value)
        } catch {
            return ProbeResult(probe: type, success: false, error: error.localizedDescription)
        }
    }
}
