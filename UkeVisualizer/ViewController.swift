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
        
        if let url = Bundle.main.url(forResource: "rounded-corner", withExtension: "txt"),
            let contents = try? String(contentsOf: url),
            let recipe = Reader.read(contents),
            let v = recipe.instantiate() as? UkeView {
            view.addSubview(v)
        }
    }


}

