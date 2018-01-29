//
//  TLBlockExplorerAPI.swift
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

enum TLBlockExplorer:Int {
    case bitcoin_blockchain  = 0
    case bitcoin_insight     = 1
    case bitcoinCash_blockexplorer     = 2
    case bitcoinCash_insight     = 3
}

class TLBlockExplorerAPI {
    
    struct STATIC_MEMBERS {
//        static var blockExplorerAPI:TLBlockExplorer = .bitcoin_blockchain
//        static var BLOCKEXPLORER_BASE_URL:String? = "https://blockchain.info/"
        static var _instance:TLBlockExplorerAPI? = nil
    }
    typealias BlockHeightSuccessHandler = (TLBlockHeightObject) -> ()
    typealias UnspentOutputsSuccessHandler = (TLUnspentOutputsObject) -> ()
    typealias AddressesSuccessHandler = (TLAddressesObject) -> ()
    typealias TxObjectSuccessHandler = (TLTxObject) -> ()

    private lazy var coinType2BlockExplorerAPI = [TLCoinType:TLBlockExplorer]()
    private lazy var coinType2BlockExplorerURL = [TLCoinType:String]()

    var bitcoinBlockchainAPI:TLBlockchainAPI? = nil
    var bitcoinInsightAPI:TLInsightAPI? = nil
    var bitcoinCashBlockExplorerAPI:TLInsightAPI? = nil
    var bitcoinCashInsightAPI:TLInsightAPI? = nil
    
    class func instance() -> (TLBlockExplorerAPI) {
        if(STATIC_MEMBERS._instance == nil) {
            STATIC_MEMBERS._instance = TLBlockExplorerAPI()
        }
        return STATIC_MEMBERS._instance!
    }
    
