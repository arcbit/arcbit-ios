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
            guard let stealthWallet = accountObject.stealthWallet else { return }
            
            DLog("recoverHDWalletaccountName \(accountName)")
            
            let sumMainAndChangeAddressMaxIdx = accountObject.recoverAccount(false)
            DLog(String(format: "accountName \(accountName) sumMainAndChangeAddressMaxIdx: \(sumMainAndChangeAddressMaxIdx)"))
            if sumMainAndChangeAddressMaxIdx > -2 || TLWalletUtils.ENABLE_STEALTH_ADDRESS() && stealthWallet.checkIfHaveStealthPayments() {
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
            
            if TLWalletUtils.ENABLE_STEALTH_ADDRESS() {
                if let stealthWallet = accountObject.stealthWallet {
                    activeAddresses += stealthWallet.getPaymentAddresses()
                    group.enter()
                    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                        accountObject.fetchNewStealthPayments(isRestoringWallet)
                        group.leave()
                    }
                }
            }
            
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
        let accountObject = self.accounts.createNewAccount(TLDisplayStrings.ACCOUNT_1_STRING(), accountType:.normal, preloadStartingAddresses:true)
        accountObject.updateAccountNeedsRecovering(false)
    }
    
    func respondToStealthChallege(_ challenge: String) {
        if (!TLStealthWebSocket.instance().isWebSocketOpen()) {
            return
        }
        for i in stride(from: 0, to: accounts.getNumberOfAccounts(), by: 1) {
            let accountObject = accounts.getAccountObjectForIdx(i)
            if accountObject.hasFetchedAccountData() &&
                accountObject.stealthWallet != nil && accountObject.stealthWallet?.isListeningToStealthPayment == false {
                if let addrAndSignature = accountObject.stealthWallet?.getStealthAddressAndSignatureFromChallenge(challenge){
                    TLStealthWebSocket.instance().sendMessageSubscribeToStealthAddress(addrAndSignature.0, signature: addrAndSignature.1)
                }
            }
        }
        for i in stride(from: 0, to: importedAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = importedAccounts.getAccountObjectForIdx(i)
            if let stealthWallet = accountObject.stealthWallet, accountObject.hasFetchedAccountData() &&
                stealthWallet.isListeningToStealthPayment == false {
                let addrAndSignature = stealthWallet.getStealthAddressAndSignatureFromChallenge(challenge)
                TLStealthWebSocket.instance().sendMessageSubscribeToStealthAddress(addrAndSignature.0, signature: addrAndSignature.1)
            }
        }
    }
    
    func setAccountsListeningToStealthPaymentsToFalse() {
        for i in stride(from: 0, to: accounts.getNumberOfAccounts(), by: 1) {
            let accountObject = accounts.getAccountObjectForIdx(i)
            if accountObject.stealthWallet != nil {
                accountObject.stealthWallet?.isListeningToStealthPayment = false
            }
        }
        
        for i in stride(from: 0, to: importedAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = importedAccounts.getAccountObjectForIdx(i)
            if let stealthWallet = accountObject.stealthWallet {
                stealthWallet.isListeningToStealthPayment = false
            }
        }
    }
    
    func listenToIncomingTransactionForWallet() {
        if (!TLTransactionListener.instance().isWebSocketOpen()) {
            return
        }
        for i in stride(from: 0, to: accounts.getNumberOfAccounts(), by: 1) {
            let accountObject = accounts.getAccountObjectForIdx(i)
            if accountObject.downloadState != .downloaded {
                continue
            }
            guard let activeMainAddresses = accountObject.getActiveMainAddresses() else { return }
            for address in activeMainAddresses {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
            }
            guard let activeChangeAddresses = accountObject.getActiveChangeAddresses() else { return }
            for address in activeChangeAddresses {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
            }
            
            if let stealthWallet = accountObject.stealthWallet {
                let stealthPaymentAddresses = stealthWallet.getUnspentPaymentAddresses()
                for address in stealthPaymentAddresses {
                    TLTransactionListener.instance().listenToIncomingTransactionForAddress(address)
                }
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
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
            }
            guard let activeChangeAddresses = accountObject.getActiveChangeAddresses() else { return }
            for address in activeChangeAddresses {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
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
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
            }
            guard let activeChangeAddresses = accountObject.getActiveChangeAddresses() else { return }
            for address in activeChangeAddresses {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
            }
            
            if let stealthWallet = accountObject.stealthWallet {
                let stealthPaymentAddresses = stealthWallet.getUnspentPaymentAddresses()
                for address in stealthPaymentAddresses {
                    TLTransactionListener.instance().listenToIncomingTransactionForAddress(address)
                }
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
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
            }
            guard let activeChangeAddresses = accountObject.getActiveChangeAddresses() else { return }
            for address in activeChangeAddresses {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
            }
            accountObject.listeningToIncomingTransactions = true
        }
        
        for i in stride(from: 0, to: importedAddresses.getCount(), by: 1) {
            let importedAddress = importedAddresses.getAddressObjectAtIdx(i)
            if importedAddress.downloadState != .downloaded {
                continue
            }
            let address = importedAddress.getAddress()
            TLTransactionListener.instance().listenToIncomingTransactionForAddress(address)
            importedAddress.listeningToIncomingTransactions = true
        }
        
        for i in stride(from: 0, to: importedWatchAddresses.getCount(), by: 1) {
            let importedAddress = importedWatchAddresses.getAddressObjectAtIdx(i)
            if importedAddress.downloadState != .downloaded {
                continue
            }
            let address = importedAddress.getAddress()
            TLTransactionListener.instance().listenToIncomingTransactionForAddress(address)
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
    
    func handleGetTxSuccessForRespondToStealthPayment(_ stealthAddress: String, paymentAddress: String,
                                                      txid: String, txTime: UInt64, txObject: TLTxObject) {
        let inputAddresses = txObject.getInputAddressArray()
        let outputAddresses = txObject.getOutputAddressArray()
        
        if outputAddresses.index(of: paymentAddress) == nil {
            return
        }
        
        let possibleStealthDataScripts = txObject.getPossibleStealthDataScripts()
        
        func processStealthPayment(_ accountObject: TLAccountObject) {
            if let stealthWallet = accountObject.stealthWallet, stealthWallet.getStealthAddress() == stealthAddress {
                if accountObject.hasFetchedAccountData() {
                    for stealthDataScript in possibleStealthDataScripts {
                        let privateKey = stealthWallet.generateAndAddStealthAddressPaymentKey(stealthDataScript, expectedAddress: paymentAddress,
                                                                                              txid: txid, txTime: txTime, stealthPaymentStatus: TLStealthPaymentStatus.unspent)
                        if privateKey != nil {
                            handleNewTxForAccount(accountObject, txObject: txObject)
                            break
                        }
                    }
                }
            } else {
                // must refresh account balance if a input address belongs to account
                // this is needed because websocket api does not notify of addresses being used as inputs
                for address in inputAddresses {
                    if accountObject.hasFetchedAccountData() && accountObject.isAddressPartOfAccount(address) {
                        handleNewTxForAccount(accountObject, txObject: txObject)
                    }
                }
            }
        }
        
        for i in stride(from: 0, to: accounts.getNumberOfAccounts(), by: 1) {
            let accountObject = accounts.getAccountObjectForIdx(i)
            processStealthPayment(accountObject)
        }
        
        for i in stride(from: 0, to: coldWalletAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = coldWalletAccounts.getAccountObjectForIdx(i)
            for address in inputAddresses {
                if accountObject.isAddressPartOfAccount(address) {
                    handleNewTxForAccount(accountObject, txObject: txObject)
                }
            }
        }
        
        for i in stride(from: 0, to: importedAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = importedAccounts.getAccountObjectForIdx(i)
            processStealthPayment(accountObject)
        }
        for i in stride(from: 0, to: importedWatchAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = importedWatchAccounts.getAccountObjectForIdx(i)
            for address in inputAddresses {
                if accountObject.isAddressPartOfAccount(address) {
                    handleNewTxForAccount(accountObject, txObject: txObject)
                }
            }
        }
        
        for i in stride(from: 0, to: importedAddresses.getCount(), by: 1) {
            let importedAddress = importedAddresses.getAddressObjectAtIdx(i)
            for addr in inputAddresses {
                if (addr == importedAddress.getAddress()) {
                    handleNewTxForImportedAddress(importedAddress, txObject: txObject)
                }
            }
        }
        
        for i in stride(from: 0, to: importedWatchAddresses.getCount(), by: 1) {
            let importedAddress = importedWatchAddresses.getAddressObjectAtIdx(i)
            for addr in inputAddresses {
                if (addr == importedAddress.getAddress()) {
                    handleNewTxForImportedAddress(importedAddress, txObject: txObject)
                }
            }
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
    
    func respondToStealthAddressSubscription(_ stealthAddress: String) {
        for i in stride(from: 0, to: accounts.getNumberOfAccounts(), by: 1) {
            let accountObject = accounts.getAccountObjectForIdx(i)
            if let stealthWallet = accountObject.stealthWallet, stealthWallet.getStealthAddress() == stealthAddress {
                stealthWallet.isListeningToStealthPayment = true
            }
        }
        for i in stride(from: 0, to: importedAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = importedAccounts.getAccountObjectForIdx(i)
            if let stealthWallet = accountObject.stealthWallet, stealthWallet.getStealthAddress() == stealthAddress {
                stealthWallet.isListeningToStealthPayment = true
            }
        }
    }
    
    func handleNewTxForAccount(_ accountObject: TLAccountObject, txObject: TLTxObject) {
        let receivedAmount = accountObject.processNewTx(txObject)
        let receivedTo = accountObject.getAccountNameOrAccountPublicKey()
        //AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: true, success: {
        AppDelegate.instance().updateUIForNewTx(txObject.getHash() as! String, receivedAmount: receivedAmount, receivedTo: receivedTo)
        //})
    }
    
    func handleNewTxForImportedAddress(_ importedAddress: TLImportedAddress, txObject: TLTxObject) {
        let receivedAmount = importedAddress.processNewTx(txObject)
        let receivedTo = importedAddress.getLabel()
        //AppDelegate.instance().pendingOperations.addSetUpImportedAddressOperation(importedAddress, fetchDataAgain: true, success: {
        AppDelegate.instance().updateUIForNewTx(txObject.getHash() as! String, receivedAmount: receivedAmount, receivedTo: receivedTo)
        //})
    }
    
    func getTransactionTag(_ txObject: TLTxObject) -> String? {
        return self.appWallet.getTransactionTag(self.coinType, txid: txObject.getHash()!)
    }
    
    func deleteTransactionTag(_ txObject: TLTxObject) {
        self.appWallet.deleteTransactionTag(self.coinType, txid: txObject.getHash()!)
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
