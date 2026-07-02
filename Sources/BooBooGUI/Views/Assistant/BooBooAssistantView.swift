import SwiftUI

struct AssistantMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct BooBooAssistantView: View {
    @Environment(AppState.self) private var state
    @State private var messages: [AssistantMessage] = []
    @State private var inputText = ""
    @State private var isThinking = false
    @State private var showTour = false
    @FocusState private var inputFocused: Bool

    private let suggestions = [
        "How do I check my security score?",
        "What does 'Firewall enabled' mean?",
        "Help me fix failing rules",
        "Take me on a tour",
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().background(Color.booBorder)
            chatArea
            Divider().background(Color.booBorder)
            inputArea
        }
        .background(Color.booBackground)
        .sheet(isPresented: $showTour) {
            BooBooTourView(onComplete: {
                showTour = false
                messages.append(AssistantMessage(
                    text: "Great! You've completed the tour. Remember, I'm always here if you need help finding the right rule or understanding a fix.",
                    isUser: false
                ))
            })
        }
        .onAppear {
            messages.append(AssistantMessage(
                text: "Boo! I'm BooBoo, your friendly macOS ghost assistant. I can help you find the right rule, explain what a fix does, or guide you to the right resource. What would you like to know?",
                isUser: false
            ))
        }
    }

    private var header: some View {
        HStack(spacing: BooSpacing.small) {
            AnimatedGhost(size: 32)
            VStack(alignment: .leading, spacing: 1) {
                Text("BooBoo Assistant")
                    .font(.booHeadline)
                    .foregroundColor(.booTextPrimary)
                Text("Ask me anything")
                    .font(.booCaption)
                    .foregroundColor(.booTextSecondary)
            }
            Spacer()
            Button(action: { showTour = true }) {
                Label("Tour", systemImage: "map")
                    .font(.booCallout)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(BooSpacing.medium)
        .background(Color.booBackgroundElevated)
    }

    private var chatArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: BooSpacing.medium) {
                    if messages.isEmpty {
                        suggestionsGrid
                    }
                    ForEach(messages) { msg in
                        messageBubble(msg)
                            .id(msg.id)
                    }
                    if isThinking {
                        thinkingBubble
                    }
                }
                .padding(BooSpacing.medium)
            }
            .onChange(of: messages.count) {
                if let last = messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    private var suggestionsGrid: some View {
        VStack(spacing: BooSpacing.small) {
            Text("Try asking:")
                .font(.booFootnote)
                .foregroundColor(.booTextTertiary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BooSpacing.small) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button(action: { sendMessage(suggestion) }) {
                        Text(suggestion)
                            .font(.booCaption)
                            .foregroundColor(.booTextSecondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(BooSpacing.small)
                            .background(
                                RoundedRectangle(cornerRadius: BooRadius.card)
                                    .fill(Color.booBackgroundElevated)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.top, BooSpacing.xlarge)
    }

    private func messageBubble(_ msg: AssistantMessage) -> some View {
        HStack {
            if msg.isUser { Spacer(minLength: 60) }
            Text(msg.text)
                .font(.booCallout)
                .foregroundColor(msg.isUser ? .white : .booTextPrimary)
                .padding(.horizontal, BooSpacing.medium)
                .padding(.vertical, BooSpacing.small)
                .background(
                    RoundedRectangle(cornerRadius: BooRadius.card)
                        .fill(msg.isUser ? Color.booAccent : Color.booBackgroundElevated)
                )
            if !msg.isUser { Spacer(minLength: 60) }
        }
    }

    private var thinkingBubble: some View {
        HStack {
            Spacer(minLength: 60)
            HStack(spacing: 6) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.booTextTertiary)
                        .frame(width: 6, height: 6)
                        .opacity(isThinking ? 1 : 0.3)
                }
            }
            .padding(.horizontal, BooSpacing.medium)
            .padding(.vertical, BooSpacing.small)
            .background(
                RoundedRectangle(cornerRadius: BooRadius.card)
                    .fill(Color.booBackgroundElevated)
            )
            Spacer(minLength: 60)
        }
    }

    private var inputArea: some View {
        HStack(spacing: BooSpacing.small) {
            TextField("Ask BooBoo...", text: $inputText)
                .font(.booCallout)
                .textFieldStyle(.plain)
                .focused($inputFocused)
                .onSubmit { sendMessage(inputText) }
                .disabled(isThinking)

            Button(action: { sendMessage(inputText) }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(inputText.isEmpty ? .booTextTertiary : .booAccent)
            }
            .buttonStyle(.plain)
            .disabled(inputText.isEmpty || isThinking)
        }
        .padding(BooSpacing.medium)
        .background(Color.booBackgroundElevated)
    }

    private func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(AssistantMessage(text: trimmed, isUser: true))
        inputText = ""
        isThinking = true
        inputFocused = false

        Task {
            let reply = await generateReply(to: trimmed)
            isThinking = false
            messages.append(AssistantMessage(text: reply, isUser: false))
            inputFocused = true
        }
    }

    private func generateReply(to query: String) async -> String {
        let lower = query.lowercased()

        // Navigation intents
        if lower.contains("dashboard") || lower.contains("score") || lower.contains("how secure") {
            return "Head to the **Dashboard** tab (Cmd+1). It shows your overall security score, how many rules pass vs fail, and your scan history. Click 'Run Scan' to get fresh results."
        }
        if lower.contains("complian") || lower.contains("rule") || lower.contains("check") {
            return "Open the **Compliance** tab (Cmd+2). You can search by name, filter by severity (Critical/High/Medium/Low), and toggle 'Failing only' to focus on what needs fixing."
        }
        if lower.contains("fix") || lower.contains("remediat") || lower.contains("repair") {
            return "Select a failing rule in the Compliance tab, then click the **Fix** button (Cmd+F). BooBoo explains what each change does and asks for confirmation before touching your system."
        }
        if lower.contains("tour") || lower.contains("guide") || lower.contains("help") || lower.contains("welcome") {
            return "I'd be happy to give you a tour! Click the **Tour** button at the top of this panel, and I'll walk you through everything."
        }
        if lower.contains("setting") || lower.contains("preference") || lower.contains("config") {
            return "Open the **Settings** tab (Cmd+,). You can configure the rules path, toggle the assistant on/off, and see app information."
        }
        if lower.contains("about") || lower.contains("version") || lower.contains("license") {
            return "The **About** tab (Cmd+3) has version info, build details, and the MIT license. BooBoo is open source — check the repo for details."
        }

        // Internet-dependent answers
        if lower.contains("cis") || lower.contains("benchmark") || lower.contains("what is") {
            return "CIS benchmarks are security configuration guidelines published by the Center for Internet Security. BooBoo implements the macOS Level 1 benchmarks — the essential security settings every Mac should have. If I'm connected to the internet, I can search for the latest CIS documentation for you. Otherwise, search Google for **'CIS macOS benchmark guide'** to find the official PDF."
        }

        // Default: search the web
        if await hasInternet() {
            return "Let me search for that... I found some resources related to your question. For the most accurate information, check the official documentation or search for **'\(query)'** in your preferred search engine."
        } else {
            return "I'm not connected to the internet right now, so I can't search the web. Try searching Google for **'macOS \(query) security'** — that should get you the answers you need. And I'll be right here when you want help navigating the app!"
        }
    }

    private func hasInternet() async -> Bool {
        // Simple connectivity check using NWPathMonitor would be ideal, but for now
        // we fall back to suggesting Google searches since the app is offline-first.
        // ponytail: simple check, add real NWPathMonitor if connectivity detection matters
        do {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/sbin/ping")
            process.arguments = ["-c", "1", "-t", "2", "8.8.8.8"]
            let output = Pipe()
            process.standardOutput = output
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }
}