    init() {
        TLWalletUtils.SUPPORT_COIN_TYPES().forEach({ (coinType) in
            var blockExplorerURL = TLPreferences.getBlockExplorerURL(coinType, blockExplorer: TLPreferences.getBlockExplorerAPI(coinType))
            if (blockExplorerURL == nil) {
                TLPreferences.resetBlockExplorerAPIURL(coinType)
                blockExplorerURL = TLPreferences.getBlockExplorerURL(coinType, blockExplorer: TLPreferences.getBlockExplorerAPI(coinType))
            }
            self.coinType2BlockExplorerAPI[coinType] = TLPreferences.getBlockExplorerAPI(coinType)
            self.coinType2BlockExplorerURL[coinType] = blockExplorerURL
            switch coinType {
            case .BCH:
                if (self.coinType2BlockExplorerAPI[coinType] == .bitcoinCash_blockexplorer) {
                    self.bitcoinCashBlockExplorerAPI = TLInsightAPI(baseURL: blockExplorerURL!)
                } else if (self.coinType2BlockExplorerAPI[coinType] == .bitcoinCash_insight) {
                    self.bitcoinCashInsightAPI = TLInsightAPI(baseURL: blockExplorerURL!)
                }
            case .BTC:
                if (self.coinType2BlockExplorerAPI[coinType] == .bitcoin_blockchain) {
                    self.bitcoinBlockchainAPI = TLBlockchainAPI(baseURL: blockExplorerURL!)
                    //needed for push tx api for stealth addresses
                    self.bitcoinInsightAPI = TLInsightAPI(baseURL: "https://insight.bitpay.com/")
                } else if (self.coinType2BlockExplorerAPI[coinType] == .bitcoin_insight) {
                    self.bitcoinInsightAPI = TLInsightAPI(baseURL: blockExplorerURL!)
                }
            }
        })
    }
    
    
    func getBlockHeight(_ coinType: TLCoinType, success: @escaping TLBlockExplorerAPI.BlockHeightSuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> (){
        switch coinType {
        case .BCH:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoinCash_blockexplorer) {
                self.bitcoinBlockchainAPI!.getBlockHeight({(height:AnyObject!) in
                    let blockHeight = TLBlockHeightObject(jsonDict:  ["height": UInt64(NSNumber(value: (height as! NSString).longLongValue as Int64)) as AnyObject])
                    success(blockHeight)
                }, failure:failure)
            }
            else {
                //Insight does not have a good way to get block height
                /*
                 self.bitcoinInsightAPI!.getBlockHeight({(jsonData:AnyObject!) in
                 let blockHeight = ["height": ((jsonData as! NSDictionary).objectForKey("txoutsetinfo") as! NSDictionary).objectForKey("height")!]
                 success(blockHeight)
                 }, failure:{(code:NSInteger, status:String!) in })
                 */
            }
        case .BTC:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoin_blockchain) {
                self.bitcoinBlockchainAPI!.getBlockHeight({(height:AnyObject!) in
                    let blockHeight = TLBlockHeightObject(jsonDict:  ["height": UInt64(NSNumber(value: (height as! NSString).longLongValue as Int64)) as AnyObject])
                    success(blockHeight)
                }, failure:failure)
            }
            else {
                //Insight does not have a good way to get block height
                /*
                 self.bitcoinInsightAPI!.getBlockHeight({(jsonData:AnyObject!) in
                 let blockHeight = ["height": ((jsonData as! NSDictionary).objectForKey("txoutsetinfo") as! NSDictionary).objectForKey("height")!]
                 success(blockHeight)
                 }, failure:{(code:NSInteger, status:String!) in })
                 */
            }
        }
    }
    
    func getAddressesInfoSynchronous(_ coinType: TLCoinType, addressArray:Array<String>) throws -> TLAddressesObject {
        switch coinType {
        case .BCH:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoinCash_blockexplorer) {
                return TLAddressesObject(coinType, jsonDict: try self.bitcoinCashBlockExplorerAPI!.getAddressesInfoSynchronous(addressArray))
            } else {
                return TLAddressesObject(coinType, jsonDict: try self.bitcoinCashInsightAPI!.getAddressesInfoSynchronous(addressArray))
            }
        case .BTC:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoin_blockchain) {
                return TLAddressesObject(coinType, jsonDict: try self.bitcoinBlockchainAPI!.getAddressesInfoSynchronous(addressArray))
            } else {
                return TLAddressesObject(coinType, jsonDict: try self.bitcoinInsightAPI!.getAddressesInfoSynchronous(addressArray))
            }
        }
    }
    
    func getAddressesInfo(_ coinType: TLCoinType, addressArray:Array<String>, success:@escaping TLBlockExplorerAPI.AddressesSuccessHandler, failure:@escaping TLNetworking.FailureHandler)-> () {
        switch coinType {
        case .BCH:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoinCash_blockexplorer) {
                self.bitcoinCashBlockExplorerAPI!.getAddressesInfo(addressArray, success: {
                    (jsonData) in
                    success(TLAddressesObject(coinType, jsonDict: jsonData as! NSDictionary))
                }, failure:failure)
            } else {
                self.bitcoinCashInsightAPI!.getAddressesInfo(addressArray, success: {
                    (jsonData) in
                    success(TLAddressesObject(coinType, jsonDict: jsonData as! NSDictionary))
                }, failure:failure)
            }
        case .BTC:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoin_blockchain) {
                self.bitcoinBlockchainAPI!.getAddressesInfo(addressArray, success: {
                    (jsonData) in
                    success(TLAddressesObject(coinType, jsonDict: jsonData as! NSDictionary))
                }, failure:failure)
            } else {
                self.bitcoinInsightAPI!.getAddressesInfo(addressArray, success: {
                    (jsonData) in
                    success(TLAddressesObject(coinType, jsonDict: jsonData as! NSDictionary))
                }, failure:failure)
            }
        }
    }
    
    func getUnspentOutputs(_ coinType: TLCoinType, addressArray:Array<String>, success:@escaping TLBlockExplorerAPI.UnspentOutputsSuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> () {
        switch coinType {
        case .BCH:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoinCash_blockexplorer) {
                self.bitcoinCashBlockExplorerAPI!.getUnspentOutputs(addressArray, success: {
                    (jsonData) in
                    success(TLUnspentOutputsObject(jsonData as! NSDictionary, blockExplorerJSONType: self.coinType2BlockExplorerAPI[coinType]!))
                }, failure:failure)
            } else {
                self.bitcoinCashInsightAPI!.getUnspentOutputs(addressArray, success: {
                    (jsonData) in
                    success(TLUnspentOutputsObject(jsonData as! NSDictionary, blockExplorerJSONType: self.coinType2BlockExplorerAPI[coinType]!))
                }, failure:failure)
            }
        case .BTC:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoin_blockchain) {
                self.bitcoinBlockchainAPI!.getUnspentOutputs(addressArray, success: {
                    (jsonData) in
                    success(TLUnspentOutputsObject(jsonData as! NSDictionary, blockExplorerJSONType: self.coinType2BlockExplorerAPI[coinType]!))
                }, failure:failure)
            } else {
                self.bitcoinInsightAPI!.getUnspentOutputs(addressArray, success: {
                    (jsonData) in
                    success(TLUnspentOutputsObject(jsonData as! NSDictionary, blockExplorerJSONType: self.coinType2BlockExplorerAPI[coinType]!))
                }, failure:failure)
            }
        }
    }
    
    func getUnspentOutputsSynchronous(_ coinType: TLCoinType, addressArray:NSArray) throws -> TLUnspentOutputsObject {
        switch coinType {
        case .BCH:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoinCash_blockexplorer) {
                return TLUnspentOutputsObject(try self.bitcoinCashBlockExplorerAPI!.getUnspentOutputsSynchronous(addressArray), blockExplorerJSONType: self.coinType2BlockExplorerAPI[coinType]!)
            } else {
                return TLUnspentOutputsObject(try self.bitcoinCashInsightAPI!.getUnspentOutputsSynchronous(addressArray), blockExplorerJSONType: self.coinType2BlockExplorerAPI[coinType]!)
                
                //            let jsonData = self.bitcoinInsightAPI!.getUnspentOutputsSynchronous(addressArray)
                //            if jsonData is NSDictionary { // if don't get dict http error, will get array
                //                return jsonData as! NSDictionary
                //            }
                //            let transansformedJsonData = TLInsightAPI.insightUnspentOutputsToBlockchainUnspentOutputs(jsonData as! NSArray)
            }
        case .BTC:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoin_blockchain) {
                return TLUnspentOutputsObject(try self.bitcoinBlockchainAPI!.getUnspentOutputsSynchronous(addressArray), blockExplorerJSONType: self.coinType2BlockExplorerAPI[coinType]!)
            } else {
                return TLUnspentOutputsObject(try self.bitcoinInsightAPI!.getUnspentOutputsSynchronous(addressArray), blockExplorerJSONType: self.coinType2BlockExplorerAPI[coinType]!)
                
                //            let jsonData = self.bitcoinInsightAPI!.getUnspentOutputsSynchronous(addressArray)
                //            if jsonData is NSDictionary { // if don't get dict http error, will get array
                //                return jsonData as! NSDictionary
                //            }
                //            let transansformedJsonData = TLInsightAPI.insightUnspentOutputsToBlockchainUnspentOutputs(jsonData as! NSArray)
            }
        }
    }
    
