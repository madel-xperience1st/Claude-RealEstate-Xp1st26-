import SwiftUI

/// In-app chat interface connecting to Salesforce Agentforce.
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                ChatBubble(message: message) { quickReply in
                                    Task {
                                        await viewModel.sendMessage(
                                            quickReply.label,
                                            quickReplyValue: quickReply.value
                                        )
                                    }
                                }
                                .id(message.id)
                            }

                            if viewModel.isTyping {
                                HStack {
                                    TypingIndicator()
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        withAnimation {
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }

                Divider()

                // Input Bar
                HStack(spacing: 12) {
                    TextField(
                        NSLocalizedString("chat_placeholder", comment: ""),
                        text: $messageText,
                        axis: .vertical
                    )
                    .textFieldStyle(.plain)
                    .lineLimit(1...4)
                    .focused($isInputFocused)
                    .accessibilityLabel(NSLocalizedString("chat_input", comment: ""))

                    Button {
                        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !text.isEmpty else { return }
                        messageText = ""
                        Task { await viewModel.sendMessage(text) }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel(NSLocalizedString("send_message", comment: ""))
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
            }
            .navigationTitle(NSLocalizedString("tab_chat", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Escalate to live agent
                    } label: {
                        Image(systemName: "person.fill.questionmark")
                    }
                    .accessibilityLabel(NSLocalizedString("escalate_agent", comment: ""))
                }
            }
            .loading(viewModel.isLoading)
            .task {
                if viewModel.sessionId == nil {
                    await viewModel.startSession()
                }
            }
        }
    }
}

/// Typing indicator animation.
struct TypingIndicator: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 8, height: 8)
                    .opacity(animating ? 0.3 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 16))
        .onAppear { animating = true }
        .accessibilityLabel(NSLocalizedString("agent_typing", comment: ""))
    }
}
