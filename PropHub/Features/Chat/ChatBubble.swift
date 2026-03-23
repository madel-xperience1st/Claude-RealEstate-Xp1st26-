import SwiftUI

/// Premium chat bubble with navy/gold styling.
struct ChatBubble: View {
    let message: ChatMessage
    let onQuickReply: (QuickReply) -> Void

    var body: some View {
        HStack {
            if message.sender == .user { Spacer(minLength: 60) }

            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 6) {
                Text(message.text)
                    .font(.subheadline)
                    .foregroundStyle(message.sender == .user ? .white : .brandCharcoal)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(bubbleColor, in: BubbleShape(isUser: message.sender == .user))

                if let quickReplies = message.quickReplies, !quickReplies.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(quickReplies, id: \.value) { reply in
                            Button {
                                onQuickReply(reply)
                            } label: {
                                Text(reply.label)
                                    .font(.caption)
                                    .foregroundStyle(.brandNavy)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(
                                        Capsule()
                                            .stroke(Color.brandGold, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }

                Text(message.timestamp.shortDateTimeFormatted)
                    .font(.system(size: 10))
                    .foregroundStyle(.brandGray)
            }

            if message.sender != .user { Spacer(minLength: 60) }
        }
    }

    private var bubbleColor: Color {
        switch message.sender {
        case .user: return .brandNavy
        case .agent: return .brandPlatinum
        case .system: return Color(hex: "E8E8E5")
        }
    }
}

/// Rounded bubble shape with tail.
struct BubbleShape: Shape {
    let isUser: Bool

    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 18
        var path = Path()
        let corners: UIRectCorner = isUser
            ? [.topLeft, .topRight, .bottomLeft]
            : [.topLeft, .topRight, .bottomRight]
        path.addRoundedRect(in: rect, cornerRadii: RectangleCornerRadii(
            topLeading: radius,
            bottomLeading: isUser ? radius : 4,
            bottomTrailing: isUser ? 4 : radius,
            topTrailing: radius
        ))
        return path
    }
}

/// Simple flow layout for quick reply buttons.
struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrangeSubviews(proposal: proposal, subviews: subviews).size
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
            positions: positions, sizes: sizes,
            size: CGSize(width: maxWidth, height: currentY + rowHeight)
        )
    }

    struct ArrangementResult {
        let positions: [CGPoint]
        let sizes: [CGSize]
        let size: CGSize
    }
}
