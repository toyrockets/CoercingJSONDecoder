import Combine
import XCTest
@testable import CoercingJSONDecoder

final class CoercionTests: XCTestCase {
    func testIntegerCoercion() {
        struct TestStruct: Decodable, Equatable {
            let one: Int?
            let two: Int?
            let three: Int?
            let four: Int?
            let five: Int?
            let six: Int?
            let seven: Int?
            let eight: Int?
            let nine: Int?
            let ten: Int?
        }

        let json = """
        {
            "one": 1,
            "two": "2",
            "three": 3.0,
            "four": 3.1,
            "five": "3.0",
            "six": "3.1",
            "seven": true,
            "eight": "invalid",
            "nine": [],
            "ten": {}
        }
        """

        guard let result = runTestWithDecoder(CoercingJSONDecoder(), json: json, type: TestStruct.self) else {
            XCTFail("Failed to decode data")
            return
        }

        XCTAssertEqual(result.one, 1)
        XCTAssertEqual(result.two, 2)
        XCTAssertEqual(result.three, 3)
        XCTAssertEqual(result.four, nil)
        XCTAssertEqual(result.five, 3)
        XCTAssertEqual(result.six, nil)
        XCTAssertEqual(result.seven, 1)
        XCTAssertEqual(result.eight, nil)
        XCTAssertEqual(result.nine, nil)
        XCTAssertEqual(result.ten, nil)
    }

    func testDoubleCoercion() {

        struct TestStruct: Decodable, Equatable {
            let a: Double?
            let b: Double?
            let c: Double?
            let d: Double?
        }

        let json = """
        {
            "a": 1,
            "b": "1",
            "c": 3.14,
            "d": "3.14"
        }
        """

        guard let result = runTestWithDecoder(CoercingJSONDecoder(), json: json, type: TestStruct.self) else {
            XCTFail("Failed to decode data")
            return
        }

        XCTAssertEqual(result.a, 1)
        XCTAssertEqual(result.b, 1)
        XCTAssertEqual(result.c, 3.14)
        XCTAssertEqual(result.d, 3.14)
    }
}
