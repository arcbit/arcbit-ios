//
//  TLBlockchainAPI.swift
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
class TLBlockchainAPI {
    
    struct STATIC_MEMBERS {
        static let BLOCKCHAIN_ENDPOINT_ADDRESS = "address/"
        static let BLOCKCHAIN_ENDPOINT_TX = "tx/"
        static let BC_REQ_FORMAT  = "format"
        static let BC_REQ_ACTIVE  = "active"
    }
    
    var networking:TLNetworking
    var baseURL:String
    
    init(baseURL: String) {
        self.networking = TLNetworking()
        self.baseURL = baseURL
    }
    
    func getBlockHeight(_ success: @escaping TLNetworking.SuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> (){
        let endPoint = "q/getblockcount"
        let url = URL(string: endPoint, relativeTo:URL(string:self.baseURL))
        
        self.networking.httpGET(url!, parameters:nil,
            success: {(jsonData:AnyObject!) in
                success(jsonData!)
            }, failure:{(code, status) in
                if (code == 200) {
                    success(status as AnyObject!)
                } else {
                    failure(code, status)
                }
        })
    }
    
//    func getAddressData(_ address:String, success:@escaping TLNetworking.SuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> () {
//        let endPoint = String(format:"%@%@", STATIC_MEMBERS.BLOCKCHAIN_ENDPOINT_ADDRESS, address)
//        let parameters = [
//            STATIC_MEMBERS.BC_REQ_FORMAT: "json"
//        ]
//        let url = URL(string:endPoint, relativeTo:URL(string:self.baseURL))
//        self.networking.httpGET(url!, parameters:parameters as NSDictionary,
//            success:success, failure:failure)
//    }
//
//    func getAddressDataSynchronous(_ address:String) throws -> NSDictionary {
//        let endPoint = String(format:"%@%@", STATIC_MEMBERS.BLOCKCHAIN_ENDPOINT_ADDRESS, address)
//        let parameters = [
//            STATIC_MEMBERS.BC_REQ_FORMAT: "json"
//        ]
//        let url = URL(string:endPoint, relativeTo:URL(string:self.baseURL))
//        return try self.networking.httpGETSynchronous(url!, parameters:parameters as NSDictionary) as! NSDictionary
//    }
    
    func getTx(_ txHash:String, success:@escaping TLNetworking.SuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> () {
        let endPoint = String(format:"%@%@", STATIC_MEMBERS.BLOCKCHAIN_ENDPOINT_TX, txHash)
        let parameters = [
            STATIC_MEMBERS.BC_REQ_FORMAT: "json"
        ]
        
        let url = URL(string:endPoint, relativeTo:URL(string:self.baseURL))
        self.networking.httpGET(url!, parameters:parameters as NSDictionary,
            success:success, failure:failure)
    }
    
    func getTxBackground(_ txHash:String, success:@escaping TLNetworking.SuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> () {
        let endPoint = String(format:"%@%@", STATIC_MEMBERS.BLOCKCHAIN_ENDPOINT_TX, txHash)
        let parameters = [
            STATIC_MEMBERS.BC_REQ_FORMAT: "json"
        ]
        
        let url = URL(string:endPoint, relativeTo:URL(string:self.baseURL))
        self.networking.httpGETBackground(url!, parameters:parameters as NSDictionary,
            success:success, failure:failure)
    }
    
    func pushTx(_ txHex:String, txHash:String, success:@escaping TLNetworking.SuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> () {
        let endPoint = "pushtx"
        let parameters = [
            STATIC_MEMBERS.BC_REQ_FORMAT: "plain",
            "tx":txHex
        ]
        
        let url = URL(string:endPoint, relativeTo:URL(string:self.baseURL))
        self.networking.httpPOST(url!, parameters:parameters as NSDictionary,
            success:success, failure:failure)
    }
    
    func getUnspentOutputsSynchronous(_ addressArray:NSArray) throws -> NSDictionary {
        let endPoint = "unspent"
        let parameters = [
            STATIC_MEMBERS.BC_REQ_ACTIVE:addressArray.componentsJoined(by: "|")
        ]
        let url = URL(string:endPoint, relativeTo:URL(string:self.baseURL))
        return try self.networking.httpGETSynchronous(url!, parameters:parameters as NSDictionary) as! NSDictionary
    }
    
    func getUnspentOutputs(_ addressArray:Array<String>, success:@escaping TLNetworking.SuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> () {
        let endPoint = "unspent"
        let parameters = [
            STATIC_MEMBERS.BC_REQ_ACTIVE:addressArray.joined(separator: "|")
        ]
        let url = URL(string:endPoint, relativeTo:URL(string:self.baseURL))
        self.networking.httpGET(url!, parameters:parameters as NSDictionary,
            success:success, failure:failure)
    }
    
    func getAddressesInfoSynchronous(_ addressArray:Array<String>) throws -> NSDictionary {
        let endPoint = "multiaddr"
        let parameters = [
            STATIC_MEMBERS.BC_REQ_ACTIVE:addressArray.joined(separator: "|"),
            "no_buttons":"true"]
        let url = URL(string:endPoint, relativeTo:URL(string:self.baseURL))
        return try self.networking.httpGETSynchronous(url!, parameters:parameters as NSDictionary) as! NSDictionary
    }
    
    func getAddressesInfo(_ addressArray:Array<String>, success:@escaping TLNetworking.SuccessHandler, failure:@escaping TLNetworking.FailureHandler) -> () {
        let endPoint = "multiaddr"
        let parameters = [
            STATIC_MEMBERS.BC_REQ_ACTIVE:addressArray.joined(separator: "|"),
            "no_buttons":"true"]
        let url = URL(string:endPoint, relativeTo:URL(string:self.baseURL))
        self.networking.httpGET(url!, parameters:parameters as NSDictionary,
            success:success, failure:failure)
    }
}
