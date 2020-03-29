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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = try! UkeView(fromRecipe: [
            .defineProperty(name: "color", type: UIColor.self),
            .setValue(0.5, keyPath: "layer.opacity")
        ])
        self.view.addSubview(view)
    }


}

