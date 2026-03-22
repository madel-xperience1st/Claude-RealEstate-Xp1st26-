import Foundation

/// View model managing the Agentforce chat session and message exchange.
/// In demo mode, uses intelligent mock responses from MockDataProvider.
@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isTyping = false
    @Published var isLoading = false
    @Published var error: APIError?
    @Published var sessionId: String?

    private let apiService = APIService.shared
    private let userSession = UserSession.shared
    private let settings = AppSettings.shared

    /// Starts a new chat session.
    func startSession() async {
        isLoading = true

        if settings.useMockData {
            try? await Task.sleep(nanoseconds: 300_000_000)
            sessionId = "demo-session-\(UUID().uuidString.prefix(8))"
            messages.append(ChatMessage(
                text: MockDataProvider.welcomeMessage,
                sender: .agent,
                quickReplies: [
                    QuickReply(label: "Unit status", value: "unit_status"),
                    QuickReply(label: "Payments", value: "view_payments"),
                    QuickReply(label: "Service request", value: "request_service"),
                    QuickReply(label: "New launches", value: "new_launches")
                ]
            ))
            isLoading = false
            return
        }

        guard let contactId = userSession.contactId,
              let projectId = userSession.activeProjectId else {
            isLoading = false
            return
        }

        do {
            let response: ChatSessionResponse = try await apiService.request(
                .createChatSession(contactId: contactId, projectId: projectId, unitId: nil)
            )
            sessionId = response.sessionId
            messages.append(ChatMessage(
                text: response.welcomeMessage,
                sender: .agent
            ))
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    /// Sends a text message and receives the response.
    func sendMessage(_ text: String, quickReplyValue: String? = nil) async {
        guard let _ = sessionId else { return }

        let userMessage = ChatMessage(text: text, sender: .user)
        messages.append(userMessage)
        isTyping = true

        if settings.useMockData {
            // Simulate realistic typing delay
            let delay = UInt64.random(in: 800_000_000...1_500_000_000)
            try? await Task.sleep(nanoseconds: delay)
            let responses = MockDataProvider.chatResponse(for: quickReplyValue ?? text)
            messages.append(contentsOf: responses)
            isTyping = false
            return
        }

        do {
            let response: ChatMessageResponse = try await apiService.request(
                .sendChatMessage(sessionId: sessionId ?? "", text: text, quickReplyValue: quickReplyValue)
            )
            messages.append(contentsOf: response.messages)
        } catch let apiError as APIError {
            error = apiError
            messages.append(ChatMessage(
                text: NSLocalizedString("chat_error", comment: ""),
                sender: .system
            ))
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isTyping = false
    }

    /// Ends the current chat session.
    func endSession() async {
        if !settings.useMockData, let sessionId = sessionId {
            do {
                let _: [String: String] = try await apiService.request(
                    .endChatSession(sessionId: sessionId)
                )
            } catch {
                // Session cleanup failure is non-critical
            }
        }
        self.sessionId = nil
        messages.removeAll()
    }
}
