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
    case bindingNotFound(String)
    case invalidBindingOverrideType
    case poseNotFound(String)
}

enum ChildType {
    case pushView(UIView.Type)
    case pushLayer(CALayer.Type)
    case pop
}

enum RecipeBinding {
    case property(Property)
    case initialValue(Any?)
    case sameValue(as: String)
    case immediateExpression(NSExpression)
    case layoutExpression(NSExpression)
    case child(ChildType)
    
    func toBindingInstruction() -> BindingInstruction? {
        switch self {
        case .property(_):
            return nil
        case .initialValue(let value):
            return BindingInstruction.constantValue(value)
        case .sameValue(let keyPath):
            return BindingInstruction.sameValue(as: keyPath)
        case .immediateExpression(let expression):
            return BindingInstruction.immediateExpression(expression)
        case .layoutExpression(let expression):
            return BindingInstruction.layoutExpression(expression)
        case .child(_):
            return nil
        }
    }
}

public enum BindingInstruction {
    case constantValue(Any?)
    case sameValue(as: String)
    case immediateExpression(NSExpression)
    case layoutExpression(NSExpression)
}

public typealias PoseBinding = (String, BindingInstruction)

class Pose {
    var name: String
    var bindingOverrides: [String: BindingInstruction]
    var bindingOverrideOrder: [String]
    
    init(name: String, overrides: [PoseBinding] = []) {
        self.name = name
        self.bindingOverrideOrder = overrides.map({ $0.0 })
        self.bindingOverrides = Dictionary(uniqueKeysWithValues: overrides)
    }
}


public class UkeRecipe {
    static let POP_CHILD_KEY = "__UkeRecipe.popChild"
    static let LAYOUT_TRIGGER_KEYPATHS: Set = ["frame", "bounds", "size", "height", "width"]
    static let DEFAULT_POSE_NAME = "default"
    
    var bindings: [String: RecipeBinding] = [
        POP_CHILD_KEY: .child(.pop)
    ]
    
    var properties: [String] = []
    var initialValues: [String] = []
    var dependencies: [String: [String]] = [:]
    var copyBindings: [String] = []
    var immediateBindings: [String] = []
    var layoutBindings: [String] = []
    var children: [String] = []
    
    var defaultPose = Pose(name: DEFAULT_POSE_NAME)
    var currentPose: Pose
    var poses: [String: Pose] = [:]
    
    public init(instructions: [UkeRecipeInstruction]) throws {
        poses[UkeRecipe.DEFAULT_POSE_NAME] = defaultPose
        currentPose = defaultPose
        for instruction in instructions {
            try runInstruction(instruction, currentIdentifier: nil)
        }
    }
    
    public func instantiate() -> UkeView {
        return UkeView(fromRecipe: self)
    }
    
