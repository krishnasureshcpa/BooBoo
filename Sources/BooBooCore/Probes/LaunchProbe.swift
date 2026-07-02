import Foundation

public final class LaunchProbe: Probe {
    public let type: ProbeType = .launch
    private let runner: ProcessRunner
    private let fm: FileManager

    public init(runner: ProcessRunner = ProcessRunner()) {
        self.runner = runner
        self.fm = FileManager.default
    }

    public func run() async throws -> ProbeResult {
        do {
            let searchPaths = [
                "/Library/LaunchDaemons",
                "/Library/LaunchAgents",
                NSHomeDirectory() + "/Library/LaunchAgents",
            ]

            var results: [String] = []

            for path in searchPaths {
                guard fm.fileExists(atPath: path) else {
                    results.append("\(path): does not exist")
                    continue
                }
                let contents = try fm.contentsOfDirectory(atPath: path)
                let plists = contents.filter { $0.hasSuffix(".plist") }
                results.append("\(path): \(plists.count) plists")

                for plist in plists.prefix(15) {
                    let fullPath = (path as NSString).appendingPathComponent(plist)
                    do {
                        let data = try Data(contentsOf: URL(fileURLWithPath: fullPath))
                        if let dict = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] {
                            let label = dict["Label"] as? String ?? "unknown"
                            let prog = dict["Program"] as? String ?? dict["ProgramArguments"].flatMap { ($0 as? [String])?.first } ?? ""
                            let huh = dict["KeepAlive"] != nil ? "keepalive" : "oneshot"
                            let signed = try await checkSignature(fullPath)
                            results.append("  \(label): \(prog) (\(huh), signed: \(signed))")
                        }
                    } catch {
                        results.append("  \(plist): unreadable (\(error.localizedDescription))")
                    }
                }
                if plists.count > 15 {
                    results.append("  ... and \(plists.count - 15) more")
                }
            }

            return ProbeResult(probe: type, success: true, value: results.joined(separator: "\n"))
        } catch {
            return ProbeResult(probe: type, success: false, error: error.localizedDescription)
        }
    }

    private func checkSignature(_ path: String) async throws -> String {
        let out = try await runner.runBash("/usr/sbin/spctl --assess --type execute \"\(path)\" 2>&1 || true")
        if out.stdout.contains("accepted") || out.stdout.contains("approved") { return "yes" }
        return "no"
    }
}
