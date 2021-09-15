
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

    func decodeNil() throws -> Bool {
        fatalError("\(#function)")
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        fatalError("\(#function)")

//        precondition(node.pointee.type == yajl_t_array)
//
//        guard let node = node.pointee.u.array.values[currentIndex] else {
//            let key = _JSONKey(intValue: currentIndex)!
//            let context = DecodingError.Context(codingPath: codingPath + [key], debugDescription: "Could not find \(key)")
//            throw DecodingError.valueNotFound(type, context)
//        }
//
//        if node.pointee.type == yajl_t_true {
//            currentIndex += 1
//            return true
//        } else if node.pointee.type == yajl_t_false {
//            currentIndex += 1
//            return false
//        } else {
//            let type = Bool.self
//            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected to decode \(String(describing: type)) but found a \(node.pointee.type.description) instead.")
//            throw DecodingError.typeMismatch(type, context)
//        }
    }

    func decode(_ type: String.Type) throws -> String {
        fatalError("\(#function)")
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
        guard let value = value[currentIndex] else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(String(describing: type)) value")
            throw DecodingError.typeMismatch(type, context)
        }

        let documentDecoder = CoercingJSONDocumentDecoder(decoder: decoder, value: value, codingPath: codingPath, userInfo: userInfo)
        let object = try T(from: documentDecoder)
        currentIndex += 1
        return object
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("\(#function)")
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError("\(#function)")
    }

    func superDecoder() throws -> Decoder {
        fatalError("\(#function)")
    }
}
