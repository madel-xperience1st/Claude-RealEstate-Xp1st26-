import SwiftUI

/// Chat bubble component with support for quick reply buttons.
struct ChatBubble: View {
    let message: ChatMessage
    let onQuickReply: (QuickReply) -> Void

    var body: some View {
        HStack {
            if message.sender == .user { Spacer(minLength: 60) }

            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 6) {
                Text(message.text)
                    .font(.body)
                    .foregroundStyle(message.sender == .user ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        bubbleColor,
                        in: RoundedRectangle(cornerRadius: 18)
                    )

                // Quick replies
                if let quickReplies = message.quickReplies, !quickReplies.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(quickReplies, id: \.value) { reply in
                            Button {
                                onQuickReply(reply)
                            } label: {
                                Text(reply.label)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .stroke(Color.accentColor, lineWidth: 1)
                                    )
                            }
                            .accessibilityLabel(reply.label)
                        }
                    }
                }

                // Timestamp
                Text(message.timestamp.shortDateTimeFormatted)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if message.sender != .user { Spacer(minLength: 60) }
        }
        .accessibilityElement(children: .combine)
    }

    private var bubbleColor: Color {
        switch message.sender {
        case .user:
            return .blue
        case .agent:
            return Color(.systemGray5)
        case .system:
            return Color(.systemGray6)
        }
    }
}

/// Simple flow layout for quick reply buttons.
struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(result.sizes[index])
            )
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> ArrangementResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            sizes.append(size)
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return ArrangementResult(
            positions: positions,
            sizes: sizes,
            size: CGSize(width: maxWidth, height: currentY + rowHeight)
        )
    }

    struct ArrangementResult {
        let positions: [CGPoint]
        let sizes: [CGSize]
        let size: CGSize
    }
}
