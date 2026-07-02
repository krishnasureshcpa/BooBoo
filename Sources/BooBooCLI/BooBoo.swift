import ArgumentParser
import Foundation

@main
struct BooBoo: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "booboo",
        abstract: "macOS security auditing tool",
        subcommands: [
            ScanCommand.self,
            CheckCommand.self,
            ListCommand.self,
            FixCommand.self,
            ReportCommand.self,
            VersionCommand.self,
        ]
    )
}
