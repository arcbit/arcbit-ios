//
//  AppDelegate.swift
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
import UIKit
import AVFoundation
import HockeySDK

@UIApplicationMain
@objc(AppDelegate) class AppDelegate: UIResponder, UIApplicationDelegate, LTHPasscodeViewControllerDelegate, BITHockeyManagerDelegate {
    
    let MAX_CONSECUTIVE_FAILED_STEALTH_CHALLENGE_COUNT = 8
    let SAVE_WALLET_PAYLOAD_DELAY = 2.0
    let DEFAULT_BLOCKEXPLORER_API = TLBlockExplorer.Blockchain
    let RESPOND_TO_STEALTH_PAYMENT_GET_TX_TRIES_MAX_TRIES = 3

    var window:UIWindow?
    private var storyboard:UIStoryboard?
    private var modalDelegate:AnyObject?
    var appWallet = TLWallet(walletName: "App Wallet")
    var accounts:TLAccounts?
    var importedAccounts:TLAccounts?
    var importedWatchAccounts:TLAccounts?
    var importedAddresses:TLImportedAddresses?
    var importedWatchAddresses:TLImportedAddresses?
    var godSend:TLSpaghettiGodSend?
    var receiveSelectedObject:TLSelectedObject?
    var historySelectedObject:TLSelectedObject?
    var bitcoinURIOptionsDict:NSDictionary?
    var justSetupHDWallet = false
    var giveExitAppNoticeForBlockExplorerAPIToTakeEffect = false
    private var isAccountsAndImportsLoaded = false
    var saveWalletJSONEnabled = true
    var consecutiveFailedStealthChallengeCount = 0
    private var savedPasscodeViewDefaultBackgroundColor: UIColor?
    private var savedPasscodeViewDefaultLabelTextColor: UIColor?
    private var savedPasscodeViewDefaultPasscodeTextColor: UIColor?
    private var hasFinishLaunching = false
    private var respondToStealthPaymentGetTxTries = 0
    var scannedEncryptedPrivateKey:String? = nil
    var scannedAddressBookAddress:String? = nil
    var doHiddenPresentAndDimissTransparentViewController = false
    let pendingOperations = PendingOperations()
    var listeningToToAddress:String? = nil
    var inputedToAddress: String? = nil
    var inputedToAmount: TLCoin? = nil
    var pendingSelfStealthPaymentTxid: String? = nil
    var sentPaymentHashes = [String:String]()

