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
    
    public init?(url: URL) {
        guard let contents = try? String(contentsOf: url) else { return nil }
        self.init()
        guard Reader.read(contents, into: self) else { return nil }
    }
}
