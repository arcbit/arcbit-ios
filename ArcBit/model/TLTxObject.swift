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

@objc class TLTxObject : NSObject
{
    fileprivate var txDict : NSDictionary
    fileprivate var inputAddressToValueArray : NSMutableArray?
    fileprivate var outputAddressToValueArray : NSMutableArray?
    fileprivate var addresses:[String]? = nil
    fileprivate var txid : String?
    
    init(dict: NSDictionary) {
        txDict = NSDictionary(dictionary:dict)
        super.init()
        txid = nil
        buildTxObject(txDict)
    }
    
    fileprivate func buildTxObject(_ tx: NSDictionary) -> (){
        inputAddressToValueArray = NSMutableArray()
        let inputsArray = tx.object(forKey: "inputs") as? NSArray
        if (inputsArray != nil) {
            for _input in inputsArray! {
                let input = _input as! NSDictionary
                let prevOut = input.object(forKey: "prev_out") as? NSDictionary
                if (prevOut != nil) {
                    let addr = prevOut!.object(forKey: "addr") as? String
                    
                    let inp = NSMutableDictionary()
                    if (addr != nil) {
                        inp.setObject(addr!, forKey:"addr" as NSCopying)
                        inp.setObject(prevOut!.object(forKey: "value") as! Int, forKey:"value" as NSCopying)
                    }
                    inputAddressToValueArray!.add(inp)
                }
            }
        }
        
        outputAddressToValueArray = NSMutableArray()
        let outsArray = tx.object(forKey: "out") as? NSArray
        if (outsArray != nil) {
            for _output in outsArray! {
                let output = _output as! NSDictionary
                let addr = output.object(forKey: "addr") as? String
                let outt = NSMutableDictionary()
                if (addr != nil) {
                    outt.setObject(addr!, forKey:"addr" as NSCopying)
                    outt.setObject(output.object(forKey: "value") as! Int, forKey:"value" as NSCopying)
                }
                
                outt.setObject(output.object(forKey: "script") as! String, forKey:"script" as NSCopying)
                outputAddressToValueArray!.add(outt)
            }
        }
    }
    
    func getAddresses() -> [String] {
        if (addresses != nil)
        {
            return addresses!
        }
        
        addresses = [String]()
        
        for addressTovalueDict in inputAddressToValueArray! {
            if let address = (addressTovalueDict as! NSDictionary).object(forKey: "addr") as? String {
                addresses!.append(address)
            }
        }
        for addressTovalueDict in outputAddressToValueArray! {
            if let address = (addressTovalueDict as! NSDictionary).object(forKey: "addr") as? String {
                addresses!.append(address)
            }
        }
        return addresses!
    }
    
    func getInputAddressToValueArray() -> (NSArray?) {
        return inputAddressToValueArray
    }
    
    func getInputAddressArray() -> [String] {
        var addresses = [String]()
        addresses.reserveCapacity(inputAddressToValueArray!.count)
        for _input in inputAddressToValueArray! {
            let input = _input as! NSDictionary
            if let address = input.object(forKey: "addr") as? String {
                addresses.append(address)
            }
        }
        return addresses
    }
    
    func getOutputAddressArray() -> [String] {
        var addresses = [String]()
        addresses.reserveCapacity(outputAddressToValueArray!.count)
        for _output in outputAddressToValueArray! {
            let output = _output as! NSDictionary
            if let address = output.object(forKey: "addr") as? String {
                addresses.append(address)
            }
        }
        return addresses
    }
    
    func getPossibleStealthDataScripts() -> [String] {
        var possibleStealthDataScripts = [String]()
        possibleStealthDataScripts.reserveCapacity(outputAddressToValueArray!.count)
        
        for _output in outputAddressToValueArray! {
            let output = _output as! NSDictionary
            let script = output.object(forKey: "script") as! String
            if script.characters.count == 80 {
                possibleStealthDataScripts.append(script)
            }
        }
        return possibleStealthDataScripts
    }
    
    func getOutputAddressToValueArray() -> (NSArray?) {
        return outputAddressToValueArray
    }
    
    func getHash() -> NSString? {
        return txDict.object(forKey: "hash") as! NSString?
    }
    
    func getTxid() -> (String?) {
        if (txid == nil) {
            txid = TLWalletUtils.reverseHexString(txDict.object(forKey: "hash") as! String)
        }
        return txid
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
            let height = UInt64(TLBlockchainStatus.instance().blockHeight)
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

