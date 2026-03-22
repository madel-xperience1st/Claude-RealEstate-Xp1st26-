import Foundation

/// View model managing the Agentforce chat session and message exchange.
@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isTyping = false
    @Published var isLoading = false
    @Published var error: APIError?
    @Published var sessionId: String?

    private let apiService = APIService.shared
    private let userSession = UserSession.shared

    /// Starts a new chat session with the Agentforce agent.
    func startSession() async {
        guard let contactId = userSession.contactId,
              let projectId = userSession.activeProjectId else { return }

        isLoading = true

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

    /// Sends a text message to the agent and receives the response.
    func sendMessage(_ text: String, quickReplyValue: String? = nil) async {
        guard let sessionId = sessionId else { return }

        let userMessage = ChatMessage(text: text, sender: .user)
        messages.append(userMessage)
        isTyping = true

        do {
            let response: ChatMessageResponse = try await apiService.request(
                .sendChatMessage(sessionId: sessionId, text: text, quickReplyValue: quickReplyValue)
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
        guard let sessionId = sessionId else { return }
        do {
            let _: [String: String] = try await apiService.request(
                .endChatSession(sessionId: sessionId)
            )
        } catch {
            // Session cleanup failure is non-critical
        }
        self.sessionId = nil
        messages.removeAll()
    }
}
