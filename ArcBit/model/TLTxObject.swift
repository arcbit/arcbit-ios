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
    private var txDict : NSDictionary
    private var inputAddressToValueArray : NSMutableArray?
    private var outputAddressToValueArray : NSMutableArray?
    private var addresses:[String]? = nil
    private var txid : String?
    
    init(dict: NSDictionary) {
        txDict = NSDictionary(dictionary:dict)
        super.init()
        txid = nil
        buildTxObject(txDict)
    }
    
    private func buildTxObject(tx: NSDictionary) -> (){
        inputAddressToValueArray = NSMutableArray()
        let blockHeightString = tx.objectForKey("block_height") as? NSNumber
        var blockHeight:Int64 = 0
        if (blockHeightString != nil) {
            blockHeight = blockHeightString!.longLongValue
        }
        let timeString = tx.objectForKey("time") as? NSNumber
        var time:Int64 = 0
        if (timeString != nil) {
            time = timeString!.longLongValue
        }
        
        let inputsArray = tx.objectForKey("inputs") as? NSArray
        if (inputsArray != nil) {
            for _input in inputsArray! {
                let input = _input as! NSDictionary
                let prevOut = input.objectForKey("prev_out") as? NSDictionary
                if (prevOut != nil) {
                    let addr = prevOut!.objectForKey("addr") as? String
                    
                    let inp = NSMutableDictionary()
                    if (addr != nil) {
                        inp.setObject(addr!, forKey:"addr")
                        inp.setObject(prevOut!.objectForKey("value") as! UInt, forKey:"value")
                    }
                    inputAddressToValueArray!.addObject(inp)
                }
            }
        }
        
        outputAddressToValueArray = NSMutableArray()
        let outsArray = tx.objectForKey("out") as? NSArray
        if (outsArray != nil) {
            for _output in outsArray! {
                let output = _output as! NSDictionary
                let addr = output.objectForKey("addr") as? String
                let outt = NSMutableDictionary()
                if (addr != nil) {
                    outt.setObject(addr!, forKey:"addr")
                    outt.setObject(output.objectForKey("value") as! UInt, forKey:"value")
                }
                
                outt.setObject(output.objectForKey("script") as! String, forKey:"script")
                outputAddressToValueArray!.addObject(outt)
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
            if let address = (addressTovalueDict as! NSDictionary).objectForKey("addr") as? String {
                addresses!.append(address)
            }
        }
        for addressTovalueDict in outputAddressToValueArray! {
            if let address = (addressTovalueDict as! NSDictionary).objectForKey("addr") as? String {
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
            if let address = input.objectForKey("addr") as? String {
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
            if let address = output.objectForKey("addr") as? String {
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
            let script = output.objectForKey("script") as! String
            if count(script) == 80 {
                possibleStealthDataScripts.append(script)
            }
        }
        return possibleStealthDataScripts
    }
    
    func getOutputAddressToValueArray() -> (NSArray?) {
        return outputAddressToValueArray
    }
    
    func getHash() -> NSString? {
        return txDict.objectForKey("hash") as! NSString?
    }
    
    func getTxid() -> (String?) {
        if (txid == nil) {
            txid = TLWalletUtils.reverseTxidHexString(txDict.objectForKey("hash") as! String)
        }
        return txid
    }
    
    func getTxUnixTime() -> UInt64 {
        let timeNumber = txDict.objectForKey("time") as? NSNumber
        if (timeNumber != nil) {
            return timeNumber!.unsignedLongLongValue
        }
        return 0
    }
    
    private func getTxUnixTimeInterval() -> NSTimeInterval {
        return NSTimeInterval((txDict.objectForKey("time") as! NSNumber).longLongValue)
    }
    
    func getTime() -> (String){
        let interval = getTxUnixTimeInterval()
        
        //TODO: specific to insight api, later dont use confirmations but block_height for all apis
        if (txDict.objectForKey("confirmations") != nil && interval <= 0) {
            return ""
        }
        
        let transactionDate = NSDate(timeIntervalSince1970:interval)
        
        let formatterTime = NSDateFormatter()
        formatterTime.dateFormat = "@ hh:mm a"
        
        if (transactionDate.isToday()) {
            return String(format:"%@ %@", "Today", formatterTime.stringFromDate(transactionDate))
        } else {
            let formatterDate = NSDateFormatter()
            formatterDate.dateFormat = "EEE dd MMM"
            return String(format:"%@ %@", formatterDate.stringFromDate(transactionDate), formatterTime.stringFromDate(transactionDate))
        }
    }
    
    func getConfirmations() -> UInt64 {
        //TODO: specific to insight api, later dont use confirmations but block_height for all apis
        if (txDict.objectForKey("confirmations") as! NSNumber? != nil) {
            return UInt64((txDict.objectForKey("confirmations") as! NSNumber).longLongValue)
        }
        
        if (txDict.objectForKey("block_height") != nil && (txDict.objectForKey("block_height") as! NSNumber).unsignedLongLongValue > 0) {
            return UInt64(TLBlockchainStatus.instance().blockHeight) - UInt64((txDict.objectForKey("block_height") as! NSNumber).unsignedLongLongValue) + UInt64(1)
        }
        
        return 0
    }
}