//    func getAddressDataSynchronous(_ address:String) throws -> NSDictionary {
//        if (STATIC_MEMBERS.blockExplorerAPI == .blockchain) {
//            return try self.bitcoinBlockchainAPI!.getAddressDataSynchronous(address)
//        } else {
//            return try self.bitcoinInsightAPI!.getAddressDataSynchronous(address)
//        }
//    }
//    
//    func getAddressData(_ address:String, success:@escaping TLNetworking.SuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> () {
//        if (STATIC_MEMBERS.blockExplorerAPI == .blockchain) {
//            self.bitcoinBlockchainAPI!.getAddressData(address, success:success, failure:failure)
//        } else {
//            self.bitcoinInsightAPI!.getAddressData(address, success: success, failure: failure)
//        }
//    }
    
    func getTx(_ coinType: TLCoinType, txHash:String, success:@escaping TLBlockExplorerAPI.TxObjectSuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> () {
        switch coinType {
        case .BCH:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoinCash_blockexplorer) {
                self.bitcoinCashBlockExplorerAPI!.getTx(txHash, success: {
                    (jsonData) in
                    success(TLTxObject(coinType, dict: jsonData as! NSDictionary))
                }, failure:failure)
            } else {
                self.bitcoinCashInsightAPI!.getTx(txHash, success:{(jsonData:AnyObject!) in
                    let transformedTx = TLInsightAPI.insightTxToBlockchainTx(jsonData as! NSDictionary)
                    success(TLTxObject(coinType, dict: transformedTx as! NSDictionary))
                }, failure:{(code, status) in
                    failure(code, status)
                })
            }
        case .BTC:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoin_blockchain) {
                self.bitcoinBlockchainAPI!.getTx(txHash, success: {
                    (jsonData) in
                    success(TLTxObject(coinType, dict: jsonData as! NSDictionary))
                }, failure:failure)
            } else {
                self.bitcoinInsightAPI!.getTx(txHash, success:{(jsonData:AnyObject!) in
                    let transformedTx = TLInsightAPI.insightTxToBlockchainTx(jsonData as! NSDictionary)
                    success(TLTxObject(coinType, dict: transformedTx as! NSDictionary))
                }, failure:{(code, status) in
                    failure(code, status)
                })
            }
        }
    }
    
    func getTxBackground(_ coinType: TLCoinType, txHash:String, success:@escaping TLBlockExplorerAPI.TxObjectSuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> () {
        switch coinType {
        case .BCH:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoinCash_blockexplorer) {
                self.bitcoinCashBlockExplorerAPI!.getTxBackground(txHash, success: {
                    (jsonData) in
                    success(TLTxObject(coinType, dict: jsonData as! NSDictionary))
                }, failure:failure)
            } else {
                self.bitcoinCashInsightAPI!.getTxBackground(txHash, success:{(jsonData:AnyObject!) in
                    let transformedTx = TLInsightAPI.insightTxToBlockchainTx(jsonData as! NSDictionary)
                    success(TLTxObject(coinType, dict: transformedTx!))
                }, failure:{(code, status) in
                    failure(code, status)
                })
            }
        case .BTC:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoin_blockchain) {
                self.bitcoinBlockchainAPI!.getTxBackground(txHash, success: {
                    (jsonData) in
                    success(TLTxObject(coinType, dict: jsonData as! NSDictionary))
                }, failure:failure)
            } else {
                self.bitcoinInsightAPI!.getTxBackground(txHash, success:{(jsonData:AnyObject!) in
                    let transformedTx = TLInsightAPI.insightTxToBlockchainTx(jsonData as! NSDictionary)
                    success(TLTxObject(coinType, dict: transformedTx!))
                }, failure:{(code, status) in
                    failure(code, status)
                })
            }
        }
    }
    
    func pushTx(_ coinType: TLCoinType, txHex:String, txHash:String, success:@escaping TLNetworking.SuccessHandler, failure:@escaping TLNetworking.FailureHandler)-> () {
        switch coinType {
        case .BCH:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoinCash_blockexplorer) {
                self.bitcoinCashBlockExplorerAPI!.pushTx(txHex, success:success, failure:failure)
            } else {
                self.bitcoinCashInsightAPI!.pushTx(txHex, success:success, failure:failure)
            }
        case .BTC:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoin_blockchain) {
                self.bitcoinBlockchainAPI!.pushTx(txHex, txHash:txHash, success:success, failure:failure)
            } else {
                self.bitcoinInsightAPI!.pushTx(txHex, success:success, failure:failure)
            }
        }
    }
    
    func openWebViewForAddress(_ coinType: TLCoinType, address:String) -> () {
        switch coinType {
        case .BCH:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoinCash_blockexplorer) {
                let endPoint = "address/"
                let url = String(format: "%@%@%@", self.coinType2BlockExplorerURL[coinType]!, endPoint, address)
                UIApplication.shared.openURL(URL(string: url)!)
            } else {
                let endPoint = "address/"
                let url = String(format: "%@%@%@", self.coinType2BlockExplorerURL[coinType]!, endPoint, address)
                UIApplication.shared.openURL(URL(string:url)!)
            }
        case .BTC:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoin_blockchain) {
                let endPoint = "address/"
                let url = String(format: "%@%@%@", self.coinType2BlockExplorerURL[coinType]!, endPoint, address)
                UIApplication.shared.openURL(URL(string: url)!)
            } else {
                let endPoint = "address/"
                let url = String(format: "%@%@%@", self.coinType2BlockExplorerURL[coinType]!, endPoint, address)
                UIApplication.shared.openURL(URL(string:url)!)
            }
        }
    }
    
    func openWebViewForTransaction(_ coinType: TLCoinType, txid:String) -> () {
        switch coinType {
        case .BCH:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoinCash_blockexplorer) {
                let endPoint = "tx/"
                let url = String(format: "%@%@%@", self.coinType2BlockExplorerURL[coinType]!, endPoint, txid)
                UIApplication.shared.openURL(URL(string: url)!)
            } else {
                let endPoint = "tx/"
                let url = String(format: "%@%@%@", self.coinType2BlockExplorerURL[coinType]!, endPoint, txid)
                UIApplication.shared.openURL(URL(string: url)!)
            }
        case .BTC:
            if (self.coinType2BlockExplorerAPI[coinType] == .bitcoin_blockchain) {
                let endPoint = "tx/"
                let url = String(format: "%@%@%@", self.coinType2BlockExplorerURL[coinType]!, endPoint, txid)
                UIApplication.shared.openURL(URL(string: url)!)
            } else {
                let endPoint = "tx/"
                let url = String(format: "%@%@%@", self.coinType2BlockExplorerURL[coinType]!, endPoint, txid)
                UIApplication.shared.openURL(URL(string: url)!)
            }
        }
    }
}
