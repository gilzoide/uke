//
//  UkeView.swift
//  Uke
//
//  Created by Gil on 1/5/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit

public class UkeView : UIView {
    var recipe: UkeRecipe!
    var properties: [String: Any?] = [:]
    var children: [String: Any] = [:]
    private var bypassDependencyResolution: Bool = false
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public convenience init(fromRecipe recipe: UkeRecipe) {
        self.init(frame: CGRect.zero)
        self.recipe = recipe
        recipe.applyInitialValues(self)
    }
    
    public func apply(poseNamed name: String) throws {
        try recipe.apply(poseNamed: name, toView: self)
    }
    
    public func value(forBinding binding: BindingInstruction) -> Any? {
        switch binding {
        case .constantValue(let value), .layoutConstantValue(let value):
            return value
        case .sameValue(let keyPath), .layoutSameValue(let keyPath):
            return self[keyPath]
        case .immediateExpression(let expression), .layoutExpression(let expression):
            return expression.expressionValue(with: self, context: nil)
        }
    }
    
    public func apply(binding: BindingInstruction, forKeyPath keyPath: String) {
        if case .layoutExpression(_) = binding  {
            setNeedsLayout()
        }
        else {
            self[keyPath] = self.value(forBinding: binding)
        }
    }
    
    public subscript(_ keyPath: String) -> Any? {
        get { value(forKeyPath: keyPath) }
        set { setValue(newValue, forKeyPath: keyPath) }
    }
    
    public override func setValue(_ value: Any?, forKeyPath keyPath: String) {
        super.setValue(value, forKeyPath: keyPath)
        resolveDependencies(forKeyPath: keyPath)
    }
    
    public override func setValue(_ value: Any?, forUndefinedKey key: String) {
        guard recipe.isValid(property: key, value: value) else { return super.setValue(value, forUndefinedKey: key) }
        properties[key] = value
    }
    
    public override func value(forUndefinedKey key: String) -> Any? {
        return properties[key] ?? children[key] ?? super.value(forUndefinedKey: key)
    }
    
    func runBypassingDependencyResolution(closure: () -> Void) {
        bypassDependencyResolution = true
        closure()
        bypassDependencyResolution = false
    }
    
    func resolveDependencies(forKeyPath keyPath: String) {
        guard !bypassDependencyResolution else { return }
        recipe.resolveDependencies(forTarget: self, keyPath: keyPath)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        runBypassingDependencyResolution {
            for (keyPath, binding) in recipe.layoutBindingInstructions() {
                self[keyPath] = self.value(forBinding: binding)
            }
        }
    }
}
