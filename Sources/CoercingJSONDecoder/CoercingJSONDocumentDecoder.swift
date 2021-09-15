//
//  File.swift
//  
//
//  Created by Ryan Dingman on 9/12/21.
//

import Foundation

internal final class CoercingJSONDocumentDecoder: Decoder {

    let decoder: CoercingJSONDecoder
    let value: Any?
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]

    init(decoder: CoercingJSONDecoder, value: Any?, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.decoder = decoder
        self.value = value
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        guard let dictionary = value as? [String: Any?] else {
            let expectedType = Dictionary<String, Any?>.self
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected to decode \(String(describing: expectedType)) but found a \(Swift.type(of: value)) instead.")
            throw DecodingError.typeMismatch(expectedType, context)
        }

        return KeyedDecodingContainer(CoercingJSONKeyedDecodingContainer(value: dictionary, decoder: decoder, codingPath: codingPath, userInfo: userInfo))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard let array = value as? [Any] else {
            let expectedType = Array<Any>.self
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Expected to decode \(String(describing: expectedType)) but found a \(type(of: value)) instead.")
            throw DecodingError.typeMismatch(expectedType, context)
        }

        return CoercingJSONUnkeyedDecodingContainer(decoder: decoder, value: array, codingPath: codingPath, userInfo: userInfo)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return CoercingJSONSingleValueDecodingContainer(decoder: decoder, value: value, codingPath: codingPath, userInfo: userInfo)
    }
}
