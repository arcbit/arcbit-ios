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
    case blockchain  = 0
    case insight     = 1
}

class TLBlockExplorerAPI {
    
    struct STATIC_MEMBERS {
        static var blockExplorerAPI:TLBlockExplorer = .blockchain
        static var BLOCKEXPLORER_BASE_URL:String? = "https://blockchain.info/"
        static var _instance:TLBlockExplorerAPI? = nil
    }
    typealias BlockHeightSuccessHandler = (TLBlockHeightObject) -> ()
    typealias UnspentOutputsSuccessHandler = (TLUnspentOutputsObject) -> ()
    typealias AddressesSuccessHandler = (TLAddressesObject) -> ()
    typealias TxObjectSuccessHandler = (TLTxObject) -> ()

    var blockchainAPI:TLBlockchainAPI? = nil
    var insightAPI:TLInsightAPI? = nil

    class func instance() -> (TLBlockExplorerAPI) {
        if(STATIC_MEMBERS._instance == nil) {
            var blockExplorerURL = TLPreferences.getBlockExplorerURL(TLPreferences.getBlockExplorerAPI())
            if (blockExplorerURL == nil) {
                TLPreferences.resetBlockExplorerAPIURL()
                blockExplorerURL = TLPreferences.getBlockExplorerURL(TLPreferences.getBlockExplorerAPI())
            }
            
            STATIC_MEMBERS.BLOCKEXPLORER_BASE_URL = blockExplorerURL
            STATIC_MEMBERS.blockExplorerAPI = TLPreferences.getBlockExplorerAPI()
            STATIC_MEMBERS._instance = TLBlockExplorerAPI()
        }
        
        return STATIC_MEMBERS._instance!
    }
    
