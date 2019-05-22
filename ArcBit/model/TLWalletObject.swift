//
//  TLWalletObject.swift
//  ArcBit
//
//  Created by Timothy Lee on 1/4/18.
//  Copyright © 2018 ArcBit. All rights reserved.
//

import Foundation

@objc class TLWalletObject:NSObject {
    fileprivate var appWallet:TLWallet
    fileprivate var coinType:TLCoinType = TLCoinType.BTC
    let accounts:TLAccounts
    let coldWalletAccounts:TLAccounts
    let importedAccounts:TLAccounts
    let importedWatchAccounts:TLAccounts
    let importedAddresses:TLImportedAddresses
    let importedWatchAddresses:TLImportedAddresses

    init(appWallet: TLWallet, coinType: TLCoinType) {
        self.appWallet = appWallet
        self.coinType = coinType
        accounts = TLAccounts(appWallet: appWallet, coinType:self.coinType, accountsArray: appWallet.getAccountObjectArray(self.coinType), accountType:.hdWallet)
        coldWalletAccounts = TLAccounts(appWallet: appWallet, coinType:self.coinType, accountsArray: appWallet.getColdWalletAccountArray(self.coinType), accountType: .coldWallet)
        importedAccounts = TLAccounts(appWallet: appWallet, coinType:self.coinType, accountsArray: appWallet.getImportedAccountArray(self.coinType), accountType: .imported)
        importedWatchAccounts = TLAccounts(appWallet: appWallet, coinType:self.coinType, accountsArray: appWallet.getWatchOnlyAccountArray(self.coinType), accountType:.importedWatch)
        importedAddresses = TLImportedAddresses(appWallet: appWallet, coinType:self.coinType, importedAddresses: appWallet.getImportedPrivateKeyArray(self.coinType), accountAddressType:TLAccountAddressType.imported)
        importedWatchAddresses = TLImportedAddresses(appWallet: appWallet, coinType:self.coinType, importedAddresses: appWallet.getWatchOnlyAddressArray(self.coinType), accountAddressType:TLAccountAddressType.importedWatch)
    }

    func aAccountNeedsRecovering() -> Bool {
        for i in stride(from: 0, to: accounts.getNumberOfAccounts(), by: 1) {
            let accountObject = accounts.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                return true
            }
        }
        
