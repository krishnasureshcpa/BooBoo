import XCTest
import Foundation
@testable import BooBooCLI

final class CLITests: XCTestCase {

    func testVersionCommandAbstract() {
        XCTAssertFalse(VersionCommand.configuration.abstract?.isEmpty ?? true)
    }

    func testScanCommandConfig() {
        XCTAssertFalse(ScanCommand.configuration.abstract?.isEmpty ?? true)
        XCTAssertEqual(ScanCommand.configuration._commandName, "scan")
    }

    func testListCommandConfig() {
        XCTAssertEqual(ListCommand.configuration._commandName, "list")
    }

    func testFixCommandConfig() {
        XCTAssertEqual(FixCommand.configuration._commandName, "fix")
    }

    func testMainCommandHasAllSubcommands() {
        let names = BooBoo.configuration.subcommands.map { $0._commandName }
        XCTAssertTrue(names.contains("scan"))
        XCTAssertTrue(names.contains("check"))
        XCTAssertTrue(names.contains("list"))
        XCTAssertTrue(names.contains("fix"))
        XCTAssertTrue(names.contains("report"))
        XCTAssertTrue(names.contains("version"))
    }
}
