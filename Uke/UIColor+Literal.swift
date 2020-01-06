//
//  UIColor+Literal.swift
//  Uke
//
//  Created by Gil on 1/6/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit

public extension UIColor {
    @objc static func color(selectorName: String) -> UIColor? {
        let selectorName = selectorName.hasSuffix("Color") ? selectorName : selectorName.appending("Color")
        let selector = Selector(selectorName)
        return UIColor.responds(to: selector) ? UIColor.perform(selector)?.takeRetainedValue() as? UIColor : nil
    }
    
    @objc static func color(hexaString: String) -> UIColor? {
        let scanner = Scanner(string: hexaString)
        if let int = scanner.scanInt(representation: .hexadecimal) {
            return color(hexa: int)
        }
        return nil
    }
    
    @objc static func color(hexa: Int) -> UIColor {
        let r = CGFloat((hexa & 0xff0000) >> 16) / 255.0
        let g = CGFloat((hexa & 0x00ff00) >>  8) / 255.0
        let b = CGFloat((hexa & 0x0000ff) >>  0) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
