//
//  ViewController.swift
//  UkeVisualizer
//
//  Created by Gil on 1/5/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit
import UkeLua

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let engine = UkeEngine()
        let _ = engine.templateNamed("rounded-corner")
    }


}

