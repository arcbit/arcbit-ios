//
//  TLInsightAPI.swift
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


class TLInsightAPI {
    var networking:TLNetworking
    var baseURL:String

    init(baseURL: String) {
        self.networking = TLNetworking()
        self.baseURL = baseURL
    }
    
    func getBlockHeight(_ success: @escaping (TLNetworking.SuccessHandler), failure: @escaping (TLNetworking.FailureHandler)) {
        let endPoint = "api/status/"
        let parameters = [
            "q": "getTxOutSetInfo"
        ]
        let url = URL(string: endPoint, relativeTo: URL(string: self.baseURL))!
        self.networking.httpGET(url, parameters: parameters as NSDictionary,
            success: {
                (jsonData: AnyObject!) in
                success(jsonData)
            }, failure: {
                (code: NSInteger, status: String!) in
                failure(code, status)
        })
    }
    
    func getUnspentOutputsSynchronous(_ addressArray: NSArray) -> NSDictionary {
        let endPoint = String(format: "%@%@%@", "api/addrs/", addressArray.componentsJoined(by: ","), "/utxo")
        let parameters = [:]
        
        let url = URL(string: endPoint, relativeTo: URL(string: self.baseURL))!
        
        let jsonData: AnyObject? = self.networking.httpGETSynchronous(url, parameters: parameters as NSDictionary)
        
        if jsonData is NSDictionary { // if don't get dict http error, will get array
            return jsonData as! NSDictionary
        }
        
        let transansformedJsonData = TLInsightAPI.insightUnspentOutputsToBlockchainUnspentOutputs(jsonData as! NSArray)
        
        return transansformedJsonData
    }
    
    func getUnspentOutputs(_ addressArray: Array<String>, success: @escaping TLNetworking.SuccessHandler, failure: @escaping TLNetworking.FailureHandler) {
        let endPoint = String(format: "%@%@%@", "api/addrs/", addressArray.joined(separator: ","), "/utxo")
        let parameters = [:]
        
        let url = URL(string: endPoint, relativeTo: URL(string: self.baseURL))!
        self.networking.httpGET(nil, parameters: parameters as NSDictionary,
            success: {
                (jsonData: AnyObject!) in
                
                let transansformedJsonData = TLInsightAPI.insightUnspentOutputsToBlockchainUnspentOutputs(jsonData as! NSArray) as NSDictionary
                
                success(transansformedJsonData)
            }, failure: {
                (code: NSInteger, status: String!) in
                failure(code, status)
        })
    }
    
    func getAddressesInfoSynchronous(_ addressArray: Array<String>, txCountFrom: Int=0, allTxs: NSMutableArray=[]) -> NSDictionary {
        let endPoint = String(format: "%@%@%@", "api/addrs/", addressArray.joined(separator: ","), "/txs")
        
        let parameters = ["from":txCountFrom, "to":txCountFrom+50]

        let url = URL(string: endPoint, relativeTo: URL(string: self.baseURL))!
        
        let jsonData: AnyObject? = self.networking.httpGETSynchronous(url, parameters: parameters as NSDictionary)

        if ((jsonData as! NSDictionary).object(forKey: TLNetworking.STATIC_MEMBERS.HTTP_ERROR_CODE) != nil) {
            return jsonData as! NSDictionary
        }
        
        let txs = (jsonData as! NSDictionary).object(forKey: "items") as! NSArray
        let to = ((jsonData as! NSDictionary).object(forKey: "to") as! NSNumber)
        let totalItems = ((jsonData as! NSDictionary).object(forKey: "totalItems") as! NSNumber).uint64Value
        
        if to.uint64Value >= totalItems {
            if allTxs.count == 0 {
                let transansformedJsonData = TLInsightAPI.insightAddressesTxsToBlockchainMultiaddr(addressArray as NSArray, txs: txs)
                return transansformedJsonData
            } else {
                allTxs.addObjects(from: txs as [AnyObject])
                let transansformedJsonData = TLInsightAPI.insightAddressesTxsToBlockchainMultiaddr(addressArray as NSArray, txs: allTxs)
                return transansformedJsonData
            }
        } else {
            allTxs.addObjects(from: txs as [AnyObject])
            return self.getAddressesInfoSynchronous(addressArray, txCountFrom: to.intValue, allTxs: allTxs)
        }
    }
    