    class func instance() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! (AppDelegate)
    }
    
    private func getSendFromType() -> TLSendFromType {
        return TLPreferences.getSendFromType()
    }
    
    private func getSendFromIndex() -> Int {
        return Int(TLPreferences.getSendFromIndex())
    }
    
    func aAccountNeedsRecovering() -> Bool {
        for (var i = 0; i < AppDelegate.instance().accounts!.getNumberOfAccounts();  i++) {
            let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                return true
            }
        }
        
        for (var i = 0; i < AppDelegate.instance().importedAccounts!.getNumberOfAccounts();  i++) {
            let accountObject = AppDelegate.instance().importedAccounts!.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                return true
            }
        }
        
        for (var i = 0; i < AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts();  i++) {
            let accountObject = AppDelegate.instance().importedWatchAccounts!.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                return true
            }
        }
        return false
    }
    
    func checkToRecoverAccounts() {
        for (var i = 0; i < AppDelegate.instance().accounts!.getNumberOfAccounts();  i++) {
            let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                accountObject.clearAllAddresses()
                accountObject.recoverAccount(false, recoverStealthPayments: true)
            }
        }
        
        for (var i = 0; i < AppDelegate.instance().importedAccounts!.getNumberOfAccounts();  i++) {
            let accountObject = AppDelegate.instance().importedAccounts!.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                accountObject.clearAllAddresses()
                accountObject.recoverAccount(false, recoverStealthPayments: true)
            }
        }
        
        for (var i = 0; i < AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts();  i++) {
            let accountObject = AppDelegate.instance().importedWatchAccounts!.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                accountObject.clearAllAddresses()
                accountObject.recoverAccount(false, recoverStealthPayments: true)
            }
        }
    }
    
    func updateGodSend() {
        var sendFromType = TLPreferences.getSendFromType()
        var sendFromIndex = Int(TLPreferences.getSendFromIndex())
        
        if (sendFromType == .HDWallet) {
            if (sendFromIndex > self.accounts!.getNumberOfAccounts() - 1 ) {
                sendFromType = TLSendFromType.HDWallet
                sendFromIndex = 0
            }
        } else if (sendFromType == .ImportedAccount) {
            if (sendFromIndex > self.importedAccounts!.getNumberOfAccounts() - 1) {
                sendFromType = TLSendFromType.HDWallet
                sendFromIndex = 0
            }
        } else if (sendFromType == .ImportedWatchAccount) {
            if (sendFromIndex > self.importedWatchAccounts!.getNumberOfAccounts() - 1) {
                sendFromType = TLSendFromType.HDWallet
                sendFromIndex = 0
            }
        } else if (sendFromType == .ImportedAddress) {
            if (sendFromIndex > self.importedAddresses!.getCount() - 1 ) {
                sendFromType = TLSendFromType.HDWallet
                sendFromIndex = 0
            }
        } else if (sendFromType == .ImportedWatchAddress) {
            if (sendFromIndex > self.importedWatchAddresses!.getCount() - 1) {
                sendFromType = TLSendFromType.HDWallet
                sendFromIndex = 0
            }
        }
        
        self.updateGodSend(sendFromType, sendFromIndex:sendFromIndex)
    }
    
    func updateGodSend(sendFromType: TLSendFromType, sendFromIndex: Int) {
        TLPreferences.setSendFromType(sendFromType)
        TLPreferences.setSendFromIndex(UInt(sendFromIndex))
        
        if (sendFromType == .HDWallet) {
            let accountObject = self.accounts!.getAccountObjectForIdx(sendFromIndex)
            self.godSend?.setOnlyFromAccount(accountObject)
        } else if (sendFromType == .ImportedAccount) {
            let accountObject = self.importedAccounts!.getAccountObjectForIdx(sendFromIndex)
            self.godSend?.setOnlyFromAccount(accountObject)
        } else if (sendFromType == .ImportedWatchAccount) {
            let accountObject = self.importedWatchAccounts!.getAccountObjectForIdx(sendFromIndex)
            self.godSend?.setOnlyFromAccount(accountObject)
        } else if (sendFromType == .ImportedAddress) {
            let importedAddress = self.importedAddresses!.getAddressObjectAtIdx(sendFromIndex)
            self.godSend?.setOnlyFromAddress(importedAddress)
        } else if (sendFromType == .ImportedWatchAddress) {
            let importedAddress = self.importedWatchAddresses!.getAddressObjectAtIdx(sendFromIndex)
            self.godSend?.setOnlyFromAddress(importedAddress)
        }
    }
    
    func updateReceiveSelectedObject(sendFromType: TLSendFromType, sendFromIndex: Int) {
        if (sendFromType == .HDWallet) {
            let accountObject = self.accounts!.getAccountObjectForIdx(sendFromIndex)
            self.receiveSelectedObject!.setSelectedAccount(accountObject)
        } else if (sendFromType == .ImportedAccount) {
            let accountObject = self.importedAccounts!.getAccountObjectForIdx(sendFromIndex)
            self.receiveSelectedObject!.setSelectedAccount(accountObject)
        } else if (sendFromType == .ImportedWatchAccount) {
            let accountObject = self.importedWatchAccounts!.getAccountObjectForIdx(sendFromIndex)
            self.receiveSelectedObject!.setSelectedAccount(accountObject)
        } else if (sendFromType == .ImportedAddress) {
            let importedAddress = self.importedAddresses!.getAddressObjectAtIdx(sendFromIndex)
            self.receiveSelectedObject!.setSelectedAddress(importedAddress)
        } else if (sendFromType == .ImportedWatchAddress) {
            let importedAddress = self.importedWatchAddresses!.getAddressObjectAtIdx(sendFromIndex)
            self.receiveSelectedObject!.setSelectedAddress(importedAddress)
        }
    }
    
    func updateHistorySelectedObject(sendFromType: TLSendFromType, sendFromIndex: Int) {
        if (sendFromType == .HDWallet) {
            let accountObject = self.accounts!.getAccountObjectForIdx(sendFromIndex)
            self.historySelectedObject!.setSelectedAccount(accountObject)
        } else if (sendFromType == .ImportedAccount) {
            let accountObject = self.importedAccounts!.getAccountObjectForIdx(sendFromIndex)
            self.historySelectedObject!.setSelectedAccount(accountObject)
        } else if (sendFromType == .ImportedWatchAccount) {
            let accountObject = self.importedWatchAccounts!.getAccountObjectForIdx(sendFromIndex)
            self.historySelectedObject!.setSelectedAccount(accountObject)
        } else if (sendFromType == .ImportedAddress) {
            let importedAddress = self.importedAddresses!.getAddressObjectAtIdx(sendFromIndex)
            self.historySelectedObject!.setSelectedAddress(importedAddress)
        } else if (sendFromType == .ImportedWatchAddress) {
            let importedAddress = self.importedWatchAddresses!.getAddressObjectAtIdx(sendFromIndex)
            self.historySelectedObject!.setSelectedAddress(importedAddress)
        }
    }
    
    
    func showLockViewForEnteringPasscode(notification: NSNotification) {
        if (!hasFinishLaunching && LTHPasscodeViewController.doesPasscodeExist()) {
            //LTHPasscodeViewController.sharedUser().maxNumberOfAllowedFailedAttempts = 0
            UIApplication.sharedApplication().statusBarHidden = true
            LTHPasscodeViewController.sharedUser().delegate = self
            LTHPasscodeViewController.sharedUser().showLockScreenWithAnimation(false,
                withLogout:false                                                         ,
                andLogoutTitle:nil)
        }
        
        hasFinishLaunching = true
    }
    
    func recoverHDWallet(mnemonic: String, shouldRefreshApp: Bool = true) {
        if shouldRefreshApp {
            self.refreshApp(mnemonic)
        } else {
            let masterHex = TLHDWalletWrapper.getMasterHex(mnemonic)
            self.appWallet.createInitialWalletPayload(mnemonic, masterHex:masterHex)
            
            self.accounts = TLAccounts(appWallet: self.appWallet, accountsArray:self.appWallet.getAccountObjectArray(), accountType:.HDWallet)
            self.importedWatchAccounts = TLAccounts(appWallet: self.appWallet, accountsArray:self.appWallet.getWatchOnlyAccountArray(), accountType:.ImportedWatch)
            self.importedAccounts = TLAccounts(appWallet: self.appWallet, accountsArray:self.appWallet.getImportedAccountArray(), accountType:.Imported)
            self.importedAddresses = TLImportedAddresses(appWallet: self.appWallet, importedAddresses:self.appWallet.getImportedPrivateKeyArray(), accountAddressType:.Imported)
            self.importedWatchAddresses = TLImportedAddresses(appWallet: self.appWallet, importedAddresses:self.appWallet.getWatchOnlyAddressArray(), accountAddressType:.ImportedWatch)
        }
        
        var accountIdx = 0
        var consecutiveUnusedAccountCount = 0
        let MAX_CONSECUTIVE_UNUSED_ACCOUNT_LOOK_AHEAD_COUNT = 4
        
        while (true) {
            let accountName = String(format:"Account %lu".localized, (accountIdx + 1))
            let accountObject = self.accounts!.createNewAccount(accountName, accountType:.Normal, preloadStartingAddresses:false)
            
            DLog("recoverHDWalletaccountName %@", accountName)
            
            let sumMainAndChangeAddressMaxIdx = accountObject.recoverAccount(false)
            DLog(String(format: "accountName %@ sumMainAndChangeAddressMaxIdx: %ld", accountName, sumMainAndChangeAddressMaxIdx))
            if sumMainAndChangeAddressMaxIdx > -2 || accountObject.stealthWallet!.checkIfHaveStealthPayments() {
                consecutiveUnusedAccountCount = 0
            } else {
                consecutiveUnusedAccountCount++
                if (consecutiveUnusedAccountCount == MAX_CONSECUTIVE_UNUSED_ACCOUNT_LOOK_AHEAD_COUNT) {
                    break
                }
            }
            
            accountIdx += 1
        }
        
        DLog("recoverHDWallet getNumberOfAccounts: \(self.accounts!.getNumberOfAccounts())")
        if (self.accounts!.getNumberOfAccounts() == 0) {
            let accountObject = self.accounts!.createNewAccount("Account 1".localized, accountType:.Normal)
        } else if (self.accounts!.getNumberOfAccounts() > 1) {
            while (self.accounts!.getNumberOfAccounts() > 1 && consecutiveUnusedAccountCount > 0) {
                self.accounts!.popTopAccount()
                consecutiveUnusedAccountCount--
            }
        }
    }
    
    // work around to show SendView
    func checkToShowSendViewWithURL(notification: NSNotification) {
        if (self.bitcoinURIOptionsDict != nil) {
            assert(self.window!.rootViewController is ECSlidingViewController, "rootViewController != ECSlidingViewController")
            let vc = self.window!.rootViewController as! ECSlidingViewController
            vc.topViewController.showSendView()
        }
    }
    
    func setSettingsPasscodeViewColors() {
        LTHPasscodeViewController.sharedUser().view.backgroundColor = savedPasscodeViewDefaultBackgroundColor
        
        LTHPasscodeViewController.sharedUser().failedAttemptLabel.textColor = savedPasscodeViewDefaultLabelTextColor
        LTHPasscodeViewController.sharedUser().enterPasscodeLabel.textColor = savedPasscodeViewDefaultLabelTextColor
        LTHPasscodeViewController.sharedUser().OKButton.setTitleColor(savedPasscodeViewDefaultLabelTextColor, forState:UIControlState.Normal)
        
        LTHPasscodeViewController.sharedUser().firstDigitTextField.textColor = savedPasscodeViewDefaultPasscodeTextColor
        LTHPasscodeViewController.sharedUser().secondDigitTextField.textColor = savedPasscodeViewDefaultPasscodeTextColor
        LTHPasscodeViewController.sharedUser().thirdDigitTextField.textColor = savedPasscodeViewDefaultPasscodeTextColor
        LTHPasscodeViewController.sharedUser().fourthDigitTextField.textColor = savedPasscodeViewDefaultPasscodeTextColor
    }
    
    private func setupPasscodeViewColors() {
        savedPasscodeViewDefaultBackgroundColor = LTHPasscodeViewController.sharedUser().backgroundColor
        savedPasscodeViewDefaultLabelTextColor = LTHPasscodeViewController.sharedUser().labelTextColor
        savedPasscodeViewDefaultPasscodeTextColor = LTHPasscodeViewController.sharedUser().passcodeTextColor
        
        LTHPasscodeViewController.sharedUser().backgroundColor = TLColors.mainAppColor()
        LTHPasscodeViewController.sharedUser().labelTextColor = TLColors.mainAppOppositeColor()
        LTHPasscodeViewController.sharedUser().passcodeTextColor = TLColors.mainAppOppositeColor()
        
        LTHPasscodeViewController.sharedUser().navigationBarTintColor = TLColors.mainAppColor()
        LTHPasscodeViewController.sharedUser().navigationTintColor = TLColors.mainAppOppositeColor()
        LTHPasscodeViewController.sharedUser().navigationTitleColor = TLColors.mainAppOppositeColor()
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        BITHockeyManager.sharedHockeyManager().configureWithIdentifier("1930166332eb254d7c9cecd88f3ca6b0")
        BITHockeyManager.sharedHockeyManager().startManager()
        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
        
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true

        self.window!.backgroundColor = TLColors.mainAppColor()
        application.statusBarStyle = UIStatusBarStyle.LightContent
        
        self.justSetupHDWallet = false
        let appVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        if (TLPreferences.getInstallDate() != nil) {
            TLPreferences.setHasSetupHDWallet(false)
            TLPreferences.setInstallDate()
            TLPreferences.setAppVersion(appVersion)
        } else if appVersion != TLPreferences.getAppVersion() {
            DLog("set new appVersion %@", appVersion)
            TLPreferences.setAppVersion(appVersion)
        }
        
        self.setupPasscodeViewColors()
        
        self.isAccountsAndImportsLoaded = false
        
        if (TLPreferences.hasSetupHDWallet() && UIApplication.instancesRespondToSelector("registerUserNotificationSettings"))
        {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories:nil))
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"checkToShowSendViewWithURL:", name:UIApplicationDidBecomeActiveNotification, object:nil)
        
        // condition is used so that I dont prompt user to setup notifactions when just installed app
        if (TLPreferences.hasSetupHDWallet()) {
            //setUpLocalNotification()
        }
        
        hasFinishLaunching = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"showLockViewForEnteringPasscode:", name:TLNotificationEvents.EVENT_SEND_SCREEN_LOADING(), object:nil)
        
        return true
    }
    
    func refreshApp(passphrase: String, clearWalletInMemory: Bool = true) {
        if (TLPreferences.getCloudBackupWalletFileName() == nil) {
            TLPreferences.setCloudBackupWalletFileName()
        }
        
        TLPreferences.deleteWalletPassphrase()
        TLPreferences.deleteEncryptedWalletJSONPassphrase()
        
        TLPreferences.setWalletPassphrase(passphrase)
        TLPreferences.setEncryptedWalletJSONPassphrase(passphrase)
        TLPreferences.clearEncryptedWalletPassphraseKey()

        TLPreferences.setCanRestoreDeletedApp(true)
        TLPreferences.setInAppSettingsCanRestoreDeletedApp(true)
        
        TLPreferences.setEnableBackupWithiCloud(false)
        TLPreferences.setInAppSettingsKitEnableBackupWithiCloud(false)
        
        TLPreferences.setIsAutomaticFee(true)
        TLPreferences.setInAppSettingsKitTransactionFee(TLWalletUtils.DEFAULT_FEE_AMOUNT())
        TLPreferences.setEnablePINCode(false)
        TLSuggestions.instance().enabledAllSuggestions()
        TLPreferences.resetBlockExplorerAPIURL()
        
        TLPreferences.setBlockExplorerAPI(String(format:"%ld", DEFAULT_BLOCKEXPLORER_API.rawValue))
        TLPreferences.setInAppSettingsKitBlockExplorerAPI(String(format:"%ld", DEFAULT_BLOCKEXPLORER_API.rawValue))
        
        TLPreferences.resetStealthExplorerAPIURL()
        TLPreferences.resetStealthServerPort()
        TLPreferences.resetStealthWebSocketPort()

        LTHPasscodeViewController.deletePasscode()
        
        let DEFAULT_CURRENCY_IDX = "20"
        TLPreferences.setCurrency(DEFAULT_CURRENCY_IDX)
        TLPreferences.setInAppSettingsKitCurrency(DEFAULT_CURRENCY_IDX)
        TLPreferences.setEnableSoundNotification(true)
        
        TLPreferences.setSendFromType(.HDWallet)
        TLPreferences.setSendFromIndex(0)
        
        if clearWalletInMemory {
            let masterHex = TLHDWalletWrapper.getMasterHex(passphrase)
            self.appWallet.createInitialWalletPayload(passphrase, masterHex:masterHex)
            
            self.accounts = TLAccounts(appWallet: self.appWallet, accountsArray:self.appWallet.getAccountObjectArray(), accountType:.HDWallet)
            self.importedWatchAccounts = TLAccounts(appWallet: self.appWallet, accountsArray:self.appWallet.getWatchOnlyAccountArray(), accountType:.ImportedWatch)
            self.importedAccounts = TLAccounts(appWallet:self.appWallet, accountsArray:self.appWallet.getImportedAccountArray(), accountType:.Imported)
            self.importedAddresses = TLImportedAddresses(appWallet: self.appWallet, importedAddresses:self.appWallet.getImportedPrivateKeyArray(), accountAddressType:.Imported)
            self.importedWatchAddresses = TLImportedAddresses(appWallet: self.appWallet, importedAddresses:self.appWallet.getWatchOnlyAddressArray(), accountAddressType:.ImportedWatch)
        }
        
        self.receiveSelectedObject = TLSelectedObject()
        self.historySelectedObject = TLSelectedObject()
        
        //self.appWallet.addAddressBookEntry("vJmwhHhMNevDQh188gSeHd2xxxYGBQmnVuMY2yG2MmVTC31UWN5s3vaM3xsM2Q1bUremdK1W7eNVgPg1BnvbTyQuDtMKAYJanahvse", label: "ArcBit Donation")
    }
    
    func setAccountsListeningToStealthPaymentsToFalse() {
        for (var i = 0; i < self.accounts!.getNumberOfAccounts();  i++) {
            let accountObject = self.accounts!.getAccountObjectForIdx(i)
            if accountObject.stealthWallet != nil {
                accountObject.stealthWallet!.isListeningToStealthPayment = false
            }
        }
        
        for (var i = 0; i < self.importedAccounts!.getNumberOfAccounts();  i++) {
            let accountObject = self.importedAccounts!.getAccountObjectForIdx(i)
            if accountObject.stealthWallet != nil {
                accountObject.stealthWallet!.isListeningToStealthPayment = false
            }
        }
    }
    
    func respondToStealthChallegeNotification(note: NSNotification) {
        let responseDict = note.object as! NSDictionary
        let challenge = responseDict.objectForKey("challenge") as! String
        let lock = NSLock()
        lock.lock()
        TLStealthWebSocket.instance().challenge = challenge
        lock.unlock()
        self.respondToStealthChallege(challenge)
    }
    
    func respondToStealthChallege(challenge: String) {
        if (!self.isAccountsAndImportsLoaded || !TLStealthWebSocket.instance().isWebSocketOpen()) {
            return
        }

        for (var i = 0; i < self.accounts!.getNumberOfAccounts();  i++) {
            let accountObject = self.accounts!.getAccountObjectForIdx(i)
            if accountObject.hasFetchedAccountData() &&
                accountObject.stealthWallet != nil && accountObject.stealthWallet!.isListeningToStealthPayment == false {
                    let addrAndSignature = accountObject.stealthWallet!.getStealthAddressAndSignatureFromChallenge(challenge)
                    TLStealthWebSocket.instance().sendMessageSubscribeToStealthAddress(addrAndSignature.0, signature: addrAndSignature.1)
            }
        }
        
        for (var i = 0; i < self.importedAccounts!.getNumberOfAccounts();  i++) {
            let accountObject = self.importedAccounts!.getAccountObjectForIdx(i)
            if accountObject.hasFetchedAccountData() &&
                accountObject.stealthWallet != nil && accountObject.stealthWallet!.isListeningToStealthPayment == false {
                    let addrAndSignature = accountObject.stealthWallet!.getStealthAddressAndSignatureFromChallenge(challenge)
                    TLStealthWebSocket.instance().sendMessageSubscribeToStealthAddress(addrAndSignature.0, signature: addrAndSignature.1)
            }
        }
    }
    
    func respondToStealthAddressSubscription(note: NSNotification) {
        let responseDict = note.object as! NSDictionary
        let stealthAddress = responseDict.objectForKey("addr") as! String
        let subscriptionSuccess = responseDict.objectForKey("success") as! String
        if subscriptionSuccess == "False" && consecutiveFailedStealthChallengeCount < MAX_CONSECUTIVE_FAILED_STEALTH_CHALLENGE_COUNT {
            consecutiveFailedStealthChallengeCount++
            TLStealthWebSocket.instance().sendMessageGetChallenge()
            return
        }
        consecutiveFailedStealthChallengeCount = 0
        
        for (var i = 0; i < self.accounts!.getNumberOfAccounts();  i++) {
            let accountObject = self.accounts!.getAccountObjectForIdx(i)
            if accountObject.stealthWallet!.getStealthAddress() == stealthAddress {
                accountObject.stealthWallet!.isListeningToStealthPayment = true
            }
        }
        
        for (var i = 0; i < self.importedAccounts!.getNumberOfAccounts();  i++) {
            let accountObject = self.importedAccounts!.getAccountObjectForIdx(i)
            if accountObject.stealthWallet!.getStealthAddress() == stealthAddress {
                accountObject.stealthWallet!.isListeningToStealthPayment = true
            }
        }
    }

    func handleGetTxSuccessForRespondToStealthPayment(stealthAddress: String, paymentAddress: String,
        txid: String, txTime: UInt64, txObject: TLTxObject) {
            let inputAddresses = txObject.getInputAddressArray()
            let outputAddresses = txObject.getOutputAddressArray()
            
            if find(outputAddresses, paymentAddress) == nil {
                return
            }

            let possibleStealthDataScripts = txObject.getPossibleStealthDataScripts()
            
            func proccessStealthPayment(accountObject: TLAccountObject) {
                if accountObject.stealthWallet!.getStealthAddress() == stealthAddress {
                    if accountObject.hasFetchedAccountData() {
                        for stealthDataScript in possibleStealthDataScripts {
                            let privateKey = accountObject.stealthWallet!.generateAndAddStealthAddressPaymentKey(stealthDataScript, expectedAddress: paymentAddress,
                                txid: txid, txTime: txTime, stealthPaymentStatus: TLStealthPaymentStatus.Unspent)
                            if privateKey != nil {
                                self.handleNewTxForAccount(accountObject, txObject: txObject)
                                break
                            }
                        }
                    }
                } else {
                    // must refresh account balance if a input address belongs to account
                    // this is needed because websocket api does not notify of addresses being used as inputs
                    for address in inputAddresses {
                        if accountObject.hasFetchedAccountData() && accountObject.isAddressPartOfAccount(address) {
                            self.handleNewTxForAccount(accountObject, txObject: txObject)
                        }
                    }
                }
            }

            for (var i = 0; i < self.accounts!.getNumberOfAccounts();  i++) {
                let accountObject = self.accounts!.getAccountObjectForIdx(i)
                proccessStealthPayment(accountObject)
            }
            
            for (var i = 0; i < self.importedAccounts!.getNumberOfAccounts();  i++) {
                let accountObject = self.importedAccounts!.getAccountObjectForIdx(i)
                proccessStealthPayment(accountObject)
            }
            
            for (var i = 0; i < self.importedWatchAccounts!.getNumberOfAccounts();  i++) {
                let accountObject = self.importedAccounts!.getAccountObjectForIdx(i)
                for address in inputAddresses {
                    if accountObject.isAddressPartOfAccount(address) {
                        self.handleNewTxForAccount(accountObject, txObject: txObject)
                    }
                }
            }
            for (var i = 0; i < self.importedAddresses!.getCount();  i++) {
                let importedAddress = self.importedAddresses!.getAddressObjectAtIdx(i)
                for addr in inputAddresses {
                    if (addr == importedAddress.getAddress()) {
                        self.handleNewTxForImportedAddress(importedAddress, txObject: txObject)
                    }
                }
            }
            for (var i = 0; i < self.importedWatchAddresses!.getCount();  i++) {
                let importedAddress = self.importedWatchAddresses!.getAddressObjectAtIdx(i)
                for addr in inputAddresses {
                    if (addr == importedAddress.getAddress()) {
                        self.handleNewTxForImportedAddress(importedAddress, txObject: txObject)
                    }
                }
            }
    }
    
    func respondToStealthPayment(note: NSNotification) {
        let responseDict = note.object as! NSDictionary
        let stealthAddress = responseDict.objectForKey("stealth_addr") as! String
        let txid = responseDict.objectForKey("txid") as! String
        let paymentAddress = responseDict.objectForKey("addr") as! String
        let txTime = UInt64((responseDict.objectForKey("time") as! NSNumber).unsignedLongLongValue)
        DLog("respondToStealthPayment stealthAddress: %@", stealthAddress)
        DLog("respondToStealthPayment respondToStealthPaymentGetTxTries: \(self.respondToStealthPaymentGetTxTries)")

        if self.respondToStealthPaymentGetTxTries < self.RESPOND_TO_STEALTH_PAYMENT_GET_TX_TRIES_MAX_TRIES {
            TLBlockExplorerAPI.instance().getTx(txid, success: { (jsonData:AnyObject!) -> () in
                let txObject = TLTxObject(dict:jsonData as! NSDictionary)
                self.handleGetTxSuccessForRespondToStealthPayment(stealthAddress,
                    paymentAddress: paymentAddress, txid: txid, txTime: txTime, txObject: txObject)
                
                    self.respondToStealthPaymentGetTxTries = 0
                }, failure: { (code: NSInteger, status: String!) -> () in
                    DLog("respondToStealthPayment getTx fail %@", txid)
                    self.respondToStealthPayment(note)
                    self.respondToStealthPaymentGetTxTries++
            })
        }
    }
    
    func setWalletTransactionListenerClosed() {
        DLog("setWalletTransactionListenerClosed")
        for (var i = 0; i < self.accounts!.getNumberOfAccounts();  i++) {
            let accountObject = self.accounts!.getAccountObjectForIdx(i)
            accountObject.listeningToIncomingTransactions = false
        }
        for (var i = 0; i < self.importedAccounts!.getNumberOfAccounts();  i++) {
            let accountObject = self.importedAccounts!.getAccountObjectForIdx(i)
            accountObject.listeningToIncomingTransactions = false
        }
        for (var i = 0; i < self.importedWatchAccounts!.getNumberOfAccounts();  i++) {
            let accountObject = self.importedWatchAccounts!.getAccountObjectForIdx(i)
            accountObject.listeningToIncomingTransactions = false
        }
        for (var i = 0; i < self.importedAddresses!.getCount();  i++) {
            let importedAddress = self.importedAddresses!.getAddressObjectAtIdx(i)
            importedAddress.listeningToIncomingTransactions = false
        }
        for (var i = 0; i < self.importedWatchAddresses!.getCount();  i++) {
            let importedAddress = self.importedWatchAddresses!.getAddressObjectAtIdx(i)
            importedAddress.listeningToIncomingTransactions = false
        }
    }
    
    func listenToIncomingTransactionForGeneratedAddress(note: NSNotification) {
        let address: AnyObject? = note.object
        
        TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
    }
    
    func updateModelWithNewTransaction(note: NSNotification) {
        let txDict = note.object as! NSDictionary
        DLog("updateModelWithNewTransaction txDict: %@", txDict.debugDescription)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let txObject = TLTxObject(dict:txDict)
            if self.pendingSelfStealthPaymentTxid != nil {
                // Special case where receiving stealth payment from same sending account. 
                // Let stealth websocket handle it
                // Need this cause, must generate private key and add address to account so that the bitcoins can be accounted for.
                if txObject.getHash() == self.pendingSelfStealthPaymentTxid {
                    self.pendingSelfStealthPaymentTxid = nil
                    return
                }
            }
            
            let addressesInTx = txObject.getAddresses()
            
            for (var i = 0; i < self.accounts!.getNumberOfAccounts();  i++) {
                let accountObject = self.accounts!.getAccountObjectForIdx(i)
                if !accountObject.hasFetchedAccountData() {
                    continue
                }
                for address in addressesInTx {
                    if (accountObject.isAddressPartOfAccount(address )) {
                        DLog("updateModelWithNewTransaction accounts %@", accountObject.getAccountID())
                        self.handleNewTxForAccount(accountObject, txObject: txObject)
                    }
                }
            }
            
            for (var i = 0; i < self.importedAccounts!.getNumberOfAccounts();  i++) {
                let accountObject = self.importedAccounts!.getAccountObjectForIdx(i)
                if !accountObject.hasFetchedAccountData() {
                    continue
                }
                for address in addressesInTx {
                    if (accountObject.isAddressPartOfAccount(address)) {
                        DLog("updateModelWithNewTransaction importedAccounts %@", accountObject.getAccountID())
                        self.handleNewTxForAccount(accountObject, txObject: txObject)
                    }
                }
            }
            
            for (var i = 0; i < self.importedWatchAccounts!.getNumberOfAccounts();  i++) {
                let accountObject = self.importedWatchAccounts!.getAccountObjectForIdx(i)
                if !accountObject.hasFetchedAccountData() {
                    continue
                }
                for address in addressesInTx {
                    if (accountObject.isAddressPartOfAccount(address)) {
                        DLog("updateModelWithNewTransaction importedWatchAccounts %@", accountObject.getAccountID())
                        self.handleNewTxForAccount(accountObject, txObject: txObject)
                    }
                }
            }
            
            for (var i = 0; i < self.importedAddresses!.getCount();  i++) {
                let importedAddress = self.importedAddresses!.getAddressObjectAtIdx(i)
                if !importedAddress.hasFetchedAccountData() {
                    continue
                }
                let address = importedAddress.getAddress()
                for addr in addressesInTx {
                    if (addr == address) {
                        DLog("updateModelWithNewTransaction importedAddresses %@", address)
                        self.handleNewTxForImportedAddress(importedAddress, txObject: txObject)
                    }
                }
            }
            
            for (var i = 0; i < self.importedWatchAddresses!.getCount();  i++) {
                let importedAddress = self.importedWatchAddresses!.getAddressObjectAtIdx(i)
                if !importedAddress.hasFetchedAccountData() {
                    continue
                }
                let address = importedAddress.getAddress()
                for addr in addressesInTx {
                    if (addr == address) {
                        DLog("updateModelWithNewTransaction importedWatchAddresses %@", address)
                        self.handleNewTxForImportedAddress(importedAddress, txObject: txObject)
                    }
                }
            }
        }
    }

    func handleNewTxForAccount(accountObject: TLAccountObject, txObject: TLTxObject) {
        let receivedAmount = accountObject.processNewTx(txObject)
        let receivedTo = accountObject.getAccountNameOrAccountPublicKey()
        //AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: true, success: {
            self.updateUIForNewTx(txObject.getHash() as! String, receivedAmount: receivedAmount, receivedTo: receivedTo)
        //})
    }
    
    func handleNewTxForImportedAddress(importedAddress: TLImportedAddress, txObject: TLTxObject) {
        var receivedAmount = importedAddress.processNewTx(txObject)
        let receivedTo = importedAddress.getLabel()
        //AppDelegate.instance().pendingOperations.addSetUpImportedAddressOperation(importedAddress, fetchDataAgain: true, success: {
            self.updateUIForNewTx(txObject.getHash() as! String, receivedAmount: receivedAmount, receivedTo: receivedTo)
        //})
    }
    
    func updateUIForNewTx(txHash: String, receivedAmount: TLCoin?, receivedTo: String) {
        dispatch_async(dispatch_get_main_queue()) {
            if self.listeningToToAddress != nil {
                NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_TO_ADDRESS_WEBSOCKET_NOTIFICATION(), object:nil, userInfo:nil)
                self.listeningToToAddress = nil
                if self.inputedToAddress != nil && self.inputedToAmount != nil {
                    self.showLocalNotificationForCoinsSent(txHash, address: self.inputedToAddress!, amount: self.inputedToAmount!)
                    self.inputedToAddress = nil
                    self.inputedToAmount = nil
                }
            }
            NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_UNCONFIRMED_TRANSACTION(), object:nil, userInfo:nil)
            if receivedAmount != nil {
                NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_RECEIVE_PAYMENT(), object:nil, userInfo:nil)
                self.promptReceivedPayment(receivedTo, receivedAmount: receivedAmount!)
            }
        }
    }
    
    func promptReceivedPayment(receivedTo:String, receivedAmount:TLCoin) {
        let msg = "\(receivedTo) received \(TLWalletUtils.getProperAmount(receivedAmount))"
        TLPrompts.promptSuccessMessage(msg, message: "")
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        if (TLPreferences.getEnableSoundNotification()) {
            AudioServicesPlaySystemSound(1016)
        }
    }
    
    func updateModelWithNewBlock(note: NSNotification) {
        let jsonData = note.object as! NSDictionary
        let blockHeight = jsonData.objectForKey("height") as! NSNumber
        DLog("updateModelWithNewBlock: %llu", blockHeight)
        TLBlockchainStatus.instance().blockHeight = blockHeight.unsignedLongLongValue
        
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_BLOCK(), object:nil, userInfo:nil)
        
    }
    
    func initializeWalletAppAndShowInitialScreen(recoverHDWalletIfNewlyInstalledApp:(Bool), walletPayload:(NSDictionary?)) {
        if (TLPreferences.getEnableBackupWithiCloud()) {
            TLCloudDocumentSyncWrapper.instance().checkCloudAvailability()
        }
        TLAnalytics.instance()
        
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"saveWalletPayloadDelay:",
            name:TLWallet.EVENT_WALLET_PAYLOAD_UPDATED(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateModelWithNewTransaction:",
            name:TLNotificationEvents.EVENT_NEW_UNCONFIRMED_TRANSACTION(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateModelWithNewBlock:",
            name:TLNotificationEvents.EVENT_NEW_BLOCK(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"listenToIncomingTransactionForGeneratedAddress:",
            name:TLNotificationEvents.EVENT_NEW_ADDRESS_GENERATED(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"setWalletTransactionListenerClosed",
            name:TLNotificationEvents.EVENT_TRANSACTION_LISTENER_CLOSE(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"listenToIncomingTransactionForWallet",
            name:TLNotificationEvents.EVENT_TRANSACTION_LISTENER_OPEN(), object:nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"setAccountsListeningToStealthPaymentsToFalse",
            name:TLNotificationEvents.EVENT_STEALTH_PAYMENT_LISTENER_CLOSE(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"respondToStealthChallegeNotification:",
            name:TLNotificationEvents.EVENT_RECEIVED_STEALTH_CHALLENGE(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"respondToStealthAddressSubscription:",
            name:TLNotificationEvents.EVENT_RECEIVED_STEALTH_ADDRESS_SUBSCRIPTION(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"respondToStealthPayment:",
            name:TLNotificationEvents.EVENT_RECEIVED_STEALTH_PAYMENT(), object:nil)
    
        var passphrase = TLWalletPassphrase.getDecryptedWalletPassphrase()

        if (!TLPreferences.hasSetupHDWallet()) {
            if (recoverHDWalletIfNewlyInstalledApp) {
                self.recoverHDWallet(passphrase!)
            } else {
                passphrase = TLHDWalletWrapper.generateMnemonicPassphrase()
                self.refreshApp(passphrase!)
                let accountObject = self.accounts!.createNewAccount("Account 1", accountType:.Normal, preloadStartingAddresses:true)
                accountObject.updateAccountNeedsRecovering(false)
                AppDelegate.instance().updateGodSend(TLSendFromType.HDWallet, sendFromIndex:0)
                AppDelegate.instance().updateReceiveSelectedObject(TLSendFromType.HDWallet, sendFromIndex:0)
                AppDelegate.instance().updateHistorySelectedObject(TLSendFromType.HDWallet, sendFromIndex:0)
            }
            self.justSetupHDWallet = true
            let encryptedWalletJson = TLWalletJson.getEncryptedWalletJsonContainer(self.appWallet.getWalletsJson()!,
                password:TLWalletJson.getDecryptedEncryptedWalletJSONPassphrase()!)
            let success = self.saveWalletJson(encryptedWalletJson, date:NSDate())
            if success {
                TLPreferences.setHasSetupHDWallet(true)
            } else {
                NSException(name: "Error".localized, reason: "Error saving wallet JSON file".localized, userInfo: nil).raise()
            }
        } else {
            let masterHex = TLHDWalletWrapper.getMasterHex(passphrase ?? "")

            if (walletPayload != nil) {
                self.appWallet.loadWalletPayload(walletPayload!, masterHex:masterHex)
            } else {
                TLPrompts.promptErrorMessage("Error".localized, message:"Error loading wallet JSON file".localized)
                NSException(name: "Error".localized, reason: "Error loading wallet JSON file".localized, userInfo: nil).raise()
            }
        }
        
        self.accounts = TLAccounts(appWallet: self.appWallet, accountsArray:self.appWallet.getAccountObjectArray(), accountType:.HDWallet)
        self.importedWatchAccounts = TLAccounts(appWallet: self.appWallet, accountsArray:self.appWallet.getWatchOnlyAccountArray(), accountType:.ImportedWatch)
        self.importedAccounts = TLAccounts(appWallet:self.appWallet, accountsArray:self.appWallet.getImportedAccountArray(), accountType:.Imported)
        self.importedAddresses = TLImportedAddresses(appWallet: self.appWallet, importedAddresses:self.appWallet.getImportedPrivateKeyArray(), accountAddressType:TLAccountAddressType.Imported)
        self.importedWatchAddresses = TLImportedAddresses(appWallet: self.appWallet, importedAddresses:self.appWallet.getWatchOnlyAddressArray(), accountAddressType:TLAccountAddressType.ImportedWatch)
        
        self.isAccountsAndImportsLoaded = true
        
        self.godSend = TLSpaghettiGodSend()
        self.receiveSelectedObject = TLSelectedObject()
        self.historySelectedObject = TLSelectedObject()
        self.updateGodSend()
        let selectObjected: AnyObject? = self.godSend?.getSelectedSendObject()
        if (selectObjected is TLAccountObject) {
            self.receiveSelectedObject!.setSelectedAccount(selectObjected as! TLAccountObject)
            self.historySelectedObject!.setSelectedAccount(selectObjected as! TLAccountObject)
        } else if (selectObjected is TLImportedAddress) {
            self.receiveSelectedObject!.setSelectedAddress(selectObjected as! TLImportedAddress)
            self.historySelectedObject!.setSelectedAddress(selectObjected as! TLImportedAddress)
        }
        assert(self.accounts!.getNumberOfAccounts() > 0, "")
        
        TLBlockExplorerAPI.instance()
        TLExchangeRate.instance()
        TLAchievements.instance()
        
        let blockExplorerURL = TLPreferences.getBlockExplorerURL(TLPreferences.getBlockExplorerAPI())!
        let baseURL = NSURL(string:blockExplorerURL)
        TLNetworking.isReachable(baseURL!, reachable:{(reachable: TLDOMAINREACHABLE) in
            if (reachable == TLDOMAINREACHABLE.NOTREACHABLE) {
                TLPrompts.promptErrorMessage("Network Error".localized,
                    message:String(format:"%@ servers not reachable.".localized, blockExplorerURL))
            }
        })
        
        TLBlockExplorerAPI.instance().getBlockHeight({(jsonData:AnyObject!) in
            let blockHeight = (jsonData.objectForKey("height") as! NSNumber).unsignedLongLongValue
            DLog("setBlockHeight: %llu", (jsonData.objectForKey("height") as! NSNumber))
            TLBlockchainStatus.instance().blockHeight = blockHeight
            }, failure:{(code:NSInteger, status:String!) in
                DLog("Error getting block height.")
                TLPrompts.promptErrorMessage("Network Error".localized,
                    message:String(format:"Error getting block height.".localized))
        })
    }
    
    func refreshHDWalletAccounts(isRestoringWallet: Bool) {
        let group = dispatch_group_create()
        for (var i = 0; i < self.accounts!.getNumberOfAccounts();  i++) {
            let accountObject = self.accounts!.getAccountObjectForIdx(i)
            dispatch_group_enter(group)
            
            // if account needs recovering dont fetch account data
            if (accountObject.needsRecovering()) {
                return
            }
            
            var activeAddresses = accountObject.getActiveMainAddresses()! as! [String]
            activeAddresses += accountObject.getActiveChangeAddresses()! as! [String]
            
            if accountObject.stealthWallet != nil {
                activeAddresses += accountObject.stealthWallet!.getPaymentAddresses()
            }
            
            if accountObject.stealthWallet != nil {
                dispatch_group_enter(group)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    accountObject.fetchNewStealthPayments(isRestoringWallet)
                    dispatch_group_leave(group)
                }
            }
            
            accountObject.getAccountData(activeAddresses, shouldResetAccountBalance: true, success: {
                () in
                dispatch_group_leave(group)
                
                }, failure: {
                    () in
                    dispatch_group_leave(group)
            })
        }
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
    }
    
    func showLocalNotificationForCoinsSent(txHash: String, address: String, amount: TLCoin) {
        if sentPaymentHashes[txHash] == nil {
            sentPaymentHashes[txHash] = ""
            let msg = String(format:"Sent %@ to %@".localized, TLWalletUtils.getProperAmount(amount), address)
            TLPrompts.promptSuccessMessage(msg, message: "")
            //self.showLocalNotification(msg)
        }
        
    }
    
    private func setUpLocalNotification() {
        if (TLUtils.getiOSVersion() >= 8) {
            let types = UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert
            let mySettings =
            UIUserNotificationSettings(forTypes: types, categories:nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
        }
    }
    
    func application(applcation: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        DLog("didReceiveLocalNotification: %@", notification.alertBody!)
        let av = UIAlertView(title:notification.alertBody!,
            message:""                                       ,
            delegate:nil                                       ,
            cancelButtonTitle:nil                               ,
            otherButtonTitles:"OK".localized)
        
        av.show()
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
    }
    
    private func showLocalNotification(message: String) {
        DLog("showLocalNotification: %@", message)
        let localNotification = UILocalNotification()
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.fireDate = NSDate(timeIntervalSinceNow:1)
        localNotification.alertBody = message
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        if (TLPreferences.getEnableSoundNotification()) {
            AudioServicesPlaySystemSound(1016)
        }
    }
    
    private func isCameraAllowed() -> Bool {
        return AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) != AVAuthorizationStatus.Denied
    }
    
    private func promptAppNotAllowedCamera() {
        let displayName = TLUtils.defaultAppName()
        
        let av = UIAlertView(title: String(format:"%@ is not allowed to access the camera".localized, displayName),
            message: String(format:"\nallow camera access in\n Settings->Privacy->Camera->%@".localized, displayName),
            delegate:nil      ,
            cancelButtonTitle:"OK".localized)
        
        av.show()
    }
    
    
    func showPrivateKeyReaderController(viewController: UIViewController, success: TLWalletUtils.SuccessWithDictionary, error: TLWalletUtils.ErrorWithString) {
        if (!isCameraAllowed()) {
            self.promptAppNotAllowedCamera()
            return
        }
        
        let reader = TLQRCodeScannerViewController(success:{(data: String?) in
            if (TLCoreBitcoinWrapper.isBIP38EncryptedKey(data!)) {
                self.scannedEncryptedPrivateKey = data!
            }
                
            else {
                success(["privateKey":data!])
            }
            
            }, error:{(e: String?) in
                error(e)
        })
        
        viewController.presentViewController(reader, animated:true, completion:nil)
    }
    
    func showAddressReaderControllerFromViewController(viewController: (UIViewController), success: (TLWalletUtils.SuccessWithString), error: (TLWalletUtils.ErrorWithString)) {
        if (!isCameraAllowed()) {
            promptAppNotAllowedCamera()
            return
        }
        
        let reader = TLQRCodeScannerViewController(success:{(data: String?) in
            success(data)
            }, error:{(e: String?) in
                error(e)
        })
        
        viewController.presentViewController(reader, animated:true, completion:nil)
    }
    
    func showExtendedPrivateKeyReaderController(viewController: (UIViewController), success: (TLWalletUtils.SuccessWithString), error: (TLWalletUtils.ErrorWithString)) {
        if (!isCameraAllowed()) {
            promptAppNotAllowedCamera()
            return
        }
        
        let reader = TLQRCodeScannerViewController(success:{(data: String?) in
            success(data)
            }, error:{(e: String?) in
                error(e)
        })
        
        viewController.presentViewController(reader, animated:true, completion:nil)
    }
    
    func showExtendedPublicKeyReaderController(viewController: (UIViewController), success: (TLWalletUtils.SuccessWithString), error: (TLWalletUtils.ErrorWithString)) {
        if (!isCameraAllowed()) {
            promptAppNotAllowedCamera()
            return
        }
        
        let reader = TLQRCodeScannerViewController(success:{(data: String?) in
            success(data)
            }, error:{(e: String?) in
                error(e)
        })
        
        viewController.presentViewController(reader, animated:true, completion:nil)
    }
    
    func listenToIncomingTransactionForWallet() {
        if (!self.isAccountsAndImportsLoaded || !TLTransactionListener.instance().isWebSocketOpen()) {
            return
        }
        
        for (var i = 0; i < self.accounts!.getNumberOfAccounts();  i++) {
            let accountObject = self.accounts!.getAccountObjectForIdx(i)
            if accountObject.downloadState != .Downloaded {
                continue
            }
            let activeMainAddresses = accountObject.getActiveMainAddresses()
            for address in activeMainAddresses! {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
            }
            let activeChangeAddresses = accountObject.getActiveChangeAddresses()
            for address in activeChangeAddresses! {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
            }
            
            if accountObject.stealthWallet != nil {
                let stealthPaymentAddresses = accountObject.stealthWallet!.getUnspentPaymentAddresses()
                for address in stealthPaymentAddresses {
                    TLTransactionListener.instance().listenToIncomingTransactionForAddress(address)
                }
            }
            accountObject.listeningToIncomingTransactions = true
        }
        
        for (var i = 0; i < self.importedAccounts!.getNumberOfAccounts();  i++) {
            let accountObject = self.importedAccounts!.getAccountObjectForIdx(i)
            if accountObject.downloadState != .Downloaded {
                continue
            }
            let activeMainAddresses = accountObject.getActiveMainAddresses()
            for address in activeMainAddresses! {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
            }
            let activeChangeAddresses = accountObject.getActiveChangeAddresses()
            for address in activeChangeAddresses! {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
            }
            
            if accountObject.stealthWallet != nil {
                let stealthPaymentAddresses = accountObject.stealthWallet!.getUnspentPaymentAddresses()
                for address in stealthPaymentAddresses {
                    TLTransactionListener.instance().listenToIncomingTransactionForAddress(address)
                }
            }
            accountObject.listeningToIncomingTransactions = true
        }
        
        for (var i = 0; i < self.importedWatchAccounts!.getNumberOfAccounts();  i++) {
            let accountObject = self.importedWatchAccounts!.getAccountObjectForIdx(i)
            if accountObject.downloadState != .Downloaded {
                continue
            }
            let activeMainAddresses = accountObject.getActiveMainAddresses()
            for address in activeMainAddresses! {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
            }
            let activeChangeAddresses = accountObject.getActiveChangeAddresses()
            for address in activeChangeAddresses! {
                TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
            }
            accountObject.listeningToIncomingTransactions = true
        }
        
        
        for (var i = 0; i < self.importedAddresses!.getCount();  i++) {
            let importedAddress = self.importedAddresses!.getAddressObjectAtIdx(i)
            if importedAddress.downloadState != .Downloaded {
                continue
            }
            let address = importedAddress.getAddress()
            TLTransactionListener.instance().listenToIncomingTransactionForAddress(address)
            importedAddress.listeningToIncomingTransactions = true
        }
        
        for (var i = 0; i < self.importedWatchAddresses!.getCount();  i++) {
            let importedAddress = self.importedWatchAddresses!.getAddressObjectAtIdx(i)
            if importedAddress.downloadState != .Downloaded {
                continue
            }
            let address = importedAddress.getAddress()
            TLTransactionListener.instance().listenToIncomingTransactionForAddress(address)
            importedAddress.listeningToIncomingTransactions = true
        }
        
    }
    
    func application(application: (UIApplication), openURL url: (NSURL), sourceApplication: (String)?, annotation:(AnyObject)?) -> Bool {
        self.bitcoinURIOptionsDict = TLWalletUtils.parseBitcoinURI(url.absoluteString!)        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
    }
    
    func applicationWillTerminate(application: UIApplication) {
        if (TLPreferences.getEnableBackupWithiCloud()) {
            // when terminating app must save immediately, don't wait to save to iCloud
            let encryptedWalletJson = TLWalletJson.getEncryptedWalletJsonContainer(self.appWallet.getWalletsJson()!,
                password:TLWalletJson.getDecryptedEncryptedWalletJSONPassphrase()!)
            self.saveWalletJson(encryptedWalletJson, date:NSDate())
        }
        self.saveWalletJsonCloud()
    }
    
    func saveWalletPayloadDelay(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            if self.saveWalletJSONEnabled == false {
                return
            }
            NSObject.cancelPreviousPerformRequestsWithTarget(self, selector:"saveWalletJsonCloudBackground", object:nil)
            NSTimer.scheduledTimerWithTimeInterval(self.SAVE_WALLET_PAYLOAD_DELAY, target: self,
                selector: Selector("saveWalletJsonCloudBackground"), userInfo: nil, repeats: false)
        }
    }
    
    func saveWalletJsonCloudBackground() {
        DLog("saveWalletJsonCloudBackground starting...")
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        dispatch_async(queue) {
            self.saveWalletJsonCloud()
        }
    }
    
    func printOutWalletJSON() {
        DLog("printOutWalletJSON:\n\(self.appWallet.getWalletsJson()!)")
    }
    
    func saveWalletJsonCloud() -> Bool {
        if saveWalletJSONEnabled == false {
            DLog("saveWalletJSONEnabled disabled")
            return false
        }
        DLog("saveFileToCloud starting...")
        
        let encryptedWalletJson = TLWalletJson.getEncryptedWalletJsonContainer(self.appWallet.getWalletsJson()!,
            password:TLWalletJson.getDecryptedEncryptedWalletJSONPassphrase()!)
        if (TLPreferences.getEnableBackupWithiCloud()) {
            if (TLCloudDocumentSyncWrapper.instance().checkCloudAvailability()) {
                TLCloudDocumentSyncWrapper.instance().saveFileToCloud(TLPreferences.getCloudBackupWalletFileName()!, content:encryptedWalletJson,
                    completion:{(cloudDocument: UIDocument!,documentData: NSData!, error: NSError?) in
                        if error == nil {
                            self.saveWalletJson(encryptedWalletJson, date:cloudDocument.fileModificationDate!)
                            DLog("saveFileToCloud done")
                        } else {
                            DLog("saveFileToCloud error %@", error!.description)
                        }
                })
            } else {
                self.saveWalletJson(encryptedWalletJson, date:NSDate())
                DLog("saveFileToCloud ! checkCloudAvailability save local done")
            }
        } else {
            self.saveWalletJson(encryptedWalletJson, date:NSDate())
            DLog("saveFileToCloud local done")
        }
        return true
    }
    
    private func saveWalletJson(encryptedWalletJson: (NSString), date: (NSDate)) -> Bool {
        let success = TLWalletJson.saveWalletJson(encryptedWalletJson as String, date:date)
        
        if (!success) {
            dispatch_async(dispatch_get_main_queue()) {
                TLPrompts.promptErrorMessage("Error".localized, message:"Local back up to wallet failed!".localized)
            }
        }
        
        return success
    }
    
    func getLocalWalletJsonDict() -> NSDictionary? {
        return TLWalletJson.getWalletJsonDict(TLWalletJson.getLocalWalletJSONFile(),
            password:TLWalletJson.getDecryptedEncryptedWalletJSONPassphrase())
    }
    
    private func menuShownHideStatusBar() {
        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    private func menuHiddenShowStatusBar() {
        UIApplication.sharedApplication().statusBarHidden = false
    }
    
    
    func passcodeViewControllerWillClose() {
        UIApplication.sharedApplication().statusBarHidden = false
    }
    
    func maxNumberOfFailedAttemptsReached() {
    }
    
    func passcodeWasEnteredSuccessfully() {
        UIApplication.sharedApplication().statusBarHidden = false
    }
    
    func logoutButtonWasPressed() {
        UIApplication.sharedApplication().statusBarHidden = false
    }
}