//
//  File.swift
//  
//
//  Created by Ryan Dingman on 9/12/21.
//

import Foundation

extension String {
    internal func snakecased() -> String {
        var newString = ""

        var previousWasUppercase = false
        var previousInsertedUnderscore = false

        for scalar in unicodeScalars {
            let isUppercase = CharacterSet.uppercaseLetters.contains(scalar)

            if isUppercase {
                if !previousWasUppercase && !newString.isEmpty {
                    newString.append("_")
                }
            } else {
                if previousWasUppercase && !previousInsertedUnderscore {
                    newString.insert("_", at: newString.index(before: newString.endIndex))
                }
            }

            let character = Character(scalar)
            newString.append(character)

            previousInsertedUnderscore = isUppercase && !previousWasUppercase
            previousWasUppercase = isUppercase
        }

        return newString.lowercased()
    }
}
