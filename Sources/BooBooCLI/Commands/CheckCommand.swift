import ArgumentParser
import BooBooCore

struct CheckCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "check",
        abstract: "Run a single rule check"
    )

    @Argument(help: "Rule ID to check")
    var ruleId: String

    @Option(name: .long, help: "Path to rules directory")
    var rulesDir: String = "./rules"

    mutating func run() async throws {
        let engine = RuleEngine()
        let allRules: [Rule]
        do {
            allRules = try engine.loadRules(from: rulesDir)
        } catch {
            printStderr("Error: \(error.localizedDescription)")
            throw ExitCode.failure
        }

        let ruleMap = Dictionary(uniqueKeysWithValues: allRules.map { ($0.id, $0) })

        guard let rule = ruleMap[ruleId] else {
            printStderr("Error: rule '\(ruleId)' not found")
            throw ExitCode.failure
        }

        let report = try await engine.runScan(rules: [rule])

        guard let result = report.results.first else {
            printStderr("Error: no result returned for rule '\(ruleId)'")
            throw ExitCode.failure
        }

        let status = result.status.rawValue.uppercased()
        print("Rule: \(rule.id) - \(rule.title)")
        print("Status: \(status)")
        print("Message: \(result.message)")
        if let details = result.details {
            print("Details: \(details)")
        }

    }
}
