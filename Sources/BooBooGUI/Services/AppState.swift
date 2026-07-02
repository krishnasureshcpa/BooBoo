import Foundation
import BooBooCore

@MainActor @Observable
final class AppState {
    let engine: RuleEngine
    let remediationService: RemediationService
    private(set) var rules: [Rule] = []
    private(set) var report: ScanReport?
    private(set) var isScanning = false
    private(set) var isFixing = false
    private(set) var fixResults: [String: CheckResult] = [:]
    private(set) var error: String?

    var searchText = ""
    var selectedSeverities: Set<Severity> = []
    var selectedCategories: Set<RuleCategory> = []
    var showOnlyFailing = false

    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding") }
    }
    var showAssistant = false

    func finishOnboarding() {
        hasCompletedOnboarding = true
        showAssistant = true
    }

    init(engine: RuleEngine = RuleEngine(), remediationService: RemediationService = RemediationService()) {
        self.engine = engine
        self.remediationService = remediationService
    }

    // MARK: - Computed

    var passed: Int { report?.passed ?? 0 }
    var failed: Int { report?.failed ?? 0 }
    var errors: Int { report?.errors ?? 0 }
    var totalRules: Int { rules.count }
    var score: Double { totalRules > 0 ? (Double(passed) / Double(totalRules)) * 100 : 0 }

    var filteredRules: [Rule] {
        var result = rules
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.id.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        if !selectedSeverities.isEmpty {
            result = result.filter { selectedSeverities.contains($0.severity) }
        }
        if !selectedCategories.isEmpty {
            result = result.filter { selectedCategories.contains($0.category) }
        }
        if showOnlyFailing {
            let failingIds = Set(
                (report?.results ?? []).filter { $0.status == .failed }.map(\.ruleId)
            )
            result = result.filter { failingIds.contains($0.id) }
        }
        return result
    }

    var groupedFilteredRules: [(RuleCategory, [Rule])] {
        Dictionary(grouping: filteredRules, by: { $0.category })
            .sorted { $0.key.rawValue < $1.key.rawValue }
    }

    func result(for ruleId: String) -> CheckResult? {
        report?.results.first { $0.ruleId == ruleId }
    }

    // MARK: - Actions

    func loadRules(from directory: String) {
        do {
            rules = try engine.loadRules(from: directory)
            error = nil
        } catch {
            self.error = "Failed to load rules: \(error.localizedDescription)"
            rules = []
        }
    }

    func runScan() async {
        isScanning = true
        error = nil
        do {
            report = try await engine.runScan(rules: rules)
        } catch {
            self.error = "Scan failed: \(error.localizedDescription)"
        }
        isScanning = false
    }

    func fixRule(_ rule: Rule) async -> Bool {
        isFixing = true
        let result = (try? await remediationService.remediate(rule: rule) { true }) ??
            CheckResult(ruleId: rule.id, status: .error, message: "Remediation threw")
        fixResults[rule.id] = result
        isFixing = false
        return result.status == .remediated
    }

    func fixAllFailing() async -> (succeeded: Int, failed: Int) {
        isFixing = true
        let failing = rules.filter { rule in
            guard let r = result(for: rule.id) else { return false }
            return r.status == .failed
        }
        var succeeded = 0, failed = 0
        for rule in failing {
            let ok = await fixRule(rule)
            if ok { succeeded += 1 } else { failed += 1 }
        }
        isFixing = false
        return (succeeded, failed)
    }
}
