import XCTest
@testable import MacDevKit

final class MacDevKitTests: XCTestCase {

    func testPlatformNameIsKnown() {
        XCTAssertFalse(PlatformInfo.name.isEmpty)
        XCTAssertTrue(["macOS", "Linux", "Unknown"].contains(PlatformInfo.name))
    }

    func testShellCapturesOutput() {
        let result = Shell.run("/bin/sh", ["-c", "echo hello"])
        XCTAssertEqual(result.code, 0)
        XCTAssertEqual(result.output, "hello")
    }

    func testShellReportsMissingTool() {
        let result = Shell.run("definitely-not-a-real-binary-12345")
        XCTAssertNotEqual(result.code, 0)
    }

    func testDoctorHasCoreChecks() {
        let checks = Doctor.runAll()
        XCTAssertGreaterThanOrEqual(checks.count, 6)
        XCTAssertTrue(checks.contains { $0.name == "Swift" })
        XCTAssertTrue(checks.contains { $0.name == "Git" })
    }

    func testRenderContainsHeaderAndSummary() {
        let text = Doctor.render(Doctor.runAll())
        XCTAssertTrue(text.contains("macdev doctor"))
        XCTAssertTrue(text.contains("通过"))
    }

    func testSwiftCheckPassesInThisEnvironment() {
        let checks = Doctor.runAll()
        let swift = checks.first { $0.name == "Swift" }
        XCTAssertNotNil(swift)
        XCTAssertEqual(swift?.status, .ok)
    }

    func testExitCodeIsZeroWhenNoFailure() {
        let checks = Doctor.runAll()
        let expected: Int32 = checks.contains { $0.status == .fail } ? 1 : 0
        XCTAssertEqual(Doctor.exitCode(for: checks), expected)
    }
}
