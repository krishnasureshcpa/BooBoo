import XCTest
import Foundation
@testable import BooBooCore

final class CoreTests: XCTestCase {

    // MARK: - Rule Model

    func testRuleInit() {
        let check = CheckDefinition(value: "1.0", op: .equals)
        let rule = Rule(
            id: "cis-001", title: "Test Rule", category: .authentication,
            severity: .high, description: "desc", rationale: "why",
            frameworks: ["CIS"], platforms: ["macOS"],
            probe: .password, check: check
        )
        XCTAssertEqual(rule.id, "cis-001")
        XCTAssertEqual(rule.probe, .password)
        XCTAssertEqual(rule.check.op, .equals)
        XCTAssertEqual(rule.check.value, "1.0")
    }

    func testRuleCodableRoundTrip() throws {
        let check = CheckDefinition(value: "enabled", op: .isEnabled)
        let rule = Rule(
            id: "cis-002", title: "Round Trip", category: .firewall,
            severity: .critical, description: "d", rationale: "r",
            frameworks: ["CIS"], platforms: ["macOS"],
            probe: .firewall, check: check
        )
        let data = try JSONEncoder().encode(rule)
        let decoded = try JSONDecoder().decode(Rule.self, from: data)
        XCTAssertEqual(decoded.id, rule.id)
        XCTAssertEqual(decoded.probe, rule.probe)
        XCTAssertEqual(decoded.check.op, rule.check.op)
    }

    // MARK: - CheckOperator Raw Values

    func testCheckOperatorRawValues() {
        XCTAssertEqual(CheckOperator.equals.rawValue, "equals")
        XCTAssertEqual(CheckOperator.notEquals.rawValue, "not_equals")
        XCTAssertEqual(CheckOperator.greaterThanOrEqual.rawValue, "greater_than_or_equal")
        XCTAssertEqual(CheckOperator.lessThanOrEqual.rawValue, "less_than_or_equal")
        XCTAssertEqual(CheckOperator.isEnabled.rawValue, "is_enabled")
        XCTAssertEqual(CheckOperator.matches.rawValue, "matches")
    }

    // MARK: - ScanReport

    func testScanReportEmpty() {
        let r = ScanReport(totalRules: 0, passed: 0, failed: 0, errors: 0)
        XCTAssertEqual(r.complianceScore, 0)
        XCTAssertTrue(r.summary.contains("0/0"))
    }

    func testScanReportScore() {
        let r = ScanReport(totalRules: 10, passed: 7, failed: 2, errors: 1)
        XCTAssertEqual(r.complianceScore, 70)
        XCTAssertTrue(r.summary.contains("7/10"))
    }

    // MARK: - CheckEvaluator

    let sampleRule = Rule(
        id: "test", title: "Sample", category: .authentication,
        severity: .medium, description: "d", rationale: "r",
        frameworks: ["CIS"], platforms: ["macOS"],
        probe: .password,
        check: CheckDefinition(value: nil, op: .exists)
    )

    func testEvaluatorProbeFailure() {
        let e = CheckEvaluator()
        let pr = ProbeResult(probe: .password, success: false, error: "boom")
        let result = e.evaluate(probeResult: pr, check: sampleRule.check, rule: sampleRule)
        XCTAssertFalse(result.passed)
        XCTAssertTrue(result.message.contains("Probe failed"))
    }

    func testEvaluatorEquals() {
        let e = CheckEvaluator()
        let check = CheckDefinition(value: "hello", op: .equals)
        let pr = ProbeResult(probe: .password, success: true, value: "hello")
        XCTAssertTrue(e.evaluate(probeResult: pr, check: check, rule: sampleRule).passed)
        let pr2 = ProbeResult(probe: .password, success: true, value: "world")
        XCTAssertFalse(e.evaluate(probeResult: pr2, check: check, rule: sampleRule).passed)
    }

    func testEvaluatorContains() {
        let e = CheckEvaluator()
        let check = CheckDefinition(value: "abc", op: .contains)
        let pr = ProbeResult(probe: .password, success: true, value: "xx abc yy")
        XCTAssertTrue(e.evaluate(probeResult: pr, check: check, rule: sampleRule).passed)
        let pr2 = ProbeResult(probe: .password, success: true, value: "xyz")
        XCTAssertFalse(e.evaluate(probeResult: pr2, check: check, rule: sampleRule).passed)
    }

