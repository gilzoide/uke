//
//  UkeRecipeInstruction.swift
//  Uke
//
//  Created by Gil Reis on 29/03/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit

public enum UkeRecipeInstruction {
    case property(String, type: Any.Type, initialValue: Any? = nil)
    
    case constant(String, _ value: Any?, runOnLayout: Bool = false)
    case sameValue(String, as: String, runOnLayout: Bool = false)
    case expression(String, format: String, dependencyKeyPaths: [String] = [], runOnLayout: Bool = false)
    
    case subview(String, UIView.Type = UIView.self, recipe: [UkeRecipeInstruction])
    case sublayer(String, CALayer.Type = CALayer.self, recipe: [UkeRecipeInstruction])
    
    case pose(String, bindings: [PoseBinding])
}
