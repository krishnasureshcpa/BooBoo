import Foundation

public final class RemediationService: Sendable {
    private let runner: ProcessRunner
    private let checkEvaluator: CheckEvaluator

    public init(runner: ProcessRunner = ProcessRunner(), checkEvaluator: CheckEvaluator = CheckEvaluator()) {
        self.runner = runner
        self.checkEvaluator = checkEvaluator
    }

    public func remediate(
        rule: Rule,
        confirmation: @escaping () async -> Bool
    ) async throws -> CheckResult {
        guard let remediation = rule.remediation else {
            return CheckResult(ruleId: rule.id, status: .skipped, message: "\(rule.title): no remediation defined")
        }

        guard await confirmation() else {
            return CheckResult(ruleId: rule.id, status: .skipped, message: "\(rule.title): remediation cancelled by user")
        }

        do {
            let output: ProcessRunner.Output

            switch remediation.action {
            case .runCommand, .executeScript:
                guard let cmd = remediation.command else {
                    return CheckResult(ruleId: rule.id, status: .error, message: "\(rule.title): no command for remediation")
                }
                output = try await runner.run(
                    executable: "/bin/bash",
                    args: ["-c", cmd],
                    sudo: remediation.sudo,
                    timeout: 60
                )

            case .writeFile:
                return CheckResult(ruleId: rule.id, status: .error, message: "\(rule.title): write_file remediation not yet implemented")

            case .deleteFile:
                guard let path = remediation.command else {
                    return CheckResult(ruleId: rule.id, status: .error, message: "\(rule.title): no path for delete_file")
                }
                let cmd = remediation.sudo ? "/usr/bin/sudo rm -rf \"\(path)\"" : "/bin/rm -rf \"\(path)\""
                output = try await runner.runBash(cmd, timeout: 60)

            case .modifyPlist:
                guard let cmd = remediation.command else {
                    return CheckResult(ruleId: rule.id, status: .error, message: "\(rule.title): no command for modify_plist")
                }
                output = try await runner.run(executable: "/usr/bin/defaults", args: cmd.split(separator: " ").map(String.init), sudo: remediation.sudo)

            case .enableService, .disableService:
                let action = remediation.action == .enableService ? "enable" : "disable"
                guard let svc = remediation.command else {
                    return CheckResult(ruleId: rule.id, status: .error, message: "\(rule.title): no service name")
                }
                output = try await runner.run(executable: "/bin/launchctl", args: [action, "system/\(svc)"], sudo: true)

            case .setPreference:
                guard let cmd = remediation.command else {
                    return CheckResult(ruleId: rule.id, status: .error, message: "\(rule.title): no command for set_preference")
                }
                output = try await runner.run(executable: "/usr/bin/defaults", args: cmd.split(separator: " ").map(String.init), sudo: remediation.sudo)
            }

            guard output.succeeded else {
                let detail = output.stderr.trimmingCharacters(in: .whitespacesAndNewlines)
                return CheckResult(
                    ruleId: rule.id, status: .error,
                    message: "\(rule.title): remediation failed (\(detail))",
                    details: detail
                )
            }

            let probe = try makeProbe(for: rule.probe)
            let probeResult = try await probe.run()
            let evaluation = checkEvaluator.evaluate(probeResult: probeResult, check: rule.check, rule: rule)
            let status: CheckStatus = evaluation.passed ? .remediated : .failed
            return CheckResult(
                ruleId: rule.id, status: status,
                message: evaluation.passed ? "\(rule.title): remediated successfully" : "\(rule.title): remediation applied but check still fails",
                details: evaluation.details
            )
        } catch {
            return CheckResult(ruleId: rule.id, status: .error, message: "\(rule.title): remediation error — \(error.localizedDescription)")
        }
    }

    private func makeProbe(for type: ProbeType) -> any Probe {
        let runner = ProcessRunner()
        switch type {
        case .system: return SystemProbe(runner: runner)
        case .tcc: return TCCProbe(runner: runner)
        case .launch: return LaunchProbe(runner: runner)
        case .fileSystem: return FileSystemProbe(runner: runner)
        case .network: return NetworkProbe(runner: runner)
        case .password: return PasswordProbe(runner: runner)
        case .firewall: return FirewallProbe(runner: runner)
        case .softwareUpdate: return SoftwareUpdateProbe(runner: runner)
        case .sharing: return SharingProbe(runner: runner)
        case .application: return ApplicationProbe(runner: runner)
        }
    }
}
