import SwiftUI

/// BooBoo Design System — Typography
///
/// SF Pro Rounded for friendly, approachable UI (Apple-native feel).
/// SF Mono for terminal output, CLI-like text, and code blocks.
extension Font {
    static let booLargeTitle = Font.system(.largeTitle, design: .rounded).weight(.semibold)
    static let booTitle = Font.system(.title, design: .rounded).weight(.semibold)
    static let booTitle2 = Font.system(.title2, design: .rounded).weight(.medium)
    static let booTitle3 = Font.system(.title3, design: .rounded)
    static let booHeadline = Font.system(.headline, design: .rounded)
    static let booBody = Font.system(.body, design: .rounded)
    static let booCallout = Font.system(.callout, design: .rounded)
    static let booSubheadline = Font.system(.subheadline, design: .rounded)
    static let booFootnote = Font.system(.footnote, design: .rounded)
    static let booCaption = Font.system(.caption, design: .rounded)
    static let booCaption2 = Font.system(.caption2, design: .rounded)

    // Monospace for terminal output, commands, code
    static let booMonoBody = Font.system(.body, design: .monospaced)
    static let booMonoCaption = Font.system(.caption, design: .monospaced)
    static let booMonoFootnote = Font.system(.footnote, design: .monospaced)
}