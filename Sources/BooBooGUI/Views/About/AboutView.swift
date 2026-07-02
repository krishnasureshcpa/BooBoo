import SwiftUI
import BooBooCore

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: BooSpacing.xxlarge) {
                heroSection
                infoSection
                licenseSection
            }
            .padding(BooSpacing.xlarge)
        }
        .background(Color.booBackground)
    }

    private var heroSection: some View {
        VStack(spacing: BooSpacing.small) {
            Image(systemName: "ghost.fill")
                .font(.system(size: 64))
                .foregroundColor(.booAccent)

            Text("BooBoo")
                .font(.booLargeTitle)
                .foregroundColor(.booTextPrimary)

            VStack(spacing: 2) {
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
                .multilineTextAlignment(.center)
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: BooSpacing.small) {
            GroupBox {
                VStack(alignment: .leading, spacing: BooSpacing.medium) {
                    aboutRow(label: "Bundle ID", value: "com.sgkrishna.booboo")
                    Divider().background(Color.booBorder)
                    aboutRow(label: "Architecture", value: "Apple Silicon (arm64)")
                    Divider().background(Color.booBorder)
                    aboutRow(label: "Minimum OS", value: "macOS 14.0")
                    Divider().background(Color.booBorder)
                    aboutRow(label: "License", value: "MIT")
                }
                .padding(BooSpacing.medium)
            } label: {
                Label("About", systemImage: "info.circle")
                    .font(.booTitle3)
                    .foregroundColor(.booTextPrimary)
            }
            .groupBoxStyle(BooGroupBoxStyle())
        }
    }

    private var licenseSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: BooSpacing.small) {
                Text("MIT License")
                    .font(.booHeadline)
                    .foregroundColor(.booTextPrimary)

                Text("Copyright (c) 2026 krishnasureshcpa")
                    .font(.booCallout)
                    .foregroundColor(.booTextSecondary)

                Text("""
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
""")
                    .font(.booMonoCaption)
                    .foregroundColor(.booTextTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(BooSpacing.medium)
        } label: {
            Label("License", systemImage: "doc.text")
                .font(.booTitle3)
                .foregroundColor(.booTextPrimary)
        }
        .groupBoxStyle(BooGroupBoxStyle())
    }

    private func aboutRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.booCallout)
                .foregroundColor(.booTextSecondary)
            Spacer()
            Text(value)
                .font(.booCallout)
                .foregroundColor(.booTextPrimary)
        }
    }
}