    func testEvaluatorExists() {
        let e = CheckEvaluator()
        let check = CheckDefinition(value: nil, op: .exists)
        XCTAssertTrue(e.evaluate(probeResult: ProbeResult(probe: .password, success: true, value: "yes"), check: check, rule: sampleRule).passed)
        XCTAssertFalse(e.evaluate(probeResult: ProbeResult(probe: .password, success: true, value: ""), check: check, rule: sampleRule).passed)
    }

    func testEvaluatorNumericOperators() {
        let e = CheckEvaluator()
        let gt = CheckDefinition(value: "5", op: .greaterThan)
        XCTAssertTrue(e.evaluate(probeResult: ProbeResult(probe: .password, success: true, value: "10"), check: gt, rule: sampleRule).passed)
        XCTAssertFalse(e.evaluate(probeResult: ProbeResult(probe: .password, success: true, value: "3"), check: gt, rule: sampleRule).passed)

        let gte = CheckDefinition(value: "5", op: .greaterThanOrEqual)
        XCTAssertTrue(e.evaluate(probeResult: ProbeResult(probe: .password, success: true, value: "5"), check: gte, rule: sampleRule).passed)
        XCTAssertTrue(e.evaluate(probeResult: ProbeResult(probe: .password, success: true, value: "10"), check: gte, rule: sampleRule).passed)
        XCTAssertFalse(e.evaluate(probeResult: ProbeResult(probe: .password, success: true, value: "3"), check: gte, rule: sampleRule).passed)

        let lte = CheckDefinition(value: "5", op: .lessThanOrEqual)
        XCTAssertTrue(e.evaluate(probeResult: ProbeResult(probe: .password, success: true, value: "5"), check: lte, rule: sampleRule).passed)
        XCTAssertTrue(e.evaluate(probeResult: ProbeResult(probe: .password, success: true, value: "3"), check: lte, rule: sampleRule).passed)
        XCTAssertFalse(e.evaluate(probeResult: ProbeResult(probe: .password, success: true, value: "10"), check: lte, rule: sampleRule).passed)
    }

    func testEvaluatorIsEnabled() {
        let e = CheckEvaluator()
        let en = CheckDefinition(value: nil, op: .isEnabled)
        XCTAssertTrue(e.evaluate(probeResult: ProbeResult(probe: .password, success: true, value: "enabled"), check: en, rule: sampleRule).passed)
        XCTAssertFalse(e.evaluate(probeResult: ProbeResult(probe: .password, success: true, value: "disabled"), check: en, rule: sampleRule).passed)
    }

    // MARK: - YamlParser

    func testYamlParserSingleRule() throws {
        let yaml = """
        ---
        id: cis-001
        title: Test Password Rule
        category: authentication
        severity: high
        probe: password
        description: Ensure password is set
        rationale: Security
        frameworks: [CIS]
        platforms: [macOS]
        check:
          op: exists
        """
        let parser = YamlParser()
        let rules = try parser.parse(yaml)
        XCTAssertEqual(rules.count, 1)
        XCTAssertEqual(rules[0].id, "cis-001")
        XCTAssertEqual(rules[0].probe, .password)
        XCTAssertEqual(rules[0].check.op, .exists)
    }

    func testYamlParserMultipleDocs() throws {
        let yaml = """
        ---
        id: cis-001
        title: Rule One
        category: authentication
        severity: high
        probe: password
        description: d
        rationale: r
        frameworks: [CIS]
        platforms: [macOS]
        check:
          op: exists
        ---
        id: cis-002
        title: Rule Two
        category: firewall
        severity: medium
        probe: firewall
        description: d
        rationale: r
        frameworks: [CIS]
        platforms: [macOS]
        check:
          op: is_enabled
        """
        let parser = YamlParser()
        let rules = try parser.parse(yaml)
        XCTAssertEqual(rules.count, 2)
    }

    func testYamlParserMissingIdReturnsEmpty() throws {
        let yaml = """
        ---
        title: No ID
        category: authentication
        severity: high
        probe: password
        description: d
        rationale: r
        frameworks: [CIS]
        platforms: [macOS]
        check:
          op: exists
        """
        let parser = YamlParser()
        let rules = try parser.parse(yaml)
        XCTAssertTrue(rules.isEmpty)
    }

    func testYamlParserInvalidOperatorThrows() {
        let yaml = """
        ---
        id: cis-bad
        title: Bad Op
        category: authentication
        severity: high
        probe: password
        description: d
        rationale: r
        frameworks: [CIS]
        platforms: [macOS]
        check:
          op: nonexistent_op
        """
        let parser = YamlParser()
        XCTAssertThrowsError(try parser.parse(yaml))
    }
}