    // MARK: View Instances
    func applyInitialValues(_ view: UkeView) {
        view.runBypassingDependencyResolution {
            var parentStack: [AnyObject] = [view]
            for name in children {
                if let binding = bindings[name], case RecipeBinding.child(let childOperation) = binding {
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
                    case RecipeBinding.property(let property):
                        view[name] = property.initialValue
                    case RecipeBinding.initialValue(let value):
                        view[name] = value
                    default:
                        break
                    }
                }
            }
            for name in copyBindings {
                if let binding = bindings[name], case RecipeBinding.sameValue(let keyPath) = binding {
                    view[name] = view[keyPath]
                }
            }
            for name in immediateBindings {
                if let binding = bindings[name], case RecipeBinding.immediateExpression(let expression) = binding {
                    let value = expression.expressionValue(with: view, context: nil)
                    view[name] = value
                }
            }
            if layoutBindings.count > 0 {
                view.setNeedsLayout()
            }
        }
    }
    
    func apply(poseNamed name: String, toView view: UkeView) throws {
        guard let pose = poses[name] else {
            throw UkeRecipeError.poseNotFound(name)
        }
        apply(pose: pose, toView: view)
    }
    
    func apply(pose: Pose, toView view: UkeView) {
        guard currentPose !== pose else { return }
        currentPose = pose
        for keyPath in pose.bindingOverrideOrder {
            view.apply(binding: pose.bindingOverrides[keyPath]!, forKeyPath: keyPath)
        }
    }
    
    func resolveDependencies(forTarget view: UkeView, keyPath: String) {
        if UkeRecipe.LAYOUT_TRIGGER_KEYPATHS.contains(keyPath) {
            view.setNeedsLayout()
        }
        if let dependencies = dependencies[keyPath] {
            for d in dependencies {
                if let binding = currentPose.bindingOverrides[d] ?? bindings[d]?.toBindingInstruction() {
                    switch binding {
                    case .sameValue(_):
                        view[d] = view[keyPath]
                    case .immediateExpression(let expression):
                        let value = expression.expressionValue(with: view, context: nil)
                        view[d] = value
                    case .layoutExpression(_):
                        view.setNeedsLayout()
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func layoutExpressions() -> [(String, NSExpression)] {
        return layoutBindings.map { (name) -> (String, NSExpression) in
            if case let RecipeBinding.layoutExpression(expression) = bindings[name]! {
                return (name, expression)
            }
            return (name, NSExpression())
        }
    }
    
    func isValid(property name: String, value: Any?) -> Bool {
        if let binding = bindings[name], case RecipeBinding.property(_) = binding {
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: Private
    func runInstruction(_ instruction: UkeRecipeInstruction, currentIdentifier: String?) throws {
        switch instruction {
        case .property(let name, let type, let initialValue):
            try assureNotBound(name: name)
            bindings[name] = .property(Property(name: name, type: type, initialValue: initialValue))
            properties.append(name)
            initialValues.append(name)
        case .constant(let keyPath, let value):
            let childName = currentIdentifier?.appending(".") ?? ""
            let fullName = "\(childName)\(keyPath)"
            try assureNotBound(name: fullName)
            bindings[fullName] = .initialValue(value)
            initialValues.append(fullName)
        case .sameValue(let name, let dependencyKeyPath):
            let childName = currentIdentifier?.appending(".") ?? ""
            let fullName = "\(childName)\(name)"
            try assureNotBound(name: fullName)
            bindings[fullName] = .sameValue(as: dependencyKeyPath)
            addDependency(fullName, forKeyPath: dependencyKeyPath)
            copyBindings.append(fullName)
        case .expression(let name, let format, let dependencyKeyPaths, let runOnLayout):
            let childName = currentIdentifier?.appending(".") ?? ""
            let fullName = "\(childName)\(name)"
            try assureNotBound(name: fullName)
            
            let expression = NSExpression(format: format, argumentArray: dependencyKeyPaths)
            if !dependencyKeyPaths.isEmpty {
                for keyPath in dependencyKeyPaths {
                    if runOnLayout && UkeRecipe.LAYOUT_TRIGGER_KEYPATHS.contains(keyPath) {
                        continue
                    }
                    addDependency(fullName, forKeyPath: keyPath)
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
        case .subview(let name, let viewType, let recipe):
            try assureNotBound(name: name)
            bindings[name] = .child(.pushView(viewType))
            children.append(name)
            for instruction in recipe {
                try runInstruction(instruction, currentIdentifier: name)
            }
            children.append(UkeRecipe.POP_CHILD_KEY)
        case .sublayer(let name, let layerType, let recipe):
            try assureNotBound(name: name)
            bindings[name] = .child(.pushLayer(layerType))
            children.append(name)
            for instruction in recipe {
                try runInstruction(instruction, currentIdentifier: name)
            }
            children.append(UkeRecipe.POP_CHILD_KEY)
        case .pose(let name, let overrides):
            if poses[name] != nil {
                throw UkeRecipeError.bindingAlreadyExists(name)
            }
            for (key, override) in overrides {
                let binding = bindings[key]?.toBindingInstruction()
                switch (binding, override) {
                case (nil, .constantValue(_)):
                    if defaultPose.bindingOverrides[key] == nil {
                        defaultPose.bindingOverrides[key] = .constantValue(nil)
                    }
                case (nil, _):
                    throw UkeRecipeError.bindingNotFound(key)
                case (.some(.constantValue(_)), .constantValue(_)),
                     (.some(.immediateExpression(_)), .immediateExpression(_)),
                     (.some(.layoutExpression(_)), .layoutExpression(_)):
                    if defaultPose.bindingOverrides[key] == nil {
                        defaultPose.bindingOverrides[key] = binding!
                    }
                default:
                    throw UkeRecipeError.invalidBindingOverrideType
                }
            }
            poses[name] = Pose(name: name, overrides: overrides)
        }
    }
    
    func addDependency(_ name: String, forKeyPath keyPath: String) {
        var deps = dependencies[keyPath, default: []]
        deps.append(name)
        dependencies.updateValue(deps, forKey: keyPath)
    }
    
    func assureNotBound(name: String) throws {
        if bindings[name] != nil {
            throw UkeRecipeError.bindingAlreadyExists(name)
        }
    }
}
