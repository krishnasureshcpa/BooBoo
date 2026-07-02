import SwiftUI
import BooBooCore

struct DashboardView: View {
    @Environment(AppState.self) private var state

    private var scoreColor: Color {
        let s = state.score
        if s < 40 { return .booDanger }
        if s < 70 { return .booWarning }
        return .booSuccess
    }

    var body: some View {
        ScrollView {
            VStack(spacing: BooSpacing.xxlarge) {
                heroSection
                if state.isScanning {
                    scanningIndicator
                }
                statusCard
                buttonRow
                statsRow
                if let error = state.error {
                    errorBanner(error)
                }
            }
            .padding(BooSpacing.xlarge)
        }
        .background(Color.booBackground)
    }

    private var heroSection: some View {
        VStack(spacing: BooSpacing.small) {
            Image(systemName: "ghost.fill")
                .font(.system(size: 48))
                .foregroundColor(.booAccent)

            Text("BooBoo")
                .font(.booLargeTitle)
                .foregroundColor(.booTextPrimary)

            Text("macOS Security & Privacy")
                .font(.booCallout)
                .foregroundColor(.booTextTertiary)
        }
    }

    private var scanningIndicator: some View {
        HStack(spacing: BooSpacing.small) {
            ProgressView()
                .scaleEffect(0.8)
                .controlSize(.small)
            Text("Scanning \(state.totalRules) rules...")
                .font(.booCallout)
                .foregroundColor(.booAccent)
        }
        .padding(.vertical, BooSpacing.small)
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: BooSpacing.medium) {
            HStack {
                Text(state.report != nil ? "Last Scan Score" : "No Scan Yet")
                    .font(.booHeadline)
                    .foregroundColor(.booTextPrimary)
                Spacer()
                if state.report != nil {
                    Text("\(Int(state.score))%")
                        .font(.booTitle2)
                        .foregroundColor(scoreColor)
                } else {
                    Image(systemName: "minus.circle")
                        .font(.title2)
                        .foregroundColor(.booTextTertiary)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.booBackgroundHover)
                        .frame(height: 8)

                    if state.report != nil {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(scoreColor)
                            .frame(width: geo.size.width * CGFloat(state.score / 100), height: 8)
                            .animation(.easeOut(duration: 0.5), value: state.score)
                    }
                }
            }
            .frame(height: 8)
        }
        .padding(BooSpacing.medium)
        .background(RoundedRectangle(cornerRadius: BooRadius.card).fill(Color.booBackgroundElevated))
        .overlay(RoundedRectangle(cornerRadius: BooRadius.card).stroke(Color.booBorder, lineWidth: 1))
    }

    private var buttonRow: some View {
        HStack(spacing: BooSpacing.medium) {
            Button(action: { Task { await state.runScan() } }) {
                Label("Run Full Scan", systemImage: "play.fill")
                    .font(.booHeadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BooSpacing.small)
            }
            .buttonStyle(.borderedProminent)
            .tint(.booAccent)
            .disabled(state.isScanning)
            .keyboardShortcut("s", modifiers: .command)

            Button(action: { Task { await state.runScan() } }) {
                Label("Rescan", systemImage: "arrow.clockwise")
                    .font(.booHeadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BooSpacing.small)
            }
            .buttonStyle(.bordered)
            .tint(.booAccent)
            .disabled(state.isScanning || state.report == nil)
            .keyboardShortcut("r", modifiers: .command)
        }
    }

    private var statsRow: some View {
        HStack(spacing: BooSpacing.medium) {
            StatCard(label: "Total", value: "\(state.totalRules)", icon: "gearshape")
            StatCard(label: "Passed", value: "\(state.passed)", icon: "checkmark.circle", color: .booSuccess)
            StatCard(label: "Failed", value: "\(state.failed)", icon: "xmark.circle", color: .booDanger)
            StatCard(label: "Errors", value: "\(state.errors)", icon: "exclamationmark.triangle", color: .booWarning)
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: BooSpacing.small) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.booWarning)
            Text(message)
                .font(.booCallout)
                .foregroundColor(.booTextSecondary)
        }
        .padding(BooSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BooRadius.card)
                .fill(Color.booWarning.opacity(0.1))
        )
    }
}
