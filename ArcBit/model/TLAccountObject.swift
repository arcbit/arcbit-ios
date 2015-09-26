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
    
    var appWallet:TLWallet?
    private var accountDict: NSMutableDictionary?
    var unspentOutputs: NSMutableArray?
    var stealthPaymentUnspentOutputs: NSMutableArray?
    private var mainActiveAddresses = [String]()
    private var changeActiveAddresses = [String]()
    private var activeAddressesDict = [String:Bool]()
    private var mainArchivedAddresses = [String]()
    private var changeArchivedAddresses = [String]()
    private var address2BalanceDict = [String:TLCoin]()
    private var address2HDIndexDict = [String:Int]()
    private var address2IsMainAddress = [String:Bool]()
    private var address2NumberOfTransactions = [String:Int]()
    private var HDIndexToArchivedMainAddress = [Int:String]()
    private var HDIndexToArchivedChangeAddress = [Int:String]()
    private var txObjectArray = [TLTxObject]()
    private var txidToAccountAmountDict = [String:TLCoin]()
    private var txidToAccountAmountTypeDict = [String:Int]()
    private var receivingAddressesArray = [String]()
    private var processedTxDict = [String:Bool]()
    private var accountType: TLAccountType?
    private var accountBalance = TLCoin.zero()
    private var totalUnspentOutputsSum: TLCoin?
    private var fetchedAccountData = false
    var listeningToIncomingTransactions = false
    private var positionInWalletArray = 0
    private var extendedPrivateKey: String?
    var stealthWallet: TLStealthWallet?
    var downloadState:TLDownloadState = .NotDownloading

    class func MAX_ACCOUNT_WAIT_TO_RECEIVE_ADDRESS() -> (Int) {
        return 5
    }
    
    class func NUM_ACCOUNT_STEALTH_ADDRESSES() -> (Int) {
        return 1
    }
    
    private func setUpActiveMainAddresses() -> () {
        mainActiveAddresses = [String]()
        let addressesArray = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES) as! NSMutableArray
        let minAddressIdx = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX) as! Int
        
        let startIdx: Int
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            startIdx = minAddressIdx
        } else {
            startIdx = 0
        }
        for (var i = startIdx; i < addressesArray.count; i++) {
            let addressDict = addressesArray.objectAtIndex(i) as! NSDictionary
            let HDIndex = addressDict.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX) as! Int
            let address = addressDict.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
            address2HDIndexDict[address] = HDIndex
            address2IsMainAddress[address] = true
            address2BalanceDict[address] = TLCoin.zero()
            address2NumberOfTransactions[address] = 0
            mainActiveAddresses.append(address)
            activeAddressesDict[address] = true
        }
    }
    
    private func setUpActiveChangeAddresses() -> () {
        changeActiveAddresses = [String]()
        
        let addressesArray = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES) as! NSMutableArray
        let minAddressIdx = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX) as! Int
        
        var startIdx = 0
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            startIdx = minAddressIdx
        } else {
            startIdx = 0
        }
        for (var i = startIdx; i < addressesArray.count; i++) {
            let addressDict = addressesArray.objectAtIndex(i) as! NSDictionary
            let HDIndex = addressDict.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX) as! Int
            let address = addressDict.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
            address2HDIndexDict[address] = HDIndex
            address2IsMainAddress[address] = false
            address2BalanceDict[address] = TLCoin.zero()
            address2NumberOfTransactions[address] = 0
            changeActiveAddresses.append(address)
            activeAddressesDict[address] = true
        }
    }
    
    private func setUpArchivedMainAddresses() -> () {
        mainArchivedAddresses = [String]()
        
        let addressesArray = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES) as! NSMutableArray
        let maxAddressIdx = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX) as! Int// - 1
        
        for (var i = 0; i < maxAddressIdx; i++) {
            let addressDict = addressesArray.objectAtIndex(i) as! NSDictionary
            assert(addressDict.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS) as! Int == Int(TLAddressStatus.Archived.rawValue), "")
            let HDIndex = addressDict.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX) as! Int
            
            let address = addressDict.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
            
            address2HDIndexDict[address] = HDIndex
            address2IsMainAddress[address] = true

            address2BalanceDict[address] = TLCoin.zero()
            address2NumberOfTransactions[address] = 0
            mainArchivedAddresses.append(address)
        }
    }
    
    private func setUpArchivedChangeAddresses() -> () {
        changeArchivedAddresses = [String]()
        
        let addressesArray = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES) as! NSMutableArray
        let maxAddressIdx = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX) as! Int// - 1
        
        for (var i = 0; i < maxAddressIdx; i++) {
            let addressDict = addressesArray.objectAtIndex(i) as! NSDictionary
            let HDIndex = addressDict.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX) as! Int
            
            let address = addressDict.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
            assert((addressDict.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS) as! Int) == Int(TLAddressStatus.Archived.rawValue), "")
            address2HDIndexDict[address] = HDIndex
            address2IsMainAddress[address] = false
            address2BalanceDict[address] = TLCoin.zero()
            address2NumberOfTransactions[address] = 0
            changeArchivedAddresses.append(address)
        }
    }
    
    init(appWallet: TLWallet, dict: NSDictionary, accountType at: TLAccountType) {
        super.init()
        self.appWallet = appWallet
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

        
        if (accountType == TLAccountType.HDWallet) {
            positionInWalletArray = getAccountIdxNumber()
        } else if (accountType == TLAccountType.Imported) {
            //set later in accounts
        } else if (accountType == TLAccountType.ImportedWatch) {
            //set later in accounts
        }
        
        if accountType != TLAccountType.ImportedWatch {
            let stealthAddressArray = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES) as! NSArray
            let stealthWalletDict = stealthAddressArray.objectAtIndex(0) as! NSDictionary
            self.stealthWallet = TLStealthWallet(stealthDict: stealthWalletDict, accountObject: self,
                updateStealthPaymentStatuses: !self.isArchived())
            
            
            //add default zero balance so that if user goes to address list view before account data downloaded,
            // then accountObject will return a 0 balance for payment address instead of getting optional unwrap nil error
            for var i = 0; i < self.stealthWallet!.getStealthAddressPaymentsCount(); i++ {
                let address = self.stealthWallet!.getPaymentAddressForIndex(i)
                address2BalanceDict[address] = TLCoin.zero()
            }
        }
    }
    
    func isWatchOnly() -> (Bool) {
        return accountType == TLAccountType.ImportedWatch
    }
    
    func hasSetExtendedPrivateKeyInMemory() -> (Bool) {
        assert(accountType == TLAccountType.ImportedWatch, "")
        return extendedPrivateKey != nil
    }
    
    func setExtendedPrivateKeyInMemory(extendedPrivKey: String) -> Bool {
        assert(accountType == TLAccountType.ImportedWatch, "")
        assert(TLHDWalletWrapper.isValidExtendedPrivateKey(extendedPrivKey), "extendedPrivKey isValidExtendedPrivateKey")
        
        if (TLHDWalletWrapper.getExtendPubKey(extendedPrivKey) == getExtendedPubKey()) {
            extendedPrivateKey = extendedPrivKey
            return true
        }
        return false
    }
    
    func clearExtendedPrivateKeyFromMemory() -> () {
        assert(accountType == TLAccountType.ImportedWatch, "")
        extendedPrivateKey = nil
    }
    
    
    func hasFetchedAccountData() -> (Bool) {
        return self.fetchedAccountData
    }
    
    func renameAccount(accountName: String) -> (Bool) {
        accountDict!.setObject(accountName, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME)
        return true
    }
    
    func getAccountName() -> String {
        return accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME) as! String
    }
    
    func getAccountNameOrAccountPublicKey() -> String {
        let accountName = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME) as! String
        return accountName != "" ? accountName : getExtendedPubKey()
    }
    
    func getDefaultNameAccount() -> String {
        return "Default Account Name".localized
    }
    
    
    func archiveAccount(enabled: Bool) -> (Bool) {
        let status = enabled ? TLAddressStatus.Archived : TLAddressStatus.Active
        accountDict!.setObject(status.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
        return true
    }
    
    func isArchived() -> (Bool) {
        return (accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS) as! Int) == Int(TLAddressStatus.Archived.rawValue)
    }
    
    func getAccountID() -> (String) {
        let accountIdx = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
        return String(accountIdx)
    }
    
    func getAccountIdxNumber() -> (Int) {
        return accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
    }
    
    func getAccountHDIndex() -> UInt32 {
        return TLHDWalletWrapper.getAccountIdxForExtendedKey(getExtendedPubKey()) as UInt32
    }
    
    func getExtendedPubKey() -> String {
        return accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY) as! String
    }
    
    func getExtendedPrivKey() -> String? {
        if (accountType == TLAccountType.HDWallet) {
            return accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PRIVATE_KEY) as? String
        } else if (accountType == TLAccountType.Imported) {
            return accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PRIVATE_KEY) as? String
        } else if (accountType == TLAccountType.ImportedWatch) {
            return extendedPrivateKey
        }
        return nil
    }
    
    func getAddressBalance(address: String) -> TLCoin {
        if let amount = address2BalanceDict[address] {
            return amount
        } else {
            return TLCoin.zero()
        }
    }
    
    func getNumberOfTransactionsForAddress(address: String) -> Int? {
        assert(self.isHDWalletAddress(address))
        return address2NumberOfTransactions[address]
    }
    
    func getAddressHDIndex(address: String) -> Int {
        return address2HDIndexDict[address]!
    }
    
    func getAccountPrivateKey(address: String) -> String? {
        if self.isHDWalletAddress(address) {
            if (address2IsMainAddress[address] == true) {
                return getMainPrivateKey(address)
            } else {
                return getChangePrivateKey(address)
            }
        }
        
        return nil
    }
    
    func getMainPrivateKey(address: String) -> String {
        let HDIndexNumber = address2HDIndexDict[address]!
        let addressSequence = [Int(TLAddressType.Main.rawValue), HDIndexNumber]
        if (accountType == TLAccountType.ImportedWatch) {
            assert(extendedPrivateKey != nil, "")
            return TLHDWalletWrapper.getPrivateKey(extendedPrivateKey!, sequence: addressSequence, isTestnet: self.appWallet!.walletConfig.isTestnet)
        } else {
            return TLHDWalletWrapper.getPrivateKey(accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PRIVATE_KEY) as! String, sequence: addressSequence, isTestnet: self.appWallet!.walletConfig.isTestnet)
        }
    }
    
    func getChangePrivateKey(address: String) -> String {
        let HDIndexNumber = address2HDIndexDict[address]!
        let addressSequence = [TLAddressType.Change.rawValue, HDIndexNumber]
        if (accountType == TLAccountType.ImportedWatch) {
            assert(extendedPrivateKey != nil, "")
            return TLHDWalletWrapper.getPrivateKey(extendedPrivateKey!, sequence: addressSequence, isTestnet: self.appWallet!.walletConfig.isTestnet)
        } else {
            return TLHDWalletWrapper.getPrivateKey(accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PRIVATE_KEY) as! String, sequence: addressSequence, isTestnet: self.appWallet!.walletConfig.isTestnet)
        }
    }
    
    func getTxObjectCount() -> Int {
        return txObjectArray.count
    }
    
    func getTxObject(txIdx: Int) -> TLTxObject {
        return txObjectArray[txIdx]
    }
    
    private func isAddressPartOfAccountActiveChangeAddresses(address: String) -> (Bool) {
        return changeActiveAddresses.indexOf(address) != nil
    }
    
    private func isAddressPartOfAccountActiveMainAddresses(address: String) -> Bool {
        return mainActiveAddresses.indexOf(address) != nil
    }
    
    func isActiveAddress(address: String) -> Bool {
        return activeAddressesDict[address] != nil
    }
    
    func isHDWalletAddress(address: String) -> Bool {
        return address2HDIndexDict[address] != nil
    }
    
    func isAddressPartOfAccount(address: String) -> Bool {
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
    
    func getAccountAmountChangeForTx(txHash: String) -> TLCoin? {
        return txidToAccountAmountDict[txHash]
    }
    
    func getAccountAmountChangeTypeForTx(txHash: String) -> TLAccountTxType {
        return TLAccountTxType(rawValue: txidToAccountAmountTypeDict[txHash]!)!
    }
    
    private func addToAddressBalance(address: NSString, amount: TLCoin) -> () {
        var addressBalance = address2BalanceDict[address as String]
        if (addressBalance == nil) {
            addressBalance = amount
            address2BalanceDict[address as String] = addressBalance!
        } else {
            addressBalance! = addressBalance!.add(amount)
            address2BalanceDict[address as String] = addressBalance!
        }
    }
    
    private func subtractToAddressBalance(address: String, amount: TLCoin) -> () {
        var addressBalance = address2BalanceDict[address]
        if (addressBalance == nil) {
            addressBalance = TLCoin.zero().subtract(amount)
            address2BalanceDict[address] = addressBalance!
        } else {
            addressBalance = addressBalance!.subtract(amount)
            address2BalanceDict[address] = addressBalance!
        }
    }
    
    func processNewTx(txObject: TLTxObject) -> TLCoin? {
        if (processedTxDict[txObject.getHash()! as String] != nil) {
            return nil
        }
        processedTxDict[txObject.getHash()! as String] = true
        
        let receivedAmount = processTx(txObject, shouldCheckToAddressesNTxsCount: true, shouldUpdateAccountBalance: true)
        
        
        txObjectArray.insert(txObject, atIndex: 0)
        
        checkToArchiveAddresses()
        updateReceivingAddresses()
        updateChangeAddresses()
        return receivedAmount
    }
    
    private func processTx(txObject: TLTxObject, shouldCheckToAddressesNTxsCount: Bool, shouldUpdateAccountBalance: Bool) -> TLCoin? {
        var currentTxSubtract:UInt64 = 0
        var currentTxAdd:UInt64 = 0
        
        let address2hasUpdatedNTxCount = NSMutableDictionary()
        
        //DLog("processTx: \(self.getAccountID()) \(txObject.getTxid()!)")
    
        let outputAddressToValueArray = txObject.getOutputAddressToValueArray()

        for _output in outputAddressToValueArray! {
            let output = _output as! NSDictionary
            
            let value:UInt64
            if let v = output.objectForKey("value") as? NSNumber {
                value = UInt64(v.unsignedLongLongValue)
            } else {
                value = 0
            }
            
            if let address = output.objectForKey("addr") as? String {
                
                if (isActiveAddress(address)) {
                    
                    currentTxAdd += value
                    //DLog("addToAddressBalance: \(address) \(value)")
                    if (shouldUpdateAccountBalance) {
                        addToAddressBalance(address, amount: TLCoin(uint64: value))
                    }
                    
                    if (shouldCheckToAddressesNTxsCount &&
                        address2hasUpdatedNTxCount.objectForKey(address) == nil) {
                            
                            address2hasUpdatedNTxCount.setObject("", forKey: address)
                            
                            let ntxs = getNumberOfTransactionsForAddress(address)!
                            address2NumberOfTransactions[address] = ntxs + 1
                    }
                } else if self.stealthWallet != nil && self.stealthWallet!.isPaymentAddress(address) {
                    currentTxAdd += value
                    //DLog("addToAddressBalance: stealth \(address) \(value)")
                    if shouldUpdateAccountBalance {
                        addToAddressBalance(address, amount: TLCoin(uint64: value))
                    }
                } else {
                }
            }
        }
        
        let inputAddressToValueArray = txObject.getInputAddressToValueArray()
        for _input in inputAddressToValueArray! {
            let input = _input as! NSDictionary
            
            let value:UInt64
            if let v = input.objectForKey("value") as? NSNumber {
                value = UInt64(v.unsignedLongLongValue)
            } else {
                value = 0
            }

            if let address = input.objectForKey("addr") as? String {

                if (isActiveAddress(address)) {
                        
                    currentTxSubtract += value
                    //DLog("subtractToAddressBalance: \(address) \(value)")
                    if (shouldUpdateAccountBalance) {
                        subtractToAddressBalance(address, amount: TLCoin(uint64: value))
                    }
                    
                    if (shouldCheckToAddressesNTxsCount &&
                        address2hasUpdatedNTxCount.objectForKey(address) == nil) {
                            
                            address2hasUpdatedNTxCount.setObject("", forKey: address)
                            let ntxs = getNumberOfTransactionsForAddress(address)!
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
            txidToAccountAmountTypeDict[txObject.getHash()! as String] = Int(TLAccountTxType.Send.rawValue)
            return nil
        } else if (currentTxSubtract < currentTxAdd) {
            let amountChangeToAccountFromTx = TLCoin(uint64: UInt64(currentTxAdd - currentTxSubtract))
            txidToAccountAmountDict[txObject.getHash()! as String] = amountChangeToAccountFromTx
            txidToAccountAmountTypeDict[txObject.getHash()! as String] = Int(TLAccountTxType.Receive.rawValue)
            return amountChangeToAccountFromTx
        } else {
            let amountChangeToAccountFromTx = TLCoin.zero()
            txidToAccountAmountDict[txObject.getHash()! as String] = amountChangeToAccountFromTx
            txidToAccountAmountTypeDict[txObject.getHash()! as String] = Int(TLAccountTxType.MoveBetweenAccount.rawValue)
            return nil
        }
    }
    
    func getReceivingAddressesCount() -> Int {
        return receivingAddressesArray.count
    }
    
    func getReceivingAddress(idx: Int) -> (String) {
        return receivingAddressesArray[idx]
    }
    
    private func updateReceivingAddresses() -> () {
        receivingAddressesArray = [String]()
        
        var addressIdx = 0
        for (addressIdx = 0; addressIdx < mainActiveAddresses.count; addressIdx++) {
            let address = mainActiveAddresses[addressIdx]
            if (getNumberOfTransactionsForAddress(address)! == 0) {
                break
            }
        }
        
        var lookedAtAllAddresses = false
        var receivingAddressesStartIdx = -1
        for (; addressIdx < addressIdx + TLAccountObject.MAX_ACCOUNT_WAIT_TO_RECEIVE_ADDRESS(); addressIdx++) {
            if (addressIdx >= getMainActiveAddressesCount()) {
                lookedAtAllAddresses = true
                break
            }
            
            let address = mainActiveAddresses[addressIdx]
            if (getNumberOfTransactionsForAddress(address)! == 0) {
                receivingAddressesArray.append(address)
                if receivingAddressesStartIdx == -1 {
                    receivingAddressesStartIdx = addressIdx
                }
            }
            if (receivingAddressesArray.count >= TLAccountObject.MAX_ACCOUNT_WAIT_TO_RECEIVE_ADDRESS() ||
                addressIdx - receivingAddressesStartIdx >= TLAccountObject.MAX_ACCOUNT_WAIT_TO_RECEIVE_ADDRESS()) {
                    break
            }
        }
        
        while (lookedAtAllAddresses && receivingAddressesArray.count < TLAccountObject.MAX_ACCOUNT_WAIT_TO_RECEIVE_ADDRESS()) {
            let address = getNewMainAddress(getMainAddressesCount())
            addressIdx++
            if (addressIdx - receivingAddressesStartIdx < TLAccountObject.MAX_ACCOUNT_WAIT_TO_RECEIVE_ADDRESS()) {
                receivingAddressesArray.append(address)
            } else {
                break
            }
        }
        
        while (getMainActiveAddressesCount() - addressIdx < ACCOUNT_UNUSED_ACTIVE_MAIN_ADDRESS_AHEAD_OF_LATEST_USED_ONE_MINIMUM_COUNT) {
            getNewMainAddress(getMainAddressesCount())
        }

        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_UPDATED_RECEIVING_ADDRESSES(), object: nil)
    }
    
    
    private func updateChangeAddresses() -> () {
        var addressIdx = 0
        for (; addressIdx < changeActiveAddresses.count; addressIdx++) {
                let address = changeActiveAddresses[addressIdx]
            if (getNumberOfTransactionsForAddress(address)! == 0) {
                break
            }
        }
        while (getChangeActiveAddressesCount() - addressIdx < ACCOUNT_UNUSED_ACTIVE_CHANGE_ADDRESS_AHEAD_OF_LATEST_USED_ONE_MINIMUM_COUNT) {
            getNewChangeAddress(getChangeAddressesCount())
        }
    }
    
    
    private func checkToArchiveAddresses() -> () {
        self.checkToArchiveMainAddresses()
        self.checkToArchiveChangeAddresses()
    }
    
    private func checkToArchiveMainAddresses() -> () {
        if (getMainActiveAddressesCount() <= MAX_ACTIVE_MAIN_ADDRESS_TO_HAVE) {
            return
        }

        let activeMainAddresses = getActiveMainAddresses()!.copy() as! NSArray

        for _address in activeMainAddresses {
            let address = _address as! String
            if (getAddressBalance(address).lessOrEqual(TLCoin.zero()) &&
                getNumberOfTransactionsForAddress(address)! > 0) {

                    let addressIdx = address2HDIndexDict[address]!
                    let accountIdx = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
                    
                    if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
                        
                        assert(addressIdx == mainArchivedAddresses.count, "")
                        mainArchivedAddresses.append(address)
                    } else {
                        if (accountType == TLAccountType.HDWallet) {
                            assert(addressIdx == self.appWallet!.getMinMainAddressIdxFromHDWallet(accountIdx), "")
                        } else if (accountType == TLAccountType.Imported) {
                            assert(addressIdx == self.appWallet!.getMinMainAddressIdxFromImportedAccount(getPositionInWalletArray()), "")
                        } else {
                            assert(addressIdx == self.appWallet!.getMinMainAddressIdxFromImportedWatchAccount(getPositionInWalletArray()), "")
                        }
                    }
                    
                    assert(mainActiveAddresses.first == address, "")
                    mainActiveAddresses.removeAtIndex(mainActiveAddresses.indexOf(address)!)
                    activeAddressesDict.removeValueForKey(address)
                    if (accountType == TLAccountType.HDWallet) {
                        self.appWallet!.updateMainAddressStatusFromHDWallet(accountIdx,
                            addressIdx: addressIdx,
                            addressStatus: TLAddressStatus.Archived)
                    } else if (accountType == TLAccountType.Imported) {
                        self.appWallet!.updateMainAddressStatusFromImportedAccount(getPositionInWalletArray(),
                            addressIdx: addressIdx,
                            addressStatus: TLAddressStatus.Archived)
                    } else {
                        self.appWallet!.updateMainAddressStatusFromImportedWatchAccount(getPositionInWalletArray(),
                            addressIdx: addressIdx,
                            addressStatus: TLAddressStatus.Archived)
                    }
            } else {
                return
            }
            if (getMainActiveAddressesCount() <= MAX_ACTIVE_MAIN_ADDRESS_TO_HAVE) {
                return
            }
        }
    }
    
    private func checkToArchiveChangeAddresses() -> () {
        if (getChangeActiveAddressesCount() <= MAX_ACTIVE_CHANGE_ADDRESS_TO_HAVE) {
            return
        }
        
        let activeChangeAddresses = getActiveChangeAddresses()!.copy() as! NSArray
        
        for _address in activeChangeAddresses {
            let address = _address as! String
            
            if (getAddressBalance(address).lessOrEqual(TLCoin.zero()) &&
                getNumberOfTransactionsForAddress(address)! > 0) {
                    
                    let addressIdx = address2HDIndexDict[address]!
                    let accountIdx = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
                    
                    if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
                        assert(addressIdx == changeArchivedAddresses.count, "")
                        changeArchivedAddresses.append(address)
                    } else {
                        if (accountType == TLAccountType.HDWallet) {
                            assert(addressIdx == self.appWallet!.getMinChangeAddressIdxFromHDWallet(accountIdx), "")
                        } else if (accountType == TLAccountType.Imported) {
                            assert(addressIdx == self.appWallet!.getMinChangeAddressIdxFromImportedAccount(getPositionInWalletArray()), "")
                        } else {
                            assert(addressIdx == self.appWallet!.getMinChangeAddressIdxFromImportedWatchAccount(getPositionInWalletArray()), "")
                        }
                    }
                    
                    assert(changeActiveAddresses.first == address, "")
                    changeActiveAddresses.removeAtIndex(changeActiveAddresses.indexOf(address)!)
                    activeAddressesDict.removeValueForKey(address)
                    if (accountType == TLAccountType.HDWallet) {
                        self.appWallet!.updateChangeAddressStatusFromHDWallet(accountIdx,
                            addressIdx: addressIdx,
                            addressStatus: TLAddressStatus.Archived)
                    } else if (accountType == TLAccountType.Imported) {
                        self.appWallet!.updateChangeAddressStatusFromImportedAccount(getPositionInWalletArray(),
                            addressIdx: addressIdx,
                            addressStatus: TLAddressStatus.Archived)
                    } else {
                        self.appWallet!.updateChangeAddressStatusFromImportedWatchAccount(getPositionInWalletArray(),
                            addressIdx: addressIdx,
                            addressStatus: TLAddressStatus.Archived)
                    }
            } else {
                return
            }
            if (getChangeActiveAddressesCount() <= MAX_ACTIVE_CHANGE_ADDRESS_TO_HAVE) {
                return
            }
        }
    }
    
    private func processTxArray(txArray: NSArray, shouldResetAccountBalance: (Bool)) -> () {
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
    
    func setPositionInWalletArray(idx: Int) -> () {
        positionInWalletArray = idx
    }
    
    private func getNewMainAddress(expectedAddressIndex: Int) -> String {
        let addressDict: NSDictionary
        
        if (accountType == TLAccountType.HDWallet) {
            let accountIdx = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
            addressDict = self.appWallet!.getNewMainAddressFromHDWallet(accountIdx, expectedAddressIndex: expectedAddressIndex)
        } else if (accountType == TLAccountType.Imported) {
            addressDict = self.appWallet!.getNewMainAddressFromImportedAccount(positionInWalletArray, expectedAddressIndex: expectedAddressIndex)
        } else {
            addressDict = self.appWallet!.getNewMainAddressFromImportedWatchAccount(positionInWalletArray, expectedAddressIndex: expectedAddressIndex)
        }
        
        let address = addressDict.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
        let HDIndex = addressDict.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX) as! Int
        address2HDIndexDict[address] = HDIndex
        address2IsMainAddress[address] = true
        address2BalanceDict[address] = TLCoin.zero()
        address2NumberOfTransactions[address] = 0
        mainActiveAddresses.append(address)
        activeAddressesDict[address] = true
        
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_NEW_ADDRESS_GENERATED(), object: address)
        
        return address
    }
    
    private func getNewChangeAddress(expectedAddressIndex: Int) -> (String) {
        let addressDict: NSDictionary
        
        if (accountType == TLAccountType.HDWallet) {
            let accountIdx = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
            addressDict = self.appWallet!.getNewChangeAddressFromHDWallet(accountIdx, expectedAddressIndex: expectedAddressIndex)
        } else if (accountType == TLAccountType.Imported) {
            addressDict = self.appWallet!.getNewChangeAddressFromImportedAccount(positionInWalletArray, expectedAddressIndex: expectedAddressIndex)
        } else {
            addressDict = self.appWallet!.getNewChangeAddressFromImportedWatchAccount(UInt(positionInWalletArray), expectedAddressIndex: expectedAddressIndex)
        }
        
        let address = addressDict.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String
        let HDIndex = addressDict.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX) as! Int
        address2HDIndexDict[address] = HDIndex
        address2IsMainAddress[address] = false
        address2BalanceDict[address] = TLCoin.zero()
        address2NumberOfTransactions[address] = 0
        changeActiveAddresses.append(address)
        activeAddressesDict[address] = true
        
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_NEW_ADDRESS_GENERATED(), object: address)
        
        return address
    }
    
    private func removeTopMainAddress() -> (Bool) {
        if (accountType == TLAccountType.HDWallet) {
            let accountIdx = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
            self.appWallet!.removeTopMainAddressFromHDWallet(accountIdx)!
        } else if (accountType == TLAccountType.Imported) {
            self.appWallet!.removeTopMainAddressFromImportedAccount(positionInWalletArray)!
        } else if (accountType == TLAccountType.ImportedWatch) {
            self.appWallet!.removeTopMainAddressFromImportedWatchAccount(positionInWalletArray)!
        }
        
        if (mainActiveAddresses.count > 0) {
            let address = mainActiveAddresses.last!
            address2HDIndexDict.removeValueForKey(address)
            address2BalanceDict.removeValueForKey(address)
            address2NumberOfTransactions.removeValueForKey(address)
            mainActiveAddresses.removeLast()
            activeAddressesDict.removeValueForKey(address)
            return true
        } else if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            if (mainArchivedAddresses.count > 0) {
                let address = mainArchivedAddresses.last!
                address2HDIndexDict.removeValueForKey(address)
                address2BalanceDict.removeValueForKey(address)
                address2NumberOfTransactions.removeValueForKey(address)
                mainArchivedAddresses.removeLast()
                activeAddressesDict.removeValueForKey(address)
            }
            return true
        }
        
        return false
    }
    
    private func removeTopChangeAddress() -> (Bool) {
        if (accountType == TLAccountType.HDWallet) {
            let accountIdx = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
            self.appWallet!.removeTopChangeAddressFromHDWallet(accountIdx)!
        } else if (accountType == TLAccountType.Imported) {
            self.appWallet!.removeTopChangeAddressFromImportedAccount(positionInWalletArray)!
        } else if (accountType == TLAccountType.ImportedWatch) {
            self.appWallet!.removeTopChangeAddressFromImportedWatchAccount(positionInWalletArray)!
        }
        
        if (changeActiveAddresses.count > 0) {
            let address = changeActiveAddresses.last!
            address2HDIndexDict.removeValueForKey(address)
            address2BalanceDict.removeValueForKey(address)
            address2NumberOfTransactions.removeValueForKey(address)
            changeActiveAddresses.removeLast()
            activeAddressesDict.removeValueForKey(address)
            
            return true
        } else if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            if (changeArchivedAddresses.count > 0) {
                let address = changeArchivedAddresses.last!
                address2HDIndexDict.removeValueForKey(address)
                address2BalanceDict.removeValueForKey(address)
                address2NumberOfTransactions.removeValueForKey(address)
                changeArchivedAddresses.removeLast()
                activeAddressesDict.removeValueForKey(address)
                
            }
            return true
        }
        
        return false
    }
    
    func getCurrentChangeAddress() -> String {
        for address in changeActiveAddresses {
            if getNumberOfTransactionsForAddress(address)! == 0 && self.getAddressBalance(address).equalTo(TLCoin.zero()) {
                return address
            }
        }

        return getNewChangeAddress(getChangeAddressesCount())
    }
    
    func getActiveMainAddresses() -> NSArray? {
        return mainActiveAddresses
    }
    
    func getActiveChangeAddresses() -> NSArray? {
        return changeActiveAddresses
    }
    
    func getMainActiveAddressesCount() -> Int {
        return mainActiveAddresses.count
    }
    
    func getMainArchivedAddressesCount() -> Int {
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            return mainArchivedAddresses.count
        } else {
            if (accountType == TLAccountType.HDWallet) {
                let accountIdx = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
                return self.appWallet!.getMinMainAddressIdxFromHDWallet(accountIdx)
            } else if (accountType == TLAccountType.Imported) {
                return self.appWallet!.getMinMainAddressIdxFromImportedAccount(getPositionInWalletArray())
            } else {
                return self.appWallet!.getMinMainAddressIdxFromImportedWatchAccount(getPositionInWalletArray())
            }
        }
    }
    
    private func getMainAddressesCount() -> Int {
        return getMainActiveAddressesCount() + getMainArchivedAddressesCount()
    }
    
    func getChangeActiveAddressesCount() -> Int {
        return changeActiveAddresses.count
    }
    
    func getChangeArchivedAddressesCount() -> Int {
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            return changeArchivedAddresses.count
        } else {
            if (accountType == TLAccountType.HDWallet) {
                let accountIdx = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
                return self.appWallet!.getMinChangeAddressIdxFromHDWallet(accountIdx)
            } else if (accountType == TLAccountType.Imported) {
                return self.appWallet!.getMinChangeAddressIdxFromImportedAccount(getPositionInWalletArray())
            } else {
                return self.appWallet!.getMinChangeAddressIdxFromImportedWatchAccount(getPositionInWalletArray())
            }
        }
    }
    
    private func getChangeAddressesCount() -> Int {
        return getChangeActiveAddressesCount() + getChangeArchivedAddressesCount()
    }
    
    func getMainActiveAddress(idx: Int) -> String {
        return mainActiveAddresses[idx]
    }
    
    func getChangeActiveAddress(idx: Int) -> String {
        return changeActiveAddresses[idx]
    }
    
    func getMainArchivedAddress(idx: Int) -> String {
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            return mainArchivedAddresses[idx]
        } else {
            let HDIndex = idx
            var address = HDIndexToArchivedMainAddress[HDIndex]
            if (address == nil) {
                let extendedPublicKey = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY) as! String
                let mainAddressSequence = [Int(TLAddressType.Main.rawValue), idx]
                address = TLHDWalletWrapper.getAddress(extendedPublicKey, sequence: mainAddressSequence, isTestnet: self.appWallet!.walletConfig.isTestnet)
                HDIndexToArchivedMainAddress[HDIndex] = address!
                
                address2HDIndexDict[address!] = HDIndex
                address2IsMainAddress[address!] = true
            }
            return address!
        }
    }
    
    func getChangeArchivedAddress(idx: Int) -> String {
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            return changeArchivedAddresses[idx]
        } else {
            let HDIndex = idx
            var address = HDIndexToArchivedChangeAddress[HDIndex]
            if (address == nil) {
                let extendedPublicKey = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY) as! String
                let mainAddressSequence = [Int(TLAddressType.Main.rawValue), idx]
                address = TLHDWalletWrapper.getAddress(extendedPublicKey, sequence: mainAddressSequence, isTestnet: self.appWallet!.walletConfig.isTestnet)
                HDIndexToArchivedChangeAddress[HDIndex] = address!
                
                address2HDIndexDict[address!] = HDIndex
                address2IsMainAddress[address!] = false
            }
            return address!
        }
    }
    
    func recoverAccountMainAddresses(shouldResetAccountBalance: Bool) -> Int {
        var lookAheadOffset = 0
        var continueLookingAheadAddress = true
        DLog("recoverAccountMainAddresses: getAccountID: %@", function: getAccountID())
        var accountAddressIdx = -1
        
        while (continueLookingAheadAddress) {
            var addresses = [String]()
            addresses.reserveCapacity(GAP_LIMIT)
            
            let addressToIdxDict = NSMutableDictionary(capacity: GAP_LIMIT)
            
            for (var i = lookAheadOffset; i < lookAheadOffset + GAP_LIMIT; i++) {
                let address = getNewMainAddress(i)
                DLog(String(format:"getNewMainAddress HDIdx: %lu address: %@", i, address))
                addresses.append(address)
                addressToIdxDict.setObject(i, forKey: address)
            }

            let jsonData = getAccountDataSynchronous(addresses,
                shouldResetAccountBalance: shouldResetAccountBalance,
                shouldProcessTxArray: false)
                        
            let addressesArray = jsonData!.objectForKey("addresses") as! NSArray
            var balance:UInt64 = 0
            for _addressDict in addressesArray {
                let addressDict = _addressDict as! NSDictionary
                let n_tx = addressDict.objectForKey("n_tx") as! Int
                let address = addressDict.objectForKey("address") as! String
                address2NumberOfTransactions[address] = n_tx
                let addressBalance = (addressDict.objectForKey("final_balance") as! NSNumber).unsignedLongLongValue
                balance += addressBalance
                address2BalanceDict[address] = TLCoin(uint64: addressBalance)

                
                let HDIdx = addressToIdxDict.objectForKey(address) as! Int
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
    
    private func recoverAccountChangeAddresses(shouldResetAccountBalance: Bool) -> Int {
        var lookAheadOffset = 0
        var continueLookingAheadAddress = true
        var accountAddressIdx = -1
        
        
        while (continueLookingAheadAddress) {
            var addresses = [String]()
            addresses.reserveCapacity(GAP_LIMIT)
            let addressToIdxDict = NSMutableDictionary(capacity: GAP_LIMIT)
            for (var i = lookAheadOffset; i < lookAheadOffset + GAP_LIMIT; i++) {
                let address = getNewChangeAddress(i)
                DLog(String(format:"getNewChangeAddress HDIdx: %lu address: %@", i, address))
                addresses.append(address)
                addressToIdxDict.setObject(i, forKey: address)
            }
            
            let jsonData = getAccountDataSynchronous(addresses,
                shouldResetAccountBalance: shouldResetAccountBalance,
                shouldProcessTxArray: false)
            
            let addressesArray = jsonData!.objectForKey("addresses") as! NSArray
            var balance:UInt64 = 0
            for _addressDict in addressesArray {
                let addressDict = _addressDict as! NSDictionary
                let n_tx = addressDict.objectForKey("n_tx") as! Int
                let address = addressDict.objectForKey("address") as! String
                address2NumberOfTransactions[address] = n_tx
                let addressBalance = (addressDict.objectForKey("final_balance") as! NSNumber).unsignedLongLongValue
                balance += addressBalance
                address2BalanceDict[address] = TLCoin(uint64: addressBalance)
                
                let HDIdx = addressToIdxDict.objectForKey(address) as! Int
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
    
    func recoverAccount(shouldResetAccountBalance: Bool, recoverStealthPayments: Bool=false) -> Int {
        let accountMainAddressMaxIdx = recoverAccountMainAddresses(shouldResetAccountBalance)
        let accountChangeAddressMaxIdx = recoverAccountChangeAddresses(shouldResetAccountBalance)
        
        checkToArchiveAddresses()
        updateReceivingAddresses()
        updateChangeAddresses()
        if recoverStealthPayments && self.stealthWallet != nil {
            let semaphore = dispatch_semaphore_create(0)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                self.fetchNewStealthPayments(recoverStealthPayments)
                dispatch_semaphore_signal(semaphore)
            }
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        }
        
        updateAccountNeedsRecovering(false)
        return accountMainAddressMaxIdx + accountChangeAddressMaxIdx
    }
    
    func updateAccountNeedsRecovering(needsRecovering: Bool) -> () {
        if (accountType == TLAccountType.HDWallet) {
            let accountIdx = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
            self.appWallet!.updateAccountNeedsRecoveringFromHDWallet(accountIdx, accountNeedsRecovering: needsRecovering)
        } else if (accountType == TLAccountType.Imported) {
            self.appWallet!.updateAccountNeedsRecoveringFromImportedAccount(getPositionInWalletArray(), accountNeedsRecovering: needsRecovering)
        } else {
            self.appWallet!.updateAccountNeedsRecoveringFromImportedWatchAccount(getPositionInWalletArray(), accountNeedsRecovering: needsRecovering)
        }
        accountDict!.setObject(needsRecovering, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING)
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
        
        
        if (accountType == TLAccountType.HDWallet) {
            let accountIdx = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int
            self.appWallet!.clearAllAddressesFromHDWallet(accountIdx)
            self.appWallet!.clearAllStealthPaymentsFromHDWallet(accountIdx)
        } else if (accountType == TLAccountType.Imported) {
            self.appWallet!.clearAllAddressesFromImportedAccount(getPositionInWalletArray())
            self.appWallet!.clearAllStealthPaymentsFromImportedAccount(getPositionInWalletArray())
        } else {
            self.appWallet!.clearAllAddressesFromImportedWatchAccount(getPositionInWalletArray())
        }
        

    }
    
    func needsRecovering() -> (Bool) {
        let needsRecovering = accountDict!.objectForKey(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING) as! Bool
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
            let amount = unspentOutput.objectForKey("value") as! NSNumber
            totalUnspentOutputsSumTemp += amount.unsignedLongLongValue
        }
        
        for _unspentOutput in unspentOutputs! {
            let unspentOutput = _unspentOutput as! NSDictionary
            let amount = unspentOutput.objectForKey("value") as! NSNumber
            totalUnspentOutputsSumTemp += amount.unsignedLongLongValue
        }
        
        totalUnspentOutputsSum = TLCoin(uint64: totalUnspentOutputsSumTemp)
        return totalUnspentOutputsSum!
    }
    
    func getUnspentOutputs(success: TLWalletUtils.Success, failure:TLWalletUtils.Error) {
        var activeAddresses = getActiveMainAddresses()! as! [String]
        activeAddresses += getActiveChangeAddresses()! as! [String]
        
        if self.stealthWallet != nil {
            activeAddresses += self.stealthWallet!.getUnspentPaymentAddresses()
        }
        
        unspentOutputs = nil
        totalUnspentOutputsSum = nil
        stealthPaymentUnspentOutputs = nil
        
        TLBlockExplorerAPI.instance().getUnspentOutputs(activeAddresses, success: {
            (jsonData: AnyObject!) in
            let unspentOutputs = (jsonData as! NSDictionary).objectForKey("unspent_outputs") as! NSArray!
            self.unspentOutputs = NSMutableArray(capacity: unspentOutputs.count)
            self.stealthPaymentUnspentOutputs = NSMutableArray(capacity: unspentOutputs.count)

            for unspentOutput in unspentOutputs! {
                let outputScript = unspentOutput.objectForKey("script") as! String
                
                let address = TLCoreBitcoinWrapper.getAddressFromOutputScript(outputScript, isTestnet: self.appWallet!.walletConfig.isTestnet)
                if (address == nil) {
                    DLog("address cannot be decoded. not normal pubkeyhash outputScript: %@", function: outputScript)
                    continue
                }
                if self.stealthWallet != nil && self.stealthWallet!.isPaymentAddress(address!) == true {
                    self.stealthPaymentUnspentOutputs!.addObject(unspentOutput)
                } else {
                    self.unspentOutputs!.addObject(unspentOutput)
                }
            }
        
            self.unspentOutputs = NSMutableArray(array: self.unspentOutputs!.sortedArrayUsingComparator {
                (obj1, obj2) -> NSComparisonResult in
                
                var confirmations1 = 0
                var confirmations2 = 0
                
                if let c1 = (obj1 as! NSDictionary).objectForKey("confirmations") as? Int {
                    confirmations1 = c1
                }
                
                if let c2 = (obj2 as! NSDictionary).objectForKey("confirmations") as? Int {
                    confirmations2 = c2
                }

                if confirmations1 > confirmations2 {
                    return .OrderedAscending
                } else if confirmations1 < confirmations2 {
                    return .OrderedDescending
                } else {
                    return .OrderedSame
                }
            })
            
            self.stealthPaymentUnspentOutputs = NSMutableArray(array: self.stealthPaymentUnspentOutputs!.sortedArrayUsingComparator {
                (obj1, obj2) -> NSComparisonResult in
                
                var confirmations1 = 0
                var confirmations2 = 0
                
                if let c1 = (obj1 as! NSDictionary).objectForKey("confirmations") as? Int {
                    confirmations1 = c1
                }
                
                if let c2 = (obj2 as! NSDictionary).objectForKey("confirmations") as? Int {
                    confirmations2 = c2
                }
                
                if confirmations1 > confirmations2 {
                    return .OrderedAscending
                } else if confirmations1 < confirmations2 {
                    return .OrderedDescending
                } else {
                    return .OrderedSame
                }
            })

            success()
            }, failure: {
                (code: NSInteger, status: String!) in
                failure()
        })
    }
    
    func fetchNewStealthPayments(isRestoringAccount: Bool) {
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
            offset += TLWalletJSONKeys.STATIC_MEMBERS.STEALTH_PAYMENTS_FETCH_COUNT
        }
        
        self.setStealthAddressLastTxTime(TLPreferences.getStealthExplorerURL()!, lastTxTime: currentLatestTxTime)
        
        if isRestoringAccount {
            self.stealthWallet!.setUpStealthPaymentAddresses(true, isSetup: true, async: false)
            self.stealthWallet!.setUpStealthPaymentAddresses(true, isSetup: true, async: false)
        }
    }
    
    func getAccountData(addresses: Array<String>, shouldResetAccountBalance: Bool,
        success: TLWalletUtils.Success, failure:TLWalletUtils.Error) -> () {
            
            TLBlockExplorerAPI.instance().getAddressesInfo(addresses, success: {
                (_jsonData: AnyObject!) in
                let jsonData = _jsonData as! NSDictionary
                if (shouldResetAccountBalance) {
                    self.resetAccountBalances()
                }
                
                let addressesDict = jsonData.objectForKey("addresses") as! NSArray
                var balance:UInt64 = 0
                for _addressDict in addressesDict {
                    let addressDict = _addressDict as! NSDictionary
                    let n_tx = addressDict.objectForKey("n_tx") as! Int
                    let address = addressDict.objectForKey("address") as! String
                    self.address2NumberOfTransactions[address] = n_tx
                    let addressBalance = (addressDict.objectForKey("final_balance") as! NSNumber).unsignedLongLongValue
                    balance += addressBalance
                    self.address2BalanceDict[address] = TLCoin(uint64: addressBalance)
                }
                self.accountBalance = TLCoin(uint64: self.accountBalance.toUInt64() + balance)
                
                self.processTxArray(jsonData.objectForKey("txs") as! NSArray, shouldResetAccountBalance: true)
                
                
                self.fetchedAccountData = true
                self.subscribeToWebsockets()
                self.downloadState = .Downloaded
                DLog("postNotificationName: EVENT_FETCHED_ADDRESSES_DATA \(self.getAccountIdxNumber())")
                NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA(), object: nil)
                success()
                },
                failure: {
                    (code: NSInteger, status: String!) in
                    failure()
            })
    }
    
    private func getAccountDataSynchronous(addresses: Array<String>, shouldResetAccountBalance: Bool, shouldProcessTxArray: Bool) -> NSDictionary? {
        let jsonData = TLBlockExplorerAPI.instance().getAddressesInfoSynchronous(addresses)
        if (jsonData.objectForKey(TLNetworking.STATIC_MEMBERS.HTTP_ERROR_CODE) == nil) {
            if (shouldResetAccountBalance) {
                resetAccountBalances()
            }
            
            let addressesArray = jsonData.objectForKey("addresses") as! NSArray
            var balance:UInt64 = 0
            for _addressDict in addressesArray {
                let addressDict = _addressDict as! NSDictionary
                let n_tx = addressDict.objectForKey("n_tx") as! Int
                let address = addressDict.objectForKey("address") as! String
                address2NumberOfTransactions[address] = n_tx
                let addressBalance = (addressDict.objectForKey("final_balance") as! NSNumber).unsignedLongLongValue
                balance += addressBalance
                address2BalanceDict[address] = TLCoin(uint64: addressBalance)
            }
            self.accountBalance = TLCoin(uint64: self.accountBalance.toUInt64() + balance)
            
            if (shouldProcessTxArray) {
                self.processTxArray(jsonData.objectForKey("txs") as! NSArray, shouldResetAccountBalance: false)
                self.fetchedAccountData = false //need to be false because after recovering account need to fetch stealth payments
            }
        } else {
            DLog("getAccountDataSynchronous error \(jsonData.description)")
            NSException(name: "Network Error", reason: "HTTP Error", userInfo: nil).raise()
        }
        
        return jsonData
    }
    
    
    private func resetAccountBalances() -> () {
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
    
    func setStealthAddressServerStatus(serverURL: String, isWatching: Bool) -> () {
        if (self.accountType == TLAccountType.HDWallet) {
            let accountIdx = self.getAccountIdxNumber()
            self.appWallet!.setStealthAddressServerStatusHDWallet(accountIdx, serverURL: serverURL, isWatching: isWatching)
        } else if (self.accountType == TLAccountType.Imported) {
            self.appWallet!.setStealthAddressServerStatusImportedAccount(self.getPositionInWalletArray(), serverURL: serverURL, isWatching: isWatching)
        } else {
            self.appWallet!.setStealthAddressServerStatusImportedWatchAccount(self.getPositionInWalletArray(), serverURL: serverURL, isWatching: isWatching)
        }
    }

    func setStealthAddressLastTxTime(serverURL: String, lastTxTime: UInt64) -> () {
        if (self.accountType == TLAccountType.HDWallet) {
            let accountIdx = self.getAccountIdxNumber()
            self.appWallet!.setStealthAddressLastTxTimeHDWallet(accountIdx, serverURL: serverURL, lastTxTime: lastTxTime)
        } else if (self.accountType == TLAccountType.Imported) {
            self.appWallet!.setStealthAddressLastTxTimeImportedAccount(self.getPositionInWalletArray(), serverURL: serverURL, lastTxTime: lastTxTime)
        } else {
            self.appWallet!.setStealthAddressLastTxTimeImportedWatchAccount(self.getPositionInWalletArray(), serverURL: serverURL, lastTxTime: lastTxTime)
        }
    }
    
    func addStealthAddressPaymentKey(privateKey:String, address:String, txid: String, txTime: UInt64, stealthPaymentStatus: TLStealthPaymentStatus) -> () {
        if (accountType == TLAccountType.HDWallet) {
            let accountIdx = self.getAccountIdxNumber()
            self.appWallet!.addStealthAddressPaymentKeyHDWallet(accountIdx, privateKey:privateKey,
                address:address, txid:txid, txTime: txTime, stealthPaymentStatus: stealthPaymentStatus)
        } else if (accountType == TLAccountType.Imported) {
            self.appWallet!.addStealthAddressPaymentKeyImportedAccount(self.getPositionInWalletArray(),
                privateKey:privateKey, address:address, txid:txid, txTime: txTime, stealthPaymentStatus: stealthPaymentStatus)
        } else if (accountType == TLAccountType.ImportedWatch) {
            self.appWallet!.addStealthAddressPaymentKeyImportedWatchAccount(self.getPositionInWalletArray(),
                privateKey:privateKey, address:address, txid:txid, txTime: txTime, stealthPaymentStatus: stealthPaymentStatus)
        }
    }
    
    func setStealthPaymentStatus(txid: String, stealthPaymentStatus: TLStealthPaymentStatus, lastCheckTime: UInt64) -> () {
        if (accountType == TLAccountType.HDWallet) {
            let accountIdx = self.getAccountIdxNumber()
            self.appWallet!.setStealthPaymentStatusHDWallet(accountIdx, txid:txid,
                stealthPaymentStatus:stealthPaymentStatus, lastCheckTime: lastCheckTime)
        } else if (accountType == TLAccountType.Imported) {
            self.appWallet!.setStealthPaymentStatusImportedAccount(self.getPositionInWalletArray(),
                txid:txid, stealthPaymentStatus:stealthPaymentStatus, lastCheckTime: lastCheckTime)
        } else if (accountType == TLAccountType.ImportedWatch) {
            self.appWallet!.setStealthPaymentStatusImportedWatchAccount(self.getPositionInWalletArray(),
                txid:txid, stealthPaymentStatus:stealthPaymentStatus, lastCheckTime: lastCheckTime)
        }
    }
    
    func removeOldStealthPayments() -> () {
        if (accountType == TLAccountType.HDWallet) {
            let accountIdx = self.getAccountIdxNumber()
            self.appWallet!.removeOldStealthPaymentsHDWallet(accountIdx)
        } else if (accountType == TLAccountType.Imported) {
            self.appWallet!.removeOldStealthPaymentsImportedAccount(self.getPositionInWalletArray())
        } else if (accountType == TLAccountType.ImportedWatch) {
            self.appWallet!.removeOldStealthPaymentsImportedWatchAccount(self.getPositionInWalletArray())
        }
    }

    func setStealthPaymentLastCheckTime(txid: String, lastCheckTime: UInt64) -> () {
        if (accountType == TLAccountType.HDWallet) {
            let accountIdx = self.getAccountIdxNumber()
            self.appWallet!.setStealthPaymentLastCheckTimeHDWallet(accountIdx, txid: txid, lastCheckTime: lastCheckTime)
        } else if (accountType == TLAccountType.Imported) {
            self.appWallet!.setStealthPaymentLastCheckTimeImportedAccount(self.getPositionInWalletArray(), txid: txid, lastCheckTime: lastCheckTime)
        } else if (accountType == TLAccountType.ImportedWatch) {
            self.appWallet!.setStealthPaymentLastCheckTimeImportedWatchAccount(self.getPositionInWalletArray(), txid: txid, lastCheckTime: lastCheckTime)
        }
    }
    
    
    func getAccountDataO() -> () {
        // if account needs recovering dont fetch account data
        if (needsRecovering()) {
            self.downloadState = .Failed
            return
        }


        var activeAddresses = getActiveMainAddresses()! as! [String]
        activeAddresses += getActiveChangeAddresses()! as! [String]
        
        if self.stealthWallet != nil {
            activeAddresses += self.stealthWallet!.getPaymentAddresses()
        }

        if self.stealthWallet != nil {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                self.fetchNewStealthPayments(false)
            }
        }
        
        self.getAccountDataO(activeAddresses, shouldResetAccountBalance: true)
    }
    
    private func getAccountDataO(addresses: Array<String>, shouldResetAccountBalance: Bool) -> () {
        let jsonData = TLBlockExplorerAPI.instance().getAddressesInfoSynchronous(addresses)
        if (jsonData.objectForKey(TLNetworking.STATIC_MEMBERS.HTTP_ERROR_CODE) != nil) {
            self.downloadState = .Failed
            return
        }

        if (shouldResetAccountBalance) {
            self.resetAccountBalances()
        }

        let addressesDict = jsonData.objectForKey("addresses") as! NSArray
        var balance:UInt64 = 0
        for _addressDict in addressesDict {
            let addressDict = _addressDict as! NSDictionary
            let n_tx = addressDict.objectForKey("n_tx") as! Int
            let address = addressDict.objectForKey("address") as! String
            self.address2NumberOfTransactions[address] = n_tx
            let addressBalance = (addressDict.objectForKey("final_balance") as! NSNumber).unsignedLongLongValue
            balance += addressBalance
            self.address2BalanceDict[address] = TLCoin(uint64: addressBalance)
        }
        self.accountBalance = TLCoin(uint64: self.accountBalance.toUInt64() + balance)
        
        self.processTxArray(jsonData.objectForKey("txs") as! NSArray, shouldResetAccountBalance: true)
        
        self.fetchedAccountData = true
        self.subscribeToWebsockets()
        self.downloadState = .Downloaded
        dispatch_async(dispatch_get_main_queue(), {
            DLog("postNotificationName: EVENT_FETCHED_ADDRESSES_DATA \(self.getAccountIdxNumber())")
            NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA(), object: nil)
        })
    }
    
    private func subscribeToWebsockets() -> () {
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