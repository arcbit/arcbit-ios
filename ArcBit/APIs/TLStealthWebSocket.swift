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
    private var webSocket: SRWebSocket?
    private var consecutiveFailedConnections = 0
    var challenge = "0"
    private let MAX_CONSECUTIVE_FAILED_CONNECTIONS = 5

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
        let certificateData = TLStealthServerConfig.instance().getSSLCertificate()
        let urlRequest = SRWebSocket.createURLRequest(urlString, withPinnedCert: certificateData)
        
        self.webSocket = SRWebSocket(URLRequest: urlRequest)
        self.webSocket!.delegate = self
        self.webSocket!.open()
    }

    func isWebSocketOpen() -> Bool {
        return self.webSocket != nil && self.webSocket!.readyState.value == SR_OPEN.value
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
    
    func sendMessageSubscribeToStealthAddress(stealthAddress: String, signature: String) -> Bool {
        let msgDict = ["op":"addr_sub", "x":["addr":stealthAddress,"sig":signature]]
        let msg = TLUtils.dictionaryToJSONString(false, dict: msgDict)
        return self.sendMessage(msg)
    }
    
    func sendMessage(msg: String) -> Bool {
        DLog("StealthWebSocket sendMessage: %@", msg)
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
        dispatch_async(dispatch_get_main_queue()) {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector:"sendMessagePing", object:nil)
        NSTimer.scheduledTimerWithTimeInterval(PERIODIC_PING_INTERVAL, target: self,
            selector: Selector("sendMessagePing"), userInfo: nil, repeats: true)
        }
    }
    
    
    func webSocketDidOpen(webSocket: SRWebSocket) -> () {
        DLog("StealthWebSocket webSocketDidOpen")
        consecutiveFailedConnections = 0
        self.sendMessageGetChallenge()
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_STEALTH_PAYMENT_LISTENER_OPEN(), object: nil, userInfo: nil)
        self.periodicPing()
    }
    
    func webSocket(webSocket:SRWebSocket, didFailWithError error:NSError) -> () {
        DLog("StealthWebSocket didFailWithError %@", error.description)

        self.webSocket!.delegate = nil
        self.webSocket!.close()
        self.webSocket = nil
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_STEALTH_PAYMENT_LISTENER_CLOSE(), object: nil)
        if consecutiveFailedConnections++ < MAX_CONSECUTIVE_FAILED_CONNECTIONS {
            self.reconnect()
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                NSObject.cancelPreviousPerformRequestsWithTarget(self, selector:"sendMessagePing", object:nil)
            }
        }
    }
    
    func webSocket(webSocket: SRWebSocket, didReceiveMessage message: AnyObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            var data = message.dataUsingEncoding(NSUTF8StringEncoding)
            
            var error: NSError?
            var jsonDict = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(0), error: &error) as! NSDictionary
            DLog("StealthWebSocket didReceiveMessage \(jsonDict.description)")

            if (jsonDict.objectForKey("op") as! String == "challenge") {
                NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_RECEIVED_STEALTH_CHALLENGE(), object: jsonDict.objectForKey("x"), userInfo: nil)
            } else if (jsonDict.objectForKey("op") as! String == "addr_sub") {
                NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_RECEIVED_STEALTH_ADDRESS_SUBSCRIPTION(), object: jsonDict.objectForKey("x"), userInfo: nil)
            } else if (jsonDict.objectForKey("op") as! String == "tx") {
                NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_RECEIVED_STEALTH_PAYMENT(), object: jsonDict.objectForKey("x"), userInfo: nil)
            }
        }
    }
    
    func webSocket(webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String, wasClean: Bool) -> () {
        if wasClean {
            DLog("StealthWebSocket didCloseWithCode With No Error \(code) \(reason)")
        } else {
            DLog("StealthWebSocket didCloseWithCode With Error \(code) \(reason)")
        }
        
        self.webSocket!.delegate = nil
        self.webSocket!.close()
        self.webSocket = nil
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_STEALTH_PAYMENT_LISTENER_CLOSE(), object: nil)
        if consecutiveFailedConnections++ < MAX_CONSECUTIVE_FAILED_CONNECTIONS {
            self.reconnect()
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                NSObject.cancelPreviousPerformRequestsWithTarget(self, selector:"sendMessagePing", object:nil)
            }
        }
    }
}