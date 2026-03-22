import Foundation

/// Provides realistic mock data for offline demos and development.
/// Enable by toggling `useMockData` in Settings or when no backend is configured.
enum MockDataProvider {

    // MARK: - Demo Projects

    static let demoProjects: [DemoProject] = [
        DemoProject(
            id: "proj-001",
            name: "Creek Harbour Residences",
            developer: "Emaar Properties",
            logoUrl: "https://logo.clearbit.com/emaar.com",
            brandPrimaryColor: "#1B4D8E",
            brandSecondaryColor: "#C5A572",
            description: "Luxury waterfront living in the heart of Dubai Creek Harbour with stunning views of the Burj Khalifa and Dubai skyline.",
            status: "Active",
            defaultCurrency: "AED",
            unitCount: 48
        ),
        DemoProject(
            id: "proj-002",
            name: "Villette Phase 3",
            developer: "SODIC",
            logoUrl: "https://logo.clearbit.com/sodic.com",
            brandPrimaryColor: "#2D5F2D",
            brandSecondaryColor: "#D4A843",
            description: "Premium villas and townhouses in New Cairo with world-class amenities and lush green spaces.",
            status: "Active",
            defaultCurrency: "EGP",
            unitCount: 32
        ),
        DemoProject(
            id: "proj-003",
            name: "DAMAC Lagoons",
            developer: "DAMAC Properties",
            logoUrl: "https://logo.clearbit.com/damacproperties.com",
            brandPrimaryColor: "#8B0000",
            brandSecondaryColor: "#FFD700",
            description: "Mediterranean-inspired townhouses with crystal lagoons, sandy beaches, and tropical water parks.",
            status: "Active",
            defaultCurrency: "AED",
            unitCount: 56
        ),
        DemoProject(
            id: "proj-004",
            name: "Jeddah Central",
            developer: "Roshn",
            logoUrl: "https://logo.clearbit.com/roshn.sa",
            brandPrimaryColor: "#006D6F",
            brandSecondaryColor: "#E8B74D",
            description: "A transformative waterfront community in the heart of Jeddah with modern urban living.",
            status: "Active",
            defaultCurrency: "SAR",
            unitCount: 24
        )
    ]

    // MARK: - Units

    static let units: [Unit] = [
        Unit(
            id: "unit-001",
            unitNumber: "A-1204",
            building: "Tower A — Creek View",
            floor: 12,
            areaSqm: 125.5,
            areaSqft: 1351.0,
            unitType: "2BR",
            status: "Delivered",
            handoverDate: dateFromString("2025-01-15"),
            totalPrice: 2_850_000,
            floorPlanUrl: nil,
            paymentCompletion: 0.85,
            projectName: "Creek Harbour Residences"
        ),
        Unit(
            id: "unit-002",
            unitNumber: "B-0803",
            building: "Tower B — Marina View",
            floor: 8,
            areaSqm: 78.3,
            areaSqft: 843.0,
            unitType: "1BR",
            status: "Under Construction",
            handoverDate: dateFromString("2026-09-30"),
            totalPrice: 1_650_000,
            floorPlanUrl: nil,
            paymentCompletion: 0.45,
            projectName: "Creek Harbour Residences"
        ),
        Unit(
            id: "unit-003",
            unitNumber: "C-PH01",
            building: "Tower C — Sky Collection",
            floor: 42,
            areaSqm: 310.0,
            areaSqft: 3337.0,
            unitType: "Penthouse",
            status: "Handover Ready",
            handoverDate: dateFromString("2025-06-01"),
            totalPrice: 12_500_000,
            floorPlanUrl: nil,
            paymentCompletion: 0.70,
            projectName: "Creek Harbour Residences"
        ),
        Unit(
            id: "unit-004",
            unitNumber: "V-105",
            building: "Orchid Cluster",
            floor: 0,
            areaSqm: 245.0,
            areaSqft: 2637.0,
            unitType: "Villa",
            status: "Delivered",
            handoverDate: dateFromString("2024-11-20"),
            totalPrice: 8_750_000,
            floorPlanUrl: nil,
            paymentCompletion: 1.0,
            projectName: "Creek Harbour Residences"
        )
    ]

