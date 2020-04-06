//
//  ViewController.swift
//  UkeVisualizer
//
//  Created by Gil on 1/5/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit
import Uke

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet var safeView: UIView!
    
    var ukeView: UkeView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recipe = try! UkeRecipe(instructions: [
            .constant("backgroundColor", UIColor.red),
            .constant("frame", CGRect(x: 100, y: 100, width: 100, height: 100)),
            
            .pose("bigger", bindings: [
                ("frame", .constantValue(CGRect(x: 100, y: 100, width: 200, height: 200))),
                ("backgroundColor", .constantValue(UIColor.green)),
            ]),
        ])
        
        ukeView = recipe.instantiate()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        ukeView.addGestureRecognizer(tapGesture)
        safeView.addSubview(ukeView)
    }
    
    var big = false
    @objc func onTap(_ sender: Any?) {
        try! ukeView.apply(poseNamed: big ? "default" : "bigger")
        big = !big
//        let side = ukeView.value(forKey: "side") as! Int
//        if side > 800 {
//            ukeView.setValue(100, forKeyPath: "side")
//        }
//        else {
//            ukeView.setValue(side + 100, forKeyPath: "side")
//        }
    }
    
    
    let COLORS = ["label", "red", "green", "blue", "yellow"]
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return COLORS.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return COLORS[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let color = UIColor.color(selectorName: COLORS[row])
        ukeView.setValue(color, forKeyPath: "color")
    }
}

