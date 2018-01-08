//
//  TLAccountObject.swift
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

@objc class TLAccountObject: NSObject {
    
    let ACCOUNT_UNUSED_ACTIVE_MAIN_ADDRESS_AHEAD_OF_LATEST_USED_ONE_MINIMUM_COUNT = 5
    let ACCOUNT_UNUSED_ACTIVE_CHANGE_ADDRESS_AHEAD_OF_LATEST_USED_ONE_MINIMUM_COUNT = 5
    let GAP_LIMIT = 20
    let MAX_ACTIVE_MAIN_ADDRESS_TO_HAVE = 55
    let MAX_ACTIVE_CHANGE_ADDRESS_TO_HAVE = 55
    let EXTENDED_KEY_DEFAULT_ACCOUNT_NAME_LENGTH = 50
    let MAX_CONSOLIDATE_STEALTH_PAYMENT_UTXOS_COUNT:Int = 12

    var appWallet:TLWallet?
    fileprivate var accountDict: NSMutableDictionary?
    lazy var haveUpDatedUTXOs: Bool = false
    lazy var unspentOutputsCount: Int = 0
    lazy var stealthPaymentUnspentOutputsCount: Int = 0
    var unspentOutputs: NSMutableArray?
    var stealthPaymentUnspentOutputs: NSMutableArray?
    fileprivate var mainActiveAddresses = [String]()
    fileprivate var changeActiveAddresses = [String]()
    fileprivate var activeAddressesDict = [String:Bool]()
    fileprivate var mainArchivedAddresses = [String]()
    fileprivate var changeArchivedAddresses = [String]()
    fileprivate var address2BalanceDict = [String:TLCoin]()
    fileprivate var address2HDIndexDict = [String:Int]()
    fileprivate var address2IsMainAddress = [String:Bool]()
    fileprivate var address2NumberOfTransactions = [String:Int]()
    fileprivate var HDIndexToArchivedMainAddress = [Int:String]()
    fileprivate var HDIndexToArchivedChangeAddress = [Int:String]()
    fileprivate var txObjectArray = [TLTxObject]()
    fileprivate var txidToAccountAmountDict = [String:TLCoin]()
    fileprivate var txidToAccountAmountTypeDict = [String:Int]()
    fileprivate var receivingAddressesArray = [String]()
    fileprivate var processedTxSet:NSMutableSet = NSMutableSet()
    var coinType:TLCoinType = TLCoinType.BTC
    fileprivate var accountType: TLAccountType?
    var accountBalance = TLCoin.zero()
    fileprivate var totalUnspentOutputsSum: TLCoin?
    fileprivate var fetchedAccountData = false
    var listeningToIncomingTransactions = false
    fileprivate var positionInWalletArray = 0
    fileprivate var extendedPrivateKey: String?
    var stealthWallet: TLStealthWallet?
    var downloadState:TLDownloadState = .notDownloading

    class func MAX_ACCOUNT_WAIT_TO_RECEIVE_ADDRESS() -> (Int) {
        return 5
    }
    
    class func NUM_ACCOUNT_STEALTH_ADDRESSES() -> (Int) {
        return 1
    }
    
