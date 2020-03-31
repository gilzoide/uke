//
//  UIView+Layout.swift
//  Uke
//
//  Created by Gil on 1/5/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit

public extension UIView {
    @objc var width: CGFloat {
        get { bounds.width }
        set { bounds = CGRect(x: 0, y: 0, width: newValue, height: bounds.height) }
    }
    @objc var height: CGFloat {
        get { bounds.height }
        set { bounds = CGRect(x: 0, y: 0, width: bounds.width, height: newValue) }
    }
    
    @objc var origin: CGPoint {
        get { frame.origin }
        set { frame = CGRect(origin: newValue, size: frame.size) }
    }
    @objc var size: CGSize {
        get { bounds.size }
        set { bounds = CGRect(origin: bounds.origin, size: newValue) }
    }
    
    @objc var boundsCenter: CGPoint {
        let bounds = self.bounds
        return CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
    }
    
    @objc var minDimension: CGFloat { min(width, height) }
    @objc var maxDimension: CGFloat { max(width, height) }
}
