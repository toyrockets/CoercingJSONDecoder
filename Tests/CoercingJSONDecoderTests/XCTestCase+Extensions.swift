//
//  File.swift
//  
//
//  Created by Ryan Dingman on 9/13/21.
//

import Combine
import Foundation
import XCTest

func XCTAssertSuccessReturn<T>(_ expression: @autoclosure () throws -> T?, in file: StaticString = #file, line: UInt = #line) -> T? {
    do {
        return try expression()
    } catch {
        XCTFail(String(describing: error), file: file, line: line)
        return nil
    }
}

extension XCTestCase {
    func decodeWithDecoder<T: Decodable & Equatable, D: TopLevelDecoder>(_ decoder: D, json: String, type: T.Type) throws -> T? where D.Input == Data {
        guard let data = json.data(using: .utf8) else {
            XCTFail("Could not convert json to data")
            return nil
        }

        return try decoder.decode(type, from: data)
    }

    @discardableResult
    func runTestWithDecoder<T: Decodable & Equatable, D: TopLevelDecoder>(_ decoder: D, json: String, type: T.Type) -> T? where D.Input == Data {
        return XCTAssertSuccessReturn(try decodeWithDecoder(decoder, json: json, type: type))
//        guard let data = json.data(using: .utf8) else {
//            XCTFail("Could not convert json to data")
//            return
//        }
//
//        XCTAssertNoThrow(try decoder.decode(type, from: data))
    }

    func runThrowingTestWithDecoder<T: Decodable, D: TopLevelDecoder>(_ decoder: D, json: String, type: T.Type) where D.Input == Data {
        guard let data = json.data(using: .utf8) else {
            XCTFail("Could not convert json to data")
            return
        }

        XCTAssertThrowsError(try decoder.decode(type, from: data))
    }


}
