//
//  TLUpdateAppData.swift
//  ArcBit
//
//  Created by Tim Lee on 8/20/15.
//  Copyright (c) 2015 ArcBit. All rights reserved.
//

import Foundation

class TLUpdateAppData {
    struct STATIC_MEMBERS {
        static var instance:TLUpdateAppData?
    }
    
    var beforeUpdatedAppVersion: String? = nil
    
    class func instance() -> (TLUpdateAppData) {
        if(STATIC_MEMBERS.instance == nil) {
            STATIC_MEMBERS.instance = TLUpdateAppData()
        }
        return STATIC_MEMBERS.instance!
    }
}