    // MARK: - Installments

    static let installments: [Installment] = [
        Installment(id: "inst-001", milestoneName: "Booking Fee (10%)", dueDate: dateFromString("2023-03-15"), amount: 285_000, status: "Paid", paidDate: dateFromString("2023-03-14"), penaltyAmount: nil, sortOrder: 1),
        Installment(id: "inst-002", milestoneName: "Down Payment (10%)", dueDate: dateFromString("2023-06-15"), amount: 285_000, status: "Paid", paidDate: dateFromString("2023-06-10"), penaltyAmount: nil, sortOrder: 2),
        Installment(id: "inst-003", milestoneName: "1st Construction (10%)", dueDate: dateFromString("2023-12-01"), amount: 285_000, status: "Paid", paidDate: dateFromString("2023-11-28"), penaltyAmount: nil, sortOrder: 3),
        Installment(id: "inst-004", milestoneName: "2nd Construction (10%)", dueDate: dateFromString("2024-06-01"), amount: 285_000, status: "Paid", paidDate: dateFromString("2024-05-30"), penaltyAmount: nil, sortOrder: 4),
        Installment(id: "inst-005", milestoneName: "3rd Construction (15%)", dueDate: dateFromString("2024-12-01"), amount: 427_500, status: "Paid", paidDate: dateFromString("2024-11-29"), penaltyAmount: nil, sortOrder: 5),
        Installment(id: "inst-006", milestoneName: "Completion (15%)", dueDate: dateFromString("2025-03-01"), amount: 427_500, status: "Overdue", paidDate: nil, penaltyAmount: 12_825, sortOrder: 6),
        Installment(id: "inst-007", milestoneName: "Handover (20%)", dueDate: dateFromString("2025-06-01"), amount: 570_000, status: "Upcoming", paidDate: nil, penaltyAmount: nil, sortOrder: 7),
        Installment(id: "inst-008", milestoneName: "Post-Handover 1 (5%)", dueDate: dateFromString("2025-12-01"), amount: 142_500, status: "Pending", paidDate: nil, penaltyAmount: nil, sortOrder: 8),
        Installment(id: "inst-009", milestoneName: "Post-Handover 2 (5%)", dueDate: dateFromString("2026-06-01"), amount: 142_500, status: "Pending", paidDate: nil, penaltyAmount: nil, sortOrder: 9)
    ]

    // MARK: - Payment Summary

    static let paymentSummary = PaymentSummary(
        totalPrice: 2_850_000,
        paidAmount: 1_567_500,
        remainingBalance: 1_282_500,
        nextDueDate: dateFromString("2025-03-01"),
        overdueCount: 1,
        overdueAmount: 427_500
    )

    // MARK: - Invoices

    static let invoices: [Invoice] = [
        Invoice(id: "inv-001", invoiceNumber: "INV-2023-0042", date: dateFromString("2023-03-10"), amount: 285_000, status: "Paid", pdfUrl: "https://example.com/inv-001.pdf"),
        Invoice(id: "inv-002", invoiceNumber: "INV-2023-0089", date: dateFromString("2023-06-10"), amount: 285_000, status: "Paid", pdfUrl: "https://example.com/inv-002.pdf"),
        Invoice(id: "inv-003", invoiceNumber: "INV-2023-0156", date: dateFromString("2023-11-25"), amount: 285_000, status: "Paid", pdfUrl: "https://example.com/inv-003.pdf"),
        Invoice(id: "inv-004", invoiceNumber: "INV-2024-0034", date: dateFromString("2024-05-25"), amount: 285_000, status: "Paid", pdfUrl: "https://example.com/inv-004.pdf"),
        Invoice(id: "inv-005", invoiceNumber: "INV-2024-0178", date: dateFromString("2024-11-25"), amount: 427_500, status: "Paid", pdfUrl: "https://example.com/inv-005.pdf"),
        Invoice(id: "inv-006", invoiceNumber: "INV-2025-0012", date: dateFromString("2025-02-20"), amount: 427_500, status: "Overdue", pdfUrl: "https://example.com/inv-006.pdf")
    ]

    // MARK: - Service Requests

