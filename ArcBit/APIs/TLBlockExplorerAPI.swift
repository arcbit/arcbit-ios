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
    case Blockchain  = 0
    case Insight     = 1
    case Toshi     = 2
    case Blockr     = 3
}

class TLBlockExplorerAPI {
    
    struct STATIC_MEMBERS {
        static var blockExplorerAPI:TLBlockExplorer = .Blockchain
        static var BLOCKEXPLORER_BASE_URL:String? = "https://blockchain.info/"
        static var _instance:TLBlockExplorerAPI? = nil
    }
    
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
        if (STATIC_MEMBERS.blockExplorerAPI == .Blockchain) {
            self.blockchainAPI = TLBlockchainAPI(baseURL: STATIC_MEMBERS.BLOCKEXPLORER_BASE_URL!)
            //needed for push tx api for stealth addresses
            self.insightAPI = TLInsightAPI(baseURL: "https://insight.bitpay.com/")
        } else if (STATIC_MEMBERS.blockExplorerAPI == .Insight) {
            self.insightAPI = TLInsightAPI(baseURL: STATIC_MEMBERS.BLOCKEXPLORER_BASE_URL!)
        }
    }
    
    
    func getBlockHeight(success: TLNetworking.SuccessHandler, failure:TLNetworking.FailureHandler) -> (){
        if (STATIC_MEMBERS.blockExplorerAPI == .Blockchain) {
            self.blockchainAPI!.getBlockHeight({(height:AnyObject!) in
                let blockHeight = ["height": NSNumber(longLong: (height as! NSString).longLongValue)]
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
    
    func getAddressesInfoSynchronous(addressArray:Array<String>) -> NSDictionary {
        if (STATIC_MEMBERS.blockExplorerAPI == .Blockchain) {
            return self.blockchainAPI!.getAddressesInfoSynchronous(addressArray)
        } else {
            return self.insightAPI!.getAddressesInfoSynchronous(addressArray)
        }
    }
    
    func getAddressesInfo(addressArray:Array<String>, success:TLNetworking.SuccessHandler, failure:TLNetworking.FailureHandler)-> () {
        if (STATIC_MEMBERS.blockExplorerAPI == .Blockchain) {
            self.blockchainAPI!.getAddressesInfo(addressArray, success:success, failure:failure)
        } else {
            self.insightAPI!.getAddressesInfo(addressArray, success:success, failure:failure)
        }
    }
    
    func getUnspentOutputs(addressArray:Array<String>, success:TLNetworking.SuccessHandler, failure:TLNetworking.FailureHandler) -> () {
        if (STATIC_MEMBERS.blockExplorerAPI == .Blockchain) {
            self.blockchainAPI!.getUnspentOutputs(addressArray, success:success, failure:failure)
        } else {
            self.insightAPI!.getUnspentOutputs(addressArray, success:success, failure:failure)
        }
    }
    
    func getUnspentOutputsSynchronous(addressArray:NSArray) -> NSDictionary {
        if (STATIC_MEMBERS.blockExplorerAPI == .Blockchain) {
            return self.blockchainAPI!.getUnspentOutputsSynchronous(addressArray)
        } else {
            return self.insightAPI!.getUnspentOutputsSynchronous(addressArray)
        }
    }
    
    func getAddressDataSynchronous(address:String) -> NSDictionary {
        if (STATIC_MEMBERS.blockExplorerAPI == .Blockchain) {
            return self.blockchainAPI!.getAddressDataSynchronous(address)
        } else {
            return self.insightAPI!.getAddressDataSynchronous(address)               
        }
    }
    
    func getAddressData(address:String, success:TLNetworking.SuccessHandler, failure:TLNetworking.FailureHandler) -> () {
        if (STATIC_MEMBERS.blockExplorerAPI == .Blockchain) {
            self.blockchainAPI!.getAddressData(address, success:success, failure:failure)
        } else {
            self.insightAPI!.getAddressData(address, success: success, failure: failure)
        }
    }
    
    func getTx(txHash:String, success:TLNetworking.SuccessHandler, failure:TLNetworking.FailureHandler) -> () {
        if (STATIC_MEMBERS.blockExplorerAPI == .Blockchain) {
            self.blockchainAPI!.getTx(txHash, success:success, failure:failure)
        } else {
            self.insightAPI!.getTx(txHash, success:{(jsonData:AnyObject!) in
                let transformedTx = TLInsightAPI.insightTxToBlockchainTx(jsonData as! NSDictionary)
                success(transformedTx)
                }, failure:{(code:NSInteger, status:String!) in
                    failure(code, status)
            })
        }
    }
    
    func getTxBackground(txHash:String, success:TLNetworking.SuccessHandler, failure:TLNetworking.FailureHandler) -> () {
        if (STATIC_MEMBERS.blockExplorerAPI == .Blockchain) {
            self.blockchainAPI!.getTxBackground(txHash, success:success, failure:failure)
        } else {
            self.insightAPI!.getTxBackground(txHash, success:{(jsonData:AnyObject!) in
                let transformedTx = TLInsightAPI.insightTxToBlockchainTx(jsonData as! NSDictionary)
                success(transformedTx)
                }, failure:{(code:NSInteger, status:String!) in
                    failure(code, status)
            })
        }
    }
    
    func pushTx(txHex:String, txHash:String, success:TLNetworking.SuccessHandler, failure:TLNetworking.FailureHandler)-> () {
        if (STATIC_MEMBERS.blockExplorerAPI == .Blockchain) {
            self.blockchainAPI!.pushTx(txHex, txHash:txHash, success:success, failure:failure)
        } else {
            self.insightAPI!.pushTx(txHex, success:success, failure:failure)
        }
    }
    
    func openWebViewForAddress(address:String) -> () {
        if (STATIC_MEMBERS.blockExplorerAPI == .Blockchain) {
            let endPoint = "address/"
            let url = String(format: "%@%@%@", STATIC_MEMBERS.BLOCKEXPLORER_BASE_URL!, endPoint, address)
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        } else {
            let endPoint = "address/"
            let url = String(format: "%@%@%@",STATIC_MEMBERS.BLOCKEXPLORER_BASE_URL!, endPoint, address)
            UIApplication.sharedApplication().openURL(NSURL(string:url)!)
        }
    }
    
    func openWebViewForTransaction(txid:String) -> () {
        if (STATIC_MEMBERS.blockExplorerAPI == .Blockchain) {
            let endPoint = "tx/"
            let url = String(format: "%@%@%@",STATIC_MEMBERS.BLOCKEXPLORER_BASE_URL!, endPoint, txid)
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        } else {
            let endPoint = "tx/"
            let url = String(format: "%@%@%@",STATIC_MEMBERS.BLOCKEXPLORER_BASE_URL!, endPoint, txid)
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
}