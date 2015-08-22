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
    case Bitcoin  = 0
    case MilliBit = 1
    case Bits     = 2
}


@objc class TLCoin:NSObject {
    struct STATIC_MEMBERS {
        static let numberFormatter: NSNumberFormatter =  NSNumberFormatter()
    }
    
    private var coin:BTCMutableBigNumber
    
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
    
    private func getBTCNumber() -> (BTCBigNumber) {
        return coin
    }
    
    func add(other:TLCoin) -> (TLCoin) {
        let tmp = coin.mutableCopy().add(other.getBTCNumber())
        return TLCoin(btcNumber: tmp.copy())
    }
    
    func subtract(other:TLCoin) -> (TLCoin) {
        let tmp = coin.mutableCopy().subtract(other.getBTCNumber())
        return TLCoin(btcNumber: tmp.copy())
    }
    
    private func multiply(other:TLCoin) -> (TLCoin) {
        let tmp = coin.mutableCopy().multiply(other.getBTCNumber())
        return TLCoin(btcNumber: tmp.copy())
    }
    
    private func divide(other:TLCoin) -> (TLCoin) {
        let tmp = coin.mutableCopy().divide(other.getBTCNumber())
        return TLCoin(btcNumber: tmp.copy())
    }
    
    init(uint64:UInt64) {
        coin = BTCMutableBigNumber(UInt64: uint64)
    }
    
    init(doubleValue:Double) {
        //TODO: get rid this init method
        let tmp = NSDecimalNumber(double: doubleValue).decimalNumberByMultiplyingBy(NSDecimalNumber(unsignedLongLong: 100000000))
        coin = BTCMutableBigNumber(UInt64: tmp.unsignedLongLongValue)
    }
    
    func toUInt64() -> (UInt64) {
        return STATIC_MEMBERS.numberFormatter.numberFromString(coin.decimalString)!.unsignedLongLongValue
    }
    
    init(bitcoinAmount:(String), bitcoinDenomination:(TLBitcoinDenomination)) {
        let satoshis:UInt64
        let bitcoinAmountString = bitcoinAmount.stringByReplacingOccurrencesOfString(",", withString: ".")
        if (bitcoinDenomination == TLBitcoinDenomination.Bitcoin) {
            satoshis = (NSDecimalNumber(string: bitcoinAmountString).decimalNumberByMultiplyingBy(NSDecimalNumber(unsignedLongLong: 100000000))).unsignedLongLongValue
        }
        else if (bitcoinDenomination == TLBitcoinDenomination.MilliBit) {
            satoshis = (NSDecimalNumber(string: bitcoinAmountString).decimalNumberByMultiplyingBy(NSDecimalNumber(unsignedLongLong: 100000))).unsignedLongLongValue
        }
        else {
            satoshis = (NSDecimalNumber(string: bitcoinAmountString).decimalNumberByMultiplyingBy(NSDecimalNumber(unsignedLongLong: 100))).unsignedLongLongValue
        }
        coin = BTCMutableBigNumber(UInt64:satoshis)
    }
    
    func bigIntegerToBitcoinAmountString(bitcoinDenomination: TLBitcoinDenomination) -> (String) {
        let bitcoinFormatter = NSNumberFormatter()
        bitcoinFormatter.numberStyle = .DecimalStyle
        
        if (bitcoinDenomination == TLBitcoinDenomination.Bitcoin) {
            bitcoinFormatter.maximumFractionDigits = 8
            return bitcoinFormatter.stringFromNumber(NSNumber(double: bigIntegerToBitcoin()))!
        }
        else if (bitcoinDenomination == TLBitcoinDenomination.MilliBit) {
            bitcoinFormatter.maximumFractionDigits = 5
            return bitcoinFormatter.stringFromNumber(NSNumber(double: bigIntegerToMilliBit()))!
        }
        else {
            bitcoinFormatter.maximumFractionDigits = 2
            return bitcoinFormatter.stringFromNumber(NSNumber(double: bigIntegerToBits()))!
        }
    }
    
    func toString() -> (String) {
        return coin.decimalString != nil ? coin.decimalString : "0"
    }
    
    private func bigIntegerToBits() -> (Double) {
        return (NSDecimalNumber(string: coin.decimalString as String).decimalNumberByMultiplyingBy(NSDecimalNumber(double: 0.01))).doubleValue
    }
    
    private func bigIntegerToMilliBit() -> (Double){
        return (NSDecimalNumber(string: coin.decimalString as String).decimalNumberByMultiplyingBy(NSDecimalNumber(double: 0.00001))).doubleValue
    }
    
    func bigIntegerToBitcoin() -> (Double) {
        return (NSDecimalNumber(string: coin.decimalString as String).decimalNumberByMultiplyingBy(NSDecimalNumber(double: 0.00000001))).doubleValue
    }
    
    func less(other:TLCoin) -> (Bool) {
        return coin.less(other.getBTCNumber())
    }
    
    func lessOrEqual(other:TLCoin) -> (Bool) {
        return coin.lessOrEqual(other.getBTCNumber())
    }
    
    func greater(other:TLCoin) -> (Bool) {
        return coin.greater(other.getBTCNumber())
    }
    
    func greaterOrEqual(other:TLCoin) -> (Bool) {
        return coin.greaterOrEqual(other.getBTCNumber())
    }
    
    func equalTo(other:TLCoin) -> (Bool) {
        return coin.greaterOrEqual(other.getBTCNumber()) && coin.lessOrEqual(other.getBTCNumber())
    }
}