//
//  TLExchangeRate.swift
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

class TLExchangeRate {
    struct STATIC_MEMBERS {
        static var instance:TLExchangeRate?
    }
    
    fileprivate var exchangeRateDict:NSMutableDictionary? = nil
    var networking:TLNetworking

    class func instance() -> (TLExchangeRate) {
        if(STATIC_MEMBERS.instance == nil) {
            STATIC_MEMBERS.instance = TLExchangeRate()
        }
        return STATIC_MEMBERS.instance!
    }
    
    init() {
        self.networking = TLNetworking()
        self.exchangeRateDict = NSMutableDictionary()
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background)
        queue.async {
            self.getExchangeRates({ (jsonData:AnyObject!) in
                let array = jsonData as! NSArray

                for i in stride(from: 0, to: array.count, by: 1) {
                    let dict = array[i] as! NSDictionary
                    (self.exchangeRateDict!)[dict["code"] as! String] = dict
                }
                
                }, failure: {(code, status) in
                    DLog("getExchangeRates failure: code:\(code) status:\(status)")
            })
        }
    }
    
    fileprivate func getExchangeRate(_ currency:String) -> (Double) {
        if (self.exchangeRateDict == nil || self.exchangeRateDict![currency] == nil) {
            return 0
        } else {
            return ((self.exchangeRateDict![currency] as! NSMutableDictionary)["rate"] as! Double)
        }
    }
    
    fileprivate func getExchangeRates(_ success: @escaping TLNetworking.SuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> () {
        self.networking.httpGET(URL(string: "https://bitpay.com/api/rates")!,
            parameters:[:], success:success, failure:failure)
    }
    
    fileprivate func fiatAmountFromBitcoin(_ currency:String, bitcoinAmount:TLCoin) -> (Double) {
        let exchangeRate = getExchangeRate(currency)
        return bitcoinAmount.bigIntegerToBitcoin() * exchangeRate
    }

    func bitcoinAmountFromFiat(_ currency:String, fiatAmount:Double) -> (TLCoin) {
        let exchangeRate = getExchangeRate(currency)
        let bitcoinAmount = TLCoin(doubleValue: fiatAmount/exchangeRate)
        return bitcoinAmount
    }
    
    func fiatAmountStringFromBitcoin(_ currency:String, bitcoinAmount:TLCoin) -> (String){
        //TODO move bitcoinFormatter to property
        let bitcoinFormatter = NumberFormatter()
        bitcoinFormatter.numberStyle = .decimal
        bitcoinFormatter.maximumFractionDigits = 2
        return bitcoinFormatter.string(from: NSNumber(value: fiatAmountFromBitcoin(currency, bitcoinAmount:bitcoinAmount) as Double))!
    }
}