    func getAddressesInfo(_ addressArray: Array<String>, txCountFrom: Int=0, allTxs: NSMutableArray=[], success: @escaping TLNetworking.SuccessHandler, failure: @escaping TLNetworking.FailureHandler) {
        let endPoint = String(format: "%@%@%@", "api/addrs/", addressArray.joined(separator: ","), "/txs")
        let parameters = ["from":txCountFrom, "to":txCountFrom+50]

        let url = URL(string: endPoint, relativeTo: URL(string: self.baseURL))!
        
        self.networking.httpGET(url, parameters: parameters as NSDictionary,
            success: {
                (jsonData: AnyObject!) in
 
                let txs = (jsonData as! NSDictionary).object(forKey: "items") as! NSArray
                let to = ((jsonData as! NSDictionary).object(forKey: "to") as! NSNumber)
                let totalItems = ((jsonData as! NSDictionary).object(forKey: "totalItems") as! NSNumber).uint64Value
                if to.uint64Value >= totalItems {
                    if allTxs.count == 0 {
                        let transformedJsonData = TLInsightAPI.insightAddressesTxsToBlockchainMultiaddr(addressArray as NSArray, txs: txs)
                        success(transformedJsonData)
                    } else {
                        allTxs.addObjects(from: txs as [AnyObject])
                        let transformedJsonData = TLInsightAPI.insightAddressesTxsToBlockchainMultiaddr(addressArray as NSArray, txs: allTxs)
                        success(transformedJsonData)
                    }
                } else {
                    allTxs.addObjects(from: txs as [AnyObject])
                    self.getAddressesInfo(addressArray, txCountFrom: to.intValue, allTxs: allTxs, success: success, failure: failure)
                }
            }, failure: failure)
    }
    
    func getAddressData(_ address: String, success: @escaping TLNetworking.SuccessHandler, failure: @escaping TLNetworking.FailureHandler) {
        let endPoint = String(format: "%@%@", "api/txs/?address=", address)
        let parameters = [:]
        
        let url = URL(string: endPoint, relativeTo: URL(string: self.baseURL))!
        self.networking.httpGET(url, parameters: parameters as NSDictionary,
            success: {
                (jsonData: AnyObject!) in
                
                let txs = (jsonData as! NSDictionary!).object(forKey: "txs") as! NSArray
                let transformedTxs = NSMutableArray(capacity:txs.count)
                
                for tx in txs as! [NSDictionary] {
                    if let transformedTx = TLInsightAPI.insightTxToBlockchainTx(tx) {
                        transformedTxs.add(transformedTx)
                    }
                }
                
                let transansformedJsonData = NSMutableDictionary()
                transansformedJsonData.setObject(transformedTxs, forKey:"txs" as NSCopying)
                
                success(transansformedJsonData)
            }, failure: failure)
    }
    
    func getAddressDataSynchronous(_ address: String) -> NSDictionary {
        let endPoint = String(format: "%@%@", "api/txs/?address=", address)
        let parameters = [:]
        
        let url = URL(string: endPoint, relativeTo: URL(string: self.baseURL))!
        let jsonData: AnyObject? = self.networking.httpGETSynchronous(url, parameters: parameters as NSDictionary)
        
        let txs = (jsonData as! NSDictionary!).object(forKey: "txs") as! NSArray
        let transformedTxs = NSMutableArray(capacity:txs.count)
        
        for tx in txs as! [NSDictionary] {
            if let transformedTx = TLInsightAPI.insightTxToBlockchainTx(tx) {
                transformedTxs.add(transformedTx)
            }
        }
        
        let transansformedJsonData = NSMutableDictionary()
        transansformedJsonData.setObject(transformedTxs, forKey:"txs" as NSCopying)
        
        return transansformedJsonData
    }
    
    func getTx(_ txHash: String, success: @escaping TLNetworking.SuccessHandler, failure: @escaping TLNetworking.FailureHandler) {
        let endPoint = String(format: "%@%@", "api/tx/", txHash)
        let parameters = [:]
        
        let url = URL(string: endPoint, relativeTo: URL(string: self.baseURL))!
        self.networking.httpGET(url, parameters: parameters as NSDictionary, success: success, failure: failure)
    }

