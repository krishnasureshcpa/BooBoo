import SwiftUI

struct GhostPlaceholder: View {
    let size: CGFloat

    var body: some View {
        Image(systemName: "ghost.fill")
            .font(.system(size: size * 0.5))
            .foregroundColor(.booAccent)
            .frame(width: size, height: size)
    }
}