    init() {
        if (STATIC_MEMBERS.blockExplorerAPI == .blockchain) {
            self.blockchainAPI = TLBlockchainAPI(baseURL: STATIC_MEMBERS.BLOCKEXPLORER_BASE_URL!)
            //needed for push tx api for stealth addresses
            self.insightAPI = TLInsightAPI(baseURL: "https://insight.bitpay.com/")
        } else if (STATIC_MEMBERS.blockExplorerAPI == .insight) {
            self.insightAPI = TLInsightAPI(baseURL: STATIC_MEMBERS.BLOCKEXPLORER_BASE_URL!)
        }
    }
    
    
    func getBlockHeight(_ success: @escaping TLBlockExplorerAPI.BlockHeightSuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> (){
        if (STATIC_MEMBERS.blockExplorerAPI == .blockchain) {
            self.blockchainAPI!.getBlockHeight({(height:AnyObject!) in
                let blockHeight = TLBlockHeightObject(jsonDict:  ["height": UInt64(NSNumber(value: (height as! NSString).longLongValue as Int64)) as AnyObject])
                success(blockHeight)
                }, failure:failure)
        }
        else {
            //Insight does not have a good way to get block height
            /*
            self.insightAPI!.getBlockHeight({(jsonData:AnyObject!) in
                let blockHeight = ["height": ((jsonData as! NSDictionary).objectForKey("txoutsetinfo") as! NSDictionary).objectForKey("height")!]
                success(blockHeight)
                }, failure:{(code:NSInteger, status:String!) in })
            */
        }
    }
    
    func getAddressesInfoSynchronous(_ addressArray:Array<String>) throws -> TLAddressesObject {
        if (STATIC_MEMBERS.blockExplorerAPI == .blockchain) {
            return try self.blockchainAPI!.getAddressesInfoSynchronous(addressArray)
        } else {
            return TLAddressesObject(try self.insightAPI!.getAddressesInfoSynchronous(addressArray))
        }
    }
    
    func getAddressesInfo(_ addressArray:Array<String>, success:@escaping TLBlockExplorerAPI.AddressesSuccessHandler, failure:@escaping TLNetworking.FailureHandler)-> () {
        if (STATIC_MEMBERS.blockExplorerAPI == .blockchain) {
            self.blockchainAPI!.getAddressesInfo(addressArray, success: {
                (jsonData) in
                success(TLAddressesObject(jsonData as! NSDictionary))
//                success(AddressesObject(jsonData as! NSDictionary, blockExplorerJSONType: STATIC_MEMBERS.blockExplorerAPI))
            }, failure:failure)
        } else {
            self.insightAPI!.getAddressesInfo(addressArray, success: {
                (jsonData) in
                success(TLAddressesObject(jsonData as! NSDictionary))
//                success(AddressesObject(jsonData as! NSDictionary, blockExplorerJSONType: STATIC_MEMBERS.blockExplorerAPI))
            }, failure:failure)
        }
    }
    
    func getUnspentOutputs(_ addressArray:Array<String>, success:@escaping TLBlockExplorerAPI.UnspentOutputsSuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> () {
        if (STATIC_MEMBERS.blockExplorerAPI == .blockchain) {
            self.blockchainAPI!.getUnspentOutputs(addressArray, success: {
                (jsonData) in
                success(TLUnspentOutputsObject(jsonData as! NSDictionary, blockExplorerJSONType: STATIC_MEMBERS.blockExplorerAPI))
            }, failure:failure)
        } else {
            self.insightAPI!.getUnspentOutputs(addressArray, success: {
                (jsonData) in
                success(TLUnspentOutputsObject(jsonData as! NSDictionary, blockExplorerJSONType: STATIC_MEMBERS.blockExplorerAPI))
            }, failure:failure)
        }
    }
    
    func getUnspentOutputsSynchronous(_ addressArray:NSArray) throws -> TLUnspentOutputsObject {
        if (STATIC_MEMBERS.blockExplorerAPI == .blockchain) {
            return try self.blockchainAPI!.getUnspentOutputsSynchronous(addressArray)
        } else {
            return TLUnspentOutputsObject(try self.insightAPI!.getUnspentOutputsSynchronous(addressArray), blockExplorerJSONType: STATIC_MEMBERS.blockExplorerAPI)

//            let jsonData = self.insightAPI!.getUnspentOutputsSynchronous(addressArray)
//            if jsonData is NSDictionary { // if don't get dict http error, will get array
//                return jsonData as! NSDictionary
//            }
//            let transansformedJsonData = TLInsightAPI.insightUnspentOutputsToBlockchainUnspentOutputs(jsonData as! NSArray)

        }
    }
    
//    func getAddressDataSynchronous(_ address:String) throws -> NSDictionary {
//        if (STATIC_MEMBERS.blockExplorerAPI == .blockchain) {
//            return try self.blockchainAPI!.getAddressDataSynchronous(address)
//        } else {
//            return try self.insightAPI!.getAddressDataSynchronous(address)
//        }
//    }
//    
//    func getAddressData(_ address:String, success:@escaping TLNetworking.SuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> () {
//        if (STATIC_MEMBERS.blockExplorerAPI == .blockchain) {
//            self.blockchainAPI!.getAddressData(address, success:success, failure:failure)
//        } else {
//            self.insightAPI!.getAddressData(address, success: success, failure: failure)
//        }
//    }
    
    func getTx(_ txHash:String, success:@escaping TLBlockExplorerAPI.TxObjectSuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> () {
        if (STATIC_MEMBERS.blockExplorerAPI == .blockchain) {
            self.blockchainAPI!.getTx(txHash, success: {
                (jsonData) in
                success(TLTxObject(jsonData as! NSDictionary))
            }, failure:failure)
        } else {
            self.insightAPI!.getTx(txHash, success:{(jsonData:AnyObject!) in
                let transformedTx = TLInsightAPI.insightTxToBlockchainTx(jsonData as! NSDictionary)
                success(TLTxObject(transformedTx as! NSDictionary))
                }, failure:{(code, status) in
                    failure(code, status)
            })
        }
    }
    
    func getTxBackground(_ txHash:String, success:@escaping TLBlockExplorerAPI.TxObjectSuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> () {
        if (STATIC_MEMBERS.blockExplorerAPI == .blockchain) {
            self.blockchainAPI!.getTxBackground(txHash, success: {
                (jsonData) in
                success(TLTxObject(jsonData as! NSDictionary))
            }, failure:failure)
        } else {
            self.insightAPI!.getTxBackground(txHash, success:{(jsonData:AnyObject!) in
                let transformedTx = TLInsightAPI.insightTxToBlockchainTx(jsonData as! NSDictionary)
                success(TLTxObject(transformedTx!))
            }, failure:{(code, status) in
                failure(code, status)
            })
        }
    }
    
    func pushTx(_ txHex:String, txHash:String, success:@escaping TLNetworking.SuccessHandler, failure:@escaping TLNetworking.FailureHandler)-> () {
        if (STATIC_MEMBERS.blockExplorerAPI == .blockchain) {
            self.blockchainAPI!.pushTx(txHex, txHash:txHash, success:success, failure:failure)
        } else {
            self.insightAPI!.pushTx(txHex, success:success, failure:failure)
        }
    }
    
    func openWebViewForAddress(_ address:String) -> () {
        if (STATIC_MEMBERS.blockExplorerAPI == .blockchain) {
            let endPoint = "address/"
            let url = String(format: "%@%@%@", STATIC_MEMBERS.BLOCKEXPLORER_BASE_URL!, endPoint, address)
            UIApplication.shared.openURL(URL(string: url)!)
        } else {
            let endPoint = "address/"
            let url = String(format: "%@%@%@",STATIC_MEMBERS.BLOCKEXPLORER_BASE_URL!, endPoint, address)
            UIApplication.shared.openURL(URL(string:url)!)
        }
    }
    
    func openWebViewForTransaction(_ txid:String) -> () {
        if (STATIC_MEMBERS.blockExplorerAPI == .blockchain) {
            let endPoint = "tx/"
            let url = String(format: "%@%@%@",STATIC_MEMBERS.BLOCKEXPLORER_BASE_URL!, endPoint, txid)
            UIApplication.shared.openURL(URL(string: url)!)
        } else {
            let endPoint = "tx/"
            let url = String(format: "%@%@%@",STATIC_MEMBERS.BLOCKEXPLORER_BASE_URL!, endPoint, txid)
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
}
