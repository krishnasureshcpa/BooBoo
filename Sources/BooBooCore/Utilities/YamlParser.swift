import Foundation

public struct YamlParser: Sendable {
    public init() {}

    public func parse(_ content: String) throws -> [Rule] {
        let lines = content.components(separatedBy: .newlines)
        var rules: [Rule] = []
        var currentDoc: [String: Any] = [:]
        var inDocument = false

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
            if trimmed == "---" {
                if inDocument, let rule = try buildRule(from: currentDoc) {
                    rules.append(rule)
                }
                currentDoc = [:]
                inDocument = true
                continue
            }
            guard inDocument else { continue }

            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("- ") {
                let keyValue = String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                if let colonIndex = keyValue.firstIndex(of: ":") {
                    let key = String(keyValue[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                    let val = String(keyValue[colonIndex...].dropFirst()).trimmingCharacters(in: .whitespaces)
                    currentDoc[key] = parseValue(val)
                }
                continue
            }

            if let colonIndex = trimmed.firstIndex(of: ":") {
                let key = String(trimmed[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                let rest = String(trimmed[colonIndex...].dropFirst()).trimmingCharacters(in: .whitespaces)

                if rest.isEmpty || rest == "|" || rest == ">" {
                    currentDoc[key] = true
                } else if rest.hasPrefix("[") && rest.hasSuffix("]") {
                    let inner = String(rest.dropFirst().dropLast())
                    let items = inner.split(separator: ",").map {
                        $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                    }
                    currentDoc[key] = items
                } else if rest == "true" {
                    currentDoc[key] = true
                } else if rest == "false" {
                    currentDoc[key] = false
                } else if let num = Int(rest) {
                    currentDoc[key] = num
                } else if rest.hasPrefix("'") && rest.hasSuffix("'") {
                    currentDoc[key] = String(rest.dropFirst().dropLast())
                } else if rest.hasPrefix("\"") && rest.hasSuffix("\"") {
                    currentDoc[key] = String(rest.dropFirst().dropLast())
                } else {
                    currentDoc[key] = rest
                }
            }
        }

        if inDocument, let rule = try buildRule(from: currentDoc) {
            rules.append(rule)
        }

        return rules
    }

    private func buildRule(from doc: [String: Any]) throws -> Rule? {
        guard let id = doc["id"] as? String, let title = doc["title"] as? String else {
            return nil
        }
        guard let catStr = doc["category"] as? String, let category = RuleCategory(rawValue: catStr) else {
            return nil
        }
        guard let sevStr = doc["severity"] as? String, let severity = Severity(rawValue: sevStr) else {
            return nil
        }
        guard let probeStr = doc["probe"] as? String, let probe = ProbeType(rawValue: probeStr) else {
            return nil
        }

        let description = doc["description"] as? String ?? ""
        let rationale = doc["rationale"] as? String ?? ""
        let frameworks = doc["frameworks"] as? [String] ?? []
        let platforms = doc["platforms"] as? [String] ?? []

        let check = try parseCheck(from: doc["check"])
        let remediation = try parseRemediation(from: doc["remediation"])

        return Rule(
            id: id, title: title, category: category, severity: severity,
            description: description, rationale: rationale,
            frameworks: frameworks, platforms: platforms,
            probe: probe, check: check, remediation: remediation
        )
    }

    private func parseCheck(from value: Any?) throws -> CheckDefinition {
        guard let dict = value as? [String: Any] else {
            throw YamlError.invalidCheckDefinition
        }
        guard let opStr = dict["op"] as? String, let op = CheckOperator(rawValue: opStr) else {
            throw YamlError.invalidCheckOperator
        }
        let checkValue = dict["value"] as? String
        let path = dict["path"] as? String
        let args = dict["args"] as? [String]
        return CheckDefinition(value: checkValue, op: op, path: path, args: args)
    }

    private func parseRemediation(from value: Any?) throws -> Remediation? {
        guard let dict = value as? [String: Any] else { return nil }
        guard let actionStr = dict["action"] as? String, let action = RemediationAction(rawValue: actionStr) else {
            return nil
        }
        let command = dict["command"] as? String
        let args = dict["args"] as? [String]
        let sudo = dict["sudo"] as? Bool ?? false
        let description = dict["description"] as? String ?? ""
        let rollbackCommand = dict["rollback_command"] as? String
        let requires = dict["requires"] as? [String]
        return Remediation(action: action, command: command, args: args, sudo: sudo, description: description, rollbackCommand: rollbackCommand, requires: requires)
    }

    private func parseValue(_ raw: String) -> Any {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if trimmed == "true" { return true }
        if trimmed == "false" { return false }
        if let num = Int(trimmed) { return num }
        if let dbl = Double(trimmed) { return dbl }
        return trimmed
    }
}

public enum YamlError: Swift.Error, LocalizedError, Sendable {
    case invalidCheckDefinition
    case invalidCheckOperator
    case invalidYamlStructure(String)

    public var errorDescription: String? {
        switch self {
        case .invalidCheckDefinition: return "Invalid check definition in YAML"
        case .invalidCheckOperator: return "Invalid check operator in YAML"
        case .invalidYamlStructure(let d): return "Invalid YAML structure: \(d)"
        }
    }
}
