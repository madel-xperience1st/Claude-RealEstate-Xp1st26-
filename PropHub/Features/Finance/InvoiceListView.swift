import SwiftUI

/// Premium invoice list with download capability.
struct InvoiceListView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @State private var downloadingInvoiceId: String?

    var body: some View {
        List {
            ForEach(viewModel.invoices) { invoice in
                InvoiceRow(
                    invoice: invoice,
                    isDownloading: downloadingInvoiceId == invoice.id,
                    onDownload: { Task { await downloadPDF(invoice) } }
                )
                .listRowBackground(Color.brandWhite)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .emptyState(
            viewModel.invoices.isEmpty && !viewModel.isLoading,
            icon: "doc.text",
            title: "No Invoices",
            message: "No invoices found."
        )
    }

    private func downloadPDF(_ invoice: Invoice) async {
        downloadingInvoiceId = invoice.id
        do {
            let data = try await viewModel.downloadInvoicePDF(invoiceId: invoice.id)
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(invoice.invoiceNumber).pdf")
            try data.write(to: url)
            await MainActor.run {
                let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.present(activityVC, animated: true)
                }
            }
        } catch {
            print("[PropHub] PDF download failed: \(error.localizedDescription)")
        }
        downloadingInvoiceId = nil
    }
}

/// Premium invoice row.
struct InvoiceRow: View {
    let invoice: Invoice
    let isDownloading: Bool
    let onDownload: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(invoice.invoiceNumber)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.brandCharcoal)
                Text(invoice.date.mediumFormatted)
                    .font(.caption)
                    .foregroundStyle(.brandGray)
            }

            Spacer()

            CurrencyText(amount: invoice.amount, style: .body)
                .foregroundStyle(.brandCharcoal)

            StatusBadge.forInstallmentStatus(invoice.status)

            if invoice.pdfUrl != nil {
                Button(action: onDownload) {
                    if isDownloading {
                        ProgressView()
                            .scaleEffect(0.7)
                            .tint(.brandGold)
                    } else {
                        Image(systemName: "arrow.down.doc")
                            .foregroundStyle(.brandNavy)
                    }
                }
                .disabled(isDownloading)
            }
        }
        .padding(.vertical, 6)
    }
}
