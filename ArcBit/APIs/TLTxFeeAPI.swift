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

    static func getAPIValue(_ dynamicFeeSetting: TLDynamicFeeSetting) -> String {
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
    
    fileprivate var networking:TLNetworking
    fileprivate var cachedDynamicFees: NSDictionary?
    fileprivate var cachedDynamicFeesTime: TimeInterval?


    init() {
        self.networking = TLNetworking()
    }
    
    func getCachedDynamicFee(_ coinType: TLCoinType) -> NSNumber? {
        let dynamicFeeSetting = TLPreferences.getInAppSettingsKitDynamicFeeSetting(coinType)
        switch coinType {
        case .BCH:
            // hardcoded satoshis per byte for now works because bitcoin cash fees are near-zero because of no capacity issue
            // TODO still need to figure out numbers
            switch dynamicFeeSetting {
            case .FastestFee:
                return NSNumber(integerLiteral: 10)
            case .HalfHourFee:
                return NSNumber(integerLiteral: 1)
            case .HourFee:
                return NSNumber(integerLiteral: 0)
            }
        case .BTC:
            if self.cachedDynamicFees != nil {
                switch dynamicFeeSetting {
                case .FastestFee:
                    return self.cachedDynamicFees!.object(forKey: TLDynamicFeeSetting.getAPIValue(TLDynamicFeeSetting.FastestFee)) as? NSNumber
                case .HalfHourFee:
                    return self.cachedDynamicFees!.object(forKey: TLDynamicFeeSetting.getAPIValue(TLDynamicFeeSetting.HalfHourFee)) as? NSNumber
                case .HourFee:
                    return self.cachedDynamicFees!.object(forKey: TLDynamicFeeSetting.getAPIValue(TLDynamicFeeSetting.HourFee)) as? NSNumber
                }
            }
            return nil
        }
    }
    
    func haveUpdatedCachedDynamicFees(_ coinType: TLCoinType) -> Bool {
        switch coinType {
        case .BCH:
            return true
        case .BTC:
            let nowUnixTime = Date().timeIntervalSince1970
            let tenMinutesInSeconds = 600.0
            if self.cachedDynamicFeesTime == nil || nowUnixTime - self.cachedDynamicFeesTime! > tenMinutesInSeconds {
                return false
            }
            return true
        }
    }

    func getDynamicTxFee(_ coinType: TLCoinType, success:@escaping TLNetworking.SuccessHandler, failure:@escaping TLNetworking.FailureHandler)-> () {
        switch coinType {
        case .BCH:
            success(NSDictionary())
        case .BTC:
            self.networking.httpGET(URL(string: "https://bitcoinfees.21.co/api/v1/fees/recommended")!,
                                    parameters:[:], success:{
                                        (_jsonData) in
                                        if let jsonData = _jsonData as? NSDictionary {
                                            self.cachedDynamicFeesTime = Date().timeIntervalSince1970
                                            self.cachedDynamicFees = jsonData
                                            DLog("TLTxFeeAPI getDynamicTxFee success \(jsonData.description)")
                                        } else {
                                            self.cachedDynamicFees = nil
                                        }
                                        success(_jsonData)
            }, failure: {
                (code, status) in
                self.cachedDynamicFees = nil
                DLog("TLTxFeeAPI getDynamicTxFee failure")
                failure(code, status)
            })
        }

    }
}