    static let serviceRequests: [ServiceRequest] = [
        ServiceRequest(id: "sr-001", caseNumber: "CS-002341", category: "HVAC", subject: "AC not cooling in master bedroom", status: "In Progress", createdDate: dateFromString("2025-03-10"), assignedTechnician: "Ahmed Al-Rashid", description: "The split AC in the master bedroom is running but not cooling. Temperature stays at 28°C.", preferredDate: dateFromString("2025-03-15"), relatedAssetId: "asset-001"),
        ServiceRequest(id: "sr-002", caseNumber: "CS-002298", category: "Plumbing", subject: "Kitchen sink slow drain", status: "Completed", createdDate: dateFromString("2025-02-28"), assignedTechnician: "Mohammed Farouk", description: "Kitchen sink draining very slowly, taking 5+ minutes.", preferredDate: nil, relatedAssetId: nil),
        ServiceRequest(id: "sr-003", caseNumber: "CS-002387", category: "Electrical", subject: "Living room dimmer switch not working", status: "Assigned", createdDate: dateFromString("2025-03-18"), assignedTechnician: "Khalid Nasser", description: "Dimmer switch in the living room only works on full brightness.", preferredDate: dateFromString("2025-03-22"), relatedAssetId: nil),
        ServiceRequest(id: "sr-004", caseNumber: "CS-002156", category: "General", subject: "Balcony door seal replacement", status: "Completed", createdDate: dateFromString("2025-01-15"), assignedTechnician: "Omar Saleh", description: "Wind noise through balcony sliding door. Seal appears worn.", preferredDate: nil, relatedAssetId: nil),
        ServiceRequest(id: "sr-005", caseNumber: "CS-002401", category: "Maintenance", subject: "Annual HVAC maintenance due", status: "New", createdDate: dateFromString("2025-03-20"), assignedTechnician: nil, description: "Scheduled annual maintenance for all AC units in the apartment.", preferredDate: dateFromString("2025-04-01"), relatedAssetId: nil)
    ]

    // MARK: - Assets

    static let assets: [Asset] = [
        Asset(id: "asset-001", name: "Samsung WindFree Split AC", serialNumber: "SAM-WF-2024-1204A", manufacturer: "Samsung", installDate: dateFromString("2024-10-15"), warrantyEndDate: dateFromString("2026-10-15"), warrantyStatus: "Active", category: "HVAC"),
        Asset(id: "asset-002", name: "Samsung WindFree Split AC", serialNumber: "SAM-WF-2024-1204B", manufacturer: "Samsung", installDate: dateFromString("2024-10-15"), warrantyEndDate: dateFromString("2026-10-15"), warrantyStatus: "Active", category: "HVAC"),
        Asset(id: "asset-003", name: "Bosch Serie 6 Refrigerator", serialNumber: "BSH-S6-2024-7823", manufacturer: "Bosch", installDate: dateFromString("2024-10-20"), warrantyEndDate: dateFromString("2025-10-20"), warrantyStatus: "Expiring Soon", category: "Appliance"),
        Asset(id: "asset-004", name: "Siemens Built-in Oven", serialNumber: "SIE-BO-2024-4521", manufacturer: "Siemens", installDate: dateFromString("2024-10-20"), warrantyEndDate: dateFromString("2026-10-20"), warrantyStatus: "Active", category: "Appliance"),
        Asset(id: "asset-005", name: "Grohe Essence Kitchen Mixer", serialNumber: "GRH-EK-2024-9012", manufacturer: "Grohe", installDate: dateFromString("2024-10-18"), warrantyEndDate: dateFromString("2029-10-18"), warrantyStatus: "Active", category: "Plumbing"),
        Asset(id: "asset-006", name: "Schneider Wiser Lighting Panel", serialNumber: "SCH-WL-2024-3345", manufacturer: "Schneider Electric", installDate: dateFromString("2024-10-15"), warrantyEndDate: dateFromString("2025-04-15"), warrantyStatus: "Expiring Soon", category: "Electrical"),
        Asset(id: "asset-007", name: "Roca In-Wash Inspira Smart Toilet", serialNumber: "ROC-IW-2024-6678", manufacturer: "Roca", installDate: dateFromString("2024-10-18"), warrantyEndDate: dateFromString("2024-10-18"), warrantyStatus: "Expired", category: "Plumbing")
    ]

