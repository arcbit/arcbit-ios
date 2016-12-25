//
//  TLStealthWallet.swift
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

@objc class TLStealthWallet: NSObject {
    struct Challenge {
        static var challenge = ""
        static var needsRefreshing = true
    }
    
    struct STATIC_MEMBERS {
        static let MAX_CONSECUTIVE_INVALID_SIGNATURES = 4
        static let PREVIOUS_TX_CONFIRMATIONS_TO_COUNT_AS_SPENT:UInt64 = 12
        static let TIME_TO_WAIT_TO_CHECK_FOR_SPENT_TX:UInt64 = 86400 // 1 day in seconds
    }
    
    fileprivate var stealthWalletDict: NSDictionary?
    fileprivate var unspentPaymentAddress2PaymentTxid = [String:String]()
    fileprivate var paymentAddress2PrivateKeyDict = [String:String]()
    fileprivate var paymentTxid2PaymentAddressDict = [String:String]()
    fileprivate var scanPublicKey: String? = nil
    fileprivate var spendPublicKey: String? = nil
    fileprivate var accountObject: TLAccountObject?
    var hasUpdateStealthPaymentStatuses = false
    var isListeningToStealthPayment: Bool = false

    init(stealthDict: NSDictionary, accountObject: TLAccountObject, updateStealthPaymentStatuses: Bool) {
        super.init()
        self.stealthWalletDict = stealthDict
        self.accountObject = accountObject
        self.setUpStealthPaymentAddresses(updateStealthPaymentStatuses, isSetup: true)
    }
    
