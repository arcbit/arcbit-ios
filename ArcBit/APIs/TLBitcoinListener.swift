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
    fileprivate var blockExplorerAPI: TLBlockExplorer?
    fileprivate var keepAliveTimer: Timer?
    fileprivate var socket: SocketIOClient?
    fileprivate var socketIsConnected: Bool = false
    fileprivate var webSocket: SRWebSocket?
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
        if (blockExplorerAPI == TLBlockExplorer.blockchain) {
            DLog("websocket reconnect blockchain.info")
            if (self.webSocket != nil) {
                self.webSocket!.delegate = nil
                self.webSocket!.close()
            }
            
            self.webSocket = SRWebSocket(urlRequest: URLRequest(url: URL(string: "wss://ws.blockchain.info/inv")!))
            
            self.webSocket!.delegate = self
            
            self.webSocket!.open()
        } else {
            DLog("websocket reconnect insight")
            let url = String(format: "%@", TLPreferences.getBlockExplorerURL(TLBlockExplorer.insight)!)
            self.socket = SocketIOClient(socketURL: URL(string: url)!, config: [.log(true), .forcePolling(true)])
            weak var weakSelf = self

            self.socket!.on("connect") {data, ack in
                DLog("socketio onConnect")
                self.consecutiveFailedConnections = 0
                weakSelf!.socketIsConnected = true
                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_TRANSACTION_LISTENER_OPEN()), object: nil, userInfo: nil)
//                weakSelf!.socket!.emit("subscribe", "inv")
            }
            self.socket!.on("disconnect") {data, ack in
                DLog("socketio onDisconnect")
                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_TRANSACTION_LISTENER_CLOSE()), object: nil, userInfo: nil)
                if self.consecutiveFailedConnections < self.MAX_CONSECUTIVE_FAILED_CONNECTIONS {
                    self.reconnect()
                }
                self.consecutiveFailedConnections += 1
            }
            self.socket!.on("error") {data, ack in
                DLog("socketio error: \(data as AnyObject)")
            }
            self.socket!.on("block") {data, ack in
                let dataArray = data as NSArray
                let firstObject: AnyObject? = dataArray.firstObject as AnyObject?
                // data!.debugDescription is lastest block hash
                // can't use this to update confirmations on transactions because insight tx does not contain blockheight field
                DLog("socketio received lastest block hash: \(firstObject!.debugDescription)")
                
            }
//            socket.on("tx") {data, ack in
//                DLog("socketio__ tx \(data)")
//            }
            self.socket!.connect()
        }
    }
    
    func isWebSocketOpen() -> Bool {
        if (blockExplorerAPI == TLBlockExplorer.blockchain) {
            return self.webSocket != nil && self.webSocket!.readyState.rawValue == SR_OPEN.rawValue
        } else {
            return self.socketIsConnected
        }
    }
    
    fileprivate func sendWebSocketMessage(_ msg: String) -> Bool {
        DLog("sendWebSocketMessage msg: \(msg)")
        if self.isWebSocketOpen() {
            self.webSocket!.send(msg)
            return true
        } else {
            DLog("Websocket Error: not connect to websocket server")
            return false
        }
    }
    
    @discardableResult func listenToIncomingTransactionForAddress(_ address: String) -> Bool {
        //DLog("listen address: %@", address)
        if (blockExplorerAPI == TLBlockExplorer.blockchain) {
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
                if self.socket == nil {
                    return false
                }
                
                //DLog("socketio emit address: \(address)")
                self.socket!.emit("unsubscribe", "bitcoind/addresstxid", [address])
                self.socket!.emit("subscribe", "bitcoind/addresstxid", [address])
                
                self.socket!.on("bitcoind/addresstxid") {data, ack in
                    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
                        //DLog("socketio on data: \(data)")
                        let dataArray = data as NSArray
                        let dataDictionary = dataArray.firstObject as! NSDictionary
                        let addr = dataDictionary["address"] as! String
                        //bad api design, this on is not address specific, will call for every subscribe address
                        if (addr == address) {
                            let txHash = dataDictionary["txid"] as! String
                            //DLog("socketio on address: \(addr)")
                            //DLog("socketio transaction: \(txHash)")
                            TLBlockExplorerAPI.instance().getTx(txHash, success: {
                                (txDict: AnyObject?) in
                                if txDict != nil {
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_NEW_UNCONFIRMED_TRANSACTION()), object: txDict!, userInfo: nil)
                                }
                                }, failure: {
                                    (code, status) in
                            })
                        }
                    }
                }
                return true
            } else {
                return false
            }
        }
    }
    
    func close() -> () {
        if (blockExplorerAPI == TLBlockExplorer.blockchain) {
            DLog("closing blockchain.info websocket")
            self.webSocket!.close()
        } else {
            DLog("closing socketio")
            self.socket?.disconnect()
        }
    }
    
    fileprivate func keepAlive() -> () {
        if (keepAliveTimer != nil) {
            keepAliveTimer!.invalidate()
        }
        keepAliveTimer = nil
        keepAliveTimer = Timer.scheduledTimer(timeInterval: SEND_EMPTY_PACKET_TIME_INTERVAL,
            target: self,
            selector: #selector(TLTransactionListener.sendEmptyPacket),
            userInfo: nil,
            repeats: true)
    }
    
    func sendEmptyPacket() -> () {
        DLog("blockchain.info Websocket sendEmptyPacket")
        if self.isWebSocketOpen() {
            self.sendWebSocketMessage("")
        }
    }
 
    func webSocketDidOpen(_ webSocket: SRWebSocket) -> () {
        DLog("blockchain.info webSocketDidOpen")
        consecutiveFailedConnections = 0
        self.sendWebSocketMessage("{\"op\":\"blocks_sub\"}")

        self.keepAlive()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_TRANSACTION_LISTENER_OPEN()), object: nil, userInfo: nil)
    }
    
    func webSocket(_ webSocket:SRWebSocket, didFailWithError error:NSError) -> () {
        DLog("blockchain.info Websocket didFailWithError \(error.description)")
        
        self.webSocket!.delegate = nil
        self.webSocket!.close()
        self.webSocket = nil
        if consecutiveFailedConnections < MAX_CONSECUTIVE_FAILED_CONNECTIONS {
            self.reconnect()
        }
        consecutiveFailedConnections += 1
    }
    
    public func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
            let data = (message as AnyObject).data(using: String.Encoding.utf8.rawValue)
            
            let jsonDict = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0))) as! NSDictionary
            DLog("blockchain.info didReceiveMessage \(jsonDict.description)")

            if (jsonDict.object(forKey: "op") as! String == "utx") {
                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_NEW_UNCONFIRMED_TRANSACTION()), object: jsonDict.object(forKey: "x"), userInfo: nil)
            } else if (jsonDict.object(forKey: "op") as! String == "block") {
                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_NEW_BLOCK()), object: jsonDict.object(forKey: "x"), userInfo: nil)
            }
        }
    }
    
    func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String, wasClean: Bool) -> () {
        if wasClean {
            DLog("blockchain.info Websocket didCloseWithCode With No Error \(code) \(reason)")
        } else {
            DLog("blockchain.info Websocket didCloseWithCode With Error \(code) \(reason)")
        }
        
        self.webSocket!.delegate = nil
        self.webSocket!.close()
        self.webSocket = nil
        if consecutiveFailedConnections < MAX_CONSECUTIVE_FAILED_CONNECTIONS {
            self.reconnect()
        }
        consecutiveFailedConnections += 1
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_TRANSACTION_LISTENER_CLOSE()), object: nil, userInfo: nil)
    }
}