    func getTxBackground(_ txHash: String, success: @escaping TLNetworking.SuccessHandler, failure: @escaping TLNetworking.FailureHandler) {
        let endPoint = String(format: "%@%@", "api/tx/", txHash)
        let parameters = [:]
        
        let url = URL(string: endPoint, relativeTo: URL(string: self.baseURL))!
        self.networking.httpGETBackground(url, parameters: parameters as NSDictionary, success: success, failure: failure)
    }

    
    class func insightToBlockchainUnspentOutput(_ unspentOutputDict: NSDictionary) -> NSDictionary? {
        // bug in insight, see https://insight.bitpay.com/api/addrs/1GjuCPLhmrdrAdifz1XLdpVVeQjsvZYGou/utxo
        if unspentOutputDict.object(forKey: "scriptPubKey") == nil {
            // got following so far
            // insight bug for txid 1cf031f8ac2896994e57c299e23b4ed35e2d218a7c6877302da0e3292337f530 when tried to do f5b0e820f23a6724f669463a6bf2e03806169b3d7fee7b6d27a642840109823d
            DLog("no scriptPubKey, insight bug? txid \(unspentOutputDict.object(forKey: "txid") as! String)")
            return nil
        }
        
        let blockchainUnspentOutputDict = NSMutableDictionary()
        let txid = unspentOutputDict.object(forKey: "txid") as! String
        let txHash = TLWalletUtils.reverseHexString(txid)
        blockchainUnspentOutputDict.setObject(txHash, forKey: "tx_hash" as NSCopying)
        blockchainUnspentOutputDict.setObject(txid, forKey: "tx_hash_big_endian" as NSCopying)
        blockchainUnspentOutputDict.setObject(unspentOutputDict.object(forKey: "vout")!, forKey: "tx_output_n" as NSCopying)
        blockchainUnspentOutputDict.setObject(unspentOutputDict.object(forKey: "scriptPubKey")!, forKey: "script" as NSCopying)
        let amountNumber = unspentOutputDict.object(forKey: "amount") as! NSNumber
        
        
        // Insight API should really return unspent output amount in satoshi's
        // amountNumber is a decimal number ie 0.09942 which could end up being 0.09941999999999999, so need to fix with code below
        let bitcoinFormatter = NumberFormatter()
        bitcoinFormatter.numberStyle = .decimal
        bitcoinFormatter.roundingMode = .halfUp
        bitcoinFormatter.maximumFractionDigits = 8
        bitcoinFormatter.locale = Locale(identifier: "en_US")
        let amount = TLCoin(bitcoinAmount: bitcoinFormatter.string(from: amountNumber)!, bitcoinDenomination: TLBitcoinDenomination.bitcoin, locale: Locale(identifier: "en_US"))
        blockchainUnspentOutputDict.setObject(NSNumber(value: amount.toUInt64() as UInt64), forKey: "value" as NSCopying)


        let confirmations: AnyObject? = unspentOutputDict.object(forKey: "confirmations") as AnyObject?
        if (confirmations != nil) {
            blockchainUnspentOutputDict.setObject(confirmations!, forKey: "confirmations" as NSCopying)
        } else {
            blockchainUnspentOutputDict.setObject(0, forKey: "confirmations" as NSCopying)
        }
        
        return blockchainUnspentOutputDict
    }
    
    func pushTx(_ txHex: String, success: @escaping TLNetworking.SuccessHandler, failure: @escaping TLNetworking.FailureHandler) {
        let endPoint = "api/tx/send"
        let parameters = [
            "rawtx": txHex
        ]
        
        let url = URL(string: endPoint, relativeTo: URL(string: self.baseURL))!
        self.networking.httpPOST(url, parameters: parameters as NSDictionary,
            success: success, failure: failure)
    }
    
    
    class func insightUnspentOutputsToBlockchainUnspentOutputs(_ unspentOutputs: NSArray) -> NSDictionary {
        let transansformedUnspentOutputs = NSMutableArray(capacity: unspentOutputs.count)
        
        for _unspentOutput in unspentOutputs {
            let unspentOutput = _unspentOutput as! NSDictionary
            if let dict = TLInsightAPI.insightToBlockchainUnspentOutput(unspentOutput) {
                transansformedUnspentOutputs.add(dict)
            }
        }
        
        let transansformedJsonData = NSMutableDictionary()
        transansformedJsonData.setObject(transansformedUnspentOutputs, forKey: "unspent_outputs" as NSCopying)
        
        return transansformedJsonData
    }
    
    class func insightAddressesTxsToBlockchainMultiaddr(_ addressArray: NSArray, txs: NSArray) -> NSDictionary {
        let addressExistDict = NSMutableDictionary(capacity: addressArray.count)
        
        let transansformedAddressesDict = NSMutableDictionary(capacity: addressArray.count)
        