    func getStealthAddress() -> String {
        return self.stealthWalletDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESS) as! String
    }
    
    func getStealthAddressScanKey() -> String {
        return self.stealthWalletDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESS_SCAN_KEY) as! String
    }
    
    func getStealthAddressSpendKey() -> String {
        return self.stealthWalletDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESS_SPEND_KEY) as! String
    }
    
    func getStealthAddressLastTxTime() -> UInt64 {
        return (self.stealthWalletDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LAST_TX_TIME) as! NSNumber).uint64Value
    }
    
    func getStealthAddressServers() -> NSMutableDictionary {
        return self.stealthWalletDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_SERVERS) as! NSMutableDictionary
    }
    
    func paymentTxidExist(_ txid: String) -> Bool {
        return self.paymentTxid2PaymentAddressDict[txid] != nil
    }
    
    func isPaymentAddress(_ address: String) -> Bool {
        return self.paymentAddress2PrivateKeyDict[address] != nil
    }
    
    func getPaymentAddressPrivateKey(_ address: String) -> String? {
        return self.paymentAddress2PrivateKeyDict[address]
    }
    
    func setPaymentAddressPrivateKey(_ address: String, privateKey: String) -> () {
        let lock = NSLock()
        lock.lock()
        self.paymentAddress2PrivateKeyDict[address] = privateKey
        lock.unlock()
    }
    
    func getStealthAddressPayments() -> NSArray {
        return self.stealthWalletDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYMENTS) as! NSArray
    }
    
    func getPaymentAddressForIndex(_ index: Int) -> String {
        let paymentDict = (self.stealthWalletDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYMENTS)
            as! NSArray).object(at: index) as! NSDictionary
        return paymentDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
    }
    
    func getStealthAddressPaymentsCount() -> Int {
        return (self.stealthWalletDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYMENTS) as! NSArray).count
    }
    
    func getPaymentAddresses() -> Array<String> {
        return [String](self.paymentAddress2PrivateKeyDict.keys)
    }
    
    func getUnspentPaymentAddresses() -> Array<String> {
        return [String](self.unspentPaymentAddress2PaymentTxid.keys)
    }
    
    func getStealthAddressSpendPublicKey() -> String {
        if spendPublicKey == nil {
            let publicKeys = TLStealthAddress.getScanPublicKeyAndSpendPublicKey(self.getStealthAddress(), isTestnet: self.accountObject!.appWallet!.walletConfig.isTestnet)
            scanPublicKey = publicKeys.0
            spendPublicKey = publicKeys.1
        }
        return spendPublicKey!
    }
    
    func getStealthAddressScanPublicKey() -> String {
        if scanPublicKey == nil {
            let publicKeys = TLStealthAddress.getScanPublicKeyAndSpendPublicKey(self.getStealthAddress(), isTestnet: self.accountObject!.appWallet!.walletConfig.isTestnet)
            scanPublicKey = publicKeys.0
            spendPublicKey = publicKeys.1
        }
        return scanPublicKey!
    }
    
    func setUpStealthPaymentAddresses(_ updateStealthPaymentStatuses: Bool, isSetup: Bool, async: Bool=true) -> () {
        DLog("\(self.accountObject!.getAccountIdxNumber()) setUpStealthPaymentAddresses0 \(self.getStealthAddressPayments().count)")
        if isSetup {
            self.accountObject!.removeOldStealthPayments()
        }
        DLog("\(self.accountObject!.getAccountIdxNumber()) setUpStealthPaymentAddresses1 \(self.getStealthAddressPayments().count)")

        let paymentsArray = self.getStealthAddressPayments()

        if isSetup {
            self.unspentPaymentAddress2PaymentTxid = [String:String]()
            self.paymentAddress2PrivateKeyDict = [String:String]()
            self.paymentTxid2PaymentAddressDict = [String:String]()
        }
        
        var possiblyClaimedTxidArray = [String]()
        var possiblyClaimedAddressArray = [String]()
        var possiblyClaimedTxTimeArray = [UInt64]()

        let nowTime = UInt64(Date().timeIntervalSince1970)

    
        for i in stride(from: 0, to: paymentsArray.count, by: 1) {
            if let paymentDict = paymentsArray.object(at: i) as? NSDictionary {
                let address = paymentDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
                let txid = paymentDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TXID) as! String
                let privateKey = paymentDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_KEY) as! String
                if isSetup {
                    self.paymentTxid2PaymentAddressDict[txid] = address
                    self.paymentAddress2PrivateKeyDict[address] = privateKey
                }
                
                let stealthPaymentStatus = paymentDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS) as! Int
                
                if isSetup {
                    if stealthPaymentStatus == TLStealthPaymentStatus.unspent.rawValue {
                        self.unspentPaymentAddress2PaymentTxid[address] = txid
                    }
                }
                
                // dont check to remove last STEALTH_PAYMENTS_FETCH_COUNT payment addresses
                if i >= paymentsArray.count - Int(TLStealthExplorerAPI.STATIC_MEMBERS.STEALTH_PAYMENTS_FETCH_COUNT) {
                    continue
                }
                
                if stealthPaymentStatus == TLStealthPaymentStatus.claimed.rawValue || stealthPaymentStatus == TLStealthPaymentStatus.unspent.rawValue {
                    
                    let lastCheckTime = UInt64((paymentDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHECK_TIME) as! NSNumber).uint64Value)
                    
                    if (nowTime - lastCheckTime) > STATIC_MEMBERS.TIME_TO_WAIT_TO_CHECK_FOR_SPENT_TX {
                        possiblyClaimedTxidArray.append(txid)
                        possiblyClaimedAddressArray.append(address)
                        possiblyClaimedTxTimeArray.append(lastCheckTime)
                    }
                }
            }
        }
        
        if updateStealthPaymentStatuses {
            hasUpdateStealthPaymentStatuses = true
            if async {
                DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.low).async {
                    self.addOrSetStealthPaymentsWithStatus(possiblyClaimedTxidArray, addressArray: possiblyClaimedAddressArray,
                        txTimeArray: possiblyClaimedTxTimeArray, isAddingPayments: false, waitForCompletion: false)
                }
            } else {
                self.addOrSetStealthPaymentsWithStatus(possiblyClaimedTxidArray, addressArray: possiblyClaimedAddressArray,
                    txTimeArray: possiblyClaimedTxTimeArray, isAddingPayments: false, waitForCompletion: true)
            }
        }
    }
    
    func updateStealthPaymentStatusesAsync() -> () {
        self.setUpStealthPaymentAddresses(true, isSetup: false)
    }
    
    func getPrivateKeyForAddress(_ expectedAddress: String, script: String) -> String? {
        let scanKey = self.getStealthAddressScanKey()
        let spendKey = self.getStealthAddressSpendKey()
        if let secret = TLStealthAddress.getPaymentAddressPrivateKeySecretFromScript(script, scanPrivateKey: scanKey, spendPrivateKey: spendKey) {
            let outputAddress = TLCoreBitcoinWrapper.getAddressFromSecret(secret, isTestnet: self.accountObject!.appWallet!.walletConfig.isTestnet)
            if outputAddress! == expectedAddress {
                return TLCoreBitcoinWrapper.privateKeyFromSecret(secret, isTestnet: self.accountObject!.appWallet!.walletConfig.isTestnet)
            }
        }
        return nil
    }
    
    func isCurrentServerWatching() -> Bool {
        let currentServerURL = TLPreferences.getStealthExplorerURL()!
        let stealthAddressServersDict = self.getStealthAddressServers()
        if let stealthServerDict: AnyObject = stealthAddressServersDict.object(forKey: currentServerURL) as AnyObject? {
            return (stealthServerDict as! NSDictionary).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_WATCHING) as! Bool
        } else {
            self.accountObject!.setStealthAddressServerStatus(currentServerURL, isWatching: false)

            let serverAttributes = [
                TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_WATCHING: false,
            ]
            let serverAttributesDict = NSMutableDictionary(dictionary: serverAttributes)
            stealthAddressServersDict.setObject(serverAttributesDict, forKey: currentServerURL as NSCopying)
            
            return false
        }
    }
    
    func checkIfHaveStealthPayments() -> Bool {
        let stealthAddress = self.getStealthAddress()
        let scanKey = self.getStealthAddressScanKey()
        let spendKey = self.getStealthAddressSpendKey()
        let scanPublicKey = self.getStealthAddressScanPublicKey()
        let success = TLStealthWallet.watchStealthAddress(stealthAddress, scanPriv: scanKey, spendPriv: spendKey, scanPublicKey: scanPublicKey)
        if success {
            let gotOldestPaymentAddressesAndPayments = self.getStealthPayments(stealthAddress,
                scanPriv: scanKey, spendPriv: spendKey, scanPublicKey: scanPublicKey, offset: 0)
            if gotOldestPaymentAddressesAndPayments != nil &&
                (gotOldestPaymentAddressesAndPayments!.2 != nil && gotOldestPaymentAddressesAndPayments!.2!.count > 0) {
                return true
            }
        }
        
        return false
    }
    
    func checkToWatchStealthAddress() -> () {
        let stealthAddress = self.getStealthAddress()
        if self.isCurrentServerWatching() != true {
            let scanKey = self.getStealthAddressScanKey()
            let spendKey = self.getStealthAddressSpendKey()
            let scanPublicKey = self.getStealthAddressScanPublicKey()
            let success = TLStealthWallet.watchStealthAddress(stealthAddress, scanPriv: scanKey, spendPriv: spendKey, scanPublicKey: scanPublicKey)
            if success {
                let stealthAddressServersDict = self.getStealthAddressServers()
                let currentServerURL = TLPreferences.getStealthExplorerURL()!
                (stealthAddressServersDict.object(forKey: currentServerURL) as! NSMutableDictionary).setObject(true, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_WATCHING as NSCopying)
                self.accountObject!.setStealthAddressServerStatus(currentServerURL, isWatching: true)
            }
        }
    }

    func getStealthAddressAndSignatureFromChallenge(_ challenge: String) -> (String, String) {
        let privKey = self.getStealthAddressScanKey()
        let signature = TLCoreBitcoinWrapper.getSignature(privKey, message: challenge);
        let stealthAddress = self.getStealthAddress()
        return (stealthAddress, signature);
    }
    
    class func getChallengeAndSign(_ stealthAddress: String, privKey: String, pubKey: String) -> String? {
        if TLStealthWallet.Challenge.needsRefreshing == true {
            let jsonData = TLStealthExplorerAPI.instance().getChallenge()
            if let _: AnyObject = jsonData.object(forKey: TLNetworking.STATIC_MEMBERS.HTTP_ERROR_CODE) as AnyObject? {
                return nil
            }
            
            TLStealthWallet.Challenge.challenge = jsonData["challenge"] as! String
            TLStealthWallet.Challenge.needsRefreshing = false
        }
        
        let challenge = TLStealthWallet.Challenge.challenge

        DLog("getChallengeAndSign \(challenge)")
        return TLCoreBitcoinWrapper.getSignature(privKey, message: challenge);
    }

    func addOrSetStealthPaymentsWithStatus(_ txidArray: [String], addressArray: [String], txTimeArray: [UInt64], isAddingPayments: Bool, waitForCompletion: Bool) -> () {
        var jsonData:NSDictionary? = nil
        if txidArray.count > 0 {
            jsonData = TLBlockExplorerAPI.instance().getUnspentOutputsSynchronous(addressArray as NSArray)
            if let _: AnyObject = jsonData!.object(forKey: TLNetworking.STATIC_MEMBERS.HTTP_ERROR_CODE) as AnyObject? {
                let msg = jsonData![TLNetworking.STATIC_MEMBERS.HTTP_ERROR_MSG] as? String
                if msg != "No free outputs to spend" {
                    
                    return
                } else {
                    jsonData = ["unspent_outputs":[]];
                }
            }
        }
        
        var txid2hasUnspentOutputs = [String:Bool]()
        for txid in txidArray {
            txid2hasUnspentOutputs[txid] = false
        }

        if jsonData != nil {
            let unspentOutputs = jsonData!.object(forKey: "unspent_outputs") as! NSArray
            
            for _unspentOutput in unspentOutputs {
                let unspentOutput = _unspentOutput as! NSDictionary
                let unspentOutputTxid = unspentOutput.object(forKey: "tx_hash_big_endian") as! String
                txid2hasUnspentOutputs[unspentOutputTxid] = true
            }
        }

        let group = DispatchGroup()
        let nowTime = UInt64(Date().timeIntervalSince1970)

        for i in 0 ..< txidArray.count {
            let txid = txidArray[i]
            let paymentAddress = addressArray[i]
            let txTime = txTimeArray[i]

            if txid2hasUnspentOutputs[txid] == false {
                // means blockexplorer has not seen tx yet OR stealth payment already been spent
                
                if waitForCompletion {
                    group.enter()
                }
                // cant figure out whether stealth payments has been spent by getting unspent outputs because
                // blockexplorer api might receive tx yet, if we are pushing tx from a source that is not the blockexplorer api
                TLBlockExplorerAPI.instance().getTxBackground(txid, success: { (jsonData:AnyObject?) -> () in
                    if (jsonData == nil) {
                        if waitForCompletion {
                            group.leave()
                        }
                        return
                    }
                    let stealthDataScriptAndOutputAddresses = TLStealthWallet.getStealthDataScriptAndOutputAddresses((jsonData as? NSDictionary)!)
                    
                    if stealthDataScriptAndOutputAddresses == nil || stealthDataScriptAndOutputAddresses!.0 == nil {
                        if waitForCompletion {
                            group.leave()
                        }
                        return
                    }
                    if (stealthDataScriptAndOutputAddresses!.1).index(of: paymentAddress) != nil {
                        let txObject = TLTxObject(dict:jsonData as! NSDictionary)
                        
                        //Note: this confirmation count is not the confirmations for the tx that spent the stealth payment
                        let confirmations = txObject.getConfirmations()
                        
                        if confirmations >= STATIC_MEMBERS.PREVIOUS_TX_CONFIRMATIONS_TO_COUNT_AS_SPENT {
                            if isAddingPayments {
                                if let privateKey = self.generateAndAddStealthAddressPaymentKey(stealthDataScriptAndOutputAddresses!.0!, expectedAddress: paymentAddress,
                                    txid: txid, txTime: txTime, stealthPaymentStatus: TLStealthPaymentStatus.spent) {
                                        self.setPaymentAddressPrivateKey(paymentAddress, privateKey: privateKey)
                                } else {
                                    DLog("no privateKey for \(paymentAddress)")
                                }
                            } else {
                                self.accountObject!.setStealthPaymentStatus(txid, stealthPaymentStatus: TLStealthPaymentStatus.spent, lastCheckTime: nowTime)
                            }
                        } else {
                            if isAddingPayments {
                                if let privateKey = self.generateAndAddStealthAddressPaymentKey(stealthDataScriptAndOutputAddresses!.0!, expectedAddress: paymentAddress,
                                    txid: txid, txTime: txTime, stealthPaymentStatus: TLStealthPaymentStatus.claimed) {
                                        self.setPaymentAddressPrivateKey(paymentAddress, privateKey: privateKey)
                                } else {
                                    DLog("no privateKey for \(paymentAddress)")
                                }
                            } else {
                                self.accountObject!.setStealthPaymentStatus(txid, stealthPaymentStatus: TLStealthPaymentStatus.claimed, lastCheckTime: nowTime)
                            }
                        }
                        
                    }
                    if waitForCompletion {
                        group.leave()
                    }
                    
                    }, failure: { (code, status) -> () in
                        if waitForCompletion {
                            group.leave()
                        }
                })
                
            } else {
                if waitForCompletion {
                    group.enter()
                }
                TLBlockExplorerAPI.instance().getTxBackground(txid, success: { (jsonData:AnyObject?) -> () in
                    if (jsonData == nil) {
                        if waitForCompletion {
                            group.leave()
                        }
                        return
                    }
                    if let stealthDataScriptAndOutputAddresses = TLStealthWallet.getStealthDataScriptAndOutputAddresses((jsonData as? NSDictionary)!) {
                        if stealthDataScriptAndOutputAddresses.0 == nil {
                            if waitForCompletion {
                                group.leave()
                            }
                            return
                        }
                        if (stealthDataScriptAndOutputAddresses.1).index(of: paymentAddress) != nil {
                            if isAddingPayments {
                                if let privateKey = self.generateAndAddStealthAddressPaymentKey(stealthDataScriptAndOutputAddresses.0!, expectedAddress: paymentAddress,
                                    txid: txid, txTime: txTime, stealthPaymentStatus: TLStealthPaymentStatus.unspent) {
                                        self.setPaymentAddressPrivateKey(paymentAddress, privateKey: privateKey)
                                } else {
                                    DLog("no privateKey for \(paymentAddress)")
                                }
                            } else {
                                self.accountObject!.setStealthPaymentStatus(txid, stealthPaymentStatus: TLStealthPaymentStatus.unspent, lastCheckTime: nowTime)
                            }
                        }
                    }
                    if waitForCompletion {
                        group.leave()
                    }
                    
                    }, failure: { (code, status) -> () in
                        if waitForCompletion {
                            group.leave()
                        }
                        
                })
                
            }
        }
        
        if waitForCompletion {
            group.wait(timeout: DispatchTime.distantFuture)
        }
    }
    
    func getAndStoreStealthPayments(_ offset: Int) -> (Bool, UInt64, [String])? {
        let stealthAddress = self.getStealthAddress()
        let scanKey = self.getStealthAddressScanKey()
        let spendKey = self.getStealthAddressSpendKey()
        let scanPublicKey = self.getStealthAddressScanPublicKey()
        
        let ret = self.getStealthPayments(stealthAddress, scanPriv: scanKey, spendPriv: spendKey,
            scanPublicKey: scanPublicKey, offset: offset)
        
        if ret == nil {
            return nil
        }
        
        let gotOldestPaymentAddresses = ret!.0
        let latestTxTime = ret!.1
        let payments = ret!.2

        if payments == nil {
            return (gotOldestPaymentAddresses, latestTxTime, [])
        }
        
        var txidArray = [String]()
        var addressArray = [String]()
        var txTimeArray = [UInt64]()

        for _payment in payments!.reverseObjectEnumerator() {
            let payment = _payment as! NSDictionary
            let txid = payment.object(forKey: "txid") as! String
            if self.paymentTxidExist(txid) == true {
                continue
            }
            let addr = payment.object(forKey: "addr") as! String
            txidArray.append(txid)
            addressArray.append(addr)
            txTimeArray.append(UInt64((payment.object(forKey: "time") as! NSNumber).uint64Value))
        }
        if txidArray.count == 0 {
            return (gotOldestPaymentAddresses, latestTxTime, [])
        }

        // must check if txids exist and are stealth payments that belong to this account before storing it
        self.addOrSetStealthPaymentsWithStatus(txidArray, addressArray: addressArray, txTimeArray: txTimeArray, isAddingPayments: true, waitForCompletion: true)
        return (gotOldestPaymentAddresses, latestTxTime, addressArray)
    }

    class func getStealthDataScriptAndOutputAddresses(_ jsonTxData: NSDictionary) -> (stealthDataScript: String?, outputAddresses:Array<String>)? {
        let outsArray = jsonTxData.object(forKey: "out") as? NSArray
        
        if (outsArray != nil) {
            var outputAddresses = [String]()
            var stealthDataScript:String? = nil
            for _output in outsArray! {
                let output = _output as! NSDictionary
                
                if let addr = output.object(forKey: "addr") as? String {
                    outputAddresses.append(addr)
                } else {
                    let script = output.object(forKey: "script") as! String
                    if script.characters.count == 80 {
                        stealthDataScript = script
                    }
                    
                }
            }
            return (stealthDataScript, outputAddresses)
        }
        return nil
    }

    func generateAndAddStealthAddressPaymentKey(_ stealthAddressDataScript: String, expectedAddress: String, txid: String, txTime: UInt64, stealthPaymentStatus:
        TLStealthPaymentStatus) -> String? {

        if self.paymentTxidExist(txid) == true {
            return nil
        }
        if let privateKey = self.getPrivateKeyForAddress(expectedAddress, script: stealthAddressDataScript) {
            self.unspentPaymentAddress2PaymentTxid[expectedAddress] = txid
            self.paymentTxid2PaymentAddressDict[txid] = expectedAddress
            self.setPaymentAddressPrivateKey(expectedAddress, privateKey: privateKey)

            self.accountObject!.addStealthAddressPaymentKey(privateKey, address: expectedAddress, txid: txid, txTime: txTime, stealthPaymentStatus: stealthPaymentStatus)
            return privateKey
        } else {
            DLog("error key not found for address \(expectedAddress)")
            return nil
        }
    }
    
    func addStealthAddressPaymentKey(_ privateKey: String, paymentAddress: String, txid: String, txTime: UInt64, stealthPaymentStatus: TLStealthPaymentStatus) -> Bool {
        self.unspentPaymentAddress2PaymentTxid[paymentAddress] = txid
        self.paymentTxid2PaymentAddressDict[txid] = paymentAddress
        self.setPaymentAddressPrivateKey(paymentAddress, privateKey: privateKey)
        self.accountObject!.addStealthAddressPaymentKey(privateKey, address: paymentAddress, txid: txid, txTime: txTime, stealthPaymentStatus: stealthPaymentStatus)
        return true
    }
    
    func getStealthPayments(_ stealthAddress: String, scanPriv: String, spendPriv: String,
        scanPublicKey: String, offset:Int) -> (Bool, UInt64, NSArray?)? {
            var signature = TLStealthWallet.getChallengeAndSign(stealthAddress, privKey: scanPriv, pubKey: scanPublicKey)
            
            if signature == nil {
                return nil
            }
                        
            var gotOldestPaymentAddresses = false
            
            var jsonData:NSDictionary? = nil
            var consecutiveInvalidSignatures = 0
            
            while true {
                jsonData = TLStealthExplorerAPI.instance().getStealthPaymentsSynchronous(stealthAddress, signature: signature!, offset: offset)
                if let _: AnyObject = jsonData?.object(forKey: TLNetworking.STATIC_MEMBERS.HTTP_ERROR_CODE) as AnyObject? {
                    return nil
                }
                
                if let errorCode = jsonData!.object(forKey: TLStealthExplorerAPI.STATIC_MEMBERS.SERVER_ERROR_CODE) as? Int {
                    if errorCode == TLStealthExplorerAPI.STATIC_MEMBERS.INVALID_SIGNATURE_ERROR {
                        consecutiveInvalidSignatures += 1
                        if (consecutiveInvalidSignatures > STATIC_MEMBERS.MAX_CONSECUTIVE_INVALID_SIGNATURES) {
                            return nil
                        }
                        TLStealthWallet.Challenge.needsRefreshing = true
                        signature = TLStealthWallet.getChallengeAndSign(stealthAddress, privKey: scanPriv, pubKey: scanPublicKey)
                        if signature == nil {
                            return nil
                        }
                    }
                    continue
                }
                break
            }
            
            let stealthPayments = jsonData!["payments"] as! NSArray

            if stealthPayments.count == 0 {
                gotOldestPaymentAddresses = true
                return (true, 0, stealthPayments)
            }
            
            let txTimeLowerBound = self.getStealthAddressLastTxTime()
            let olderTxTime = ((stealthPayments.lastObject as! NSDictionary)["time"] as! NSNumber).uint64Value
            if olderTxTime < txTimeLowerBound || stealthPayments.count < TLStealthExplorerAPI.STATIC_MEMBERS.STEALTH_PAYMENTS_FETCH_COUNT {
                gotOldestPaymentAddresses = true
            }
            
            let latestTxTime = ((stealthPayments.firstObject as! NSDictionary)["time"] as! NSNumber).uint64Value
            return (gotOldestPaymentAddresses, latestTxTime, stealthPayments)
    }
    
    class func watchStealthAddress(_ stealthAddress: String, scanPriv: String, spendPriv: String, scanPublicKey: String) -> Bool {
        var signature = self.getChallengeAndSign(stealthAddress, privKey: scanPriv, pubKey: scanPublicKey)
        if signature == nil {
            return false
        }
        
        var consecutiveInvalidSignatures = 0
        
        while true {
            let jsonData = TLStealthExplorerAPI.instance().watchStealthAddressSynchronous(stealthAddress, scanPriv: scanPriv, signature: signature!)
            
            if let _: AnyObject = jsonData.object(forKey: TLNetworking.STATIC_MEMBERS.HTTP_ERROR_CODE) as AnyObject? {
                return false
            }
            
            if let errorCode = (jsonData as NSDictionary).object(forKey: TLStealthExplorerAPI.STATIC_MEMBERS.SERVER_ERROR_CODE) as? Int {
                if errorCode == TLStealthExplorerAPI.STATIC_MEMBERS.INVALID_SIGNATURE_ERROR {
                    TLStealthWallet.Challenge.needsRefreshing = true
                    signature = self.getChallengeAndSign(stealthAddress, privKey: scanPriv, pubKey: scanPublicKey)
                    if signature == nil {
                        return false
                    }
                    consecutiveInvalidSignatures += 1
                    if (consecutiveInvalidSignatures > STATIC_MEMBERS.MAX_CONSECUTIVE_INVALID_SIGNATURES) {
                        return false
                    } else {
                        continue
                    }
                }
            } else {
                if let success: AnyObject = jsonData.object(forKey: "success") as AnyObject?  {
                    return success as! Bool
                }
                
                return false
            }
        }
    }
}
