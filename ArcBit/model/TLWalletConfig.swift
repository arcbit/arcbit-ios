//
//  TLWalletConfig.swift
//  ArcBit
//
//  Created by Tim Lee on 8/27/15.
//  Copyright (c) 2015 ArcBit. All rights reserved.
//

import Foundation

class TLWalletConfig {
    var isTestnet:Bool = false

    init(isTestnet:Bool) {
        self.isTestnet = isTestnet
    }
}
