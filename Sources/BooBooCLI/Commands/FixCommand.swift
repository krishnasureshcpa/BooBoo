import ArgumentParser
import BooBooCore

struct FixCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "fix",
        abstract: "Remediate a failed rule"
    )

    @Argument(help: "Rule ID to fix")
    var ruleId: String

    @Flag(name: .long, help: "Confirm remediation")
    var confirm: Bool = false

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

        guard let remediation = rule.remediation else {
            printStderr("Error: no remediation defined for rule '\(ruleId)'")
            throw ExitCode.failure
        }

        print("Rule: \(rule.id) - \(rule.title)")
        print("Remediation: \(remediation.description)")
        print()

        guard confirm else {
            print("Use --confirm to apply this remediation")
            return
        }

        let remediationService = RemediationService()
        let result = try await remediationService.remediate(rule: rule, confirmation: { true })

        let status = result.status.rawValue.uppercased()
        print("Result: \(status)")
        print("Message: \(result.message)")
        if let details = result.details {
            print("Details: \(details)")
        }

        if result.status == .error || result.status == .failed {
            throw ExitCode.failure
        }
    }
}
