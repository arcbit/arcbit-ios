//
//  TLAnalytics.swift
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

class TLAnalytics: NSObject {
    struct STATIC_MEMBERS {
        static var _instance:TLAnalytics? = nil
    }
    
    class func instance() -> (TLAnalytics) {
        if(STATIC_MEMBERS._instance == nil) {
            STATIC_MEMBERS._instance = TLAnalytics()
        }
        return STATIC_MEMBERS._instance!
    }
    
    override init() {
        super.init()
        observeUserInterfaceInteractions()
    }
    
    fileprivate func observeUserInterfaceInteractionsWithAchievements() -> () {
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateSentPayment(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_SEND_PAYMENT()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateReceivePayment(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_RECEIVE_PAYMENT()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateViewHistoryScreen(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_HISTORY()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateCreateNewAccount(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_CREATE_NEW_ACCOUNT()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateEditAccountName(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_EDIT_ACCOUNT_NAME()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateArchiveAccount(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_ARCHIVE_ACCOUNT()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateEnablePINCode(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_ENABLE_PIN_CODE()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateBackupPassphrase(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_BACKUP_PASSPHRASE()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateRestoreWallet(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_RESTORE_WALLET()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateAddToAddressBook(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_ADD_TO_ADDRESS_BOOK()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateEditEntryAddressBook(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_EDIT_ENTRY_ADDRESS_BOOK()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateDeleteEntryAddressBook(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_DELETE_ENTRY_ADDRESS_BOOK()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateSendToAddressInAddressBook(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_SEND_TO_ADDRESS_IN_ADDRESS_BOOK()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateTagTransaction(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_TAG_TRANSACTION()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateToggleAutomaticTxFee(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_TOGGLE_AUTOMATIC_TX_FEE()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateChangeAutomaticTxFee(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_CHANGE_AUTOMATIC_TX_FEE()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateViewAccountAddresses(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESSES()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateViewAccountAddress(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESS()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateViewTransactionInWeb(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_TRANSACTION_IN_WEB()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateViewAccountAddressInWeb(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESS_IN_WEB()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateViewEnableAdvancedMode(_:)),
             name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_ENABLE_ADVANCE_MODE()), object:nil)

        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateImportAccount(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_IMPORT_ACCOUNT()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateImportWatchOnlyAccount(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_IMPORT_WATCH_ONLY_ACCOUNT()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateImportPrivateKey(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_IMPORT_PRIVATE_KEY()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateImportWatchOnlyAddress(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_IMPORT_WATCH_ONLY_ADDRESS()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateChangeBlockExplorerType(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_CHANGE_BLOCKEXPLORER_TYPE()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateViewExtendedPublicKey(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateViewExtendedPrivateKey(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_EXTENDED_PRIVATE_KEY()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateViewAccountsPrivateKey(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_ACCOUNT_PRIVATE_KEY()), object:nil)
    }
    
    func observeUserInterfaceInteractions() -> () {
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateViewSendScreen(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_SEND_SCREEN()), object:nil)
        
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateViewReceiveScreen(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_RECEIVE_SCREEN()), object:nil)
        
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateViewAccountsScreen(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_ACCOUNTS_SCREEN()), object:nil)
        
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateViewManageAccountsScreen(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_MANAGE_ACCOUNTS_SCREEN()), object:nil)
        
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateViewHelpScreen(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_HELP_SCREEN()), object:nil)
        
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLAnalytics.updateViewSettingsScreen(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_SETTINGS_SCREEN()), object:nil)
        
        observeUserInterfaceInteractionsWithAchievements()
    }
    
    func updateViewSendScreen(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_SEND_SCREEN())
    }
    
    func updateViewReceiveScreen(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_RECEIVE_SCREEN())
    }
    
    func updateViewAccountsScreen(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_ACCOUNTS_SCREEN())
    }
    
    func updateViewManageAccountsScreen(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_MANAGE_ACCOUNTS_SCREEN())
    }
    
    func updateViewHelpScreen(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_HELP_SCREEN())
    }
    
    func updateViewSettingsScreen(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_SETTINGS_SCREEN())
    }
    
    // Achievements
    func updateSentPayment(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_SEND_PAYMENT())
    }
    
    func updateReceivePayment(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_RECEIVE_PAYMENT())
    }
    
    func updateViewHistoryScreen(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_HISTORY())
    }
    
    func updateCreateNewAccount(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_CREATE_NEW_ACCOUNT())
    }
    
    func updateEditAccountName(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_EDIT_ACCOUNT_NAME())
    }
    
    func updateArchiveAccount(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_ARCHIVE_ACCOUNT())
    }
    
    func updateEnablePINCode(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_ENABLE_PIN_CODE())
    }
    
    func updateBackupPassphrase(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_BACKUP_PASSPHRASE())
    }
    
    func updateRestoreWallet(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_RESTORE_WALLET())
    }
    
    func updateAddToAddressBook(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_ADD_TO_ADDRESS_BOOK())
    }
    
    func updateEditEntryAddressBook(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_EDIT_ENTRY_ADDRESS_BOOK())
    }
    
    func updateDeleteEntryAddressBook(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_DELETE_ENTRY_ADDRESS_BOOK())
    }
    
    func updateSendToAddressInAddressBook(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_SEND_TO_ADDRESS_IN_ADDRESS_BOOK())
    }
    
    func updateTagTransaction(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_TAG_TRANSACTION())
    }
    
    func updateToggleAutomaticTxFee(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_TOGGLE_AUTOMATIC_TX_FEE())
    }
    
    func updateChangeAutomaticTxFee(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_CHANGE_AUTOMATIC_TX_FEE())
    }
    
    func updateViewAccountAddresses(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESSES())
    }
    
    func updateViewAccountAddress(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESS())
    }
    
    func updateViewTransactionInWeb(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_TRANSACTION_IN_WEB())
    }
    
    func updateViewAccountAddressInWeb(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESS_IN_WEB())
    }
    
    func updateViewEnableAdvancedMode(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_ENABLE_ADVANCE_MODE())
    }
    
    
    func updateImportAccount(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_IMPORT_ACCOUNT())
    }
    
    func updateImportWatchOnlyAccount(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_IMPORT_WATCH_ONLY_ACCOUNT())
    }
    
    func updateImportPrivateKey(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_IMPORT_PRIVATE_KEY())
    }
    
    func updateImportWatchOnlyAddress(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_IMPORT_WATCH_ONLY_ADDRESS())
    }
    
    func updateChangeBlockExplorerType(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_CHANGE_BLOCKEXPLORER_TYPE())
    }
    
    func updateViewExtendedPublicKey(_ notification: Notification) -> ()  {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY())
    }
    
    func updateViewExtendedPrivateKey(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_EXTENDED_PRIVATE_KEY())
    }
    
    func updateViewAccountsPrivateKey(_ notification: Notification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_ACCOUNT_PRIVATE_KEY())
    }
    
    fileprivate func updateUserAnalyticsWithEvent(_ event: String) -> ()  {
        let userAnalyticsDict = NSMutableDictionary(dictionary:TLPreferences.getAnalyticsDict() ?? NSDictionary())
        let dict = (userAnalyticsDict.value(forKey: event) as! NSNumber? ?? 0)
        let eventCount = dict.uintValue
        userAnalyticsDict.setObject(eventCount + 1, forKey:event as NSCopying)
        TLPreferences.setAnalyticsDict(userAnalyticsDict)
    }
}
