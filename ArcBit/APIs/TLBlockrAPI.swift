//
//  TLBlockrAPI.swift
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

class TLBlockrAPI {
    var networking:TLNetworking
    let baseURL:String = "https://btc.blockr.io/"
    
    init() {
        self.networking = TLNetworking()
    }
    
    // https://btc.blockr.io/documentation/api
    /*
    //success response from pushTx
    {
        code = 200
        data = txid
        message = ""
        status = success
    }
    */
    func pushTx(_ txHex: String, success: TLNetworking.SuccessHandler, failure: TLNetworking.FailureHandler) {
        let endPoint = "api/v1/tx/push"
        let parameters = [
            "hex": txHex
        ]
        
        let url = URL(string: endPoint, relativeTo: URL(string: self.baseURL))!
        self.networking.httpPOST(url, parameters: parameters,
            success: success, failure: failure)
    }
}
