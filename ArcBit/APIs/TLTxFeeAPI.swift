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
    private var cachedDynamicFees: NSDictionary?
    var cachedDynamicFeesTime: NSTimeInterval?


    init() {
        self.networking = TLNetworking()
    }
    
    func getCachedDynamicFee() -> NSNumber? {
        var dynamicFee:NSNumber? = nil
        if self.cachedDynamicFees != nil {
            let dynamicFeeSetting = TLPreferences.getInAppSettingsKitDynamicFeeSetting()
            if dynamicFeeSetting == TLDynamicFeeSetting.FastestFee {
                dynamicFee = self.cachedDynamicFees!.objectForKey(TLDynamicFeeSetting.getAPIValue(TLDynamicFeeSetting.FastestFee)) as? NSNumber
            } else if dynamicFeeSetting == TLDynamicFeeSetting.HalfHourFee {
                dynamicFee = self.cachedDynamicFees!.objectForKey(TLDynamicFeeSetting.getAPIValue(TLDynamicFeeSetting.HalfHourFee)) as? NSNumber
            } else if dynamicFeeSetting == TLDynamicFeeSetting.HourFee {
                dynamicFee = self.cachedDynamicFees!.objectForKey(TLDynamicFeeSetting.getAPIValue(TLDynamicFeeSetting.HourFee)) as? NSNumber
            }
        }
        return dynamicFee
    }
    
    func haveUpdatedCachedDynamicFees() -> Bool {
        let nowUnixTime = NSDate().timeIntervalSince1970
        let tenMinutesInSeconds = 600.0
        if self.cachedDynamicFeesTime == nil || nowUnixTime - self.cachedDynamicFeesTime! > tenMinutesInSeconds {
            return false
        }
        return true
    }

    func getDynamicTxFee(success:TLNetworking.SuccessHandler, failure:TLNetworking.FailureHandler)-> () {
        self.networking.httpGET(NSURL(string: "https://bitcoinfees.21.co/api/v1/fees/recommended")!,
                                parameters:[:], success:{
                                    (_jsonData: AnyObject!) in
                                    if let jsonData = _jsonData as? NSDictionary {
                                        self.cachedDynamicFeesTime = NSDate().timeIntervalSince1970
                                        self.cachedDynamicFees = jsonData
                                        DLog("TLTxFeeAPI getDynamicTxFee success %@", function: jsonData.description)
                                    } else {
                                        self.cachedDynamicFees = nil
                                    }
                                    success(_jsonData)
            }, failure: {
                (code: Int, status: String!) in
                self.cachedDynamicFees = nil
                DLog("TLTxFeeAPI getDynamicTxFee failure")
                failure(code, status)
        })
    }
}