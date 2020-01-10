//
//  UkeView.swift
//  Uke
//
//  Created by Gil on 1/5/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import UIKit

public class UkeView : UIView {
    private var parameters: [String: Any] = [:]
    private var children: [String: Any] = [:]
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
