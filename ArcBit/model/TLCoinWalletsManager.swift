//
//  TLCoinWalletsManager.swift
//  ArcBit
//
//  Created by Timothy Lee on 1/5/18.
//  Copyright © 2018 ArcBit. All rights reserved.
//

import Foundation

@objc class TLCoinWalletsManager:NSObject {
    struct STATIC_MEMBERS {
        static var instance:TLCoinWalletsManager?
    }
    
    lazy fileprivate var coinWalletDict = [TLCoinType:TLWalletObject]()
    var godSend:TLSelectedObject? = nil
    lazy var receiveSelectedObject:TLSelectedObject? = nil
    lazy var historySelectedObject:TLSelectedObject? = nil
    
    init(_ appWallet: TLWallet) {

        super.init()
        TLWalletUtils.SUPPORT_COIN_TYPES().forEach({ (coinType) in
            self.coinWalletDict[coinType] = TLWalletObject(appWallet: appWallet, coinType: coinType)
        })
        
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLCoinWalletsManager.setWalletTransactionListenerClosed),
             name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_TRANSACTION_LISTENER_CLOSE()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLCoinWalletsManager.listenToIncomingTransactionForWallet),
             name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_TRANSACTION_LISTENER_OPEN()), object:nil)
        
        
        func updateGodSend() {
            let sendFromCoinType = TLPreferences.getSendFromCoinType()
            var sendFromType = TLPreferences.getSendFromType()
            var sendFromIndex = Int(TLPreferences.getSendFromIndex())
            
            let coinWalletObject = self.coinWalletDict[sendFromCoinType]!
            if (sendFromType == .hdWallet) {
                if sendFromIndex > coinWalletObject.accounts.getNumberOfAccounts() - 1 {
                    sendFromType = TLSendFromType.none
                    sendFromIndex = 0
                }
            } else if (sendFromType == .coldWalletAccount) {
                if sendFromIndex > coinWalletObject.coldWalletAccounts.getNumberOfAccounts() - 1 {
                    sendFromType = TLSendFromType.none
                    sendFromIndex = 0
                }
            } else if (sendFromType == .importedAccount) {
                if sendFromIndex > coinWalletObject.importedAccounts.getNumberOfAccounts() - 1 {
                    sendFromType = TLSendFromType.none
                    sendFromIndex = 0
                }
            } else if (sendFromType == .importedWatchAccount) {
                if sendFromIndex > coinWalletObject.importedWatchAccounts.getNumberOfAccounts() - 1 {
                    sendFromType = TLSendFromType.none
                    sendFromIndex = 0
                }
            } else if (sendFromType == .importedAddress) {
                if sendFromIndex > coinWalletObject.importedAddresses.getCount() - 1 {
                    sendFromType = TLSendFromType.none
                    sendFromIndex = 0
                }
            } else if (sendFromType == .importedWatchAddress) {
                if sendFromIndex > coinWalletObject.importedWatchAddresses.getCount() - 1 {
                    sendFromType = TLSendFromType.none
                    sendFromIndex = 0
                }
            }
            self.updateGodSend(sendFromCoinType, sendFromType: sendFromType, sendFromIndex:sendFromIndex)
        }
        
        updateGodSend()
        self.receiveSelectedObject = godSend
        self.historySelectedObject = godSend
    }

    func getSelectedWalletObject(_ coinType: TLCoinType) -> TLWalletObject {
        return self.coinWalletDict[coinType]!
    }
    
    func getSelectedWalletObject() -> TLWalletObject {
        return self.coinWalletDict[TLPreferences.getSendFromCoinType()]!
    }

    func aAccountNeedsRecovering() -> Bool {
        var accountNeedsRecovering = false
        for coinType in TLWalletUtils.SUPPORT_COIN_TYPES() {
            if self.coinWalletDict[coinType]!.aAccountNeedsRecovering() {
                return true
            }
        }
        return false
    }
    
    func checkToRecoverAccounts() {
        TLWalletUtils.SUPPORT_COIN_TYPES().forEach({ (coinType) in
            self.coinWalletDict[coinType]!.checkToRecoverAccounts()
        })
    }
    
    func recoverHDWallet() {
        TLWalletUtils.SUPPORT_COIN_TYPES().forEach({ (coinType) in
            self.coinWalletDict[coinType]!.recoverHDWallet()
        })
    }
    

    
    
    func updateGodSend(_ coinType: TLCoinType, sendFromType: TLSendFromType, sendFromIndex: Int) {
        TLPreferences.setSendFromType(sendFromType)
        TLPreferences.setSendFromIndex(UInt(sendFromIndex))

        let coinWalletObject = self.coinWalletDict[coinType]!
        if sendFromType == .hdWallet {
            let accountObject = coinWalletObject.accounts.getAccountObjectForIdx(sendFromIndex)
            godSend = accountObject
        } else if sendFromType == .coldWalletAccount {
            let accountObject = coinWalletObject.coldWalletAccounts.getAccountObjectForIdx(sendFromIndex)
            godSend = accountObject
        } else if sendFromType == .importedAccount {
            let accountObject = coinWalletObject.importedAccounts.getAccountObjectForIdx(sendFromIndex)
            godSend = accountObject
        } else if sendFromType == .importedWatchAccount {
            let accountObject = coinWalletObject.importedWatchAccounts.getAccountObjectForIdx(sendFromIndex)
            godSend = accountObject
        } else if sendFromType == .importedAddress {
            let importedAddress = coinWalletObject.importedAddresses.getAddressObjectAtIdx(sendFromIndex)
            godSend = importedAddress
        } else if sendFromType == .importedWatchAddress {
            let importedAddress = coinWalletObject.importedWatchAddresses.getAddressObjectAtIdx(sendFromIndex)
            godSend = importedAddress
        } else if sendFromType == .none {
            godSend = nil
        }
    }
    
    
    func updateReceiveSelectedObject(_ coinType: TLCoinType, sendFromType: TLSendFromType, sendFromIndex: Int) {
        let coinWalletObject = self.coinWalletDict[coinType]!
        switch sendFromType {
        case .hdWallet:
            let accountObject = coinWalletObject.accounts.getAccountObjectForIdx(sendFromIndex)
            receiveSelectedObject = accountObject
        case .coldWalletAccount:
            let accountObject = coinWalletObject.coldWalletAccounts.getAccountObjectForIdx(sendFromIndex)
            receiveSelectedObject = accountObject
        case .importedAccount:
            let accountObject = coinWalletObject.importedAccounts.getAccountObjectForIdx(sendFromIndex)
            receiveSelectedObject = accountObject
        case .importedWatchAccount:
            let accountObject = coinWalletObject.importedWatchAccounts.getAccountObjectForIdx(sendFromIndex)
            receiveSelectedObject = accountObject
        case .importedAddress:
            let importedAddress = coinWalletObject.importedAddresses.getAddressObjectAtIdx(sendFromIndex)
            receiveSelectedObject = importedAddress
        case .importedWatchAddress:
            let importedAddress = coinWalletObject.importedWatchAddresses.getAddressObjectAtIdx(sendFromIndex)
            receiveSelectedObject = importedAddress
        case .none:
            receiveSelectedObject = nil
        }
    }
    
    func updateHistorySelectedObject(_ coinType: TLCoinType, sendFromType: TLSendFromType, sendFromIndex: Int) {
        let coinWalletObject = self.coinWalletDict[coinType]!
        switch sendFromType {
        case .hdWallet:
            let accountObject = coinWalletObject.accounts.getAccountObjectForIdx(sendFromIndex)
            historySelectedObject = accountObject
        case .coldWalletAccount:
            let accountObject = coinWalletObject.coldWalletAccounts.getAccountObjectForIdx(sendFromIndex)
            historySelectedObject = accountObject
        case .importedAccount:
            let accountObject = coinWalletObject.importedAccounts.getAccountObjectForIdx(sendFromIndex)
            historySelectedObject = accountObject
        case .importedWatchAccount:
            let accountObject = coinWalletObject.importedWatchAccounts.getAccountObjectForIdx(sendFromIndex)
            historySelectedObject = accountObject
        case .importedAddress:
            let importedAddress = coinWalletObject.importedAddresses.getAddressObjectAtIdx(sendFromIndex)
            historySelectedObject = importedAddress
        case .importedWatchAddress:
            let importedAddress = coinWalletObject.importedWatchAddresses.getAddressObjectAtIdx(sendFromIndex)
            historySelectedObject = importedAddress
        case .none:
            receiveSelectedObject = nil
        }
    }
    
    @discardableResult
    func updateSelectedObjectsToEnabledCoin(_ selectAccountObjectType: TLSelectAccountObjectType) -> TLCoinType {
        var selectedCoinType = TLWalletUtils.DEFAULT_COIN_TYPE()
        for coinType in TLWalletUtils.SUPPORT_COIN_TYPES() {
            if TLPreferences.isCryptoCoinEnabled(coinType) {
                selectedCoinType = coinType
                break
            }
        }
        let sendFromType = TLSendFromType.hdWallet
        let sendFromIndex = 0
        switch selectAccountObjectType {
        case .send:
            self.updateGodSend(selectedCoinType, sendFromType: sendFromType, sendFromIndex: sendFromIndex)
        case .receive:
            self.updateReceiveSelectedObject(selectedCoinType, sendFromType: sendFromType, sendFromIndex: sendFromIndex)
        case .history:
            self.updateHistorySelectedObject(selectedCoinType, sendFromType: sendFromType, sendFromIndex: sendFromIndex)
        }
        return selectedCoinType
    }
    
    func getSendObjectSelectedCoinType() -> TLCoinType {
        if let godSend = self.godSend {
            return godSend.getSelectedObjectCoinType()
        } else {
            return TLWalletUtils.DEFAULT_COIN_TYPE()
        }
    }
    
    func getReceiveSelectedCoinType() -> TLCoinType {
        if let receiveSelectedObject = self.receiveSelectedObject {
            return receiveSelectedObject.getSelectedObjectCoinType()
        } else {
            return TLWalletUtils.DEFAULT_COIN_TYPE()
        }
    }
    
    func getHistorySelectedCoinType() -> TLCoinType {
        if let historySelectedObject = self.historySelectedObject {
            return historySelectedObject.getSelectedObjectCoinType()
        } else {
            return TLWalletUtils.DEFAULT_COIN_TYPE()
        }
    }
    
    func setWalletTransactionListenerClosed() {
        TLWalletUtils.SUPPORT_COIN_TYPES().forEach({ (coinType) in
            let coinWalletObject = self.coinWalletDict[coinType]!
            coinWalletObject.setWalletTransactionListenerClosed()
        })
    }

    func createFirstAccount() {
        TLWalletUtils.SUPPORT_COIN_TYPES().forEach({ (coinType) in
            let coinWalletObject = self.coinWalletDict[coinType]!
            coinWalletObject.createFirstAccount()
        })
    }
    
    func createFirstBitcoinCashAccount() {
        self.coinWalletDict[TLCoinType.BCH]?.createFirstAccount()
    }
    
    func refreshHDWalletAccounts(_ isRestoringWallet: Bool) {
        TLWalletUtils.SUPPORT_COIN_TYPES().forEach({ (coinType) in
            let coinWalletObject = self.coinWalletDict[coinType]!
            coinWalletObject.refreshHDWalletAccounts(isRestoringWallet)
        })
    }
    
    func listenToIncomingTransactionForWallet() {
        TLWalletUtils.SUPPORT_COIN_TYPES().forEach({ (coinType) in
            let coinWalletObject = self.coinWalletDict[coinType]!
            coinWalletObject.listenToIncomingTransactionForWallet()
        })
    }
    
    func updateModelWithNewTransaction(_ txObject: TLTxObject) {
        TLWalletUtils.SUPPORT_COIN_TYPES().forEach({ (coinType) in
            let coinWalletObject = self.coinWalletDict[coinType]!
            coinWalletObject.updateModelWithNewTransaction(txObject)
        })
    }
}

