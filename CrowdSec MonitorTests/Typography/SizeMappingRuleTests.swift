import XCTest

/// REQ-002 + REQ-003: the normative size→token mapping
/// (specs/005-ios-dynamic-type-tokens/contracts/ui-typography-contract.md, section C2)
/// must assign, for every replaced fixed size, the native text style whose default
/// rendered size has the smallest absolute difference from the replaced size
/// (FR-002), and when a replaced size is exactly equidistant between two tokens,
/// the LARGER token must be selected (FR-003).
final class SizeMappingRuleTests: XCTestCase {

    /// Apple HIG "iOS, iPadOS Dynamic Type sizes — Large (default)" point sizes,
    /// restricted to the assignable token set of contract C1
    /// (specs/005-ios-dynamic-type-tokens/contracts/ui-typography-contract.md).
    /// `.body` is excluded because the platform default is inherited by omitting
    /// `.font(...)`, and `.headline` is not in C1's allowed style list.
    /// (developer.apple.com/design/human-interface-guidelines/typography)
    private let ramp: [(style: String, size: Double)] = [
        ("caption2", 11),
        ("caption", 12),
        ("footnote", 13),
        ("subheadline", 15),
        ("callout", 16),
        ("title3", 20),
        ("title2", 22),
        ("title", 28),
        ("largeTitle", 34),
    ]

    /// Normative migration table: fixed pt → native text style name.
    private let mapping: [(fixed: Double, token: String)] = [
        (11, "caption2"),
        (12, "caption"),
        (14, "subheadline"),
        (16, "callout"),
        (18, "title3"),
        (20, "title3"),
        (22, "title2"),
        (26, "title"),
        (28, "title"),
        (30, "title"),
        (36, "largeTitle"),
        (40, "largeTitle"),
    ]

    /// FR-002 + FR-003: nearest default rendered size; exact ties resolve to the larger token.
    private func expectedToken(for fixedSize: Double) -> String {
        let sorted = ramp.sorted { lhs, rhs in
            let leftDistance = abs(lhs.size - fixedSize)
            let rightDistance = abs(rhs.size - fixedSize)
            if leftDistance != rightDistance {
                return leftDistance < rightDistance
            }
            return lhs.size > rhs.size // tie → larger token
        }
        return sorted[0].style
    }

    /// REQ-002/REQ-003: every entry of the normative table satisfies the mapping rules.
    func test_normativeMappingFollowsNearestSizeWithLargerTieRule() {
        for entry in mapping {
            XCTAssertEqual(
                entry.token,
                expectedToken(for: entry.fixed),
                "fixed \(entry.fixed)pt must map to \(expectedToken(for: entry.fixed))"
            )
        }
    }

    /// Clarified tie rule (FR-003), explicitly pinned:
    /// 14pt is equidistant between footnote (13) and subheadline (15) → subheadline.
    /// 18pt is equidistant between callout (16) and title3 (20) → title3.
    func test_clarifiedTieCasesResolveToLargerToken() {
        XCTAssertEqual(expectedToken(for: 14), "subheadline")
        XCTAssertEqual(expectedToken(for: 18), "title3")
    }

    /// FR-009 parity bound: the largest default shift in the normative table
    /// (40pt → largeTitle 34) equals exactly one adjacent ramp step (title 28 ↔ largeTitle 34).
    /// Guards against future table edits that would break default-size parity.
    func test_noMappingEntryExceedsOneTokenStepOfDefaultParity() {
        let sizes = ramp.reduce(into: [Double]()) { acc, entry in
            if !acc.contains(entry.size) { acc.append(entry.size) }
        }.sorted()
        for entry in mapping {
            guard let assigned = ramp.first(where: { $0.style == entry.token }) else {
                XCTFail("Unknown token \(entry.token)")
                continue
            }
            let shift = abs(assigned.size - entry.fixed)
            if shift > 0 {
                // Distance in ramp steps: how many adjacent gaps the shift spans.
                let gaps = zip(sizes, sizes.dropFirst()).map { ($0, $1) }
                let stepOfAssigned = gaps.first { $0.0 == assigned.size || $0.1 == assigned.size }
                XCTAssertNotNil(stepOfAssigned)
                let adjacentStep: Double = {
                    guard let gap = gaps.first(where: { $0.0 == assigned.size })
                        ?? gaps.last(where: { $0.1 == assigned.size }) else { return 7 }
                    return abs(gap.1 - gap.0)
                }()
                XCTAssertLessThanOrEqual(
                    shift,
                    adjacentStep,
                    "fixed \(entry.fixed)pt → \(entry.token) shifts \(shift)pt, exceeding one token step (FR-009)"
                )
            }
        }
    }
}
