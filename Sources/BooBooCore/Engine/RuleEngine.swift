import Foundation

public final class RuleEngine: Sendable {
    private let yamlParser: YamlParser
    private let checkEvaluator: CheckEvaluator
    private let fm: FileManager

    public init(yamlParser: YamlParser = YamlParser(), checkEvaluator: CheckEvaluator = CheckEvaluator()) {
        self.yamlParser = yamlParser
        self.checkEvaluator = checkEvaluator
        self.fm = FileManager.default
    }

    public func loadRules(from directory: String) throws -> [Rule] {
        guard fm.fileExists(atPath: directory) else {
            throw EngineError.directoryNotFound(directory)
        }
        let contents = try fm.contentsOfDirectory(atPath: directory)
        let yamlFiles = contents.filter { $0.hasSuffix(".yaml") || $0.hasSuffix(".yml") }.sorted()
        var rules: [Rule] = []
        for file in yamlFiles {
            let path = (directory as NSString).appendingPathComponent(file)
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            guard let content = String(data: data, encoding: .utf8) else {
                throw EngineError.invalidYaml(file)
            }
            let parsed = try yamlParser.parse(content)
            rules.append(contentsOf: parsed)
        }
        return rules
    }

    public func runScan(rules: [Rule]) async throws -> ScanReport {
        guard !rules.isEmpty else {
            return ScanReport(totalRules: 0, passed: 0, failed: 0, errors: 0)
        }

        var results: [CheckResult] = []
        results.reserveCapacity(rules.count)

        for rule in rules {
            let result = try await evaluateRule(rule)
            results.append(result)
        }

        let passed = results.filter { $0.status == .passed }.count
        let failed = results.filter { $0.status == .failed }.count
        let errors = results.filter { $0.status == .error }.count
        let skipped = results.filter { $0.status == .skipped }.count

        return ScanReport(
            totalRules: rules.count, passed: passed,
            failed: failed, errors: errors, skipped: skipped, results: results
        )
    }

    private func evaluateRule(_ rule: Rule) async throws -> CheckResult {
        do {
            let probe = try makeProbe(for: rule.probe)
            let probeResult = try await probe.run()
            let evaluation = checkEvaluator.evaluate(probeResult: probeResult, check: rule.check, rule: rule)
            let status: CheckStatus = evaluation.passed ? .passed : .failed
            return CheckResult(ruleId: rule.id, status: status, message: evaluation.message, details: evaluation.details)
        } catch {
            return CheckResult(ruleId: rule.id, status: .error, message: "\(rule.title): error — \(error.localizedDescription)", details: nil)
        }
    }

    private func makeProbe(for type: ProbeType) throws -> any Probe {
        let runner = ProcessRunner()
        switch type {
        case .system: return SystemProbe(runner: runner)
        case .tcc: return TCCProbe(runner: runner)
        case .launch: return LaunchProbe(runner: runner)
        case .fileSystem: return FileSystemProbe(runner: runner)
        case .network: return NetworkProbe(runner: runner)
        case .password: return PasswordProbe(runner: runner)
        case .firewall: return FirewallProbe(runner: runner)
        case .softwareUpdate: return SoftwareUpdateProbe(runner: runner)
        case .sharing: return SharingProbe(runner: runner)
        case .application: return ApplicationProbe(runner: runner)
        }
    }
}

public enum EngineError: Swift.Error, LocalizedError, Sendable {
    case directoryNotFound(String)
    case invalidYaml(String)

    public var errorDescription: String? {
        switch self {
        case .directoryNotFound(let d): return "Rules directory not found: \(d)"
        case .invalidYaml(let f): return "Cannot read file: \(f)"
        }
    }
}
