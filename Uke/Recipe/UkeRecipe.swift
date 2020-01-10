//
//  Recipe.swift
//  Uke
//
//  Created by Gil on 1/8/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit

@objc class UkeRecipe : UkeObjectRecipe {
    private var parameters: [String: Any.Type] = [:]
    private var objectsRecipes: [String: UkeObjectRecipe] = [:]
    private var keyPathExpression: [String: NSExpression] = [:]
    
    @objc public func addObjectRecipe(_ recipe: UkeObjectRecipe, identifiedBy identifier: String? = nil) {
        let key = identifier ?? String(objectsRecipes.count)
        objectsRecipes[key] = recipe
    }
    
    override init() {
        super.init(baseClass: UkeView.self)
    }
    
    override public func instantiate() -> UkeView {
        let view = super.instantiate() as! UkeView
        return view
    }
}
