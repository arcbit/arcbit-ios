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
        static let PREFERENCE_WALLET_ADVANCE_MODE = "pref-advance-mode"
        static let PREFERENCE_DISPLAY_LOCAL_CURRENCY = "pref-display-local-currency"
        static let PREFERENCE_AUTOMATIC_FEE = "pref-automatic-fee"
        static let PREFERENCE_FEE_AMOUNT = "pref-fee-amount"
        static let PREFERENCE_SUGGESTIONS_DICT = "pref-suggestions-dict"
        static let PREFERENCE_ANALYTICS_DICT = "pref-analytics-dict"
        static let PREFERENCE_SEND_FROM_TYPE = "pref-send-from-type"
        static let PREFERENCE_SEND_FROM_INDEX = "pref-send-from-index"
        static let PREFERENCE_HAS_SETUP_HDWALLET = "pref-has-setup-hdwallet"
        static let PREFERENCE_ENABLE_STEALTH_ADDRESS_DEFAULT = "pref-enable-stealth-address-default"
        static let PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE = "pref-encrypted-backup-passphrase"
        static let PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE_KEY = "pref-encrypted-backup-passphrase-key"
    }
    
    class func setHasSetupHDWallet(enabled:Bool) -> () {
        NSUserDefaults.standardUserDefaults().setBool(enabled ,forKey:CLASS_STATIC.PREFERENCE_HAS_SETUP_HDWALLET)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func hasSetupHDWallet() -> (Bool) {
        return NSUserDefaults.standardUserDefaults().boolForKey(CLASS_STATIC.PREFERENCE_HAS_SETUP_HDWALLET)
    }
    
    class func setInstallDate() -> () {
        if(NSUserDefaults.standardUserDefaults().objectForKey(CLASS_STATIC.PREFERENCE_INSTALL_DATE) == nil) {
            NSUserDefaults.standardUserDefaults().setObject(NSDate() ,forKey:CLASS_STATIC.PREFERENCE_INSTALL_DATE)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    class func getInstallDate() -> (String?) {
        let joined = NSUserDefaults.standardUserDefaults().objectForKey(CLASS_STATIC.PREFERENCE_INSTALL_DATE) as! NSDate?
        if(joined == nil) {
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        return dateFormatter.stringFromDate(joined!)
    }
    
    class func getAppVersion() -> String {
        let ver = NSUserDefaults.standardUserDefaults().stringForKey(CLASS_STATIC.PREFERENCE_APP_VERSION)
        return ver != nil ? ver! : "0";
    }
    
    class func setAppVersion(version: String) -> () {
        NSUserDefaults.standardUserDefaults().setObject(version, forKey:CLASS_STATIC.PREFERENCE_APP_VERSION)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getCurrencyIdx() -> (String?) {
        return NSUserDefaults.standardUserDefaults().stringForKey(CLASS_STATIC.PREFERENCE_FIAT_DISPLAY)
    }
    
    class func setCurrency(currencyIdx:String) -> () {
        NSUserDefaults.standardUserDefaults().setObject(currencyIdx ,forKey:CLASS_STATIC.PREFERENCE_FIAT_DISPLAY)
        NSUserDefaults.standardUserDefaults().synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_PREFERENCES_FIAT_DISPLAY_CHANGED(), object:nil, userInfo:nil)
    }
    
    class func getBitcoinDenomination() -> (TLBitcoinDenomination) {
        let value = NSUserDefaults.standardUserDefaults().stringForKey(CLASS_STATIC.PREFERENCE_BITCOIN_DISPLAY) as NSString?
        if(value == nil) {
            return TLBitcoinDenomination(rawValue: 0)!
        }
        return TLBitcoinDenomination(rawValue: value!.integerValue)!
    }
    
    class func setBitcoinDisplay(bitcoinDisplayIdx:String) -> (){
        NSUserDefaults.standardUserDefaults().setObject(bitcoinDisplayIdx ,forKey:CLASS_STATIC.PREFERENCE_BITCOIN_DISPLAY)
        NSUserDefaults.standardUserDefaults().synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_PREFERENCES_BITCOIN_DISPLAY_CHANGED()
            ,object:nil, userInfo:nil)
    }
    
    class func getSendFromType() -> (TLSendFromType) {
        return TLSendFromType(rawValue:NSUserDefaults.standardUserDefaults().integerForKey(CLASS_STATIC.PREFERENCE_SEND_FROM_TYPE))!
    }
    
    class func setSendFromType(sendFromType:TLSendFromType) -> () {
        NSUserDefaults.standardUserDefaults().setInteger(sendFromType.rawValue ,forKey:CLASS_STATIC.PREFERENCE_SEND_FROM_TYPE)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getSendFromIndex() -> (UInt) {
        return UInt(NSUserDefaults.standardUserDefaults().integerForKey(CLASS_STATIC.PREFERENCE_SEND_FROM_INDEX))
    }
    
    class func setSendFromIndex(sendFromIndex:UInt) -> () {
        NSUserDefaults.standardUserDefaults().setInteger(Int(sendFromIndex) ,forKey:CLASS_STATIC.PREFERENCE_SEND_FROM_INDEX)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    class func getBlockExplorerAPI() -> (TLBlockExplorer) {
        let value = NSUserDefaults.standardUserDefaults().stringForKey(CLASS_STATIC.PREFERENCE_BLOCKEXPLORER_API) as NSString?
        if(value == nil) {
            return TLBlockExplorer(rawValue: 0)!
        }
        return TLBlockExplorer(rawValue: value!.integerValue)!
    }
    
    class func setBlockExplorerAPI(blockexplorerIdx:String) -> () {
        NSUserDefaults.standardUserDefaults().setObject(blockexplorerIdx ,forKey:CLASS_STATIC.PREFERENCE_BLOCKEXPLORER_API)
        NSUserDefaults.standardUserDefaults().synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_PREFERENCES_BLOCKEXPLORER_API_CHANGED(),
            object:nil, userInfo:nil)
    }
    
    class func getBlockExplorerURL(blockExplorer:TLBlockExplorer) -> (String?) {
        let blockExplorer2blockExplorerURLDict = NSUserDefaults.standardUserDefaults().objectForKey(CLASS_STATIC.PREFERENCE_BLOCKEXPLORER_API_URL_DICT) as! NSDictionary
        let key = String(format:"%ld", blockExplorer.rawValue)
        return blockExplorer2blockExplorerURLDict.valueForKey(key) as? String
    }
    
    class func setBlockExplorerURL(blockExplorer:TLBlockExplorer, value:(String)) -> (){
        assert(blockExplorer == TLBlockExplorer.Insight, "can only change insight URL currently")
        let blockExplorer2blockExplorerURLDict = (NSUserDefaults.standardUserDefaults().objectForKey(CLASS_STATIC.PREFERENCE_BLOCKEXPLORER_API_URL_DICT) as! NSDictionary).mutableCopy() as! NSDictionary
        blockExplorer2blockExplorerURLDict.setValue(value ,forKey:String(format:"%ld", blockExplorer.rawValue))
        NSUserDefaults.standardUserDefaults().setObject(blockExplorer2blockExplorerURLDict ,forKey:CLASS_STATIC.PREFERENCE_BLOCKEXPLORER_API_URL_DICT)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func resetBlockExplorerAPIURL() -> (){
        let blockExplorer2blockExplorerURLDict = NSMutableDictionary(capacity: 3)
        blockExplorer2blockExplorerURLDict.setObject("https://blockchain.info/" ,forKey:String(format:"%ld", TLBlockExplorer.Blockchain.rawValue))
        blockExplorer2blockExplorerURLDict.setObject("https://insight.bitpay.com/" ,forKey:String(format:"%ld", TLBlockExplorer.Insight.rawValue))
        blockExplorer2blockExplorerURLDict.setObject("https://bitcoin.toshi.io/" ,forKey:String(format:"%ld", TLBlockExplorer.Toshi.rawValue))
        NSUserDefaults.standardUserDefaults().setObject(blockExplorer2blockExplorerURLDict ,forKey:CLASS_STATIC.PREFERENCE_BLOCKEXPLORER_API_URL_DICT)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getStealthExplorerURL() -> (String?) {
        return NSUserDefaults.standardUserDefaults().stringForKey(CLASS_STATIC.INAPPSETTINGS_KIT_STEALTH_EXPLORER_URL)
    }
    
    class func setStealthExplorerURL(value:(String)) -> () {
        NSUserDefaults.standardUserDefaults().setObject(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_STEALTH_EXPLORER_URL)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getStealthServerPort() -> (Int?) {
        return NSUserDefaults.standardUserDefaults().integerForKey(CLASS_STATIC.INAPPSETTINGS_KIT_STEALTH_SERVER_PORT)
    }
    
    class func setStealthServerPort(value:(Int)) -> () {
        NSUserDefaults.standardUserDefaults().setObject(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_STEALTH_SERVER_PORT)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getStealthWebSocketPort() -> (Int?) {
        return NSUserDefaults.standardUserDefaults().integerForKey(CLASS_STATIC.INAPPSETTINGS_KIT_STEALTH_WEB_SOCKET_PORT)
    }
    
    class func setStealthWebSocketPort(value:(Int)) -> () {
        NSUserDefaults.standardUserDefaults().setObject(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_STEALTH_WEB_SOCKET_PORT)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func resetStealthExplorerAPIURL() -> () {
        self.setStealthExplorerURL(TLStealthServerConfig.instance().getStealthServerUrl())
    }
    
    class func resetStealthServerPort() -> () {
        self.setStealthServerPort(TLStealthServerConfig.instance().getStealthServerPort())
    }
    
    class func resetStealthWebSocketPort() -> () {
        self.setStealthServerPort(TLStealthServerConfig.instance().getWebSocketServerPort())
    }
    
    class func getInAppSettingsKitBlockExplorerAPI() -> (String?){
        return NSUserDefaults.standardUserDefaults().stringForKey(CLASS_STATIC.INAPPSETTINGS_KIT_BLOCKEXPLORER_API)
    }
    
    class func setInAppSettingsKitBlockExplorerAPI(value:String) -> () {
        NSUserDefaults.standardUserDefaults().setObject(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_BLOCKEXPLORER_API)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getInAppSettingsKitBlockExplorerURL() -> (String?) {
        return NSUserDefaults.standardUserDefaults().stringForKey(CLASS_STATIC.INAPPSETTINGS_KIT_BLOCKEXPLORER_URL)
    }
    
    class func setInAppSettingsKitBlockExplorerURL(value: String) -> (){
        NSUserDefaults.standardUserDefaults().setObject(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_BLOCKEXPLORER_URL)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getInAppSettingsKitCurrencyIdx() -> (String?) {
        return NSUserDefaults.standardUserDefaults().stringForKey(CLASS_STATIC.INAPPSETTINGS_KIT_RECEIVING_CURRENCY)
    }
    
    class func setInAppSettingsKitCurrency(currencyIdx:String) -> () {
        NSUserDefaults.standardUserDefaults().setObject(currencyIdx, forKey:CLASS_STATIC.INAPPSETTINGS_KIT_RECEIVING_CURRENCY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func isInAppSettingsKitDisplayLocalCurrency() -> (Bool) {
        return NSUserDefaults.standardUserDefaults().boolForKey(CLASS_STATIC.INAPPSETTINGS_KIT_DISPLAY_LOCAL_CURRENCY)
    }
    
    class func setInAppSettingsKitDisplayLocalCurrency(enabled:Bool) -> () {
        NSUserDefaults.standardUserDefaults().setBool(enabled ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_DISPLAY_LOCAL_CURRENCY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getInAppSettingsKitName() -> (String?) {
        return NSUserDefaults.standardUserDefaults().stringForKey(CLASS_STATIC.INAPPSETTINGS_KIT_NAME)
    }
    
    class func setInAppSettingsKitName(value:String) -> () {
        NSUserDefaults.standardUserDefaults().setObject(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_NAME)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getInAppSettingsKitEnablePinCode() -> (Bool) {
        return NSUserDefaults.standardUserDefaults().boolForKey(CLASS_STATIC.INAPPSETTINGS_KIT_ENABLE_PIN_CODE)
    }
    
    class func setInAppSettingsKitEnablePinCode(value:Bool) -> () {
        NSUserDefaults.standardUserDefaults().setBool(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_ENABLE_PIN_CODE)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getInAppSettingsKitTransactionFee() -> (String?) {
        return NSUserDefaults.standardUserDefaults().stringForKey(CLASS_STATIC.INAPPSETTINGS_KIT_TRANSACTION_FEE)
    }
    
    class func setInAppSettingsKitTransactionFee(value:String) -> () {
        NSUserDefaults.standardUserDefaults().setObject(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_TRANSACTION_FEE)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getInAppSettingsKitEnableBackupWithiCloud() -> (Bool) {
        return NSUserDefaults.standardUserDefaults().boolForKey(CLASS_STATIC.INAPPSETTINGS_KIT_ENABLE_BACKUP_WITH_ICLOUD)
    }
    
    class func setInAppSettingsKitEnableBackupWithiCloud(value:Bool) -> () {
        NSUserDefaults.standardUserDefaults().setBool(value ,forKey:CLASS_STATIC.INAPPSETTINGS_KIT_ENABLE_BACKUP_WITH_ICLOUD)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getEnableBackupWithiCloud() -> (Bool) {
        return NSUserDefaults.standardUserDefaults().boolForKey(CLASS_STATIC.PREFERENCE_ENABLE_BACKUP_WITH_ICLOUD)
    }
    
    class func setEnableBackupWithiCloud(value:Bool) -> () {
        NSUserDefaults.standardUserDefaults().setBool(value ,forKey:CLASS_STATIC.PREFERENCE_ENABLE_BACKUP_WITH_ICLOUD)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func deleteAllKeychainItems() -> () {
        JNKeychain.deleteValueForKey(CLASS_STATIC.PREFERENCE_CLOUD_BACKUP_WALLET_FILE_NAME)
        JNKeychain.deleteValueForKey(CLASS_STATIC.PREFERENCE_WALLET_PASSPHRASE)
        JNKeychain.deleteValueForKey(CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_PASSPHRASE)
        JNKeychain.deleteValueForKey(CLASS_STATIC.PREFERENCE_CAN_RESTORE_DELETED_APP)
    }
    
    class func getCloudBackupWalletFileName() -> (String?) {
        //CLASS_STATIC.RESET_CLOUD_BACKUP_WALLET_FILE_NAME = true // debug only, to reset cloud backup file name install fresh app with this set once, and comment out again
        if (CLASS_STATIC.RESET_CLOUD_BACKUP_WALLET_FILE_NAME) {
            return nil
        }
        return JNKeychain.loadValueForKey(CLASS_STATIC.PREFERENCE_CLOUD_BACKUP_WALLET_FILE_NAME) as! String?
    }
    
    class func setCloudBackupWalletFileName() -> (){
        if (JNKeychain.loadValueForKey(CLASS_STATIC.PREFERENCE_CLOUD_BACKUP_WALLET_FILE_NAME) != nil && !CLASS_STATIC.RESET_CLOUD_BACKUP_WALLET_FILE_NAME) {
            NSException(name:"Cannot set cloud backup wallet file name", reason:"Cloud backup wallet file name is already set", userInfo:nil).raise()
        }
        let cloudBackupWalletFileName = String(format:"%@.%@.%@", TLWalletUtils.STATIC_MEMBERS.WALLET_JSON_CLOUD_BACKUP_FILE_NAME,
            TLStealthAddress.generateEphemeralPrivkey(), TLWalletUtils.STATIC_MEMBERS.WALLET_JSON_CLOUD_BACKUP_FILE_EXTENSION)
        DLog("cloudBackupWalletFileName %@", function: cloudBackupWalletFileName)
        JNKeychain.saveValue(cloudBackupWalletFileName ,forKey:CLASS_STATIC.PREFERENCE_CLOUD_BACKUP_WALLET_FILE_NAME)
    }
    
    class func deleteWalletPassphrase()  -> (){
        JNKeychain.deleteValueForKey(CLASS_STATIC.PREFERENCE_WALLET_PASSPHRASE)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(CLASS_STATIC.PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getWalletPassphrase(useKeychain:Bool)  -> (String?){
        if useKeychain {
            return JNKeychain.loadValueForKey(CLASS_STATIC.PREFERENCE_WALLET_PASSPHRASE) as! String?
        } else {
            return NSUserDefaults.standardUserDefaults().stringForKey(CLASS_STATIC.PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE)
        }
    }
    
    class func setWalletPassphrase(value:String, useKeychain:Bool)  -> (){
        if useKeychain {
            JNKeychain.saveValue(value ,forKey:CLASS_STATIC.PREFERENCE_WALLET_PASSPHRASE)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(CLASS_STATIC.PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE)
            NSUserDefaults.standardUserDefaults().synchronize()
        } else {
            NSUserDefaults.standardUserDefaults().setObject(value ,forKey:CLASS_STATIC.PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE)
            NSUserDefaults.standardUserDefaults().synchronize()
            JNKeychain.deleteValueForKey(CLASS_STATIC.PREFERENCE_WALLET_PASSPHRASE)
        }
    }
    class func deleteEncryptedWalletJSONPassphrase()  -> (){
        JNKeychain.deleteValueForKey(CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_PASSPHRASE)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(CLASS_STATIC.PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    class func getEncryptedWalletPassphraseKey() -> (String?) {
        return NSUserDefaults.standardUserDefaults().stringForKey(CLASS_STATIC.PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE_KEY)
    }
    
    class func setEncryptedWalletPassphraseKey(value:String)  -> (){
        NSUserDefaults.standardUserDefaults().setObject(value ,forKey:CLASS_STATIC.PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func clearEncryptedWalletPassphraseKey() -> () {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(CLASS_STATIC.PREFERENCE_ENCRYPTED_BACKUP_PASSPHRASE_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func setCanRestoreDeletedApp(enabled:Bool)  -> (){
        if (enabled) {
            JNKeychain.saveValue("true" ,forKey:CLASS_STATIC.PREFERENCE_CAN_RESTORE_DELETED_APP)
        } else {
            JNKeychain.saveValue("false" ,forKey:CLASS_STATIC.PREFERENCE_CAN_RESTORE_DELETED_APP)
        }
    }
    
    class func canRestoreDeletedApp() -> (Bool) {
        let enabled = JNKeychain.loadValueForKey(CLASS_STATIC.PREFERENCE_CAN_RESTORE_DELETED_APP) as! NSString?
        return enabled == "true" ? true : false
    }
    
    class func getInAppSettingsKitcanRestoreDeletedApp() -> (Bool) {
        return NSUserDefaults.standardUserDefaults().boolForKey(CLASS_STATIC.INAPPSETTINGS_CAN_RESTORE_DELETED_APP)
    }
    
    class func setInAppSettingsCanRestoreDeletedApp(value: Bool) -> () {
        NSUserDefaults.standardUserDefaults().setBool(value ,forKey:CLASS_STATIC.INAPPSETTINGS_CAN_RESTORE_DELETED_APP)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getEnableSoundNotification() -> (Bool) {
        return NSUserDefaults.standardUserDefaults().boolForKey(CLASS_STATIC.INAPPSETTINGS_ENABLE_SOUND_NOTIFICATION)
    }
    
    class func setEnableSoundNotification(value:Bool) -> () {
        NSUserDefaults.standardUserDefaults().setBool(value ,forKey:CLASS_STATIC.INAPPSETTINGS_ENABLE_SOUND_NOTIFICATION)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getEncryptedWalletJSONPassphrase(useKeychain:Bool) -> (String?){
        if useKeychain {
            return JNKeychain.loadValueForKey(CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_PASSPHRASE) as! String?
        } else {
            return NSUserDefaults.standardUserDefaults().stringForKey(CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_PASSPHRASE) as String?
        }
    }
    
    class func setEncryptedWalletJSONPassphrase(value: String, useKeychain:Bool) -> () {
        if useKeychain {
            JNKeychain.saveValue(value ,forKey:CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_PASSPHRASE)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_PASSPHRASE)
            NSUserDefaults.standardUserDefaults().synchronize()
        } else {
            NSUserDefaults.standardUserDefaults().setObject(value ,forKey:CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_PASSPHRASE)
            NSUserDefaults.standardUserDefaults().synchronize()
            JNKeychain.deleteValueForKey(CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_PASSPHRASE)
        }
    }
    
    class func getEncryptedWalletJSONChecksum() -> (String?) {
        return NSUserDefaults.standardUserDefaults().stringForKey(CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_CHECKSUM) as String?
    }
    
    class func setEncryptedWalletJSONChecksum(value:String) -> (){
        NSUserDefaults.standardUserDefaults().setObject(value ,forKey:CLASS_STATIC.PREFERENCE_ENCRYPTED_WALLET_JSON_CHECKSUM)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getLastSavedEncryptedWalletJSONDate() -> (NSDate) {
        return NSUserDefaults.standardUserDefaults().objectForKey(CLASS_STATIC.PREFERENCE_LAST_SAVED_ENCRYPTED_WALLET_JSON_DATE) as! NSDate
    }
    
    class func setLastSavedEncryptedWalletJSONDate(value:NSDate) -> () {
        NSUserDefaults.standardUserDefaults().setObject(value ,forKey:CLASS_STATIC.PREFERENCE_LAST_SAVED_ENCRYPTED_WALLET_JSON_DATE)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func isDisplayLocalCurrency() ->(Bool){
        return NSUserDefaults.standardUserDefaults().boolForKey(CLASS_STATIC.PREFERENCE_DISPLAY_LOCAL_CURRENCY)
    }
    
    class func setDisplayLocalCurrency(enabled:Bool) -> () {
        NSUserDefaults.standardUserDefaults().setBool(enabled ,forKey:CLASS_STATIC.PREFERENCE_DISPLAY_LOCAL_CURRENCY)
        NSUserDefaults.standardUserDefaults().synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED(), object:nil)
    }
    
    class func enabledAdvancedMode() -> (Bool) {
        return NSUserDefaults.standardUserDefaults().boolForKey(CLASS_STATIC.PREFERENCE_WALLET_ADVANCE_MODE)
    }
    
    class func setAdvancedMode(enabled:Bool) -> () {
        NSUserDefaults.standardUserDefaults().setBool(enabled ,forKey:CLASS_STATIC.PREFERENCE_WALLET_ADVANCE_MODE)
        NSUserDefaults.standardUserDefaults().synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_ADVANCE_MODE_TOGGLED(), object:enabled)
    }
    
    class func isEnablePINCode() -> (Bool) {
        return NSUserDefaults.standardUserDefaults().boolForKey(CLASS_STATIC.PREFERENCE_ENABLE_PIN_CODE)
    }
    
    class func setEnablePINCode(enabled:Bool) -> () {
        NSUserDefaults.standardUserDefaults().setBool(enabled ,forKey:CLASS_STATIC.PREFERENCE_ENABLE_PIN_CODE)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func isAutomaticFee() -> (Bool) {
        return NSUserDefaults.standardUserDefaults().boolForKey(CLASS_STATIC.PREFERENCE_AUTOMATIC_FEE)
    }
    
    class func setIsAutomaticFee(enabled:Bool) -> () {
        NSUserDefaults.standardUserDefaults().setBool(enabled ,forKey:CLASS_STATIC.PREFERENCE_AUTOMATIC_FEE)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getSuggestionsDict() -> (NSDictionary?){
        return NSUserDefaults.standardUserDefaults().objectForKey(CLASS_STATIC.PREFERENCE_SUGGESTIONS_DICT) as! NSDictionary?
    }
    
    class func setSuggestionsDict(value:NSDictionary) -> () {
        NSUserDefaults.standardUserDefaults().setObject(value ,forKey:CLASS_STATIC.PREFERENCE_SUGGESTIONS_DICT)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getAnalyticsDict() -> (NSDictionary?) {
        return NSUserDefaults.standardUserDefaults().objectForKey(CLASS_STATIC.PREFERENCE_ANALYTICS_DICT) as! NSDictionary?
    }
    
    class func setAnalyticsDict(value:NSDictionary) -> (){
        NSUserDefaults.standardUserDefaults().setObject(value ,forKey:CLASS_STATIC.PREFERENCE_ANALYTICS_DICT)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func enabledStealthAddressDefault() -> (Bool){
        return NSUserDefaults.standardUserDefaults().boolForKey(CLASS_STATIC.PREFERENCE_ENABLE_STEALTH_ADDRESS_DEFAULT)
    }
    
    class func setEnabledStealthAddressDefault(enabled:Bool) -> () {
        NSUserDefaults.standardUserDefaults().setBool(enabled ,forKey:CLASS_STATIC.PREFERENCE_ENABLE_STEALTH_ADDRESS_DEFAULT)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}