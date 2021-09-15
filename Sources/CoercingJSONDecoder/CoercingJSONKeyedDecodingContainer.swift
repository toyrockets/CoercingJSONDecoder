
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
        // TODO: Consider other strategies:
        // 1. elements only
        // 2. attributes only
        // 3. elements, then attributes
        // 4. attributes, then elements

        let decodingKey: String
        switch decoder.keyDecodingStrategy {
        case .useDefaultKeys:
            decodingKey = key.stringValue
        case .capitalized:
            decodingKey = key.stringValue.capitalized
        case .convertFromSnakeCase:
            // TODO: Implement me
            decodingKey = key.stringValue.snakecased()
        case .custom(let block):
            decodingKey = block(codingPath + [key]).stringValue
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

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        fatalError("\(#function)")
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

    func decodeIfPresent(_ type: Int.Type, forKey key: Key) throws -> Int? {
        if try decodeNil(forKey: key) {
            return nil
        }

        guard let value = value(for: key) else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.keyNotFound(key, context)
        }

        if let intValue = value as? Int {
            return intValue
        } else if let stringValue = value as? String {

            if let intValue = Int(stringValue) {
                return intValue
            } else if let doubleValue = Double(stringValue) {

                if let intValue = Int(exactly: doubleValue) {
                    return intValue
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } else {
            return nil
        }

    }
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        if let intValue = try decodeIfPresent(type, forKey: key) {
            return intValue
        } else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.typeMismatch(type, context)
        }
//        guard let value = value(for: key) else {
//            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
//            throw DecodingError.keyNotFound(key, context)
//        }
//
//        if let intValue = value as? Int {
//            return intValue
//        } else if let stringValue = value as? String {
//
//            if let intValue = Int(stringValue) {
//                return intValue
//            } else if let doubleValue = Double(stringValue) {
//
//                if let intValue = Int(exactly: doubleValue) {
//                    return intValue
//                } else {
//                    let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
//                    throw DecodingError.valueNotFound(type, context)
//                }
//            } else {
//                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
//                throw DecodingError.typeMismatch(type, context)
//            }
//        } else if let doubleValue = value as? Double {
//
//        } else {
//            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
//            throw DecodingError.typeMismatch(type, context)
//        }
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        fatalError("\(#function)")
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        fatalError("\(#function)")
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        fatalError("\(#function)")
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        fatalError("\(#function)")
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        fatalError("\(#function)")
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        fatalError("\(#function)")
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        fatalError("\(#function)")
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        fatalError("\(#function)")
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        fatalError("\(#function)")
    }

    func decode<T: Collection & Decodable>(_ type: T.Type, forKey key: Key) throws -> T where T.Element: Decodable {
        fatalError("\(#function)")
//        let documentDecoder = CoercingJSONDocumentDecoder(decoder: decoder, node: node, codingPath: codingPath + [key], userInfo: userInfo)
//        return try T(from: documentDecoder)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        switch type {
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
