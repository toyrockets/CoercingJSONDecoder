
import Foundation

internal class CoercingJSONUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    let decoder: CoercingJSONDecoder
    let value: [Any?]
    let codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]
    var count: Int? {
        return value.count
    }

    var isAtEnd: Bool {
        if let count = count {
            return currentIndex >= count
        } else {
            return true
        }
    }

    var currentIndex: Int = 0

    init(decoder: CoercingJSONDecoder, value: [Any?], codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
        self.value = value
        self.decoder = decoder
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    private func decodeCoercingLosslessStringConvertibleType<T: LosslessStringConvertible>(_ type: T.Type) throws -> T {
        if let value = try decodeCoercingLosslessStringConvertibleTypeIfPresent(type) {
            return value
        } else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.typeMismatch(type, context)
        }
    }

    private func decodeCoercingLosslessStringConvertibleTypeIfPresent<T: LosslessStringConvertible>(_ type: T.Type) throws -> T? {
        guard let value = value[currentIndex] else {
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

    private func decodeLosslessStringConvertibleTypeIfPresent<T: LosslessStringConvertible, U: Decodable>(_ type: T.Type, _ type2: U.Type) throws -> U {
        guard let value = value[currentIndex] else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.typeMismatch(type, context)
        }

        let documentDecoder = CoercingJSONDocumentDecoder(decoder: decoder, value: value, codingPath: codingPath, userInfo: userInfo)

        let object = try decodeCoercingLosslessStringConvertibleTypeIfPresent(type) as? U ?? U(from: documentDecoder)
        currentIndex += 1
        return object
    }

    private func decodeLosslessStringConvertibleType<T: LosslessStringConvertible, U: Decodable>(_ type: T.Type, _ type2: U.Type) throws -> U {
        guard let value = value[currentIndex] else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.typeMismatch(type, context)
        }

        let documentDecoder = CoercingJSONDocumentDecoder(decoder: decoder, value: value, codingPath: codingPath, userInfo: userInfo)

        let object = try decodeCoercingLosslessStringConvertibleType(type) as? U ?? U(from: documentDecoder)
        currentIndex += 1
        return object
    }


    private func decodeCoercingIntegerIfPresent<T: FixedWidthInteger>(_ type: T.Type) throws -> T? {

        guard let value = self.value[currentIndex] else {
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

    private func decodeCoercingInteger<T: FixedWidthInteger>(_ type: T.Type) throws -> T {
        if let intValue = try decodeCoercingIntegerIfPresent(type) {
            return intValue
        } else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.typeMismatch(type, context)
        }
    }

    private func decodeIntegerIfPresent<T: FixedWidthInteger, U: Decodable>(_ type: T.Type, _ type2: U.Type) throws -> U {
        guard let value = value[currentIndex] else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.typeMismatch(type, context)
        }

        let documentDecoder = CoercingJSONDocumentDecoder(decoder: decoder, value: value, codingPath: codingPath, userInfo: userInfo)

        let object = try decodeCoercingIntegerIfPresent(type) as? U ?? U(from: documentDecoder)
        currentIndex += 1
        return object
    }

    private func decodeInteger<T: FixedWidthInteger, U: Decodable>(_ type: T.Type, _ type2: U.Type) throws -> U {
        guard let value = value[currentIndex] else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.typeMismatch(type, context)
        }

        let documentDecoder = CoercingJSONDocumentDecoder(decoder: decoder, value: value, codingPath: codingPath, userInfo: userInfo)

        let object = try decodeCoercingInteger(type) as? U ?? U(from: documentDecoder)
        currentIndex += 1
        return object
    }

    func decodeNil() throws -> Bool {
        let result = value[currentIndex] == nil
        currentIndex += 1
        return result
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        return try decodeLosslessStringConvertibleType(type, type)
    }

    func decode(_ type: String.Type) throws -> String {
        return try decodeLosslessStringConvertibleType(type, type)
    }

    func decode(_ type: Double.Type) throws -> Double {
        return try decodeLosslessStringConvertibleType(type, type)
    }

    func decode(_ type: Float.Type) throws -> Float {
        return try decodeLosslessStringConvertibleType(type, type)
    }

    func decode(_ type: Int.Type) throws -> Int {
        return try decodeInteger(type, type)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        return try decodeInteger(type, type)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        return try decodeInteger(type, type)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        return try decodeInteger(type, type)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        return try decodeInteger(type, type)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        return try decodeInteger(type, type)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try decodeInteger(type, type)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try decodeInteger(type, type)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try decodeInteger(type, type)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try decodeInteger(type, type)
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {

        switch type {
        case is Bool.Type:
            return try decodeLosslessStringConvertibleType(Bool.self, type)

        case is Bool?.Type:
            return try decodeLosslessStringConvertibleTypeIfPresent(Bool.self, type)

        case is Double.Type:
            return try decodeLosslessStringConvertibleType(Double.self, type)

        case is Double?.Type:
            return try decodeLosslessStringConvertibleTypeIfPresent(Double.self, type)

        case is Float.Type:
            return try decodeLosslessStringConvertibleType(Float.self, type)

        case is Float?.Type:
            return try decodeLosslessStringConvertibleTypeIfPresent(Float.self, type)

        case is Int.Type:
            return try decodeInteger(Int.self, type)

        case is Int?.Type:
            return try decodeIntegerIfPresent(Int.self, type)

        case is Int8.Type:
            return try decodeInteger(Int8.self, type)

        case is Int8?.Type:
            return try decodeIntegerIfPresent(Int8.self, type)

        case is Int16.Type:
            return try decodeInteger(Int16.self, type)

        case is Int16?.Type:
            return try decodeIntegerIfPresent(Int16.self, type)

        case is Int32.Type:
            return try decodeInteger(Int32.self, type)

        case is Int32?.Type:
            return try decodeIntegerIfPresent(Int32.self, type)

        case is Int64.Type:
            return try decodeInteger(Int64.self, type)

        case is Int64?.Type:
            return try decodeIntegerIfPresent(Int64.self, type)

        case is UInt.Type:
            return try decodeInteger(UInt.self, type)

        case is UInt?.Type:
            return try decodeIntegerIfPresent(UInt.self, type)

        case is UInt8.Type:
            return try decodeInteger(UInt8.self, type)

        case is UInt8?.Type:
            return try decodeIntegerIfPresent(UInt8.self, type)

        case is UInt16.Type:
            return try decodeInteger(UInt16.self, type)

        case is UInt16?.Type:
            return try decodeIntegerIfPresent(UInt16.self, type)

        case is UInt32.Type:
            return try decodeInteger(UInt32.self, type)

        case is UInt32?.Type:
            return try decodeIntegerIfPresent(UInt32.self, type)

        case is UInt64.Type:
            return try decodeInteger(UInt64.self, type)

        case is UInt64?.Type:
            return try decodeIntegerIfPresent(UInt64.self, type)

        default:
            guard let value = value[currentIndex] else {
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
                throw DecodingError.typeMismatch(type, context)
            }

            let documentDecoder = CoercingJSONDocumentDecoder(decoder: decoder, value: value, codingPath: codingPath, userInfo: userInfo)

            let object = try T(from: documentDecoder)
            currentIndex += 1
            return object
        }
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {

        guard let value = value[currentIndex] as? [String: Any?] else {

            let expectedType = Dictionary<String, Any?>.self
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected to decode \(String(describing: expectedType)) but found a \(Swift.type(of: value)) instead.")
            throw DecodingError.typeMismatch(expectedType, context)
        }

        let codingPath = self.codingPath.compactMap({ NestedKey(stringValue: $0.stringValue) })
        currentIndex += 1
        return KeyedDecodingContainer(CoercingJSONKeyedDecodingContainer(value: value, decoder: decoder, codingPath: codingPath, userInfo: userInfo))
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {

        guard let value = value[currentIndex] as? [Any?] else {
            let expectedType = Array<Any>.self
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected to decode \(String(describing: expectedType)) but found a \(type(of: value)) instead.")
            throw DecodingError.typeMismatch(expectedType, context)
        }

        currentIndex += 1
        return CoercingJSONUnkeyedDecodingContainer(decoder: decoder, value: value, codingPath: codingPath, userInfo: userInfo)
    }

    func superDecoder() throws -> Decoder {
        return CoercingJSONDocumentDecoder(decoder: decoder, value: value, codingPath: codingPath, userInfo: userInfo)
    }
}
