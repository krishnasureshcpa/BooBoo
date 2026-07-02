import Foundation

/// Protocol all probes conform to.
public protocol Probe: Sendable {
    var type: ProbeType { get }
    func run() async throws -> ProbeResult
}

/// Result from evaluating a single check against probe output.
public struct CheckEvaluation: Sendable {
    public let rule: Rule
    public let passed: Bool
    public let message: String
    public let details: String?

    public init(rule: Rule, passed: Bool, message: String, details: String? = nil) {
        self.rule = rule
        self.passed = passed
        self.message = message
        self.details = details
    }
}