        for _address in addressArray {
            let address = _address as! String
            addressExistDict.setObject("", forKey: address as NSCopying)
            
            let transformedAddress = NSMutableDictionary()
            transformedAddress.setObject(0, forKey: "n_tx" as NSCopying)
            transformedAddress.setObject(address, forKey: "address" as NSCopying)
            transformedAddress.setObject(TLCoin.zero(), forKey: "final_balance" as NSCopying)
            transansformedAddressesDict.setObject(transformedAddress, forKey: address as NSCopying)
        }
        
        let transformedTxs = NSMutableArray(capacity: txs.count)
        
        let transansformedAddresses = NSMutableArray(capacity: addressArray.count)
        var i = txs.count - 1
        while i >= 0 {
            if txs.object(at: i) as! NSObject == NSNull() {
                i -= 1
                continue
            }
            let tx = txs.object(at: i) as! NSDictionary
            let transformedTx = TLInsightAPI.insightTxToBlockchainTx(tx)
            if (transformedTx == nil) {
                i -= 1
                continue;
            }
            transformedTxs.add(transformedTx!)
        
            let inputsArray = transformedTx!.object(forKey: "inputs") as? NSArray
            
            if (inputsArray != nil) {
                for _input in inputsArray! {
                    let input = _input as! NSDictionary
                    let prevOut = input.object(forKey: "prev_out") as? NSDictionary
                    if (prevOut != nil) {
                        let addr = prevOut!.object(forKey: "addr") as? String
                        
                        if (addr != nil && addressExistDict.object(forKey: addr!) != nil) {
                            let transformedAddress = transansformedAddressesDict.object(forKey: addr!) as! NSMutableDictionary
                            var addressBalance = transformedAddress.object(forKey: "final_balance") as! TLCoin

                            let value = (prevOut!.object(forKey: "value") as! NSNumber).uint64Value
                            addressBalance = addressBalance.subtract(TLCoin(uint64: value))
                            transformedAddress.setObject(addressBalance, forKey: "final_balance" as NSCopying)
                            
                            let nTxs = transformedAddress.object(forKey: "n_tx") as! Int
                            transformedAddress.setObject(nTxs + 1, forKey: "n_tx" as NSCopying)
                        }
                    }
                    
                }
            }
            
            let outsArray = transformedTx!.object(forKey: "out") as? NSArray
            
            if (outsArray != nil) {
                for _output in outsArray! {
                    let output = _output as! NSDictionary
                    let addr = output.object(forKey: "addr") as? String
                    if (addr != nil && addressExistDict.object(forKey: addr!) != nil) {
                        let transformedAddress = transansformedAddressesDict.object(forKey: addr!) as! NSMutableDictionary
                        var addressBalance = transformedAddress.object(forKey: "final_balance") as! TLCoin
                        
                        let value = (output.object(forKey: "value") as! NSNumber).uint64Value
                        addressBalance = addressBalance.add(TLCoin(uint64: value))
                        transformedAddress.setObject(addressBalance, forKey: "final_balance" as NSCopying)
                        
                        let nTxs = transformedAddress.object(forKey: "n_tx") as! Int
                        transformedAddress.setObject(nTxs + 1, forKey: "n_tx" as NSCopying)
                    }
                }
            }
            i -= 1
        }
        
        //TODO: need to sort txs because insight does not sort it for you, ask devs to sort array
        let sortedtransformedTxs = transformedTxs.sortedArray(comparator: {
            (a:AnyObject!, b:AnyObject!) -> ComparisonResult in
            
            let first = (a as! NSDictionary).object(forKey: "time") as! Int
            if (first == 0) {
                return ComparisonResult.orderedAscending
            }
            
            let second = (b as! NSDictionary).object(forKey: "time") as! Int
            if (second == 0) {
                return ComparisonResult.orderedDescending
            }
            
            if(second > first) {
                return ComparisonResult.orderedDescending
            }
            else if (second == first) {
                return ComparisonResult.orderedSame
            }
            return ComparisonResult.orderedAscending
        } as! (Any, Any) -> ComparisonResult)
        
        for _key in transansformedAddressesDict {
            let key = _key.key as! String
            let transformedAddress = transansformedAddressesDict.object(forKey: key) as! NSMutableDictionary
            let addressBalance = transformedAddress.object(forKey: "final_balance") as! TLCoin
            transformedAddress.setObject(NSNumber(value: addressBalance.toUInt64() as UInt64), forKey: "final_balance" as NSCopying)
            transansformedAddresses.add(transformedAddress)
        }
        
