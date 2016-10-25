//
//  TLStealthServerConfig.swift
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

class TLStealthServerConfig {
    struct STATIC_MEMBERS {
        static var instance:TLStealthServerConfig?
    }
    
    fileprivate var stealthServerUrl = "www.arcbit.net"
    fileprivate var stealthServerPort = 443
    fileprivate var webSocketServerPort = 443
    fileprivate var webServerProtocol = "https"
    fileprivate var webSocketProtocol = "wss"
    fileprivate var webSocketEndpoint = "/inv"

    class func instance() -> (TLStealthServerConfig) {
        if(STATIC_MEMBERS.instance == nil) {
            STATIC_MEMBERS.instance = TLStealthServerConfig()
        }
        return STATIC_MEMBERS.instance!
    }
    
    func getSSLCertificate() -> Data {
        let certificatePath = Bundle.main.path(forResource: "live", ofType: "cer")!
        let certificateData = try! Data(contentsOf: URL(fileURLWithPath: certificatePath))
        return certificateData
    }
    
    func getWebServerProtocol() -> String {
        return self.webServerProtocol
    }

    func getWebSocketProtocol() -> String {
        return self.webSocketProtocol
    }
    
    func getWebSocketEndpoint() -> String {
        return self.webSocketEndpoint
    }
    
    func getStealthServerUrl() -> String {
        return self.stealthServerUrl
    }

    func getStealthServerPort() -> Int {
        return self.stealthServerPort
    }
    
    func getWebSocketServerPort() -> Int {
        return self.webSocketServerPort
    }
}
