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

@objc class TLAnalytics {
    struct STATIC_MEMBERS {
        static var _instance:TLAnalytics? = nil
    }
    
    class func instance() -> (TLAnalytics) {
        if(STATIC_MEMBERS._instance == nil) {
            STATIC_MEMBERS._instance = TLAnalytics()
        }
        return STATIC_MEMBERS._instance!
    }
    
    init() {
        observeUserInterfaceInteractions()
    }
    
    private func observeUserInterfaceInteractionsWithAchievements() -> () {
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateSentPayment:",
            name:TLNotificationEvents.EVENT_SEND_PAYMENT(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateReceivePayment:",
            name:TLNotificationEvents.EVENT_RECEIVE_PAYMENT(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateViewHistoryScreen:",
            name:TLNotificationEvents.EVENT_VIEW_HISTORY(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateCreateNewAccount:",
            name:TLNotificationEvents.EVENT_CREATE_NEW_ACCOUNT(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateEditAccountName:",
            name:TLNotificationEvents.EVENT_EDIT_ACCOUNT_NAME(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateArchiveAccount:",
            name:TLNotificationEvents.EVENT_ARCHIVE_ACCOUNT(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateEnablePINCode:",
            name:TLNotificationEvents.EVENT_ENABLE_PIN_CODE(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateBackupPassphrase:",
            name:TLNotificationEvents.EVENT_BACKUP_PASSPHRASE(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateRestoreWallet:",
            name:TLNotificationEvents.EVENT_RESTORE_WALLET(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateAddToAddressBook:",
            name:TLNotificationEvents.EVENT_ADD_TO_ADDRESS_BOOK(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateEditEntryAddressBook:",
            name:TLNotificationEvents.EVENT_EDIT_ENTRY_ADDRESS_BOOK(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateDeleteEntryAddressBook:",
            name:TLNotificationEvents.EVENT_DELETE_ENTRY_ADDRESS_BOOK(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateSendToAddressInAddressBook:",
            name:TLNotificationEvents.EVENT_SEND_TO_ADDRESS_IN_ADDRESS_BOOK(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateTagTransaction:",
            name:TLNotificationEvents.EVENT_TAG_TRANSACTION(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateToggleAutomaticTxFee:",
            name:TLNotificationEvents.EVENT_TOGGLE_AUTOMATIC_TX_FEE(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateChangeAutomaticTxFee:",
            name:TLNotificationEvents.EVENT_CHANGE_AUTOMATIC_TX_FEE(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateViewAccountAddresses:",
            name:TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESSES(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateViewAccountAddress:",
            name:TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESS(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateViewTransactionInWeb:",
            name:TLNotificationEvents.EVENT_VIEW_TRANSACTION_IN_WEB(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateViewAccountAddressInWeb:",
            name:TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESS_IN_WEB(), object:nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateImportAccount:",
            name:TLNotificationEvents.EVENT_IMPORT_ACCOUNT(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateImportWatchOnlyAccount:",
            name:TLNotificationEvents.EVENT_IMPORT_WATCH_ONLY_ACCOUNT(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateImportPrivateKey:",
            name:TLNotificationEvents.EVENT_IMPORT_PRIVATE_KEY(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateImportWatchOnlyAddress:",
            name:TLNotificationEvents.EVENT_IMPORT_WATCH_ONLY_ADDRESS(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateChangeBlockExplorerType:",
            name:TLNotificationEvents.EVENT_CHANGE_BLOCKEXPLORER_TYPE(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateViewExtendedPublicKey:",
            name:TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateViewExtendedPrivateKey:",
            name:TLNotificationEvents.EVENT_VIEW_EXTENDED_PRIVATE_KEY(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateViewAccountsPrivateKey:",
            name:TLNotificationEvents.EVENT_VIEW_ACCOUNT_PRIVATE_KEY(), object:nil)
    }
    
    private func observeUserInterfaceInteractions() -> () {
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateViewSendScreen:",
            name:TLNotificationEvents.EVENT_VIEW_SEND_SCREEN(), object:nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateViewReceiveScreen:",
            name:TLNotificationEvents.EVENT_VIEW_RECEIVE_SCREEN(), object:nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateViewAccountsScreen:",
            name:TLNotificationEvents.EVENT_VIEW_ACCOUNTS_SCREEN(), object:nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateViewManageAccountsScreen:",
            name:TLNotificationEvents.EVENT_VIEW_MANAGE_ACCOUNTS_SCREEN(), object:nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateViewHelpScreen:",
            name:TLNotificationEvents.EVENT_VIEW_HELP_SCREEN(), object:nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateViewSettingsScreen:",
            name:TLNotificationEvents.EVENT_VIEW_SETTINGS_SCREEN(), object:nil)
        
        observeUserInterfaceInteractionsWithAchievements()
    }
    
    func updateViewSendScreen(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_SEND_SCREEN())
    }
    
    func updateViewReceiveScreen(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_RECEIVE_SCREEN())
    }
    
    func updateViewAccountsScreen(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_ACCOUNTS_SCREEN())
    }
    
    func updateViewManageAccountsScreen(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_MANAGE_ACCOUNTS_SCREEN())
    }
    
    func updateViewHelpScreen(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_HELP_SCREEN())
    }
    
    func updateViewSettingsScreen(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_SETTINGS_SCREEN())
    }
    
    // Achievements
    func updateSentPayment(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_SEND_PAYMENT())
    }
    
    func updateReceivePayment(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_RECEIVE_PAYMENT())
    }
    
    func updateViewHistoryScreen(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_HISTORY())
    }
    
    func updateCreateNewAccount(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_CREATE_NEW_ACCOUNT())
    }
    
    func updateEditAccountName(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_EDIT_ACCOUNT_NAME())
    }
    
    func updateArchiveAccount(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_ARCHIVE_ACCOUNT())
    }
    
    func updateEnablePINCode(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_ENABLE_PIN_CODE())
    }
    
    func updateBackupPassphrase(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_BACKUP_PASSPHRASE())
    }
    
    func updateRestoreWallet(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_RESTORE_WALLET())
    }
    
    func updateAddToAddressBook(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_ADD_TO_ADDRESS_BOOK())
    }
    
    func updateEditEntryAddressBook(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_EDIT_ENTRY_ADDRESS_BOOK())
    }
    
    func updateDeleteEntryAddressBook(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_DELETE_ENTRY_ADDRESS_BOOK())
    }
    
    func updateSendToAddressInAddressBook(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_SEND_TO_ADDRESS_IN_ADDRESS_BOOK())
    }
    
    func updateTagTransaction(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_TAG_TRANSACTION())
    }
    
    func updateToggleAutomaticTxFee(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_TOGGLE_AUTOMATIC_TX_FEE())
    }
    
    func updateChangeAutomaticTxFee(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_CHANGE_AUTOMATIC_TX_FEE())
    }
    
    func updateViewAccountAddresses(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESSES())
    }
    
