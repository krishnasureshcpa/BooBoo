import SwiftUI
import BooBooCore

struct SettingsView: View {
    @State private var rulesPath: String = "/etc/booboo/rules"
    @State private var scanFrequency: String = "weekly"

    let frequencies = [
        ("daily", "Daily"),
        ("weekly", "Weekly"),
        ("monthly", "Monthly"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: BooSpacing.large) {
                rulesSection
                scheduleSection
                aboutSection
                supportSection
            }
            .padding(BooSpacing.xlarge)
        }
        .background(Color.booBackground)
    }

    private var rulesSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: BooSpacing.small) {
                Text("Rules Path")
                    .font(.booHeadline)
                    .foregroundColor(.booTextPrimary)

                TextField("Path to rules directory", text: $rulesPath)
                    .textFieldStyle(.roundedBorder)
                    .font(.booMonoBody)
                    .disableAutocorrection(true)
            }
            .padding(BooSpacing.medium)
        } label: {
            Label("Rules", systemImage: "doc.text")
                .font(.booTitle3)
                .foregroundColor(.booTextPrimary)
        }
        .groupBoxStyle(BooGroupBoxStyle())
    }

    private var scheduleSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: BooSpacing.small) {
                Text("Scan Frequency")
                    .font(.booHeadline)
                    .foregroundColor(.booTextPrimary)

                Picker("Frequency", selection: $scanFrequency) {
                    ForEach(frequencies, id: \.0) { key, label in
                        Text(label).tag(key)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(true)

                HStack {
                    Image(systemName: "clock.badge.exclamationmark")
                        .foregroundColor(.booWisp)
                    Text("Coming Soon")
                        .font(.booCaption)
                        .foregroundColor(.booWisp)
                }
            }
            .padding(BooSpacing.medium)
        } label: {
            Label("Schedule", systemImage: "clock.arrow.circlepath")
                .font(.booTitle3)
                .foregroundColor(.booTextPrimary)
        }
        .groupBoxStyle(BooGroupBoxStyle())
    }

    private var aboutSection: some View {
        GroupBox {
            VStack(spacing: BooSpacing.medium) {
                GhostPlaceholder(size: BooLayout.ghostSmallSize)

                VStack(spacing: BooSpacing.xsmall) {
                    Text("BooBoo")
                        .font(.booTitle2)
                        .foregroundColor(.booTextPrimary)
                    Text("Version 1.0.0")
                        .font(.booCallout)
                        .foregroundColor(.booTextTertiary)
                    Text("Build 1")
                        .font(.booCaption)
                        .foregroundColor(.booTextTertiary)
                }

                Text("macOS Security & Privacy Compliance Tool")
                    .font(.booFootnote)
                    .foregroundColor(.booTextSecondary)
            }
            .padding(BooSpacing.medium)
            .frame(maxWidth: .infinity)
        } label: {
            Label("About", systemImage: "info.circle")
                .font(.booTitle3)
                .foregroundColor(.booTextPrimary)
        }
        .groupBoxStyle(BooGroupBoxStyle())
    }

    private var supportSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: BooSpacing.small) {
                Text("Log Location")
                    .font(.booHeadline)
                    .foregroundColor(.booTextPrimary)

                HStack(spacing: BooSpacing.small) {
                    Image(systemName: "folder")
                        .foregroundColor(.booAccent)
                    Text("~/Library/Logs/com.booboo.agent/")
                        .font(.booMonoCaption)
                        .foregroundColor(.booAccent)
                }
            }
            .padding(BooSpacing.medium)
        } label: {
            Label("Support", systemImage: "questionmark.circle")
                .font(.booTitle3)
                .foregroundColor(.booTextPrimary)
        }
        .groupBoxStyle(BooGroupBoxStyle())
    }
}

struct BooGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            configuration.label
                .padding(.horizontal, BooSpacing.medium)
                .padding(.top, BooSpacing.medium)
                .padding(.bottom, BooSpacing.small)

            configuration.content
        }
        .background(
            RoundedRectangle(cornerRadius: BooRadius.card)
                .fill(Color.booBackgroundElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BooRadius.card)
                .stroke(Color.booBorder, lineWidth: 1)
        )
    }
}
