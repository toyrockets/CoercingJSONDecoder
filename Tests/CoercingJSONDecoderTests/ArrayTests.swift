import Combine
import XCTest
@testable import CoercingJSONDecoder

    final class ArrayTests: XCTestCase {
        func testStringArray() {
            let json = """
                [ "one", "😁", "three" ]
            """

            runTestWithDecoder(CoercingJSONDecoder(), json: json, type: [String].self)
            runTestWithDecoder(JSONDecoder(), json: json, type: [String].self)
        }

        func testBooleanArray() {
            let json = """
                [ true, false, true ]
            """

            runTestWithDecoder(CoercingJSONDecoder(), json: json, type: [Bool].self)
            runTestWithDecoder(JSONDecoder(), json: json, type: [Bool].self)
        }

    }
