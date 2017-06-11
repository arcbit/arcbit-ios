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
import Fabric
import Crashlytics

@UIApplicationMain
@objc(AppDelegate) class AppDelegate: UIResponder, UIApplicationDelegate, LTHPasscodeViewControllerDelegate {
    
    let MAX_CONSECUTIVE_FAILED_STEALTH_CHALLENGE_COUNT = 8
    let SAVE_WALLET_PAYLOAD_DELAY = 2.0
    let DEFAULT_BLOCKEXPLORER_API = TLBlockExplorer.blockchain
    let RESPOND_TO_STEALTH_PAYMENT_GET_TX_TRIES_MAX_TRIES = 3

    var window:UIWindow?
    fileprivate var storyboard:UIStoryboard?
    fileprivate var modalDelegate:AnyObject?
    var appWallet = TLWallet(walletName: "App Wallet", walletConfig: TLWalletConfig(isTestnet: false))
    var accounts:TLAccounts?
    var coldWalletAccounts:TLAccounts?
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
    fileprivate var isAccountsAndImportsLoaded = false
    var saveWalletJSONEnabled = true
    var consecutiveFailedStealthChallengeCount = 0
    fileprivate var savedPasscodeViewDefaultBackgroundColor: UIColor?
    fileprivate var savedPasscodeViewDefaultLabelTextColor: UIColor?
    fileprivate var savedPasscodeViewDefaultPasscodeTextColor: UIColor?
    fileprivate var hasFinishLaunching = false
    fileprivate var respondToStealthPaymentGetTxTries = 0
    var scannedEncryptedPrivateKey:String? = nil
    var scannedAddressBookAddress:String? = nil
    let pendingOperations = PendingOperations()
    lazy var webSocketNotifiedTxHashSet:NSMutableSet = NSMutableSet()
    var pendingSelfStealthPaymentTxid: String? = nil
    lazy var txFeeAPI = TLTxFeeAPI();

    class func instance() -> AppDelegate {
        return UIApplication.shared.delegate as! (AppDelegate)
    }
    
    func aAccountNeedsRecovering() -> Bool {
        for i in stride(from: 0, to: AppDelegate.instance().accounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                return true
            }
        }
        
