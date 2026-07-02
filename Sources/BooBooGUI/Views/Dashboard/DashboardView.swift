import SwiftUI
import BooBooCore

struct DashboardView: View {
    @State private var score: Double = 72
    @State private var totalRules = 124
    @State private var passed = 89
    @State private var failed = 28
    @State private var errors = 7
    @State private var isScanning = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    private var scoreColor: Color {
        if score < 40 { return .booDanger }
        if score < 70 { return .booWarning }
        return .booSuccess
    }

    var body: some View {
        ScrollView {
            VStack(spacing: BooSpacing.xxlarge) {
                heroSection
                statusCard
                buttonRow
                statsRow
            }
            .padding(BooSpacing.xlarge)
        }
        .background(Color.booBackground)
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK") { showAlert = false }
        }
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

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: BooSpacing.medium) {
            HStack {
                Text("Last Scan Score")
                    .font(.booHeadline)
                    .foregroundColor(.booTextPrimary)
                Spacer()
                Text("\(Int(score))%")
                    .font(.booTitle2)
                    .foregroundColor(scoreColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.booBackgroundHover)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(scoreColor)
                        .frame(width: geo.size.width * CGFloat(score / 100), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(BooSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: BooRadius.card)
                .fill(Color.booBackgroundElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BooRadius.card)
                .stroke(Color.booBorder, lineWidth: 1)
        )
    }

    private var buttonRow: some View {
        HStack(spacing: BooSpacing.medium) {
            Button(action: runScan) {
                Label("Run Full Scan", systemImage: "play.fill")
                    .font(.booHeadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BooSpacing.small)
            }
            .buttonStyle(.borderedProminent)
            .tint(.booAccent)
            .disabled(isScanning)

            Button(action: viewReport) {
                Label("View Last Report", systemImage: "doc.text")
                    .font(.booHeadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BooSpacing.small)
            }
            .buttonStyle(.bordered)
            .tint(.booAccent)
        }
    }

    private var statsRow: some View {
        HStack(spacing: BooSpacing.medium) {
            StatCard(label: "Total", value: "\(totalRules)", icon: "gearshape")
            StatCard(label: "Passed", value: "\(passed)", icon: "checkmark.circle", color: .booSuccess)
            StatCard(label: "Failed", value: "\(failed)", icon: "xmark.circle", color: .booDanger)
            StatCard(label: "Errors", value: "\(errors)", icon: "exclamationmark.triangle", color: .booWarning)
        }
    }

    private func runScan() {
        isScanning = true
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            let newPassed = Int.random(in: 80...120)
            let newFailed = Int.random(in: 5...30)
            let newErrors = Int.random(in: 0...5)
            passed = newPassed
            failed = newFailed
            errors = newErrors
            totalRules = newPassed + newFailed + newErrors
            score = Double(newPassed) / Double(totalRules) * 100
            isScanning = false
            alertMessage = "Scan complete: \(newPassed) passed, \(newFailed) failed, \(newErrors) errors"
            showAlert = true
        }
    }

    private func viewReport() {
        alertMessage = "No scan report available yet."
        showAlert = true
    }
}
