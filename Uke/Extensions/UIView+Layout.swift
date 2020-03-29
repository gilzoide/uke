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
        get { return bounds.width }
        set { bounds = CGRect(x: 0, y: 0, width: newValue, height: bounds.height) }
    }
    @objc var height: CGFloat {
        get { return bounds.height }
        set { bounds = CGRect(x: 0, y: 0, width: bounds.width, height: newValue) }
    }
    
    @objc var anchorPoint: CGPoint {
        get { return layer.anchorPoint }
        set { layer.anchorPoint = newValue }
    }
    
    @objc var size: CGSize {
        get { return bounds.size }
        set { bounds = CGRect(x: 0, y: 0, width: newValue.width, height: newValue.height) }
    }
    
    @objc var boundsCenter: CGPoint {
        let bounds = self.bounds
        return CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
    }
    @objc class func keyPathsForValuesAffectingBoundsCenter() -> Set<String> {
        return Set(["width", "height", "bounds"])
    }
    
    @objc var minDimension: CGFloat {
        return min(width, height)
    }
    @objc var maxDimension: CGFloat {
        return max(width, height)
    }
    @objc class func keyPathsForValuesAffectingMinDimension() -> Set<String> {
        return Set(["width", "height", "bounds"])
    }
    @objc class func keyPathsForValuesAffectingMaxDimension() -> Set<String> {
        return Set(["width", "height", "bounds"])
    }
}