        for i in stride(from: 0, to: coldWalletAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = coldWalletAccounts.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                return true
            }
        }
        
        for i in stride(from: 0, to: importedAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = importedAccounts.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                return true
            }
        }
                
        for i in stride(from: 0, to: importedWatchAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = importedWatchAccounts.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                return true
            }
        }
        return false
    }
    
    func checkToRecoverAccounts() {
        for i in stride(from: 0, to: accounts.getNumberOfAccounts(), by: 1) {
            let accountObject = accounts.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                accountObject.clearAllAddresses()
                accountObject.recoverAccount(false, recoverStealthPayments: true)
            }
        }
        
        for i in stride(from: 0, to: coldWalletAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = coldWalletAccounts.getAccountObjectForIdx(i)
            if accountObject.needsRecovering() {
                accountObject.clearAllAddresses()
                accountObject.recoverAccount(false, recoverStealthPayments: true)
            }
        }
        
        for i in stride(from: 0, to: importedAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = importedAccounts.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                accountObject.clearAllAddresses()
                accountObject.recoverAccount(false, recoverStealthPayments: true)
            }
        }
        
        for i in stride(from: 0, to: importedWatchAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = importedWatchAccounts.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                accountObject.clearAllAddresses()
                accountObject.recoverAccount(false, recoverStealthPayments: true)
            }
        }
    }
    
    func recoverHDWallet() {
        var accountIdx = 0
        var consecutiveUnusedAccountCount = 0
        let MAX_CONSECUTIVE_UNUSED_ACCOUNT_LOOK_AHEAD_COUNT = 4
        
        while true {
            let accountName = String(format:TLDisplayStrings.ACCOUNT_X_STRING(), (accountIdx + 1))
            let accountObject = accounts.createNewAccount(accountName, accountType:.normal, preloadStartingAddresses:false)
            
            DLog("recoverHDWalletaccountName \(accountName)")
            
            let sumMainAndChangeAddressMaxIdx = accountObject.recoverAccount(false)
            DLog(String(format: "accountName \(accountName) sumMainAndChangeAddressMaxIdx: \(sumMainAndChangeAddressMaxIdx)"))
            if sumMainAndChangeAddressMaxIdx > -2 {
                consecutiveUnusedAccountCount = 0
            } else {
                consecutiveUnusedAccountCount += 1
                if consecutiveUnusedAccountCount == MAX_CONSECUTIVE_UNUSED_ACCOUNT_LOOK_AHEAD_COUNT {
                    break
                }
            }
            
            accountIdx += 1
        }
        
        DLog("recoverHDWallet getNumberOfAccounts: \(accounts.getNumberOfAccounts())")
        if accounts.getNumberOfAccounts() == 0 {
            accounts.createNewAccount(TLDisplayStrings.ACCOUNT_1_STRING(), accountType:.normal)
        } else if accounts.getNumberOfAccounts() > 1 {
            while accounts.getNumberOfAccounts() > 1 && consecutiveUnusedAccountCount > 0 {
                accounts.popTopAccount()
                consecutiveUnusedAccountCount -= 1
            }
        }
    }
    
    func refreshHDWalletAccounts(_ isRestoringWallet: Bool) {
        let group = DispatchGroup()
        for i in stride(from: 0, to: accounts.getNumberOfAccounts(), by: 1) {
            let accountObject = accounts.getAccountObjectForIdx(i)
            group.enter()
            
            // if account needs recovering dont fetch account data
            if (accountObject.needsRecovering()) {
                return
            }
            
            guard var activeAddresses = accountObject.getActiveMainAddresses() as? [String] else { return }
            activeAddresses += accountObject.getActiveChangeAddresses() as! [String]
   
            accountObject.getAccountData(activeAddresses, shouldResetAccountBalance: true, success: {
                () in
                group.leave()
                
            }, failure: {
                () in
                group.leave()
            })
        }
        group.wait(timeout: DispatchTime.distantFuture)
    }
    
    func createFirstAccount() {
        if self.accounts.getNumberOfAccounts() > 0 || self.accounts.getNumberOfArchivedAccounts() > 0 {
            return
        }
        let accountObject = self.accounts.createNewAccount(TLDisplayStrings.ACCOUNT_1_STRING(), accountType:.normal, preloadStartingAddresses:true)
        accountObject.updateAccountNeedsRecovering(false)
    }
    
    func listenToIncomingTransactionForWallet() {
        if (!TLTransactionListener.instance().isWebSocketOpen(self.coinType)) {
            return
        }
        for i in stride(from: 0, to: accounts.getNumberOfAccounts(), by: 1) {
            let accountObject = accounts.getAccountObjectForIdx(i)
            if accountObject.downloadState != .downloaded {
                continue
            }
            guard let activeMainAddresses = accountObject.getActiveMainAddresses() else { return }
            for address in activeMainAddresses {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(self.coinType, address: address as! String)
            }
            guard let activeChangeAddresses = accountObject.getActiveChangeAddresses() else { return }
            for address in activeChangeAddresses {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(self.coinType, address: address as! String)
            }
    
            accountObject.listeningToIncomingTransactions = true
        }
        
        for i in stride(from: 0, to: coldWalletAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = coldWalletAccounts.getAccountObjectForIdx(i)
            if accountObject.downloadState != .downloaded {
                continue
            }
            guard let activeMainAddresses = accountObject.getActiveMainAddresses() else { return }
            for address in activeMainAddresses {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(self.coinType, address: address as! String)
            }
            guard let activeChangeAddresses = accountObject.getActiveChangeAddresses() else { return }
            for address in activeChangeAddresses {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(self.coinType, address: address as! String)
            }
            accountObject.listeningToIncomingTransactions = true
        }
        for i in stride(from: 0, to: importedAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = importedAccounts.getAccountObjectForIdx(i)
            if accountObject.downloadState != .downloaded {
                continue
            }
            guard let activeMainAddresses = accountObject.getActiveMainAddresses() else { return }
            for address in activeMainAddresses {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(self.coinType, address: address as! String)
            }
            guard let activeChangeAddresses = accountObject.getActiveChangeAddresses() else { return }
            for address in activeChangeAddresses {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(self.coinType, address: address as! String)
            }
            
            accountObject.listeningToIncomingTransactions = true
        }
        
        for i in stride(from: 0, to: importedWatchAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = importedWatchAccounts.getAccountObjectForIdx(i)
            if accountObject.downloadState != .downloaded {
                continue
            }
            guard let activeMainAddresses = accountObject.getActiveMainAddresses() else { return }
            for address in activeMainAddresses {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(self.coinType, address: address as! String)
            }
            guard let activeChangeAddresses = accountObject.getActiveChangeAddresses() else { return }
            for address in activeChangeAddresses {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(self.coinType, address: address as! String)
            }
            accountObject.listeningToIncomingTransactions = true
        }
        
        for i in stride(from: 0, to: importedAddresses.getCount(), by: 1) {
            let importedAddress = importedAddresses.getAddressObjectAtIdx(i)
            if importedAddress.downloadState != .downloaded {
                continue
            }
            let address = importedAddress.getAddress()
            TLTransactionListener.instance().listenToIncomingTransactionForAddress(self.coinType, address: address)
            importedAddress.listeningToIncomingTransactions = true
        }
        
        for i in stride(from: 0, to: importedWatchAddresses.getCount(), by: 1) {
            let importedAddress = importedWatchAddresses.getAddressObjectAtIdx(i)
            if importedAddress.downloadState != .downloaded {
                continue
            }
            let address = importedAddress.getAddress()
            TLTransactionListener.instance().listenToIncomingTransactionForAddress(self.coinType, address: address)
            importedAddress.listeningToIncomingTransactions = true
        }
    }
    
    func setWalletTransactionListenerClosed() {
        DLog("setWalletTransactionListenerClosed")
        for i in stride(from: 0, to: accounts.getNumberOfAccounts(), by: 1) {
            let accountObject = accounts.getAccountObjectForIdx(i)
            accountObject.listeningToIncomingTransactions = false
        }
        
        for i in stride(from: 0, to: coldWalletAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = coldWalletAccounts.getAccountObjectForIdx(i)
            accountObject.listeningToIncomingTransactions = false
        }
        
        for i in stride(from: 0, to: importedAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = importedAccounts.getAccountObjectForIdx(i)
            accountObject.listeningToIncomingTransactions = false
        }
        
        for i in stride(from: 0, to: importedWatchAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = importedWatchAccounts.getAccountObjectForIdx(i)
            accountObject.listeningToIncomingTransactions = false
        }
        
        for i in stride(from: 0, to: importedAddresses.getCount(), by: 1) {
            let importedAddress = importedAddresses.getAddressObjectAtIdx(i)
            importedAddress.listeningToIncomingTransactions = false
        }
        
        for i in stride(from: 0, to: importedWatchAddresses.getCount(), by: 1) {
            let importedAddress = importedWatchAddresses.getAddressObjectAtIdx(i)
            importedAddress.listeningToIncomingTransactions = false
        }
    }
    
    func updateModelWithNewTransaction(_ txObject: TLTxObject) {
        let addressesInTx = txObject.getAddresses()
        
        for i in stride(from: 0, to: accounts.getNumberOfAccounts(), by: 1) {
            let accountObject = accounts.getAccountObjectForIdx(i)
            if !accountObject.hasFetchedAccountData() {
                continue
            }
            for address in addressesInTx {
                if (accountObject.isAddressPartOfAccount(address )) {
                    DLog("updateModelWithNewTransaction accounts \(accountObject.getAccountID())")
                    self.handleNewTxForAccount(accountObject, txObject: txObject)
                }
            }
        }
        
        for i in stride(from: 0, to: coldWalletAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = coldWalletAccounts.getAccountObjectForIdx(i)
            if !accountObject.hasFetchedAccountData() {
                continue
            }
            for address in addressesInTx {
                if (accountObject.isAddressPartOfAccount(address)) {
                    DLog("updateModelWithNewTransaction coldWalletAccounts \(accountObject.getAccountID())")
                    self.handleNewTxForAccount(accountObject, txObject: txObject)
                }
            }
        }
        
        for i in stride(from: 0, to: importedAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = importedAccounts.getAccountObjectForIdx(i)
            if !accountObject.hasFetchedAccountData() {
                continue
            }
            for address in addressesInTx {
                if (accountObject.isAddressPartOfAccount(address)) {
                    DLog("updateModelWithNewTransaction importedAccounts \(accountObject.getAccountID())")
                    self.handleNewTxForAccount(accountObject, txObject: txObject)
                }
            }
        }
        
        for i in stride(from: 0, to: importedWatchAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = importedWatchAccounts.getAccountObjectForIdx(i)
            if !accountObject.hasFetchedAccountData() {
                continue
            }
            for address in addressesInTx {
                if (accountObject.isAddressPartOfAccount(address)) {
                    DLog("updateModelWithNewTransaction importedWatchAccounts \(accountObject.getAccountID())")
                    self.handleNewTxForAccount(accountObject, txObject: txObject)
                }
            }
        }
        
        for i in stride(from: 0, to: importedAddresses.getCount(), by: 1) {
            let importedAddress = importedAddresses.getAddressObjectAtIdx(i)
            if !importedAddress.hasFetchedAccountData() {
                continue
            }
            let address = importedAddress.getAddress()
            for addr in addressesInTx {
                if (addr == address) {
                    DLog("updateModelWithNewTransaction importedAddresses \(address)")
                    self.handleNewTxForImportedAddress(importedAddress, txObject: txObject)
                }
            }
        }
        
        for i in stride(from: 0, to: importedWatchAddresses.getCount(), by: 1) {
            let importedAddress = importedWatchAddresses.getAddressObjectAtIdx(i)
            if !importedAddress.hasFetchedAccountData() {
                continue
            }
            let address = importedAddress.getAddress()
            for addr in addressesInTx {
                if (addr == address) {
                    DLog("updateModelWithNewTransaction importedWatchAddresses \(address)")
                    self.handleNewTxForImportedAddress(importedAddress, txObject: txObject)
                }
            }
        }
    }

    func handleNewTxForAccount(_ accountObject: TLAccountObject, txObject: TLTxObject) {
        let receivedAmount = accountObject.processNewTx(txObject)
        let receivedTo = accountObject.getAccountNameOrAccountPublicKey()
        //AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: true, success: {
        AppDelegate.instance().updateUIForNewTx(txObject.getHash() as! String, receivedAmount: receivedAmount, coinType: self.coinType, receivedTo: receivedTo)
        //})
    }
    
    func handleNewTxForImportedAddress(_ importedAddress: TLImportedAddress, txObject: TLTxObject) {
        let receivedAmount = importedAddress.processNewTx(txObject)
        let receivedTo = importedAddress.getLabel()
        //AppDelegate.instance().pendingOperations.addSetUpImportedAddressOperation(importedAddress, fetchDataAgain: true, success: {
        AppDelegate.instance().updateUIForNewTx(txObject.getHash() as! String, receivedAmount: receivedAmount, coinType: self.coinType, receivedTo: receivedTo)
        //})
    }
    
    func getTransactionTag(_ txObject: TLTxObject) -> String? {
        return self.appWallet.getTransactionTag(self.coinType, txid: txObject.getHash())
    }
    
    func deleteTransactionTag(_ txObject: TLTxObject) {
        self.appWallet.deleteTransactionTag(self.coinType, txid: txObject.getHash())
    }
    
    func setTransactionTag(_ txid: String, tag: String) {
        self.appWallet.setTransactionTag(self.coinType, txid: txid, tag: tag)
    }
    func getAddressBook() -> NSArray {
        return self.appWallet.getAddressBook(self.coinType)
    }
    
    func editAddressBookEntry(_ index: Int, label: String) {
        self.appWallet.editAddressBookEntry(self.coinType, index: index, label: label)
    }

    func deleteAddressBookEntry(_ index: Int) {
        self.appWallet.deleteAddressBookEntry(self.coinType, idx: index)
    }
    
    func getLabelForAddress(_ address: String) -> String? {
        return self.appWallet.getLabelForAddress(self.coinType, address: address)
    }
    
    func addAddressBookEntry(_ address: String, label: String) {
        self.appWallet.addAddressBookEntry(TLPreferences.getSendFromCoinType(), address: address, label: label)
    }
}
