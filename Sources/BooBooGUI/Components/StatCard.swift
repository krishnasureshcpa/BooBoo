import SwiftUI

struct StatCard: View {
    let label: String
    let value: String
    let icon: String
    var color: Color = .booAccent

    var body: some View {
        VStack(spacing: BooSpacing.small) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.booTitle)
                .foregroundColor(.booTextPrimary)

            Text(label)
                .font(.booCaption)
                .foregroundColor(.booTextTertiary)
        }
        .frame(maxWidth: .infinity)
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
}
