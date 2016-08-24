import XCTest
@testable import swift_libmodbus

class swift_libmodbusTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(swift_libmodbus().text, "Hello, World!")
    }


    static var allTests : [(String, (swift_libmodbusTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
