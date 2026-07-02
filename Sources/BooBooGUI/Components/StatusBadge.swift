import SwiftUI
import BooBooCore

enum CheckDisplayStatus {
    case passed, failed, warning, unknown

    var color: Color {
        switch self {
        case .passed: return .booSuccess
        case .failed: return .booDanger
        case .warning: return .booWarning
        case .unknown: return .booTextTertiary
        }
    }

    var label: String {
        switch self {
        case .passed: return "Passed"
        case .failed: return "Failed"
        case .warning: return "Warning"
        case .unknown: return "Unknown"
        }
    }

    init(status: CheckStatus) {
        switch status {
        case .passed, .remediated: self = .passed
        case .failed: self = .failed
        case .error: self = .warning
        case .skipped: self = .unknown
        }
    }

    init() {
        self = .unknown
    }
}

struct StatusBadge: View {
    let status: CheckDisplayStatus

    var body: some View {
        HStack(spacing: BooSpacing.xsmall) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
            Text(status.label)
                .font(.booCaption)
                .foregroundColor(status.color)
        }
    }
}

extension StatusBadge {
    init(status: CheckStatus) {
        self.init(status: CheckDisplayStatus(status: status))
    }
}
