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
    case constant(_ keyPath: String, _ value: Any?)
    case expression(String, format: String, dependencyKeyPaths: [String] = [], runOnLayout: Bool = false)
    case subview(String, UIView.Type = UIView.self, recipe: [UkeRecipeInstruction])
    case sublayer(String, CALayer.Type = CALayer.self, recipe: [UkeRecipeInstruction])
    
    case pose(String, bindings: [PoseBinding])
}
