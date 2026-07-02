import ArgumentParser
import Foundation
import BooBooCore

struct ReportCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "report",
        abstract: "Show the last scan report"
    )

    @Option(name: .long, help: "Output format (text or json)")
    var format: OutputFormat = .text

    mutating func run() throws {
        guard let report = try loadLatestReport() else {
            printStderr("Error: no scan reports found")
            throw ExitCode.failure
        }

        if format == .json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
            print(String(data: try encoder.encode(report), encoding: .utf8)!)
            return
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
        let dateStr = formatter.string(from: report.timestamp)

        print("Report: \(report.id.uuidString)")
        print("Date: \(dateStr)")
        print()

        let header = ["Rule ID", "Status", "Message"]
        let rows: [[String]] = report.results.map { result in
            [result.ruleId, result.status.rawValue.uppercased(), result.message]
        }
        print(formatTable(header: header, rows: rows))
        print()
        print("Summary: \(report.summary)")
    }
}
