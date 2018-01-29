//
//  TLImportedAddress.swift
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

@objc class TLImportedAddress : NSObject {
    
    fileprivate var appWallet:TLWallet?
    fileprivate var addressDict:NSMutableDictionary?
    lazy var haveUpDatedUTXOs: Bool = false
    lazy var unspentOutputsCount: Int = 0
    lazy var unspentOutputs = Array<TLUnspentOutputObject>()
    fileprivate var unspentOutputsSum:TLCoin?
    var balance = TLCoin.zero()
    fileprivate var fetchedAccountData = false
    var listeningToIncomingTransactions = false
    fileprivate var watchOnly = false
    fileprivate var archived = false
    fileprivate var positionInWalletArray:Int?
    fileprivate var txObjectArray:NSMutableArray?
    fileprivate var txidToAccountAmountDict:NSMutableDictionary?
    fileprivate var txidToAccountAmountTypeDict:NSMutableDictionary?
    fileprivate var processedTxSet:NSMutableSet?
    fileprivate var privateKey:String?
    fileprivate var importedAddress:String?
    var coinType:TLCoinType = TLWalletUtils.DEFAULT_COIN_TYPE()
    var downloadState:TLDownloadState = .notDownloading

    init(appWallet: TLWallet, coinType: TLCoinType, dict:NSDictionary) {
        super.init()
        self.appWallet = appWallet
        self.coinType = coinType
        addressDict = NSMutableDictionary(dictionary:dict)
        importedAddress = addressDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String?
        processedTxSet = NSMutableSet()
        if (addressDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_KEY) != nil) {
            self.watchOnly = false
        } else {
            self.watchOnly = true
        }
        
