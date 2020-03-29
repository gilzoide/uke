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
            .defineProperty(name: "color", type: UIColor.self),
            .setValue(UIColor.label, keyPath: "backgroundColor"),
            .bindExpression(name: "width", format: "%K", dependencyKeyPaths: ["height"], runOnLayout: true),
            .setValue(500, keyPath: "height"),
        ])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        ukeView.addGestureRecognizer(tapGesture)
        safeView.addSubview(ukeView)
    }
    
    @objc func onTap(_ sender: Any?) {
        if ukeView.height > 1000 {
           ukeView.height = 100
        }
        else {
            ukeView.height += 100
        }
    }
}

