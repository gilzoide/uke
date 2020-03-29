//
//  UkeView.swift
//  Uke
//
//  Created by Gil on 1/5/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit

public enum UkeViewError: Error {
    case propertyAlreadyExists(String)
    case bindingAlreadyExists(String)
}

public class UkeView : UIView {
    class Property {
        var name: String
        var type: Any.Type
        var value: Any?
        init(name: String, type: Any.Type, value: Any? = nil) {
            self.name = name
            self.type = type
            self.value = value
        }
    }
    
    private var properties: [String: Property] = [:]
    private var dependencies: [String: [String]] = [:]
    private var bindings: [String: NSExpression] = [:]
    private var layoutBindings: [String: NSExpression] = [:]
    private var children: [String: Any] = [:]
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public convenience init(fromRecipe instructions: [RecipeInstruction]) throws {
        self.init(frame: CGRect.zero)
        
        let objectStack = [self]
        for instruction in instructions {
            switch instruction {
            case .defineProperty(let name, let type, let initialValue):
                try defineProperty(named: name, ofType: type, initialValue: initialValue)
            case .setValue(let value, let keyPath):
                objectStack.last!.setValue(value, forKeyPath: keyPath)
            case .bindExpression(let name, let format, let dependencyKeyPaths, let runOnLayout):
                if bindings[name] != nil || layoutBindings[name] != nil {
                    throw UkeViewError.bindingAlreadyExists(name)
                }
                let expression = NSExpression(format: format, argumentArray: dependencyKeyPaths)
                if !dependencyKeyPaths.isEmpty {
                    for keyPath in dependencyKeyPaths {
                        var deps = dependencies[keyPath, default: []]
                        deps.append(name)
                        dependencies.updateValue(deps, forKey: keyPath)
                    }
                    if runOnLayout {
                        layoutBindings[name] = expression
                    }
                    else {
                        bindings[name] = expression
                    }
                }
                else {
                    let value = expression.expressionValue(with: self, context: nil)
                    setValue(value, forKey: name)
                }
            default:
                break
            }
        }
    }
    
    func defineProperty(named name: String, ofType type: Any.Type, initialValue: Any? = nil) throws {
        if properties[name] != nil {
            throw UkeViewError.propertyAlreadyExists(name)
        }
        properties[name] = Property(name: name, type: type, value: initialValue)
    }
    
    public override func setValue(_ value: Any?, forKeyPath keyPath: String) {
        super.setValue(value, forKeyPath: keyPath)
        resolveDependencies(forKeyPath: keyPath)
    }
    
    public override func setValue(_ value: Any?, forUndefinedKey key: String) {
        guard let property = properties[key] else { return super.setValue(value, forUndefinedKey: key) }
        property.value = value
    }
    
    public override func value(forUndefinedKey key: String) -> Any? {
        if let property = properties[key] { return property.value }
        else { return super.value(forUndefinedKey: key) }
    }
    
    func resolveDependencies(forKeyPath keyPath: String) {
        guard let deps = dependencies[keyPath] else { return }
        for d in deps {
            if let binding = bindings[d] {
                let value = binding.expressionValue(with: self, context: nil)
                setValue(value, forKey: d)
            }
            if layoutBindings[d] != nil {
                setNeedsLayout()
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        for (keyPath, expression) in layoutBindings {
            let value = expression.expressionValue(with: self, context: nil)
            setValue(value, forKeyPath: keyPath)
        }
    }
}
