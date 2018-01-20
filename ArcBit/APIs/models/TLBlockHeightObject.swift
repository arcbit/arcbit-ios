//
//  TLBlockHeightObject.swift
//  ArcBit
//
//  Created by Timothy Lee on 1/16/18.
//  Copyright © 2018 ArcBit. All rights reserved.
//

import Foundation

class TLBlockHeightObject {
    
    let blockHeight:UInt64
    
    init(jsonDict: Dictionary<String, AnyObject>) {
        self.blockHeight = jsonDict["height"] as! UInt64
    }
}
