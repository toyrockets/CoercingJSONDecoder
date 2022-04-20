
import Foundation

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
        return try decodeLosslessStringConvertibleType(type)
    }

    func decode(_ type: String.Type) throws -> String {
        return try decodeLosslessStringConvertibleType(type)
    }

    func decode(_ type: Double.Type) throws -> Double {
        return try decodeLosslessStringConvertibleType(type)
    }

    func decode(_ type: Float.Type) throws -> Float {
        return try decodeLosslessStringConvertibleType(type)
    }

    func decode(_ type: Int.Type) throws -> Int {
        return try decodeInteger(type)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        return try decodeInteger(type)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        return try decodeInteger(type)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        return try decodeInteger(type)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        return try decodeInteger(type)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        return try decodeInteger(type)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try decodeInteger(type)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try decodeInteger(type)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try decodeInteger(type)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try decodeInteger(type)
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let documentDecoder = CoercingJSONDocumentDecoder(decoder: decoder, value: value, codingPath: codingPath, userInfo: userInfo)
        return try T(from: documentDecoder)
    }

    private func decodeLosslessStringConvertibleTypeIfPresent<T: LosslessStringConvertible>(_ type: T.Type) throws -> T? {
        guard let value = value else {
            return nil
        }

        if let double = value as? T {
            return double
        } else if let string = value as? String {
            return T(string)
        } else {
            return nil
        }
    }

    private func decodeLosslessStringConvertibleType<T: LosslessStringConvertible>(_ type: T.Type) throws -> T {
        if let value = try decodeLosslessStringConvertibleTypeIfPresent(type) {
            return value
        } else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.typeMismatch(type, context)
        }
    }

    private func decodeIntegerIfPresent<T: FixedWidthInteger>(_ type: T.Type) throws -> T? {

        guard let value = value else {
            return nil
        }

        if let intValue = value as? T {
            return intValue
        } else if let stringValue = value as? String {

            if let intValue = T(stringValue) {
                return intValue
            } else if let doubleValue = Double(stringValue) {
                return T(exactly: doubleValue)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    private func decodeInteger<T: FixedWidthInteger & Decodable>(_ type: T.Type) throws -> T {
        if let intValue = try decodeIntegerIfPresent(type) {
            return intValue
        } else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.typeMismatch(type, context)
        }
    }
}

