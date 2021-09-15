
import Foundation

internal struct CoercingJSONSingleValueDecodingContainer: SingleValueDecodingContainer {
    var decoder: CoercingJSONDecoder
    var value: Any?
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]

    func decodeNil() -> Bool {
        return value == nil
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        guard let value = value else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.keyNotFound(codingPath.last!, context)
        }

        if let boolValue = value as? Bool {
            return boolValue
        } else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.typeMismatch(type, context)
        }
    }

    func decode(_ type: String.Type) throws -> String {
        guard let value = value else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.keyNotFound(codingPath.last!, context)
        }

        if let string = value as? String {
            return string
        } else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.typeMismatch(type, context)
        }
    }

    func decode(_ type: Double.Type) throws -> Double {
        fatalError("\(#function)")
    }

    func decode(_ type: Float.Type) throws -> Float {
        fatalError("\(#function)")
    }

    func decode(_ type: Int.Type) throws -> Int {
        fatalError("\(#function)")
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        fatalError("\(#function)")
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        fatalError("\(#function)")
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        fatalError("\(#function)")
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        fatalError("\(#function)")
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        fatalError("\(#function)")
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        fatalError("\(#function)")
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        fatalError("\(#function)")
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        fatalError("\(#function)")
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        fatalError("\(#function)")
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        fatalError("\(#function)")
    }
}

