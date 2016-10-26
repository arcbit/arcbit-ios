//
//  TLStealthWebSocket.swift
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


@objc class TLStealthWebSocket: NSObject, SRWebSocketDelegate {
    fileprivate var webSocket: SRWebSocket?
    fileprivate var consecutiveFailedConnections = 0
    var challenge = "0"
    fileprivate let MAX_CONSECUTIVE_FAILED_CONNECTIONS = 5

    struct STATIC_MEMBERS {
        static var instance: TLStealthWebSocket?
    }
    
    class func instance() -> (TLStealthWebSocket) {
        if (STATIC_MEMBERS.instance == nil) {
            STATIC_MEMBERS.instance = TLStealthWebSocket()
            TLPreferences.resetStealthExplorerAPIURL()
            TLPreferences.resetStealthWebSocketPort()
        }
        return STATIC_MEMBERS.instance!
    }
    
    func reconnect() -> () {
        if (self.webSocket != nil) {
            self.webSocket!.delegate = nil
            self.webSocket!.close()
        }
        
        let urlString = String(format: "%@://%@:%d%@", TLStealthServerConfig.instance().getWebSocketProtocol(), TLPreferences.getStealthExplorerURL()!, TLPreferences.getStealthWebSocketPort()!, TLStealthServerConfig.instance().getWebSocketEndpoint())
        DLog("StealthWebSocket reconnect url: \(urlString)")
        
        //let certificateData = TLStealthServerConfig.instance().getSSLCertificate()
        //let urlRequest = SRWebSocket.createURLRequest(urlString, withPinnedCert: certificateData)
        //self.webSocket = SRWebSocket(URLRequest: urlRequest)
        self.webSocket = SRWebSocket(urlRequest: URLRequest(url: URL(string: urlString)!))
        
        self.webSocket!.delegate = self
        self.webSocket!.open()
    }

    func isWebSocketOpen() -> Bool {
        return self.webSocket != nil && self.webSocket!.readyState.rawValue == SR_OPEN.rawValue
    }
    
    func close() -> () {
        self.webSocket!.close()
    }

    func sendMessagePing() -> Bool {
        let msg = TLUtils.dictionaryToJSONString(false, dict: ["op":"ping"])
        return self.sendMessage(msg)
    }
    func sendMessageGetChallenge() -> Bool {
        let msg = TLUtils.dictionaryToJSONString(false, dict: ["op":"challenge"])
        return self.sendMessage(msg)
    }
    
    func sendMessageSubscribeToStealthAddress(_ stealthAddress: String, signature: String) -> Bool {
        let msgDict = ["op":"addr_sub", "x":["addr":stealthAddress,"sig":signature]] as [String : Any]
        let msg = TLUtils.dictionaryToJSONString(false, dict: msgDict as NSDictionary)
        return self.sendMessage(msg)
    }
    
    func sendMessage(_ msg: String) -> Bool {
        DLog("StealthWebSocket sendMessage: \(msg)")
        if self.isWebSocketOpen() {
            self.webSocket!.send(msg)
            return true
        } else {
            DLog("StealthWebSocket Error: not connect to websocket server")
            return false
        }
    }
    
    func periodicPing() {
        let PERIODIC_PING_INTERVAL = 55.0
        DispatchQueue.main.async {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector:#selector(TLStealthWebSocket.sendMessagePing), object:nil)
        Timer.scheduledTimer(timeInterval: PERIODIC_PING_INTERVAL, target: self,
            selector: #selector(TLStealthWebSocket.sendMessagePing), userInfo: nil, repeats: true)
        }
    }
    
    
    func webSocketDidOpen(_ webSocket: SRWebSocket) -> () {
        DLog("StealthWebSocket webSocketDidOpen")
        self.sendMessageGetChallenge()
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_STEALTH_PAYMENT_LISTENER_OPEN()), object: nil, userInfo: nil)
        self.periodicPing()
    }
    
    func webSocket(_ webSocket:SRWebSocket, didFailWithError error:NSError) -> () {
        DLog("StealthWebSocket didFailWithError \(error.description)")

        self.webSocket!.delegate = nil
        self.webSocket!.close()
        self.webSocket = nil
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_STEALTH_PAYMENT_LISTENER_CLOSE()), object: nil)
        if consecutiveFailedConnections < MAX_CONSECUTIVE_FAILED_CONNECTIONS {
            self.reconnect()
        } else {
            DispatchQueue.main.async {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector:#selector(TLStealthWebSocket.sendMessagePing), object:nil)
            }
        }
        consecutiveFailedConnections += 1
    }
    
    func webSocket(_ webSocket: SRWebSocket, didReceiveMessage message: AnyObject) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
            self.consecutiveFailedConnections = 0
            let data = message.data(using: String.Encoding.utf8)

            let jsonDict = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0))) as! NSDictionary
            DLog("StealthWebSocket didReceiveMessage \(jsonDict.description)")

            if (jsonDict.object(forKey: "op") as! String == "challenge") {
                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_RECEIVED_STEALTH_CHALLENGE()), object: jsonDict.object(forKey: "x"), userInfo: nil)
            } else if (jsonDict.object(forKey: "op") as! String == "addr_sub") {
                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_RECEIVED_STEALTH_ADDRESS_SUBSCRIPTION()), object: jsonDict.object(forKey: "x"), userInfo: nil)
            } else if (jsonDict.object(forKey: "op") as! String == "tx") {
                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_RECEIVED_STEALTH_PAYMENT()), object: jsonDict.object(forKey: "x"), userInfo: nil)
            }
        }
    }
    
    func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String, wasClean: Bool) -> () {
        if wasClean {
            DLog("StealthWebSocket didCloseWithCode With No Error \(code) \(reason)")
        } else {
            DLog("StealthWebSocket didCloseWithCode With Error \(code) \(reason)")
        }
        
        self.webSocket!.delegate = nil
        self.webSocket!.close()
        self.webSocket = nil
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_STEALTH_PAYMENT_LISTENER_CLOSE()), object: nil)
        if consecutiveFailedConnections < MAX_CONSECUTIVE_FAILED_CONNECTIONS {
            self.reconnect()
        } else {
            DispatchQueue.main.async {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector:#selector(TLStealthWebSocket.sendMessagePing), object:nil)
            }
        }
        consecutiveFailedConnections += 1
    }
}
