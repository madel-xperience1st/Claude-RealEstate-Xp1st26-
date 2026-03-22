import SwiftUI

/// Displays a formatted currency amount respecting the active project's currency.
struct CurrencyText: View {
    let amount: Double
    let currencyCode: String
    let style: Style

    enum Style {
        case title
        case body
        case caption
    }

    init(amount: Double, currencyCode: String = "AED", style: Style = .body) {
        self.amount = amount
        self.currencyCode = currencyCode
        self.style = style
    }

    var body: some View {
        Text(formattedAmount)
            .font(font)
            .fontWeight(style == .title ? .bold : .regular)
            .accessibilityLabel("\(formattedAmount)")
    }

    private var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currencyCode) \(amount)"
    }

    private var font: Font {
        switch style {
        case .title: return .title2
        case .body: return .body
        case .caption: return .caption
        }
    }
}
