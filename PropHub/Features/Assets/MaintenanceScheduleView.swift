import SwiftUI

/// Displays upcoming and past maintenance records for an asset.
struct MaintenanceScheduleView: View {
    let records: [MaintenanceRecord]
    let assetId: String

    var body: some View {
        List {
            if !upcomingRecords.isEmpty {
                Section(NSLocalizedString("upcoming_maintenance", comment: "")) {
                    ForEach(upcomingRecords) { record in
                        MaintenanceRow(record: record)
                    }
                }
            }

            if !pastRecords.isEmpty {
                Section(NSLocalizedString("past_maintenance", comment: "")) {
                    ForEach(pastRecords) { record in
                        MaintenanceRow(record: record)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if records.isEmpty {
                EmptyStateView(
                    icon: "wrench",
                    title: NSLocalizedString("no_maintenance_title", comment: ""),
                    message: NSLocalizedString("no_maintenance_message", comment: "")
                )
            }
        }
    }

    private var upcomingRecords: [MaintenanceRecord] {
        records.filter { !$0.scheduledDate.isPast }
            .sorted { $0.scheduledDate < $1.scheduledDate }
    }

    private var pastRecords: [MaintenanceRecord] {
        records.filter { $0.scheduledDate.isPast }
            .sorted { $0.scheduledDate > $1.scheduledDate }
    }
}

/// Row for a maintenance record.
struct MaintenanceRow: View {
    let record: MaintenanceRecord

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.workOrderNumber)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(record.scheduledDate.mediumFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let technician = record.technicianName {
                    Label(technician, systemImage: "person.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                StatusBadge.forServiceStatus(record.status)
                if let type = record.type {
                    Text(type)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
