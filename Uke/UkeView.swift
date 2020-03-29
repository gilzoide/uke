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
    private var children: [String: Any] = [:]
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public convenience init(fromRecipe instructions: [RecipeInstruction]) throws {
        self.init(frame: CGRect.zero)
        
        for instruction in instructions {
            switch instruction {
            case .defineProperty(let name, let type, let initialValue):
                try defineProperty(named: name, ofType: type, initialValue: initialValue)
            case .setValue(let value, let keyPath):
                setValue(value, forKeyPath: keyPath)
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
    
    override public func setValue(_ value: Any?, forUndefinedKey key: String) {
        guard let property = properties[key] else { return super.setValue(value, forUndefinedKey: key) }
        property.value = value
    }
}
