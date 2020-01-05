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
        
        if let url = Bundle.main.url(forResource: "rounded-corner", withExtension: "txt"), let v = UkeView(url: url) {
            v.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
            v.backgroundColor = UIColor.red
            view.addSubview(v)
        }
    }


}

