//
//  Reader.swift
//  Uke
//
//  Created by Gil on 1/5/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit

class Reader {
    static let keyPathCharacterSet = CharacterSet.letters.union(CharacterSet(charactersIn: "."))
    static let newlineCharacterSet = CharacterSet.newlines
    
    static func read(_ contents: String, into view: UkeView) -> Bool {
        let scanner = Scanner(string: contents)
        
        while !scanner.isAtEnd {
            readLine(scanner, into: view)
        }
        
        return true
    }
    
    static func readLine(_ scanner: Scanner, into view: UkeView) {
        if let keyPath = scanner.scanCharacters(from: keyPathCharacterSet),
            let _ = scanner.scanString("="),
            let valueString = scanner.scanUpToCharacters(from: newlineCharacterSet),
            let value = readValue(valueString) {
            view.setValue(value, forKeyPath: keyPath)
        }
    }
    
    static func readValue(_ valueString: String) -> Any? {
        return Double(valueString)
    }
}
