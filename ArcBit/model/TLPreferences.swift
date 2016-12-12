//
//  TLPreferences.swift
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
class TLPreferences
{
    struct CLASS_STATIC {
        static let RESET_CLOUD_BACKUP_WALLET_FILE_NAME = false
        
        //keys must match keys defined in Settings.bundle/Root.plist
        static let INAPPSETTINGS_KIT_RECEIVING_ADDRESS = "address"
        static let INAPPSETTINGS_KIT_NAME = "name"
        static let INAPPSETTINGS_KIT_TRANSACTION_FEE = "transactionfee"
        static let INAPPSETTINGS_KIT_BLOCKEXPLORER_URL = "blockexplorerurl"
        static let INAPPSETTINGS_KIT_BLOCKEXPLORER_API = "blockexplorerapi"
        static let INAPPSETTINGS_KIT_STEALTH_EXPLORER_URL = "stealthexplorerurl"
        static let INAPPSETTINGS_KIT_STEALTH_WEB_SOCKET_URL = "stealthwebsocketurl"
        static let INAPPSETTINGS_KIT_STEALTH_SERVER_PORT = "stealthwebserverport"
        static let INAPPSETTINGS_KIT_STEALTH_WEB_SOCKET_PORT = "stealthwebsocketport"
        static let INAPPSETTINGS_KIT_RECEIVING_CURRENCY = "currency"
        static let INAPPSETTINGS_KIT_DISPLAY_LOCAL_CURRENCY = "displaylocalcurrency"
        static let INAPPSETTINGS_KIT_ENABLE_DYNAMIC_FEE = "enabledynamicfee"
        static let INAPPSETTINGS_KIT_DYNAMIC_FEE_OPTION = "dynamicfeeoption"
        static let INAPPSETTINGS_KIT_ENABLE_COLD_WALLET = "enablecoldwallet"

        static let PREFERENCE_INSTALL_DATE = "pref-install-date"
        static let PREFERENCE_APP_VERSION = "pref-app-version"
        static let PREFERENCE_PUSH_NOTIFICTION = "pref-push-notification"
        static let PREFERENCE_FIAT_DISPLAY = "pref-fiat-display"
        static let PREFERENCE_BITCOIN_DISPLAY = "pref-bitcoin-display"
        static let PREFERENCE_BLOCKEXPLORER_API = "pref-blockexplorer-api"
        static let PREFERENCE_BLOCKEXPLORER_API_URL_DICT = "pref-blockexplorer-api-url"
        static let PREFERENCE_BTC_SYMBOL_TOGGLED = "pref-btc-symbol-toggled"
        static let PREFERENCE_ENABLE_BACKUP_WITH_ICLOUD = "pref-enable-backup-with-icloud"
        static let INAPPSETTINGS_KIT_ENABLE_BACKUP_WITH_ICLOUD = "enablebackupwithicloud"
        static let INAPPSETTINGS_KIT_ENABLE_PIN_CODE = "enablepincode"
        static let INAPPSETTINGS_CAN_RESTORE_DELETED_APP = "canrestoredeletedapp"
        static let INAPPSETTINGS_ENABLE_SOUND_NOTIFICATION = "enablesoundnotification"
        static let PREFERENCE_CAN_RESTORE_DELETED_APP = "pref-can-restore-deleted-app"
        static let PREFERENCE_CLOUD_BACKUP_WALLET_FILE_NAME = "pref-cloud-backup-wallet-file-name"
        static let PREFERENCE_WALLET_PASSPHRASE = "pref-wallet-passphrase"
        static let PREFERENCE_ENCRYPTED_WALLET_JSON_PASSPHRASE = "pref-encrypted-wallet-json-passphrase"
        static let PREFERENCE_ENCRYPTED_WALLET_JSON_CHECKSUM = "pref-encrypted-wallet-json-checksum"
        static let PREFERENCE_LAST_SAVED_ENCRYPTED_WALLET_JSON_DATE = "pref-last-saved-encrypted-wallet-json-date"
        static let PREFERENCE_ENABLE_PIN_CODE = "pref-enable-pin-code"
        static let PREFERENCE_WALLET_COLD_WALLET = "pref-cold-wallet"
        static let PREFERENCE_WALLET_ADVANCE_MODE = "pref-advance-mode"
        static let PREFERENCE_DISPLAY_LOCAL_CURRENCY = "pref-display-local-currency"
        static let PREFERENCE_FEE_AMOUNT = "pref-fee-amount"
        static let PREFERENCE_SUGGESTIONS_DICT = "pref-suggestions-dict"
        static let PREFERENCE_ANALYTICS_DICT = "pref-analytics-dict"
        static let PREFERENCE_SEND_FROM_TYPE = "pref-send-from-type"
        static let PREFERENCE_SEND_FROM_INDEX = "pref-send-from-index"
        static let PREFERENCE_HAS_SETUP_HDWALLET = "pref-has-setup-hdwallet"
        static let PREFERENCE_ENABLE_STEALTH_ADDRESS_DEFAULT = "pref-enable-stealth-address-default"
        static let PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE = "pref-encrypted-backup-passphrase"
        static let PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE_KEY = "pref-encrypted-backup-passphrase-key"
        static let PREFERENCE_ENABLED_PROMPT_SHOW_WEB_WALLET = "pref-enabled-prompt-show-web-wallet"
        static let PREFERENCE_ENABLED_PROMPT_SHOW_TRY_COLD_WALLET = "pref-enabled-prompt-show-try-cold-wallet"
        static let PREFERENCE_ENABLED_PROMPT_SHOW_CHECKOUT_ANDROID_WALLET = "pref-enabled-prompt-checkout-android-wallet"
        static let PREFERENCE_ENABLED_PROMPT_RATE_APP = "pref-enabled-prompt-rate-app"
        static let PREFERENCE_RATED_ONCE = "pref-rated-once"
    }
    
