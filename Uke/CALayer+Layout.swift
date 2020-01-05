//
//  CALayer+Layout.swift
//  Uke
//
//  Created by Gil on 1/5/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit

public extension CALayer {
    @objc var width: CGFloat {
        get { return bounds.width }
        set { bounds = CGRect(x: 0, y: 0, width: newValue, height: bounds.height) }
    }
    @objc var height: CGFloat {
        get { return bounds.height }
        set { bounds = CGRect(x: 0, y: 0, width: bounds.width, height: newValue) }
    }
    
    @objc var minDimension: CGFloat {
        return min(width, height)
    }
    @objc var maxDimension: CGFloat {
        return max(width, height)
    }
}

