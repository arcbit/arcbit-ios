//
//  TLTxFeeAPI.swift
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

enum TLDynamicFeeSetting:String {
    case FastestFee  = "0"
    case HalfHourFee = "1"
    case HourFee     = "2"

    static func getAPIValue(dynamicFeeSetting: TLDynamicFeeSetting) -> String {
        if dynamicFeeSetting == FastestFee {
            return "fastestFee"
        } else if dynamicFeeSetting == HalfHourFee {
            return "halfHourFee"
        } else if dynamicFeeSetting == HourFee {
            return "hourFee"
        }
        
        return ""
    }
}

class TLTxFeeAPI {
    
    var networking:TLNetworking
    init() {
        self.networking = TLNetworking()
    }

    func getDynamicTxFee(success:TLNetworking.SuccessHandler, failure:TLNetworking.FailureHandler)-> () {
        DLog("TLTxFeeAPI getDynamicTxFee")
        self.networking.httpGET(NSURL(string: "https://bitcoinfees.21.co/api/v1/fees/recommended")!,
            parameters:[:], success:success, failure:failure)
    }
}