        for i in stride(from: 0, to: AppDelegate.instance().coldWalletAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = AppDelegate.instance().coldWalletAccounts!.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                return true
            }
        }
        
        for i in stride(from: 0, to: AppDelegate.instance().importedAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = AppDelegate.instance().importedAccounts!.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                return true
            }
        }
        
        for i in stride(from: 0, to: AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = AppDelegate.instance().importedWatchAccounts!.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                return true
            }
        }
        return false
    }
    
    func checkToRecoverAccounts() {
        for i in stride(from: 0, to: AppDelegate.instance().accounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                accountObject.clearAllAddresses()
                accountObject.recoverAccount(false, recoverStealthPayments: true)
            }
        }
        
        for i in stride(from: 0, to: AppDelegate.instance().coldWalletAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = AppDelegate.instance().coldWalletAccounts!.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                accountObject.clearAllAddresses()
                accountObject.recoverAccount(false, recoverStealthPayments: true)
            }
        }
        
        for i in stride(from: 0, to: AppDelegate.instance().importedAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = AppDelegate.instance().importedAccounts!.getAccountObjectForIdx(i)
            if (accountObject.needsRecovering()) {
                accountObject.clearAllAddresses()
                accountObject.recoverAccount(false, recoverStealthPayments: true)
            }
        }
        
        for i in stride(from: 0, to: AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts(), by: 1) {
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
        
        if (sendFromType == .hdWallet) {
            if (sendFromIndex > self.accounts!.getNumberOfAccounts() - 1 ) {
                sendFromType = TLSendFromType.hdWallet
                sendFromIndex = 0
            }
        } else if (sendFromType == .coldWalletAccount) {
            if (sendFromIndex > self.coldWalletAccounts!.getNumberOfAccounts() - 1) {
                sendFromType = TLSendFromType.hdWallet
                sendFromIndex = 0
            }
        } else if (sendFromType == .importedAccount) {
            if (sendFromIndex > self.importedAccounts!.getNumberOfAccounts() - 1) {
                sendFromType = TLSendFromType.hdWallet
                sendFromIndex = 0
            }
        } else if (sendFromType == .importedWatchAccount) {
            if (sendFromIndex > self.importedWatchAccounts!.getNumberOfAccounts() - 1) {
                sendFromType = TLSendFromType.hdWallet
                sendFromIndex = 0
            }
        } else if (sendFromType == .importedAddress) {
            if (sendFromIndex > self.importedAddresses!.getCount() - 1 ) {
                sendFromType = TLSendFromType.hdWallet
                sendFromIndex = 0
            }
        } else if (sendFromType == .importedWatchAddress) {
            if (sendFromIndex > self.importedWatchAddresses!.getCount() - 1) {
                sendFromType = TLSendFromType.hdWallet
                sendFromIndex = 0
            }
        }
        
        self.updateGodSend(sendFromType, sendFromIndex:sendFromIndex)
    }
    
    func updateGodSend(_ sendFromType: TLSendFromType, sendFromIndex: Int) {
        TLPreferences.setSendFromType(sendFromType)
        TLPreferences.setSendFromIndex(UInt(sendFromIndex))
        
        if (sendFromType == .hdWallet) {
            let accountObject = self.accounts!.getAccountObjectForIdx(sendFromIndex)
            self.godSend?.setOnlyFromAccount(accountObject)
        } else if (sendFromType == .coldWalletAccount) {
            let accountObject = self.coldWalletAccounts!.getAccountObjectForIdx(sendFromIndex)
            self.godSend?.setOnlyFromAccount(accountObject)
        } else if (sendFromType == .importedAccount) {
            let accountObject = self.importedAccounts!.getAccountObjectForIdx(sendFromIndex)
            self.godSend?.setOnlyFromAccount(accountObject)
        } else if (sendFromType == .importedWatchAccount) {
            let accountObject = self.importedWatchAccounts!.getAccountObjectForIdx(sendFromIndex)
            self.godSend?.setOnlyFromAccount(accountObject)
        } else if (sendFromType == .importedAddress) {
            let importedAddress = self.importedAddresses!.getAddressObjectAtIdx(sendFromIndex)
            self.godSend?.setOnlyFromAddress(importedAddress)
        } else if (sendFromType == .importedWatchAddress) {
            let importedAddress = self.importedWatchAddresses!.getAddressObjectAtIdx(sendFromIndex)
            self.godSend?.setOnlyFromAddress(importedAddress)
        }
    }
    
    func updateReceiveSelectedObject(_ sendFromType: TLSendFromType, sendFromIndex: Int) {
        if (sendFromType == .hdWallet) {
            let accountObject = self.accounts!.getAccountObjectForIdx(sendFromIndex)
            self.receiveSelectedObject!.setSelectedAccount(accountObject)
        } else if (sendFromType == .coldWalletAccount) {
            let accountObject = self.coldWalletAccounts!.getAccountObjectForIdx(sendFromIndex)
            self.receiveSelectedObject!.setSelectedAccount(accountObject)
        } else if (sendFromType == .importedAccount) {
            let accountObject = self.importedAccounts!.getAccountObjectForIdx(sendFromIndex)
            self.receiveSelectedObject!.setSelectedAccount(accountObject)
        } else if (sendFromType == .importedWatchAccount) {
            let accountObject = self.importedWatchAccounts!.getAccountObjectForIdx(sendFromIndex)
            self.receiveSelectedObject!.setSelectedAccount(accountObject)
        } else if (sendFromType == .importedAddress) {
            let importedAddress = self.importedAddresses!.getAddressObjectAtIdx(sendFromIndex)
            self.receiveSelectedObject!.setSelectedAddress(importedAddress)
        } else if (sendFromType == .importedWatchAddress) {
            let importedAddress = self.importedWatchAddresses!.getAddressObjectAtIdx(sendFromIndex)
            self.receiveSelectedObject!.setSelectedAddress(importedAddress)
        }
    }
    
    func updateHistorySelectedObject(_ sendFromType: TLSendFromType, sendFromIndex: Int) {
        if (sendFromType == .hdWallet) {
            let accountObject = self.accounts!.getAccountObjectForIdx(sendFromIndex)
            self.historySelectedObject!.setSelectedAccount(accountObject)
        } else if (sendFromType == .coldWalletAccount) {
            let accountObject = self.coldWalletAccounts!.getAccountObjectForIdx(sendFromIndex)
            self.historySelectedObject!.setSelectedAccount(accountObject)
        } else if (sendFromType == .importedAccount) {
            let accountObject = self.importedAccounts!.getAccountObjectForIdx(sendFromIndex)
            self.historySelectedObject!.setSelectedAccount(accountObject)
        } else if (sendFromType == .importedWatchAccount) {
            let accountObject = self.importedWatchAccounts!.getAccountObjectForIdx(sendFromIndex)
            self.historySelectedObject!.setSelectedAccount(accountObject)
        } else if (sendFromType == .importedAddress) {
            let importedAddress = self.importedAddresses!.getAddressObjectAtIdx(sendFromIndex)
            self.historySelectedObject!.setSelectedAddress(importedAddress)
        } else if (sendFromType == .importedWatchAddress) {
            let importedAddress = self.importedWatchAddresses!.getAddressObjectAtIdx(sendFromIndex)
            self.historySelectedObject!.setSelectedAddress(importedAddress)
        }
    }
    
    
    func showLockViewForEnteringPasscode(_ notification: Notification) {
        if (!hasFinishLaunching && LTHPasscodeViewController.doesPasscodeExist()) {
            //LTHPasscodeViewController.sharedUser().maxNumberOfAllowedFailedAttempts = 0
            UIApplication.shared.isStatusBarHidden = true
            LTHPasscodeViewController.sharedUser().delegate = self
            LTHPasscodeViewController.sharedUser().showLockScreen(withAnimation: false,
                withLogout:false                                                         ,
                andLogoutTitle:nil)
        }
        
        hasFinishLaunching = true
    }
    
    func recoverHDWallet(_ mnemonic: String, shouldRefreshApp: Bool = true) {
        if shouldRefreshApp {
            refreshApp(mnemonic)
        } else {
            let masterHex = TLHDWalletWrapper.getMasterHex(mnemonic)
            appWallet.createInitialWalletPayload(mnemonic, masterHex:masterHex)
            
            accounts = TLAccounts(appWallet: appWallet, accountsArray:appWallet.getAccountObjectArray(), accountType:.hdWallet)
            coldWalletAccounts = TLAccounts(appWallet: appWallet, accountsArray:appWallet.getColdWalletAccountArray(), accountType:.coldWallet)
            importedAccounts = TLAccounts(appWallet: appWallet, accountsArray:appWallet.getImportedAccountArray(), accountType:.imported)
            importedWatchAccounts = TLAccounts(appWallet: appWallet, accountsArray: appWallet.getWatchOnlyAccountArray(), accountType:.importedWatch)
            importedAddresses = TLImportedAddresses(appWallet: appWallet, importedAddresses: appWallet.getImportedPrivateKeyArray(), accountAddressType:.imported)
            importedWatchAddresses = TLImportedAddresses(appWallet: appWallet, importedAddresses: appWallet.getWatchOnlyAddressArray(), accountAddressType:.importedWatch)
        }
        
        var accountIdx = 0
        var consecutiveUnusedAccountCount = 0
        let MAX_CONSECUTIVE_UNUSED_ACCOUNT_LOOK_AHEAD_COUNT = 4
        
        while (true) {
            let accountName = String(format:TLDisplayStrings.ACCOUNT_X_STRING(), (accountIdx + 1))
            let accountObject = accounts!.createNewAccount(accountName, accountType:.normal, preloadStartingAddresses:false)
            
            DLog("recoverHDWalletaccountName \(accountName)")
            
            let sumMainAndChangeAddressMaxIdx = accountObject.recoverAccount(false)
            DLog(String(format: "accountName \(accountName) sumMainAndChangeAddressMaxIdx: \(sumMainAndChangeAddressMaxIdx)"))
            if sumMainAndChangeAddressMaxIdx > -2 || accountObject.stealthWallet!.checkIfHaveStealthPayments() {
                consecutiveUnusedAccountCount = 0
            } else {
                consecutiveUnusedAccountCount += 1
                if (consecutiveUnusedAccountCount == MAX_CONSECUTIVE_UNUSED_ACCOUNT_LOOK_AHEAD_COUNT) {
                    break
                }
            }
            
            accountIdx += 1
        }
        
        DLog("recoverHDWallet getNumberOfAccounts: \(self.accounts!.getNumberOfAccounts())")
        if (self.accounts!.getNumberOfAccounts() == 0) {
            self.accounts!.createNewAccount(TLDisplayStrings.ACCOUNT_1_STRING(), accountType:.normal)
        } else if (self.accounts!.getNumberOfAccounts() > 1) {
            while (self.accounts!.getNumberOfAccounts() > 1 && consecutiveUnusedAccountCount > 0) {
                self.accounts!.popTopAccount()
                consecutiveUnusedAccountCount -= 1
            }
        }
    }
    
    // work around to show SendView
    func checkToShowSendViewWithURL(_ notification: Notification) {
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
        LTHPasscodeViewController.sharedUser().okButton.setTitleColor(savedPasscodeViewDefaultLabelTextColor, for:UIControlState())
        
        LTHPasscodeViewController.sharedUser().firstDigitTextField.textColor = savedPasscodeViewDefaultPasscodeTextColor
        LTHPasscodeViewController.sharedUser().secondDigitTextField.textColor = savedPasscodeViewDefaultPasscodeTextColor
        LTHPasscodeViewController.sharedUser().thirdDigitTextField.textColor = savedPasscodeViewDefaultPasscodeTextColor
        LTHPasscodeViewController.sharedUser().fourthDigitTextField.textColor = savedPasscodeViewDefaultPasscodeTextColor
    }
    
    fileprivate func setupPasscodeViewColors() {
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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        AFNetworkActivityIndicatorManager.shared().isEnabled = true

        self.window!.backgroundColor = TLColors.mainAppColor()
        application.statusBarStyle = UIStatusBarStyle.lightContent
        
        self.justSetupHDWallet = false
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        if (TLPreferences.getInstallDate() == nil) {
            
            // before version 1.4.0, install date was not getting set properly, this fixes things
            if TLPreferences.getAppVersion() == "0" {
                TLPreferences.setHasSetupHDWallet(false)
                TLPreferences.setInstallDate()
                DLog("set InstallDate \(TLPreferences.getInstallDate())")
                TLPreferences.setAppVersion(appVersion)
            } else {
                TLPreferences.setInstallDate()
                DLog("set fake InstallDate \(TLPreferences.getInstallDate())")
                if appVersion != TLPreferences.getAppVersion() {
                    TLUpdateAppData.instance().beforeUpdatedAppVersion = TLPreferences.getAppVersion()
                    DLog("set new appVersion \(appVersion)")
                    TLPreferences.setAppVersion(appVersion)
                    TLPreferences.setDisabledPromptRateApp(false)
                }
            }
            
        } else if appVersion != TLPreferences.getAppVersion() {
            TLUpdateAppData.instance().beforeUpdatedAppVersion = TLPreferences.getAppVersion()
            DLog("set new appVersion \(appVersion)")
            TLPreferences.setAppVersion(appVersion)
            TLPreferences.setDisabledPromptRateApp(false)
        }
        
        self.setupPasscodeViewColors()
        
        self.isAccountsAndImportsLoaded = false
        
        if (TLPreferences.hasSetupHDWallet() && UIApplication.instancesRespond(to: "registerUserNotificationSettings"))
        {
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories:nil))
        }
        
        NotificationCenter.default.addObserver(self, selector:#selector(AppDelegate.checkToShowSendViewWithURL(_:)), name:NSNotification.Name.UIApplicationDidBecomeActive, object:nil)
        
        // condition is used so that I dont prompt user to setup notifactions when just installed app
        if (TLPreferences.hasSetupHDWallet()) {
            //setUpLocalNotification()
        }
        
        hasFinishLaunching = false
        
        NotificationCenter.default.addObserver(self, selector:#selector(AppDelegate.showLockViewForEnteringPasscode(_:)), name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_SEND_SCREEN_LOADING()), object:nil)
        
        return true
    }
    
    func refreshApp(_ passphrase: String, clearWalletInMemory: Bool = true) {
        if (TLPreferences.getCloudBackupWalletFileName() == nil) {
            TLPreferences.setCloudBackupWalletFileName()
        }

        TLPreferences.deleteWalletPassphrase()
        TLPreferences.deleteEncryptedWalletJSONPassphrase()
        
        TLPreferences.setWalletPassphrase(passphrase, useKeychain: true)
        TLPreferences.setEncryptedWalletJSONPassphrase(passphrase, useKeychain: true)
        TLPreferences.clearEncryptedWalletPassphraseKey()

        TLPreferences.setCanRestoreDeletedApp(true)
        TLPreferences.setInAppSettingsCanRestoreDeletedApp(true)
        
        TLPreferences.setEnableBackupWithiCloud(false)
        TLPreferences.setInAppSettingsKitEnableBackupWithiCloud(false)
        
        TLPreferences.setInAppSettingsKitEnabledDynamicFee(false)
        TLPreferences.setInAppSettingsKitDynamicFeeSettingIdx(TLDynamicFeeSetting.FastestFee);
        TLPreferences.setInAppSettingsKitTransactionFee(TLWalletUtils.DEFAULT_FEE_AMOUNT_IN_BITCOINS())
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
        
        TLPreferences.setSendFromType(.hdWallet)
        TLPreferences.setSendFromIndex(0)
        
        if clearWalletInMemory {
            let masterHex = TLHDWalletWrapper.getMasterHex(passphrase)
            self.appWallet.createInitialWalletPayload(passphrase, masterHex:masterHex)
            
            self.accounts = TLAccounts(appWallet: self.appWallet, accountsArray:self.appWallet.getAccountObjectArray(), accountType:.hdWallet)
            self.coldWalletAccounts = TLAccounts(appWallet: self.appWallet, accountsArray:self.appWallet.getColdWalletAccountArray(), accountType:.coldWallet)
            self.importedAccounts = TLAccounts(appWallet:self.appWallet, accountsArray:self.appWallet.getImportedAccountArray(), accountType:.imported)
            self.importedWatchAccounts = TLAccounts(appWallet: self.appWallet, accountsArray:self.appWallet.getWatchOnlyAccountArray(), accountType:.importedWatch)
            self.importedAddresses = TLImportedAddresses(appWallet: self.appWallet, importedAddresses:self.appWallet.getImportedPrivateKeyArray(), accountAddressType:.imported)
            self.importedWatchAddresses = TLImportedAddresses(appWallet: self.appWallet, importedAddresses:self.appWallet.getWatchOnlyAddressArray(), accountAddressType:.importedWatch)
        }
        
        self.receiveSelectedObject = TLSelectedObject()
        self.historySelectedObject = TLSelectedObject()
        
        //self.appWallet.addAddressBookEntry("vJmwhHhMNevDQh188gSeHd2xxxYGBQmnVuMY2yG2MmVTC31UWN5s3vaM3xsM2Q1bUremdK1W7eNVgPg1BnvbTyQuDtMKAYJanahvse", label: "ArcBit Donation")
    }
    
    func setAccountsListeningToStealthPaymentsToFalse() {
        guard let accounts = accounts else { return }
        for i in stride(from: 0, to: accounts.getNumberOfAccounts(), by: 1) {
            let accountObject = accounts.getAccountObjectForIdx(i)
            if accountObject.stealthWallet != nil {
                accountObject.stealthWallet?.isListeningToStealthPayment = false
            }
        }
        
        for i in stride(from: 0, to: self.importedAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = self.importedAccounts!.getAccountObjectForIdx(i)
            if accountObject.stealthWallet != nil {
                accountObject.stealthWallet?.isListeningToStealthPayment = false
            }
        }
    }
    
    func respondToStealthChallegeNotification(_ note: Notification) {
        let responseDict = note.object as! NSDictionary
        let challenge = responseDict.object(forKey: "challenge") as! String
        let lock = NSLock()
        lock.lock()
        TLStealthWebSocket.instance().challenge = challenge
        lock.unlock()
        self.respondToStealthChallege(challenge)
    }
    
    func respondToStealthChallege(_ challenge: String) {
        if (!self.isAccountsAndImportsLoaded || !TLStealthWebSocket.instance().isWebSocketOpen()) {
            return
        }
        guard let accounts = accounts else { return }
        for i in stride(from: 0, to: accounts.getNumberOfAccounts(), by: 1) {
            let accountObject = self.accounts!.getAccountObjectForIdx(i)
            if accountObject.hasFetchedAccountData() &&
                accountObject.stealthWallet != nil && accountObject.stealthWallet?.isListeningToStealthPayment == false {
                if let addrAndSignature = accountObject.stealthWallet?.getStealthAddressAndSignatureFromChallenge(challenge){
                    TLStealthWebSocket.instance().sendMessageSubscribeToStealthAddress(addrAndSignature.0, signature: addrAndSignature.1)
                }
            }
        }
        guard let importedAccounts = importedAccounts else { return }
        for i in stride(from: 0, to: importedAccounts.getNumberOfAccounts(), by: 1) {
            let accountObject = importedAccounts.getAccountObjectForIdx(i)
            if let stealthWallet = accountObject.stealthWallet, accountObject.hasFetchedAccountData() &&
                stealthWallet.isListeningToStealthPayment == false {
                    let addrAndSignature = stealthWallet.getStealthAddressAndSignatureFromChallenge(challenge)
                    TLStealthWebSocket.instance().sendMessageSubscribeToStealthAddress(addrAndSignature.0, signature: addrAndSignature.1)
            }
        }
    }
    
    func respondToStealthAddressSubscription(_ note: Notification) {
        let responseDict = note.object as! NSDictionary
        let stealthAddress = responseDict.object(forKey: "addr") as! String
        let subscriptionSuccess = responseDict.object(forKey: "success") as! String
        if subscriptionSuccess == "False" && consecutiveFailedStealthChallengeCount < MAX_CONSECUTIVE_FAILED_STEALTH_CHALLENGE_COUNT {
            consecutiveFailedStealthChallengeCount += 1
            TLStealthWebSocket.instance().sendMessageGetChallenge()
            return
        }
        consecutiveFailedStealthChallengeCount = 0
        
        for i in stride(from: 0, to: self.accounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = self.accounts!.getAccountObjectForIdx(i)
            if accountObject.stealthWallet!.getStealthAddress() == stealthAddress {
                accountObject.stealthWallet!.isListeningToStealthPayment = true
            }
        }
        
        for i in stride(from: 0, to: self.importedAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = self.importedAccounts!.getAccountObjectForIdx(i)
            if accountObject.stealthWallet!.getStealthAddress() == stealthAddress {
                accountObject.stealthWallet!.isListeningToStealthPayment = true
            }
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
                if accountObject.stealthWallet!.getStealthAddress() == stealthAddress {
                    if accountObject.hasFetchedAccountData() {
                        for stealthDataScript in possibleStealthDataScripts {
                            let privateKey = accountObject.stealthWallet!.generateAndAddStealthAddressPaymentKey(stealthDataScript, expectedAddress: paymentAddress,
                                txid: txid, txTime: txTime, stealthPaymentStatus: TLStealthPaymentStatus.unspent)
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

            for i in stride(from: 0, to: self.accounts!.getNumberOfAccounts(), by: 1) {
                let accountObject = self.accounts!.getAccountObjectForIdx(i)
                processStealthPayment(accountObject)
            }
        
            for i in stride(from: 0, to: self.coldWalletAccounts!.getNumberOfAccounts(), by: 1) {
                let accountObject = self.coldWalletAccounts!.getAccountObjectForIdx(i)
                for address in inputAddresses {
                    if accountObject.isAddressPartOfAccount(address) {
                        self.handleNewTxForAccount(accountObject, txObject: txObject)
                    }
                }
            }

            for i in stride(from: 0, to: self.importedAccounts!.getNumberOfAccounts(), by: 1) {
                let accountObject = self.importedAccounts!.getAccountObjectForIdx(i)
                processStealthPayment(accountObject)
            }
            
            for i in stride(from: 0, to: self.importedWatchAccounts!.getNumberOfAccounts(), by: 1) {
                let accountObject = self.importedWatchAccounts!.getAccountObjectForIdx(i)
                for address in inputAddresses {
                    if accountObject.isAddressPartOfAccount(address) {
                        self.handleNewTxForAccount(accountObject, txObject: txObject)
                    }
                }
            }
            for i in stride(from: 0, to: self.importedAddresses!.getCount(), by: 1) {
                let importedAddress = self.importedAddresses!.getAddressObjectAtIdx(i)
                for addr in inputAddresses {
                    if (addr == importedAddress.getAddress()) {
                        self.handleNewTxForImportedAddress(importedAddress, txObject: txObject)
                    }
                }
            }
            for i in stride(from: 0, to: self.importedWatchAddresses!.getCount(), by: 1) {
                let importedAddress = self.importedWatchAddresses!.getAddressObjectAtIdx(i)
                for addr in inputAddresses {
                    if (addr == importedAddress.getAddress()) {
                        self.handleNewTxForImportedAddress(importedAddress, txObject: txObject)
                    }
                }
            }
    }
    
    func respondToStealthPayment(_ note: Notification) {
        let responseDict = note.object as! NSDictionary
        let stealthAddress = responseDict.object(forKey: "stealth_addr") as! String
        let txid = responseDict.object(forKey: "txid") as! String
        let paymentAddress = responseDict.object(forKey: "addr") as! String
        let txTime = UInt64((responseDict.object(forKey: "time") as! NSNumber).uint64Value)
        DLog("respondToStealthPayment stealthAddress: \(stealthAddress)")
        DLog("respondToStealthPayment respondToStealthPaymentGetTxTries: \(self.respondToStealthPaymentGetTxTries)")

        if self.respondToStealthPaymentGetTxTries < self.RESPOND_TO_STEALTH_PAYMENT_GET_TX_TRIES_MAX_TRIES {
            TLBlockExplorerAPI.instance().getTx(txid, success: { (jsonData:AnyObject?) -> () in
                if jsonData == nil {
                    return;
                }
                let txObject = TLTxObject(dict:jsonData as! NSDictionary)
                self.handleGetTxSuccessForRespondToStealthPayment(stealthAddress,
                    paymentAddress: paymentAddress, txid: txid, txTime: txTime, txObject: txObject)
                
                    self.respondToStealthPaymentGetTxTries = 0
                }, failure: { (code, status) -> () in
                    DLog("respondToStealthPayment getTx fail \(txid)")
                    self.respondToStealthPayment(note)
                    self.respondToStealthPaymentGetTxTries += 1
            })
        }
    }
    
    func setWalletTransactionListenerClosed() {
        DLog("setWalletTransactionListenerClosed")
        for i in stride(from: 0, to: self.accounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = self.accounts!.getAccountObjectForIdx(i)
            accountObject.listeningToIncomingTransactions = false
        }
        for i in stride(from: 0, to: self.coldWalletAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = self.coldWalletAccounts!.getAccountObjectForIdx(i)
            accountObject.listeningToIncomingTransactions = false
        }
        for i in stride(from: 0, to: self.importedAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = self.importedAccounts!.getAccountObjectForIdx(i)
            accountObject.listeningToIncomingTransactions = false
        }
        for i in stride(from: 0, to: self.importedWatchAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = self.importedWatchAccounts!.getAccountObjectForIdx(i)
            accountObject.listeningToIncomingTransactions = false
        }
        for i in stride(from: 0, to: self.importedAddresses!.getCount(), by: 1) {
            let importedAddress = self.importedAddresses!.getAddressObjectAtIdx(i)
            importedAddress.listeningToIncomingTransactions = false
        }
        for i in stride(from: 0, to: self.importedWatchAddresses!.getCount(), by: 1) {
            let importedAddress = self.importedWatchAddresses!.getAddressObjectAtIdx(i)
            importedAddress.listeningToIncomingTransactions = false
        }
    }
    
    func listenToIncomingTransactionForGeneratedAddress(_ note: Notification) {
        let address: AnyObject? = note.object as AnyObject?
        
        TLTransactionListener.instance().listenToIncomingTransactionForAddress(address as! String)
    }
    
    func updateModelWithNewTransaction(_ note: Notification) {
        let txDict = note.object as! NSDictionary
        DLog("updateModelWithNewTransaction txDict: \(txDict.debugDescription)")
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async {
            let txObject = TLTxObject(dict:txDict)
            if self.pendingSelfStealthPaymentTxid != nil {
                // Special case where receiving stealth payment from same sending account. 
                // Let stealth websocket handle it
                // Need this cause, must generate private key and add address to account so that the bitcoins can be accounted for.
                if txObject.getHash() as? String == self.pendingSelfStealthPaymentTxid {
                    //self.pendingSelfStealthPaymentTxid = nil
                    return
                }
            }
            
            let addressesInTx = txObject.getAddresses()
            
            for i in stride(from: 0, to: self.accounts!.getNumberOfAccounts(), by: 1) {
                let accountObject = self.accounts!.getAccountObjectForIdx(i)
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
            
            for i in stride(from: 0, to: self.coldWalletAccounts!.getNumberOfAccounts(), by: 1) {
                let accountObject = self.coldWalletAccounts!.getAccountObjectForIdx(i)
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
            
            for i in stride(from: 0, to: self.importedAccounts!.getNumberOfAccounts(), by: 1) {
                let accountObject = self.importedAccounts!.getAccountObjectForIdx(i)
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
            
            for i in stride(from: 0, to: self.importedWatchAccounts!.getNumberOfAccounts(), by: 1) {
                let accountObject = self.importedWatchAccounts!.getAccountObjectForIdx(i)
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
            
            for i in stride(from: 0, to: self.importedAddresses!.getCount(), by: 1) {
                let importedAddress = self.importedAddresses!.getAddressObjectAtIdx(i)
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
            
            for i in stride(from: 0, to: self.importedWatchAddresses!.getCount(), by: 1) {
                let importedAddress = self.importedWatchAddresses!.getAddressObjectAtIdx(i)
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
    }

    func handleNewTxForAccount(_ accountObject: TLAccountObject, txObject: TLTxObject) {
        let receivedAmount = accountObject.processNewTx(txObject)
        let receivedTo = accountObject.getAccountNameOrAccountPublicKey()
        //AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: true, success: {
            self.updateUIForNewTx(txObject.getHash() as! String, receivedAmount: receivedAmount, receivedTo: receivedTo)
        //})
    }
    
    func handleNewTxForImportedAddress(_ importedAddress: TLImportedAddress, txObject: TLTxObject) {
        let receivedAmount = importedAddress.processNewTx(txObject)
        let receivedTo = importedAddress.getLabel()
        //AppDelegate.instance().pendingOperations.addSetUpImportedAddressOperation(importedAddress, fetchDataAgain: true, success: {
            self.updateUIForNewTx(txObject.getHash() as! String, receivedAmount: receivedAmount, receivedTo: receivedTo)
        //})
    }
    
    func updateUIForNewTx(_ txHash: String, receivedAmount: TLCoin?, receivedTo: String) {
        DispatchQueue.main.async {
            DLog("updateUIForNewTx txHash \(txHash)")
            self.webSocketNotifiedTxHashSet.add(txHash)
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_UNCONFIRMED_TRANSACTION()), object: txHash, userInfo:nil)
            if receivedAmount != nil {
                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_RECEIVE_PAYMENT()), object:nil, userInfo:nil)
                self.promptReceivedPayment(receivedTo, receivedAmount: receivedAmount!)
            }
        }
    }
    
    func promptReceivedPayment(_ receivedTo:String, receivedAmount:TLCoin) {
        let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            let msg = "\(receivedTo) received \(TLCurrencyFormat.getProperAmount(receivedAmount))"
            TLPrompts.promptSuccessMessage(msg, message: "")
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            if (TLPreferences.getEnableSoundNotification()) {
                AudioServicesPlaySystemSound(1016)
            }
        }
    }
    
    func updateModelWithNewBlock(_ note: Notification) {
        let jsonData = note.object as! NSDictionary
        let blockHeight = jsonData.object(forKey: "height") as! NSNumber
        DLog("updateModelWithNewBlock: \(blockHeight)")
        TLBlockchainStatus.instance().blockHeight = blockHeight.uint64Value
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_BLOCK()), object:nil, userInfo:nil)
        
    }
    
    func initializeWalletAppAndShowInitialScreen(_ recoverHDWalletIfNewlyInstalledApp:(Bool), walletPayload:(NSDictionary?)) {
        if (TLPreferences.getEnableBackupWithiCloud()) {
            TLCloudDocumentSyncWrapper.instance().checkCloudAvailability()
        }
        TLAnalytics.instance()
        
        NotificationCenter.default.addObserver(self
            ,selector:#selector(AppDelegate.saveWalletPayloadDelay(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(AppDelegate.updateModelWithNewTransaction(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_NEW_UNCONFIRMED_TRANSACTION()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(AppDelegate.updateModelWithNewBlock(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_NEW_BLOCK()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(AppDelegate.listenToIncomingTransactionForGeneratedAddress(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_NEW_ADDRESS_GENERATED()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(AppDelegate.setWalletTransactionListenerClosed),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_TRANSACTION_LISTENER_CLOSE()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(AppDelegate.listenToIncomingTransactionForWallet),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_TRANSACTION_LISTENER_OPEN()), object:nil)
        
        NotificationCenter.default.addObserver(self
            ,selector:#selector(AppDelegate.setAccountsListeningToStealthPaymentsToFalse),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_STEALTH_PAYMENT_LISTENER_CLOSE()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(AppDelegate.respondToStealthChallegeNotification(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_RECEIVED_STEALTH_CHALLENGE()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(AppDelegate.respondToStealthAddressSubscription(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_RECEIVED_STEALTH_ADDRESS_SUBSCRIPTION()), object:nil)
        NotificationCenter.default.addObserver(self
            ,selector:#selector(AppDelegate.respondToStealthPayment(_:)),
            name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_RECEIVED_STEALTH_PAYMENT()), object:nil)
    
        var passphrase = TLWalletPassphrase.getDecryptedWalletPassphrase()

        if (!TLPreferences.hasSetupHDWallet()) {
            if (recoverHDWalletIfNewlyInstalledApp) {
                self.recoverHDWallet(passphrase!)
            } else {
                passphrase = TLHDWalletWrapper.generateMnemonicPassphrase()
                self.refreshApp(passphrase!)
                let accountObject = self.accounts!.createNewAccount("Account 1", accountType:.normal, preloadStartingAddresses:true)
                accountObject.updateAccountNeedsRecovering(false)
                AppDelegate.instance().updateGodSend(TLSendFromType.hdWallet, sendFromIndex:0)
                AppDelegate.instance().updateReceiveSelectedObject(TLSendFromType.hdWallet, sendFromIndex:0)
                AppDelegate.instance().updateHistorySelectedObject(TLSendFromType.hdWallet, sendFromIndex:0)
            }
            self.justSetupHDWallet = true
            let encryptedWalletJson = TLWalletJson.getEncryptedWalletJsonContainer(self.appWallet.getWalletsJson()!,
                password:TLWalletJson.getDecryptedEncryptedWalletJSONPassphrase()!)
            let success = self.saveWalletJson(encryptedWalletJson as (NSString), date:Date())
            if success {
                TLPreferences.setHasSetupHDWallet(true)
            } else {
                NSException(name: NSExceptionName(rawValue: "Error"), reason: "Error saving wallet JSON file", userInfo: nil).raise()
            }
        } else {
            let masterHex = TLHDWalletWrapper.getMasterHex(passphrase ?? "")

            if (walletPayload != nil) {
                self.appWallet.loadWalletPayload(walletPayload!, masterHex:masterHex)
            } else {
                TLPrompts.promptErrorMessage(TLDisplayStrings.ERROR_STRING(), message:TLDisplayStrings.ERROR_LOADING_WALLET_JSON_FILE_STRING())
                NSException(name: NSExceptionName(rawValue: "Error"), reason: "Error loading wallet JSON file", userInfo: nil).raise()
            }
        }
        
        self.accounts = TLAccounts(appWallet: self.appWallet, accountsArray:self.appWallet.getAccountObjectArray(), accountType:.hdWallet)
        self.coldWalletAccounts = TLAccounts(appWallet:self.appWallet, accountsArray:self.appWallet.getColdWalletAccountArray(), accountType:.coldWallet)
        self.importedAccounts = TLAccounts(appWallet:self.appWallet, accountsArray:self.appWallet.getImportedAccountArray(), accountType:.imported)
        self.importedWatchAccounts = TLAccounts(appWallet: self.appWallet, accountsArray:self.appWallet.getWatchOnlyAccountArray(), accountType:.importedWatch)
        self.importedAddresses = TLImportedAddresses(appWallet: self.appWallet, importedAddresses:self.appWallet.getImportedPrivateKeyArray(), accountAddressType:TLAccountAddressType.imported)
        self.importedWatchAddresses = TLImportedAddresses(appWallet: self.appWallet, importedAddresses:self.appWallet.getWatchOnlyAddressArray(), accountAddressType:TLAccountAddressType.importedWatch)
        
        self.isAccountsAndImportsLoaded = true
        
        self.godSend = TLSpaghettiGodSend(appWallet: self.appWallet)
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
        let baseURL = URL(string:blockExplorerURL)
        TLNetworking.isReachable(baseURL!, reachable:{(reachable: TLDOMAINREACHABLE) in
            if (reachable == TLDOMAINREACHABLE.notreachable) {
                TLPrompts.promptErrorMessage(TLDisplayStrings.NETWORK_ERROR_STRING(),
                    message:String(format:TLDisplayStrings.X_SERVERS_NOT_REACHABLE_STRING(), blockExplorerURL))
            }
        })
        
        TLBlockExplorerAPI.instance().getBlockHeight({(jsonData:AnyObject!) in
            let blockHeight = (jsonData.object(forKey: "height") as! NSNumber).uint64Value
            DLog("setBlockHeight: \((jsonData.object(forKey: "height") as! NSNumber))")
            TLBlockchainStatus.instance().blockHeight = blockHeight
            }, failure:{(code, status) in
                DLog("Error getting block height.")
                TLPrompts.promptErrorMessage(TLDisplayStrings.NETWORK_ERROR_STRING(),
                    message:String(format:TLDisplayStrings.ERROR_GETTING_BLOCK_HEIGHT_STRING()))
        })
    }
    
    func refreshHDWalletAccounts(_ isRestoringWallet: Bool) {
        let group = DispatchGroup()
        for i in stride(from: 0, to: self.accounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = self.accounts!.getAccountObjectForIdx(i)
            group.enter()
            
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
                group.enter()
                DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                    accountObject.fetchNewStealthPayments(isRestoringWallet)
                    group.leave()
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
    
    fileprivate func setUpLocalNotification() {
        if (TLUtils.getiOSVersion() >= 8) {
            let types: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.sound, UIUserNotificationType.alert]
            let mySettings =
            UIUserNotificationSettings(types: types, categories:nil)
            UIApplication.shared.registerUserNotificationSettings(mySettings)
        }
    }
    
    func application(_ applcation: UIApplication, didReceive notification: UILocalNotification) {
        DLog("didReceiveLocalNotification: \(notification.alertBody!)")
        let av = UIAlertView(title:notification.alertBody!,
            message:""                                       ,
            delegate:nil                                       ,
            cancelButtonTitle:nil                               ,
            otherButtonTitles:TLDisplayStrings.OK_STRING())
        
        av.show()
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
    }
    
    fileprivate func showLocalNotification(_ message: String) {
        DLog("showLocalNotification: \(message)")
        let localNotification = UILocalNotification()
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.fireDate = Date(timeIntervalSinceNow:1)
        localNotification.alertBody = message
        localNotification.timeZone = TimeZone.current
        UIApplication.shared.scheduleLocalNotification(localNotification)
        if (TLPreferences.getEnableSoundNotification()) {
            AudioServicesPlaySystemSound(1016)
        }
    }
    
    fileprivate func isCameraAllowed() -> Bool {
        return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) != AVAuthorizationStatus.denied
    }
    
    fileprivate func promptAppNotAllowedCamera() {
        let displayName = TLUtils.defaultAppName()
        
        let av = UIAlertView(title: String(format:TLDisplayStrings.X_NOT_ALLOWED_TO_ACCESS_THE_CAMERA_STRING(), displayName),
            message: String(format:TLDisplayStrings.ALLOW_CAMERA_ACCESS_IN_STRING(), displayName),
            delegate:nil      ,
            cancelButtonTitle:TLDisplayStrings.OK_STRING())
        
        av.show()
    }
    
    
    func showPrivateKeyReaderController(_ viewController: UIViewController, success: @escaping TLWalletUtils.SuccessWithDictionary, error: @escaping TLWalletUtils.ErrorWithString) {
        if (!isCameraAllowed()) {
            self.promptAppNotAllowedCamera()
            return
        }
        
        let reader = TLQRCodeScannerViewController(success:{(data: String?) in
            if (TLCoreBitcoinWrapper.isBIP38EncryptedKey(data!, isTestnet: self.appWallet.walletConfig.isTestnet)) {
                self.scannedEncryptedPrivateKey = data!
            }
                
            else {
                success(["privateKey":data!])
            }
            
            }, error:{(e: String?) in
                error(e)
        })
        
        viewController.present(reader, animated:true, completion:nil)
    }
    
    func showAddressReaderControllerFromViewController(_ viewController: (UIViewController), success: @escaping (TLWalletUtils.SuccessWithString), error: @escaping (TLWalletUtils.ErrorWithString)) {
        if (!isCameraAllowed()) {
            promptAppNotAllowedCamera()
            return
        }
        
        let reader = TLQRCodeScannerViewController(success:{(data: String?) in
            success(data)
            }, error:{(e: String?) in
                error(e)
        })
        
        viewController.present(reader, animated:true, completion:nil)
    }
    
    func showExtendedPrivateKeyReaderController(_ viewController: (UIViewController), success: @escaping (TLWalletUtils.SuccessWithString), error: @escaping (TLWalletUtils.ErrorWithString)) {
        if (!isCameraAllowed()) {
            promptAppNotAllowedCamera()
            return
        }
        
        let reader = TLQRCodeScannerViewController(success:{(data: String?) in
            success(data)
            }, error:{(e: String?) in
                error(e)
        })
        
        viewController.present(reader, animated:true, completion:nil)
    }
    
    func showExtendedPublicKeyReaderController(_ viewController: (UIViewController), success: @escaping (TLWalletUtils.SuccessWithString), error: @escaping (TLWalletUtils.ErrorWithString)) {
        if (!isCameraAllowed()) {
            promptAppNotAllowedCamera()
            return
        }
        
        let reader = TLQRCodeScannerViewController(success:{(data: String?) in
            success(data)
            }, error:{(e: String?) in
                error(e)
        })
        
        viewController.present(reader, animated:true, completion:nil)
    }
    
    func showColdWalletSpendReaderControllerFromViewController(_ viewController: (UIViewController), success: @escaping (TLWalletUtils.SuccessWithString), error: @escaping (TLWalletUtils.ErrorWithString)) {
        if (!isCameraAllowed()) {
            promptAppNotAllowedCamera()
            return
        }
        
        let reader = TLQRCodeScannerViewController(success:{(data: String?) in
            success(data)
            }, error:{(e: String?) in
                error(e)
        })
        
        viewController.present(reader, animated:true, completion:nil)
    }
    
    func listenToIncomingTransactionForWallet() {
        if (!self.isAccountsAndImportsLoaded || !TLTransactionListener.instance().isWebSocketOpen()) {
            return
        }
        
        for i in stride(from: 0, to: self.accounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = self.accounts!.getAccountObjectForIdx(i)
            if accountObject.downloadState != .downloaded {
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
        
        for i in stride(from: 0, to: self.coldWalletAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = self.coldWalletAccounts!.getAccountObjectForIdx(i)
            if accountObject.downloadState != .downloaded {
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
        
        for i in stride(from: 0, to: self.importedAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = self.importedAccounts!.getAccountObjectForIdx(i)
            if accountObject.downloadState != .downloaded {
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
        
        for i in stride(from: 0, to: self.importedWatchAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = self.importedWatchAccounts!.getAccountObjectForIdx(i)
            if accountObject.downloadState != .downloaded {
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
        
        for i in stride(from: 0, to: self.importedAddresses!.getCount(), by: 1) {
            let importedAddress = self.importedAddresses!.getAddressObjectAtIdx(i)
            if importedAddress.downloadState != .downloaded {
                continue
            }
            let address = importedAddress.getAddress()
            TLTransactionListener.instance().listenToIncomingTransactionForAddress(address)
            importedAddress.listeningToIncomingTransactions = true
        }
        
        for i in stride(from: 0, to: self.importedWatchAddresses!.getCount(), by: 1) {
            let importedAddress = self.importedWatchAddresses!.getAddressObjectAtIdx(i)
            if importedAddress.downloadState != .downloaded {
                continue
            }
            let address = importedAddress.getAddress()
            TLTransactionListener.instance().listenToIncomingTransactionForAddress(address)
            importedAddress.listeningToIncomingTransactions = true
        }
        
    }
    
    func application(_ application: (UIApplication), open url: URL, sourceApplication: (String)?, annotation:Any) -> Bool {
        self.bitcoinURIOptionsDict = TLWalletUtils.parseBitcoinURI(url.absoluteString)        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }   
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if (TLPreferences.getEnableBackupWithiCloud()) {
            // when terminating app must save immediately, don't wait to save to iCloud
            let encryptedWalletJson = TLWalletJson.getEncryptedWalletJsonContainer(self.appWallet.getWalletsJson()!,
                password:TLWalletJson.getDecryptedEncryptedWalletJSONPassphrase()!)
            self.saveWalletJson(encryptedWalletJson as (NSString), date:Date())
        }
        self.saveWalletJsonCloud()
    }
    
    func saveWalletPayloadDelay(_ notification: Notification) {
        DispatchQueue.main.async {
            if self.saveWalletJSONEnabled == false {
                return
            }
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector:#selector(AppDelegate.saveWalletJsonCloudBackground), object:nil)
            Timer.scheduledTimer(timeInterval: self.SAVE_WALLET_PAYLOAD_DELAY, target: self,
                selector: #selector(AppDelegate.saveWalletJsonCloudBackground), userInfo: nil, repeats: false)
        }
    }
    
    func saveWalletJsonCloudBackground() {
        DLog("saveWalletJsonCloudBackground starting...")
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background)
        queue.async {
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
                TLCloudDocumentSyncWrapper.instance().saveFile(toCloud: TLPreferences.getCloudBackupWalletFileName()!, content:encryptedWalletJson,
                    completion:{(cloudDocument, documentData, error) in
                        if error == nil {
                            self.saveWalletJson(encryptedWalletJson as (NSString), date:cloudDocument!.fileModificationDate!)
                            DLog("saveFileToCloud done")
                        } else {
                            DLog("saveFileToCloud error \(error!.localizedDescription)")
                        }
                })
            } else {
                self.saveWalletJson(encryptedWalletJson as (NSString), date:Date())
                DLog("saveFileToCloud ! checkCloudAvailability save local done")
            }
        } else {
            self.saveWalletJson(encryptedWalletJson as (NSString), date:Date())
            DLog("saveFileToCloud local done")
        }
        return true
    }
    
    fileprivate func saveWalletJson(_ encryptedWalletJson: (NSString), date: (Date)) -> Bool {
        let success = TLWalletJson.saveWalletJson(encryptedWalletJson as String, date:date)
        
        if (!success) {
            DispatchQueue.main.async {
                TLPrompts.promptErrorMessage(TLDisplayStrings.LOCAL_BACK_UP_TO_WALLET_FAILED_STRING(), message:TLDisplayStrings.LOCAL_BACK_UP_TO_WALLET_FAILED_STRING())
            }
        }
        
        return success
    }
    
    func getLocalWalletJsonDict() -> NSDictionary? {
        return TLWalletJson.getWalletJsonDict(TLWalletJson.getLocalWalletJSONFile(),
            password:TLWalletJson.getDecryptedEncryptedWalletJSONPassphrase())
    }
    
    fileprivate func menuShownHideStatusBar() {
        UIApplication.shared.isStatusBarHidden = true
    }
    
    fileprivate func menuHiddenShowStatusBar() {
        UIApplication.shared.isStatusBarHidden = false
    }
    
    
    func passcodeViewControllerWillClose() {
        UIApplication.shared.isStatusBarHidden = false
    }
    
    func maxNumberOfFailedAttemptsReached() {
    }
    
    func passcodeWasEnteredSuccessfully() {
        UIApplication.shared.isStatusBarHidden = false
    }
    
    func logoutButtonWasPressed() {
        UIApplication.shared.isStatusBarHidden = false
    }
}
