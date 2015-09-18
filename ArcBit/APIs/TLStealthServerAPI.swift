//
//  TLStealthServerAPI.swift
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

class TLStealthExplorerAPI {
    
    struct STATIC_MEMBERS {
        static let UNEXPECTED_ERROR = -1000
        static let DATABASE_ERROR = -1001
        static let INVALID_STEALTH_ADDRESS_ERROR = -1002
        static let INVALID_SIGNATURE_ERROR = -1003
        static let INVALID_SCAN_KEY_ERROR = -1004
        static let TX_DECODE_FAILED_ERROR = -1005
        static let INVALID_PARAMETER_ERROR = -1006
        static let SEND_TX_ERROR = -1007

        static let SERVER_ERROR_CODE = "error_code"
        static let SERVER_ERROR_MSG = "error_msg"
        
        static var instance:TLStealthExplorerAPI? = nil
    }
    
    var networking:TLNetworking
    var baseURL:String
    class func instance() -> (TLStealthExplorerAPI) {
        if(STATIC_MEMBERS.instance == nil) {
            TLPreferences.resetStealthExplorerAPIURL()
            TLPreferences.resetStealthServerPort()
            let baseURL = TLStealthServerConfig.instance().getWebServerProtocol()+"://"+TLPreferences.getStealthExplorerURL()!+":"+String(TLPreferences.getStealthServerPort()!)
            STATIC_MEMBERS.instance = TLStealthExplorerAPI(baseURL: baseURL)
        }
        return STATIC_MEMBERS.instance!
    }
    
    init(baseURL: String) {
        let certificateData = TLStealthServerConfig.instance().getSSLCertificate()
        self.networking = TLNetworking(certificateData: certificateData)
        self.baseURL = baseURL
    }
    
    func ping(success: TLNetworking.SuccessHandler, failure:TLNetworking.FailureHandler) -> () {
        let
        endPoint = "ping"
        let parameters = [:]
        let url = NSURL(string:endPoint, relativeToURL:NSURL(string:self.baseURL))

        self.networking.httpGET(url!, parameters:parameters,
            success:success, failure:failure)
    }

    func getChallenge() -> NSDictionary {
        let endPoint = "challenge"
        let parameters = [:]
        let url = NSURL(string:endPoint, relativeToURL:NSURL(string:self.baseURL))
        let jsonDict = self.networking.httpGETSynchronous(url!, parameters: parameters) as! NSDictionary
        return jsonDict
    }
    
    func getStealthPaymentsSynchronous(stealthAddress:String, signature:String, offset:Int) -> NSDictionary {
        let endPoint = "payments"
        let parameters = [
            "addr": stealthAddress,
            "sig":signature,
            "offset":offset
        ]
        let url = NSURL(string:endPoint, relativeToURL:NSURL(string:self.baseURL))
        let jsonDict = self.networking.httpGETSynchronous(url!, parameters: parameters) as! NSDictionary
        return jsonDict
    }
    
    func watchStealthAddressSynchronous(stealthAddress:String, scanPriv:String, signature:String) -> NSDictionary {
        let endPoint = "watch"
        let parameters = [
            "addr": stealthAddress,
            "scan_key":scanPriv,
            "sig":signature
        ]
        let url = NSURL(string:endPoint, relativeToURL:NSURL(string:self.baseURL))
        let jsonDict = self.networking.httpGETSynchronous(url!, parameters: parameters) as! NSDictionary
        return jsonDict
    }
    
    func lookupTx(stealthAddress:String, txid:String, success:TLNetworking.SuccessHandler, failure:TLNetworking.FailureHandler) -> () {
        let endPoint = "lookuptx"
        let parameters = [
            "addr": stealthAddress,
            "txid":txid,
        ]
        let url = NSURL(string:endPoint, relativeToURL:NSURL(string:self.baseURL))
        
        self.networking.httpGET(url!, parameters:parameters, success:success, failure:failure)
    }
}