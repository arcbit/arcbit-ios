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
    
    private var appWallet:TLWallet?
    private var addressDict:NSMutableDictionary?
    lazy var haveUpDatedUTXOs: Bool = false
    lazy var unspentOutputsCount: Int = 0
    private var unspentOutputs:NSArray?
    private var unspentOutputsSum:TLCoin?
    var balance = TLCoin.zero()
    private var fetchedAccountData = false
    var listeningToIncomingTransactions = false
    private var watchOnly = false
    private var archived = false
    private var positionInWalletArray:Int?
    private var txObjectArray:NSMutableArray?
    private var txidToAccountAmountDict:NSMutableDictionary?
    private var txidToAccountAmountTypeDict:NSMutableDictionary?
    private var processedTxSet:NSMutableSet?
    private var privateKey:String?
    private var importedAddress:String?
    var downloadState:TLDownloadState = .NotDownloading

    init(appWallet: TLWallet, dict:NSDictionary) {
        super.init()
        self.appWallet = appWallet
        addressDict = NSMutableDictionary(dictionary:dict)
        importedAddress = addressDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String?
        unspentOutputs = NSMutableArray()
        processedTxSet = NSMutableSet()
        if (addressDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_KEY) != nil) {
            self.watchOnly = false
        } else {
            self.watchOnly = true
        }
        
        self.archived = addressDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS) as! Int == TLAddressStatus.Archived.rawValue
        resetAccountBalances()
    }
    
    func hasSetPrivateKeyInMemory() -> (Bool) {
        return privateKey != nil
    }
    
    func setPrivateKeyInMemory(privKey:String) -> (Bool) {
        if (TLCoreBitcoinWrapper.getAddress(privKey, isTestnet: self.appWallet!.walletConfig.isTestnet) == getAddress()) {
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
    
    func setHasFetchedAccountData(fetched:Bool) -> () {
        self.fetchedAccountData = fetched
        if fetched {
            self.downloadState = .Downloaded
        }
        if self.fetchedAccountData == true && self.listeningToIncomingTransactions == false {
            self.listeningToIncomingTransactions = true
            let address = self.getAddress()
            TLTransactionListener.instance().listenToIncomingTransactionForAddress(address)
        }
    }
    
    func hasFetchedAccountData() -> (Bool){
        return self.fetchedAccountData
    }
    
    func getUnspentArray() -> (NSArray?) {
        return unspentOutputs
    }
    
    func getUnspentSum() -> (TLCoin?) {
        if (unspentOutputsSum != nil) {
            return unspentOutputsSum
        }
        
        if (unspentOutputs == nil) {
            return TLCoin.zero()
        }
        
        var unspentOutputsSumTemp:UInt64 = 0
        for unspentOutput in unspentOutputs as! [NSDictionary] {
            let amount = unspentOutput.objectForKey("value") as! UInt
            unspentOutputsSumTemp += UInt64(amount)
        }
        
        
        unspentOutputsSum = TLCoin(uint64: unspentOutputsSumTemp)
        return unspentOutputsSum
    }
    
    func setUnspentOutputs(unspentOuts:NSArray)-> () {
        unspentOutputs = unspentOuts.copy() as? NSArray
    }
    
    func getBalance() -> (TLCoin?) {
        return self.balance
    }
    
    func isWatchOnly() -> (Bool) {
        return self.watchOnly
    }
    
    func setArchived(archived:Bool) -> () {
        self.archived = archived
    }
    
    func isArchived() -> (Bool) {
        return self.archived
    }
    
    func getPositionInWalletArray() -> Int {
        return positionInWalletArray ?? 0
    }
    
    func getPositionInWalletArrayNumber() -> (NSNumber) {
        return NSNumber(integer: positionInWalletArray ?? 0)
    }
    
    
    func setPositionInWalletArray(idx: Int) -> () {
        positionInWalletArray = idx
    }
    
    func isPrivateKeyEncrypted() -> (Bool) {
        if (self.watchOnly) {
            return false
        }
        if (TLCoreBitcoinWrapper.isBIP38EncryptedKey(addressDict!.objectForKey("key") as! String, isTestnet: self.appWallet!.walletConfig.isTestnet)) {
            return true
        }
        return false
    }
    
    func getAddress() -> String {
        return addressDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
    }
    
    func getEitherPrivateKeyOrEncryptedPrivateKey() -> String? {
        if (self.watchOnly) {
            return privateKey
        } else {
            return addressDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_KEY) as? String
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
            return addressDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_KEY) as? String
        }
    }
    
    func getEncryptedPrivateKey() -> (String?) {
        if (isPrivateKeyEncrypted()) {
            return addressDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_KEY) as? String
        } else {
            return nil
        }
    }
    
    func getLabel() -> (String) {
        if (addressDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL) as? String == nil ||
            addressDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL) as! String == "") {
            return addressDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
        }
        else {
            return addressDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL) as! String
        }
    }
    
    func getTxObjectCount() -> (Int) {
        return txObjectArray!.count
    }
    
    func getTxObject(txIdx: Int) -> TLTxObject {
        return txObjectArray!.objectAtIndex(txIdx) as! TLTxObject
    }
    
    func getAccountAmountChangeForTx(txHash: String) -> TLCoin? {
        return txidToAccountAmountDict!.objectForKey(txHash) as? TLCoin
    }
    
    func getAccountAmountChangeTypeForTx(txHash:String) -> TLAccountTxType {
        return TLAccountTxType(rawValue: Int(txidToAccountAmountTypeDict!.objectForKey(txHash) as! Int))!
    }
    
    
    func processNewTx(txObject: TLTxObject) -> TLCoin? {
        if (processedTxSet!.containsObject(txObject.getHash()!)) {
            // happens when you send coins to the same account, so you get the same tx from the websockets more then once
            return nil
        }
        let doesTxInvolveAddressAndReceivedAmount = processTx(txObject, shouldUpdateAccountBalance: true)
        
        txObjectArray!.insertObject(txObject, atIndex:0)
        return doesTxInvolveAddressAndReceivedAmount.1
    }
    
    func processTxArray(txArray: NSArray, shouldUpdateAccountBalance: Bool) -> (){
        resetAccountBalances()

        for tx in txArray as! [NSDictionary] {
            let txObject = TLTxObject(dict:tx)
            let doesTxInvolveAddressAndReceivedAmount = processTx(txObject, shouldUpdateAccountBalance: shouldUpdateAccountBalance)
            if (doesTxInvolveAddressAndReceivedAmount.0) {
                txObjectArray!.addObject(txObject)
            }
        }
    }
    
    private func processTx(txObject: TLTxObject, shouldUpdateAccountBalance: Bool) -> (Bool, TLCoin?) {
        haveUpDatedUTXOs = false
        processedTxSet!.addObject(txObject.getHash()!)
        var currentTxSubtract:UInt64 = 0
        var currentTxAdd:UInt64 = 0
        var doesTxInvolveAddress = false
        let ouputAddressToValueArray = txObject.getOutputAddressToValueArray()
        for output in ouputAddressToValueArray as! [NSDictionary] {
            var value:UInt64 = 0;
            if let v = output.objectForKey("value") as? NSNumber {
                value = UInt64(v.unsignedLongLongValue)
            }
            let address = output.objectForKey("addr") as? String
            if (address != nil && address == importedAddress) {
                currentTxAdd += value
                doesTxInvolveAddress = true
            }
        }
        
        let inputAddressToValueArray = txObject.getInputAddressToValueArray()
        for input in inputAddressToValueArray as! [NSDictionary] {
            var value:UInt64 = 0;
            if let v = input.objectForKey("value") as? NSNumber {
                value = UInt64(v.unsignedLongLongValue)
            }
            let address = input.objectForKey("addr") as? String
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
            txidToAccountAmountDict!.setObject(amountChangeToAccountFromTx, forKey:txObject.getHash()!)
            txidToAccountAmountTypeDict!.setObject(TLAccountTxType.Send.rawValue, forKey:txObject.getHash()!)
            receivedAmount = nil
        } else if (currentTxSubtract < currentTxAdd) {
            let amountChangeToAccountFromTx = TLCoin(uint64:currentTxAdd - currentTxSubtract)
            txidToAccountAmountDict!.setObject(amountChangeToAccountFromTx, forKey:txObject.getHash()!)
            txidToAccountAmountTypeDict!.setObject(TLAccountTxType.Receive.rawValue, forKey:txObject.getHash()!)
            receivedAmount = amountChangeToAccountFromTx
        } else {
            let amountChangeToAccountFromTx = TLCoin.zero()
            txidToAccountAmountDict!.setObject(amountChangeToAccountFromTx, forKey:txObject.getHash()!)
            txidToAccountAmountTypeDict!.setObject(TLAccountTxType.MoveBetweenAccount.rawValue, forKey:txObject.getHash()!)
            receivedAmount = nil
        }
        
        return (doesTxInvolveAddress, receivedAmount)
    }
    
    func getSingleAddressData(success: TLWalletUtils.Success, failure:TLWalletUtils.Error) -> () {
        TLBlockExplorerAPI.instance().getAddressesInfo([importedAddress!], success:{(jsonData:AnyObject!) in
            
            let addressesArray = jsonData.objectForKey("addresses") as! NSArray
            for addressDict in addressesArray {
                let addressBalance = (addressDict.objectForKey("final_balance") as! NSNumber).unsignedLongLongValue
                self.balance = TLCoin(uint64: addressBalance)

                self.processTxArray((jsonData as! NSDictionary!).objectForKey("txs") as! NSArray, shouldUpdateAccountBalance: false)
            }
            
            self.setHasFetchedAccountData(true)
            DLog("postNotificationName: EVENT_FETCHED_ADDRESSES_DATA \(self.getAddress())")
            NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA()
                ,object:self.importedAddress, userInfo:nil)
            
            success()
            }, failure: {(code:Int, status:String!) in
                failure()
            }
        )
    }
    
    func getSingleAddressDataO(fetchDataAgain:Bool) -> () {
        if self.fetchedAccountData == true && !fetchDataAgain {
            self.downloadState = .Downloaded
            return
        }
        
        let jsonData = TLBlockExplorerAPI.instance().getAddressesInfoSynchronous([importedAddress!])
        let addressesArray = jsonData.objectForKey("addresses") as! NSArray
        for addressDict in addressesArray {
            let addressBalance = (addressDict.objectForKey("final_balance") as! NSNumber).unsignedLongLongValue
            self.balance = TLCoin(uint64: addressBalance)
            self.processTxArray(jsonData.objectForKey("txs") as! NSArray, shouldUpdateAccountBalance: false)
        }
        
        self.setHasFetchedAccountData(true)
        dispatch_async(dispatch_get_main_queue(), {
            DLog("postNotificationName: EVENT_FETCHED_ADDRESSES_DATA \(self.getAddress())")
            NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA()
                ,object:self.importedAddress, userInfo:nil)
        })
    }
    
    func setLabel(label:NSString) -> (){
        addressDict!.setObject(label, forKey:TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL)
    }
    
    private func resetAccountBalances() -> () {
        txObjectArray = NSMutableArray()
        txidToAccountAmountDict = NSMutableDictionary()
        txidToAccountAmountTypeDict = NSMutableDictionary()
    }
}
