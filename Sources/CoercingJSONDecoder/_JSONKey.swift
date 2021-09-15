//
//  _JSONKey.swift
//  PlistCoder
//
//  Created by Ryan Dingman on 9/3/21.
//

import Foundation

internal struct _JSONKey: CodingKey {
    init(stringValue: String) {
        self.stringValue = stringValue
    }

    var stringValue: String

    var intValue: Int?

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

