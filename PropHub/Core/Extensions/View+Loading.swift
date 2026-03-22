import SwiftUI

extension View {
    /// Overlays a loading indicator when the condition is true.
    func loading(_ isLoading: Bool) -> some View {
        overlay {
            if isLoading {
                LoadingOverlay()
            }
        }
    }

    /// Shows an empty state view when the condition is true.
    func emptyState(
        _ isEmpty: Bool,
        icon: String = "tray",
        title: String,
        message: String
    ) -> some View {
        overlay {
            if isEmpty {
                EmptyStateView(icon: icon, title: title, message: message)
            }
        }
    }

    /// Shows an error alert with retry capability.
    func errorAlert(
        error: Binding<APIError?>,
        retryAction: @escaping () -> Void
    ) -> some View {
        alert(
            NSLocalizedString("error_title", comment: ""),
            isPresented: Binding(
                get: { error.wrappedValue != nil },
                set: { if !$0 { error.wrappedValue = nil } }
            ),
            presenting: error.wrappedValue
        ) { _ in
            Button(NSLocalizedString("try_again", comment: ""), action: retryAction)
            Button(NSLocalizedString("dismiss", comment: ""), role: .cancel) {}
        } message: { apiError in
            Text(apiError.localizedDescription)
        }
    }
}
