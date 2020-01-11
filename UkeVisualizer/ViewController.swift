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
        
        let recipe = UkeRecipe()
        recipe.addConstant(UIColor.label, forKeyPath: "backgroundColor")
        recipe.addConstant(10, forKeyPath: "layer.cornerRadius")
        recipe.addForwarding(from: "center", to: "size")
        
        
        let v = recipe.instantiate()
        v.center = CGPoint(x: 200, y: 200)
        view.addSubview(v)
        
        let v2 = recipe.instantiate()
        v2.center = CGPoint(x: 50, y: 70)
        view.addSubview(v2)
    }


}

