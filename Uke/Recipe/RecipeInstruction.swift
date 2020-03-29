//
//  Instruction.swift
//  Uke
//
//  Created by Gil Reis on 29/03/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import Foundation

public enum RecipeInstruction {
    case defineProperty(name: String, type: Any.Type, initialValue: Any? = nil)
    case setValue(_ value: Any?, keyPath: String)
    case bindExpression(format: String, name: String, dependencyKeyPaths: [String] = [], runOnLayout: Bool = false)
    case instantiate(AnyClass)
    case addChild(name: String)
}
