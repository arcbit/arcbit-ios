//
//  TLPushTxAPI.swift
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

class TLPushTxAPI {
    
    struct STATIC_MEMBERS {
        static var _instance:TLPushTxAPI? = nil
    }
    
    class func instance() -> (TLPushTxAPI) {
        if(STATIC_MEMBERS._instance == nil) {
            STATIC_MEMBERS._instance = TLPushTxAPI()
        }
        
        return STATIC_MEMBERS._instance!
    }
    
    func sendTx(_ txHex:String, txHash:String, toAddress:String, success:@escaping TLNetworking.SuccessHandler, failure:@escaping TLNetworking.FailureHandler)-> () {
        DLog("TLPushTxAPI pushTx txHex %@ ", function: txHex)
        DLog("TLPushTxAPI pushTx txHash %@ ", function: txHash)
        DLog("TLPushTxAPI pushTx toAddress %@ ", function: toAddress)

        if TLStealthAddress.isStealthAddress(toAddress, isTestnet:false) == false {
            DLog("TLPushTxAPI TLBlockExplorerAPI")
            TLBlockExplorerAPI.instance().pushTx(txHex, txHash: txHash, success:success, failure:failure)
        } else {
            var pushTxMethod = TLBlockExplorerAPI.instance().insightAPI!.pushTx
            //pushTxMethod = TLBlockrAPI().pushTx

            pushTxMethod(txHex, { (jsonData: AnyObject!) -> () in
                DLog("TLPushTxAPI pushTxMethod %@", function: jsonData)

                func getTxidFromInsightPushTx(_ jsonData:NSDictionary) -> String {
                    return jsonData.object(forKey: "txid") as! String
                }
                
                func getTxidFromBlockrPushTx(_ jsonData:NSDictionary) -> String? {
                    if jsonData.object(forKey: "status") as! String != "success" {
                        let code = jsonData.object(forKey: "code") as! Int
                        let message = jsonData.object(forKey: "message") as! String
                        failure(code, message)
                        return nil
                    }
                    return jsonData.object(forKey: "data") as? String
                }
                
                let txid = getTxidFromInsightPushTx(jsonData as! NSDictionary)
                //let txid = getTxidFromBlockrPushTx(jsonData as! NSDictionary)
                //if txid == nil { return }
                
                TLStealthExplorerAPI.instance().lookupTx(toAddress, txid: txid, success: { (jsonData: AnyObject!) -> () in
                    DLog("TLPushTxAPI TLStealthExplorerAPI success %@", function: jsonData.description)
                    if let errorCode = (jsonData as! NSDictionary).object(forKey: TLStealthExplorerAPI.STATIC_MEMBERS.SERVER_ERROR_CODE) as? Int {
                        let errorMsg = (jsonData as! NSDictionary).object(forKey: TLStealthExplorerAPI.STATIC_MEMBERS.SERVER_ERROR_MSG) as! String
                        DLog(String(format: "TLPushTxAPI TLStealthExplorerAPI success failure %ld %@", errorCode, errorMsg))
                        if errorCode == TLStealthExplorerAPI.STATIC_MEMBERS.SEND_TX_ERROR {
                            DLog("TLPushTxAPI TLStealthExplorerAPI SEND_TX_ERROR %@", function: errorMsg)
                        }
                        failure(errorCode, errorMsg)
                    } else {
                        DLog("TLPushTxAPI TLStealthExplorerAPI success success")
                        success(["txid":txid])
                    }
                    
                    }) { (code: Int, status: String!) -> () in
                        DLog("TLPushTxAPI TLStealthExplorerAPI failure")
                        DLog("TLPushTxAPI TLStealthExplorerAPI failure code: \(code)")
                        DLog("TLPushTxAPI TLStealthExplorerAPI failure status: \(status)")
                        if status != nil {
                            failure(code, "No status")
                        } else {
                            failure(code, status)
                        }
                }
            }) { (code: Int, status: String!) -> () in
                    failure(code, status)
            }
        }
    }
}
