//
//  Recipe.swift
//  Uke
//
//  Created by Gil on 1/8/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit


class Property {
    var name: String
    var type: Any.Type
    var initialValue: Any?
    
    init(name: String, type: Any.Type, initialValue: Any?) {
        self.name = name
        self.type = type
        self.initialValue = initialValue
    }
}

public enum UkeRecipeError: Error {
    case propertyAlreadyExists(String)
    case bindingAlreadyExists(String)
    case invalidChildType(AnyClass)
    case invalidPropertyValue(String, expectedType: Any.Type, foundType: Any.Type)
}

enum ChildType {
    case pushView(UIView.Type)
    case pushLayer(CALayer.Type)
    case pop
}

enum Binding {
    case property(Property)
    case initialValue(Any?)
    case immediateExpression(NSExpression)
    case layoutExpression(NSExpression)
    case child(ChildType)
}


public class UkeRecipe {
    static let POP_CHILD_KEY = "__UkeRecipe.popChild"
    static let LAYOUT_TRIGGER_KEYPATHS: Set = ["frame", "bounds", "size", "height", "width"]
    
    var bindings: [String: Binding] = [
        POP_CHILD_KEY: .child(.pop)
    ]
    
    var properties: [String] = []
    var initialValues: [String] = []
    var dependencies: [String: [String]] = [:]
    var immediateBindings: [String] = []
    var layoutBindings: [String] = []
    var children: [String] = []
    
    public init(instructions: [RecipeInstruction]) throws {
        for instruction in instructions {
            try runInstruction(instruction, currentIdentifier: nil)
        }
    }
    
    // MARK: View Instances
    public func instance() -> UkeView {
        return UkeView(fromRecipe: self)
    }
    
    func setInitialValues(_ view: UkeView) {
        view.runBypassingDependencyResolution {
            var parentStack: [AnyObject] = [view]
            for name in children {
                if let binding = bindings[name], case Binding.child(let childOperation) = binding {
                    switch childOperation {
                    case .pushView(let viewType):
                        if let parent = parentStack.last as? UIView {
                            let subview = viewType.init()
                            parent.addSubview(subview)
                            parentStack.append(subview)
                            view.children[name] = subview
                        }
                    case .pushLayer(let layerType):
                        let parent = parentStack.last
                        if let parent = (parent as? CALayer) ?? (parent as? UIView)?.layer{
                            let sublayer = layerType.init()
                            parent.addSublayer(sublayer)
                            parentStack.append(sublayer)
                            view.children[name] = sublayer
                        }
                    case .pop:
                        let _ = parentStack.popLast()
                    }
                }
            }
            for name in initialValues {
                if let binding = bindings[name] {
                    switch binding {
                    case Binding.property(let property):
                        view.setValue(property.initialValue, forKeyPath: name)
                    case Binding.initialValue(let value):
                        view.setValue(value, forKeyPath: name)
                    default:
                        break
                    }
                }
            }
            for name in immediateBindings {
                if let binding = bindings[name], case Binding.immediateExpression(let expression) = binding {
                    let value = expression.expressionValue(with: view, context: nil)
                    view.setValue(value, forKeyPath: name)
                }
            }
            if layoutBindings.count > 0 {
                view.setNeedsLayout()
            }
        }
    }
    
    func resolveDependencies(forTarget target: UkeView, keyPath: String) {
        if UkeRecipe.LAYOUT_TRIGGER_KEYPATHS.contains(keyPath) {
            target.setNeedsLayout()
        }
        if let dependencies = dependencies[keyPath] {
            for d in dependencies {
                switch bindings[d] {
                case .immediateExpression(let expression):
                    let value = expression.expressionValue(with: target, context: nil)
                    target.setValue(value, forKeyPath: d)
                case .layoutExpression(_):
                    target.setNeedsLayout()
                default:
                    break
                }
            }
        }
    }
    
    func layoutExpressions() -> [(String, NSExpression)] {
        return layoutBindings.map { (name) -> (String, NSExpression) in
            if case let Binding.layoutExpression(expression) = bindings[name]! {
                return (name, expression)
            }
            return (name, NSExpression())
        }
    }
    
    func isValid(property name: String, value: Any?) -> Bool {
        if let binding = bindings[name], case Binding.property(_) = binding {
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: Private
    func runInstruction(_ instruction: RecipeInstruction, currentIdentifier: String?) throws {
        switch instruction {
        case .defineProperty(let name, let type, let initialValue):
            try assureNotBound(name: name)
            bindings[name] = .property(Property(name: name, type: type, initialValue: initialValue))
            properties.append(name)
            initialValues.append(name)
        case .setValue(let value, let keyPath):
            let childName = currentIdentifier?.appending(".") ?? ""
            let fullName = "\(childName)\(keyPath)"
            try assureNotBound(name: fullName)
            bindings[fullName] = .initialValue(value)
            initialValues.append(fullName)
        case .bindExpression(let name, let format, let dependencyKeyPaths, let runOnLayout):
            let childName = currentIdentifier?.appending(".") ?? ""
            let fullName = "\(childName)\(name)"
            try assureNotBound(name: fullName)
            
            let expression = NSExpression(format: format, argumentArray: dependencyKeyPaths)
            if !dependencyKeyPaths.isEmpty {
                for keyPath in dependencyKeyPaths {
                    if runOnLayout && UkeRecipe.LAYOUT_TRIGGER_KEYPATHS.contains(keyPath) {
                        continue
                    }
                    var deps = dependencies[keyPath, default: []]
                    deps.append(fullName)
                    dependencies.updateValue(deps, forKey: keyPath)
                }
                if runOnLayout {
                    bindings[fullName] = .layoutExpression(expression)
                    layoutBindings.append(fullName)
                }
                else {
                    bindings[fullName] = .immediateExpression(expression)
                    immediateBindings.append(fullName)
                }
            }
            else {
                let value = expression.expressionValue(with: self, context: nil)
                bindings[fullName] = .initialValue(value)
                initialValues.append(fullName)
            }
        case .pushView(let name, let viewType, let recipe):
            try assureNotBound(name: name)
            bindings[name] = .child(.pushView(viewType))
            children.append(name)
            for instruction in recipe {
                try runInstruction(instruction, currentIdentifier: name)
            }
            children.append(UkeRecipe.POP_CHILD_KEY)
        case .pushLayer(let name, let layerType, let recipe):
            try assureNotBound(name: name)
            bindings[name] = .child(.pushLayer(layerType))
            children.append(name)
            for instruction in recipe {
                try runInstruction(instruction, currentIdentifier: name)
            }
            children.append(UkeRecipe.POP_CHILD_KEY)
        }
    }
    
    func assureNotBound(name: String) throws {
        if bindings[name] != nil {
            throw UkeRecipeError.bindingAlreadyExists(name)
        }
    }
}
