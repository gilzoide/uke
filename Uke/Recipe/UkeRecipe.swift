//
//  Recipe.swift
//  Uke
//
//  Created by Gil on 1/8/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit

@objc public class UkeRecipe : UkeObjectRecipe {
    private var parameters: [String: Any.Type] = [:]
    private var objectsRecipes: [String: UkeObjectRecipe] = [:]
    private var dependencies: [String: [(String, NSExpression?)]] = [:]
    
    @objc public func addObjectRecipe(_ recipe: UkeObjectRecipe, identifiedBy identifier: String? = nil) {
        let key = identifier ?? String(format: "_%d", objectsRecipes.count)
        objectsRecipes[key] = recipe
    }
    
    public func addDependency(from keyPath: String, to forwardKeyPath: String, usingExpression expression: NSExpression? = nil) {
        if dependencies[keyPath] == nil {
           dependencies[keyPath] = []
        }
        dependencies[keyPath]?.append((forwardKeyPath, expression))
    }
    
    override public init() {
        super.init(baseClass: UkeView.self)
    }
    
    override public func instantiate() -> UkeView {
        let view = super.instantiate() as! UkeView
        for keyPath in dependencies.keys {
            view.addObserver(self, forKeyPath: keyPath, options: .new, context: nil)
        }
        return view
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, let object = object as? NSObject, let newValue = change?[.newKey] {
            if let dependencyList = dependencies[keyPath] {
                for (dependencyKeyPath, expression) in dependencyList {
                    var value: Any? = newValue
                    if let expression = expression {
                        value = expression.expressionValue(with: object, context: nil)
                    }
                    object.setValue(value, forKeyPath: dependencyKeyPath)
                }
            }
        }
    }
}