        let transansformedJsonData = NSMutableDictionary()
        transansformedJsonData.setObject(sortedtransformedTxs, forKey: "txs" as NSCopying)
        transansformedJsonData.setObject(transansformedAddresses, forKey: "addresses" as NSCopying)
        
        return transansformedJsonData
    }
    
    class func insightTxToBlockchainTx(_ txDict: NSDictionary) -> NSDictionary? {
        let blockchainTxDict = NSMutableDictionary()
        
        let vins = txDict.object(forKey: "vin") as? NSArray
        let vouts = txDict.object(forKey: "vout") as? NSArray
        //if (vins == nil && vouts == nil && txDict.objectForKey("possibleDoubleSpend") != nil) {
        if (vins == nil && vouts == nil) {
            return nil;
        }
        
        if let txid = txDict.object(forKey: "txid") {
            blockchainTxDict.setObject(txid, forKey: "hash" as NSCopying)
        }
        if let version = txDict.object(forKey: "version") {
            blockchainTxDict.setObject(version, forKey: "ver" as NSCopying)
        }
        if let size = txDict.object(forKey: "size") {
            blockchainTxDict.setObject(size, forKey: "size" as NSCopying)
        }
        //WARNING: time dont match on different blockexplorers, and field does not exist if unconfirmed
        let time: AnyObject? = txDict.object(forKey: "time") as AnyObject?
        if (time != nil) {
            blockchainTxDict.setObject(time!, forKey: "time" as NSCopying)
        } else {
            blockchainTxDict.setObject(0, forKey: "time" as NSCopying)
        }
        //TODO: get current block and compute block_height
        let confirmations: AnyObject? = txDict.object(forKey: "confirmations") as AnyObject?
        if (confirmations != nil) {
            blockchainTxDict.setObject(confirmations!, forKey:"block_height" as NSCopying)
            blockchainTxDict.setObject(confirmations!, forKey:"confirmations" as NSCopying)
        } else {
            blockchainTxDict.setObject(0, forKey: "block_height" as NSCopying)
            blockchainTxDict.setObject(0, forKey: "confirmations" as NSCopying)
        }
        
        if vins != nil {
            let inputs = NSMutableArray()
            for _vin in vins! {
                let vin = _vin as! NSDictionary
                let input = NSMutableDictionary()
                if let sequence = vin.object(forKey: "sequence") {
                    input.setObject(sequence, forKey: "sequence" as NSCopying)
                }
                
                let prev_out = NSMutableDictionary()
                
                let addr = vin.object(forKey: "addr") as? String
                if (addr != nil) {
                    prev_out.setObject(addr!, forKey: "addr" as NSCopying)
                } else {
                    //can be nil, for example, mined coins on tx 32ee55597c590bb104c524298b14fd1c0ac96a230810bd1e68d109df532a46a0
                }
                if let valueSat = vin.object(forKey: "valueSat") {
                    prev_out.setObject(valueSat, forKey: "value" as NSCopying)
                }
                if let n = vin.object(forKey: "n") {
                    prev_out.setObject(n, forKey: "n" as NSCopying)
                }
                input.setObject(prev_out, forKey: "prev_out" as NSCopying)
                
                inputs.add(input)
            }
            blockchainTxDict.setObject(inputs, forKey: "inputs" as NSCopying)
        }
    
        if vouts != nil {
            let outs = NSMutableArray()
            for _vout in vouts! {
                let vout = _vout as! NSDictionary
                let aOut = NSMutableDictionary()
                if let n = vout.object(forKey: "n") {
                    aOut.setObject(n, forKey: "n" as NSCopying)
                }
                
                if let scriptPubKey = (vout.object(forKey: "scriptPubKey") as? NSDictionary) {
                    let addresses = scriptPubKey.object(forKey: "addresses") as? NSArray
                    if (addresses != nil) {
                        if (addresses!.count == 1) {
                            aOut.setObject(addresses!.object(at: 0), forKey: "addr" as NSCopying)
                        }
                    }
                    if let hex = scriptPubKey.object(forKey: "hex") {
                        aOut.setObject(hex, forKey: "script" as NSCopying)
                    }
                }

                if let value = vout.object(forKey: "value") as? String {
                    let coinValue = TLCoin(bitcoinAmount: value, bitcoinDenomination: .bitcoin, locale: Locale(identifier: "en_US"))
                    aOut.setObject(Int(coinValue.toUInt64()), forKey: "value" as NSCopying)

                }
                outs.add(aOut)
            }
            blockchainTxDict.setObject(outs, forKey: "out" as NSCopying)
        }
        
        return blockchainTxDict
    }
}
