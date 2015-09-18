//
//  TLBlockchainStatus.swift
//  ArcBit
//
//  Created by Timothy Lee on 3/14/15.
//  Copyright (c) 2015 Timothy Lee <stequald01@gmail.com>
//
//   This library is free software; you can redistribute it and/or
//   modify it under the terms of the GNU Lesser General Public
//   License as published by the Free Software Foundation; either
//   version 2.1 of the License, or (at your option) any later version.
//
//   This library is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//   Lesser General Public License for more details.
//
//   You should have received a copy of the GNU Lesser General Public
//   License along with this library; if not, write to the Free Software
//   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
//   MA 02110-1301  USA

import Foundation
import UIKit

class TLBlockchainStatus {
    struct STATIC_MEMBERS{
        static var _instance:TLBlockchainStatus? = nil
    }
    
    var blockHeight:UInt64 = 0
    
    class func instance() -> (TLBlockchainStatus) {
        if(STATIC_MEMBERS._instance == nil) {
            STATIC_MEMBERS._instance = TLBlockchainStatus()
        }
        return STATIC_MEMBERS._instance!
    }
}
