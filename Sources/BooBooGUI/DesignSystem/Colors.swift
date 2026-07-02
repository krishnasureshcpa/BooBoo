import SwiftUI

/// BooBoo Design System — Colors
///
/// Dark mode primary palette: haunted purple-black background with ghost white text,
/// ectoplasm purple accent, spectral cyan secondary, wisp amber warm accent,
/// slime green for success, blood red for danger.
///
/// Light mode: lavender-tinted white backgrounds with deep purple-black text.
extension Color {
    // MARK: Dark Mode Backgrounds (primary mode)
    static let booBackground = Color(red: 10/255, green: 6/255, blue: 18/255)       // #0A0612 haunted purple-black
    static let booBackgroundElevated = Color(red: 20/255, green: 14/255, blue: 32/255) // #140E20 card/sidebar
    static let booBackgroundHover = Color(red: 30/255, green: 21/255, blue: 48/255)    // #1E1530 hover

    // MARK: Light Mode Backgrounds
    static let booLightBackground = Color(red: 248/255, green: 244/255, blue: 255/255)         // #F8F4FF lavender white
    static let booLightBackgroundElevated = Color(red: 238/255, green: 230/255, blue: 248/255)  // #EEE6F8 card
    static let booLightBackgroundHover = Color(red: 224/255, green: 212/255, blue: 240/255)     // #E0D4F0 hover

    // MARK: Text
    static let booTextPrimary = Color(red: 240/255, green: 230/255, blue: 255/255)     // #F0E6FF ghost white
    static let booTextSecondary = Color(red: 184/255, green: 168/255, blue: 232/255)    // #B8A8E8 dim ghost
    static let booTextTertiary = Color(red: 122/255, green: 106/255, blue: 154/255)     // #7A6A9A muted
    static let booLightTextPrimary = Color(red: 26/255, green: 16/255, blue: 40/255)    // #1A1028 deep purple-black
    static let booLightTextSecondary = Color(red: 74/255, green: 56/255, blue: 88/255)  // #4A3858 medium purple

    // MARK: Accents
    static let booAccent = Color(red: 139/255, green: 127/255, blue: 214/255)           // #8B7FD6 ectoplasm purple
    static let booAccentBright = Color(red: 184/255, green: 168/255, blue: 255/255)     // #B8A8FF bright ectoplasm
    static let booSpectral = Color(red: 96/255, green: 240/255, blue: 224/255)          // #60F0E0 spectral cyan
    static let booWisp = Color(red: 255/255, green: 214/255, blue: 165/255)             // #FFD6A5 warm amber

    // MARK: Semantic
    static let booSuccess = Color(red: 143/255, green: 221/255, blue: 143/255)          // #8FDD8F slime green
    static let booWarning = Color(red: 255/255, green: 184/255, blue: 77/255)           // #FFB84D warning amber
    static let booDanger = Color(red: 255/255, green: 107/255, blue: 107/255)           // #FF6B6B blood red

    // MARK: Primary/Secondary shortcuts
    static let booPrimary = Color.booAccent
    static let booSecondary = Color.booSpectral

    // MARK: Borders (dark mode)
    static let booBorder = Color(red: 180/255, green: 150/255, blue: 220/255, opacity: 0.15)
    static let booBorderStrong = Color(red: 180/255, green: 150/255, blue: 220/255, opacity: 0.30)
}