    fileprivate func setUpActiveMainAddresses() -> () {
        mainActiveAddresses = [String]()
        let addressesArray = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES) as! NSMutableArray
        let minAddressIdx = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX) as! Int
        
        let startIdx: Int
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            startIdx = minAddressIdx
        } else {
            startIdx = 0
        }
        for i in stride(from: startIdx, to: addressesArray.count, by: 1) {
            let addressDict = addressesArray.object(at: i) as! NSDictionary
            let HDIndex = addressDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX) as! Int
            let address = addressDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
            address2HDIndexDict[address] = HDIndex
            address2IsMainAddress[address] = true
            address2BalanceDict[address] = TLCoin.zero()
            address2NumberOfTransactions[address] = 0
            mainActiveAddresses.append(address)
            activeAddressesDict[address] = true
        }
    }
    
    fileprivate func setUpActiveChangeAddresses() -> () {
        changeActiveAddresses = [String]()
        
        let addressesArray = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES) as! NSMutableArray
        let minAddressIdx = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX) as! Int
        
        var startIdx = 0
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            startIdx = minAddressIdx
        } else {
            startIdx = 0
        }
        for i in stride(from: startIdx, to: addressesArray.count, by: 1) {
            let addressDict = addressesArray.object(at: i) as! NSDictionary
            let HDIndex = addressDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX) as! Int
            let address = addressDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
            address2HDIndexDict[address] = HDIndex
            address2IsMainAddress[address] = false
            address2BalanceDict[address] = TLCoin.zero()
            address2NumberOfTransactions[address] = 0
            changeActiveAddresses.append(address)
            activeAddressesDict[address] = true
        }
    }
    
    fileprivate func setUpArchivedMainAddresses() -> () {
        mainArchivedAddresses = [String]()
        
        let addressesArray = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES) as! NSMutableArray
        let maxAddressIdx = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX) as! Int// - 1
        
        for i in stride(from: 0, to: maxAddressIdx, by: 1) {
            let addressDict = addressesArray.object(at: i) as! NSDictionary
            assert(addressDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS) as! Int == Int(TLAddressStatus.archived.rawValue), "")
            let HDIndex = addressDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX) as! Int
            
            let address = addressDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
            
            address2HDIndexDict[address] = HDIndex
            address2IsMainAddress[address] = true

            address2BalanceDict[address] = TLCoin.zero()
            address2NumberOfTransactions[address] = 0
            mainArchivedAddresses.append(address)
        }
    }
    
    fileprivate func setUpArchivedChangeAddresses() -> () {
        changeArchivedAddresses = [String]()
        
        let addressesArray = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES) as! NSMutableArray
        let maxAddressIdx = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX) as! Int// - 1
        
        for i in stride(from: 0, to: maxAddressIdx, by: 1) {
            let addressDict = addressesArray.object(at: i) as! NSDictionary
            let HDIndex = addressDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX) as! Int
            
            let address = addressDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
            assert((addressDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS) as! Int) == Int(TLAddressStatus.archived.rawValue), "")
            address2HDIndexDict[address] = HDIndex
            address2IsMainAddress[address] = false
            address2BalanceDict[address] = TLCoin.zero()
            address2NumberOfTransactions[address] = 0
            changeArchivedAddresses.append(address)
        }
    }
    
    init(appWallet: TLWallet, coinType: TLCoinType, dict: NSDictionary, accountType at: TLAccountType) {
        super.init()
        self.appWallet = appWallet
        self.coinType = coinType
        accountType = at
        accountDict = NSMutableDictionary(dictionary: dict)
        unspentOutputs = nil
        totalUnspentOutputsSum = nil
        extendedPrivateKey = nil
        
        txidToAccountAmountTypeDict = [String:Int]()
        address2BalanceDict = [String:TLCoin]()
        
        setUpActiveMainAddresses()
        setUpActiveChangeAddresses()
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            setUpArchivedMainAddresses()
            setUpArchivedChangeAddresses()
        } else {
            HDIndexToArchivedMainAddress = [Int:String]()
            HDIndexToArchivedChangeAddress = [Int:String]()
        }
        DLog("\(self.getAccountIdxNumber()) getMainActiveAddressesCount \(self.getMainActiveAddressesCount())")
        DLog("\(self.getAccountIdxNumber()) getMainAddressesCount \(self.getMainAddressesCount())")
        DLog("\(self.getAccountIdxNumber()) getChangeActiveAddressesCount \(self.getChangeActiveAddressesCount())")
        DLog("\(self.getAccountIdxNumber()) getChangeAddressesCount \(self.getChangeAddressesCount())")

        
        if (accountType == TLAccountType.hdWallet) {
            positionInWalletArray = getAccountIdxNumber()
        } else if (accountType == TLAccountType.coldWallet) {
            //set later in accounts
        } else if (accountType == TLAccountType.imported) {
            //set later in accounts
        } else if (accountType == TLAccountType.importedWatch) {
            //set later in accounts
        }
        
        if TLWalletUtils.ALLOW_MANUAL_SCAN_FOR_STEALTH_PAYMENT() && accountType != TLAccountType.importedWatch && accountType != TLAccountType.coldWallet {
            let stealthAddressArray = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES) as! NSArray
            let stealthWalletDict = stealthAddressArray.object(at: 0) as! NSDictionary
            self.stealthWallet = TLStealthWallet(stealthDict: stealthWalletDict, accountObject: self,
                updateStealthPaymentStatuses: !self.isArchived())
            
            
            //add default zero balance so that if user goes to address list view before account data downloaded,
            // then accountObject will return a 0 balance for payment address instead of getting optional unwrap nil error
            for i in 0 ..< self.stealthWallet!.getStealthAddressPaymentsCount() {
                let address = self.stealthWallet!.getPaymentAddressForIndex(i)
                address2BalanceDict[address] = TLCoin.zero()
            }
        }
    }
    
    func isWatchOnly() -> (Bool) {
        return accountType == TLAccountType.importedWatch
    }
    
    func isColdWalletAccount() -> (Bool) {
        return accountType == TLAccountType.coldWallet
    }
    
    func hasSetExtendedPrivateKeyInMemory() -> (Bool) {
        assert(accountType == TLAccountType.importedWatch, "")
        return extendedPrivateKey != nil
    }
    
    func setExtendedPrivateKeyInMemory(_ extendedPrivKey: String) -> Bool {
        assert(accountType == TLAccountType.importedWatch, "")
        assert(TLHDWalletWrapper.isValidExtendedPrivateKey(extendedPrivKey), "extendedPrivKey isValidExtendedPrivateKey")
        
        if (TLHDWalletWrapper.getExtendPubKey(extendedPrivKey) == getExtendedPubKey()) {
            extendedPrivateKey = extendedPrivKey
            return true
        }
        return false
    }
    
    func clearExtendedPrivateKeyFromMemory() -> () {
        assert(accountType == TLAccountType.importedWatch, "")
        extendedPrivateKey = nil
    }
    
    
    func hasFetchedAccountData() -> (Bool) {
        return self.fetchedAccountData
    }
    
    @discardableResult func renameAccount(_ accountName: String) -> (Bool) {
        accountDict!.setObject(accountName, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME as NSCopying)
        return true
    }
    
    func getAccountName() -> String {
        return accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME) as! String
    }
    
    func getAccountNameOrAccountPublicKey() -> String {
        let accountName = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME) as! String
        return accountName != "" ? accountName : getExtendedPubKey()
    }
    
    func archiveAccount(_ enabled: Bool) -> (Bool) {
        let status = enabled ? TLAddressStatus.archived : TLAddressStatus.active
        accountDict!.setObject(status.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS as NSCopying)
        return true
    }
    
    func isArchived() -> (Bool) {
        return (accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS) as! Int) == Int(TLAddressStatus.archived.rawValue)
    }
    
    func getAccountID() -> (String) {
        let accountIdx = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
        return String(accountIdx)
    }
    
    func getAccountIdxNumber() -> (Int) {
        return accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
    }
    
    func getAccountHDIndex() -> UInt32 {
        return TLHDWalletWrapper.getAccountIdxForExtendedKey(getExtendedPubKey()) as UInt32
    }
    
    func getExtendedPubKey() -> String {
        return accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY) as! String
    }
    
    func getExtendedPrivKey() -> String? {
        if (accountType == TLAccountType.hdWallet) {
            return accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PRIVATE_KEY) as? String
        } else if (accountType == TLAccountType.imported) {
            return accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PRIVATE_KEY) as? String
        } else if (accountType == TLAccountType.importedWatch) {
            return extendedPrivateKey
        }
        return nil
    }
    
    func getAddressBalance(_ address: String) -> TLCoin {
        if let amount = address2BalanceDict[address] {
            return amount
        } else {
            return TLCoin.zero()
        }
    }
    
    func getNumberOfTransactionsForAddress(_ address: String) -> Int {
        assert(self.isHDWalletAddress(address))
        if address2NumberOfTransactions[address] == nil {
            return 0;
        }
        return address2NumberOfTransactions[address]!
    }
    
    func isMainAddress(_ address: String) -> Bool {
        return address2IsMainAddress[address]!
    }
    
    func getAddressHDIndex(_ address: String) -> Int {
        return address2HDIndexDict[address]!
    }
    
    func getAccountPrivateKey(_ address: String) -> String? {
        if self.isHDWalletAddress(address) {
            if (address2IsMainAddress[address] == true) {
                return getMainPrivateKey(address)
            } else {
                return getChangePrivateKey(address)
            }
        }
        
        return nil
    }
    
    func getMainPrivateKey(_ address: String) -> String {
        let HDIndexNumber = address2HDIndexDict[address]!
        let addressSequence = [Int(TLAddressType.main.rawValue), HDIndexNumber]
        if (accountType == TLAccountType.importedWatch) {
            assert(extendedPrivateKey != nil, "")
            return TLHDWalletWrapper.getPrivateKey(extendedPrivateKey! as! NSString, sequence: addressSequence as NSArray, isTestnet: self.appWallet!.walletConfig.isTestnet)
        } else {
            return TLHDWalletWrapper.getPrivateKey(accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PRIVATE_KEY) as! NSString, sequence: addressSequence as NSArray, isTestnet: self.appWallet!.walletConfig.isTestnet)
        }
    }
    
    func getChangePrivateKey(_ address: String) -> String {
        let HDIndexNumber = address2HDIndexDict[address]!
        let addressSequence = [TLAddressType.change.rawValue, HDIndexNumber]
        if (accountType == TLAccountType.importedWatch) {
            assert(extendedPrivateKey != nil, "")
            return TLHDWalletWrapper.getPrivateKey(extendedPrivateKey! as NSString, sequence: addressSequence as NSArray, isTestnet: self.appWallet!.walletConfig.isTestnet)
        } else {
            return TLHDWalletWrapper.getPrivateKey(accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PRIVATE_KEY) as! NSString, sequence: addressSequence as NSArray, isTestnet: self.appWallet!.walletConfig.isTestnet)
        }
    }
    
    func getTxObjectCount() -> Int {
        return txObjectArray.count
    }
    
    func getTxObject(_ txIdx: Int) -> TLTxObject {
        return txObjectArray[txIdx]
    }
    
    fileprivate func isAddressPartOfAccountActiveChangeAddresses(_ address: String) -> (Bool) {
        return changeActiveAddresses.index(of: address) != nil
    }
    
    fileprivate func isAddressPartOfAccountActiveMainAddresses(_ address: String) -> Bool {
        return mainActiveAddresses.index(of: address) != nil
    }
    
    func isActiveAddress(_ address: String) -> Bool {
        return activeAddressesDict[address] != nil
    }
    
    func isHDWalletAddress(_ address: String) -> Bool {
        return address2HDIndexDict[address] != nil
    }
    
    func isAddressPartOfAccount(_ address: String) -> Bool {
        if  self.stealthWallet == nil {
            return self.isHDWalletAddress(address)
        } else {
            return self.isHDWalletAddress(address) || self.stealthWallet!.isPaymentAddress(address)            
        }
    }
    
    func getBalance() -> TLCoin {
        return self.accountBalance
    }
    
    func getAccountType() -> TLAccountType {
        return accountType!
    }
    
    func getAccountAmountChangeForTx(_ txHash: String) -> TLCoin? {
        return txidToAccountAmountDict[txHash]
    }
    
    func getAccountAmountChangeTypeForTx(_ txHash: String) -> TLAccountTxType {
        return TLAccountTxType(rawValue: txidToAccountAmountTypeDict[txHash]!)!
    }
    
    fileprivate func addToAddressBalance(_ address: NSString, amount: TLCoin) -> () {
        var addressBalance = address2BalanceDict[address as String]
        if (addressBalance == nil) {
            addressBalance = amount
            address2BalanceDict[address as String] = addressBalance!
        } else {
            addressBalance! = addressBalance!.add(amount)
            address2BalanceDict[address as String] = addressBalance!
        }
    }
    
    fileprivate func subtractToAddressBalance(_ address: String, amount: TLCoin) -> () {
        var addressBalance = address2BalanceDict[address]
        if (addressBalance == nil) {
            addressBalance = TLCoin.zero().subtract(amount)
            address2BalanceDict[address] = addressBalance!
        } else {
            addressBalance = addressBalance!.subtract(amount)
            address2BalanceDict[address] = addressBalance!
        }
    }
    
    func processNewTx(_ txObject: TLTxObject) -> TLCoin? {
        if (processedTxSet.contains(txObject.getHash()!)) {
            return nil
        }
        
        let receivedAmount = processTx(txObject, shouldCheckToAddressesNTxsCount: true, shouldUpdateAccountBalance: true)
        
        
        txObjectArray.insert(txObject, at: 0)
        
        checkToArchiveAddresses()
        updateReceivingAddresses()
        updateChangeAddresses()
        return receivedAmount
    }
    
    fileprivate func processTx(_ txObject: TLTxObject, shouldCheckToAddressesNTxsCount: Bool, shouldUpdateAccountBalance: Bool) -> TLCoin? {
        haveUpDatedUTXOs = false
        processedTxSet.add(txObject.getHash()!)
        var currentTxSubtract:UInt64 = 0
        var currentTxAdd:UInt64 = 0
        
        let address2hasUpdatedNTxCount = NSMutableDictionary()
        
//        DLog("TLAccountObject processTx: \(self.getAccountID()) \(txObject.getTxid()!)")
    
        let outputAddressToValueArray = txObject.getOutputAddressToValueArray()

        for _output in outputAddressToValueArray! {
            let output = _output as! NSDictionary
            
            var value:UInt64 = 0
            if let v = output.object(forKey: "value") as? NSNumber {
                value = UInt64(v.uint64Value)
            }
            
            if let address = output.object(forKey: "addr") as? String {
                
                if (isActiveAddress(address)) {
                    
                    currentTxAdd += value
                    //DLog("addToAddressBalance: \(address) \(value)")
                    if (shouldUpdateAccountBalance) {
                        addToAddressBalance(address as NSString, amount: TLCoin(uint64: value))
                    }
                    
                    if (shouldCheckToAddressesNTxsCount &&
                        address2hasUpdatedNTxCount.object(forKey: address) == nil) {
                            
                            address2hasUpdatedNTxCount.setObject("", forKey: address as NSCopying)
                            
                            let ntxs = getNumberOfTransactionsForAddress(address)
                            address2NumberOfTransactions[address] = ntxs + 1
                    }
                } else if self.stealthWallet != nil && self.stealthWallet!.isPaymentAddress(address) {
                    currentTxAdd += value
                    //DLog("addToAddressBalance: stealth \(address) \(value)")
                    if shouldUpdateAccountBalance {
                        addToAddressBalance(address as NSString, amount: TLCoin(uint64: value))
                    }
                } else {
                }
            }
        }
        
        let inputAddressToValueArray = txObject.getInputAddressToValueArray()
        for _input in inputAddressToValueArray! {
            let input = _input as! NSDictionary
            
            var value:UInt64 = 0
            if let v = input.object(forKey: "value") as? NSNumber {
                value = UInt64(v.uint64Value)
            }

            if let address = input.object(forKey: "addr") as? String {

                if (isActiveAddress(address)) {
                        
                    currentTxSubtract += value
                    //DLog("subtractToAddressBalance: \(address) \(value)")
                    if (shouldUpdateAccountBalance) {
                        subtractToAddressBalance(address, amount: TLCoin(uint64: value))
                    }
                    
                    if (shouldCheckToAddressesNTxsCount &&
                        address2hasUpdatedNTxCount.object(forKey: address) == nil) {
                            
                            address2hasUpdatedNTxCount.setObject("", forKey: address as NSCopying)
                            let ntxs = getNumberOfTransactionsForAddress(address)
                            address2NumberOfTransactions[address] = ntxs + 1
                    }
                } else if self.stealthWallet != nil && self.stealthWallet!.isPaymentAddress(address) {
                    currentTxSubtract += value
                    //DLog("subtractToAddressBalance: stealth \(address) \(value)")
                    if shouldUpdateAccountBalance {
                        subtractToAddressBalance(address, amount: TLCoin(uint64: value))
                    }
                } else {
                }
            }
        }
        
        //DLog("current processTxprocessTx \(self.accountBalance.toUInt64()) + \(currentTxAdd) - \(currentTxSubtract)")
        if (shouldUpdateAccountBalance) {
            self.accountBalance = TLCoin(uint64: self.accountBalance.toUInt64() + currentTxAdd - currentTxSubtract)
        }
        
        if (currentTxSubtract > currentTxAdd) {
            let amountChangeToAccountFromTx = TLCoin(uint64: UInt64(currentTxSubtract - currentTxAdd))
            txidToAccountAmountDict[txObject.getHash()! as String] = amountChangeToAccountFromTx
            txidToAccountAmountTypeDict[txObject.getHash()! as String] = Int(TLAccountTxType.send.rawValue)
            return nil
        } else if (currentTxSubtract < currentTxAdd) {
            let amountChangeToAccountFromTx = TLCoin(uint64: UInt64(currentTxAdd - currentTxSubtract))
            txidToAccountAmountDict[txObject.getHash()! as String] = amountChangeToAccountFromTx
            txidToAccountAmountTypeDict[txObject.getHash()! as String] = Int(TLAccountTxType.receive.rawValue)
            return amountChangeToAccountFromTx
        } else {
            let amountChangeToAccountFromTx = TLCoin.zero()
            txidToAccountAmountDict[txObject.getHash()! as String] = amountChangeToAccountFromTx
            txidToAccountAmountTypeDict[txObject.getHash()! as String] = Int(TLAccountTxType.moveBetweenAccount.rawValue)
            return nil
        }
    }
    
    func getReceivingAddressesCount() -> Int {
        return receivingAddressesArray.count
    }
    
    func getReceivingAddress(_ idx: Int) -> (String) {
        return receivingAddressesArray[idx]
    }
    
    fileprivate func updateReceivingAddresses() -> () {
        receivingAddressesArray = [String]()
        
        var addressIdx = 0
        while addressIdx < mainActiveAddresses.count {
            let address = mainActiveAddresses[addressIdx]
            if (getNumberOfTransactionsForAddress(address) == 0) {
                break
            }
            addressIdx += 1
        }
        
        var lookedAtAllAddresses = false
        var receivingAddressesStartIdx = -1
        while addressIdx < addressIdx + TLAccountObject.MAX_ACCOUNT_WAIT_TO_RECEIVE_ADDRESS() {
            if (addressIdx >= getMainActiveAddressesCount()) {
                lookedAtAllAddresses = true
                break
            }
            let address = mainActiveAddresses[addressIdx]
            if (getNumberOfTransactionsForAddress(address) == 0) {
                receivingAddressesArray.append(address)
                if receivingAddressesStartIdx == -1 {
                    receivingAddressesStartIdx = addressIdx
                }
            }
            if (receivingAddressesArray.count >= TLAccountObject.MAX_ACCOUNT_WAIT_TO_RECEIVE_ADDRESS() ||
                addressIdx - receivingAddressesStartIdx >= TLAccountObject.MAX_ACCOUNT_WAIT_TO_RECEIVE_ADDRESS()) {
                    break
            }
            addressIdx += 1
        }
        
        while (lookedAtAllAddresses && receivingAddressesArray.count < TLAccountObject.MAX_ACCOUNT_WAIT_TO_RECEIVE_ADDRESS()) {
            let address = getNewMainAddress(getMainAddressesCount())
            addressIdx += 1
            if (addressIdx - receivingAddressesStartIdx < TLAccountObject.MAX_ACCOUNT_WAIT_TO_RECEIVE_ADDRESS()) {
                receivingAddressesArray.append(address)
            } else {
                break
            }
        }
        
        while (getMainActiveAddressesCount() - addressIdx < ACCOUNT_UNUSED_ACTIVE_MAIN_ADDRESS_AHEAD_OF_LATEST_USED_ONE_MINIMUM_COUNT) {
            getNewMainAddress(getMainAddressesCount())
        }

        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_UPDATED_RECEIVING_ADDRESSES()), object: nil)
    }
    
    
    fileprivate func updateChangeAddresses() -> () {
        var addressIdx = 0
        for i in stride(from: addressIdx, to: changeActiveAddresses.count, by: 1) {
                let address = changeActiveAddresses[addressIdx]
            if (getNumberOfTransactionsForAddress(address) == 0) {
                break
            }
        }
        while (getChangeActiveAddressesCount() - addressIdx < ACCOUNT_UNUSED_ACTIVE_CHANGE_ADDRESS_AHEAD_OF_LATEST_USED_ONE_MINIMUM_COUNT) {
            getNewChangeAddress(getChangeAddressesCount())
        }
    }
    
    
    fileprivate func checkToArchiveAddresses() -> () {
        self.checkToArchiveMainAddresses()
        self.checkToArchiveChangeAddresses()
    }
    
    fileprivate func checkToArchiveMainAddresses() -> () {
        if (getMainActiveAddressesCount() <= MAX_ACTIVE_MAIN_ADDRESS_TO_HAVE) {
            return
        }

        let activeMainAddresses = getActiveMainAddresses()!.copy() as! NSArray

        for _address in activeMainAddresses {
            let address = _address as! String
            if (getAddressBalance(address).lessOrEqual(TLCoin.zero()) &&
                getNumberOfTransactionsForAddress(address) > 0) {

                    let addressIdx = address2HDIndexDict[address]!
                    let accountIdx = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
                    
                    if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
                        
                        assert(addressIdx == mainArchivedAddresses.count, "")
                        mainArchivedAddresses.append(address)
                    } else {
                        if (accountType == TLAccountType.hdWallet) {
                            assert(addressIdx == self.appWallet!.getMinMainAddressIdxFromHDWallet(self.coinType, accountIdx: accountIdx), "")
                        } else if (accountType == TLAccountType.imported) {
                            assert(addressIdx == self.appWallet!.getMinMainAddressIdxFromImportedAccount(self.coinType, idx: getPositionInWalletArray()), "")
                        } else {
                            assert(addressIdx == self.appWallet!.getMinMainAddressIdxFromImportedWatchAccount(self.coinType, idx: getPositionInWalletArray()), "")
                        }
                    }
                    
                    assert(mainActiveAddresses.first == address, "")
                    mainActiveAddresses.remove(at: 0)
                    activeAddressesDict.removeValue(forKey: address)
                    if (accountType == TLAccountType.hdWallet) {
                        self.appWallet!.updateMainAddressStatusFromHDWallet(self.coinType, accountIdx: accountIdx,
                            addressIdx: addressIdx,
                            addressStatus: TLAddressStatus.archived)
                    } else if (accountType == TLAccountType.imported) {
                        self.appWallet!.updateMainAddressStatusFromImportedAccount(self.coinType, idx: getPositionInWalletArray(),
                            addressIdx: addressIdx,
                            addressStatus: TLAddressStatus.archived)
                    } else {
                        self.appWallet!.updateMainAddressStatusFromImportedWatchAccount(self.coinType, idx: getPositionInWalletArray(),
                            addressIdx: addressIdx,
                            addressStatus: TLAddressStatus.archived)
                    }
            } else {
                return
            }
            if (getMainActiveAddressesCount() <= MAX_ACTIVE_MAIN_ADDRESS_TO_HAVE) {
                return
            }
        }
    }
    
    fileprivate func checkToArchiveChangeAddresses() -> () {
        if (getChangeActiveAddressesCount() <= MAX_ACTIVE_CHANGE_ADDRESS_TO_HAVE) {
            return
        }
        
        let activeChangeAddresses = getActiveChangeAddresses()!.copy() as! NSArray
        
        for _address in activeChangeAddresses {
            let address = _address as! String
            
            if (getAddressBalance(address).lessOrEqual(TLCoin.zero()) &&
                getNumberOfTransactionsForAddress(address) > 0) {
                    
                    let addressIdx = address2HDIndexDict[address]!
                    let accountIdx = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
                    
                    if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
                        assert(addressIdx == changeArchivedAddresses.count, "")
                        changeArchivedAddresses.append(address)
                    } else {
                        if (accountType == TLAccountType.hdWallet) {
                            assert(addressIdx == self.appWallet!.getMinChangeAddressIdxFromHDWallet(self.coinType, accountIdx: accountIdx), "")
                        } else if (accountType == TLAccountType.imported) {
                            assert(addressIdx == self.appWallet!.getMinChangeAddressIdxFromImportedAccount(self.coinType, idx: getPositionInWalletArray()), "")
                        } else {
                            assert(addressIdx == self.appWallet!.getMinChangeAddressIdxFromImportedWatchAccount(self.coinType, idx: getPositionInWalletArray()), "")
                        }
                    }
                    
                    assert(changeActiveAddresses.first == address, "")
                    changeActiveAddresses.remove(at: 0)
                    activeAddressesDict.removeValue(forKey: address)
                    if (accountType == TLAccountType.hdWallet) {
                        self.appWallet!.updateChangeAddressStatusFromHDWallet(self.coinType, accountIdx: accountIdx,
                            addressIdx: addressIdx,
                            addressStatus: TLAddressStatus.archived)
                    } else if (accountType == TLAccountType.imported) {
                        self.appWallet!.updateChangeAddressStatusFromImportedAccount(self.coinType, idx: getPositionInWalletArray(),
                            addressIdx: addressIdx,
                            addressStatus: TLAddressStatus.archived)
                    } else {
                        self.appWallet!.updateChangeAddressStatusFromImportedWatchAccount(self.coinType, idx: getPositionInWalletArray(),
                            addressIdx: addressIdx,
                            addressStatus: TLAddressStatus.archived)
                    }
            } else {
                return
            }
            if (getChangeActiveAddressesCount() <= MAX_ACTIVE_CHANGE_ADDRESS_TO_HAVE) {
                return
            }
        }
    }
    
    fileprivate func processTxArray(_ txArray: NSArray, shouldResetAccountBalance: (Bool)) -> () {
        for _tx in txArray {
            let tx = _tx as! NSDictionary
            let txObject = TLTxObject(dict: tx)
            processTx(txObject, shouldCheckToAddressesNTxsCount: true, shouldUpdateAccountBalance: false)
            txObjectArray.append(txObject)
        }
        
        if (shouldResetAccountBalance) {
            checkToArchiveAddresses()
            updateReceivingAddresses()
            updateChangeAddresses()
        }
    }
    
    
    func getPositionInWalletArray() -> Int {
        return positionInWalletArray
    }
    
    func setPositionInWalletArray(_ idx: Int) -> () {
        positionInWalletArray = idx
    }
    
    fileprivate func getNewMainAddress(_ expectedAddressIndex: Int) -> String {
        let addressDict: NSDictionary
        
        if (accountType == TLAccountType.hdWallet) {
            let accountIdx = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
            addressDict = self.appWallet!.getNewMainAddressFromHDWallet(self.coinType, accountIdx: accountIdx, expectedAddressIndex: expectedAddressIndex)
        } else if (accountType == TLAccountType.coldWallet) {
            addressDict = self.appWallet!.getNewMainAddressFromColdWalletAccount(self.coinType, idx: positionInWalletArray, expectedAddressIndex: expectedAddressIndex)
        } else if (accountType == TLAccountType.imported) {
            addressDict = self.appWallet!.getNewMainAddressFromImportedAccount(self.coinType, idx: positionInWalletArray, expectedAddressIndex: expectedAddressIndex)
        } else {
            addressDict = self.appWallet!.getNewMainAddressFromImportedWatchAccount(self.coinType, idx: positionInWalletArray, expectedAddressIndex: expectedAddressIndex)
        }
        
        let address = addressDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
        let HDIndex = addressDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX) as! Int
        address2HDIndexDict[address] = HDIndex
        address2IsMainAddress[address] = true
        address2BalanceDict[address] = TLCoin.zero()
        address2NumberOfTransactions[address] = 0
        mainActiveAddresses.append(address)
        activeAddressesDict[address] = true
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_NEW_ADDRESS_GENERATED()), object: address)
        
        return address
    }
    
    fileprivate func getNewChangeAddress(_ expectedAddressIndex: Int) -> (String) {
        let addressDict: NSDictionary
        
        if (accountType == TLAccountType.hdWallet) {
            let accountIdx = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
            addressDict = self.appWallet!.getNewChangeAddressFromHDWallet(self.coinType, accountIdx: accountIdx, expectedAddressIndex: expectedAddressIndex)
        } else if (accountType == TLAccountType.coldWallet) {
            addressDict = self.appWallet!.getNewChangeAddressFromColdWalletAccount(self.coinType, idx: UInt(positionInWalletArray), expectedAddressIndex: expectedAddressIndex)
        } else if (accountType == TLAccountType.imported) {
            addressDict = self.appWallet!.getNewChangeAddressFromImportedAccount(self.coinType, idx: positionInWalletArray, expectedAddressIndex: expectedAddressIndex)
        } else {
            addressDict = self.appWallet!.getNewChangeAddressFromImportedWatchAccount(self.coinType, idx: UInt(positionInWalletArray), expectedAddressIndex: expectedAddressIndex)
        }
        
        let address = addressDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
        let HDIndex = addressDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX) as! Int
        address2HDIndexDict[address] = HDIndex
        address2IsMainAddress[address] = false
        address2BalanceDict[address] = TLCoin.zero()
        address2NumberOfTransactions[address] = 0
        changeActiveAddresses.append(address)
        activeAddressesDict[address] = true
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_NEW_ADDRESS_GENERATED()), object: address)
        
        return address
    }
    
    fileprivate func removeTopMainAddress() -> (Bool) {
        if (accountType == TLAccountType.hdWallet) {
            let accountIdx = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
            self.appWallet!.removeTopMainAddressFromHDWallet(self.coinType, accountIdx: accountIdx)!
        } else if (accountType == TLAccountType.coldWallet) {
            self.appWallet!.removeTopMainAddressFromColdWalletAccount(self.coinType, idx: positionInWalletArray)!
        } else if (accountType == TLAccountType.imported) {
            self.appWallet!.removeTopMainAddressFromImportedAccount(self.coinType, idx: positionInWalletArray)!
        } else if (accountType == TLAccountType.importedWatch) {
            self.appWallet!.removeTopMainAddressFromImportedWatchAccount(self.coinType, idx: positionInWalletArray)!
        }
        
        if (mainActiveAddresses.count > 0) {
            let address = mainActiveAddresses.last!
            address2HDIndexDict.removeValue(forKey: address)
            address2BalanceDict.removeValue(forKey: address)
            address2NumberOfTransactions.removeValue(forKey: address)
            mainActiveAddresses.removeLast()
            activeAddressesDict.removeValue(forKey: address)
            return true
        } else if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            if (mainArchivedAddresses.count > 0) {
                let address = mainArchivedAddresses.last!
                address2HDIndexDict.removeValue(forKey: address)
                address2BalanceDict.removeValue(forKey: address)
                address2NumberOfTransactions.removeValue(forKey: address)
                mainArchivedAddresses.removeLast()
                activeAddressesDict.removeValue(forKey: address)
            }
            return true
        }
        
        return false
    }
    
    fileprivate func removeTopChangeAddress() -> (Bool) {
        if (accountType == TLAccountType.hdWallet) {
            let accountIdx = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
            self.appWallet!.removeTopChangeAddressFromHDWallet(self.coinType, accountIdx: accountIdx)!
        } else if (accountType == TLAccountType.coldWallet) {
            self.appWallet!.removeTopChangeAddressFromColdWalletAccount(self.coinType, idx: positionInWalletArray)!
        } else if (accountType == TLAccountType.imported) {
            self.appWallet!.removeTopChangeAddressFromImportedAccount(self.coinType, idx: positionInWalletArray)!
        } else if (accountType == TLAccountType.importedWatch) {
            self.appWallet!.removeTopChangeAddressFromImportedWatchAccount(self.coinType, idx: positionInWalletArray)!
        }
        
        if (changeActiveAddresses.count > 0) {
            let address = changeActiveAddresses.last!
            address2HDIndexDict.removeValue(forKey: address)
            address2BalanceDict.removeValue(forKey: address)
            address2NumberOfTransactions.removeValue(forKey: address)
            changeActiveAddresses.removeLast()
            activeAddressesDict.removeValue(forKey: address)
            
            return true
        } else if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            if (changeArchivedAddresses.count > 0) {
                let address = changeArchivedAddresses.last!
                address2HDIndexDict.removeValue(forKey: address)
                address2BalanceDict.removeValue(forKey: address)
                address2NumberOfTransactions.removeValue(forKey: address)
                changeArchivedAddresses.removeLast()
                activeAddressesDict.removeValue(forKey: address)
                
            }
            return true
        }
        
        return false
    }
    
    func getCurrentChangeAddress() -> String {
        for address in changeActiveAddresses {
            if getNumberOfTransactionsForAddress(address) == 0 && self.getAddressBalance(address).equalTo(TLCoin.zero()) {
                return address
            }
        }

        return getNewChangeAddress(getChangeAddressesCount())
    }
    
    func getActiveMainAddresses() -> NSArray? {
        return mainActiveAddresses as NSArray?
    }
    
    func getActiveChangeAddresses() -> NSArray? {
        return changeActiveAddresses as NSArray?
    }
    
    func getMainActiveAddressesCount() -> Int {
        return mainActiveAddresses.count
    }
    
    func getMainArchivedAddressesCount() -> Int {
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            return mainArchivedAddresses.count
        } else {
            if (accountType == TLAccountType.hdWallet) {
                let accountIdx = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
                return self.appWallet!.getMinMainAddressIdxFromHDWallet(self.coinType, accountIdx: accountIdx)
            } else if (accountType == TLAccountType.coldWallet) {
                return self.appWallet!.getMinMainAddressIdxFromColdWalletAccount(self.coinType, idx: getPositionInWalletArray())
            } else if (accountType == TLAccountType.imported) {
                return self.appWallet!.getMinMainAddressIdxFromImportedAccount(self.coinType, idx: getPositionInWalletArray())
            } else {
                return self.appWallet!.getMinMainAddressIdxFromImportedWatchAccount(self.coinType, idx: getPositionInWalletArray())
            }
        }
    }
    
    fileprivate func getMainAddressesCount() -> Int {
        return getMainActiveAddressesCount() + getMainArchivedAddressesCount()
    }
    
    func getChangeActiveAddressesCount() -> Int {
        return changeActiveAddresses.count
    }
    
    func getChangeArchivedAddressesCount() -> Int {
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            return changeArchivedAddresses.count
        } else {
            if (accountType == TLAccountType.hdWallet) {
                let accountIdx = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
                return self.appWallet!.getMinChangeAddressIdxFromHDWallet(self.coinType, accountIdx: accountIdx)
            } else if (accountType == TLAccountType.coldWallet) {
                return self.appWallet!.getMinChangeAddressIdxFromColdWalletAccount(self.coinType, idx: getPositionInWalletArray())
            } else if (accountType == TLAccountType.imported) {
                return self.appWallet!.getMinChangeAddressIdxFromImportedAccount(self.coinType, idx: getPositionInWalletArray())
            } else {
                return self.appWallet!.getMinChangeAddressIdxFromImportedWatchAccount(self.coinType, idx: getPositionInWalletArray())
            }
        }
    }
    
    fileprivate func getChangeAddressesCount() -> Int {
        return getChangeActiveAddressesCount() + getChangeArchivedAddressesCount()
    }
    
    func getMainActiveAddress(_ idx: Int) -> String {
        return mainActiveAddresses[idx]
    }
    
    func getChangeActiveAddress(_ idx: Int) -> String {
        return changeActiveAddresses[idx]
    }
    
    func getMainArchivedAddress(_ idx: Int) -> String {
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            return mainArchivedAddresses[idx]
        } else {
            let HDIndex = idx
            var address = HDIndexToArchivedMainAddress[HDIndex]
            if (address == nil) {
                let extendedPublicKey = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY) as! String
                let mainAddressSequence = [Int(TLAddressType.main.rawValue), idx]
                address = TLHDWalletWrapper.getAddress(extendedPublicKey, sequence: mainAddressSequence as NSArray, isTestnet: self.appWallet!.walletConfig.isTestnet)
                HDIndexToArchivedMainAddress[HDIndex] = address!
                
                address2HDIndexDict[address!] = HDIndex
                address2IsMainAddress[address!] = true
            }
            return address!
        }
    }
    
    func getChangeArchivedAddress(_ idx: Int) -> String {
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            return changeArchivedAddresses[idx]
        } else {
            let HDIndex = idx
            var address = HDIndexToArchivedChangeAddress[HDIndex]
            if (address == nil) {
                let extendedPublicKey = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY) as! String
                let changeAddressSequence = [Int(TLAddressType.change.rawValue), idx]
                address = TLHDWalletWrapper.getAddress(extendedPublicKey, sequence: changeAddressSequence as NSArray, isTestnet: self.appWallet!.walletConfig.isTestnet)
                HDIndexToArchivedChangeAddress[HDIndex] = address!
                
                address2HDIndexDict[address!] = HDIndex
                address2IsMainAddress[address!] = false
            }
            return address!
        }
    }
    
    func recoverAccountMainAddresses(_ shouldResetAccountBalance: Bool) -> Int {
        var lookAheadOffset = 0
        var continueLookingAheadAddress = true
        DLog("recoverAccountMainAddresses: getAccountID: \(getAccountID())")
        var accountAddressIdx = -1
        
        while (continueLookingAheadAddress) {
            var addresses = [String]()
            addresses.reserveCapacity(GAP_LIMIT)
            
            let addressToIdxDict = NSMutableDictionary(capacity: GAP_LIMIT)
            
            for i in stride(from: lookAheadOffset, to: lookAheadOffset + GAP_LIMIT, by: 1) {
                let address = getNewMainAddress(i)
                DLog(String(format:"getNewMainAddress HDIdx: %lu address: %@", i, address))
                addresses.append(address)
                addressToIdxDict.setObject(i, forKey: address as NSCopying)
            }

            let jsonData = TLBlockExplorerAPI.instance().getAddressesInfoSynchronous(addresses)
            if (jsonData.object(forKey: TLNetworking.STATIC_MEMBERS.HTTP_ERROR_CODE) != nil) {
                DLog("getAccountDataSynchronous error \(jsonData.description)")
                NSException(name: NSExceptionName(rawValue: "Network Error"), reason: "HTTP Error", userInfo: nil).raise()
            }
            let addressesArray = jsonData.object(forKey: "addresses") as! NSArray
            var balance:UInt64 = 0
            for _addressDict in addressesArray {
                let addressDict = _addressDict as! NSDictionary
                let n_tx = addressDict.object(forKey: "n_tx") as! Int
                let address = addressDict.object(forKey: "address") as! String
                address2NumberOfTransactions[address] = n_tx
                let addressBalance = (addressDict.object(forKey: "final_balance") as! NSNumber).uint64Value
                balance += addressBalance
                address2BalanceDict[address] = TLCoin(uint64: addressBalance)

                
                let HDIdx = addressToIdxDict.object(forKey: address) as! Int
                DLog(String(format: "recoverAccountMainAddresses HDIdx: %d address: %@ n_tx: %d", HDIdx, address, n_tx))
                if (n_tx > 0 && HDIdx > accountAddressIdx) {
                    accountAddressIdx = HDIdx
                }
            }
            self.accountBalance = TLCoin(uint64: self.accountBalance.toUInt64() + UInt64(balance))
            
            DLog(String(format: "accountAddressIdx: %ld lookAheadOffset: %lu", accountAddressIdx, lookAheadOffset))
            
            if (accountAddressIdx < lookAheadOffset) {
                continueLookingAheadAddress = false
            }
            
            lookAheadOffset += GAP_LIMIT
            
        }
        
        while (getMainAddressesCount() > accountAddressIdx + 1) {
            removeTopMainAddress()
        }
        
        while (getMainAddressesCount() < accountAddressIdx + 1 + ACCOUNT_UNUSED_ACTIVE_MAIN_ADDRESS_AHEAD_OF_LATEST_USED_ONE_MINIMUM_COUNT) {
            getNewMainAddress(getMainAddressesCount())
        }
        
        return accountAddressIdx
    }
    
    fileprivate func recoverAccountChangeAddresses(_ shouldResetAccountBalance: Bool) -> Int {
        var lookAheadOffset = 0
        var continueLookingAheadAddress = true
        var accountAddressIdx = -1
        
        
        while (continueLookingAheadAddress) {
            var addresses = [String]()
            addresses.reserveCapacity(GAP_LIMIT)
            let addressToIdxDict = NSMutableDictionary(capacity: GAP_LIMIT)
            for i in stride(from: lookAheadOffset, to: lookAheadOffset + GAP_LIMIT, by: 1) {
                let address = getNewChangeAddress(i)
                DLog(String(format:"getNewChangeAddress HDIdx: %lu address: %@", i, address))
                addresses.append(address)
                addressToIdxDict.setObject(i, forKey: address as NSCopying)
            }
            
            let jsonData = TLBlockExplorerAPI.instance().getAddressesInfoSynchronous(addresses)
            if (jsonData.object(forKey: TLNetworking.STATIC_MEMBERS.HTTP_ERROR_CODE) != nil) {
                DLog("getAccountDataSynchronous error \(jsonData.description)")
                NSException(name: NSExceptionName(rawValue: "Network Error"), reason: "HTTP Error", userInfo: nil).raise()
            }
            let addressesArray = jsonData.object(forKey: "addresses") as! NSArray
            var balance:UInt64 = 0
            for _addressDict in addressesArray {
                let addressDict = _addressDict as! NSDictionary
                let n_tx = addressDict.object(forKey: "n_tx") as! Int
                let address = addressDict.object(forKey: "address") as! String
                address2NumberOfTransactions[address] = n_tx
                let addressBalance = (addressDict.object(forKey: "final_balance") as! NSNumber).uint64Value
                balance += addressBalance
                address2BalanceDict[address] = TLCoin(uint64: addressBalance)
                
                let HDIdx = addressToIdxDict.object(forKey: address) as! Int
                DLog(String(format: "recoverAccountChangeAddresses HDIdx: %d address: %@ n_tx: %d", HDIdx, address, n_tx))
                if (n_tx > 0 && HDIdx > accountAddressIdx) {
                    accountAddressIdx = HDIdx
                }
            }
            accountBalance = TLCoin(uint64: self.accountBalance.toUInt64() + UInt64(balance))
            
            if (accountAddressIdx < lookAheadOffset) {
                continueLookingAheadAddress = false
            }
            
            lookAheadOffset += GAP_LIMIT
        }
        
        while (getChangeAddressesCount() > accountAddressIdx + 1) {
            removeTopChangeAddress()
        }
        
        while (getChangeAddressesCount() < accountAddressIdx + 1 + ACCOUNT_UNUSED_ACTIVE_CHANGE_ADDRESS_AHEAD_OF_LATEST_USED_ONE_MINIMUM_COUNT) {
            getNewChangeAddress(getChangeAddressesCount())
        }
        
        return accountAddressIdx
    }
    
    func recoverAccount(_ shouldResetAccountBalance: Bool, recoverStealthPayments: Bool=false) -> Int {
        let accountMainAddressMaxIdx = recoverAccountMainAddresses(shouldResetAccountBalance)
        let accountChangeAddressMaxIdx = recoverAccountChangeAddresses(shouldResetAccountBalance)
        
        checkToArchiveAddresses()
        updateReceivingAddresses()
        updateChangeAddresses()
        if recoverStealthPayments && self.stealthWallet != nil {
            let semaphore = DispatchSemaphore(value: 0)
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                self.fetchNewStealthPayments(recoverStealthPayments)
                semaphore.signal()
            }
            semaphore.wait(timeout: DispatchTime.distantFuture)
        }
        
        updateAccountNeedsRecovering(false)
        return accountMainAddressMaxIdx + accountChangeAddressMaxIdx
    }
    
    func updateAccountNeedsRecovering(_ needsRecovering: Bool) -> () {
        if (accountType == TLAccountType.hdWallet) {
            let accountIdx = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
            self.appWallet!.updateAccountNeedsRecoveringFromHDWallet(self.coinType, accountIdx: accountIdx, accountNeedsRecovering: needsRecovering)
        } else if (accountType == TLAccountType.coldWallet) {
            self.appWallet!.updateAccountNeedsRecoveringFromColdWalletAccount(self.coinType, idx: getPositionInWalletArray(), accountNeedsRecovering: needsRecovering)
        } else if (accountType == TLAccountType.imported) {
            self.appWallet!.updateAccountNeedsRecoveringFromImportedAccount(self.coinType, idx: getPositionInWalletArray(), accountNeedsRecovering: needsRecovering)
        } else {
            self.appWallet!.updateAccountNeedsRecoveringFromImportedWatchAccount(self.coinType, idx: getPositionInWalletArray(), accountNeedsRecovering: needsRecovering)
        }
        accountDict!.setObject(needsRecovering, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING as NSCopying)
    }
    
    func clearAllAddresses() -> () {
        
        mainActiveAddresses = [String]()
        mainArchivedAddresses = [String]()
        changeActiveAddresses = [String]()
        changeArchivedAddresses = [String]()
        
        txidToAccountAmountDict = [String:TLCoin]()
        txidToAccountAmountTypeDict = [String:Int]()
        address2HDIndexDict = [String:Int]()
        address2BalanceDict = [String:TLCoin]()
        address2NumberOfTransactions = [String:Int]()
        activeAddressesDict = [String:Bool]()
        
        
        if (accountType == TLAccountType.hdWallet) {
            let accountIdx = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
            self.appWallet!.clearAllAddressesFromHDWallet(self.coinType, accountIdx: accountIdx)
            self.appWallet!.clearAllStealthPaymentsFromHDWallet(self.coinType, accountIdx: accountIdx)
        } else if (accountType == TLAccountType.coldWallet) {
            self.appWallet!.clearAllAddressesFromColdWalletAccount(self.coinType, idx: getPositionInWalletArray())
        } else if (accountType == TLAccountType.imported) {
            self.appWallet!.clearAllAddressesFromImportedAccount(self.coinType, idx: getPositionInWalletArray())
            self.appWallet!.clearAllStealthPaymentsFromImportedAccount(self.coinType, idx: getPositionInWalletArray())
        } else {
            self.appWallet!.clearAllAddressesFromImportedWatchAccount(self.coinType, idx: getPositionInWalletArray())
        }
        

    }
    
    func needsRecovering() -> (Bool) {
        let needsRecovering = accountDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING) as! Bool
        return needsRecovering
    }
    
    func getUnspentArray() -> NSArray {
        return unspentOutputs!
    }
    
    func getStealthPaymentUnspentOutputsArray() -> NSArray {
        return stealthPaymentUnspentOutputs!
    }
    
    func getTotalUnspentSum() -> TLCoin {
        if (totalUnspentOutputsSum != nil) {
            return totalUnspentOutputsSum!
        }
        
        if (unspentOutputs == nil) {
            return TLCoin.zero()
        }
        
        var totalUnspentOutputsSumTemp:UInt64 = 0
        
        for _unspentOutput in stealthPaymentUnspentOutputs! {
            let unspentOutput = _unspentOutput as! NSDictionary
            let amount = unspentOutput.object(forKey: "value") as! NSNumber
            totalUnspentOutputsSumTemp += amount.uint64Value
        }
        
        for _unspentOutput in unspentOutputs! {
            let unspentOutput = _unspentOutput as! NSDictionary
            let amount = unspentOutput.object(forKey: "value") as! NSNumber
            totalUnspentOutputsSumTemp += amount.uint64Value
        }
        
        totalUnspentOutputsSum = TLCoin(uint64: totalUnspentOutputsSumTemp)
        return totalUnspentOutputsSum!
    }

    func getInputsNeededToConsume(_ amountNeeded: TLCoin) -> Int {
        var valueSelected:UInt64 = 0
        var inputCount = 0
        for _unspentOutput in stealthPaymentUnspentOutputs! {
            let unspentOutput = _unspentOutput as! NSDictionary
            let amount = unspentOutput.object(forKey: "value") as! NSNumber
            valueSelected += amount.uint64Value
            
            inputCount += 1
            if (valueSelected >= amountNeeded.toUInt64() && inputCount >= MAX_CONSOLIDATE_STEALTH_PAYMENT_UTXOS_COUNT) {
                break
            }
        }
        
        if valueSelected >= amountNeeded.toUInt64() {
            return inputCount
        }
        
        for _unspentOutput in unspentOutputs! {
            let unspentOutput = _unspentOutput as! NSDictionary
            let amount = unspentOutput.object(forKey: "value") as! NSNumber
            valueSelected += amount.uint64Value
            inputCount += 1
            if valueSelected >= amountNeeded.toUInt64() {
                return inputCount
            }
        }
        return inputCount
    }

    func getUnspentOutputs(_ success: @escaping TLWalletUtils.Success, failure:@escaping TLWalletUtils.Error) {
        var activeAddresses = getActiveMainAddresses()! as! [String]
        activeAddresses += getActiveChangeAddresses()! as! [String]
        
        if self.stealthWallet != nil {
            activeAddresses += self.stealthWallet!.getUnspentPaymentAddresses()
        }
        
        unspentOutputs = nil
        totalUnspentOutputsSum = nil
        stealthPaymentUnspentOutputs = nil
        unspentOutputsCount = 0
        stealthPaymentUnspentOutputsCount = 0
        haveUpDatedUTXOs = false
        
        TLBlockExplorerAPI.instance().getUnspentOutputs(activeAddresses, success: {
            (jsonData) in
            let unspentOutputs = (jsonData as! NSDictionary).object(forKey: "unspent_outputs") as! NSArray!
            self.unspentOutputs = NSMutableArray(capacity: unspentOutputs!.count)
            self.stealthPaymentUnspentOutputs = NSMutableArray(capacity: unspentOutputs!.count)

            for unspentOutput in unspentOutputs! {
                let outputScript = (unspentOutput as AnyObject).object(forKey: "script") as! String
                
                let address = TLCoreBitcoinWrapper.getAddressFromOutputScript(outputScript, isTestnet: self.appWallet!.walletConfig.isTestnet)
                if (address == nil) {
                    DLog("address cannot be decoded. not normal pubkeyhash outputScript: \(outputScript)")
                    continue
                }
                if self.stealthWallet != nil && self.stealthWallet!.isPaymentAddress(address!) == true {
                    self.stealthPaymentUnspentOutputs!.add(unspentOutput)
                    self.stealthPaymentUnspentOutputsCount += 1
                } else {
                    self.unspentOutputs!.add(unspentOutput)
                    self.unspentOutputsCount += 1
                }
            }
        
            self.unspentOutputs = NSMutableArray(array: self.unspentOutputs!.sortedArray (comparator: {
                (obj1, obj2) -> ComparisonResult in
                
                var confirmations1 = 0
                var confirmations2 = 0
                
                if let c1 = (obj1 as! NSDictionary).object(forKey: "confirmations") as? Int {
                    confirmations1 = c1
                }
                
                if let c2 = (obj2 as! NSDictionary).object(forKey: "confirmations") as? Int {
                    confirmations2 = c2
                }

                if confirmations1 > confirmations2 {
                    return .orderedAscending
                } else if confirmations1 < confirmations2 {
                    return .orderedDescending
                } else {
                    return .orderedSame
                }
            }))
            
            self.stealthPaymentUnspentOutputs = NSMutableArray(array: self.stealthPaymentUnspentOutputs!.sortedArray (comparator: {
                (obj1, obj2) -> ComparisonResult in
                
                var confirmations1 = 0
                var confirmations2 = 0
                
                if let c1 = (obj1 as! NSDictionary).object(forKey: "confirmations") as? Int {
                    confirmations1 = c1
                }
                
                if let c2 = (obj2 as! NSDictionary).object(forKey: "confirmations") as? Int {
                    confirmations2 = c2
                }
                
                if confirmations1 > confirmations2 {
                    return .orderedAscending
                } else if confirmations1 < confirmations2 {
                    return .orderedDescending
                } else {
                    return .orderedSame
                }
            }))
            self.haveUpDatedUTXOs = true
            success()
            }, failure: {
                (code, status) in
                failure()
        })
    }
    
    func fetchNewStealthPayments(_ isRestoringAccount: Bool) {
        self.stealthWallet!.checkToWatchStealthAddress()
        var offset = 0
        var currentLatestTxTime:UInt64 = 0
        while true {
            let ret = self.stealthWallet!.getAndStoreStealthPayments(offset)
            if ret == nil {
                break
            }
            let latestTxTime = ret!.1
            if latestTxTime > currentLatestTxTime {
                currentLatestTxTime = latestTxTime
            }
            let gotOldestPaymentAddresses = ret!.0
            let newStealthPaymentAddresses = ret!.2
            DLog("getAccountData  \(self.getAccountIdxNumber()) newStealthPaymentAddresses \(newStealthPaymentAddresses.description)")
            //TODO: txarray will not be in chronological order because of this, fix this
            if newStealthPaymentAddresses.count > 0 {
                self.getAccountDataO(newStealthPaymentAddresses, shouldResetAccountBalance: false)
            }
            if gotOldestPaymentAddresses {
                break
            }
            offset += TLStealthExplorerAPI.STATIC_MEMBERS.STEALTH_PAYMENTS_FETCH_COUNT
        }
        
        self.setStealthAddressLastTxTime(TLPreferences.getStealthExplorerURL()!, lastTxTime: currentLatestTxTime)
        
        if isRestoringAccount {
            self.stealthWallet!.setUpStealthPaymentAddresses(true, isSetup: true, async: false)
        }
    }
    
    func getAccountData(_ addresses: Array<String>, shouldResetAccountBalance: Bool,
        success: @escaping TLWalletUtils.Success, failure:@escaping TLWalletUtils.Error) -> () {
            
            TLBlockExplorerAPI.instance().getAddressesInfo(addresses, success: {
                (_jsonData) in
                let jsonData = _jsonData as! NSDictionary
                if (shouldResetAccountBalance) {
                    self.resetAccountBalances()
                }
                
                let addressesDict = jsonData.object(forKey: "addresses") as! NSArray
                var balance:UInt64 = 0
                for _addressDict in addressesDict {
                    let addressDict = _addressDict as! NSDictionary
                    let n_tx = addressDict.object(forKey: "n_tx") as! Int
                    let address = addressDict.object(forKey: "address") as! String
                    self.address2NumberOfTransactions[address] = n_tx
                    let addressBalance = (addressDict.object(forKey: "final_balance") as! NSNumber).uint64Value
                    balance += addressBalance
                    self.address2BalanceDict[address] = TLCoin(uint64: addressBalance)
                }
                self.accountBalance = TLCoin(uint64: self.accountBalance.toUInt64() + balance)
                
                self.processTxArray(jsonData.object(forKey: "txs") as! NSArray, shouldResetAccountBalance: true)
                
                
                self.fetchedAccountData = true
                self.subscribeToWebsockets()
                self.downloadState = .downloaded
                DLog("postNotificationName: EVENT_FETCHED_ADDRESSES_DATA \(self.getAccountIdxNumber())")
                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA()), object: nil)
                success()
                },
                failure: {
                    (code, status) in
                    failure()
            })
    }
    
    fileprivate func getAccountDataSynchronous(_ addresses: Array<String>, shouldResetAccountBalance: Bool, shouldProcessTxArray: Bool) -> NSDictionary? {
        let jsonData = TLBlockExplorerAPI.instance().getAddressesInfoSynchronous(addresses)
        if (jsonData.object(forKey: TLNetworking.STATIC_MEMBERS.HTTP_ERROR_CODE) == nil) {
            if (shouldResetAccountBalance) {
                resetAccountBalances()
            }
            
            let addressesArray = jsonData.object(forKey: "addresses") as! NSArray
            var balance:UInt64 = 0
            for _addressDict in addressesArray {
                let addressDict = _addressDict as! NSDictionary
                let n_tx = addressDict.object(forKey: "n_tx") as! Int
                let address = addressDict.object(forKey: "address") as! String
                address2NumberOfTransactions[address] = n_tx
                let addressBalance = (addressDict.object(forKey: "final_balance") as! NSNumber).uint64Value
                balance += addressBalance
                address2BalanceDict[address] = TLCoin(uint64: addressBalance)
            }
            self.accountBalance = TLCoin(uint64: self.accountBalance.toUInt64() + balance)
            
            if (shouldProcessTxArray) {
                self.processTxArray(jsonData.object(forKey: "txs") as! NSArray, shouldResetAccountBalance: false)
                self.fetchedAccountData = false //need to be false because after recovering account need to fetch stealth payments
            }
        } else {
            DLog("getAccountDataSynchronous error \(jsonData.description)")
            NSException(name: NSExceptionName(rawValue: "Network Error"), reason: "HTTP Error", userInfo: nil).raise()
        }
        
        return jsonData
    }
    
    
    fileprivate func resetAccountBalances() -> () {
        txObjectArray = [TLTxObject]()
        address2BalanceDict = [String:TLCoin]()
        address2NumberOfTransactions = [String:Int]()
        
        accountBalance = TLCoin.zero()
        
        for address in mainActiveAddresses {
            address2BalanceDict[address] = TLCoin.zero()
            address2NumberOfTransactions[address] = 0
        }
        for address in changeActiveAddresses {
            address2BalanceDict[address] = TLCoin.zero()
            address2NumberOfTransactions[address] = 0
        }
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            for address in mainArchivedAddresses {
                address2BalanceDict[address] = TLCoin.zero()
                address2NumberOfTransactions[address] = 0
            }
            for address in changeArchivedAddresses {
                address2BalanceDict[address] = TLCoin.zero()
                address2NumberOfTransactions[address] = 0
            }
        }
    }
    
    func setStealthAddressServerStatus(_ serverURL: String, isWatching: Bool) -> () {
        if (self.accountType == TLAccountType.hdWallet) {
            let accountIdx = self.getAccountIdxNumber()
            self.appWallet!.setStealthAddressServerStatusHDWallet(self.coinType, accountIdx: accountIdx, serverURL: serverURL, isWatching: isWatching)
        } else if (self.accountType == TLAccountType.coldWallet) {
            self.appWallet!.setStealthAddressServerStatusColdWalletAccount(self.coinType, idx: self.getPositionInWalletArray(), serverURL: serverURL, isWatching: isWatching)
        } else if (self.accountType == TLAccountType.imported) {
            self.appWallet!.setStealthAddressServerStatusImportedAccount(self.coinType, idx: self.getPositionInWalletArray(), serverURL: serverURL, isWatching: isWatching)
        } else {
            self.appWallet!.setStealthAddressServerStatusImportedWatchAccount(self.coinType, idx: self.getPositionInWalletArray(), serverURL: serverURL, isWatching: isWatching)
        }
    }

    func setStealthAddressLastTxTime(_ serverURL: String, lastTxTime: UInt64) -> () {
        if (self.accountType == TLAccountType.hdWallet) {
            let accountIdx = self.getAccountIdxNumber()
            self.appWallet!.setStealthAddressLastTxTimeHDWallet(self.coinType, accountIdx: accountIdx, serverURL: serverURL, lastTxTime: lastTxTime)
        } else if (self.accountType == TLAccountType.coldWallet) {
            self.appWallet!.setStealthAddressLastTxTimeColdWalletAccount(self.coinType, idx: self.getPositionInWalletArray(), serverURL: serverURL, lastTxTime: lastTxTime)
        } else if (self.accountType == TLAccountType.imported) {
            self.appWallet!.setStealthAddressLastTxTimeImportedAccount(self.coinType, idx: self.getPositionInWalletArray(), serverURL: serverURL, lastTxTime: lastTxTime)
        } else {
            self.appWallet!.setStealthAddressLastTxTimeImportedWatchAccount(self.coinType, idx: self.getPositionInWalletArray(), serverURL: serverURL, lastTxTime: lastTxTime)
        }
    }
    
    func addStealthAddressPaymentKey(_ privateKey:String, address:String, txid: String, txTime: UInt64, stealthPaymentStatus: TLStealthPaymentStatus) -> () {
        if (accountType == TLAccountType.hdWallet) {
            let accountIdx = self.getAccountIdxNumber()
            self.appWallet!.addStealthAddressPaymentKeyHDWallet(self.coinType, accountIdx: accountIdx, privateKey:privateKey,
                address:address, txid:txid, txTime: txTime, stealthPaymentStatus: stealthPaymentStatus)
        } else if (accountType == TLAccountType.coldWallet) {
            self.appWallet!.addStealthAddressPaymentKeyColdWalletAccount(self.coinType, idx: self.getPositionInWalletArray(),
                privateKey:privateKey, address:address, txid:txid, txTime: txTime, stealthPaymentStatus: stealthPaymentStatus)
        } else if (accountType == TLAccountType.imported) {
            self.appWallet!.addStealthAddressPaymentKeyImportedAccount(self.coinType, idx: self.getPositionInWalletArray(),
                privateKey:privateKey, address:address, txid:txid, txTime: txTime, stealthPaymentStatus: stealthPaymentStatus)
        } else if (accountType == TLAccountType.importedWatch) {
            self.appWallet!.addStealthAddressPaymentKeyImportedWatchAccount(self.coinType, idx: self.getPositionInWalletArray(),
                privateKey:privateKey, address:address, txid:txid, txTime: txTime, stealthPaymentStatus: stealthPaymentStatus)
        }
    }
    
    func setStealthPaymentStatus(_ txid: String, stealthPaymentStatus: TLStealthPaymentStatus, lastCheckTime: UInt64) -> () {
        if (accountType == TLAccountType.hdWallet) {
            let accountIdx = self.getAccountIdxNumber()
            self.appWallet!.setStealthPaymentStatusHDWallet(self.coinType, accountIdx: accountIdx, txid:txid,
                stealthPaymentStatus:stealthPaymentStatus, lastCheckTime: lastCheckTime)
        } else if (accountType == TLAccountType.coldWallet) {
            self.appWallet!.setStealthPaymentStatusColdWalletAccount(self.coinType, idx: self.getPositionInWalletArray(),
                txid:txid, stealthPaymentStatus:stealthPaymentStatus, lastCheckTime: lastCheckTime)
        } else if (accountType == TLAccountType.imported) {
            self.appWallet!.setStealthPaymentStatusImportedAccount(self.coinType, idx: self.getPositionInWalletArray(),
                txid:txid, stealthPaymentStatus:stealthPaymentStatus, lastCheckTime: lastCheckTime)
        } else if (accountType == TLAccountType.importedWatch) {
            self.appWallet!.setStealthPaymentStatusImportedWatchAccount(self.coinType, idx: self.getPositionInWalletArray(),
                txid:txid, stealthPaymentStatus:stealthPaymentStatus, lastCheckTime: lastCheckTime)
        }
    }
    
    func removeOldStealthPayments() -> () {
        if (accountType == TLAccountType.hdWallet) {
            let accountIdx = self.getAccountIdxNumber()
            self.appWallet!.removeOldStealthPaymentsHDWallet(self.coinType, accountIdx: accountIdx)
        } else if (accountType == TLAccountType.coldWallet) {
            self.appWallet!.removeOldStealthPaymentsColdWalletAccount(self.coinType, idx: self.getPositionInWalletArray())
        } else if (accountType == TLAccountType.imported) {
            self.appWallet!.removeOldStealthPaymentsImportedAccount(self.coinType, idx: self.getPositionInWalletArray())
        } else if (accountType == TLAccountType.importedWatch) {
            self.appWallet!.removeOldStealthPaymentsImportedWatchAccount(self.coinType, idx: self.getPositionInWalletArray())
        }
    }

    func setStealthPaymentLastCheckTime(_ txid: String, lastCheckTime: UInt64) -> () {
        if (accountType == TLAccountType.hdWallet) {
            let accountIdx = self.getAccountIdxNumber()
            self.appWallet!.setStealthPaymentLastCheckTimeHDWallet(self.coinType, accountIdx: accountIdx, txid: txid, lastCheckTime: lastCheckTime)
        } else if (accountType == TLAccountType.coldWallet) {
            self.appWallet!.setStealthPaymentLastCheckTimeColdWalletAccount(self.coinType, idx: self.getPositionInWalletArray(), txid: txid, lastCheckTime: lastCheckTime)
        } else if (accountType == TLAccountType.imported) {
            self.appWallet!.setStealthPaymentLastCheckTimeImportedAccount(self.coinType, idx: self.getPositionInWalletArray(), txid: txid, lastCheckTime: lastCheckTime)
        } else if (accountType == TLAccountType.importedWatch) {
            self.appWallet!.setStealthPaymentLastCheckTimeImportedWatchAccount(self.coinType, idx: self.getPositionInWalletArray(), txid: txid, lastCheckTime: lastCheckTime)
        }
    }
    
    
    func getAccountDataO() -> () {
        // if account needs recovering dont fetch account data
        if (needsRecovering()) {
            self.downloadState = .failed
            return
        }


        var activeAddresses = getActiveMainAddresses()! as! [String]
        activeAddresses += getActiveChangeAddresses()! as! [String]
        
        if self.stealthWallet != nil {
            activeAddresses += self.stealthWallet!.getPaymentAddresses()
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                self.fetchNewStealthPayments(false)
            }
        }
        
        self.getAccountDataO(activeAddresses, shouldResetAccountBalance: true)
    }
    
    fileprivate func getAccountDataO(_ addresses: Array<String>, shouldResetAccountBalance: Bool) -> () {
        let jsonData = TLBlockExplorerAPI.instance().getAddressesInfoSynchronous(addresses)
        if (jsonData.object(forKey: TLNetworking.STATIC_MEMBERS.HTTP_ERROR_CODE) != nil) {
            self.downloadState = .failed
            return
        }

        if (shouldResetAccountBalance) {
            self.resetAccountBalances()
        }

        let addressesDict = jsonData.object(forKey: "addresses") as! NSArray
        var balance:UInt64 = 0
        for _addressDict in addressesDict {
            let addressDict = _addressDict as! NSDictionary
            let n_tx = addressDict.object(forKey: "n_tx") as! Int
            let address = addressDict.object(forKey: "address") as! String
            self.address2NumberOfTransactions[address] = n_tx
            let addressBalance = (addressDict.object(forKey: "final_balance") as! NSNumber).uint64Value
            balance += addressBalance
            self.address2BalanceDict[address] = TLCoin(uint64: addressBalance)
        }
        self.accountBalance = TLCoin(uint64: self.accountBalance.toUInt64() + balance)
        
        self.processTxArray(jsonData.object(forKey: "txs") as! NSArray, shouldResetAccountBalance: true)
        
        self.fetchedAccountData = true
        self.subscribeToWebsockets()
        self.downloadState = .downloaded
        DispatchQueue.main.async(execute: {
            DLog("postNotificationName: EVENT_FETCHED_ADDRESSES_DATA \(self.getAccountIdxNumber())")
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA()), object: nil)
        })
    }
    
    fileprivate func subscribeToWebsockets() -> () {
        if self.listeningToIncomingTransactions == false {
            self.listeningToIncomingTransactions = true
            let activeMainAddresses = self.getActiveMainAddresses()
            for address in activeMainAddresses! {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
            }
            let activeChangeAddresses = self.getActiveChangeAddresses()
            for address in activeChangeAddresses! {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
            }
        }
        if self.stealthWallet != nil {
            let stealthPaymentAddresses = self.stealthWallet!.getUnspentPaymentAddresses()
            for address in stealthPaymentAddresses {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(address)
            }
            
            if self.stealthWallet!.isListeningToStealthPayment == false {
                let challenge = TLStealthWebSocket.instance().challenge
                let addrAndSignature = self.stealthWallet!.getStealthAddressAndSignatureFromChallenge(challenge)
                TLStealthWebSocket.instance().sendMessageSubscribeToStealthAddress(addrAndSignature.0, signature: addrAndSignature.1)
            }
        }
    }
}
