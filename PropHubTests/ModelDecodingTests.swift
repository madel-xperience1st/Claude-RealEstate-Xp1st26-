import XCTest
@testable import PropHub

final class ModelDecodingTests: XCTestCase {

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    func testDemoProjectDecoding() throws {
        let json = """
        {
            "id": "proj-001",
            "name": "Emaar Beachfront",
            "developer": "Emaar Properties",
            "logo_url": "https://example.com/logo.png",
            "brand_primary_color": "#1B4D8E",
            "brand_secondary_color": "#F5A623",
            "description": "Luxury beachfront living",
            "status": "Active",
            "default_currency": "AED",
            "unit_count": 42
        }
        """.data(using: .utf8)!

        let project = try decoder.decode(DemoProject.self, from: json)
        XCTAssertEqual(project.id, "proj-001")
        XCTAssertEqual(project.name, "Emaar Beachfront")
        XCTAssertEqual(project.developer, "Emaar Properties")
        XCTAssertEqual(project.brandPrimaryColor, "#1B4D8E")
        XCTAssertEqual(project.defaultCurrency, "AED")
        XCTAssertEqual(project.unitCount, 42)
    }

    func testUnitDecoding() throws {
        let json = """
        {
            "id": "unit-001",
            "unit_number": "A-1204",
            "building": "Tower A",
            "floor": 12,
            "area_sqm": 85.5,
            "area_sqft": 920.3,
            "unit_type": "2BR",
            "status": "Delivered",
            "handover_date": "2025-06-15T00:00:00Z",
            "total_price": 1500000.00,
            "floor_plan_url": "https://example.com/plan.jpg",
            "payment_completion": 0.75,
            "project_name": "Emaar Beachfront"
        }
        """.data(using: .utf8)!

        let unit = try decoder.decode(Unit.self, from: json)
        XCTAssertEqual(unit.id, "unit-001")
        XCTAssertEqual(unit.unitNumber, "A-1204")
        XCTAssertEqual(unit.floor, 12)
        XCTAssertEqual(unit.areaSqm, 85.5)
        XCTAssertEqual(unit.unitType, "2BR")
        XCTAssertEqual(unit.paymentCompletion, 0.75)
    }

    func testInstallmentDecoding() throws {
        let json = """
        {
            "id": "inst-001",
            "milestone_name": "Booking Fee",
            "due_date": "2024-01-15T00:00:00Z",
            "amount": 150000.00,
            "status": "Paid",
            "paid_date": "2024-01-10T00:00:00Z",
            "penalty_amount": null,
            "sort_order": 1
        }
        """.data(using: .utf8)!

        let installment = try decoder.decode(Installment.self, from: json)
        XCTAssertEqual(installment.id, "inst-001")
        XCTAssertEqual(installment.milestoneName, "Booking Fee")
        XCTAssertEqual(installment.amount, 150000.00)
        XCTAssertEqual(installment.status, "Paid")
        XCTAssertNotNil(installment.paidDate)
        XCTAssertNil(installment.penaltyAmount)
    }

    func testPaymentSummaryDecoding() throws {
        let json = """
        {
            "total_price": 1500000.00,
            "paid_amount": 750000.00,
            "remaining_balance": 750000.00,
            "next_due_date": "2025-04-01T00:00:00Z",
            "overdue_count": 1,
            "overdue_amount": 150000.00
        }
        """.data(using: .utf8)!

        let summary = try decoder.decode(PaymentSummary.self, from: json)
        XCTAssertEqual(summary.totalPrice, 1500000.00)
        XCTAssertEqual(summary.paidAmount, 750000.00)
        XCTAssertEqual(summary.overdueCount, 1)
    }

    func testServiceRequestDecoding() throws {
        let json = """
        {
            "id": "sr-001",
            "case_number": "CS-001234",
            "category": "Plumbing",
            "subject": "Kitchen sink leak",
            "status": "In Progress",
            "created_date": "2025-03-01T10:30:00Z",
            "assigned_technician": "Ahmed Hassan",
            "description": "Water leaking from under the sink",
            "preferred_date": null,
            "related_asset_id": null
        }
        """.data(using: .utf8)!

        let request = try decoder.decode(ServiceRequest.self, from: json)
        XCTAssertEqual(request.caseNumber, "CS-001234")
        XCTAssertEqual(request.category, "Plumbing")
        XCTAssertEqual(request.assignedTechnician, "Ahmed Hassan")
    }

    func testAssetDecoding() throws {
        let json = """
        {
            "id": "asset-001",
            "name": "Samsung Split AC",
            "serial_number": "SAM-AC-2024-001",
            "manufacturer": "Samsung",
            "install_date": "2024-06-15T00:00:00Z",
            "warranty_end_date": "2026-06-15T00:00:00Z",
            "warranty_status": "Active",
            "category": "HVAC"
        }
        """.data(using: .utf8)!

        let asset = try decoder.decode(Asset.self, from: json)
        XCTAssertEqual(asset.name, "Samsung Split AC")
        XCTAssertEqual(asset.warrantyStatus, "Active")
        XCTAssertEqual(asset.category, "HVAC")
    }

    func testProjectLaunchDecoding() throws {
        let json = """
        {
            "id": "launch-001",
            "name": "Marina Views Phase 2",
            "description": "Premium waterfront apartments",
            "price_range_min": 800000,
            "price_range_max": 2500000,
            "expected_handover": "Q4 2027",
            "hero_image_urls": "https://example.com/img1.jpg, https://example.com/img2.jpg",
            "amenities": "[\\"Pool\\", \\"Gym\\", \\"Spa\\"]",
            "launch_date": "2025-04-01T00:00:00Z",
            "is_active": true
        }
        """.data(using: .utf8)!

        let launch = try decoder.decode(ProjectLaunch.self, from: json)
        XCTAssertEqual(launch.name, "Marina Views Phase 2")
        XCTAssertEqual(launch.imageURLs.count, 2)
        XCTAssertEqual(launch.amenitiesList, ["Pool", "Gym", "Spa"])
    }
}
