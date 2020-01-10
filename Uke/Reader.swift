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

public class Reader {
    static let parser = UkeParser()
    
    public static func read(_ contents: String) -> UkeObjectRecipe? {
        let result = contents.withCString { (cString) -> Result<UkeObjectRecipe, ReaderError> in
            guard let recipe = parser.recipe(withContents: cString) else { return Result.failure(ReaderError.invalidCommand) }
            return Result.success(recipe)
        }
        switch result {
        case .success(let recipe):
            return recipe
        case .failure(_):
            return nil
        }
    }
}
