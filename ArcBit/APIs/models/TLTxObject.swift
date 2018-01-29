//
//  TLTxObject.swift
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

class TLTxInputPrevOutObject {
    let addr:String
    let value:UInt64
    
    init(_ jsonDict: NSDictionary) {
        self.addr = jsonDict.object(forKey: "addr") as! String
        self.value = jsonDict.object(forKey: "value") as! UInt64
    }
}

class TLTxInputObject {
    let prevOut:TLTxInputPrevOutObject
    init?(_ jsonDict: NSDictionary) {
        if let prevOut = jsonDict.object(forKey: "prev_out") as? NSDictionary {
            self.prevOut = TLTxInputPrevOutObject(prevOut)
        } else {
            return nil
        }
    }
}

class TLTxOutputObject {
    private(set) var addr:String?
    private(set) var value:UInt64?
    let script:String

    init(_ jsonDict: NSDictionary) {
        if let address = jsonDict.object(forKey: "addr") as? String {
            self.addr = address
        }
        if let value = jsonDict.object(forKey: "value") as? UInt64 {
            self.value = value
        }
        self.script = jsonDict.object(forKey: "script") as! String
    }
}

@objc class TLTxObject : NSObject {

    let coinType:TLCoinType
    fileprivate var txDict : NSDictionary
    fileprivate lazy var inputAddressToValueArray = Array<TLTxInputObject>()
    fileprivate lazy var outputAddressToValueArray = Array<TLTxOutputObject>()
    fileprivate var addresses:[String]? = nil
    fileprivate var txid : String?

    init(_ coinType:TLCoinType, dict: NSDictionary) {
        self.coinType = coinType
        txDict = NSDictionary(dictionary:dict)
        super.init()
        txid = nil
        buildTxObject(txDict)
    }
    
    fileprivate func buildTxObject(_ tx: NSDictionary) -> (){
        if let inputsArray = tx.object(forKey: "inputs") as? NSArray {
            for input in inputsArray {
                if let txInputObject = TLTxInputObject(input as! NSDictionary) {
                    inputAddressToValueArray.append(txInputObject)
                }
            }
        }
        
        if let outsArray = tx.object(forKey: "out") as? NSArray {
            for output in outsArray {
                outputAddressToValueArray.append(TLTxOutputObject(output as! NSDictionary))
            }
        }
    }
    
    func getAddresses() -> [String] {
        if (addresses != nil) {
            return addresses!
        }
        
        addresses = [String]()
        
        for inputObject in inputAddressToValueArray {
            addresses!.append(inputObject.prevOut.addr)
        }
        for outputObject in outputAddressToValueArray {
            if let addr = outputObject.addr {
                addresses!.append(addr)
            }
        }
        return addresses!
    }
    
    func getInputAddressToValueArray() -> Array<TLTxInputObject> {
        return inputAddressToValueArray
    }
    
    func getInputAddressArray() -> [String] {
        var addresses = [String]()
        addresses.reserveCapacity(inputAddressToValueArray.count)
        for inputObject in inputAddressToValueArray {
            addresses.append(inputObject.prevOut.addr)
        }
        return addresses
    }
    
    func getOutputAddressArray() -> [String] {
        var addresses = [String]()
        addresses.reserveCapacity(outputAddressToValueArray.count)
        for outputObject in outputAddressToValueArray {
            if let address = outputObject.addr {
                addresses.append(address)
            }
        }
        return addresses
    }
    
    func getPossibleStealthDataScripts() -> [String] {
        var possibleStealthDataScripts = [String]()
        possibleStealthDataScripts.reserveCapacity(outputAddressToValueArray.count)
        
        for outputObject in outputAddressToValueArray {
            if outputObject.script.count == 80 {
                possibleStealthDataScripts.append(outputObject.script)
            }
        }
        return possibleStealthDataScripts
    }
    
    func getOutputAddressToValueArray() -> Array<TLTxOutputObject> {
        return outputAddressToValueArray
    }
    
    func getHash() -> String {
        return txDict.object(forKey: "hash") as! String
    }
    
    func getTxid() -> String {
        if (txid == nil) {
            txid = TLWalletUtils.reverseHexString(txDict.object(forKey: "hash") as! String)
        }
        return txid!
    }
    
    func getTxUnixTime() -> UInt64 {
        let timeNumber = txDict.object(forKey: "time") as? NSNumber
        if (timeNumber != nil) {
            return timeNumber!.uint64Value
        }
        return 0
    }
    
    fileprivate func getTxUnixTimeInterval() -> TimeInterval {
        return TimeInterval((txDict.object(forKey: "time") as! NSNumber).int64Value)
    }
    
    func getTime() -> (String){
        let interval = getTxUnixTimeInterval()
        
        //TODO: specific to insight api, later dont use confirmations but block_height for all apis
        if (txDict.object(forKey: "confirmations") != nil && interval <= 0) {
            return ""
        }
        
        let transactionDate = Date(timeIntervalSince1970:interval)
        
        let formatterTime = DateFormatter()
        formatterTime.dateFormat = "@ hh:mm a"
        
        if ((transactionDate as NSDate).isToday()) {
            return String(format:"%@ %@", TLDisplayStrings.TODAY_STRING(), formatterTime.string(from: transactionDate))
        } else {
            let formatterDate = DateFormatter()
            formatterDate.dateFormat = "EEE dd MMM YYYY"
            return String(format:"%@ %@", formatterDate.string(from: transactionDate), formatterTime.string(from: transactionDate))
        }
    }
    
    func getConfirmations() -> UInt64 {
        //TODO: specific to insight api, later dont use confirmations but block_height for all apis
        if (txDict.object(forKey: "confirmations") as? NSNumber? != nil) {
            if let conf:NSNumber = txDict.object(forKey: "confirmations") as? NSNumber {
                return UInt64(conf.int64Value)
            }
        }
        
        if (txDict.object(forKey: "block_height") != nil && (txDict.object(forKey: "block_height") as! NSNumber).uint64Value > 0) {
            let height = UInt64(TLBlockchainStatus.instance().getBlockHeight(self.coinType))
            let txBlockHeight = UInt64((txDict.object(forKey: "block_height") as! NSNumber).uint64Value) + UInt64(1)
            if txBlockHeight < height {
                return height - txBlockHeight
            } else {
                return 6 //FIXME
            }
        }
        
        return 0
    }
}

