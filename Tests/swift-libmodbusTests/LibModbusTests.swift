import XCTest
@testable import LibModbus

class LibModbusTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(Modbus().text, "Hello, World!")
    }


    static var allTests : [(String, (LibModbusTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