    // MARK: - Warranty

    static func warranty(for assetId: String) -> Warranty {
        let asset = assets.first { $0.id == assetId }
        return Warranty(
            startDate: asset?.installDate ?? Date(),
            endDate: asset?.warrantyEndDate ?? Date(),
            status: asset?.warrantyStatus ?? "Unknown",
            provider: asset?.manufacturer,
            terms: "Standard manufacturer warranty covering defects in materials and workmanship under normal use. Does not cover damage from misuse, unauthorized modifications, or natural disasters. On-site service included within 48 hours of request."
        )
    }

    // MARK: - Maintenance Records

    static let maintenanceRecords: [MaintenanceRecord] = [
        MaintenanceRecord(id: "wo-001", workOrderNumber: "WO-2025-0342", scheduledDate: dateFromString("2025-04-01"), status: "Scheduled", technicianName: "Ahmed Al-Rashid", type: "Preventive"),
        MaintenanceRecord(id: "wo-002", workOrderNumber: "WO-2025-0298", scheduledDate: dateFromString("2025-03-10"), status: "In Progress", technicianName: "Ahmed Al-Rashid", type: "Corrective"),
        MaintenanceRecord(id: "wo-003", workOrderNumber: "WO-2024-1845", scheduledDate: dateFromString("2024-10-20"), status: "Completed", technicianName: "Faisal Mahmoud", type: "Installation"),
        MaintenanceRecord(id: "wo-004", workOrderNumber: "WO-2025-0156", scheduledDate: dateFromString("2025-01-20"), status: "Completed", technicianName: "Mohammed Farouk", type: "Corrective")
    ]

    // MARK: - Project Launches

    static let projectLaunches: [ProjectLaunch] = [
        ProjectLaunch(
            id: "launch-001",
            name: "Creek Harbour Tower D — Sky Collection",
            description: "The most exclusive residences in Creek Harbour. Premium 3BR and 4BR apartments with private pool access, panoramic views, and dedicated concierge services. Smart home automation throughout.",
            priceRangeMin: 4_500_000,
            priceRangeMax: 15_000_000,
            expectedHandover: "Q2 2028",
            heroImageUrls: nil,
            amenities: "[\"Infinity Pool\", \"Private Cinema\", \"Spa & Wellness Center\", \"Concierge Service\", \"Rooftop Lounge\", \"EV Charging\", \"Smart Home\", \"Children's Play Area\"]",
            launchDate: dateFromString("2025-04-15"),
            isActive: true
        ),
        ProjectLaunch(
            id: "launch-002",
            name: "Creek Harbour Retail Boulevard",
            description: "Premium retail and dining spaces along the waterfront promenade. Perfect for investors seeking high-yield commercial properties in Dubai's fastest-growing community.",
            priceRangeMin: 2_000_000,
            priceRangeMax: 8_000_000,
            expectedHandover: "Q4 2027",
            heroImageUrls: nil,
            amenities: "[\"Waterfront Promenade\", \"Valet Parking\", \"Central Courtyard\", \"Loading Docks\", \"24/7 Security\"]",
            launchDate: dateFromString("2025-05-01"),
            isActive: true
        )
    ]

    // MARK: - Chat Messages

    static let welcomeMessage = "Hello! Welcome to Creek Harbour Residences support. I'm your AI assistant. How can I help you today?"

