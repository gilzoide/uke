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
            .defineProperty(name: "side", type: CGFloat.self, initialValue: 100),
            .defineProperty(name: "color", type: UIColor.self, initialValue: UIColor.green),
            .defineProperty(name: "bgColor", type: UIColor.self, initialValue: UIColor.white),
            .setValue(nil, keyPath: "backgroundColor"),
            .setValue(CGPoint.zero, keyPath: "anchorPoint"),
            .bindExpression(name: "width", format: "%K", dependencyKeyPaths: ["side"], runOnLayout: true),
            .bindExpression(name: "height", format: "%K", dependencyKeyPaths: ["side"], runOnLayout: true),
            
            .pushView(name: "background"),
            .bindExpression(name: "backgroundColor", format: "%K", dependencyKeyPaths: ["bgColor"]),
            .bindExpression(name: "borderColor", format: "%K", dependencyKeyPaths: ["color"]),
            .setValue(5, keyPath: "borderWidth"),
            .bindExpression(name: "width", format: "%K", dependencyKeyPaths: ["minDimension"], runOnLayout: true),
            .bindExpression(name: "height", format: "%K", dependencyKeyPaths: ["background.width"], runOnLayout: true),
            .bindExpression(name: "center", format: "%K", dependencyKeyPaths: ["boundsCenter"], runOnLayout: true),
            .bindExpression(name: "cornerRadius", format: "%K * 0.5", dependencyKeyPaths: ["background.width"], runOnLayout: true),
            .addChild,
            
            .pushView(name: "checkImage", UIImageView.self),
            .bindExpression(name: "width", format: "%K * 0.7", dependencyKeyPaths: ["background.width"], runOnLayout: true),
            .bindExpression(name: "height", format: "%K * 0.7", dependencyKeyPaths: ["background.height"], runOnLayout: true),
            .bindExpression(name: "center", format: "%K", dependencyKeyPaths: ["boundsCenter"], runOnLayout: true),
            .bindExpression(name: "tintColor", format: "%K", dependencyKeyPaths: ["color"]),
            .setValue(1, keyPath: "contentMode"),
            .setValue(UIImage(named: "check"), keyPath: "image"),
            .addChild,
        ])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        ukeView.addGestureRecognizer(tapGesture)
        safeView.addSubview(ukeView)
    }
    
    @objc func onTap(_ sender: Any?) {
        let side = ukeView.value(forKey: "side") as! Int
        if side > 800 {
            ukeView.setValue(100, forKeyPath: "side")
        }
        else {
            ukeView.setValue(side + 100, forKeyPath: "side")
        }
    }
}