    func updateViewAccountAddress(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESS())
    }
    
    func updateViewTransactionInWeb(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_TRANSACTION_IN_WEB())
    }
    
    func updateViewAccountAddressInWeb(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESS_IN_WEB())
    }
    
    
    func updateImportAccount(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_IMPORT_ACCOUNT())
    }
    
    func updateImportWatchOnlyAccount(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_IMPORT_WATCH_ONLY_ACCOUNT())
    }
    
    func updateImportPrivateKey(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_IMPORT_PRIVATE_KEY())
    }
    
    func updateImportWatchOnlyAddress(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_IMPORT_WATCH_ONLY_ADDRESS())
    }
    
    func updateChangeBlockExplorerType(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_CHANGE_BLOCKEXPLORER_TYPE())
    }
    
    func updateViewExtendedPublicKey(notification: NSNotification) -> ()  {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY())
    }
    
    func updateViewExtendedPrivateKey(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_EXTENDED_PRIVATE_KEY())
    }
    
    func updateViewAccountsPrivateKey(notification: NSNotification) -> () {
        updateUserAnalyticsWithEvent(TLNotificationEvents.EVENT_VIEW_ACCOUNT_PRIVATE_KEY())
    }
    
    private func updateUserAnalyticsWithEvent(event: String) -> ()  {
        let userAnalyticsDict = NSMutableDictionary(dictionary:TLPreferences.getAnalyticsDict() ?? NSDictionary())
        let dict = (userAnalyticsDict.valueForKey(event) as! NSNumber? ?? 0)
        let eventCount = dict.unsignedIntegerValue
        userAnalyticsDict.setObject(eventCount + 1, forKey:event)
        TLPreferences.setAnalyticsDict(userAnalyticsDict)
    }
}