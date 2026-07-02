import SwiftUI
import BooBooCore

struct SeverityLabel: View {
    let severity: Severity

    private var color: Color {
        switch severity {
        case .critical: return .booDanger
        case .high: return .booWarning
        case .medium: return .booWisp
        case .low: return .booTextSecondary
        case .informational: return .booTextTertiary
        }
    }

    var body: some View {
        Text(severity.rawValue.capitalized)
            .font(.booCaption)
            .foregroundColor(color)
            .padding(.horizontal, BooSpacing.small)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: BooRadius.small)
                    .fill(color.opacity(0.15))
            )
    }
}
