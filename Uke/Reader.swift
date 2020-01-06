//
//  Reader.swift
//  Uke
//
//  Created by Gil on 1/5/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit

public enum ReaderError: Error {
    case invalidCommand
    case expectedColor
    case invalidValue
}

class Reader {
    static let parser = UkeParser()
    
    static func read(_ contents: String, into view: UkeView) -> Bool {
        let result = contents.withCString { (cString) -> Result<Bool, ReaderError> in
            return parser.read(cString, into: view) > 0
                ? Result.success(true)
                : Result.failure(ReaderError.invalidCommand)
        }
        switch result {
        case .success(_):
            return true
        case .failure(_):
            return false
        }
    }
}