    static func chatResponse(for input: String) -> [ChatMessage] {
        let lowered = input.lowercased()

        if lowered.contains("status") || lowered.contains("unit") {
            return [ChatMessage(
                text: "Your unit A-1204 in Tower A — Creek View is currently **Delivered**. It was handed over on January 15, 2025. Is there anything specific about your unit you'd like to know?",
                sender: .agent,
                quickReplies: [
                    QuickReply(label: "View payments", value: "view_payments"),
                    QuickReply(label: "Request service", value: "request_service"),
                    QuickReply(label: "Check warranty", value: "check_warranty")
                ]
            )]
        } else if lowered.contains("payment") || lowered.contains("owe") || lowered.contains("due") || lowered.contains("view_payments") {
            return [ChatMessage(
                text: "Here's your payment summary for unit A-1204:\n\n• Total Price: AED 2,850,000\n• Paid: AED 1,567,500 (55%)\n• Remaining: AED 1,282,500\n• ⚠️ Overdue: AED 427,500 (Completion milestone)\n\nWould you like to make a payment or discuss a payment plan?",
                sender: .agent,
                quickReplies: [
                    QuickReply(label: "Payment plan", value: "payment_plan"),
                    QuickReply(label: "Contact finance", value: "contact_finance")
                ]
            )]
        } else if lowered.contains("overdue") {
            return [ChatMessage(
                text: "You have **1 overdue installment**:\n\n• Completion (15%) — AED 427,500\n• Due: March 1, 2025\n• Days overdue: 21\n• Penalty: AED 12,825\n\nI recommend contacting our finance team to arrange payment and discuss penalty waiver options.",
                sender: .agent,
                quickReplies: [
                    QuickReply(label: "Contact finance", value: "contact_finance"),
                    QuickReply(label: "Talk to human", value: "escalate")
                ]
            )]
        } else if lowered.contains("service") || lowered.contains("fix") || lowered.contains("repair") || lowered.contains("request_service") || lowered.contains("ac") || lowered.contains("plumbing") {
            return [ChatMessage(
                text: "I can help you create a service request. What type of issue are you experiencing?",
                sender: .agent,
                quickReplies: [
                    QuickReply(label: "HVAC / AC", value: "service_hvac"),
                    QuickReply(label: "Plumbing", value: "service_plumbing"),
                    QuickReply(label: "Electrical", value: "service_electrical"),
                    QuickReply(label: "General", value: "service_general")
                ]
            )]
        } else if lowered.contains("warranty") || lowered.contains("check_warranty") {
            return [ChatMessage(
                text: "Here's a summary of your asset warranties for unit A-1204:\n\n✅ Samsung Split AC x2 — Active until Oct 2026\n⚠️ Bosch Refrigerator — Expiring Oct 2025\n✅ Siemens Oven — Active until Oct 2026\n⚠️ Schneider Lighting — Expiring Apr 2025\n❌ Roca Smart Toilet — Expired\n\nWould you like details on any specific asset?",
                sender: .agent,
                quickReplies: [
                    QuickReply(label: "Expiring items", value: "expiring_warranty"),
                    QuickReply(label: "Request maintenance", value: "request_service")
                ]
            )]
        } else if lowered.contains("launch") || lowered.contains("new project") || lowered.contains("upcoming") {
            return [ChatMessage(
                text: "We have exciting new launches coming up! 🎉\n\n**Creek Harbour Tower D — Sky Collection**\nPremium 3BR & 4BR with private pools\nFrom AED 4,500,000\nExpected: Q2 2028\n\nWould you like to join the priority waitlist?",
                sender: .agent,
                quickReplies: [
                    QuickReply(label: "Join waitlist", value: "join_waitlist"),
                    QuickReply(label: "More details", value: "launch_details")
                ]
            )]
        } else if lowered.contains("human") || lowered.contains("agent") || lowered.contains("escalate") || lowered.contains("manager") {
            return [ChatMessage(
                text: "I'll connect you with a live agent right away. Please hold for a moment while I transfer your conversation.\n\n⏳ Estimated wait time: 2 minutes",
                sender: .agent
            )]
        } else {
            return [ChatMessage(
                text: "I'd be happy to help! Here are some things I can assist you with:",
                sender: .agent,
                quickReplies: [
                    QuickReply(label: "Unit status", value: "unit_status"),
                    QuickReply(label: "Payments", value: "view_payments"),
                    QuickReply(label: "Service request", value: "request_service"),
                    QuickReply(label: "Talk to human", value: "escalate")
                ]
            )]
        }
    }

    // MARK: - Auth

    static let mockUser = AuthUser(
        id: "user-demo-001",
        email: "demo@prophub.com",
        displayName: "Sarah Johnson",
        role: "Senior Presales Consultant",
        contactId: "003xx000001234"
    )

    // MARK: - Helpers

    private static func dateFromString(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.date(from: string) ?? Date()
    }
}