    class func setHasSetupHDWallet(_ enabled:Bool) -> () {
        UserDefaults.standard.set(enabled ,forKey:CLASS_STATIC.PREFERENCE_HAS_SETUP_HDWALLET)
        UserDefaults.standard.synchronize()
    }
    
    class func hasSetupHDWallet() -> (Bool) {
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.PREFERENCE_HAS_SETUP_HDWALLET)
    }
    
    class func setInstallDate() -> () {
        if(UserDefaults.standard.object(forKey: CLASS_STATIC.PREFERENCE_INSTALL_DATE) == nil) {
            UserDefaults.standard.set(Date() ,forKey:CLASS_STATIC.PREFERENCE_INSTALL_DATE)
            UserDefaults.standard.synchronize()
        }
    }
    
    class func getInstallDate() -> (Date?) {
        let joinedDate = UserDefaults.standard.object(forKey: CLASS_STATIC.PREFERENCE_INSTALL_DATE) as! Date?
        if(joinedDate == nil) {
            return nil
        }
        return joinedDate
    }
    
    class func getAppVersion() -> String {
        let ver = UserDefaults.standard.string(forKey: CLASS_STATIC.PREFERENCE_APP_VERSION)
        return ver != nil ? ver! : "0";
    }
    
    class func setAppVersion(_ version: String) -> () {
        UserDefaults.standard.set(version, forKey:CLASS_STATIC.PREFERENCE_APP_VERSION)
        UserDefaults.standard.synchronize()
    }
    
    class func getCurrencyIdx() -> (String?) {
        return UserDefaults.standard.string(forKey: CLASS_STATIC.PREFERENCE_FIAT_DISPLAY)
    }
    
    class func setCurrency(_ currencyIdx:String) -> () {
        UserDefaults.standard.set(currencyIdx ,forKey:CLASS_STATIC.PREFERENCE_FIAT_DISPLAY)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_PREFERENCES_FIAT_DISPLAY_CHANGED()), object:nil, userInfo:nil)
    }
    
    class func getBitcoinDenomination() -> (TLBitcoinDenomination) {
        let value = UserDefaults.standard.string(forKey: CLASS_STATIC.PREFERENCE_BITCOIN_DISPLAY) as NSString?
        if(value == nil) {
            return TLBitcoinDenomination(rawValue: 0)!
        }
        return TLBitcoinDenomination(rawValue: value!.integerValue)!
    }
    
    class func setBitcoinDisplay(_ bitcoinDisplayIdx:String) -> (){
        UserDefaults.standard.set(bitcoinDisplayIdx ,forKey:CLASS_STATIC.PREFERENCE_BITCOIN_DISPLAY)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_PREFERENCES_BITCOIN_DISPLAY_CHANGED())
            ,object:nil, userInfo:nil)
    }
    
    class func getSendFromType() -> (TLSendFromType) {
        return TLSendFromType(rawValue:UserDefaults.standard.integer(forKey: CLASS_STATIC.PREFERENCE_SEND_FROM_TYPE))!
    }
    
    class func setSendFromType(_ sendFromType:TLSendFromType) -> () {
        UserDefaults.standard.set(sendFromType.rawValue ,forKey:CLASS_STATIC.PREFERENCE_SEND_FROM_TYPE)
        UserDefaults.standard.synchronize()
    }
    
    class func getSendFromIndex() -> (UInt) {
        return UInt(UserDefaults.standard.integer(forKey: CLASS_STATIC.PREFERENCE_SEND_FROM_INDEX))
    }
    
    class func setSendFromIndex(_ sendFromIndex:UInt) -> () {
        UserDefaults.standard.set(Int(sendFromIndex) ,forKey:CLASS_STATIC.PREFERENCE_SEND_FROM_INDEX)
        UserDefaults.standard.synchronize()
    }
    
    
    class func getBlockExplorerAPI() -> (TLBlockExplorer) {
        let value = UserDefaults.standard.string(forKey: CLASS_STATIC.PREFERENCE_BLOCKEXPLORER_API) as NSString?
        if(value == nil) {
            return TLBlockExplorer(rawValue: 0)!
        }
        return TLBlockExplorer(rawValue: value!.integerValue)!
    }
    
    class func setBlockExplorerAPI(_ blockexplorerIdx:String) -> () {
        UserDefaults.standard.set(blockexplorerIdx ,forKey:CLASS_STATIC.PREFERENCE_BLOCKEXPLORER_API)
        UserDefaults.standard.synchronize()
    }
    
    class func getBlockExplorerURL(_ blockExplorer:TLBlockExplorer) -> (String?) {
        let blockExplorer2blockExplorerURLDict = UserDefaults.standard.object(forKey: CLASS_STATIC.PREFERENCE_BLOCKEXPLORER_API_URL_DICT) as! NSDictionary
        let key = String(format:"%ld", blockExplorer.rawValue)
        return blockExplorer2blockExplorerURLDict.value(forKey: key) as? String
    }
    
    class func setBlockExplorerURL(_ blockExplorer:TLBlockExplorer, value:(String)) -> (){
        assert(blockExplorer == TLBlockExplorer.insight, "can only change insight URL currently")
        let blockExplorer2blockExplorerURLDict = (UserDefaults.standard.object(forKey: CLASS_STATIC.PREFERENCE_BLOCKEXPLORER_API_URL_DICT) as! NSDictionary).mutableCopy() as! NSDictionary
        blockExplorer2blockExplorerURLDict.setValue(value ,forKey:String(format:"%ld", blockExplorer.rawValue))
        UserDefaults.standard.set(blockExplorer2blockExplorerURLDict ,forKey:CLASS_STATIC.PREFERENCE_BLOCKEXPLORER_API_URL_DICT)
        UserDefaults.standard.synchronize()
    }
    
    class func resetBlockExplorerAPIURL() -> (){
        let blockExplorer2blockExplorerURLDict = NSMutableDictionary(capacity: 3)
        blockExplorer2blockExplorerURLDict.setObject("https://blockchain.info/" ,forKey:String(format:"%ld", TLBlockExplorer.blockchain.rawValue) as NSCopying)
        blockExplorer2blockExplorerURLDict.setObject("https://insight.bitpay.com/" ,forKey:String(format:"%ld", TLBlockExplorer.insight.rawValue) as NSCopying)
        blockExplorer2blockExplorerURLDict.setObject("https://bitcoin.toshi.io/" ,forKey:String(format:"%ld", TLBlockExplorer.toshi.rawValue) as NSCopying)
        UserDefaults.standard.set(blockExplorer2blockExplorerURLDict ,forKey:CLASS_STATIC.PREFERENCE_BLOCKEXPLORER_API_URL_DICT)
        UserDefaults.standard.synchronize()
    }
    
    class func getStealthExplorerURL() -> (String?) {
        return UserDefaults.standard.string(forKey: CLASS_STATIC.INAPPSETTINGS_KIT_STEALTH_EXPLORER_URL)
    }
    
    class func setStealthExplorerURL(_ value:(String)) -> () {
        UserDefaults.standard.set(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_STEALTH_EXPLORER_URL)
        UserDefaults.standard.synchronize()
    }
    
    class func getStealthServerPort() -> (Int?) {
        return UserDefaults.standard.integer(forKey: CLASS_STATIC.INAPPSETTINGS_KIT_STEALTH_SERVER_PORT)
    }
    
    class func setStealthServerPort(_ value:(Int)) -> () {
        UserDefaults.standard.set(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_STEALTH_SERVER_PORT)
        UserDefaults.standard.synchronize()
    }
    
    class func getStealthWebSocketPort() -> (Int?) {
        return UserDefaults.standard.integer(forKey: CLASS_STATIC.INAPPSETTINGS_KIT_STEALTH_WEB_SOCKET_PORT)
    }
    
    class func setStealthWebSocketPort(_ value:(Int)) -> () {
        UserDefaults.standard.set(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_STEALTH_WEB_SOCKET_PORT)
        UserDefaults.standard.synchronize()
    }
    
    class func resetStealthExplorerAPIURL() -> () {
        self.setStealthExplorerURL(TLStealthServerConfig.instance().getStealthServerUrl())
    }
    
    class func resetStealthServerPort() -> () {
        self.setStealthServerPort(TLStealthServerConfig.instance().getStealthServerPort())
    }
    
    class func resetStealthWebSocketPort() -> () {
        self.setStealthWebSocketPort(TLStealthServerConfig.instance().getWebSocketServerPort())
    }
    
    class func getInAppSettingsKitBlockExplorerAPI() -> (String?){
        return UserDefaults.standard.string(forKey: CLASS_STATIC.INAPPSETTINGS_KIT_BLOCKEXPLORER_API)
    }
    
    class func setInAppSettingsKitBlockExplorerAPI(_ value:String) -> () {
        UserDefaults.standard.set(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_BLOCKEXPLORER_API)
        UserDefaults.standard.synchronize()
    }
    
    class func getInAppSettingsKitBlockExplorerURL() -> (String?) {
        return UserDefaults.standard.string(forKey: CLASS_STATIC.INAPPSETTINGS_KIT_BLOCKEXPLORER_URL)
    }
    
    class func setInAppSettingsKitBlockExplorerURL(_ value: String) -> (){
        UserDefaults.standard.set(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_BLOCKEXPLORER_URL)
        UserDefaults.standard.synchronize()
    }
    
    class func getInAppSettingsKitCurrencyIdx() -> (String?) {
        return UserDefaults.standard.string(forKey: CLASS_STATIC.INAPPSETTINGS_KIT_RECEIVING_CURRENCY)
    }
    
    class func setInAppSettingsKitCurrency(_ currencyIdx:String) -> () {
        UserDefaults.standard.set(currencyIdx, forKey:CLASS_STATIC.INAPPSETTINGS_KIT_RECEIVING_CURRENCY)
        UserDefaults.standard.synchronize()
    }
    
    class func isInAppSettingsKitDisplayLocalCurrency() -> (Bool) {
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.INAPPSETTINGS_KIT_DISPLAY_LOCAL_CURRENCY)
    }
    
    class func setInAppSettingsKitDisplayLocalCurrency(_ enabled:Bool) -> () {
        UserDefaults.standard.set(enabled ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_DISPLAY_LOCAL_CURRENCY)
        UserDefaults.standard.synchronize()
    }
    
    class func getInAppSettingsKitName() -> (String?) {
        return UserDefaults.standard.string(forKey: CLASS_STATIC.INAPPSETTINGS_KIT_NAME)
    }
    
    class func setInAppSettingsKitName(_ value:String) -> () {
        UserDefaults.standard.set(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_NAME)
        UserDefaults.standard.synchronize()
    }
    
    class func getInAppSettingsKitEnablePinCode() -> (Bool) {
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.INAPPSETTINGS_KIT_ENABLE_PIN_CODE)
    }
    
    class func setInAppSettingsKitEnablePinCode(_ value:Bool) -> () {
        UserDefaults.standard.set(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_ENABLE_PIN_CODE)
        UserDefaults.standard.synchronize()
    }
    
    class func getInAppSettingsKitTransactionFee() -> (String?) {
        return UserDefaults.standard.string(forKey: CLASS_STATIC.INAPPSETTINGS_KIT_TRANSACTION_FEE)
    }
    
    class func setInAppSettingsKitTransactionFee(_ value:String) -> () {
        UserDefaults.standard.set(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_TRANSACTION_FEE)
        UserDefaults.standard.synchronize()
    }
    
    class func getInAppSettingsKitEnableBackupWithiCloud() -> (Bool) {
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.INAPPSETTINGS_KIT_ENABLE_BACKUP_WITH_ICLOUD)
    }
    
    class func setInAppSettingsKitEnableBackupWithiCloud(_ value:Bool) -> () {
        UserDefaults.standard.set(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_ENABLE_BACKUP_WITH_ICLOUD)
        UserDefaults.standard.synchronize()
    }
    
    class func getEnableBackupWithiCloud() -> (Bool) {
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.PREFERENCE_ENABLE_BACKUP_WITH_ICLOUD)
    }
    
    class func setEnableBackupWithiCloud(_ value:Bool) -> () {
        UserDefaults.standard.set(value ,forKey:CLASS_STATIC.PREFERENCE_ENABLE_BACKUP_WITH_ICLOUD)
        UserDefaults.standard.synchronize()
    }
    
    class func deleteAllKeychainItems() -> () {
        JNKeychain.deleteValue(forKey: CLASS_STATIC.PREFERENCE_CLOUD_BACKUP_WALLET_FILE_NAME)
        JNKeychain.deleteValue(forKey: CLASS_STATIC.PREFERENCE_WALLET_PASSPHRASE)
        JNKeychain.deleteValue(forKey: CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_PASSPHRASE)
        JNKeychain.deleteValue(forKey: CLASS_STATIC.PREFERENCE_CAN_RESTORE_DELETED_APP)
    }
    
    class func getCloudBackupWalletFileName() -> (String?) {
        //CLASS_STATIC.RESET_CLOUD_BACKUP_WALLET_FILE_NAME = true // debug only, to reset cloud backup file name install fresh app with this set once, and comment out again
        if (CLASS_STATIC.RESET_CLOUD_BACKUP_WALLET_FILE_NAME) {
            return nil
        }
        return JNKeychain.loadValue(forKey: CLASS_STATIC.PREFERENCE_CLOUD_BACKUP_WALLET_FILE_NAME) as! String?
    }
    
    class func setCloudBackupWalletFileName() -> (){
        if (JNKeychain.loadValue(forKey: CLASS_STATIC.PREFERENCE_CLOUD_BACKUP_WALLET_FILE_NAME) != nil && !CLASS_STATIC.RESET_CLOUD_BACKUP_WALLET_FILE_NAME) {
            NSException(name:NSExceptionName(rawValue: "Cannot set cloud backup wallet file name"), reason:"Cloud backup wallet file name is already set", userInfo:nil).raise()
        }
        let cloudBackupWalletFileName = String(format:"%@.%@.%@", TLWalletUtils.STATIC_MEMBERS.WALLET_JSON_CLOUD_BACKUP_FILE_NAME,
            TLStealthAddress.generateEphemeralPrivkey(), TLWalletUtils.STATIC_MEMBERS.WALLET_JSON_CLOUD_BACKUP_FILE_EXTENSION)
        DLog("cloudBackupWalletFileName \(cloudBackupWalletFileName)")
        JNKeychain.saveValue(cloudBackupWalletFileName ,forKey:CLASS_STATIC.PREFERENCE_CLOUD_BACKUP_WALLET_FILE_NAME)
    }
    
    class func deleteWalletPassphrase()  -> (){
        JNKeychain.deleteValue(forKey: CLASS_STATIC.PREFERENCE_WALLET_PASSPHRASE)
        UserDefaults.standard.removeObject(forKey: CLASS_STATIC.PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE)
        UserDefaults.standard.synchronize()
    }
    
    class func getWalletPassphrase(_ useKeychain:Bool)  -> (String?){
        if useKeychain {
            return JNKeychain.loadValue(forKey: CLASS_STATIC.PREFERENCE_WALLET_PASSPHRASE) as! String?
        } else {
            return UserDefaults.standard.string(forKey: CLASS_STATIC.PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE)
        }
    }
    
    class func setWalletPassphrase(_ value:String, useKeychain:Bool)  -> (){
        if useKeychain {
            JNKeychain.saveValue(value ,forKey:CLASS_STATIC.PREFERENCE_WALLET_PASSPHRASE)
            UserDefaults.standard.removeObject(forKey: CLASS_STATIC.PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE)
            UserDefaults.standard.synchronize()
        } else {
            UserDefaults.standard.set(value ,forKey:CLASS_STATIC.PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE)
            UserDefaults.standard.synchronize()
            JNKeychain.deleteValue(forKey: CLASS_STATIC.PREFERENCE_WALLET_PASSPHRASE)
        }
    }
    class func deleteEncryptedWalletJSONPassphrase()  -> (){
        JNKeychain.deleteValue(forKey: CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_PASSPHRASE)
        UserDefaults.standard.removeObject(forKey: CLASS_STATIC.PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE)
        UserDefaults.standard.synchronize()
    }

    class func getEncryptedWalletPassphraseKey() -> (String?) {
        return UserDefaults.standard.string(forKey: CLASS_STATIC.PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE_KEY)
    }
    
    class func setEncryptedWalletPassphraseKey(_ value:String)  -> (){
        UserDefaults.standard.set(value ,forKey:CLASS_STATIC.PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE_KEY)
        UserDefaults.standard.synchronize()
    }
    
    class func clearEncryptedWalletPassphraseKey() -> () {
        UserDefaults.standard.removeObject(forKey: CLASS_STATIC.PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE_KEY)
        UserDefaults.standard.synchronize()
    }
    
    class func setCanRestoreDeletedApp(_ enabled:Bool)  -> (){
        if (enabled) {
            JNKeychain.saveValue("true" ,forKey:CLASS_STATIC.PREFERENCE_CAN_RESTORE_DELETED_APP)
        } else {
            JNKeychain.saveValue("false" ,forKey:CLASS_STATIC.PREFERENCE_CAN_RESTORE_DELETED_APP)
        }
    }
    
    class func canRestoreDeletedApp() -> (Bool) {
        let enabled = JNKeychain.loadValue(forKey: CLASS_STATIC.PREFERENCE_CAN_RESTORE_DELETED_APP) as! NSString?
        return enabled == "true" ? true : false
    }
    
    class func getInAppSettingsKitcanRestoreDeletedApp() -> (Bool) {
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.INAPPSETTINGS_CAN_RESTORE_DELETED_APP)
    }
    
    class func setInAppSettingsCanRestoreDeletedApp(_ value: Bool) -> () {
        UserDefaults.standard.set(value ,forKey:CLASS_STATIC.INAPPSETTINGS_CAN_RESTORE_DELETED_APP)
        UserDefaults.standard.synchronize()
    }
    
    class func getEnableSoundNotification() -> (Bool) {
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.INAPPSETTINGS_ENABLE_SOUND_NOTIFICATION)
    }
    
    class func setEnableSoundNotification(_ value:Bool) -> () {
        UserDefaults.standard.set(value ,forKey:CLASS_STATIC.INAPPSETTINGS_ENABLE_SOUND_NOTIFICATION)
        UserDefaults.standard.synchronize()
    }
    
    class func getEncryptedWalletJSONPassphrase(_ useKeychain:Bool) -> (String?){
        if useKeychain {
            return JNKeychain.loadValue(forKey: CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_PASSPHRASE) as! String?
        } else {
            return UserDefaults.standard.string(forKey: CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_PASSPHRASE) as String?
        }
    }
    
    class func setEncryptedWalletJSONPassphrase(_ value: String, useKeychain:Bool) -> () {
        if useKeychain {
            JNKeychain.saveValue(value ,forKey:CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_PASSPHRASE)
            UserDefaults.standard.removeObject(forKey: CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_PASSPHRASE)
            UserDefaults.standard.synchronize()
        } else {
            UserDefaults.standard.set(value ,forKey:CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_PASSPHRASE)
            UserDefaults.standard.synchronize()
            JNKeychain.deleteValue(forKey: CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_PASSPHRASE)
        }
    }
    
    class func getEncryptedWalletJSONChecksum() -> (String?) {
        return UserDefaults.standard.string(forKey: CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_CHECKSUM) as String?
    }
    
    class func setEncryptedWalletJSONChecksum(_ value:String) -> (){
        UserDefaults.standard.set(value ,forKey:CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_CHECKSUM)
        UserDefaults.standard.synchronize()
    }
    
    class func getLastSavedEncryptedWalletJSONDate() -> (Date) {
        return UserDefaults.standard.object(forKey: CLASS_STATIC.PREFERENCE_LAST_SAVED_ENCRYPTED_WALLET_JSON_DATE) as! Date
    }
    
    class func setLastSavedEncryptedWalletJSONDate(_ value:Date) -> () {
        UserDefaults.standard.set(value ,forKey:CLASS_STATIC.PREFERENCE_LAST_SAVED_ENCRYPTED_WALLET_JSON_DATE)
        UserDefaults.standard.synchronize()
    }
    
    class func isDisplayLocalCurrency() ->(Bool){
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.PREFERENCE_DISPLAY_LOCAL_CURRENCY)
    }
    
    class func setDisplayLocalCurrency(_ enabled:Bool) -> () {
        UserDefaults.standard.set(enabled ,forKey:CLASS_STATIC.PREFERENCE_DISPLAY_LOCAL_CURRENCY)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED()), object:nil)
    }
    
    class func enabledColdWallet() -> (Bool) {
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.PREFERENCE_WALLET_COLD_WALLET)
    }
    
    class func setEnableColdWallet(_ enabled:Bool) -> () {
        UserDefaults.standard.set(enabled ,forKey:CLASS_STATIC.PREFERENCE_WALLET_COLD_WALLET)
        UserDefaults.standard.synchronize()
    }
    
    class func enabledInAppSettingsKitColdWallet() -> (Bool) {
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.INAPPSETTINGS_KIT_ENABLE_COLD_WALLET)
    }
    
    class func setEnableInAppSettingsKitColdWallet(_ enabled:Bool) -> () {
        UserDefaults.standard.set(enabled ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_ENABLE_COLD_WALLET)
        UserDefaults.standard.synchronize()
    }
    
    class func enabledAdvancedMode() -> (Bool) {
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.PREFERENCE_WALLET_ADVANCE_MODE)
    }
    
    class func setAdvancedMode(_ enabled:Bool) -> () {
        UserDefaults.standard.set(enabled ,forKey:CLASS_STATIC.PREFERENCE_WALLET_ADVANCE_MODE)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_ADVANCE_MODE_TOGGLED()), object:enabled)
        if enabled {
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_ENABLE_ADVANCE_MODE()), object:enabled)
        }
    }
    
    class func isEnablePINCode() -> (Bool) {
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.PREFERENCE_ENABLE_PIN_CODE)
    }
    
    class func setEnablePINCode(_ enabled:Bool) -> () {
        UserDefaults.standard.set(enabled ,forKey:CLASS_STATIC.PREFERENCE_ENABLE_PIN_CODE)
        UserDefaults.standard.synchronize()
    }
    
    class func getSuggestionsDict() -> (NSDictionary?){
        return UserDefaults.standard.object(forKey: CLASS_STATIC.PREFERENCE_SUGGESTIONS_DICT) as! NSDictionary?
    }
    
    class func setSuggestionsDict(_ value:NSDictionary) -> () {
        UserDefaults.standard.set(value ,forKey:CLASS_STATIC.PREFERENCE_SUGGESTIONS_DICT)
        UserDefaults.standard.synchronize()
    }
    
    class func getAnalyticsDict() -> (NSDictionary?) {
        return UserDefaults.standard.object(forKey: CLASS_STATIC.PREFERENCE_ANALYTICS_DICT) as! NSDictionary?
    }
    
    class func setAnalyticsDict(_ value:NSDictionary) -> (){
        UserDefaults.standard.set(value ,forKey:CLASS_STATIC.PREFERENCE_ANALYTICS_DICT)
        UserDefaults.standard.synchronize()
    }
    
    class func enabledStealthAddressDefault() -> (Bool){
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.PREFERENCE_ENABLE_STEALTH_ADDRESS_DEFAULT)
    }
    
    class func setEnabledStealthAddressDefault(_ enabled:Bool) -> () {
        UserDefaults.standard.set(enabled ,forKey:CLASS_STATIC.PREFERENCE_ENABLE_STEALTH_ADDRESS_DEFAULT)
        UserDefaults.standard.synchronize()
    }
    
    class func disabledPromptShowWebWallet() -> (Bool) {
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.PREFERENCE_ENABLED_PROMPT_SHOW_WEB_WALLET)
    }
    
    class func setDisabledPromptShowWebWallet(_ disabled:Bool) -> () {
        UserDefaults.standard.set(disabled ,forKey:CLASS_STATIC.PREFERENCE_ENABLED_PROMPT_SHOW_WEB_WALLET)
        UserDefaults.standard.synchronize()
    }
    
    class func disabledPromptShowTryColdWallet() -> (Bool) {
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.PREFERENCE_ENABLED_PROMPT_SHOW_TRY_COLD_WALLET)
    }
    
    class func setDisabledPromptShowTryColdWallet(_ disabled:Bool) -> () {
        UserDefaults.standard.set(disabled ,forKey:CLASS_STATIC.PREFERENCE_ENABLED_PROMPT_SHOW_TRY_COLD_WALLET)
        UserDefaults.standard.synchronize()
    }
    
    class func disabledPromptCheckoutAndroidWallet() -> (Bool) {
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.PREFERENCE_ENABLED_PROMPT_SHOW_CHECKOUT_ANDROID_WALLET)
    }
    
    class func setDisabledPromptCheckoutAndroidWallet(_ disabled:Bool) -> () {
        UserDefaults.standard.set(disabled ,forKey:CLASS_STATIC.PREFERENCE_ENABLED_PROMPT_SHOW_CHECKOUT_ANDROID_WALLET)
        UserDefaults.standard.synchronize()
    }
    
    class func disabledPromptRateApp() -> (Bool) {
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.PREFERENCE_ENABLED_PROMPT_RATE_APP)
    }
    
    class func setDisabledPromptRateApp(_ disabled:Bool) -> () {
        UserDefaults.standard.set(disabled ,forKey:CLASS_STATIC.PREFERENCE_ENABLED_PROMPT_RATE_APP)
        UserDefaults.standard.synchronize()
    }
    
    class func hasRatedOnce() -> (Bool) {
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.PREFERENCE_RATED_ONCE)
    }
    
    class func setHasRatedOnce() -> () {
        UserDefaults.standard.set(true ,forKey:CLASS_STATIC.PREFERENCE_RATED_ONCE)
        UserDefaults.standard.synchronize()
    }
    
    class func enabledInAppSettingsKitDynamicFee() -> (Bool){
        return UserDefaults.standard.bool(forKey: CLASS_STATIC.INAPPSETTINGS_KIT_ENABLE_DYNAMIC_FEE)
    }
    
    class func setInAppSettingsKitEnabledDynamicFee(_ enabled:Bool) -> () {
        UserDefaults.standard.set(enabled ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_ENABLE_DYNAMIC_FEE)
        UserDefaults.standard.synchronize()
    }

    //WARNING: TLDynamicFeeSetting, therefore InAppSettingsKit must match the keys for 21's dynamic fee api return object keys called in TLTxFeeAPI
    class func getInAppSettingsKitDynamicFeeSetting() -> TLDynamicFeeSetting {
        if let fee = UserDefaults.standard.string(forKey: CLASS_STATIC.INAPPSETTINGS_KIT_DYNAMIC_FEE_OPTION) {
            return TLDynamicFeeSetting(rawValue:fee)!
        } else {
            return TLDynamicFeeSetting.FastestFee
        }
    }
    
    class func setInAppSettingsKitDynamicFeeSettingIdx(_ dynamicFeeSetting:TLDynamicFeeSetting) -> () {
        UserDefaults.standard.set(dynamicFeeSetting.rawValue ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_DYNAMIC_FEE_OPTION)
        UserDefaults.standard.synchronize()
    }
}
