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
            .property("color", type: UIColor.self, initialValue: UIColor.label),
            .constant("frame", CGRect(x: 10, y: 10, width: 400, height: 400)),
            .sameValue("backgroundColor", as: "color"),
        ])
        
        ukeView = recipe.instantiate()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        ukeView.addGestureRecognizer(tapGesture)
        safeView.addSubview(ukeView)
    }
    
    var big = false
    @objc func onTap(_ sender: Any?) {
//        try! ukeView.apply(poseNamed: big ? "default" : "big")
//        big = !big
        
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

