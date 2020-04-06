//
//  UkeRecipeInstruction.swift
//  Uke
//
//  Created by Gil Reis on 29/03/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit

public enum UkeRecipeInstruction {
    case defineProperty(name: String, type: Any.Type, initialValue: Any? = nil)
    case setValue(_ value: Any?, keyPath: String)
    case bindExpression(name: String, format: String, dependencyKeyPaths: [String] = [], runOnLayout: Bool = false)
    case pushView(name: String, UIView.Type = UIView.self, recipe: [UkeRecipeInstruction])
    case pushLayer(name: String, CALayer.Type = CALayer.self, recipe: [UkeRecipeInstruction])
    
    case addPose(name: String, bindings: [String: BindingOverride])
}
