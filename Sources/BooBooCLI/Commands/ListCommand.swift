import ArgumentParser
import Foundation
import BooBooCore

struct ListCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all rules grouped by category"
    )

    @Option(name: .long, help: "Filter by rule category")
    var category: String?

    @Option(name: .long, help: "Filter by severity")
    var severity: String?

    @Option(name: .long, help: "Output format (text or json)")
    var format: OutputFormat = .text

    @Option(name: .long, help: "Path to rules directory")
    var rulesDir: String = "./rules"

    mutating func run() throws {
        let engine = RuleEngine()
        let allRules: [Rule]
        do {
            allRules = try engine.loadRules(from: rulesDir)
        } catch {
            printStderr("Error: \(error.localizedDescription)")
            throw ExitCode.failure
        }

        let rules = filterRules(allRules, category: category, severity: severity)
        let grouped = Dictionary(grouping: rules, by: { $0.category })
        let sortedCategories = grouped.keys.sorted { $0.rawValue < $1.rawValue }

        if format == .json {
            let items: [[String: String]] = rules.map { rule in
                [
                    "id": rule.id,
                    "title": rule.title,
                    "severity": rule.severity.rawValue,
                    "category": rule.category.rawValue,
                ]
            }
            let data = try JSONSerialization.data(withJSONObject: items, options: [.prettyPrinted, .sortedKeys])
            print(String(data: data, encoding: .utf8)!)
            return
        }

        for category in sortedCategories {
            guard let catRules = grouped[category] else { continue }
            print(category.rawValue.uppercased())
            let header = ["Rule ID", "Title", "Severity"]
            let rows: [[String]] = catRules.map { rule in
                [rule.id, rule.title, rule.severity.rawValue.uppercased()]
            }
            let table = formatTable(header: header, rows: rows)
            for line in table.split(separator: "\n") {
                print("  \(line)")
            }
            print()
        }
    }
}
