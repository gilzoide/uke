//
//  ViewController.swift
//  UkeVisualizer
//
//  Created by Gil on 1/5/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit
import Uke

class ViewController: UIViewController {
    @IBOutlet var safeView: UIView!
    
    var ukeView: UkeView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ukeView = try! UkeView(fromRecipe: [
            .setValue(CGPoint.zero, keyPath: "anchorPoint"),
            .defineProperty(name: "color", type: UIColor.self),
            .bindExpression(name: "backgroundColor", format: "%K", dependencyKeyPaths: ["color"]),
            .setValue(UIColor.label, keyPath: "color"),
            .bindExpression(name: "width", format: "%K", dependencyKeyPaths: ["height"], runOnLayout: true),
            .setValue(500, keyPath: "height"),
            
            .pushView(name: "inner"),
            .bindExpression(name: "center", format: "%K", dependencyKeyPaths: ["boundsCenter"], runOnLayout: true),
            .bindExpression(name: "width", format: "%K - 16", dependencyKeyPaths: ["width"], runOnLayout: true),
            .bindExpression(name: "height", format: "%K - 16", dependencyKeyPaths: ["height"], runOnLayout: true),
            .bindExpression(name: "layer.cornerRadius", format: "floor(%K * 0.5)", dependencyKeyPaths: ["inner.minDimension"], runOnLayout: true),
            .setValue(UIColor.black, keyPath: "backgroundColor"),
            .addChild,
        ])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        ukeView.addGestureRecognizer(tapGesture)
        safeView.addSubview(ukeView)
    }
    
    @objc func onTap(_ sender: Any?) {
        if ukeView.height > 800 {
           ukeView.height = 100
        }
        else {
            ukeView.height += 100
        }
    }
}

