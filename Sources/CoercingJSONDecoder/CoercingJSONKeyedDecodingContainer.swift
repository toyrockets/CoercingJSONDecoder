
import Foundation

internal class CoercingJSONKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    let value: [String: Any?]
    let decoder: CoercingJSONDecoder
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]

    init(value: [String: Any?], decoder: CoercingJSONDecoder, codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any], lastCachedIndex: Int = -1) {
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
        if let stringValue = try decodeIfPresent(type, forKey: key) {
            return stringValue
        } else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.typeMismatch(type, context)
        }
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        guard let value = value(for: key) else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.keyNotFound(key, context)
        }

        if let doubleValue = value as? Double {
            return doubleValue
        } else if let stringValue = value as? String, let doubleValue = Double(stringValue) {
            return doubleValue
        } else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.typeMismatch(type, context)
        }
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        fatalError("\(#function)")
    }

    // MARK: - Integer decoding

    private func decodeIntegerIfPresent<T: FixedWidthInteger>(_ type: T.Type, forKey key: Key) throws -> T? {
//        if try decodeNil(forKey: key) {
//            return nil
//        }

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

    // MARK: - Other decoding

    func decode<T: Collection & Decodable>(_ type: T.Type, forKey key: Key) throws -> T where T.Element: Decodable {
        fatalError("\(#function)")
//        let documentDecoder = CoercingJSONDocumentDecoder(decoder: decoder, node: node, codingPath: codingPath + [key], userInfo: userInfo)
//        return try T(from: documentDecoder)
    }

    func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T : Decodable {
        switch type {
        case is Date.Type:
            guard let value = value(for: key), value != nil else {
                return nil
            }

            // if let doubleValue = try decodeIfPresent(Double.self, forKey: key) {
            //     return Date(timeIntervalSince1970: doubleValue) as? T
            // }
            //
            // guard let stringValue = try decodeIfPresent(String.self, forKey: key) else {
            //     return nil
            // }
            //
            // return decoder.iso8601DateFormatter.date(from: stringValue) as? T

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

//        case is URL.Type:
//            let string = try unbox(String.self, forKey: key)
//
//            let characterSet = CharacterSet.whitespacesAndNewlines.inverted
//            let unescapedString = string.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: characterSet)
//            if let unescapedString = unescapedString, let url = URL(string: unescapedString) as? T {
//                return url
//            } else {
//                throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Invalid URL string: \(string)")
//            }
//        case is Decimal.Type:
//            let string = try unbox(String.self, forKey: key)
//
//            if let decimalValue = Decimal(string: string) as? T {
//                return decimalValue
//            } else {
//                throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Invalid decimal string: \(string)")
//            }
//
        default:
            guard let value = value(for: key) else {
                throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Missing node for key: \(key)")
            }

            let documentDecoder = CoercingJSONDocumentDecoder(decoder: decoder, value: value, codingPath: codingPath + [key], userInfo: userInfo)
            return try T(from: documentDecoder)
        }
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("\(#function)")
//        guard let node = node(for: key) else {
//            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Missing node for key: \(key)")
//        }
//
//        return KeyedDecodingContainer(CoercingJSONKeyedDecodingContainer<NestedKey>(node: node, decoder: decoder, codingPath: [key], userInfo: userInfo))

//        return KeyedDecodingContainer(CoercingJSONKeyedDecodingContainer<NestedKey>(node: node, decoder: decoder, codingPath: [key], userInfo: userInfo, cachedIndexes: cachedIndexes, lastCachedIndex: lastCachedIndex))
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        fatalError("\(#function)")

//        guard let node = node(for: key) else {
//            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Missing node for key: \(key)")
//        }
//
//        return CoercingJSONUnkeyedDecodingContainer(decoder: decoder, node: node, codingPath: codingPath + [key], userInfo: userInfo)
    }

    func superDecoder() throws -> Decoder {
        fatalError("\(#function)")
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        fatalError("\(#function)")
    }


}
