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
    
    func getBlockHeight(success: (TLNetworking.SuccessHandler), failure: (TLNetworking.FailureHandler)) {
        let endPoint = "api/status/"
        let parameters = [
            "q": "getTxOutSetInfo"
        ]
        let url = NSURL(string: endPoint, relativeToURL: NSURL(string: self.baseURL))!
        self.networking.httpGET(url, parameters: parameters,
            success: {
                (jsonData: AnyObject!) in
                success(jsonData)
            }, failure: {
                (code: NSInteger, status: String!) in
                failure(code, status)
        })
    }
    
    func getUnspentOutputsSynchronous(addressArray: NSArray) -> NSDictionary {
        let endPoint = String(format: "%@%@%@", "api/addrs/", addressArray.componentsJoinedByString(","), "/utxo")
        let parameters = [:]
        
        let url = NSURL(string: endPoint, relativeToURL: NSURL(string: self.baseURL))!
        
        let jsonData: AnyObject? = self.networking.httpGETSynchronous(url, parameters: parameters)
        
        if jsonData is NSDictionary { // if don't get dict http error, will get array
            return jsonData as! NSDictionary
        }
        
        let transansformedJsonData = TLInsightAPI.insightUnspentOutputsToBlockchainUnspentOutputs(jsonData as! NSArray)
        
        return transansformedJsonData
    }
    
    func getUnspentOutputs(addressArray: Array<String>, success: TLNetworking.SuccessHandler, failure: TLNetworking.FailureHandler) {
        let endPoint = String(format: "%@%@%@", "api/addrs/", addressArray.joinWithSeparator(","), "/utxo")
        let parameters = [:]
        
        let url = NSURL(string: endPoint, relativeToURL: NSURL(string: self.baseURL))!
        self.networking.httpGET(url, parameters: parameters,
            success: {
                (jsonData: AnyObject!) in
                
                let transansformedJsonData = TLInsightAPI.insightUnspentOutputsToBlockchainUnspentOutputs(jsonData as! NSArray) as NSDictionary
                
                success(transansformedJsonData)
            }, failure: {
                (code: NSInteger, status: String!) in
                failure(code, status)
        })
    }
    
    func getAddressesInfoSynchronous(addressArray: Array<String>, txCountFrom: Int=0, allTxs: NSMutableArray=[]) -> NSDictionary {
        let endPoint = String(format: "%@%@%@", "api/addrs/", addressArray.joinWithSeparator(","), "/txs")
        
        let parameters = ["from":txCountFrom]

        let url = NSURL(string: endPoint, relativeToURL: NSURL(string: self.baseURL))!
        
        let jsonData: AnyObject? = self.networking.httpGETSynchronous(url, parameters: parameters)
        
        if ((jsonData as! NSDictionary).objectForKey(TLNetworking.STATIC_MEMBERS.HTTP_ERROR_CODE) != nil) {
            return jsonData as! NSDictionary
        }
        
        let txs = (jsonData as! NSDictionary).objectForKey("items") as! NSArray
        let to = ((jsonData as! NSDictionary).objectForKey("to") as! NSNumber)
        let totalItems = ((jsonData as! NSDictionary).objectForKey("totalItems") as! NSNumber).unsignedLongLongValue
        
        if to.unsignedLongLongValue >= totalItems {
            if allTxs.count == 0 {
                let transansformedJsonData = TLInsightAPI.insightAddressesTxsToBlockchainMultiaddr(addressArray, txs: txs)
                return transansformedJsonData
            } else {
                allTxs.addObjectsFromArray(txs as [AnyObject])
                let transansformedJsonData = TLInsightAPI.insightAddressesTxsToBlockchainMultiaddr(addressArray, txs: allTxs)
                return transansformedJsonData
            }
        } else {
            allTxs.addObjectsFromArray(txs as [AnyObject])
            return self.getAddressesInfoSynchronous(addressArray, txCountFrom: to.integerValue, allTxs: allTxs)
        }
    }
    
    func getAddressesInfo(addressArray: Array<String>, txCountFrom: Int=0, allTxs: NSMutableArray=[], success: TLNetworking.SuccessHandler, failure: TLNetworking.FailureHandler) {
        let endPoint = String(format: "%@%@%@", "api/addrs/", addressArray.joinWithSeparator(","), "/txs")
        let parameters = ["from":txCountFrom]

        let url = NSURL(string: endPoint, relativeToURL: NSURL(string: self.baseURL))!
        
        self.networking.httpGET(url, parameters: parameters,
            success: {
                (jsonData: AnyObject!) in
                if ((jsonData as! NSDictionary).objectForKey(TLNetworking.STATIC_MEMBERS.HTTP_ERROR_CODE) != nil) {
                    success(jsonData as! NSDictionary)
                }
 
                let txs = (jsonData as! NSDictionary).objectForKey("items") as! NSArray
                let to = ((jsonData as! NSDictionary).objectForKey("to") as! NSNumber)
                let totalItems = ((jsonData as! NSDictionary).objectForKey("totalItems") as! NSNumber).unsignedLongLongValue
                if to.unsignedLongLongValue >= totalItems {
                    if allTxs.count == 0 {
                        let transformedJsonData = TLInsightAPI.insightAddressesTxsToBlockchainMultiaddr(addressArray, txs: txs)
                        success(transformedJsonData)
                    } else {
                        allTxs.addObjectsFromArray(txs as [AnyObject])
                        let transformedJsonData = TLInsightAPI.insightAddressesTxsToBlockchainMultiaddr(addressArray, txs: allTxs)
                        success(transformedJsonData)
                    }
                } else {
                    allTxs.addObjectsFromArray(txs as [AnyObject])
                    self.getAddressesInfo(addressArray, allTxs: allTxs, txCountFrom: to.integerValue, success: success, failure: failure)
                }
            }, failure: failure)
    }
    
    func getAddressData(address: String, success: TLNetworking.SuccessHandler, failure: TLNetworking.FailureHandler) {
        let endPoint = String(format: "%@%@", "api/txs/?address=", address)
        let parameters = [:]
        
        let url = NSURL(string: endPoint, relativeToURL: NSURL(string: self.baseURL))!
        self.networking.httpGET(url, parameters: parameters,
            success: {
                (jsonData: AnyObject!) in
                
                let txs = (jsonData as! NSDictionary!).objectForKey("txs") as! NSArray
                let transformedTxs = NSMutableArray(capacity:txs.count)
                
                for tx in txs as! [NSDictionary] {
                    transformedTxs.addObject(TLInsightAPI.insightTxToBlockchainTx(tx))
                }
                
                let transansformedJsonData = NSMutableDictionary()
                transansformedJsonData.setObject(transformedTxs, forKey:"txs")
                
                success(transansformedJsonData)
            }, failure: failure)
    }
    
    func getAddressDataSynchronous(address: String) -> NSDictionary {
        let endPoint = String(format: "%@%@", "api/txs/?address=", address)
        let parameters = [:]
        
        let url = NSURL(string: endPoint, relativeToURL: NSURL(string: self.baseURL))!
        let jsonData: AnyObject? = self.networking.httpGETSynchronous(url, parameters: parameters)
        
        let txs = (jsonData as! NSDictionary!).objectForKey("txs") as! NSArray
        let transformedTxs = NSMutableArray(capacity:txs.count)
        
        for tx in txs as! [NSDictionary] {
            transformedTxs.addObject(TLInsightAPI.insightTxToBlockchainTx(tx))
        }
        
        let transansformedJsonData = NSMutableDictionary()
        transansformedJsonData.setObject(transformedTxs, forKey:"txs")
        
        return transansformedJsonData
    }
    
    func getTx(txHash: String, success: TLNetworking.SuccessHandler, failure: TLNetworking.FailureHandler) {
        let endPoint = String(format: "%@%@", "api/tx/", txHash)
        let parameters = [:]
        
        let url = NSURL(string: endPoint, relativeToURL: NSURL(string: self.baseURL))!
        self.networking.httpGET(url, parameters: parameters, success: success, failure: failure)
    }

    func getTxBackground(txHash: String, success: TLNetworking.SuccessHandler, failure: TLNetworking.FailureHandler) {
        let endPoint = String(format: "%@%@", "api/tx/", txHash)
        let parameters = [:]
        
        let url = NSURL(string: endPoint, relativeToURL: NSURL(string: self.baseURL))!
        self.networking.httpGETBackground(url, parameters: parameters, success: success, failure: failure)
    }

    
    class func insightToBlockchainUnspentOutput(unspentOutputDict: NSDictionary) -> NSDictionary? {
        // bug in insight, see https://insight.bitpay.com/api/addrs/1GjuCPLhmrdrAdifz1XLdpVVeQjsvZYGou/utxo
        if unspentOutputDict.objectForKey("scriptPubKey") == nil {
            // got following so far
            // insight bug for txid 1cf031f8ac2896994e57c299e23b4ed35e2d218a7c6877302da0e3292337f530 when tried to do f5b0e820f23a6724f669463a6bf2e03806169b3d7fee7b6d27a642840109823d
            DLog("no scriptPubKey, insight bug? txid %@", function: unspentOutputDict.objectForKey("txid") as! String)
            return nil
        }
        
        let blockchainUnspentOutputDict = NSMutableDictionary()
        let txid = unspentOutputDict.objectForKey("txid") as! String
        let txHash = TLWalletUtils.reverseHexString(txid)
        blockchainUnspentOutputDict.setObject(txHash, forKey: "tx_hash")
        blockchainUnspentOutputDict.setObject(txid, forKey: "tx_hash_big_endian")
        blockchainUnspentOutputDict.setObject(unspentOutputDict.objectForKey("vout")!, forKey: "tx_output_n")
        blockchainUnspentOutputDict.setObject(unspentOutputDict.objectForKey("scriptPubKey")!, forKey: "script")
        let amountNumber = unspentOutputDict.objectForKey("amount") as! NSNumber
        
        
        // Insight API should really return unspent output amount in satoshi's
        // amountNumber is a decimal number ie 0.09942 which could end up being 0.09941999999999999, so need to fix with code below
        let bitcoinFormatter = NSNumberFormatter()
        bitcoinFormatter.numberStyle = .DecimalStyle
        bitcoinFormatter.roundingMode = .RoundHalfUp
        bitcoinFormatter.maximumFractionDigits = 8
        bitcoinFormatter.locale = NSLocale(localeIdentifier: "en_US")
        let amount = TLCoin(bitcoinAmount: bitcoinFormatter.stringFromNumber(amountNumber)!, bitcoinDenomination: TLBitcoinDenomination.Bitcoin, locale: NSLocale(localeIdentifier: "en_US"))
        blockchainUnspentOutputDict.setObject(NSNumber(unsignedLongLong: amount.toUInt64()), forKey: "value")


        let confirmations: AnyObject? = unspentOutputDict.objectForKey("confirmations") as AnyObject?
        if (confirmations != nil) {
            blockchainUnspentOutputDict.setObject(confirmations!, forKey: "confirmations")
        } else {
            blockchainUnspentOutputDict.setObject(0, forKey: "confirmations")
        }
        
        return blockchainUnspentOutputDict
    }
    
    func pushTx(txHex: String, success: TLNetworking.SuccessHandler, failure: TLNetworking.FailureHandler) {
        let endPoint = "api/tx/send"
        let parameters = [
            "rawtx": txHex
        ]
        
        let url = NSURL(string: endPoint, relativeToURL: NSURL(string: self.baseURL))!
        self.networking.httpPOST(url, parameters: parameters,
            success: success, failure: failure)
    }
    
    
    class func insightUnspentOutputsToBlockchainUnspentOutputs(unspentOutputs: NSArray) -> NSDictionary {
        let transansformedUnspentOutputs = NSMutableArray(capacity: unspentOutputs.count)
        
        for _unspentOutput in unspentOutputs {
            let unspentOutput = _unspentOutput as! NSDictionary
            if let dict = TLInsightAPI.insightToBlockchainUnspentOutput(unspentOutput) {
                transansformedUnspentOutputs.addObject(dict)
            }
        }
        
        let transansformedJsonData = NSMutableDictionary()
        transansformedJsonData.setObject(transansformedUnspentOutputs, forKey: "unspent_outputs")
        
        return transansformedJsonData
    }
    
    class func insightAddressesTxsToBlockchainMultiaddr(addressArray: NSArray, txs: NSArray) -> NSDictionary {
        let addressExistDict = NSMutableDictionary(capacity: addressArray.count)
        
        let transansformedAddressesDict = NSMutableDictionary(capacity: addressArray.count)
        
        for _address in addressArray {
            let address = _address as! String
            addressExistDict.setObject("", forKey: address)
            
            let transformedAddress = NSMutableDictionary()
            transformedAddress.setObject(0, forKey: "n_tx")
            transformedAddress.setObject(address, forKey: "address")
            transformedAddress.setObject(TLCoin.zero(), forKey: "final_balance")
            transansformedAddressesDict.setObject(transformedAddress, forKey: address)
        }
        
        let transformedTxs = NSMutableArray(capacity: txs.count)
        
        let transansformedAddresses = NSMutableArray(capacity: addressArray.count)
        for (var i = txs.count - 1; i >= 0; i--) {
            if txs.objectAtIndex(i) as! NSObject == NSNull() {
                continue
            }
            let tx = txs.objectAtIndex(i) as! NSDictionary
            let transformedTx = TLInsightAPI.insightTxToBlockchainTx(tx)
            transformedTxs.addObject(transformedTx)
        
            let inputsArray = transformedTx.objectForKey("inputs") as? NSArray
            
            if (inputsArray != nil) {
                for _input in inputsArray! {
                    let input = _input as! NSDictionary
                    let prevOut = input.objectForKey("prev_out") as? NSDictionary
                    if (prevOut != nil) {
                        let addr = prevOut!.objectForKey("addr") as? String
                        
                        if (addr != nil && addressExistDict.objectForKey(addr!) != nil) {
                            let transformedAddress = transansformedAddressesDict.objectForKey(addr!) as! NSMutableDictionary
                            var addressBalance = transformedAddress.objectForKey("final_balance") as! TLCoin

                            let value = (prevOut!.objectForKey("value") as! NSNumber).unsignedLongLongValue
                            addressBalance = addressBalance.subtract(TLCoin(uint64: value))
                            transformedAddress.setObject(addressBalance, forKey: "final_balance")
                            
                            let nTxs = transformedAddress.objectForKey("n_tx") as! Int
                            transformedAddress.setObject(nTxs + 1, forKey: "n_tx")
                        }
                    }
                    
                }
            }
            
            let outsArray = transformedTx.objectForKey("out") as? NSArray
            
            if (outsArray != nil) {
                for _output in outsArray! {
                    let output = _output as! NSDictionary
                    let addr = output.objectForKey("addr") as? String
                    if (addr != nil && addressExistDict.objectForKey(addr!) != nil) {
                        let transformedAddress = transansformedAddressesDict.objectForKey(addr!) as! NSMutableDictionary
                        var addressBalance = transformedAddress.objectForKey("final_balance") as! TLCoin
                        
                        let value = (output.objectForKey("value") as! NSNumber).unsignedLongLongValue
                        addressBalance = addressBalance.add(TLCoin(uint64: value))
                        transformedAddress.setObject(addressBalance, forKey: "final_balance")
                        
                        let nTxs = transformedAddress.objectForKey("n_tx") as! Int
                        transformedAddress.setObject(nTxs + 1, forKey: "n_tx")
                    }
                }
            }
        }
        
        //TODO: need to sort txs because insight does not sort it for you, ask devs to sort array
        let sortedtransformedTxs = transformedTxs.sortedArrayUsingComparator{
            (a:AnyObject!, b:AnyObject!) -> NSComparisonResult in
            
            let first = (a as! NSDictionary).objectForKey("time") as! Int
            if (first == 0) {
                return NSComparisonResult.OrderedAscending
            }
            
            let second = (b as! NSDictionary).objectForKey("time") as! Int
            if (second == 0) {
                return NSComparisonResult.OrderedDescending
            }
            
            if(second > first) {
                return NSComparisonResult.OrderedDescending
            }
            else if (second == first) {
                return NSComparisonResult.OrderedSame
            }
            return NSComparisonResult.OrderedAscending
        }
        
        for _key in transansformedAddressesDict {
            let key = _key.key as! String
            let transformedAddress = transansformedAddressesDict.objectForKey(key) as! NSMutableDictionary
            let addressBalance = transformedAddress.objectForKey("final_balance") as! TLCoin
            transformedAddress.setObject(NSNumber(unsignedLongLong: addressBalance.toUInt64()), forKey: "final_balance")
            transansformedAddresses.addObject(transformedAddress)
        }
        
        let transansformedJsonData = NSMutableDictionary()
        transansformedJsonData.setObject(sortedtransformedTxs, forKey: "txs")
        transansformedJsonData.setObject(transansformedAddresses, forKey: "addresses")
        
        return transansformedJsonData
    }
    
    class func insightTxToBlockchainTx(txDict: NSDictionary) -> NSDictionary {
        let blockchainTxDict = NSMutableDictionary()
        
        blockchainTxDict.setObject(txDict.objectForKey("txid")!, forKey: "hash")
        blockchainTxDict.setObject(txDict.objectForKey("version")!, forKey: "ver")
        blockchainTxDict.setObject(txDict.objectForKey("size")!, forKey: "size")
        //WARNING: time dont match on different blockexplorers, and field does not exist if unconfirmed
        let time: AnyObject? = txDict.objectForKey("time")
        if (time != nil) {
            blockchainTxDict.setObject(time!, forKey: "time")
        } else {
            blockchainTxDict.setObject(0, forKey: "time")
        }
        //TODO: get current block and compute block_height
        let confirmations: AnyObject? = txDict.objectForKey("confirmations")
        if (confirmations != nil) {
            blockchainTxDict.setObject(confirmations!, forKey:"block_height")
            blockchainTxDict.setObject(confirmations!, forKey:"confirmations")
        } else {
            blockchainTxDict.setObject(0, forKey: "block_height")
            blockchainTxDict.setObject(0, forKey: "confirmations")
        }
        
        let vins = txDict.objectForKey("vin") as! NSArray
        let inputs = NSMutableArray()
        for _vin in vins {
            let vin = _vin as! NSDictionary
            let input = NSMutableDictionary()
            
            input.setObject(vin.objectForKey("sequence")!, forKey: "sequence")
            
            let prev_out = NSMutableDictionary()
            
            let addr = vin.objectForKey("addr") as? String
            if (addr != nil) {
                prev_out.setObject(addr!, forKey: "addr")
            } else {
                //can be nil, for example, mined coins on tx 32ee55597c590bb104c524298b14fd1c0ac96a230810bd1e68d109df532a46a0
            }
            
            prev_out.setObject(vin.objectForKey("valueSat")!, forKey: "value")
            prev_out.setObject(vin.objectForKey("n")!, forKey: "n")
            
            input.setObject(prev_out, forKey: "prev_out")
            
            inputs.addObject(input)
        }
        blockchainTxDict.setObject(inputs, forKey: "inputs")
        
        
        let vouts = txDict.objectForKey("vout") as! NSArray
        let outs = NSMutableArray()
        for _vout in vouts {
            let vout = _vout as! NSDictionary
            let aOut = NSMutableDictionary()
            aOut.setObject(vout.objectForKey("n")!, forKey: "n")
            aOut.setObject((vout.objectForKey("scriptPubKey") as! NSDictionary).objectForKey("hex")!, forKey: "script")
            let addresses = ((vout.objectForKey("scriptPubKey") as! NSDictionary).objectForKey("addresses")) as? NSArray
            if (addresses != nil) {
                if (addresses!.count == 1) {
                    aOut.setObject(addresses!.objectAtIndex(0), forKey: "addr")
                }
            }
            
            let value = vout.objectForKey("value") as! String
            let coinValue = TLCoin(bitcoinAmount: value, bitcoinDenomination: .Bitcoin, locale: NSLocale(localeIdentifier: "en_US"))
            aOut.setObject(Int(coinValue.toUInt64()), forKey: "value")
            
            outs.addObject(aOut)
        }
        blockchainTxDict.setObject(outs, forKey: "out")
        
        return blockchainTxDict
    }
}
