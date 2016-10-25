//
//  TLCoin.swift
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

enum TLBitcoinDenomination:Int {
    case bitcoin  = 0
    case milliBit = 1
    case bits     = 2
}


@objc class TLCoin:NSObject {
    struct STATIC_MEMBERS {
        static let numberFormatter: NumberFormatter =  NumberFormatter()
    }
    
    fileprivate var coin:BTCMutableBigNumber
    
    class func zero() -> (TLCoin) {
        return TLCoin(btcNumber:BTCBigNumber.zero())
    }
    
    class func one() -> (TLCoin) {
        return TLCoin(btcNumber:BTCBigNumber.one())
    }
    
    class func negativeOne() -> (TLCoin) {
        return TLCoin(btcNumber:BTCBigNumber.negativeOne())
    }
    
    init(btcNumber:BTCBigNumber) {
        coin = btcNumber.mutableCopy()
    }
    
    fileprivate func getBTCNumber() -> (BTCBigNumber) {
        return coin
    }
    
    func add(_ other:TLCoin) -> (TLCoin) {
        let tmp = coin.mutableCopy().add(other.getBTCNumber())
        return TLCoin(btcNumber: tmp!.copy())
    }
    
    func subtract(_ other:TLCoin) -> (TLCoin) {
        let tmp = coin.mutableCopy().subtract(other.getBTCNumber())
        return TLCoin(btcNumber: tmp!.copy())
    }
    
    fileprivate func multiply(_ other:TLCoin) -> (TLCoin) {
        let tmp = coin.mutableCopy().multiply(other.getBTCNumber())
        return TLCoin(btcNumber: tmp!.copy())
    }
    
    fileprivate func divide(_ other:TLCoin) -> (TLCoin) {
        let tmp = coin.mutableCopy().divide(other.getBTCNumber())
        return TLCoin(btcNumber: tmp!.copy())
    }
    
    init(uint64:UInt64) {
        coin = BTCMutableBigNumber(uInt64: uint64)
    }
    
    init(doubleValue:Double) {
        //TODO: get rid this init method
        let tmp = NSDecimalNumber(value: doubleValue as Double).multiplying(by: NSDecimalNumber(value: 100000000 as UInt64))
        coin = BTCMutableBigNumber(uInt64: tmp.uint64Value)
    }
    
    func toUInt64() -> (UInt64) {
        return STATIC_MEMBERS.numberFormatter.number(from: coin.decimalString)!.uint64Value
    }
    
    init(bitcoinAmount:(String), bitcoinDenomination:(TLBitcoinDenomination), locale: Locale=Locale.current) {
        //TODO move to TLCurrencyFormat like android, so dont have to create formatter everytime
        let bitcoinFormatter = NumberFormatter()
        bitcoinFormatter.numberStyle = .decimal
        bitcoinFormatter.maximumFractionDigits = 8
        bitcoinFormatter.locale = locale
        
        let tmpString = bitcoinFormatter.number(from: bitcoinAmount)
        if tmpString == nil {
            coin = BTCMutableBigNumber(uInt64:0)
            return
        }

        let satoshis:UInt64
        let mericaFormatter = NumberFormatter()
        mericaFormatter.maximumFractionDigits = 8
        mericaFormatter.locale = Locale(identifier: "en_US")
        let decimalAmount = NSDecimalNumber(string: mericaFormatter.string(from: bitcoinFormatter.number(from: bitcoinAmount)!))
        if (bitcoinDenomination == TLBitcoinDenomination.bitcoin) {
            satoshis = decimalAmount.multiplying(by: NSDecimalNumber(string: "100000000")).uint64Value
        }
        else if (bitcoinDenomination == TLBitcoinDenomination.milliBit) {
            satoshis = (decimalAmount.multiplying(by: NSDecimalNumber(value: 100000 as UInt64))).uint64Value
        }
        else {
            satoshis = (decimalAmount.multiplying(by: NSDecimalNumber(value: 100 as UInt64))).uint64Value
        }
        coin = BTCMutableBigNumber(uInt64:satoshis)
    }
    
    func bigIntegerToBitcoinAmountString(_ bitcoinDenomination: TLBitcoinDenomination) -> (String) {
        //TODO move to TLCurrencyFormat like android, so dont have to create formatter everytime
        let bitcoinFormatter = NumberFormatter()
        bitcoinFormatter.numberStyle = .decimal
        
        if (bitcoinDenomination == TLBitcoinDenomination.bitcoin) {
            bitcoinFormatter.maximumFractionDigits = 8
            return bitcoinFormatter.string(from: NSNumber(value: bigIntegerToBitcoin() as Double))!
        }
        else if (bitcoinDenomination == TLBitcoinDenomination.milliBit) {
            bitcoinFormatter.maximumFractionDigits = 5
            return bitcoinFormatter.string(from: NSNumber(value: bigIntegerToMilliBit() as Double))!
        }
        else {
            bitcoinFormatter.maximumFractionDigits = 2
            return bitcoinFormatter.string(from: NSNumber(value: bigIntegerToBits() as Double))!
        }
    }
    
    func toString() -> (String) {
        return coin.decimalString != nil ? coin.decimalString : "0"
    }
    
    fileprivate func bigIntegerToBits() -> (Double) {
        return (NSDecimalNumber(string: coin.decimalString as String).multiplying(by: NSDecimalNumber(value: 0.01 as Double))).doubleValue
    }
    
    fileprivate func bigIntegerToMilliBit() -> (Double){
        return (NSDecimalNumber(string: coin.decimalString as String).multiplying(by: NSDecimalNumber(value: 0.00001 as Double))).doubleValue
    }
    
    func bigIntegerToBitcoin() -> (Double) {
        return (NSDecimalNumber(string: coin.decimalString as String).multiplying(by: NSDecimalNumber(value: 0.00000001 as Double))).doubleValue
    }
    
    func less(_ other:TLCoin) -> (Bool) {
        return coin.less(other.getBTCNumber())
    }
    
    func lessOrEqual(_ other:TLCoin) -> (Bool) {
        return coin.lessOrEqual(other.getBTCNumber())
    }
    
    func greater(_ other:TLCoin) -> (Bool) {
        return coin.greater(other.getBTCNumber())
    }
    
    func greaterOrEqual(_ other:TLCoin) -> (Bool) {
        return coin.greaterOrEqual(other.getBTCNumber())
    }
    
    func equalTo(_ other:TLCoin) -> (Bool) {
        return coin.greaterOrEqual(other.getBTCNumber()) && coin.lessOrEqual(other.getBTCNumber())
    }
}
