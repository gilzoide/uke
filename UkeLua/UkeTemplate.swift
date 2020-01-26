//
//  UkeTemplate.swift
//  UkeLua
//
//  Created by Gil on 1/15/20.
//  Copyright © 2020 Gil. All rights reserved.
//

import Foundation

@objc public class UkeTemplate : NSObject {
    @objc var name: String
    
    @objc public init(name: String) {
        self.name = name
    }
}
