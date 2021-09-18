import XCTest
@testable import CoercingJSONDecoder

final class DictionaryTests: XCTestCase {
    func testInvalidJson() {
        struct TestStruct: Decodable, Equatable {
            let integer: Int?
        }

        let json = """
        {
            "fooble": ,
        }
        """

        runThrowingTestWithDecoder(CoercingJSONDecoder(), json: json, type: TestStruct.self)
        runThrowingTestWithDecoder(JSONDecoder(), json: json, type: TestStruct.self)

    }

    func testMissingKeyWithOptional() {
        struct TestStruct: Decodable, Equatable {
            let integer: Int?
        }

        let json = "{}"

        let result1 = runTestWithDecoder(CoercingJSONDecoder(), json: json, type: TestStruct.self)
        let result2 = runTestWithDecoder(JSONDecoder(), json: json, type: TestStruct.self)
        XCTAssertEqual(result1, result2)
    }

    func testMissingKey() {
        struct TestStruct: Decodable, Equatable {
            let integer: Int
        }

        let json = "{}"

        runThrowingTestWithDecoder(JSONDecoder(), json: json, type: TestStruct.self)
        runThrowingTestWithDecoder(CoercingJSONDecoder(), json: json, type: TestStruct.self)

    }

    func testNil() {
        struct TestStruct: Decodable, Equatable {
            let integer: Int?
            let string: String?
        }

        let json = """
        {
            "integer": null
        }
        """

        runTestWithDecoder(JSONDecoder(), json: json, type: TestStruct.self)
        runTestWithDecoder(CoercingJSONDecoder(), json: json, type: TestStruct.self)

    }

    func testSnakecaseKey() {
        struct TestStruct: Decodable, Equatable {
            let multiwordKey: Int
        }

        let json = """
        {
            "multiword_key": 1
        }
        """

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        runTestWithDecoder(jsonDecoder, json: json, type: TestStruct.self)

        let coercingJSONDecoder = CoercingJSONDecoder()
        coercingJSONDecoder.keyDecodingStrategy = .convertFromSnakeCase
        runTestWithDecoder(coercingJSONDecoder, json: json, type: TestStruct.self)
    }

    func testArrayTypeMismatch() {
        let json = """
        {
            "integer": null
        }
        """

        runThrowingTestWithDecoder(JSONDecoder(), json: json, type: [String].self)
        runThrowingTestWithDecoder(CoercingJSONDecoder(), json: json, type: [String].self)
    }

    func testDictionaryTypeMismatch() {
        struct TestStruct: Decodable, Equatable {
            let multiwordKey: Int
        }

        let json = """
        [
            "one", "two", "three"
        ]
        """

        runThrowingTestWithDecoder(JSONDecoder(), json: json, type: TestStruct.self)
        runThrowingTestWithDecoder(CoercingJSONDecoder(), json: json, type: TestStruct.self)
    }

    func testBooleans() {
        struct TestStruct: Decodable, Equatable {
            let flag: Bool
        }

        let json = """
        {
            "flag": true
        }
        """

        runTestWithDecoder(CoercingJSONDecoder(), json: json, type: TestStruct.self)
        runTestWithDecoder(JSONDecoder(), json: json, type: TestStruct.self)

    }

    func testIntegers() {
        struct TestStruct: Decodable, Equatable {
            let int: Int
            let int8: Int8
            let int16: Int16
            let int32: Int32
            let int64: Int64
            let uint: UInt
            let uint8: UInt8
            let uint16: UInt16
            let uint32: UInt32
            let uint64: UInt64
        }

        let json = """
        {
            "int": 1,
            "int8": 1,
            "int16": 1,
            "int32": 1,
            "int64": 1,
            "uint": 1,
            "uint8": 1,
            "uint16": 1,
            "uint32": 1,
            "uint64": 1
        }
        """

        let result1 = runTestWithDecoder(CoercingJSONDecoder(), json: json, type: TestStruct.self)
        let result2 = runTestWithDecoder(JSONDecoder(), json: json, type: TestStruct.self)
        XCTAssertEqual(result1, result2)
    }

    func testOptionalIntegers() {
        struct TestStruct: Decodable, Equatable {
            let int: Int?
            let int8: Int8?
            let int16: Int16?
            let int32: Int32?
            let int64: Int64?
            let uint: UInt?
            let uint8: UInt8?
            let uint16: UInt16?
            let uint32: UInt32?
            let uint64: UInt64?
        }

        let json = """
        {
            "int": 1,
            "int8": 1,
            "int16": 1,
            "int32": 1,
            "int64": 1,
            "uint": 1,
            "uint8": 1,
            "uint16": 1,
            "uint32": 1,
            "uint64": 1
        }
        """

        let result1 = runTestWithDecoder(CoercingJSONDecoder(), json: json, type: TestStruct.self)
        let result2 = runTestWithDecoder(JSONDecoder(), json: json, type: TestStruct.self)
        XCTAssertEqual(result1, result2)
    }

    func testDoubles() {
        struct TestStruct: Decodable, Equatable {
            let double: Double
        }

        let json = """
        {
            "double": 3.14
        }
        """

        runTestWithDecoder(CoercingJSONDecoder(), json: json, type: TestStruct.self)
        runTestWithDecoder(JSONDecoder(), json: json, type: TestStruct.self)

    }

    func testCustomDecodeables() {
        struct TestStruct: Decodable, Equatable {
            enum Status: String, Decodable, Equatable {
                case processing
            }

            let double: Double
            let status: Status
        }

        let json = """
        {
            "double": 3.14,
            "status": "processing"
        }
        """

        runTestWithDecoder(CoercingJSONDecoder(), json: json, type: TestStruct.self)
        runTestWithDecoder(JSONDecoder(), json: json, type: TestStruct.self)
    }

}
