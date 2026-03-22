import Foundation

/// Model representing a chat message in the Agentforce conversation.
struct ChatMessage: Codable, Identifiable, Equatable {
    let id: UUID
    let text: String
    let sender: Sender
    let timestamp: Date
    let quickReplies: [QuickReply]?

    enum Sender: String, Codable {
        case user
        case agent
        case system
    }

    init(text: String, sender: Sender, timestamp: Date = Date(), quickReplies: [QuickReply]? = nil) {
        self.id = UUID()
        self.text = text
        self.sender = sender
        self.timestamp = timestamp
        self.quickReplies = quickReplies
    }
}

/// Quick reply option returned by the Agentforce agent.
struct QuickReply: Codable, Equatable {
    let label: String
    let value: String
}

/// Response from creating a chat session.
struct ChatSessionResponse: Codable {
    let sessionId: String
    let welcomeMessage: String
}

/// Response from sending a chat message.
struct ChatMessageResponse: Codable {
    let messages: [ChatMessage]
}
