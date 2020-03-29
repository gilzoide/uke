//
//  UIView+LayerProperties.swift
//  Uke
//
//  Created by Gil Reis on 29/03/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit

public extension UIView {
    @objc var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set { layer.borderColor = newValue?.cgColor }
    }
    @objc var borderWidth: CGFloat {
        get { layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @objc var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    @objc var anchorPoint: CGPoint {
        get { layer.anchorPoint }
        set { layer.anchorPoint = newValue }
    }
}