        self.archived = addressDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS) as! Int == TLAddressStatus.archived.rawValue
        resetAccountBalances()
    }
    
    func hasSetPrivateKeyInMemory() -> (Bool) {
        return privateKey != nil
    }
    
    func setPrivateKeyInMemory(_ privKey:String) -> (Bool) {
        if (TLCoreBitcoinWrapper.getAddress(self.coinType, privateKey: privKey, isTestnet: self.appWallet!.walletConfig.isTestnet) == getAddress()) {
            privateKey = privKey
            return true
        }
        return false
    }
    
    func clearPrivateKeyFromMemory() -> (){
        privateKey = nil
    }
    
    func getDefaultAddressLabel()-> (String?) {
        return importedAddress
    }
    
    func setHasFetchedAccountData(_ fetched:Bool) -> () {
        self.fetchedAccountData = fetched
        if fetched {
            self.downloadState = .downloaded
        }
        if self.fetchedAccountData == true && self.listeningToIncomingTransactions == false {
            self.listeningToIncomingTransactions = true
            let address = self.getAddress()
            TLTransactionListener.instance().listenToIncomingTransactionForAddress(self.coinType, address: address)
        }
    }
    
    func hasFetchedAccountData() -> (Bool){
        return self.fetchedAccountData
    }
    
    func getUnspentArray() -> Array<TLUnspentOutputObject> {
        return unspentOutputs
    }
    
    func getUnspentSum() -> (TLCoin?) {
        if (unspentOutputsSum != nil) {
            return unspentOutputsSum
        }
        
//        if (unspentOutputs == nil) {
//            return TLCoin.zero()
//        }
        
        var unspentOutputsSumTemp:UInt64 = 0
        for unspentOutput in unspentOutputs {
            unspentOutputsSumTemp += unspentOutput.value
        }
        
        
        unspentOutputsSum = TLCoin(uint64: unspentOutputsSumTemp)
        return unspentOutputsSum
    }

    func getInputsNeededToConsume(_ amountNeeded: TLCoin) -> Int {
        var valueSelected:UInt64 = 0
        var inputCount = 0
        for unspentOutput in unspentOutputs {
            valueSelected += unspentOutput.value
            inputCount += 1
            if valueSelected >= amountNeeded.toUInt64() {
                return inputCount
            }
        }
        return inputCount
    }
    
    func setUnspentOutputs(_ unspentOuts:Array<TLUnspentOutputObject>) {
        // https://stackoverflow.com/questions/27812433/how-do-i-make-a-exact-duplicate-copy-of-an-array
//        self.unspentOuts = unspentOuts.map { $0.copy() }
        self.unspentOutputs = unspentOuts
//        unspentOutputs = unspentOuts.copy() as? NSArray
    }
    
    func getBalance() -> (TLCoin?) {
        return self.balance
    }
    
    func isWatchOnly() -> (Bool) {
        return self.watchOnly
    }
    
    func setArchived(_ archived:Bool) -> () {
        self.archived = archived
    }
    
    func isArchived() -> (Bool) {
        return self.archived
    }
    
    func getPositionInWalletArray() -> Int {
        return positionInWalletArray ?? 0
    }
    
    func getPositionInWalletArrayNumber() -> (NSNumber) {
        return NSNumber(value: positionInWalletArray ?? 0 as Int)
    }
    
    
    func setPositionInWalletArray(_ idx: Int) -> () {
        positionInWalletArray = idx
    }
    
    func isPrivateKeyEncrypted() -> (Bool) {
        if (self.watchOnly) {
            return false
        }
        if (TLCoreBitcoinWrapper.isBIP38EncryptedKey(self.coinType, privateKey: addressDict!.object(forKey: "key") as! String, isTestnet: self.appWallet!.walletConfig.isTestnet)) {
            return true
        }
        return false
    }
    
    func getAddress() -> String {
        return addressDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
    }
    
    func getEitherPrivateKeyOrEncryptedPrivateKey() -> String? {
        if (self.watchOnly) {
            return privateKey
        } else {
            return addressDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_KEY) as? String
        }
    }
    
    func getPrivateKey() -> (String?) {
        if (self.watchOnly) {
            return privateKey
        }
        else if (isPrivateKeyEncrypted()) {
            return privateKey
        }
        else {
            return addressDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_KEY) as? String
        }
    }
    
    func getEncryptedPrivateKey() -> (String?) {
        if (isPrivateKeyEncrypted()) {
            return addressDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_KEY) as? String
        } else {
            return nil
        }
    }
    
    func getLabel() -> (String) {
        if (addressDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL) as? String == nil ||
            addressDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL) as! String == "") {
            return addressDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
        }
        else {
            return addressDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL) as! String
        }
    }
    
    func getTxObjectCount() -> (Int) {
        return txObjectArray!.count
    }
    
    func getTxObject(_ txIdx: Int) -> TLTxObject {
        return txObjectArray!.object(at: txIdx) as! TLTxObject
    }
    
    func getAccountAmountChangeForTx(_ txHash: String) -> TLCoin? {
        return txidToAccountAmountDict!.object(forKey: txHash) as? TLCoin
    }
    
    func getAccountAmountChangeTypeForTx(_ txHash:String) -> TLAccountTxType {
        return TLAccountTxType(rawValue: Int(txidToAccountAmountTypeDict!.object(forKey: txHash) as! Int))!
    }
    
    
    func processNewTx(_ txObject: TLTxObject) -> TLCoin? {
        if (processedTxSet!.contains(txObject.getHash())) {
            // happens when you send coins to the same account, so you get the same tx from the websockets more then once
            return nil
        }
        let doesTxInvolveAddressAndReceivedAmount = processTx(txObject, shouldUpdateAccountBalance: true)
        
        txObjectArray!.insert(txObject, at:0)
        return doesTxInvolveAddressAndReceivedAmount.1
    }
    
    func processTxArray(_ txArray: Array<TLTxObject>, shouldUpdateAccountBalance: Bool) -> (){
        resetAccountBalances()

        for txObject in txArray {
            let doesTxInvolveAddressAndReceivedAmount = processTx(txObject, shouldUpdateAccountBalance: shouldUpdateAccountBalance)
            if (doesTxInvolveAddressAndReceivedAmount.0) {
                txObjectArray!.add(txObject)
            }
        }
    }
    
    fileprivate func processTx(_ txObject: TLTxObject, shouldUpdateAccountBalance: Bool) -> (Bool, TLCoin?) {
        haveUpDatedUTXOs = false
        processedTxSet!.add(txObject.getHash())
        var currentTxSubtract:UInt64 = 0
        var currentTxAdd:UInt64 = 0
        var doesTxInvolveAddress = false
        let ouputAddressToValueArray = txObject.getOutputAddressToValueArray()
        for output in ouputAddressToValueArray as! [NSDictionary] {
            var value:UInt64 = 0;
            if let v = output.object(forKey: "value") as? NSNumber {
                value = UInt64(v.uint64Value)
            }
            let address = output.object(forKey: "addr") as? String
            if (address != nil && address == importedAddress) {
                currentTxAdd += value
                doesTxInvolveAddress = true
            }
        }
        
        let inputAddressToValueArray = txObject.getInputAddressToValueArray()
        for input in inputAddressToValueArray as! [NSDictionary] {
            var value:UInt64 = 0;
            if let v = input.object(forKey: "value") as? NSNumber {
                value = UInt64(v.uint64Value)
            }
            let address = input.object(forKey: "addr") as? String
            if (address != nil && address == importedAddress) {
                currentTxSubtract += value
                doesTxInvolveAddress = true
            }
            
        }
        
        if (shouldUpdateAccountBalance) {
            self.balance = TLCoin(uint64: self.balance.toUInt64() + currentTxAdd - currentTxSubtract)
        }

        let receivedAmount:TLCoin?
        if (currentTxSubtract > currentTxAdd) {
            let amountChangeToAccountFromTx = TLCoin(uint64:currentTxSubtract - currentTxAdd)
            txidToAccountAmountDict!.setObject(amountChangeToAccountFromTx, forKey:txObject.getHash() as NSCopying)
            txidToAccountAmountTypeDict!.setObject(TLAccountTxType.send.rawValue, forKey:txObject.getHash() as NSCopying)
            receivedAmount = nil
        } else if (currentTxSubtract < currentTxAdd) {
            let amountChangeToAccountFromTx = TLCoin(uint64:currentTxAdd - currentTxSubtract)
            txidToAccountAmountDict!.setObject(amountChangeToAccountFromTx, forKey:txObject.getHash() as NSCopying)
            txidToAccountAmountTypeDict!.setObject(TLAccountTxType.receive.rawValue, forKey:txObject.getHash() as NSCopying)
            receivedAmount = amountChangeToAccountFromTx
        } else {
            let amountChangeToAccountFromTx = TLCoin.zero()
            txidToAccountAmountDict!.setObject(amountChangeToAccountFromTx, forKey:txObject.getHash() as NSCopying)
            txidToAccountAmountTypeDict!.setObject(TLAccountTxType.moveBetweenAccount.rawValue, forKey:txObject.getHash() as NSCopying)
            receivedAmount = nil
        }
        
        return (doesTxInvolveAddress, receivedAmount)
    }
    
    func getSingleAddressData(_ success: @escaping TLWalletUtils.Success, failure:@escaping TLWalletUtils.Error) -> () {
        TLBlockExplorerAPI.instance().getAddressesInfo(self.coinType, addressArray: [importedAddress!], success:{(addressesObject) in
            
            for addressObject in addressesObject.addresses {
                self.balance = TLCoin(uint64: addressObject.finalBalance)
                self.processTxArray(addressesObject.txs, shouldUpdateAccountBalance: false)
            }
            
            self.setHasFetchedAccountData(true)
            DLog("postNotificationName: EVENT_FETCHED_ADDRESSES_DATA \(self.getAddress())")
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA())
                ,object:self.importedAddress, userInfo:nil)
            
            success()
            }, failure: {(code, status) in
                failure()
            }
        )
    }
    
    func getSingleAddressDataO(_ fetchDataAgain:Bool) -> () {
        if self.fetchedAccountData == true && !fetchDataAgain {
            self.downloadState = .downloaded
            return
        }
        
        do {
            let addressesObject = try TLBlockExplorerAPI.instance().getAddressesInfoSynchronous(self.coinType, addressArray: [importedAddress!])
            for addressObject in addressesObject.addresses {
                self.balance = TLCoin(uint64: addressObject.finalBalance)
                self.processTxArray(addressesObject.txs, shouldUpdateAccountBalance: false)
            }
            self.setHasFetchedAccountData(true)
            DispatchQueue.main.async(execute: {
                DLog("postNotificationName: EVENT_FETCHED_ADDRESSES_DATA \(self.getAddress())")
                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA())
                    ,object:self.importedAddress, userInfo:nil)
            })
        } catch TLNetworkingError.NetworkError(let code, let message) {
            DLog("getAccountDataSynchronous error \(code) \(message)")
            NSException(name: NSExceptionName(rawValue: "Network Error"), reason: "HTTP Error", userInfo: nil).raise()
        } catch { //TODO why do i need this, xcode gives error that above catch is not exhastive, need to look into
            NSException(name: NSExceptionName(rawValue: "Network Error"), reason: "HTTP Error", userInfo: nil).raise()
        }
    }
    
    func setLabel(_ label:NSString) -> (){
        addressDict!.setObject(label, forKey:TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL as NSCopying)
    }
    
    fileprivate func resetAccountBalances() -> () {
        txObjectArray = NSMutableArray()
        txidToAccountAmountDict = NSMutableDictionary()
        txidToAccountAmountTypeDict = NSMutableDictionary()
    }
}
