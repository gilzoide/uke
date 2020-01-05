//
//  Reader.swift
//  Uke
//
//  Created by Gil on 1/5/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit

enum ReaderError: Error {
    case invalidValue
}

class Reader {
    static let keyPathCharacterSet = CharacterSet.letters.union(CharacterSet(charactersIn: "."))
    static let newlineCharacterSet = CharacterSet.newlines
    
    static func read(_ contents: String, into view: UkeView) -> Bool {
        let scanner = Scanner(string: contents)
        
        do {
            while !scanner.isAtEnd {
                try readLine(scanner, into: view)
            }
            return true
        }
        catch {
            print("!!! Read error: \(error)")
            return false
        }
    }
    
    static func readLine(_ scanner: Scanner, into view: UkeView) throws {
        if let keyPath = scanner.scanCharacters(from: keyPathCharacterSet),
            let _ = scanner.scanString("="),
            let valueString = scanner.scanUpToCharacters(from: newlineCharacterSet) {
            let value = try readValue(valueString)
            view.setValue(value, forKeyPath: keyPath)
        }
    }
    
    static func readValue(_ valueString: String) throws -> Any {
        guard let val = Double(valueString) else { throw ReaderError.invalidValue }
        return val
    }
}
