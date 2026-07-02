import ArgumentParser

struct VersionCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "version",
        abstract: "Show version information"
    )

    mutating func run() {
        print("BooBoo 1.0.0")
    }
}
