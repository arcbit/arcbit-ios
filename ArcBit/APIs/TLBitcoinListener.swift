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

@objc class TLTransactionListener: NSObject {
    let MAX_CONSECUTIVE_FAILED_CONNECTIONS = 5
    let SEND_EMPTY_PACKET_TIME_INTERVAL = 60.0

//    fileprivate var keepAliveTimerBitcoinCash: Timer?
    fileprivate var socketBitcoinCash: SocketIOClient?
    fileprivate lazy var socketIsConnectedBitcoinCash: Bool = false
    fileprivate var webSocketBitcoinCash: SocketIOClient?
//    fileprivate var webSocketBitcoinCash: SRWebSocket?
//    fileprivate lazy var consecutiveFailedConnectionsBitcoinCash = 0

    
    fileprivate var keepAliveTimerBitcoin: Timer?
    fileprivate var socketBitcoin: SocketIOClient?
    fileprivate lazy var socketIsConnectedBitcoin: Bool = false
    fileprivate var webSocketBitcoin: SRWebSocket?
    fileprivate lazy var consecutiveFailedConnectionsBitcoin = 0
    
    private lazy var coinType2BlockExplorerAPI = [TLCoinType:TLBlockExplorer]()

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
        TLWalletUtils.SUPPORT_COIN_TYPES().forEach({ (coinType) in
            self.coinType2BlockExplorerAPI[coinType] = TLPreferences.getBlockExplorerAPI(coinType)
        })
    }
    
    func reconnect(_ coinType: TLCoinType) -> () {
        switch coinType {
        case .BCH:
            if (self.coinType2BlockExplorerAPI[coinType] == TLBlockExplorer.bitcoinCash_blockexplorer) {
                DLog("websocket reconnect blockchain.info")
                DLog("websocket reconnect insight")
                let url = String(format: "%@", TLPreferences.getBlockExplorerURL(coinType, blockExplorer: TLBlockExplorer.bitcoinCash_blockexplorer)!)
                self.webSocketBitcoinCash = SocketIOClient(socketURL: URL(string: url)!, config: [.log(false), .forcePolling(true)])
                weak var weakSelf = self
                self.webSocketBitcoinCash?.on("connect") {data, ack in
                    DLog("socketio onConnect")
                    self.consecutiveFailedConnectionsBitcoin = 0
                    weakSelf!.socketIsConnectedBitcoinCash = true
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_TRANSACTION_LISTENER_OPEN()), object: nil, userInfo: nil)
                    weakSelf!.webSocketBitcoinCash!.emit("subscribe", "inv")
                }
                self.webSocketBitcoinCash?.on("disconnect") {data, ack in
                    DLog("socketio onDisconnect")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_TRANSACTION_LISTENER_CLOSE()), object: nil, userInfo: nil)
                    if self.consecutiveFailedConnectionsBitcoin < self.MAX_CONSECUTIVE_FAILED_CONNECTIONS {
                        self.reconnect(coinType)
                    }
                    self.consecutiveFailedConnectionsBitcoin += 1
                }
                self.webSocketBitcoinCash?.on("error") {data, ack in
                    DLog("socketio error: \(data as AnyObject)")
                }
                self.webSocketBitcoinCash?.on("block") {data, ack in
                    let dataArray = data as NSArray
                    let firstObject: AnyObject? = dataArray.firstObject as AnyObject?
                    // data!.debugDescription is lastest block hash
                    // can't use this to update confirmations on transactions because insight tx does not contain blockheight field
                    DLog("socketio received lastest block hash: \(firstObject!.debugDescription)")
                    
                }
                //            self.socket?.on("tx") {data, ack in
                //                DLog("socketio__ tx \(data)")
                //            }
                self.webSocketBitcoinCash?.connect()
            } else {
                DLog("websocket reconnect insight")
                let url = String(format: "%@", TLPreferences.getBlockExplorerURL(coinType, blockExplorer: TLBlockExplorer.bitcoinCash_insight)!)
                self.socketBitcoinCash = SocketIOClient(socketURL: URL(string: url)!, config: [.log(false), .forcePolling(true)])
                weak var weakSelf = self
                self.socketBitcoinCash?.on("connect") {data, ack in
                    DLog("socketio onConnect")
                    self.consecutiveFailedConnectionsBitcoin = 0
                    weakSelf!.socketIsConnectedBitcoinCash = true
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_TRANSACTION_LISTENER_OPEN()), object: nil, userInfo: nil)
                    weakSelf!.socketBitcoinCash!.emit("subscribe", "inv")
                }
                self.socketBitcoinCash?.on("disconnect") {data, ack in
                    DLog("socketio onDisconnect")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_TRANSACTION_LISTENER_CLOSE()), object: nil, userInfo: nil)
                    if self.consecutiveFailedConnectionsBitcoin < self.MAX_CONSECUTIVE_FAILED_CONNECTIONS {
                        self.reconnect(coinType)
                    }
                    self.consecutiveFailedConnectionsBitcoin += 1
                }
                self.socketBitcoinCash?.on("error") {data, ack in
                    DLog("socketio error: \(data as AnyObject)")
                }
                self.socketBitcoinCash?.on("block") {data, ack in
                    let dataArray = data as NSArray
                    let firstObject: AnyObject? = dataArray.firstObject as AnyObject?
                    // data!.debugDescription is lastest block hash
                    // can't use this to update confirmations on transactions because insight tx does not contain blockheight field
                    DLog("socketio received lastest block hash: \(firstObject!.debugDescription)")
                    
                }
                //            self.socket?.on("tx") {data, ack in
                //                DLog("socketio__ tx \(data)")
                //            }
                self.socketBitcoinCash?.connect()
            }
        case .BTC:
            if (self.coinType2BlockExplorerAPI[coinType] == TLBlockExplorer.bitcoin_blockchain) {
                DLog("websocket reconnect blockchain.info")
                self.webSocketBitcoin?.delegate = nil
                self.webSocketBitcoin?.close()
                
                self.webSocketBitcoin = SRWebSocket(urlRequest: URLRequest(url: URL(string: "wss://ws.blockchain.info/inv")!))
                
                self.webSocketBitcoin?.delegate = self
                
                self.webSocketBitcoin?.open()
            } else {
                DLog("websocket reconnect insight")
                let url = String(format: "%@", TLPreferences.getBlockExplorerURL(coinType, blockExplorer: TLBlockExplorer.bitcoin_insight)!)
                self.socketBitcoin = SocketIOClient(socketURL: URL(string: url)!, config: [.log(false), .forcePolling(true)])
                weak var weakSelf = self
                self.socketBitcoin?.on("connect") {data, ack in
                    DLog("socketio onConnect")
                    self.consecutiveFailedConnectionsBitcoin = 0
                    weakSelf!.socketIsConnectedBitcoin = true
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_TRANSACTION_LISTENER_OPEN()), object: nil, userInfo: nil)
                    weakSelf!.socketBitcoin!.emit("subscribe", "inv")
                }
                self.socketBitcoin?.on("disconnect") {data, ack in
                    DLog("socketio onDisconnect")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_TRANSACTION_LISTENER_CLOSE()), object: nil, userInfo: nil)
                    if self.consecutiveFailedConnectionsBitcoin < self.MAX_CONSECUTIVE_FAILED_CONNECTIONS {
                        self.reconnect(coinType)
                    }
                    self.consecutiveFailedConnectionsBitcoin += 1
                }
                self.socketBitcoin?.on("error") {data, ack in
                    DLog("socketio error: \(data as AnyObject)")
                }
                self.socketBitcoin?.on("block") {data, ack in
                    let dataArray = data as NSArray
                    let firstObject: AnyObject? = dataArray.firstObject as AnyObject?
                    // data!.debugDescription is lastest block hash
                    // can't use this to update confirmations on transactions because insight tx does not contain blockheight field
                    DLog("socketio received lastest block hash: \(firstObject!.debugDescription)")
                    
                }
                //            self.socket?.on("tx") {data, ack in
                //                DLog("socketio__ tx \(data)")
                //            }
                self.socketBitcoin?.connect()
            }
        }
    }
    
    func isWebSocketOpen(_ coinType: TLCoinType) -> Bool {
        switch coinType {
        case .BCH:
            if (self.coinType2BlockExplorerAPI[coinType] == TLBlockExplorer.bitcoinCash_blockexplorer) {
                return self.socketIsConnectedBitcoinCash
            } else {
                return self.socketIsConnectedBitcoinCash
            }
        case .BTC:
            if (self.coinType2BlockExplorerAPI[coinType] == TLBlockExplorer.bitcoin_blockchain) {
                guard let webSocket = self.webSocketBitcoin else { return false }
                return webSocket.readyState.rawValue == SR_OPEN.rawValue
            } else {
                return self.socketIsConnectedBitcoin
            }
        }
    }
    
    fileprivate func sendWebSocketMessage(_ coinType: TLCoinType, msg: String) -> Bool {
        switch coinType {
        case .BCH:
            // bitcoin cash not using blockchain.info
            return true
        case .BTC:
            DLog("sendWebSocketMessage msg: \(msg)")
            if self.isWebSocketOpen(coinType) {
                self.webSocketBitcoin?.send(msg)
                return true
            } else {
                DLog("Websocket Error: not connect to websocket server")
                return false
            }
        }
    }
    
    @discardableResult func listenToIncomingTransactionForAddress(_ coinType: TLCoinType, address: String) -> Bool {
        switch coinType {
        case .BCH:
            //DLog("listen address: %@", address)
            if (self.coinType2BlockExplorerAPI[coinType] == TLBlockExplorer.bitcoinCash_blockexplorer) {
                if (self.socketIsConnectedBitcoinCash) {
                    guard let socket = self.webSocketBitcoinCash else { return false }
                    
                    //DLog("socketio emit address: \(address)")
                    socket.emit("unsubscribe", "bitcoind/addresstxid", [address])
                    socket.emit("subscribe", "bitcoind/addresstxid", [address])
                    
                    socket.on("bitcoind/addresstxid") {data, ack in
                        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
                            DLog("socketio on data: \(data)")
                            let dataArray = data as NSArray
                            let dataDictionary = dataArray.firstObject as! NSDictionary
                            let addr = dataDictionary["address"] as! String
                            //bad api design, this on is not address specific, will call for every subscribe address
                            if (addr == address) {
                                let txHash = dataDictionary["txid"] as! String
                                //DLog("socketio on address: \(addr)")
                                //DLog("socketio transaction: \(txHash)")
                                TLBlockExplorerAPI.instance().getTx(coinType, txHash: txHash, success: {
                                    (txObject) in
                                    //                                if let txDict = txDict { // TODO test before remove commented out code
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_NEW_UNCONFIRMED_TRANSACTION()), object: txObject, userInfo: nil)
                                    //                                }
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
            } else {
                if (self.socketIsConnectedBitcoinCash) {
                    guard let socket = self.socketBitcoinCash else { return false }
                    
                    DLog("socketio emit address: \(address)")
                    socket.emit("unsubscribe", "bitcoind/addresstxid", [address])
                    socket.emit("subscribe", "bitcoind/addresstxid", [address])
                    
                    socket.on("bitcoind/addresstxid") {data, ack in
                        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
                            DLog("socketio on data: \(data)")
                            let dataArray = data as NSArray
                            let dataDictionary = dataArray.firstObject as! NSDictionary
                            let addr = dataDictionary["address"] as! String
                            //bad api design, this on is not address specific, will call for every subscribe address
                            if (addr == address) {
                                let txHash = dataDictionary["txid"] as! String
                                //DLog("socketio on address: \(addr)")
                                //DLog("socketio transaction: \(txHash)")
                                TLBlockExplorerAPI.instance().getTx(coinType, txHash: txHash, success: {
                                    (txObject) in
                                    //                                if let txDict = txDict { // TODO test before remove commented out code
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_NEW_UNCONFIRMED_TRANSACTION()), object: txObject, userInfo: nil)
                                    //                                }
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
        case .BTC:
            //DLog("listen address: %@", address)
            if (self.coinType2BlockExplorerAPI[coinType] == TLBlockExplorer.bitcoin_blockchain) {
                if self.isWebSocketOpen(coinType) {
                    let msg = String(format: "{\"op\":\"addr_sub\", \"addr\":\"%@\"}", address)
                    self.sendWebSocketMessage(coinType, msg: msg)
                    return true
                } else {
                    DLog("Websocket Error: not connect to websocket server")
                    return false
                }
            } else {
                if (self.socketIsConnectedBitcoin) {
                    guard let socket = self.socketBitcoin else { return false }
                    
                    //DLog("socketio emit address: \(address)")
                    socket.emit("unsubscribe", "bitcoind/addresstxid", [address])
                    socket.emit("subscribe", "bitcoind/addresstxid", [address])
                    
                    socket.on("bitcoind/addresstxid") {data, ack in
                        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
                            DLog("socketio on data: \(data)")
                            let dataArray = data as NSArray
                            let dataDictionary = dataArray.firstObject as! NSDictionary
                            let addr = dataDictionary["address"] as! String
                            //bad api design, this on is not address specific, will call for every subscribe address
                            if (addr == address) {
                                let txHash = dataDictionary["txid"] as! String
                                //DLog("socketio on address: \(addr)")
                                //DLog("socketio transaction: \(txHash)")
                                TLBlockExplorerAPI.instance().getTx(coinType, txHash: txHash, success: {
                                    (txObject) in
                                    //                                if let txDict = txDict { // TODO test before remove commented out code
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_NEW_UNCONFIRMED_TRANSACTION()), object: txObject, userInfo: nil)
                                    //                                }
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
    }
    
    func close(_ coinType: TLCoinType) -> () {
        switch coinType {
        case .BCH:
            if (self.coinType2BlockExplorerAPI[coinType] == TLBlockExplorer.bitcoinCash_blockexplorer) {
                DLog("closing blockchain.info websocket")
                self.webSocketBitcoinCash?.disconnect()
            } else {
                DLog("closing socketio")
                self.socketBitcoin?.disconnect()
            }
        case .BTC:
            if (self.coinType2BlockExplorerAPI[coinType] == TLBlockExplorer.bitcoin_blockchain) {
                DLog("closing blockchain.info websocket")
                self.webSocketBitcoin?.close()
            } else {
                DLog("closing socketio")
                self.socketBitcoin?.disconnect()
            }
        }
    }
    
    fileprivate func keepAlive() -> () {
        keepAliveTimerBitcoin?.invalidate()
        keepAliveTimerBitcoin = nil
        keepAliveTimerBitcoin = Timer.scheduledTimer(timeInterval: SEND_EMPTY_PACKET_TIME_INTERVAL,
            target: self,
            selector: #selector(TLTransactionListener.sendEmptyPacket),
            userInfo: nil,
            repeats: true)
    }
    
    func sendEmptyPacket() -> () {
        DLog("blockchain.info Websocket sendEmptyPacket")
        if self.isWebSocketOpen(TLCoinType.BTC) {
            self.sendWebSocketMessage(TLCoinType.BTC, msg: "")
        }
    }
    
    func updateModelWithNewBlock(_ jsonData: NSDictionary) {
        let blockHeight = jsonData.object(forKey: "height") as! NSNumber
        let blockHeightObject = TLBlockHeightObject(jsonDict:  ["height": UInt64(blockHeight.uint64Value) as AnyObject])
        DLog("updateModelWithNewBlock: \(blockHeightObject.blockHeight)")
        TLBlockchainStatus.instance().setBlockHeight(TLCoinType.BTC, blockHeight: blockHeightObject)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_BLOCK()), object:nil, userInfo:nil)
    }
}

extension TLTransactionListener : SRWebSocketDelegate {
    func webSocketDidOpen(_ webSocket: SRWebSocket) -> () {
        DLog("blockchain.info webSocketDidOpen")
        consecutiveFailedConnectionsBitcoin = 0
        self.sendWebSocketMessage(TLCoinType.BTC, msg: "{\"op\":\"blocks_sub\"}")

        self.keepAlive()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_TRANSACTION_LISTENER_OPEN()), object: nil, userInfo: nil)
    }
    
    func webSocket(_ webSocket:SRWebSocket, didFailWithError error:NSError) -> () {
        DLog("blockchain.info Websocket didFailWithError \(error.description)")
        
        self.webSocketBitcoin?.delegate = nil
        self.webSocketBitcoin?.close()
        self.webSocketBitcoin = nil
        if consecutiveFailedConnectionsBitcoin < MAX_CONSECUTIVE_FAILED_CONNECTIONS {
            self.reconnect(TLCoinType.BTC)
        }
        consecutiveFailedConnectionsBitcoin += 1
    }
    
    public func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
            let data = (message as AnyObject).data(using: String.Encoding.utf8.rawValue)
            
            let jsonDict = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0))) as! NSDictionary
            DLog("blockchain.info didReceiveMessage \(jsonDict.description)")

            if (jsonDict.object(forKey: "op") as! String == "utx") {
                let txObject = TLTxObject(TLCoinType.BTC, dict: jsonDict.object(forKey: "x") as! NSDictionary)
                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_NEW_UNCONFIRMED_TRANSACTION()), object: txObject, userInfo: nil)
            } else if (jsonDict.object(forKey: "op") as! String == "block") {
                self.updateModelWithNewBlock(jsonDict.object(forKey: "x") as! NSDictionary)
            }
        }
    }
    
    func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String, wasClean: Bool) -> () {
        if wasClean {
            DLog("blockchain.info Websocket didCloseWithCode With No Error \(code) \(reason)")
        } else {
            DLog("blockchain.info Websocket didCloseWithCode With Error \(code) \(reason)")
        }
        
        self.webSocketBitcoin?.delegate = nil
        self.webSocketBitcoin?.close()
        self.webSocketBitcoin = nil
        if consecutiveFailedConnectionsBitcoin < MAX_CONSECUTIVE_FAILED_CONNECTIONS {
            self.reconnect(TLCoinType.BTC)
        }
        consecutiveFailedConnectionsBitcoin += 1
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_TRANSACTION_LISTENER_CLOSE()), object: nil, userInfo: nil)
    }
}
