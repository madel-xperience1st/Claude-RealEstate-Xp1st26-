import Foundation

extension Date {
    /// Formats the date as a localized medium-style string (e.g., "Mar 22, 2026").
    var mediumFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.timeZone = .current
        return formatter.string(from: self)
    }

    /// Formats the date as a localized short date with time (e.g., "3/22/26 2:30 PM").
    var shortDateTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter.string(from: self)
    }

    /// Returns the number of days from today (negative = past, positive = future).
    var daysFromToday: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: self)).day ?? 0
    }

    /// Returns a human-readable relative description (e.g., "3 days ago", "in 2 weeks").
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Whether the date is in the past.
    var isPast: Bool {
        self < Date()
    }

    /// Whether the date falls within the next N days.
    func isWithinDays(_ days: Int) -> Bool {
        let target = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return self <= target && self >= Date()
    }
}
