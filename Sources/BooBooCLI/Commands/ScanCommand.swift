import ArgumentParser
import Foundation
import BooBooCore

struct ScanCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "scan",
        abstract: "Run a full security scan"
    )

    @Flag(name: .long, help: "Show detailed output for each check")
    var verbose: Bool = false

    @Option(name: .long, help: "Output format (text or json)")
    var format: OutputFormat = .text

    @Option(name: .long, help: "Filter by rule category")
    var category: String?

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

        let rules = filterRules(allRules, category: category, severity: nil)

        if rules.isEmpty {
            print("No rules to scan")
            return
        }

        let report = try await engine.runScan(rules: rules)
        try saveReport(report)

        if format == .json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
            print(String(data: try encoder.encode(report), encoding: .utf8)!)
            return
        }

        let ruleMap = Dictionary(uniqueKeysWithValues: rules.map { ($0.id, $0) })
        let header = ["Rule ID", "Title", "Status", "Message"]
        let rows: [[String]] = report.results.map { result in
            let title = ruleMap[result.ruleId]?.title ?? result.ruleId
            let msg = verbose ? result.message : (result.status == .passed ? "passed" : result.message)
            return [result.ruleId, title, result.status.rawValue.uppercased(), msg]
        }
        print(formatTable(header: header, rows: rows))
        print()
        print("Summary: \(report.summary)")
    }
}
