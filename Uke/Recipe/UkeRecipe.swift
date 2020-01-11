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
    private var forwardDependencies: [String: [String]] = [:]
    
    @objc public func addObjectRecipe(_ recipe: UkeObjectRecipe, identifiedBy identifier: String? = nil) {
        let key = identifier ?? String(format: "_%d", objectsRecipes.count)
        objectsRecipes[key] = recipe
    }
    
    public func addForwarding(from keyPath: String, to forwardKeyPath: String) {
        if forwardDependencies[keyPath] == nil {
           forwardDependencies[keyPath] = []
        }
        forwardDependencies[keyPath]?.append(forwardKeyPath)
    }
    
    override public init() {
        super.init(baseClass: UkeView.self)
    }
    
    override public func instantiate() -> UkeView {
        let view = super.instantiate() as! UkeView
        for keyPath in forwardDependencies.keys {
            view.addObserver(self, forKeyPath: keyPath, options: .new, context: nil)
        }
        return view
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, let object = object as? NSObject, let newValue = change?[.newKey] {
            if let forwardList = forwardDependencies[keyPath] {
                for forwardKeyPath in forwardList {
                    object.setValue(newValue, forKeyPath: forwardKeyPath)
                }
            }
        }
    }
}
