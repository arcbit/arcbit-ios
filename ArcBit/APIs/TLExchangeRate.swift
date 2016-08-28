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
    
    private var exchangeRateDict:NSMutableDictionary? = nil
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
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        dispatch_async(queue) {
            self.getExchangeRates({ (jsonData:AnyObject!) in
                let array = jsonData as! NSArray
                for(var i = 0; i < array.count; i++) {
                    let dict = array[i] as! NSDictionary
                    (self.exchangeRateDict!)[dict["code"] as! String] = dict
                }
                
                }, failure: {(code:Int, status:String!) in
                    DLog("getExchangeRates failure: code:\(code) status:\(status)")
            })
        }
    }
    
    private func getExchangeRate(currency:String) -> (Double) {
        if (self.exchangeRateDict == nil || self.exchangeRateDict![currency] == nil) {
            return 0
        } else {
            return ((self.exchangeRateDict![currency] as! NSMutableDictionary)["rate"] as! Double)
        }
    }
    
    private func getExchangeRates(success: TLNetworking.SuccessHandler, failure:TLNetworking.FailureHandler) -> () {
        self.networking.httpGET(NSURL(string: "https://bitpay.com/api/rates")!,
            parameters:[:], success:success, failure:failure)
    }
    
    private func fiatAmountFromBitcoin(currency:String, bitcoinAmount:TLCoin) -> (Double) {
        let exchangeRate = getExchangeRate(currency)
        return bitcoinAmount.bigIntegerToBitcoin() * exchangeRate
    }

    func bitcoinAmountFromFiat(currency:String, fiatAmount:Double) -> (TLCoin) {
        let exchangeRate = getExchangeRate(currency)
        let bitcoinAmount = TLCoin(doubleValue: fiatAmount/exchangeRate)
        return bitcoinAmount
    }
    
    func fiatAmountStringFromBitcoin(currency:String, bitcoinAmount:TLCoin) -> (String){
        //TODO move bitcoinFormatter to property
        let bitcoinFormatter = NSNumberFormatter()
        bitcoinFormatter.numberStyle = .DecimalStyle
        bitcoinFormatter.maximumFractionDigits = 2
        return bitcoinFormatter.stringFromNumber(NSNumber(double: fiatAmountFromBitcoin(currency, bitcoinAmount:bitcoinAmount)))!
    }
}