extension TLCoinWalletsManager {
    func getTransactionTag(_ coinType: TLCoinType, txObject: TLTxObject) -> String? {
        return self.getSelectedWalletObject(coinType).getTransactionTag(txObject)
    }
    
    func deleteTransactionTag(_ coinType: TLCoinType, txObject: TLTxObject) {
        self.getSelectedWalletObject(coinType).deleteTransactionTag(txObject)
    }
    
    func setTransactionTag(_ coinType: TLCoinType, txid: String, tag: String) {
        self.getSelectedWalletObject(coinType).setTransactionTag(txid, tag: tag)
    }
    
    func getAddressBook(_ coinType: TLCoinType) -> NSArray {
        return self.getSelectedWalletObject(coinType).getAddressBook()
    }
    
    func editAddressBookEntry(_ coinType: TLCoinType, idx: Int, label: String) {
        self.getSelectedWalletObject(coinType).editAddressBookEntry(idx, label: label)
    }
    
    func deleteAddressBookEntry(_ coinType: TLCoinType, idx: Int) {
        self.getSelectedWalletObject(coinType).deleteAddressBookEntry(idx)
    }
    
    func getLabelForAddress(_ coinType: TLCoinType, address: String) -> String? {
        return self.getSelectedWalletObject(coinType).getLabelForAddress(address)
    }
    
    func addAddressBookEntry(_ coinType: TLCoinType, address: String, label: String) {
        self.getSelectedWalletObject(coinType).addAddressBookEntry(address, label: label)
    }
}
