import Foundation

public final class FileSystemProbe: Probe {
    public let type: ProbeType = .fileSystem
    private let runner: ProcessRunner
    private let fm: FileManager

    public init(runner: ProcessRunner = ProcessRunner()) {
        self.runner = runner
        self.fm = FileManager.default
    }

    public func run() async throws -> ProbeResult {
        do {
            let criticalPaths = [
                "/etc/pam.d",
                "/var/log",
                "/etc/ssh",
                "/etc/security",
                "/Library/Preferences",
                "/System/Library/CoreServices",
            ]

            var lines: [String] = []

            for path in criticalPaths {
                var isDir: ObjCBool = false
                if fm.fileExists(atPath: path, isDirectory: &isDir) {
                    let attrs = try fm.attributesOfItem(atPath: path)
                    let perms = attrs[.posixPermissions] as? Int ?? 0
                    let owner = attrs[.ownerAccountName] as? String ?? "?"
                    lines.append("\(path): exists, owner=\(owner), perms=\(String(format: "%04o", perms))")
                } else {
                    lines.append("\(path): not found")
                }
            }

            let sip = try await runner.run(executable: "/usr/bin/csrutil", args: ["status"])
            lines.append("SIP: \(sip.stdout.trimmingCharacters(in: .whitespacesAndNewlines))")

            let gatekeeper = try await runner.run(executable: "/usr/sbin/spctl", args: ["--status"])
            lines.append("Gatekeeper: \(gatekeeper.stdout.trimmingCharacters(in: .whitespacesAndNewlines))")

            return ProbeResult(probe: type, success: true, value: lines.joined(separator: "\n"))
        } catch {
            return ProbeResult(probe: type, success: false, error: error.localizedDescription)
        }
    }
}
