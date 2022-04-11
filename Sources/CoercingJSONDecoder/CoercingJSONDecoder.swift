//
//  Copyright © 2021 Toy Rockets, LLC. All rights reserved.
//

import Combine
import Foundation

public class CoercingJSONDecoder {
    public enum DateDecodingStrategy {
        case deferredToDate
        case secondsSince1970
        case millisecondsSince1970
        @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
        case iso8601
        case formatted(DateFormatter)
        case custom((Decoder) throws -> Date)
    }

    public enum DataDecodingStrategy {
        case deferredToData
        case base64
        case custom((Decoder) throws -> Data)
    }

    public enum NonConformingFloatDecodingStrategy {
        case `throw`
        case convertFromString(positiveInfinity: String, negativeInfinity: String, nan: String)
    }

    public enum KeyDecodingStrategy {
        case useDefaultKeys
        case capitalized
        case convertFromSnakeCase
        case custom(([CodingKey]) -> CodingKey)
    }

    public var dateDecodingStrategies: [DateDecodingStrategy] = [.deferredToDate]
    public var dataDecodingStrategy: DataDecodingStrategy = .base64
    public var nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy = .throw
    public var keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys

    public var userInfo: [CodingUserInfoKey : Any] = [:]

    internal var iso8601DateFormatter: ISO8601DateFormatter = {
        return ISO8601DateFormatter()
    }()

    public init() {
    }

    open func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let decoder = CoercingJSONDocumentDecoder(decoder: self, value: jsonObject, codingPath: [], userInfo: userInfo)
            return try T(from: decoder)
        } catch let error as DecodingError {
            throw error
        } catch {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Could not parse the JSON document", underlyingError: error)
            throw DecodingError.dataCorrupted(context)
        }
    }
}

extension CoercingJSONDecoder: TopLevelDecoder {
    public typealias Input = Data
}
