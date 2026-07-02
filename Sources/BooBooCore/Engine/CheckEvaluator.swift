import Foundation

public struct CheckEvaluator: Sendable {
    public init() {}

    public func evaluate(probeResult: ProbeResult, check: CheckDefinition, rule: Rule) -> CheckEvaluation {
        guard probeResult.success else {
            return CheckEvaluation(
                rule: rule, passed: false,
                message: "Probe failed: \(probeResult.error ?? "unknown error")",
                details: probeResult.error
            )
        }

        let value = probeResult.value ?? ""
        let checkValue = check.value ?? ""
        let result: Bool

        switch check.op {
        case .equals:
            result = value == checkValue
        case .notEquals:
            result = value != checkValue
        case .contains:
            result = value.contains(checkValue)
        case .notContains:
            result = !value.contains(checkValue)
        case .exists:
            result = !value.isEmpty
        case .notExists:
            result = value.isEmpty
        case .greaterThan:
            result = (Double(value) ?? 0) > (Double(checkValue) ?? 0)
        case .lessThan:
            result = (Double(value) ?? 0) < (Double(checkValue) ?? 0)
        case .greaterThanOrEqual:
            result = (Double(value) ?? 0) >= (Double(checkValue) ?? 0)
        case .lessThanOrEqual:
            result = (Double(value) ?? 0) <= (Double(checkValue) ?? 0)
        case .matches:
            result = (try? RegexCache.match(value, pattern: checkValue)) ?? false
        case .isEnabled:
            result = !value.lowercased().contains("disabled") && !value.lowercased().contains("off")
        case .isDisabled:
            result = value.lowercased().contains("disabled") || value.lowercased().contains("off")
        }

        let message: String
        if result {
            message = "\(rule.title): passed"
        } else {
            let verb: String
            switch check.op {
            case .equals: verb = "expected \(checkValue)"
            case .notEquals: verb = "expected != \(checkValue)"
            case .contains: verb = "expected to contain \(checkValue)"
            case .notContains: verb = "expected not to contain \(checkValue)"
            case .exists: verb = "expected a value"
            case .notExists: verb = "expected no value"
            case .greaterThan: verb = "expected > \(checkValue)"
            case .lessThan: verb = "expected < \(checkValue)"
            case .greaterThanOrEqual: verb = "expected >= \(checkValue)"
            case .lessThanOrEqual: verb = "expected <= \(checkValue)"
            case .matches: verb = "expected to match \(checkValue)"
            case .isEnabled: verb = "expected enabled"
            case .isDisabled: verb = "expected disabled"
            }
            message = "\(rule.title): failed (\(verb))"
        }

        return CheckEvaluation(rule: rule, passed: result, message: message, details: value)
    }
}

private enum RegexCache {
    private static var cache: [String: NSRegularExpression] = [:]
    private static let lock = NSLock()

    static func match(_ string: String, pattern: String) throws -> Bool {
        lock.lock()
        defer { lock.unlock() }
        if let regex = cache[pattern] {
            return regex.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)) != nil
        }
        let regex = try NSRegularExpression(pattern: pattern)
        cache[pattern] = regex
        return regex.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)) != nil
    }
}
