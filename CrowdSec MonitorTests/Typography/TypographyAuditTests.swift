import XCTest

/// Source-level audit enforcing the UI typography contract
/// (specs/005-ios-dynamic-type-tokens/contracts/ui-typography-contract.md, section C5).
///
/// - REQ-001: every view renders text at a size defined by the native typography
///   tokens — zero fixed text-size values remain in any view.
/// - REQ-007: every interface icon scales with the system text size setting —
///   zero fixed icon-size values remain in any view.
/// - Contract C5: no custom font scale may be introduced (`Font.custom`,
///   `.custom(... relativeTo:)`); `@ScaledMetric` is the only sanctioned
///   scaled-size mechanism (used for the two 60 pt hero symbols).
final class TypographyAuditTests: XCTestCase {

    /// Views directory on the build machine, resolved relative to this test file:
    /// `<repo>/ios/CrowdSec MonitorTests/Typography/TypographyAuditTests.swift`
    ///   → `<repo>/ios/CrowdSec Monitor/Views`
    private var viewsDirectory: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // Typography/
            .deletingLastPathComponent() // CrowdSec MonitorTests/
            .deletingLastPathComponent() // ios/
            .appendingPathComponent("CrowdSec Monitor")
            .appendingPathComponent("Views")
    }

    private func swiftFilesUnderViews() throws -> [URL] {
        let root = viewsDirectory
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: root.path),
            "Views directory not found at \(root.path) — the audit must run on the real source tree"
        )
        let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)
        let files = enumerator?.allObjects.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" } ?? []
        XCTAssertGreaterThan(files.count, 0, "No Swift files found under \(root.path)")
        return files
    }

    private func totalMatches(in files: [URL], pattern: String) throws -> [String] {
        let regex = try NSRegularExpression(pattern: pattern)
        var violations: [String] = []
        for file in files {
            let content = try String(contentsOf: file, encoding: .utf8)
            let count = regex.numberOfMatches(
                in: content,
                range: NSRange(location: 0, length: content.utf16.count)
            )
            if count > 0 {
                violations.append("\(file.lastPathComponent): \(count) occurrence(s)")
            }
        }
        return violations
    }

    /// REQ-001 + REQ-007 / SC-001: no fixed literal point sizes may remain in any view
    /// — for text or for icons. The sanctioned hero-symbol mechanism
    /// (`@ScaledMetric` feeding `size: heroSymbolSize`, a variable) does not match:
    /// the audit only flags literal numeric sizes.
    func test_noFixedTextOrIconSizesRemainInViews() throws {
        let files = try swiftFilesUnderViews()
        let violations = try totalMatches(in: files, pattern: #"\.system\(size:\s*[0-9]"#)
        XCTAssertTrue(
            violations.isEmpty,
            """
            Fixed text/icon sizes remain in views (REQ-001/REQ-007). \
            Migration to native text styles is incomplete:
            \(violations.joined(separator: "\n"))
            """
        )
    }

    /// Contract C5: no custom font scale in views. `Font.custom` / `.custom(... relativeTo:)`
    /// are banned; the only sanctioned scaled-size mechanism is `@ScaledMetric`
    /// (hero symbols, research.md R3).
    func test_noCustomFontScaleIntroducedInViews() throws {
        let files = try swiftFilesUnderViews()
        let violations = try totalMatches(in: files, pattern: #"Font\.custom|\.custom\(.*relativeTo"#)
        XCTAssertTrue(
            violations.isEmpty,
            "Custom font scale detected — only native text styles are allowed (contract C5): \(violations)"
        )
    }
}
