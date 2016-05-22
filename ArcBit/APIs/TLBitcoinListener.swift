//
//  TLBitcoinListener.swift
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

@objc class TLTransactionListener: NSObject, SRWebSocketDelegate {
    let MAX_CONSECUTIVE_FAILED_CONNECTIONS = 5
    let SEND_EMPTY_PACKET_TIME_INTERVAL = 60.0
    private var blockExplorerAPI: TLBlockExplorer?
    private var keepAliveTimer: NSTimer?
//    private var socket: SIOSocket?
    private var socketIsConnected: Bool = false
    private var webSocket: SRWebSocket?
    var consecutiveFailedConnections = 0
    
    struct STATIC_MEMBERS {
        static var instance: TLTransactionListener?
    }
    
    class func instance() -> (TLTransactionListener) {
        if (STATIC_MEMBERS.instance == nil) {
            STATIC_MEMBERS.instance = TLTransactionListener()
        }
        return STATIC_MEMBERS.instance!
    }
    
    override init() {
        super.init()
        blockExplorerAPI = TLPreferences.getBlockExplorerAPI()
    }
    
    func reconnect() -> () {
        if (blockExplorerAPI == TLBlockExplorer.Blockchain) {
            DLog("websocket reconnect blockchain.info")
            if (self.webSocket != nil) {
                self.webSocket!.delegate = nil
                self.webSocket!.close()
            }
            
            self.webSocket = SRWebSocket(URLRequest: NSURLRequest(URL: NSURL(string: "wss://ws.blockchain.info/inv")!))
            
            self.webSocket!.delegate = self
            
            self.webSocket!.open()
        } else {
            DLog("websocket reconnect insight")
            let url = String(format: "%@", TLPreferences.getBlockExplorerURL(TLBlockExplorer.Insight)!)
//            SIOSocket.socketWithHost(url, response: {
//                (socket: SIOSocket!) in
//                self.socket = socket
//                
//                weak var weakSelf = self
//                self.socket!.onConnect = {
//                    () in
//                    DLog("socketio onConnect")
//                    self.consecutiveFailedConnections = 0
//                    weakSelf!.socketIsConnected = true
//                    NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_TRANSACTION_LISTENER_OPEN(), object: nil, userInfo: nil)
//                }
//                
//                self.socket!.onDisconnect = {
//                    () in
//                    DLog("socketio onDisconnect")
//                    NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_TRANSACTION_LISTENER_CLOSE(), object: nil, userInfo: nil)
//                    if self.consecutiveFailedConnections++ < self.MAX_CONSECUTIVE_FAILED_CONNECTIONS {
//                        self.socket?.close()
//                        self.reconnect()
//                    }
//                }
//                
//                self.socket!.onError = {
//                    (data: [NSObject:AnyObject]!) in
//                    DLog("socketio error: %@", function: data)
//                }
//                
//                self.socket!.onReconnectionAttempt = {
//                    (recCounter: Int) in
//                    DLog("socketio Reconnection counter \(recCounter)")
//                }
//                
//                self.socket!.onReconnectionError = {
//                    (data: [NSObject:AnyObject]!) in
//                    DLog("socketio reconnection error: %@", function: data)
//                }
//                
//                self.socket!.on("block", callback: {
//                    (_args: [AnyObject]!) in
//                    let args = _args as NSArray
//                    let data: AnyObject? = args.firstObject
//                    // data!.debugDescription is lastest block hash
//                    // can't use this to update confirmations on transactions because insight tx does not contain blockheight field
//                    DLog("socketio received lastest block hash: %@", function: data!.debugDescription ?? "")
//                })
//            })
        }
    }
    
    func isWebSocketOpen() -> Bool {
        if (blockExplorerAPI == TLBlockExplorer.Blockchain) {
            return self.webSocket != nil && self.webSocket!.readyState.rawValue == SR_OPEN.rawValue
        } else {
            return self.socketIsConnected
        }
    }
    
    private func sendWebSocketMessage(msg: String) -> Bool {
        DLog("sendWebSocketMessage msg: %@", function: msg)
        if self.isWebSocketOpen() {
            self.webSocket!.send(msg)
            return true
        } else {
            DLog("Websocket Error: not connect to websocket server")
            return false
        }
    }
    
