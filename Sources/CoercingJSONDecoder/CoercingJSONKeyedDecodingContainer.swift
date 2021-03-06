
import Foundation

internal class CoercingJSONKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    let value: [String: Any?]
    let decoder: CoercingJSONDecoder
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]

    init(value: [String: Any?], decoder: CoercingJSONDecoder, codingPath: [Key], userInfo: [CodingUserInfoKey: Any], lastCachedIndex: Int = -1) {
        self.value = value
        self.decoder = decoder
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    var allKeys: [Key] {
        return value.keys.compactMap({ Key(stringValue: $0) })
    }

    func value(for key: Key) -> Any?? {

        let decodingKey: String

        switch decoder.keyDecodingStrategy {
        case .useDefaultKeys:
            decodingKey = key.stringValue
        case .capitalized:
            decodingKey = key.stringValue.capitalized
        case .convertFromSnakeCase:
            decodingKey = key.stringValue.snakecased()
        case .custom(let block):
            var codingPath = self.codingPath
            codingPath.append(key)
            decodingKey = block(codingPath).stringValue
        }

        return value[decodingKey]
    }

    func contains(_ key: Key) -> Bool {
        return value.contains(where: { $0.key == key.stringValue })
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        guard let value = value(for: key) else {
            return true
        }

        return value == nil
    }

    private func decodeLosslessStringConvertibleTypeIfPresent<T: LosslessStringConvertible>(_ type: T.Type, forKey key: Key) throws -> T? {
        guard let value = value(for: key) else {
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

    private func decodeLosslessStringConvertibleType<T: LosslessStringConvertible>(_ type: T.Type, forKey key: Key) throws -> T {
        if let value = try decodeLosslessStringConvertibleTypeIfPresent(type, forKey: key) {
            return value
        } else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.typeMismatch(type, context)
        }
    }


    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        guard let value = value(for: key) else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.keyNotFound(key, context)
        }

        if let boolValue = value as? Bool {
            return boolValue
        } else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.typeMismatch(type, context)
        }
    }

    func decodeIfPresent(_ type: String.Type, forKey key: Key) throws -> String? {
        guard let value = value(for: key), value != nil else {
            return nil
        }

        if let stringValue = value as? String {

            guard stringValue.lowercased() != "null" else {
                return nil
            }
            return stringValue
        }

        if let stringArrayValue = value as? [String], stringArrayValue.count == 1 {
            return stringArrayValue.first
        }

        if let convertibleValue = value as? CustomStringConvertible, convertibleValue.description != "<null>" {
            return convertibleValue.description
        }

        if let objectValue = value as? NSObject, objectValue.description != "<null>" {
            return objectValue.description
        }

        return nil
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        return try decodeLosslessStringConvertibleType(type, forKey: key)
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        return try decodeLosslessStringConvertibleType(type, forKey: key)
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        return try decodeLosslessStringConvertibleType(type, forKey: key)
    }

    // MARK: - Integer decoding

    private func decodeIntegerIfPresent<T: FixedWidthInteger>(_ type: T.Type, forKey key: Key) throws -> T? {

        guard let value = value(for: key), value != nil else {
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

    private func decodeInteger<T: FixedWidthInteger & Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        if let intValue = try decodeIntegerIfPresent(type, forKey: key) {
            return intValue
        } else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.typeMismatch(type, context)
        }
    }

    func decodeIfPresent(_ type: Int.Type, forKey key: Key) throws -> Int? {
        try decodeIntegerIfPresent(type, forKey: key)
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        try decodeInteger(type, forKey: key)
    }

    func decodeIfPresent(_ type: Int8.Type, forKey key: Key) throws -> Int8? {
        try decodeIntegerIfPresent(type, forKey: key)
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        try decodeInteger(type, forKey: key)
    }

    func decodeIfPresent(_ type: Int16.Type, forKey key: Key) throws -> Int16? {
        try decodeIntegerIfPresent(type, forKey: key)
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        try decodeInteger(type, forKey: key)
    }

    func decodeIfPresent(_ type: Int32.Type, forKey key: Key) throws -> Int32? {
        try decodeIntegerIfPresent(type, forKey: key)
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        try decodeInteger(type, forKey: key)
    }

    func decodeIfPresent(_ type: Int64.Type, forKey key: Key) throws -> Int64? {
        try decodeIntegerIfPresent(type, forKey: key)
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        try decodeInteger(type, forKey: key)
    }

    func decodeIfPresent(_ type: UInt.Type, forKey key: Key) throws -> UInt? {
        try decodeIntegerIfPresent(type, forKey: key)
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        try decodeInteger(type, forKey: key)
    }

    func decodeIfPresent(_ type: UInt8.Type, forKey key: Key) throws -> UInt8? {
        try decodeIntegerIfPresent(type, forKey: key)
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        try decodeInteger(type, forKey: key)
    }

    func decodeIfPresent(_ type: UInt16.Type, forKey key: Key) throws -> UInt16? {
        try decodeIntegerIfPresent(type, forKey: key)
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        try decodeInteger(type, forKey: key)
    }

    func decodeIfPresent(_ type: UInt32.Type, forKey key: Key) throws -> UInt32? {
        try decodeIntegerIfPresent(type, forKey: key)
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        try decodeInteger(type, forKey: key)
    }

    func decodeIfPresent(_ type: UInt64.Type, forKey key: Key) throws -> UInt64? {
        try decodeIntegerIfPresent(type, forKey: key)
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        try decodeInteger(type, forKey: key)
    }

    func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T : Decodable {
        switch type {
        case is Date.Type:
            guard let value = value(for: key), value != nil else {
                return nil
            }

            for dateDecodingStrategy in decoder.dateDecodingStrategies {
                switch dateDecodingStrategy {

                case .deferredToDate:
                   let decoder = CoercingJSONDocumentDecoder(decoder: decoder, value: value, codingPath: codingPath + [key], userInfo: userInfo)
                   return try Date(from: decoder) as? T

                case .secondsSince1970:
                   if let doubleValue = try? decodeIfPresent(Double.self, forKey: key) {
                       return Date(timeIntervalSince1970: doubleValue) as? T
                   }

                case .millisecondsSince1970:
                   if let doubleValue = try? decodeIfPresent(Double.self, forKey: key) {
                       return Date(timeIntervalSince1970: doubleValue / 1000) as? T
                   }

                case .iso8601:
                   if let stringValue = try decodeIfPresent(String.self, forKey: key),
                      let date = decoder.iso8601DateFormatter.date(from: stringValue) {
                       return date as? T
                   }

                case .formatted(let formatter):
                   if let stringValue = try decodeIfPresent(String.self, forKey: key),
                      let date = formatter.date(from: stringValue) {
                       return date as? T
                   }

                case .custom(let block):
                   let decoder = CoercingJSONDocumentDecoder(decoder: decoder, value: value, codingPath: codingPath + [key], userInfo: userInfo)
                    if let date = try? block(decoder) {
                        return date as? T
                    }
                }
            }

           return nil

        default:
            guard let value = value(for: key), value != nil else {
                return nil
            }

            let documentDecoder = CoercingJSONDocumentDecoder(decoder: decoder, value: value, codingPath: codingPath + [key], userInfo: userInfo)
            return try T(from: documentDecoder)
        }
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        switch type {
        case is Date.Type:
            if let dateValue = try decodeIfPresent(type, forKey: key) {
                return dateValue
            } else {
                let context = DecodingError.Context(codingPath: codingPath + [key], debugDescription: "Expected \(String(describing: type)) value")
                throw DecodingError.typeMismatch(type, context)
            }

        default:
            guard let value = value(for: key) else {
                throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Missing node for key: \(key)")
            }

            let documentDecoder = CoercingJSONDocumentDecoder(decoder: decoder, value: value, codingPath: codingPath + [key], userInfo: userInfo)
            return try T(from: documentDecoder)
        }
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {

        guard let dictionary = value(for: key) as? [String: Any?] else {
            let expectedType = Dictionary<String, Any?>.self
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected to decode \(String(describing: expectedType)) but found a \(Swift.type(of: value)) instead.")
            throw DecodingError.typeMismatch(expectedType, context)
        }

        let fop = (self.codingPath + [key]).compactMap({ NestedKey(stringValue: $0.stringValue) })
        let container = CoercingJSONKeyedDecodingContainer<NestedKey>(value: dictionary, decoder: decoder, codingPath: fop, userInfo: userInfo)
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {

        guard let value = value(for: key) as? [Any?] else {
            let expectedType = Array<Any>.self
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected to decode \(String(describing: expectedType)) but found a \(type(of: value)) instead.")
            throw DecodingError.typeMismatch(expectedType, context)
        }

        let codingPath = self.codingPath.compactMap({ Key(stringValue: $0.stringValue) })
        return CoercingJSONUnkeyedDecodingContainer(decoder: decoder, value: value, codingPath: codingPath + [key], userInfo: userInfo)
    }

    func superDecoder() throws -> Decoder {
        return CoercingJSONDocumentDecoder(decoder: decoder, value: value, codingPath: codingPath, userInfo: userInfo)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        return CoercingJSONDocumentDecoder(decoder: decoder, value: value, codingPath: codingPath + [key], userInfo: userInfo)
    }
}
