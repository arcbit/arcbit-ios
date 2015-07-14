//
//  TLWallet.swift
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

enum TLAccount:Int {
    case Normal       = 0
    case Multisig     = 1
}

enum TLAddressStatus:Int {
    case Archived = 0 //archived: passed window
    case Active = 1
}

enum TLAddressType:Int {
    case Main = 0
    case Change = 1
    case Stealth = 2
}

enum TLStealthPaymentStatus:Int {
    case Unspent = 0 // >=0 confirmations for payment tx
    case Claimed = 1 // 0-5 confirmations for payment tx and >=0 confirm for claimed tx
    case Spent = 2 // > 6 confirmations for payment tx and >=0 confirm for claimed tx
}


@objc class TLWallet {
    
    class func WALLET_PAYLOAD_KEY_LABEL() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL
    }
    
    class func WALLET_PAYLOAD_KEY_ADDRESS() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS
    }
    
    class func WALLET_PAYLOAD_KEY_KEY() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_KEY_KEY
    }
    
    class func WALLET_PAYLOAD_KEY_STATUS() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS
    }
    class func WALLET_PAYLOAD_KEY_MAIN_ADDRESSES() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES
    }
    class func WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX
    }
    class func WALLET_PAYLOAD_KEY_INDEX() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX
    }
    class func EVENT_WALLET_PAYLOAD_UPDATED() -> (String)
    {
        return STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED
    }
    class func WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX
    }
    class func WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES
    }
    class func WALLET_PAYLOAD_KEY_NAME() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME
    }
    class func WALLET_PAYLOAD_ACCOUNT_IDX() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX
    }
    class func WALLET_PAYLOAD_EXTENDED_PRIVATE_KEY() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PRIVATE_KEY
    }
    class func WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY
    }
    class func WALLET_PAYLOAD_KEY_STEALTH_ADDRESS_SPEND_KEY() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESS_SPEND_KEY
    }
    class func WALLET_PAYLOAD_KEY_STEALTH_ADDRESS() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESS
    }
    class func WALLET_PAYLOAD_KEY_PAYMENTS() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYMENTS
    }
    class func WALLET_PAYLOAD_KEY_STEALTH_ADDRESS_SCAN_KEY() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESS_SCAN_KEY
    }
    class func WALLET_PAYLOAD_KEY_WATCHING() -> (String)
    {
        return STATIC_MEMBERS.WALLET_PAYLOAD_KEY_WATCHING
    }

    
    struct STATIC_MEMBERS {
        static let STEALTH_PAYMENTS_FETCH_COUNT = 50

        static let EVENT_WALLET_PAYLOAD_UPDATED = "event.wallet.payload.updated"

        static let WALLET_PAYLOAD_VERSION = "1"
        static let WALLET_PAYLOAD_KEY_VERSION = "version"
        static let WALLET_PAYLOAD_KEY_PAYLOAD = "payload"
        static let WALLET_PAYLOAD_KEY_WALLETS = "wallets"
        static let WALLET_PAYLOAD_KEY_HDWALLETS = "hd_wallets"
        static let WALLET_PAYLOAD_KEY_ACCOUNTS = "accounts"
        static let WALLET_PAYLOAD_CURRENT_ACCOUNT_ID = "current_account_id"
        static let WALLET_PAYLOAD_IMPORTS = "imports"
        static let WALLET_PAYLOAD_IMPORTED_ACCOUNTS = "imported_accounts"
        static let WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS = "watch_only_accounts"
        static let WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS = "imported_private_keys"
        static let WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES = "watch_only_addresses"
        static let WALLET_PAYLOAD_ACCOUNT_IDX = "account_idx"
        static let WALLET_PAYLOAD_EXTENDED_PRIVATE_KEY = "xprv"
        static let WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY = "xpub"
        static let WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING = "needs_recovering"
        static let WALLET_PAYLOAD_KEY_MAIN_ADDRESSES = "main_addresses"
        static let WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES = "change_addresses"
        static let WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES = "stealth_addresses"
        static let WALLET_PAYLOAD_KEY_STEALTH_ADDRESS = "stealth_address"
        static let WALLET_PAYLOAD_KEY_STEALTH_ADDRESS_SCAN_KEY = "scan_key"
        static let WALLET_PAYLOAD_KEY_STEALTH_ADDRESS_SPEND_KEY = "spend_key"
        static let WALLET_PAYLOAD_KEY_PAYMENTS = "payments"
        static let WALLET_PAYLOAD_KEY_SERVERS = "servers"
        static let WALLET_PAYLOAD_KEY_WATCHING = "watching"
        static let WALLET_PAYLOAD_KEY_TXID = "txid"
        static let WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX = "min_main_address_idx"
        static let WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX = "min_change_address_vidx"
        static let WALLET_PAYLOAD_KEY_TIME = "time"
        static let WALLET_PAYLOAD_KEY_CHECK_TIME = "check_time"
        static let WALLET_PAYLOAD_KEY_LAST_TX_TIME = "last_tx_time"
        static let WALLET_PAYLOAD_KEY_KEY = "key"
        static let WALLET_PAYLOAD_KEY_ADDRESS = "address"
        static let WALLET_PAYLOAD_KEY_STATUS = "status"
        static let WALLET_PAYLOAD_KEY_INDEX = "index"
        static let WALLET_PAYLOAD_KEY_LABEL = "label"
        static let WALLET_PAYLOAD_KEY_NAME = "name"
        static let WALLET_PAYLOAD_KEY_MAX_ACCOUNTS_CREATED = "max_account_id_created"
        static let WALLET_PAYLOAD_KEY_MASTER_HEX = "master_hex"
        static let WALLET_PAYLOAD_KEY_PASSPHRASE = "passphrase"
        static let WALLET_PAYLOAD_KEY_ADDRESS_BOOK = "address_book"
        static let WALLET_PAYLOAD_KEY_TRANSACTION_TAGS = "tx_tags"
        
        static let STEALTH_ADDRESS_ADDRESSES_MAX = 100
        static var _instance: TLWallet? = nil
    }
    
    private var walletName: String?
    private var rootDict: NSMutableDictionary?
    private var currentHDWalletIdx: Int?
    private var masterHex: String?
    
    class func createAddressKey(changeIdx: Int, addressIdx: Int) -> String {
        return String(format: "%lu,%lu", changeIdx, addressIdx)
    }
    
    private func createAccountDict(accountName: String, extendedKey: String,
        isPrivateExtendedKey: Bool, accountIdx: Int) -> (NSMutableDictionary) {
            return createAccountDictWithPreload(accountName, extendedKey: extendedKey, isPrivateExtendedKey: isPrivateExtendedKey,
                accountIdx: accountIdx, preloadStartingAddresses: true)
    }
    
    
    init(walletName: String) {
        self.walletName = walletName
        currentHDWalletIdx = 0
    }
    
    //----------------------------------------------------------------------------------------------------------------
    
    private func createStealthAddressDict(extendKey: String, isPrivateExtendedKey: (Bool)) -> (NSMutableDictionary) {
        assert(isPrivateExtendedKey == true, "Cant generate stealth address scan key from xpub key")
        let stealthAddressDict = NSMutableDictionary()
        let stealthAddressObject = TLHDWalletWrapper.getStealthAddress(extendKey, isTestnet: TLWalletUtils.STATIC_MEMBERS.IS_TESTNET)
        stealthAddressDict.setObject((stealthAddressObject.objectForKey("stealthAddress"))!, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESS)
        stealthAddressDict.setObject((stealthAddressObject.objectForKey("scanPriv"))!, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESS_SCAN_KEY)
        stealthAddressDict.setObject((stealthAddressObject.objectForKey("spendPriv"))!, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESS_SPEND_KEY)
        stealthAddressDict.setObject(NSMutableDictionary(), forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_SERVERS)
        stealthAddressDict.setObject(NSMutableArray(), forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYMENTS)
        stealthAddressDict.setObject(NSNumber(unsignedLongLong: 0), forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LAST_TX_TIME)
        return stealthAddressDict
    }
    
    private func createAccountDictWithPreload(accountName: String, extendedKey: String,
        isPrivateExtendedKey: Bool, accountIdx: Int,
        preloadStartingAddresses: Bool) -> (NSMutableDictionary) {
            
            let account = NSMutableDictionary()
            account.setObject(accountName, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME)
            account.setObject(accountIdx, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX)
            
            if (isPrivateExtendedKey) {
                let extendedPublickey = TLHDWalletWrapper.getExtendPubKey(extendedKey)
                account.setObject(extendedPublickey, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY)
                account.setObject(extendedKey, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PRIVATE_KEY)
                
                let stealthAddressesArray = NSMutableArray()
                
                let stealthAddressDict = createStealthAddressDict(extendedKey, isPrivateExtendedKey: isPrivateExtendedKey)
                stealthAddressesArray.addObject(stealthAddressDict)
                
                account.setObject(stealthAddressesArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES)
            } else {
                account.setObject(extendedKey, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY)
            }
            
            account.setValue(TLAddressStatus.Active.rawValue, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
            account.setObject(true, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING)
            
            let mainAddressesArray = NSMutableArray()
            account.setObject(mainAddressesArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES)
            
            let changeAddressesArray = NSMutableArray()
            account.setObject(changeAddressesArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES)
            
            account.setObject(0, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX)
            account.setObject(0, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX)
            
            if (!preloadStartingAddresses) {
                return account
            }
            
            //create initial receiving address
            for (var i = 0; i < TLAccountObject.MAX_ACCOUNT_WAIT_TO_RECEIVE_ADDRESS(); i++) {
                let mainAddressDict = NSMutableDictionary()
                let mainAddressIdx = i
                let mainAddressSequence = [TLAddressType.Main.rawValue, (mainAddressIdx)]
                
                let extendedPublicKey = account.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY) as! String
                let address = TLHDWalletWrapper.getAddress(extendedPublicKey, sequence: mainAddressSequence)
                mainAddressDict.setObject(address, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS)
                mainAddressDict.setObject(TLAddressStatus.Active.rawValue, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
                mainAddressDict.setObject(i, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX)
                
                mainAddressesArray.addObject(mainAddressDict)
            }
            
            let changeAddressDict = NSMutableDictionary()
            let changeAddressIdx = 0
            let changeAddressSequence = [TLAddressType.Change.rawValue, changeAddressIdx]
            
            let extendedPublicKey = account.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY) as! String
            let address = TLHDWalletWrapper.getAddress(extendedPublicKey, sequence: changeAddressSequence)
            changeAddressDict.setObject(address, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS)
            changeAddressDict.setObject(TLAddressStatus.Active.rawValue, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
            changeAddressDict.setObject(0, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX)
            
            changeAddressesArray.addObject(changeAddressDict)
            
            return account
    }
    
    
    internal func getAccountDict(accountIdx: Int) -> (NSMutableDictionary) {
        let accountsArray = getAccountsArray()
        let accountDict = accountsArray.objectAtIndex(accountIdx) as! NSMutableDictionary
        return accountDict
    }
    
    //----------------------------------------------------------------------------------------------------------------
    
    func clearAllAddressesFromHDWallet(accountIdx: Int) -> () {
        let accountDict = getAccountDict(accountIdx)
        let mainAddressesArray = NSMutableArray()
        accountDict.setObject(mainAddressesArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES)
        let changeAddressesArray = NSMutableArray()
        accountDict.setObject(changeAddressesArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES)
        accountDict.setObject(0, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX)
        accountDict.setObject(0, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX)
        
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func clearAllAddressesFromImportedAccount(idx: Int) -> () {
        let accountDict = getImportedAccountAtIndex(idx)
        let mainAddressesArray = NSMutableArray()
        accountDict.setObject(mainAddressesArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES)
        let changeAddressesArray = NSMutableArray()
        accountDict.setObject(changeAddressesArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES)
        accountDict.setObject(0, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX)
        accountDict.setObject(0, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func clearAllAddressesFromImportedWatchAccount(idx: Int) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        let mainAddressesArray = NSMutableArray()
        accountDict.setObject(mainAddressesArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES)
        let changeAddressesArray = NSMutableArray()
        accountDict.setObject(changeAddressesArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES)
        accountDict.setObject(0, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX)
        accountDict.setObject(0, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    //----------------------------------------------------------------------------------------------------------------
    func updateAccountNeedsRecoveringFromHDWallet(accountIdx: Int, accountNeedsRecovering: Bool) -> () {
        let accountDict = getAccountDict(accountIdx)
        accountDict.setObject(accountNeedsRecovering, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func updateAccountNeedsRecoveringFromImportedAccount(idx: Int, accountNeedsRecovering: Bool) -> () {
        let accountDict = getImportedAccountAtIndex(idx)
        accountDict.setObject(accountNeedsRecovering, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func updateAccountNeedsRecoveringFromImportedWatchAccount(idx: Int, accountNeedsRecovering: Bool) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        accountDict.setObject(accountNeedsRecovering, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    //----------------------------------------------------------------------------------------------------------------
    
    
    func updateMainAddressStatusFromHDWallet(accountIdx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            let accountDict = getAccountDict(accountIdx)
            self.updateMainAddressStatus(accountDict,
                addressIdx: addressIdx,
                addressStatus: addressStatus)
    }
    
    func updateMainAddressStatusFromImportedAccount(idx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            let accountDict = getImportedAccountAtIndex(idx)
            self.updateMainAddressStatus(accountDict,
                addressIdx: addressIdx,
                addressStatus: addressStatus)
    }
    
    func updateMainAddressStatusFromImportedWatchAccount(idx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
            self.updateMainAddressStatus(accountDict,
                addressIdx: addressIdx,
                addressStatus: addressStatus)
    }
    
    func updateMainAddressStatus(accountDict: NSMutableDictionary, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            
            let minMainAddressIdx = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX) as! UInt
            
            DLog("updateMainAddressStatus accountIdx \(accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int)")
            DLog("updateMainAddressStatus minMainAddressIdx \(minMainAddressIdx) addressIdx: \(addressIdx)")
            
            assert(UInt(addressIdx) == minMainAddressIdx, "addressIdx != minMainAddressIdx")
            accountDict.setObject((minMainAddressIdx+1), forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX)
            
            let mainAddressesArray = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES) as! NSMutableArray
            
            if (addressStatus == .Archived && !TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
                mainAddressesArray.removeObjectAtIndex(0)
            } else {
                let mainAddressDict = mainAddressesArray.objectAtIndex(addressIdx) as! NSMutableDictionary
                mainAddressDict.setObject(addressStatus.rawValue, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func updateChangeAddressStatusFromHDWallet(accountIdx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            let accountDict = getAccountDict(accountIdx)
            self.updateChangeAddressStatus(accountDict,
                addressIdx: addressIdx,
                addressStatus: addressStatus)
    }
    
    func updateChangeAddressStatusFromImportedAccount(idx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            let accountDict = getImportedAccountAtIndex(idx)
            self.updateChangeAddressStatus(accountDict,
                addressIdx: addressIdx,
                addressStatus: addressStatus)
    }
    
    func updateChangeAddressStatusFromImportedWatchAccount(idx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
            self.updateChangeAddressStatus(accountDict,
                addressIdx: addressIdx,
                addressStatus: addressStatus)
    }
    
    func updateChangeAddressStatus(accountDict: NSMutableDictionary, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            
            let minChangeAddressIdx = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX) as! UInt
            
            DLog("updateChangeAddressStatus accountIdx \(accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int)")
            DLog("updateChangeAddressStatus minChangeAddressIdx \(minChangeAddressIdx) addressIdx: \(addressIdx)")
            
            assert(UInt(addressIdx) == minChangeAddressIdx, "addressIdx != minChangeAddressIdx")
            accountDict.setObject((minChangeAddressIdx + 1), forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX)
            
            let changeAddressesArray = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES) as! NSMutableArray
            
            if (addressStatus == .Archived && !TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
                changeAddressesArray.removeObjectAtIndex(0)
            } else {
                let changeAddressDict = changeAddressesArray.objectAtIndex(addressIdx) as! NSMutableDictionary
                changeAddressDict.setObject(addressStatus.rawValue, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    //----------------------------------------------------------------------------------------------------------------
    func getMinMainAddressIdxFromHDWallet(accountIdx: Int) -> Int {
        let accountDict = getAccountDict(accountIdx)
        return self.getMinMainAddressIdx(accountDict)
    }
    
    func getMinMainAddressIdxFromImportedAccount(idx: Int) -> (Int) {
        let accountDict = getImportedAccountAtIndex(idx)
        return self.getMinMainAddressIdx(accountDict)
    }
    
    func getMinMainAddressIdxFromImportedWatchAccount(idx: Int) -> (Int) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        return self.getMinMainAddressIdx(accountDict)
    }
    
    func getMinMainAddressIdx(accountDict: NSMutableDictionary) -> (Int) {
        return accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX) as! Int
    }
    
    func getMinChangeAddressIdxFromHDWallet(accountIdx: Int) -> (Int) {
        let accountDict = getAccountDict(accountIdx)
        return self.getMinChangeAddressIdx(accountDict) as Int
    }
    
    func getMinChangeAddressIdxFromImportedAccount(idx: Int) -> (Int) {
        let accountDict = getImportedAccountAtIndex(idx)
        return self.getMinChangeAddressIdx(accountDict) as Int
    }
    
    func getMinChangeAddressIdxFromImportedWatchAccount(idx: Int) -> (Int) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        return self.getMinChangeAddressIdx(accountDict) as Int
    }
    
    func getMinChangeAddressIdx(accountDict: NSMutableDictionary) -> (Int) {
        return accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX) as! Int
    }
    
    //----------------------------------------------------------------------------------------------------------------
    
    func getNewMainAddressFromHDWallet(accountIdx: Int, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getAccountDict(accountIdx)
        return getNewMainAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    func getNewMainAddressFromImportedAccount(idx: Int, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getImportedAccountAtIndex(idx)
        return getNewMainAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    func getNewMainAddressFromImportedWatchAccount(idx: Int, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        return getNewMainAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    private func getNewMainAddress(accountDict: NSDictionary, expectedAddressIndex: Int) -> (NSDictionary) {
        let mainAddressesArray = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES) as! NSMutableArray
        
        DLog(String(format:"getNewMainAddress expectedAddressIndex %lu mainAddressesArray.count %lu", expectedAddressIndex, mainAddressesArray.count))
        
        let mainAddressIdx:Int
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            assert(expectedAddressIndex == mainAddressesArray.count, "expectedAddressIndex != _mainAddressesArray_count")
            mainAddressIdx = (expectedAddressIndex)
        } else {
            let minMainAddressIdx = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX) as! Int
            assert(expectedAddressIndex == mainAddressesArray.count + minMainAddressIdx, "expectedAddressIndex != _mainAddressesArray_count + minMainAddressIdx")
            mainAddressIdx = (expectedAddressIndex)
        }
        
        if (mainAddressIdx >= NSIntegerMax) {
            NSException(name: "Universe ended", reason: "reached max hdwallet index", userInfo: nil).raise()
            
        }
        
        let mainAddressSequence = [TLAddressType.Main.rawValue, mainAddressIdx]
        let mainAddressDict = NSMutableDictionary()
        
        let extendedPublicKey = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY) as! String
        let address = TLHDWalletWrapper.getAddress(extendedPublicKey, sequence: mainAddressSequence)
        
        mainAddressDict.setObject(address, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS)
        mainAddressDict.setObject((TLAddressStatus.Active.rawValue), forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
        mainAddressDict.setObject(mainAddressIdx, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX)
        
        mainAddressesArray.addObject(mainAddressDict)
        
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
        }
        
        return mainAddressDict
    }
    //----------------------------------------------------------------------------------------------------------------
    func getNewChangeAddressFromHDWallet(accountIdx: Int, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getAccountDict(accountIdx)
        return getNewChangeAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    func getNewChangeAddressFromImportedAccount(idx: Int, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getImportedAccountAtIndex(idx)
        return getNewChangeAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    func getNewChangeAddressFromImportedWatchAccount(idx: UInt, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(Int(idx))
        return getNewChangeAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    private func getNewChangeAddress(accountDict: NSDictionary, expectedAddressIndex: Int) -> (NSDictionary) {
        
        let changeAddressesArray = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES) as! NSMutableArray
        
        DLog(String(format: "getNewChangeAddress expectedAddressIndex %lu changeAddressesArray.count %lu", expectedAddressIndex, changeAddressesArray.count))
        
        let changeAddressIdx:Int
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            assert(expectedAddressIndex == changeAddressesArray.count, "expectedAddressIndex != [changeAddressesArray count]")
            changeAddressIdx = (changeAddressesArray.count)
        } else {
            let minChangeAddressIdx = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX) as! Int
            assert(expectedAddressIndex == changeAddressesArray.count + minChangeAddressIdx, "expectedAddressIndex != _mainAddressesArray_count + minChangeAddressIdx")
            changeAddressIdx = (expectedAddressIndex)
        }
        
        if (changeAddressIdx >= NSIntegerMax) {
            NSException(name: "Universe ended", reason: "reached max hdwallet index", userInfo: nil).raise()
        }
        
        let changeAddressSequence = [TLAddressType.Change.rawValue, changeAddressIdx]
        let changeAddressDict = NSMutableDictionary()
        
        let extendedPublicKey = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY) as! String
        let address = TLHDWalletWrapper.getAddress(extendedPublicKey, sequence: changeAddressSequence)
        changeAddressDict.setObject(address, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS)
        changeAddressDict.setObject(TLAddressStatus.Active.rawValue, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
        changeAddressDict.setObject(changeAddressIdx, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX)
        
        changeAddressesArray.addObject(changeAddressDict)
        
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
        }
        
        return changeAddressDict
    }
    
    //----------------------------------------------------------------------------------------------------------------
    func removeTopMainAddressFromHDWallet(accountIdx: Int) -> (String?) {
        let accountDict = getAccountDict(accountIdx)
        return removeTopMainAddress(accountDict)
    }
    
    func removeTopMainAddressFromImportedAccount(idx: Int) -> (String?) {
        let accountDict = getImportedAccountAtIndex(idx)
        return removeTopMainAddress(accountDict)
    }
    
    func removeTopMainAddressFromImportedWatchAccount(idx: Int) -> (String?) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        return removeTopMainAddress(accountDict)
    }
    
    private func removeTopMainAddress(accountDict: NSMutableDictionary) -> (String?) {
        let mainAddressesArray = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES) as! NSMutableArray
        if (mainAddressesArray.count > 0) {
            let mainAddressDict = mainAddressesArray.lastObject as! NSDictionary
            mainAddressesArray.removeLastObject()
            NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
            return mainAddressDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as? String
        }
        
        return nil
    }
    //----------------------------------------------------------------------------------------------------------------
    func removeTopChangeAddressFromHDWallet(accountIdx: Int) -> (String?) {
        let accountDict = getAccountDict(accountIdx)
        return removeTopChangeAddress(accountDict)
    }
    
    func removeTopChangeAddressFromImportedAccount(idx: Int) -> (String?) {
        let accountDict = getImportedAccountAtIndex(idx)
        return removeTopChangeAddress(accountDict)
        
    }
    
    func removeTopChangeAddressFromImportedWatchAccount(idx: Int) -> (String?) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        return removeTopChangeAddress(accountDict)
        
    }
    
    private func removeTopChangeAddress(accountDict: NSMutableDictionary) -> (String?) {
        let changeAddressesArray = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES) as! NSMutableArray
        if (changeAddressesArray.count > 0) {
            let changeAddressDict = changeAddressesArray.lastObject as! NSDictionary
            changeAddressesArray.removeLastObject()
            NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
            return changeAddressDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as? String
        }
        return nil
    }
    
    //----------------------------------------------------------------------------------------------------------------
    
    func archiveAccountHDWallet(accountIdx: Int, enabled: Bool) -> () {
        let accountsArray = getAccountsArray()
        assert(accountsArray.count > 1, "")
        let accountDict = accountsArray.objectAtIndex(accountIdx) as! NSDictionary
        let status = enabled ? TLAddressStatus.Archived : TLAddressStatus.Active
        accountDict.setValue(status.rawValue, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func archiveAccountImportedAccount(idx: Int, enabled: Bool) -> () {
        let accountDict = getImportedAccountAtIndex(idx)
        let status = enabled ? TLAddressStatus.Archived : TLAddressStatus.Active
        accountDict.setValue(status.rawValue, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func archiveAccountImportedWatchAccount(idx: Int, enabled: Bool) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        let status = enabled ? TLAddressStatus.Archived : TLAddressStatus.Active
        accountDict.setValue(status.rawValue, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }

    //----------------------------------------------------------------------------------------------------------------
    
    private func getAccountsArray() -> NSMutableArray {
        let hdWalletDict = getHDWallet()
        let accountsArray = hdWalletDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ACCOUNTS) as! NSMutableArray
        return accountsArray
    }
    
    func removeTopAccount() -> (Bool) {
        let accountsArray = getAccountsArray()
        if (accountsArray.count > 0) {
            accountsArray.removeLastObject()
            let hdWalletDict = getHDWallet()
            let maxAccountIDCreated = hdWalletDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAX_ACCOUNTS_CREATED) as! Int
            hdWalletDict.setObject((maxAccountIDCreated - 1), forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAX_ACCOUNTS_CREATED)
            NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
            return true
        }
        
        return false
    }
    
    private func createNewAccount(accountName: String, accountType: TLAccount) -> (TLAccountObject) {
        return createNewAccount(accountName, accountType: accountType, preloadStartingAddresses: true)
    }
    
    func createNewAccount(accountName: String, accountType: TLAccount, preloadStartingAddresses: Bool) -> TLAccountObject {
            assert(self.masterHex != nil, "")
            let hdWalletDict = getHDWallet()
            let accountsArray = getAccountsArray()
            let maxAccountIDCreated = hdWalletDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAX_ACCOUNTS_CREATED) as! UInt
            let extendPrivKey = TLHDWalletWrapper.getExtendPrivKey(self.masterHex!, accountIdx: maxAccountIDCreated)
            let accountDict = createAccountDictWithPreload(accountName, extendedKey: extendPrivKey,
                isPrivateExtendedKey: true, accountIdx: Int(maxAccountIDCreated), preloadStartingAddresses: preloadStartingAddresses)
            accountsArray.addObject(accountDict)
            hdWalletDict.setObject((maxAccountIDCreated + 1), forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAX_ACCOUNTS_CREATED)
        
            NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
        
            if (getCurrentAccountID() == nil) {
                setCurrentAccountID("0")
            }
            
            return TLAccountObject(appWallet: self, dict: accountDict, accountType: .HDWallet)
    }
    
    private func createWallet(passphrase: String, masterHex: String, walletName: String) -> (NSMutableDictionary) {
        let createdWalletDict = NSMutableDictionary()
        
        let hdWalletDict = NSMutableDictionary()
        hdWalletDict.setObject(walletName, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME)
        hdWalletDict.setObject(masterHex, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MASTER_HEX)
        hdWalletDict.setObject(passphrase, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PASSPHRASE)
        
        hdWalletDict.setObject(0, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAX_ACCOUNTS_CREATED)
        
        let accountsArray = NSMutableArray()
        hdWalletDict.setObject(accountsArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ACCOUNTS)
        let hdWalletsArray = NSMutableArray()
        hdWalletsArray.addObject(hdWalletDict)
        
        createdWalletDict.setValue(hdWalletsArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_HDWALLETS)
        
        let importedKeysDict = NSMutableDictionary()
        
        let importedAccountsArray = NSMutableArray()
        let watchOnlyAccountsArray = NSMutableArray()
        let importedPrivateKeysArray = NSMutableArray()
        let watchOnlyAddressesArray = NSMutableArray()
        importedKeysDict.setObject(importedAccountsArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS)
        importedKeysDict.setObject(watchOnlyAccountsArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS)
        importedKeysDict.setObject(importedPrivateKeysArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS)
        importedKeysDict.setObject(watchOnlyAddressesArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES)
        
        
        createdWalletDict.setObject(importedKeysDict, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTS)
        
        return createdWalletDict
    }
    
    private func getImportedKeysDict() -> (NSMutableDictionary) {
        let hdWallet = getCurrentWallet()
        return hdWallet.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTS) as! NSMutableDictionary
    }
    
    internal func getImportedAccountAtIndex(idx: Int) -> (NSMutableDictionary) {
        let importedKeysDict = getImportedKeysDict()
        let importedAccountsArray = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS) as! NSArray
        
        let accountDict = importedAccountsArray.objectAtIndex(idx) as! NSMutableDictionary
        return accountDict
    }
    
    internal func getImportedWatchOnlyAccountAtIndex(idx: Int) -> (NSMutableDictionary) {
        let importedKeysDict = getImportedKeysDict()
        let watchOnlyAccountsArray = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS) as! NSArray
        let accountDict = watchOnlyAccountsArray.objectAtIndex(idx) as! NSMutableDictionary
        return accountDict
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------------------------------------------------------
    
    func addImportedAccount(extendedPrivateKey: String) -> (TLAccountObject) {
        let importedKeysDict = getImportedKeysDict()
        let importedAccountsArray = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS) as! NSMutableArray
        
        let accountIdx = importedAccountsArray.count // "accountIdx" key is different for ImportedAccount then hdwallet account
        let accountDict = createAccountDictWithPreload("", extendedKey: extendedPrivateKey, isPrivateExtendedKey: true, accountIdx: accountIdx, preloadStartingAddresses: false)
        importedAccountsArray.addObject(accountDict)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
        
        return TLAccountObject(appWallet: self, dict: accountDict, accountType: .Imported)
    }
    
    func deleteImportedAccount(idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let importedAccountsArray = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS) as! NSMutableArray
        
        importedAccountsArray.removeObjectAtIndex(idx)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func setImportedAccountLabel(label: String, idx: Int) -> () {
        let accountDict = getImportedAccountAtIndex(idx)
        accountDict.setObject(label, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func getImportedAccountArray() -> (NSArray) {
        let importedKeysDict = getImportedKeysDict()
        let accountsArray = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS) as! NSArray
        
        
        let accountObjectArray = NSMutableArray()
        for accountDict in accountsArray as! [NSDictionary] {
            let accountObject = TLAccountObject(appWallet: self, dict: accountDict, accountType: .Imported)
            accountObjectArray.addObject(accountObject)
            
            
        }
        return accountObjectArray
    }
    
    func addWatchOnlyAccount(extendedPublicKey: String) -> (TLAccountObject) {
        let importedKeysDict = getImportedKeysDict()
        let watchOnlyAccountsArray = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS) as! NSMutableArray
        
        let accountIdx = watchOnlyAccountsArray.count // "accountIdx" key is different for ImportedAccount then hdwallet account
        let watchOnlyAccountDict = createAccountDictWithPreload("", extendedKey: extendedPublicKey, isPrivateExtendedKey: false, accountIdx: accountIdx, preloadStartingAddresses: false)
        watchOnlyAccountsArray.addObject(watchOnlyAccountDict)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
        return TLAccountObject(appWallet: self, dict: watchOnlyAccountDict, accountType: .ImportedWatch)
    }
    
    func deleteWatchOnlyAccount(idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let watchOnlyAccountsArray = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS) as! NSMutableArray
        
        watchOnlyAccountsArray.removeObjectAtIndex(idx)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func setWatchOnlyAccountLabel(label: String, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let watchOnlyAccountsArray = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS) as! NSArray
        
        let accountDict = watchOnlyAccountsArray.objectAtIndex(idx) as! NSMutableDictionary
        accountDict.setObject(label, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func getWatchOnlyAccountArray() -> (NSArray) {
        let importedKeysDict = getImportedKeysDict()
        let accountsArray = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS) as! NSArray
        
        
        let accountObjectArray = NSMutableArray()
        for accountDict in accountsArray as! [NSDictionary] {
            let accountObject = TLAccountObject(appWallet: self, dict: accountDict, accountType: .ImportedWatch)
            accountObjectArray.addObject(accountObject)
        }
        return accountObjectArray
    }
    
    func getImportedAddressObjectAtIdx(idx: Int) -> (TLImportedAddress) {
        let importedKeysDict = getImportedKeysDict()
        let importedAddress = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS) as! NSDictionary
        return TLImportedAddress(dict: importedAddress)
    }
    
    func addImportedPrivateKey(privateKey: String, encryptedPrivateKey: String?) -> (NSDictionary) {
        let importedKeysDict = getImportedKeysDict()
        let importedPrivateKeyArray = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSMutableArray
        
        var importedPrivateKey = NSDictionary()
        if (encryptedPrivateKey == nil) {
            importedPrivateKey = [
                STATIC_MEMBERS.WALLET_PAYLOAD_KEY_KEY: privateKey,
                STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS: TLCoreBitcoinWrapper.getAddress(privateKey)!,
                STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL: String(""),
                STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS: Int(TLAddressStatus.Active.rawValue)
            ]
        } else {
            importedPrivateKey = [
                STATIC_MEMBERS.WALLET_PAYLOAD_KEY_KEY: encryptedPrivateKey!,
                STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS: TLCoreBitcoinWrapper.getAddress(privateKey)!,
                STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL: String(),
                STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS: Int(TLAddressStatus.Active.rawValue)
            ]
        }
        
        let importedPrivateKeyDict = NSMutableDictionary(dictionary: importedPrivateKey)
        importedPrivateKeyArray.addObject(importedPrivateKeyDict)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
        return importedPrivateKey
    }
    
    func deleteImportedPrivateKey(idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let importedPrivateKeyArray = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSMutableArray
        
        importedPrivateKeyArray.removeObjectAtIndex(idx)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func setImportedPrivateKeyLabel(label: String, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let importedPrivateKeyArray = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSArray
        
        let privateKeyDict = importedPrivateKeyArray.objectAtIndex(idx) as! NSMutableDictionary
        privateKeyDict.setObject(label, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func setImportedPrivateKeyArchive(archive: Bool, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let importedPrivateKeyArray = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSArray
        let privateKeyDict = importedPrivateKeyArray.objectAtIndex(idx) as! NSMutableDictionary
        
        let status = archive ? TLAddressStatus.Archived : TLAddressStatus.Active
        privateKeyDict.setObject(status.rawValue, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func getImportedPrivateKeyArray() -> (NSArray) {
        let importedKeysDict = getImportedKeysDict()
        
        let importedAddresses = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSArray
        let importedAddressesObjectArray = NSMutableArray(capacity: importedAddresses.count)
        
        for addressDict in importedAddresses as! [NSDictionary] {
            let importedAddressObject = TLImportedAddress(dict: addressDict)
            importedAddressesObjectArray.addObject(importedAddressObject)
        }
        return importedAddressesObjectArray
    }
    
    func getImportedWatchAddressObjectAtIdx(idx: Int) -> (TLImportedAddress) {
        let importedKeysDict = getImportedKeysDict()
        let importedAddress = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSDictionary
        return TLImportedAddress(dict: importedAddress)
    }
    
    func addWatchOnlyAddress(address: NSString) -> (NSDictionary) {
        let importedKeysDict = getImportedKeysDict()
        let watchOnlyAddressArray = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES) as! NSMutableArray
        
        let watchOnlyAddress = [
            STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS: address,
            STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL: "",
            STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS: (TLAddressStatus.Active.rawValue)
        ]
        
        let watchOnlyAddressDict = NSMutableDictionary(dictionary: watchOnlyAddress)
        watchOnlyAddressArray.addObject(watchOnlyAddressDict)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
        return watchOnlyAddress
    }
    
    func deleteImportedWatchAddress(idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let watchOnlyAddressArray = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES) as! NSMutableArray
        
        watchOnlyAddressArray.removeObjectAtIndex(idx)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    
    func setWatchOnlyAddressLabel(label: String, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let watchOnlyAddressArray = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES) as! NSArray
        let addressDict = watchOnlyAddressArray.objectAtIndex(idx) as! NSMutableDictionary
        addressDict.setObject(label, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func setWatchOnlyAddressArchive(archive: Bool, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let watchOnlyAddressArray = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES) as! NSArray
        let addressDict = watchOnlyAddressArray.objectAtIndex(idx) as! NSMutableDictionary
        
        let status = archive ? TLAddressStatus.Archived : TLAddressStatus.Active
        addressDict.setObject(status.rawValue, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    
    func getWatchOnlyAddressArray() -> (NSArray) {
        let importedKeysDict = getImportedKeysDict()
        
        let importedAddresses = importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES) as! NSArray
        let importedAddressesObjectArray = NSMutableArray(capacity: importedAddresses.count)
        
        for addressDict in importedAddresses as! [NSDictionary] {
            let importedAddressObject = TLImportedAddress(dict: addressDict)
            importedAddressesObjectArray.addObject(importedAddressObject)
        }
        
        return importedAddressesObjectArray
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------------------------------------------------------
    
    func getAddressBook() -> (NSArray) {
        return self.getCurrentWallet().objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS_BOOK) as! NSArray
    }
    
    func addAddressBookEntry(address: String, label: String) -> () {
        let addressBookArray = getCurrentWallet().objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS_BOOK) as! NSMutableArray
        addressBookArray.addObject([STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS: address, STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL: label])
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func editAddressBookEntry(index: Int, label: String) -> () {
        let addressBookArray = getCurrentWallet().objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS_BOOK) as! NSMutableArray
        let oldEntry = addressBookArray.objectAtIndex(index) as! NSDictionary
        addressBookArray.replaceObjectAtIndex(index, withObject: [STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS: oldEntry.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String, STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL: label])
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func deleteAddressBookEntry(idx: Int) -> () {
        let addressBookArray = getCurrentWallet().objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS_BOOK) as! NSMutableArray
        addressBookArray.removeObjectAtIndex(idx)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func setTransactionTag(txid: String, tag: String) -> () {
        let transactionLabelDict = getCurrentWallet().objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TRANSACTION_TAGS) as! NSMutableDictionary
        transactionLabelDict.setObject(tag, forKey: txid)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func deleteTransactionTag(txid: String) -> () {
        let transactionLabelDict = getCurrentWallet().objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TRANSACTION_TAGS) as! NSMutableDictionary
        transactionLabelDict.removeObjectForKey(txid)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func getTransactionTag(txid: String) -> String? {
        let transactionLabelDict = getCurrentWallet().objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TRANSACTION_TAGS) as! NSDictionary
        return transactionLabelDict.objectForKey(txid) as! String?
    }
    
    
    private func createNewWallet(passphrase: String, masterHex: String, walletName: String) -> () {
        let walletsArray = getWallets()
        
        let walletDict = createWallet(passphrase, masterHex: masterHex, walletName: walletName)
        walletDict.setValue(NSMutableArray(), forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS_BOOK)
        walletDict.setValue(NSMutableDictionary(), forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TRANSACTION_TAGS)
        
        walletsArray.addObject(walletDict)
    }
    
    func createInitialWalletPayload(passphrase: String, masterHex: String) -> () {
        self.masterHex = masterHex
        
        rootDict = NSMutableDictionary()
        let walletsArray = NSMutableArray()
        rootDict!.setValue(STATIC_MEMBERS.WALLET_PAYLOAD_VERSION, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_VERSION)
        
        let payload = NSMutableDictionary()
        rootDict!.setValue(payload, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYLOAD)
        
        payload.setValue(walletsArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_WALLETS)
        createNewWallet(passphrase, masterHex: masterHex, walletName: "default")
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func loadWalletPayload(walletPayload: NSDictionary, masterHex: NSString) -> () {
        self.masterHex = masterHex as String
        
        rootDict = NSMutableDictionary(dictionary: walletPayload)
        let walletDict = getCurrentWallet().mutableCopy() as! NSMutableDictionary
        
        let accountsArray = getAccountsArray().mutableCopy() as! NSMutableArray
        for (var i = 0; i < accountsArray.count; i++) {
            let accountDict: AnyObject = accountsArray.objectAtIndex(i).mutableCopy()
            accountsArray.replaceObjectsAtIndexes(NSIndexSet(index: i), withObjects: (NSArray(object: accountDict)) as [AnyObject])
        }
        
        let importedKeysDict = getImportedKeysDict().mutableCopy() as! NSMutableDictionary
        //DLog(String(format: "loadWalletPayload rootDict: \n%@", rootDict!.description))
        
        walletDict.setObject(importedKeysDict, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTS)
        
        let importedAccountsArray: AnyObject = (importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS) as! NSArray).mutableCopy()
        importedKeysDict.setObject(importedAccountsArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS)
        
        let watchOnlyAccountsArray: AnyObject = (importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS) as! NSArray).mutableCopy()
        importedKeysDict.setObject(watchOnlyAccountsArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS)
        
        let importedPrivateKeysArray: AnyObject = (importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSArray).mutableCopy()
        importedKeysDict.setObject(importedPrivateKeysArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS)
        
        let watchOnlyAddressesArray: AnyObject = (importedKeysDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES) as! NSArray).mutableCopy()
        importedKeysDict.setObject(watchOnlyAddressesArray, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES)
    }
    
    func getWalletsJson() -> (NSDictionary?) {
        return rootDict?.copy() as? NSDictionary
    }
    
    private func getWallets() -> (NSMutableArray) {
        return (rootDict!.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYLOAD) as! NSDictionary).objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_WALLETS) as! NSMutableArray
    }
    
    private func getFirstWallet() -> (NSMutableDictionary) {
        return getWallets().objectAtIndex(0) as! NSMutableDictionary
    }
    
    
    private func getCurrentWallet() -> (NSMutableDictionary) {
        return getFirstWallet()
    }
    
    private func getHDWallet() -> (NSMutableDictionary) {
        return (getCurrentWallet().objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_HDWALLETS) as! NSArray).objectAtIndex(0) as! NSMutableDictionary
    }
    
    private func getCurrentAccountID() -> (String?) {
        let hdWallet = getHDWallet()
        return hdWallet.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_CURRENT_ACCOUNT_ID) as? String
    }
    
    private func setCurrentAccountID(accountID: String) -> () {
        let hdWallet = getHDWallet()
        hdWallet.setObject(accountID, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_CURRENT_ACCOUNT_ID)
    }
    
    func renameAccount(accountIdxNumber: Int, accountName: String) -> (Bool) {
        let accountsArray = getAccountsArray()
        let accountDict = accountsArray.objectAtIndex(accountIdxNumber) as! NSMutableDictionary
        accountDict.setObject(accountName, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
        
        return true
    }
    
    func getAccountObjectArray() -> (NSArray) {
        let accountsArray = getAccountsArray()
        
        let accountObjectArray = NSMutableArray()
        for accountDict in accountsArray {
            let accountObject = TLAccountObject(appWallet: self, dict: accountDict as! NSDictionary, accountType: .HDWallet)
            accountObjectArray.addObject(accountObject)
        }
        return accountObjectArray
    }
    
    private func getAccountObjectForIdx(accountIdx: Int) -> (TLAccountObject) {
        let accountsArray = getAccountsArray()
        let accountDict = accountsArray.objectAtIndex(accountIdx) as! NSDictionary
        return TLAccountObject(appWallet: self, dict: accountDict, accountType: .HDWallet)
    }
}



