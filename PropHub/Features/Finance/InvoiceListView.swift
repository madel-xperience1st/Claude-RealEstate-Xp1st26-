import SwiftUI

/// List of all invoices with download PDF capability.
struct InvoiceListView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @State private var downloadingInvoiceId: String?

    var body: some View {
        List {
            ForEach(viewModel.invoices) { invoice in
                InvoiceRow(
                    invoice: invoice,
                    isDownloading: downloadingInvoiceId == invoice.id,
                    onDownload: {
                        Task { await downloadPDF(invoice) }
                    }
                )
            }
        }
        .listStyle(.plain)
        .emptyState(
            viewModel.invoices.isEmpty && !viewModel.isLoading,
            icon: "doc.text",
            title: NSLocalizedString("no_invoices_title", comment: ""),
            message: NSLocalizedString("no_invoices_message", comment: "")
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
                // Share the downloaded PDF
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

/// Row displaying a single invoice.
struct InvoiceRow: View {
    let invoice: Invoice
    let isDownloading: Bool
    let onDownload: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(invoice.invoiceNumber)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(invoice.date.mediumFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            CurrencyText(amount: invoice.amount, style: .body)

            StatusBadge.forInstallmentStatus(invoice.status)

            if invoice.pdfUrl != nil {
                Button(action: onDownload) {
                    if isDownloading {
                        ProgressView()
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "arrow.down.doc")
                            .foregroundStyle(.blue)
                    }
                }
                .disabled(isDownloading)
                .accessibilityLabel(NSLocalizedString("download_pdf", comment: ""))
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