    func listenToIncomingTransactionForAddress(address: String) -> Bool {
        //DLog("listen address: %@", address)
        if (blockExplorerAPI == TLBlockExplorer.Blockchain) {
            if self.isWebSocketOpen() {
                let msg = String(format: "{\"op\":\"addr_sub\", \"addr\":\"%@\"}", address)
                self.sendWebSocketMessage(msg)
                return true
            } else {
                DLog("Websocket Error: not connect to websocket server")
                return false
            }
        } else {
            if (self.socketIsConnected) {
//                if self.socket == nil {
//                    return false
//                }
//                self.socket!.emit("subscribe", args: [address])
//                
//                self.socket!.on(address, callback: {
//                    (_args: [AnyObject]!) in
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
//
//                        let args = _args as NSArray
//                        let data: AnyObject? = args.firstObject
//                        
//                        let txHash = data!.debugDescription ?? ""
//                        DLog("socketio on address: %@", function: address)
//                        DLog("socketio transaction: %@", function: txHash)
//                        
//                        //TODO: temp solution, ask Insight devs to get all tx data in websockets API
//                        TLBlockExplorerAPI.instance().getTx(txHash, success: {
//                            (txDict: AnyObject?) in
//                            if txDict != nil {
//                                NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_NEW_UNCONFIRMED_TRANSACTION(), object: txDict!, userInfo: nil)
//                            }
//                            }, failure: {
//                                (code: NSInteger, status: String!) in
//                        })
//                    }
//                })
                return true
                
            } else {
                return false
            }
        }
    }
    
    func close() -> () {
        if (blockExplorerAPI == TLBlockExplorer.Blockchain) {
            DLog("closing blockchain.info websocket")
            self.webSocket!.close()
        } else {
            DLog("closing socketio")
//            self.socket!.close()
        }
    }
    
    private func keepAlive() -> () {
        if (keepAliveTimer != nil) {
            keepAliveTimer!.invalidate()
        }
        keepAliveTimer = nil
        keepAliveTimer = NSTimer.scheduledTimerWithTimeInterval(SEND_EMPTY_PACKET_TIME_INTERVAL,
            target: self,
            selector: "sendEmptyPacket",
            userInfo: nil,
            repeats: true)
    }
    
    func sendEmptyPacket() -> () {
        DLog("blockchain.info Websocket sendEmptyPacket")
        if self.isWebSocketOpen() {
            self.sendWebSocketMessage("")
        }
    }
 
    func webSocketDidOpen(webSocket: SRWebSocket) -> () {
        DLog("blockchain.info webSocketDidOpen")
        consecutiveFailedConnections = 0
        self.sendWebSocketMessage("{\"op\":\"blocks_sub\"}")

        self.keepAlive()
        
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_TRANSACTION_LISTENER_OPEN(), object: nil, userInfo: nil)
    }
    
    func webSocket(webSocket:SRWebSocket, didFailWithError error:NSError) -> () {
        DLog("blockchain.info Websocket didFailWithError %@", function: error.description)
        
        self.webSocket!.delegate = nil
        self.webSocket!.close()
        self.webSocket = nil
        if consecutiveFailedConnections++ < MAX_CONSECUTIVE_FAILED_CONNECTIONS {
            self.reconnect()
        }
    }
    
    func webSocket(webSocket: SRWebSocket, didReceiveMessage message: AnyObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            let data = message.dataUsingEncoding(NSUTF8StringEncoding)
            
            let jsonDict = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))) as! NSDictionary
            DLog("blockchain.info didReceiveMessage \(jsonDict.description)")

            if (jsonDict.objectForKey("op") as! String == "utx") {
                NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_NEW_UNCONFIRMED_TRANSACTION(), object: jsonDict.objectForKey("x"), userInfo: nil)
            } else if (jsonDict.objectForKey("op") as! String == "block") {
                NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_NEW_BLOCK(), object: jsonDict.objectForKey("x"), userInfo: nil)
            }
        }
    }
    
    func webSocket(webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String, wasClean: Bool) -> () {
        if wasClean {
            DLog("blockchain.info Websocket didCloseWithCode With No Error \(code) \(reason)")
        } else {
            DLog("blockchain.info Websocket didCloseWithCode With Error \(code) \(reason)")
        }
        
        self.webSocket!.delegate = nil
        self.webSocket!.close()
        self.webSocket = nil
        if consecutiveFailedConnections++ < MAX_CONSECUTIVE_FAILED_CONNECTIONS {
            self.reconnect()
        }
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_TRANSACTION_LISTENER_CLOSE(), object: nil, userInfo: nil)
    }
}
