import Foundation

/// BooBoo Design System — Spacing
///
/// 4-point grid system:
///   4pt — xsmall (icon padding, tight grouping)
///   8pt — small (inline spacing, label gaps)
///  16pt — medium (card padding, section gaps)
///  24pt — large (section headers, form groups)
///  32pt — xlarge (page margins, major sections)
///  48pt — xxlarge (hero spacing, major dividers)
enum BooSpacing {
    static let xsmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xlarge: CGFloat = 32
    static let xxlarge: CGFloat = 48
}

/// BooBoo Design System — Corner Radii
///
/// Window-level: 10pt, Card-level: 12pt, Button-level: 8pt, Input-level: 6pt
enum BooRadius {
    static let window: CGFloat = 10
    static let card: CGFloat = 12
    static let button: CGFloat = 8
    static let input: CGFloat = 6
    static let small: CGFloat = 4
}

/// BooBoo Design System — Layout Constants
enum BooLayout {
    static let sidebarWidth: CGFloat = 240
    static let toolbarHeight: CGFloat = 44
    static let statusBarHeight: CGFloat = 28
    static let ghostSmallSize: CGFloat = 48
    static let ghostLargeSize: CGFloat = 120
    static let ghostMediumSize: CGFloat = 80
    static let ghostTinySize: CGFloat = 16
}