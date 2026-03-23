import SwiftUI

/// Premium concierge chat interface.
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 14) {
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
                        .padding(16)
                    }
                    .background(Color.brandWhite)
                    .onChange(of: viewModel.messages.count) { _, _ in
                        withAnimation {
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }

                // Input Bar
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 12) {
                        TextField("Ask your concierge...", text: $messageText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .lineLimit(1...4)
                            .focused($isInputFocused)
                            .font(.subheadline)

                        Button {
                            let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !text.isEmpty else { return }
                            messageText = ""
                            Task { await viewModel.sendMessage(text) }
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundStyle(
                                    messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? .brandGray : .brandNavy
                                )
                        }
                        .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.white)
                }
            }
            .navigationTitle("Concierge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: {
                        Image(systemName: "person.fill.questionmark")
                            .foregroundStyle(.brandNavy)
                    }
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

/// Typing indicator with gold dots.
struct TypingIndicator: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.brandGold)
                    .frame(width: 7, height: 7)
                    .opacity(animating ? 0.3 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.6).repeatForever().delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.brandPlatinum, in: RoundedRectangle(cornerRadius: 18))
        .onAppear { animating = true }
    }
}
