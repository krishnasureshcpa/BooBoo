import SwiftUI

struct WelcomeView: View {
    @Environment(AppState.self) private var state
    @State private var phase: WelcomePhase = .greeting

    enum WelcomePhase {
        case greeting
        case tour
        case done
    }

    var body: some View {
        ZStack {
            Color.booBackground.ignoresSafeArea()

            switch phase {
            case .greeting: greetingView
            case .tour: tourView
            case .done: Color.clear
            }
        }
        .frame(minWidth: 600, minHeight: 500)
    }

    private var greetingView: some View {
        VStack(spacing: BooSpacing.xlarge) {
            Spacer()

            AnimatedGhost(size: 120)

            Text("BooBoo")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.booTextPrimary)

            Text("Your friendly macOS ghost.\nI keep your Mac clean, compliant, and out of trouble.")
                .font(.booBody)
                .foregroundColor(.booTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()

            VStack(spacing: BooSpacing.medium) {
                Button(action: { withAnimation { phase = .tour } }) {
                    Text("Take a Tour")
                        .font(.booHeadline)
                        .frame(minWidth: 200)
                        .padding(.vertical, BooSpacing.small)
                }
                .buttonStyle(.borderedProminent)
                .tint(.booAccent)

                Button(action: { state.finishOnboarding() }) {
                    Text("Skip, I know my way around")
                        .font(.booCallout)
                        .foregroundColor(.booTextTertiary)
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(BooSpacing.xxlarge)
    }

    private var tourView: some View {
        BooBooTourView(onComplete: { state.finishOnboarding() })
    }
}

struct AnimatedGhost: View {
    let size: CGFloat
    @State private var floatUp = false
    @State private var pulseIn = false
    @State private var wobble = false

    var body: some View {
        Image(systemName: "ghost.fill")
            .font(.system(size: size * 0.6))
            .foregroundColor(.booAccent.opacity(0.9))
            .frame(width: size, height: size)
            .scaleEffect(pulseIn ? 1.0 : 0.95)
            .offset(y: floatUp ? -8 : 8)
            .rotationEffect(.degrees(wobble ? 4 : -4))
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    floatUp.toggle()
                }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulseIn.toggle()
                }
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(0.3)) {
                    wobble.toggle()
                }
            }
    }
}

struct BooBooTourView: View {
    let onComplete: () -> Void
    @State private var currentStep = 0

    private let steps: [(title: String, icon: String, text: String)] = [
        ("Dashboard", "square.grid.2x2",
         "The Dashboard shows your Mac's security score at a glance. Green means good. Red means something needs attention."),
        ("Compliance Rules", "checkmark.shield",
         "Under Compliance, you'll find 50+ CIS Level 1 rules. Search, filter by severity, or see only the failing ones."),
        ("Fix & Remediate", "wrench.and.screwdriver",
         "Select any failing rule and click Fix. BooBoo explains exactly what it will change before touching your system."),
        ("Need Help?", "questionmark.bubble",
         "Stuck? Open the assistant from the menu bar. Ask me anything — I'll guide you to the right place or search the web for answers."),
    ]

    var body: some View {
        VStack(spacing: BooSpacing.large) {
            Spacer()

            AnimatedGhost(size: 60)

            Text(steps[currentStep].title)
                .font(.booTitle2)
                .foregroundColor(.booTextPrimary)

            Image(systemName: steps[currentStep].icon)
                .font(.system(size: 40))
                .foregroundColor(.booAccent)
                .padding(.vertical, BooSpacing.small)

            Text(steps[currentStep].text)
                .font(.booBody)
                .foregroundColor(.booTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, BooSpacing.xxlarge)
                .frame(maxWidth: 500)

            Spacer()

            HStack(spacing: BooSpacing.small) {
                ForEach(0..<steps.count, id: \.self) { i in
                    Circle()
                        .fill(i == currentStep ? Color.booAccent : Color.booTextTertiary.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            HStack(spacing: BooSpacing.medium) {
                if currentStep > 0 {
                    Button(action: { withAnimation { currentStep -= 1 } }) {
                        Text("Back")
                            .font(.booCallout)
                            .frame(minWidth: 100)
                    }
                    .buttonStyle(.bordered)
                }

                if currentStep < steps.count - 1 {
                    Button(action: { withAnimation { currentStep += 1 } }) {
                        Text("Next")
                            .font(.booHeadline)
                            .frame(minWidth: 100)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.booAccent)
                } else {
                    Button(action: onComplete) {
                        Text("Get Started")
                            .font(.booHeadline)
                            .frame(minWidth: 140)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.booAccent)
                }
            }

            Spacer()
        }
        .padding(BooSpacing.xxlarge)
    }
}
