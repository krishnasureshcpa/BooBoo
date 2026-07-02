import Foundation

// MARK: - Rule Definition

public enum RuleCategory: String, Codable, CaseIterable, Sendable {
    case authentication
    case authorization
    case logging
    case firewall
    case encryption
    case updates
    case sharing
    case systemHardening = "system_hardening"
    case applicationSecurity = "application_security"
    case fileIntegrity = "file_integrity"
}

public enum Severity: String, Codable, CaseIterable, Sendable {
    case critical, high, medium, low, informational
}

public enum ProbeType: String, Codable, Sendable {
    case system
    case tcc
    case launch
    case fileSystem = "file_system"
    case network
    case password
    case firewall
    case softwareUpdate = "software_update"
    case sharing
    case application
}

public enum CheckOperator: String, Codable, Sendable {
    case equals
    case notEquals = "not_equals"
    case contains
    case notContains = "not_contains"
    case exists
    case notExists = "not_exists"
    case greaterThan = "greater_than"
    case lessThan = "less_than"
    case greaterThanOrEqual = "greater_than_or_equal"
    case lessThanOrEqual = "less_than_or_equal"
    case matches
    case isEnabled = "is_enabled"
    case isDisabled = "is_disabled"
}

public enum RemediationAction: String, Codable, Sendable {
    case runCommand = "run_command"
    case writeFile = "write_file"
    case deleteFile = "delete_file"
    case modifyPlist = "modify_plist"
    case executeScript = "execute_script"
    case enableService = "enable_service"
    case disableService = "disable_service"
    case setPreference = "set_preference"
}

public enum CheckStatus: String, Codable, Sendable {
    case passed, failed, error, skipped, remediated
}

// MARK: - Rule

public struct CheckDefinition: Codable, Sendable {
    public let value: String?
    public let op: CheckOperator
    public let path: String?
    public let args: [String]?

    public init(value: String? = nil, op: CheckOperator, path: String? = nil, args: [String]? = nil) {
        self.value = value
        self.op = op
        self.path = path
        self.args = args
    }
}

public struct Remediation: Codable, Sendable {
    public let action: RemediationAction
    public let command: String?
    public let args: [String]?
    public let sudo: Bool
    public let description: String
    public let rollbackCommand: String?
    public let requires: [String]?

    public init(action: RemediationAction, command: String? = nil, args: [String]? = nil,
                sudo: Bool = false, description: String, rollbackCommand: String? = nil,
                requires: [String]? = nil) {
        self.action = action
        self.command = command
        self.args = args
        self.sudo = sudo
        self.description = description
        self.rollbackCommand = rollbackCommand
        self.requires = requires
    }
}

public struct Rule: Codable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let category: RuleCategory
    public let severity: Severity
    public let description: String
    public let rationale: String
    public let frameworks: [String]
    public let platforms: [String]
    public let probe: ProbeType
    public let check: CheckDefinition
    public let remediation: Remediation?

    public init(id: String, title: String, category: RuleCategory, severity: Severity,
                description: String, rationale: String, frameworks: [String], platforms: [String],
                probe: ProbeType, check: CheckDefinition, remediation: Remediation? = nil) {
        self.id = id
        self.title = title
        self.category = category
        self.severity = severity
        self.description = description
        self.rationale = rationale
        self.frameworks = frameworks
        self.platforms = platforms
        self.probe = probe
        self.check = check
        self.remediation = remediation
    }
}

// MARK: - Results

public struct CheckResult: Identifiable, Codable, Sendable {
    public let id: UUID
    public let ruleId: String
    public let status: CheckStatus
    public let timestamp: Date
    public let message: String
    public let details: String?

    public init(id: UUID = UUID(), ruleId: String, status: CheckStatus,
                timestamp: Date = Date(), message: String, details: String? = nil) {
        self.id = id
        self.ruleId = ruleId
        self.status = status
        self.timestamp = timestamp
        self.message = message
        self.details = details
    }
}

public struct ProbeResult: Codable, Sendable {
    public let probe: ProbeType
    public let success: Bool
    public let value: String?
    public let error: String?

    public init(probe: ProbeType, success: Bool, value: String? = nil, error: String? = nil) {
        self.probe = probe
        self.success = success
        self.value = value
        self.error = error
    }
}

// MARK: - Scan Report

public struct HardwareInfo: Codable, Sendable {
    public let chip: String
    public let memory: String
    public let serialNumber: String?

    public init(chip: String, memory: String, serialNumber: String? = nil) {
        self.chip = chip
        self.memory = memory
        self.serialNumber = serialNumber
    }
}

public struct SystemState: Codable, Sendable {
    public let timestamp: Date
    public let macOSVersion: String
    public let hardwareInfo: HardwareInfo?

    public init(timestamp: Date = Date(), macOSVersion: String, hardwareInfo: HardwareInfo? = nil) {
        self.timestamp = timestamp
        self.macOSVersion = macOSVersion
        self.hardwareInfo = hardwareInfo
    }
}

public struct ScanReport: Identifiable, Codable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let totalRules: Int
    public let passed: Int
    public let failed: Int
    public let errors: Int
    public let skipped: Int
    public let results: [CheckResult]

    public var complianceScore: Double {
        guard totalRules > 0 else { return 0 }
        return Double(passed) / Double(totalRules) * 100
    }

    public var summary: String {
        "\(passed)/\(totalRules) passed (\(Int(complianceScore))%) — \(failed) failed, \(errors) errors, \(skipped) skipped"
    }

    public init(id: UUID = UUID(), timestamp: Date = Date(), totalRules: Int, passed: Int,
                failed: Int, errors: Int, skipped: Int = 0, results: [CheckResult] = []) {
        self.id = id
        self.timestamp = timestamp
        self.totalRules = totalRules
        self.passed = passed
        self.failed = failed
        self.errors = errors
        self.skipped = skipped
        self.results = results
    }
}
