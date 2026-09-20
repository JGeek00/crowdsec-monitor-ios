@testable import CrowdSec_Monitor
import SwiftUI
import XCTest

/// Anexo 001 (v2) — test-plan REQ-A002 U1 (rotation −60°, reduction threshold at
/// accessibility-XXL), REQ-004 U1 (label-count policy) and REQ-005 U1 (1:1 label↔slot
/// at standard sizes). The policies are pure members of DashboardBarChart.
@MainActor
final class DashboardChartTests: XCTestCase {
    // MARK: - Fixtures (contract format "yyyy-MM-dd", 7 distinct days)

    private let week = (0..<7).map {
        ActivityHistory(date: "2026-02-1\($0)", amountAlerts: 3, amountDecisions: 2)
    }

    private let standardSizes: [DynamicTypeSize] = [
        .xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge,
    ]

    // MARK: - REQ-A002 U1 — rotation policy

    func testAxisLabelRotationIsMinusSixtyDegrees() {
        XCTAssertEqual(DashboardBarChart.axisLabelRotationDegrees, -60)
    }

    // MARK: - REQ-004 U1 / REQ-A002 U1 — label-subset policy

    func testAllSevenLabelsAtEveryStandardSize() {
        for size in standardSizes {
            XCTAssertEqual(
                DashboardBarChart.visibleLabelIndices(count: 7, typeSize: size),
                Array(0..<7),
                "full rotated label set required at \(size) (no thinning at standard sizes)"
            )
        }
    }

    func testReducedSubsetAtAccessibilityXXLAndAbove() {
        for size in [DynamicTypeSize.accessibility4, .accessibility5] {
            let indices = DashboardBarChart.visibleLabelIndices(count: 7, typeSize: size)
            XCTAssertLessThan(indices.count, 7, "reduction expected at \(size)")
            XCTAssertEqual(indices.first, 0, "first day stays anchored at \(size)")
            XCTAssertEqual(indices.last, 6, "last day stays anchored at \(size)")
        }
    }

    func testBoundaryAccessibilityXLStillShowsAllSeven() {
        // Just below the clarified threshold (accessibility-XXL): still full set.
        XCTAssertEqual(
            DashboardBarChart.visibleLabelIndices(count: 7, typeSize: .accessibility3),
            Array(0..<7)
        )
    }

    // MARK: - REQ-005 U1 — 1:1 label↔slot at standard sizes

    func testStandardLabelsMapOneToOneWithSlots() {
        let indices = DashboardBarChart.visibleLabelIndices(count: 7, typeSize: .large)
        XCTAssertEqual(indices.count, 7)
        XCTAssertEqual(Set(indices).count, 7, "no duplicate label slots")
    }

    // MARK: - REQ-A004 U1 — selection resolution (no dead zones)

    func testEveryDisplayedCategoryResolvesToExactlyOneEntry() {
        let labels = week.map { DashboardBarChart.dayLabel(from: $0.date) }
        XCTAssertEqual(Set(labels).count, labels.count, "every displayed category resolves to exactly one entry — any selection designates a day")
    }

    func testUnparseableDateFallsBackToRawString() {
        // research D6: pre-feature fallback — the entry stays selectable via its raw string.
        XCTAssertEqual(DashboardBarChart.dayLabel(from: "not-a-date"), "not-a-date")
    }
}
