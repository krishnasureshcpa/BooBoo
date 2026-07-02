import ArgumentParser
import Foundation
import BooBooCore

enum OutputFormat: String, ExpressibleByArgument {
    case text, json
}

func printStderr(_ message: String) {
    try? FileHandle.standardError.write(contentsOf: Data((message + "\n").utf8))
}

func filterRules(_ rules: [Rule], category: String?, severity: String?) -> [Rule] {
    var result = rules
    if let raw = category, let cat = RuleCategory(rawValue: raw) {
        result = result.filter { $0.category == cat }
    }
    if let raw = severity, let sev = Severity(rawValue: raw) {
        result = result.filter { $0.severity == sev }
    }
    return result
}

func reportsDirectory() -> URL {
    FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Application Support/BooBoo/reports")
}

func saveReport(_ report: ScanReport) throws {
    let dir = reportsDirectory()
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
    let dateStr = formatter.string(from: report.timestamp)
        .replacingOccurrences(of: ":", with: "-")
    let url = dir.appendingPathComponent("scan_\(dateStr).json")
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
    try encoder.encode(report).write(to: url)
}

func loadLatestReport() throws -> ScanReport? {
    let dir = reportsDirectory()
    guard FileManager.default.fileExists(atPath: dir.path) else { return nil }
    let contents = try FileManager.default.contentsOfDirectory(
        at: dir, includingPropertiesForKeys: [.contentModificationDateKey]
    )
    let jsonFiles = contents.filter { $0.pathExtension == "json" }
    guard !jsonFiles.isEmpty else { return nil }
    let sorted = try jsonFiles.sorted { a, b in
        let aDate = try a.resourceValues(forKeys: [.contentModificationDateKey])
            .contentModificationDate ?? .distantPast
        let bDate = try b.resourceValues(forKeys: [.contentModificationDateKey])
            .contentModificationDate ?? .distantPast
        return aDate > bDate
    }
    let data = try Data(contentsOf: sorted[0])
    return try JSONDecoder().decode(ScanReport.self, from: data)
}

func formatTable(header: [String], rows: [[String]]) -> String {
    guard !header.isEmpty else { return "" }
    let columnCount = header.count
    var widths = header.map { $0.count }
    for row in rows {
        for (i, cell) in row.enumerated() where i < columnCount {
            widths[i] = max(widths[i], cell.count)
        }
    }
    let padding = 2
    var result = ""
    for (i, col) in header.enumerated() {
        result += col.padding(toLength: widths[i] + padding, withPad: " ", startingAt: 0)
    }
    result += "\n"
    for w in widths {
        result += String(repeating: "-", count: w + padding)
    }
    result += "\n"
    for row in rows {
        for (i, cell) in row.enumerated() where i < columnCount {
            result += cell.padding(toLength: widths[i] + padding, withPad: " ", startingAt: 0)
        }
        result += "\n"
    }
    return String(result.dropLast())
}
