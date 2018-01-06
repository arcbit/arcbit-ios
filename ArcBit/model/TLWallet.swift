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

class TLWallet {
    fileprivate var walletName: String?
    var walletConfig: TLWalletConfig
    fileprivate var rootDict: NSMutableDictionary?
    fileprivate var currentHDWalletIdx: Int?
    fileprivate var masterHex: String?
    
    init(walletName: String, walletConfig: TLWalletConfig) {
        self.walletName = walletName
        self.walletConfig = walletConfig
        currentHDWalletIdx = 0
    }
    
    //----------------------------------------------------------------------------------------------------------------
    
    fileprivate func createStealthAddressDict(_ extendKey: String, isPrivateExtendedKey: (Bool)) -> (NSMutableDictionary) {
        assert(isPrivateExtendedKey == true, "Cant generate stealth address scan key from xpub key")
        let stealthAddressDict = NSMutableDictionary()
        let stealthAddressObject = TLHDWalletWrapper.getStealthAddress(extendKey, isTestnet: self.walletConfig.isTestnet)
        stealthAddressDict.setObject((stealthAddressObject.object(forKey: "stealthAddress"))!, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESS as NSCopying)
        stealthAddressDict.setObject((stealthAddressObject.object(forKey: "scanPriv"))!, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESS_SCAN_KEY as NSCopying)
        stealthAddressDict.setObject((stealthAddressObject.object(forKey: "spendPriv"))!, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESS_SPEND_KEY as NSCopying)
        stealthAddressDict.setObject(NSMutableDictionary(), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_SERVERS as NSCopying)
        stealthAddressDict.setObject(NSMutableArray(), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYMENTS as NSCopying)
        stealthAddressDict.setObject(NSNumber(value: 0 as UInt64), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LAST_TX_TIME as NSCopying)
        return stealthAddressDict
    }
    
    fileprivate func createAccountDictWithPreload(_ accountName: String, extendedKey: String,
        isPrivateExtendedKey: Bool, accountIdx: Int,
        preloadStartingAddresses: Bool) -> (NSMutableDictionary) {
            
            let account = NSMutableDictionary()
            account.setObject(accountName, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME as NSCopying)
            account.setObject(accountIdx, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX as NSCopying)
            
            if (isPrivateExtendedKey) {
                let extendedPublickey = TLHDWalletWrapper.getExtendPubKey(extendedKey)
                account.setObject(extendedPublickey, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY as NSCopying)
                account.setObject(extendedKey, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PRIVATE_KEY as NSCopying)
                
                let stealthAddressesArray = NSMutableArray()
                
                let stealthAddressDict = createStealthAddressDict(extendedKey, isPrivateExtendedKey: isPrivateExtendedKey)
                stealthAddressesArray.add(stealthAddressDict)
                
                account.setObject(stealthAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES as NSCopying)
            } else {
                account.setObject(extendedKey, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY as NSCopying)
            }
            
            account.setValue(TLAddressStatus.active.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
            account.setObject(true, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING as NSCopying)
            
            let mainAddressesArray = NSMutableArray()
            account.setObject(mainAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES as NSCopying)
            
            let changeAddressesArray = NSMutableArray()
            account.setObject(changeAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES as NSCopying)
            
            account.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX as NSCopying)
            account.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX as NSCopying)
            
            if (!preloadStartingAddresses) {
                return account
            }
            
            let extendedPublicKey = account.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY) as! String
            //create initial receiving address
            for i in stride(from: 0, to: TLAccountObject.MAX_ACCOUNT_WAIT_TO_RECEIVE_ADDRESS(), by: 1) {
                let mainAddressDict = NSMutableDictionary()
                let mainAddressIdx = i
                let mainAddressSequence = [TLAddressType.main.rawValue, (mainAddressIdx)]
                
                let address = TLHDWalletWrapper.getAddress(extendedPublicKey, sequence: mainAddressSequence as NSArray, isTestnet: self.walletConfig.isTestnet)
                mainAddressDict.setObject(address, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS as NSCopying)
                mainAddressDict.setObject(TLAddressStatus.active.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS as NSCopying)
                mainAddressDict.setObject(i, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX as NSCopying)
                
                mainAddressesArray.add(mainAddressDict)
            }
            
            let changeAddressDict = NSMutableDictionary()
            let changeAddressIdx = 0
            let changeAddressSequence = [TLAddressType.change.rawValue, changeAddressIdx]
            
            let address = TLHDWalletWrapper.getAddress(extendedPublicKey, sequence: changeAddressSequence as NSArray, isTestnet: self.walletConfig.isTestnet)
            changeAddressDict.setObject(address, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS as NSCopying)
            changeAddressDict.setObject(TLAddressStatus.active.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS as NSCopying)
            changeAddressDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX as NSCopying)
            
            changeAddressesArray.add(changeAddressDict)
            
            return account
    }
    
    
    internal func getAccountDict(_ coinType: TLCoinType, accountIdx: Int) -> (NSMutableDictionary) {
        let accountsArray = getAccountsArray(coinType)
        let accountDict = accountsArray.object(at: accountIdx) as! NSMutableDictionary
        return accountDict
    }
    
    //----------------------------------------------------------------------------------------------------------------
    
    func clearAllAddressesFromHDWallet(_ coinType: TLCoinType, accountIdx: Int) -> () {
        let accountDict = getAccountDict(coinType, accountIdx: accountIdx)
        let mainAddressesArray = NSMutableArray()
        accountDict.setObject(mainAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES as NSCopying)
        let changeAddressesArray = NSMutableArray()
        accountDict.setObject(changeAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES as NSCopying)
        accountDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX as NSCopying)
        accountDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX as NSCopying)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func clearAllAddressesFromColdWalletAccount(_ coinType: TLCoinType, idx: Int) -> () {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: idx)
        let mainAddressesArray = NSMutableArray()
        accountDict.setObject(mainAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES as NSCopying)
        let changeAddressesArray = NSMutableArray()
        accountDict.setObject(changeAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES as NSCopying)
        accountDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX as NSCopying)
        accountDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func clearAllAddressesFromImportedAccount(_ coinType: TLCoinType, idx: Int) -> () {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
        let mainAddressesArray = NSMutableArray()
        accountDict.setObject(mainAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES as NSCopying)
        let changeAddressesArray = NSMutableArray()
        accountDict.setObject(changeAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES as NSCopying)
        accountDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX as NSCopying)
        accountDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func clearAllAddressesFromImportedWatchAccount(_ coinType: TLCoinType, idx: Int) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: idx)
        let mainAddressesArray = NSMutableArray()
        accountDict.setObject(mainAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES as NSCopying)
        let changeAddressesArray = NSMutableArray()
        accountDict.setObject(changeAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES as NSCopying)
        accountDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX as NSCopying)
        accountDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    //----------------------------------------------------------------------------------------------------------------
    func updateAccountNeedsRecoveringFromHDWallet(_ coinType: TLCoinType, accountIdx: Int, accountNeedsRecovering: Bool) -> () {
        let accountDict = getAccountDict(coinType, accountIdx: accountIdx)
        accountDict.setObject(accountNeedsRecovering, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func updateAccountNeedsRecoveringFromColdWalletAccount(_ coinType: TLCoinType, idx: Int, accountNeedsRecovering: Bool) -> () {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: idx)
        accountDict.setObject(accountNeedsRecovering, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func updateAccountNeedsRecoveringFromImportedAccount(_ coinType: TLCoinType, idx: Int, accountNeedsRecovering: Bool) -> () {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
        accountDict.setObject(accountNeedsRecovering, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func updateAccountNeedsRecoveringFromImportedWatchAccount(_ coinType: TLCoinType, idx: Int, accountNeedsRecovering: Bool) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: idx)
        accountDict.setObject(accountNeedsRecovering, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    //----------------------------------------------------------------------------------------------------------------
    
    
    func updateMainAddressStatusFromHDWallet(_ coinType: TLCoinType, accountIdx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
        let accountDict = getAccountDict(coinType, accountIdx: accountIdx)
        self.updateMainAddressStatus(accountDict,
                                     addressIdx: addressIdx,
                                     addressStatus: addressStatus)
    }
    
    func updateMainAddressStatusFromColdWalletAccount(_ coinType: TLCoinType, idx: Int, addressIdx: Int,
                                                         addressStatus: TLAddressStatus) -> () {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: idx)
        self.updateMainAddressStatus(accountDict,
                                     addressIdx: addressIdx,
                                     addressStatus: addressStatus)
    }
    
    func updateMainAddressStatusFromImportedAccount(_ coinType: TLCoinType, idx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
            self.updateMainAddressStatus(accountDict,
                addressIdx: addressIdx,
                addressStatus: addressStatus)
    }
    
    func updateMainAddressStatusFromImportedWatchAccount(_ coinType: TLCoinType, idx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: idx)
            self.updateMainAddressStatus(accountDict,
                addressIdx: addressIdx,
                addressStatus: addressStatus)
    }
    
    func updateMainAddressStatus(_ accountDict: NSMutableDictionary, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            
            let minMainAddressIdx = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX) as! Int
            
            DLog("updateMainAddressStatus accountIdx \(accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int)")
            DLog("updateMainAddressStatus minMainAddressIdx \(minMainAddressIdx) addressIdx: \(addressIdx)")
            
            assert(Int(addressIdx) == minMainAddressIdx, "addressIdx != minMainAddressIdx")
            accountDict.setObject((minMainAddressIdx+1), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX as NSCopying)
            
            let mainAddressesArray = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES) as! NSMutableArray
            
            if (addressStatus == .archived && !TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
                mainAddressesArray.removeObject(at: 0)
            } else {
                let mainAddressDict = mainAddressesArray.object(at: addressIdx) as! NSMutableDictionary
                mainAddressDict.setObject(addressStatus.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS as NSCopying)
            }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func updateChangeAddressStatusFromHDWallet(_ coinType: TLCoinType, accountIdx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
        let accountDict = getAccountDict(coinType, accountIdx: accountIdx)
            self.updateChangeAddressStatus(accountDict,
                addressIdx: addressIdx,
                addressStatus: addressStatus)
    }
    
    func updateChangeAddressStatusFromImportedAccount(_ coinType: TLCoinType, idx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
            self.updateChangeAddressStatus(accountDict,
                addressIdx: addressIdx,
                addressStatus: addressStatus)
    }
    
    func updateChangeAddressStatusFromColdWalletAccount(_ coinType: TLCoinType, idx: Int, addressIdx: Int,
                                                           addressStatus: TLAddressStatus) -> () {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: idx)
        self.updateChangeAddressStatus(accountDict,
                                       addressIdx: addressIdx,
                                       addressStatus: addressStatus)
    }
    
    func updateChangeAddressStatusFromImportedWatchAccount(_ coinType: TLCoinType, idx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: idx)
            self.updateChangeAddressStatus(accountDict,
                addressIdx: addressIdx,
                addressStatus: addressStatus)
    }
    
    func updateChangeAddressStatus(_ accountDict: NSMutableDictionary, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            
            let minChangeAddressIdx = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX) as! Int
            
            DLog("updateChangeAddressStatus accountIdx \(accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int)")
            DLog("updateChangeAddressStatus minChangeAddressIdx \(minChangeAddressIdx) addressIdx: \(addressIdx)")
            
            assert(Int(addressIdx) == minChangeAddressIdx, "addressIdx != minChangeAddressIdx")
            accountDict.setObject((minChangeAddressIdx + 1), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX as NSCopying)
            
            let changeAddressesArray = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES) as! NSMutableArray
            
            if (addressStatus == .archived && !TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
                changeAddressesArray.removeObject(at: 0)
            } else {
                let changeAddressDict = changeAddressesArray.object(at: addressIdx) as! NSMutableDictionary
                changeAddressDict.setObject(addressStatus.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS as NSCopying)
            }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    //----------------------------------------------------------------------------------------------------------------
    func getMinMainAddressIdxFromHDWallet(_ coinType: TLCoinType, accountIdx: Int) -> Int {
        let accountDict = getAccountDict(coinType, accountIdx: accountIdx)
        return self.getMinMainAddressIdx(accountDict)
    }
    
    func getMinMainAddressIdxFromColdWalletAccount(_ coinType: TLCoinType, idx: Int) -> (Int) {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: idx)
        return self.getMinMainAddressIdx(accountDict)
    }
    
    func getMinMainAddressIdxFromImportedAccount(_ coinType: TLCoinType, idx: Int) -> (Int) {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
        return self.getMinMainAddressIdx(accountDict)
    }
    
    func getMinMainAddressIdxFromImportedWatchAccount(_ coinType: TLCoinType, idx: Int) -> (Int) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: idx)
        return self.getMinMainAddressIdx(accountDict)
    }
    
    func getMinMainAddressIdx(_ accountDict: NSMutableDictionary) -> (Int) {
        return accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX) as! Int
    }
    
    func getMinChangeAddressIdxFromHDWallet(_ coinType: TLCoinType, accountIdx: Int) -> (Int) {
        let accountDict = getAccountDict(coinType, accountIdx: accountIdx)
        return self.getMinChangeAddressIdx(accountDict) as Int
    }
    
    func getMinChangeAddressIdxFromColdWalletAccount(_ coinType: TLCoinType, idx: Int) -> (Int) {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: idx)
        return self.getMinChangeAddressIdx(accountDict) as Int
    }
    
    func getMinChangeAddressIdxFromImportedAccount(_ coinType: TLCoinType, idx: Int) -> (Int) {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
        return self.getMinChangeAddressIdx(accountDict) as Int
    }
    
    func getMinChangeAddressIdxFromImportedWatchAccount(_ coinType: TLCoinType, idx: Int) -> (Int) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: idx)
        return self.getMinChangeAddressIdx(accountDict) as Int
    }
    
    func getMinChangeAddressIdx(_ accountDict: NSMutableDictionary) -> (Int) {
        return accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX) as! Int
    }
    
    //----------------------------------------------------------------------------------------------------------------
    
    func getNewMainAddressFromHDWallet(_ coinType: TLCoinType, accountIdx: Int, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getAccountDict(coinType, accountIdx: accountIdx)
        return getNewMainAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    func getNewMainAddressFromColdWalletAccount(_ coinType: TLCoinType, idx: Int, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: idx)
        return getNewMainAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    func getNewMainAddressFromImportedAccount(_ coinType: TLCoinType, idx: Int, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
        return getNewMainAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    func getNewMainAddressFromImportedWatchAccount(_ coinType: TLCoinType, idx: Int, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: idx)
        return getNewMainAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    fileprivate func getNewMainAddress(_ accountDict: NSDictionary, expectedAddressIndex: Int) -> (NSDictionary) {
        let mainAddressesArray = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES) as! NSMutableArray
        
        DLog(String(format:"getNewMainAddress expectedAddressIndex %lu mainAddressesArray.count %lu", expectedAddressIndex, mainAddressesArray.count))
        
        let mainAddressIdx:Int
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            assert(expectedAddressIndex == mainAddressesArray.count, "expectedAddressIndex != mainAddressesArray.count")
            mainAddressIdx = (expectedAddressIndex)
        } else {
            let minMainAddressIdx = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX) as! Int
            assert(expectedAddressIndex == mainAddressesArray.count + minMainAddressIdx, "expectedAddressIndex != mainAddressesArray.count + minMainAddressIdx")
            mainAddressIdx = (expectedAddressIndex)
        }
        
        if (mainAddressIdx >= NSIntegerMax) {
            NSException(name: NSExceptionName(rawValue: "Universe ended"), reason: "reached max hdwallet index", userInfo: nil).raise()
            
        }
        
        let mainAddressSequence = [TLAddressType.main.rawValue, mainAddressIdx]
        let mainAddressDict = NSMutableDictionary()
        
        let extendedPublicKey = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY) as! String
        let address = TLHDWalletWrapper.getAddress(extendedPublicKey, sequence: mainAddressSequence as NSArray, isTestnet: self.walletConfig.isTestnet)
        
        mainAddressDict.setObject(address, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS as NSCopying)
        mainAddressDict.setObject((TLAddressStatus.active.rawValue), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS as NSCopying)
        mainAddressDict.setObject(mainAddressIdx, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX as NSCopying)
        
        mainAddressesArray.add(mainAddressDict)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
        }
        
        return mainAddressDict
    }
    //----------------------------------------------------------------------------------------------------------------
    func getNewChangeAddressFromHDWallet(_ coinType: TLCoinType, accountIdx: Int, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getAccountDict(coinType, accountIdx: accountIdx)
        return getNewChangeAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    func getNewChangeAddressFromColdWalletAccount(_ coinType: TLCoinType, idx: UInt, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: Int(idx))
        return getNewChangeAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    func getNewChangeAddressFromImportedAccount(_ coinType: TLCoinType, idx: Int, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
        return getNewChangeAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    func getNewChangeAddressFromImportedWatchAccount(_ coinType: TLCoinType, idx: UInt, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: Int(idx))
        return getNewChangeAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    fileprivate func getNewChangeAddress(_ accountDict: NSDictionary, expectedAddressIndex: Int) -> (NSDictionary) {
        
        let changeAddressesArray = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES) as! NSMutableArray
        
        DLog(String(format: "getNewChangeAddress expectedAddressIndex %lu changeAddressesArray.count %lu", expectedAddressIndex, changeAddressesArray.count))
        
        let changeAddressIdx:Int
        if (TLWalletUtils.STATIC_MEMBERS.SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON) {
            assert(expectedAddressIndex == changeAddressesArray.count, "expectedAddressIndex != changeAddressesArray.count")
            changeAddressIdx = (changeAddressesArray.count)
        } else {
            let minChangeAddressIdx = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX) as! Int
            assert(expectedAddressIndex == changeAddressesArray.count + minChangeAddressIdx, "expectedAddressIndex != changeAddressesArray.count + minChangeAddressIdx")
            changeAddressIdx = (expectedAddressIndex)
        }
        
        if (changeAddressIdx >= NSIntegerMax) {
            NSException(name: NSExceptionName(rawValue: "Universe ended"), reason: "reached max hdwallet index", userInfo: nil).raise()
        }
        
        let changeAddressSequence = [TLAddressType.change.rawValue, changeAddressIdx]
        let changeAddressDict = NSMutableDictionary()
        
        let extendedPublicKey = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY) as! String
        let address = TLHDWalletWrapper.getAddress(extendedPublicKey, sequence: changeAddressSequence as NSArray, isTestnet: self.walletConfig.isTestnet)
        changeAddressDict.setObject(address, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS as NSCopying)
        changeAddressDict.setObject(TLAddressStatus.active.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS as NSCopying)
        changeAddressDict.setObject(changeAddressIdx, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_INDEX as NSCopying)
        
        changeAddressesArray.add(changeAddressDict)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
        }
        
        return changeAddressDict
    }
    
    //----------------------------------------------------------------------------------------------------------------
    func removeTopMainAddressFromHDWallet(_ coinType: TLCoinType, accountIdx: Int) -> (String?) {
        let accountDict = getAccountDict(coinType, accountIdx: accountIdx)
        return removeTopMainAddress(accountDict)
    }
    
    func removeTopMainAddressFromColdWalletAccount(_ coinType: TLCoinType, idx: Int) -> (String?) {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: idx)
        return removeTopMainAddress(accountDict)
    }
    
    func removeTopMainAddressFromImportedAccount(_ coinType: TLCoinType, idx: Int) -> (String?) {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
        return removeTopMainAddress(accountDict)
    }
    
    func removeTopMainAddressFromImportedWatchAccount(_ coinType: TLCoinType, idx: Int) -> (String?) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: idx)
        return removeTopMainAddress(accountDict)
    }
    
    fileprivate func removeTopMainAddress(_ accountDict: NSMutableDictionary) -> (String?) {
        let mainAddressesArray = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES) as! NSMutableArray
        if (mainAddressesArray.count > 0) {
            let mainAddressDict = mainAddressesArray.lastObject as! NSDictionary
            mainAddressesArray.removeLastObject()
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
            return mainAddressDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as? String
        }
        
        return nil
    }
    //----------------------------------------------------------------------------------------------------------------
    func removeTopChangeAddressFromHDWallet(_ coinType: TLCoinType, accountIdx: Int) -> (String?) {
        let accountDict = getAccountDict(coinType, accountIdx: accountIdx)
        return removeTopChangeAddress(accountDict)
    }
    
    func removeTopChangeAddressFromColdWalletAccount(_ coinType: TLCoinType, idx: Int) -> (String?) {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: idx)
        return removeTopChangeAddress(accountDict)
    }

    func removeTopChangeAddressFromImportedAccount(_ coinType: TLCoinType, idx: Int) -> (String?) {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
        return removeTopChangeAddress(accountDict)
    }
    
    func removeTopChangeAddressFromImportedWatchAccount(_ coinType: TLCoinType, idx: Int) -> (String?) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: idx)
        return removeTopChangeAddress(accountDict)
    }
    
    fileprivate func removeTopChangeAddress(_ accountDict: NSMutableDictionary) -> (String?) {
        let changeAddressesArray = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES) as! NSMutableArray
        if (changeAddressesArray.count > 0) {
            let changeAddressDict = changeAddressesArray.lastObject as! NSDictionary
            changeAddressesArray.removeLastObject()
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
            return changeAddressDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as? String
        }
        return nil
    }
    
    //----------------------------------------------------------------------------------------------------------------
    
    func archiveAccountHDWallet(_ coinType: TLCoinType, accountIdx: Int, enabled: Bool) -> () {
        let accountsArray = getAccountsArray(coinType)
        assert(accountsArray.count > 1, "")
        let accountDict = accountsArray.object(at: accountIdx) as! NSDictionary
        let status = enabled ? TLAddressStatus.archived : TLAddressStatus.active
        accountDict.setValue(status.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func archiveAccountColdWalletAccount(_ coinType: TLCoinType, idx: Int, enabled: Bool) -> () {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: idx)
        let status = enabled ? TLAddressStatus.archived : TLAddressStatus.active
        accountDict.setValue(status.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func archiveAccountImportedAccount(_ coinType: TLCoinType, idx: Int, enabled: Bool) -> () {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
        let status = enabled ? TLAddressStatus.archived : TLAddressStatus.active
        accountDict.setValue(status.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func archiveAccountImportedWatchAccount(_ coinType: TLCoinType, idx: Int, enabled: Bool) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: idx)
        let status = enabled ? TLAddressStatus.archived : TLAddressStatus.active
        accountDict.setValue(status.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }

    //----------------------------------------------------------------------------------------------------------------
    
    fileprivate func getAccountsArray(_ coinType: TLCoinType) -> NSMutableArray {
        let hdWalletDict = getHDWallet(coinType)
        let accountsArray = hdWalletDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ACCOUNTS) as! NSMutableArray
        return accountsArray
    }
    
    func removeTopAccount(_ coinType: TLCoinType) -> (Bool) {
        let accountsArray = getAccountsArray(coinType)
        if (accountsArray.count > 0) {
            accountsArray.removeLastObject()
            let hdWalletDict = getHDWallet(coinType)
            let maxAccountIDCreated = hdWalletDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAX_ACCOUNTS_CREATED) as! Int
            hdWalletDict.setObject((maxAccountIDCreated - 1), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAX_ACCOUNTS_CREATED as NSCopying)
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
            return true
        }
        
        return false
    }
    
    fileprivate func createNewAccount(_ coinType: TLCoinType, accountName: String, accountType: TLAccount) -> (TLAccountObject) {
        return createNewAccount(coinType, accountName: accountName, accountType: accountType, preloadStartingAddresses: true)
    }
    
    func createNewAccount(_ coinType: TLCoinType, accountName: String, accountType: TLAccount, preloadStartingAddresses: Bool) -> TLAccountObject {
            assert(self.masterHex != nil, "")
            let hdWalletDict = getHDWallet(coinType)
            let accountsArray = getAccountsArray(coinType)
            let maxAccountIDCreated = hdWalletDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAX_ACCOUNTS_CREATED) as! Int
            let extendPrivKey = TLHDWalletWrapper.getExtendPrivKey(self.masterHex!, accountIdx: UInt(maxAccountIDCreated))
            let accountDict = createAccountDictWithPreload(accountName, extendedKey: extendPrivKey,
                isPrivateExtendedKey: true, accountIdx: Int(maxAccountIDCreated), preloadStartingAddresses: preloadStartingAddresses)
            accountsArray.add(accountDict)
            hdWalletDict.setObject((maxAccountIDCreated + 1), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAX_ACCOUNTS_CREATED as NSCopying)
        
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
        
        return TLAccountObject(appWallet: self, coinType: coinType, dict: accountDict, accountType: .hdWallet)
    }
    
    func createWalletDictForCoin() -> NSMutableDictionary {
        let coinWalletDict = NSMutableDictionary()
        
        let hdWalletDict = NSMutableDictionary()        
        hdWalletDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAX_ACCOUNTS_CREATED as NSCopying)
        
        let accountsArray = NSMutableArray()
        hdWalletDict.setObject(accountsArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ACCOUNTS as NSCopying)
        let hdWalletsArray = NSMutableArray()
        hdWalletsArray.add(hdWalletDict)
        
        coinWalletDict.setValue(hdWalletsArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_HDWALLETS)
        
        let importedKeysDict = NSMutableDictionary()
        
        let coldWalletAccountsArray = NSMutableArray()
        let importedAccountsArray = NSMutableArray()
        let watchOnlyAccountsArray = NSMutableArray()
        let importedPrivateKeysArray = NSMutableArray()
        let watchOnlyAddressesArray = NSMutableArray()
        importedKeysDict.setObject(coldWalletAccountsArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_COLD_WALLET_ACCOUNTS as NSCopying)
        importedKeysDict.setObject(importedAccountsArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS as NSCopying)
        importedKeysDict.setObject(watchOnlyAccountsArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS as NSCopying)
        importedKeysDict.setObject(importedPrivateKeysArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS as NSCopying)
        importedKeysDict.setObject(watchOnlyAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES as NSCopying)
        
        
        coinWalletDict.setObject(importedKeysDict, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTS as NSCopying)
        
        coinWalletDict.setValue(NSMutableArray(), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS_BOOK)
        coinWalletDict.setValue(NSMutableDictionary(), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TRANSACTION_TAGS)
        
        return coinWalletDict
    }
    
    fileprivate func createWallet(_ passphrase: String, masterHex: String, walletName: String) -> (NSMutableDictionary) {
        let createdWalletDict = NSMutableDictionary()
        createdWalletDict.setObject(walletName, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_WALLET_NAME as NSCopying)
        TLWalletUtils.SUPPORT_COIN_TYPES().forEach({ (coinType) in
            switch coinType {
            case .BTC:
                let coinWalletDict = createWalletDictForCoin()
                createdWalletDict.setObject(coinWalletDict, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_BITCOIN as NSCopying)
            case .BCH:
                let coinWalletDict = createWalletDictForCoin()
                createdWalletDict.setObject(coinWalletDict, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_BITCOIN_CASH as NSCopying)
            }
        })
        return createdWalletDict
    }
    
    fileprivate func getImportedKeysDict(_ coinType: TLCoinType) -> (NSMutableDictionary) {
        let hdWallet = getCurrentWallet(coinType)
        return hdWallet.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTS) as! NSMutableDictionary
    }
    
    internal func getColdWalletAccountAtIndex(_ coinType: TLCoinType, idx: Int) -> (NSMutableDictionary) {
        let importedKeysDict = getImportedKeysDict(coinType)
        let coldWalletAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_COLD_WALLET_ACCOUNTS) as! NSArray
        let accountDict = coldWalletAccountsArray.object(at: idx) as! NSMutableDictionary
        return accountDict
    }
    
    internal func getImportedAccountAtIndex(_ coinType: TLCoinType, idx: Int) -> (NSMutableDictionary) {
        let importedKeysDict = getImportedKeysDict(coinType)
        let importedAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS) as! NSArray
        
        let accountDict = importedAccountsArray.object(at: idx) as! NSMutableDictionary
        return accountDict
    }
    
    internal func getImportedWatchOnlyAccountAtIndex(_ coinType: TLCoinType, idx: Int) -> (NSMutableDictionary) {
        let importedKeysDict = getImportedKeysDict(coinType)
        let watchOnlyAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS) as! NSArray
        let accountDict = watchOnlyAccountsArray.object(at: idx) as! NSMutableDictionary
        return accountDict
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------------------------------------------------------
    
    func addColdWalletAccount(_ coinType: TLCoinType, extendedPublicKey: String) -> (TLAccountObject) {
        let importedKeysDict = getImportedKeysDict(coinType)
        let coldWalletAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_COLD_WALLET_ACCOUNTS) as! NSMutableArray
        
        let accountIdx = coldWalletAccountsArray.count // "accountIdx" key is different for ImportedAccount then hdwallet account
        let coldWalletAccountDict = createAccountDictWithPreload("", extendedKey: extendedPublicKey, isPrivateExtendedKey: false, accountIdx: accountIdx, preloadStartingAddresses: false)
        coldWalletAccountsArray.add(coldWalletAccountDict)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
        return TLAccountObject(appWallet: self, coinType: coinType, dict: coldWalletAccountDict, accountType: .coldWallet)
    }
    
    func deleteColdWalletAccount(_ coinType: TLCoinType, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict(coinType)
        let coldWalletAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_COLD_WALLET_ACCOUNTS) as! NSMutableArray
        
        coldWalletAccountsArray.removeObject(at: idx)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func setColdWalletAccountName(_ coinType: TLCoinType, name: String, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict(coinType)
        let coldWalletAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_COLD_WALLET_ACCOUNTS) as! NSArray
        
        let accountDict = coldWalletAccountsArray.object(at: idx) as! NSMutableDictionary
        accountDict.setObject(name, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func getColdWalletAccountArray(_ coinType: TLCoinType) -> (NSArray) {
        let importedKeysDict = getImportedKeysDict(coinType)
        let accountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_COLD_WALLET_ACCOUNTS) as! NSArray
        
        
        let accountObjectArray = NSMutableArray()
        for accountDict in accountsArray as! [NSDictionary] {
            let accountObject = TLAccountObject(appWallet: self, coinType: coinType, dict: accountDict, accountType: .coldWallet)
            accountObjectArray.add(accountObject)
        }
        return accountObjectArray
    }

    func addImportedAccount(_ coinType: TLCoinType, extendedPrivateKey: String) -> (TLAccountObject) {
        let importedKeysDict = getImportedKeysDict(coinType)
        let importedAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS) as! NSMutableArray
        
        let accountIdx = importedAccountsArray.count // "accountIdx" key is different for ImportedAccount then hdwallet account
        let accountDict = createAccountDictWithPreload("", extendedKey: extendedPrivateKey, isPrivateExtendedKey: true, accountIdx: accountIdx, preloadStartingAddresses: false)
        importedAccountsArray.add(accountDict)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
        
        return TLAccountObject(appWallet: self, coinType: coinType, dict: accountDict, accountType: .imported)
    }
    
    func deleteImportedAccount(_ coinType: TLCoinType, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict(coinType)
        let importedAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS) as! NSMutableArray
        
        importedAccountsArray.removeObject(at: idx)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func setImportedAccountName(_ coinType: TLCoinType, name: String, idx: Int) -> () {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
        accountDict.setObject(name, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func getImportedAccountArray(_ coinType: TLCoinType) -> (NSArray) {
        let importedKeysDict = getImportedKeysDict(coinType)
        let accountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS) as! NSArray
        
        
        let accountObjectArray = NSMutableArray()
        for accountDict in accountsArray as! [NSDictionary] {
            let accountObject = TLAccountObject(appWallet: self, coinType: coinType, dict: accountDict, accountType: .imported)
            accountObjectArray.add(accountObject)
            
            
        }
        return accountObjectArray
    }
    
    func addWatchOnlyAccount(_ coinType: TLCoinType, extendedPublicKey: String) -> (TLAccountObject) {
        let importedKeysDict = getImportedKeysDict(coinType)
        let watchOnlyAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS) as! NSMutableArray
        
        let accountIdx = watchOnlyAccountsArray.count // "accountIdx" key is different for ImportedAccount then hdwallet account
        let watchOnlyAccountDict = createAccountDictWithPreload("", extendedKey: extendedPublicKey, isPrivateExtendedKey: false, accountIdx: accountIdx, preloadStartingAddresses: false)
        watchOnlyAccountsArray.add(watchOnlyAccountDict)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
        return TLAccountObject(appWallet: self, coinType: coinType, dict: watchOnlyAccountDict, accountType: .importedWatch)
    }
    
    func deleteWatchOnlyAccount(_ coinType: TLCoinType, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict(coinType)
        let watchOnlyAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS) as! NSMutableArray
        
        watchOnlyAccountsArray.removeObject(at: idx)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func setWatchOnlyAccountName(_ coinType: TLCoinType, name: String, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict(coinType)
        let watchOnlyAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS) as! NSArray
        
        let accountDict = watchOnlyAccountsArray.object(at: idx) as! NSMutableDictionary
        accountDict.setObject(name, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func getWatchOnlyAccountArray(_ coinType: TLCoinType) -> (NSArray) {
        let importedKeysDict = getImportedKeysDict(coinType)
        let accountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS) as! NSArray
        
        
        let accountObjectArray = NSMutableArray()
        for accountDict in accountsArray as! [NSDictionary] {
            let accountObject = TLAccountObject(appWallet: self, coinType: coinType, dict: accountDict, accountType: .importedWatch)
            accountObjectArray.add(accountObject)
        }
        return accountObjectArray
    }
    
    func addImportedPrivateKey(_ coinType: TLCoinType, privateKey: String, encryptedPrivateKey: String?) -> (NSDictionary) {
        let importedKeysDict = getImportedKeysDict(coinType)
        let importedPrivateKeyArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSMutableArray
        
        var importedPrivateKey = NSDictionary()
        if (encryptedPrivateKey == nil) {
            importedPrivateKey = [
                TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_KEY: privateKey,
                TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS: TLCoreBitcoinWrapper.getAddress(privateKey, isTestnet: self.walletConfig.isTestnet)!,
                TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL: "",
                TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS: Int(TLAddressStatus.active.rawValue)
            ]
        } else {
            importedPrivateKey = [
                TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_KEY: encryptedPrivateKey!,
                TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS: TLCoreBitcoinWrapper.getAddress(privateKey, isTestnet: self.walletConfig.isTestnet)!,
                TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL: String(),
                TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS: Int(TLAddressStatus.active.rawValue)
            ]
        }
        
        let importedPrivateKeyDict = NSMutableDictionary(dictionary: importedPrivateKey)
        importedPrivateKeyArray.add(importedPrivateKeyDict)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
        return importedPrivateKey
    }
    
    func deleteImportedPrivateKey(_ coinType: TLCoinType, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict(coinType)
        let importedPrivateKeyArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSMutableArray
        
        importedPrivateKeyArray.removeObject(at: idx)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func setImportedPrivateKeyLabel(_ coinType: TLCoinType, label: String, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict(coinType)
        let importedPrivateKeyArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSArray
        
        let privateKeyDict = importedPrivateKeyArray.object(at: idx) as! NSMutableDictionary
        privateKeyDict.setObject(label, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func setImportedPrivateKeyArchive(_ coinType: TLCoinType, archive: Bool, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict(coinType)
        let importedPrivateKeyArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSArray
        let privateKeyDict = importedPrivateKeyArray.object(at: idx) as! NSMutableDictionary
        
        let status = archive ? TLAddressStatus.archived : TLAddressStatus.active
        privateKeyDict.setObject(status.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func getImportedPrivateKeyArray(_ coinType: TLCoinType) -> (NSArray) {
        let importedKeysDict = getImportedKeysDict(coinType)
        
        let importedAddresses = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSArray
        let importedAddressesObjectArray = NSMutableArray(capacity: importedAddresses.count)
        
        for addressDict in importedAddresses as! [NSDictionary] {
            let importedAddressObject = TLImportedAddress(appWallet: self, dict: addressDict)
            importedAddressesObjectArray.add(importedAddressObject)
        }
        return importedAddressesObjectArray
    }
    
    func addWatchOnlyAddress(_ coinType: TLCoinType, address: NSString) -> (NSDictionary) {
        let importedKeysDict = getImportedKeysDict(coinType)
        let watchOnlyAddressArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES) as! NSMutableArray
        
        let watchOnlyAddress = [
            TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS: address,
            TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL: "",
            TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS: (TLAddressStatus.active.rawValue)
        ] as [String : Any]
        
        let watchOnlyAddressDict = NSMutableDictionary(dictionary: watchOnlyAddress)
        watchOnlyAddressArray.add(watchOnlyAddressDict)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
        return watchOnlyAddress as (NSDictionary)
    }
    
    func deleteImportedWatchAddress(_ coinType: TLCoinType, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict(coinType)
        let watchOnlyAddressArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES) as! NSMutableArray
        
        watchOnlyAddressArray.removeObject(at: idx)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    
    func setWatchOnlyAddressLabel(_ coinType: TLCoinType, label: String, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict(coinType)
        let watchOnlyAddressArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES) as! NSArray
        let addressDict = watchOnlyAddressArray.object(at: idx) as! NSMutableDictionary
        addressDict.setObject(label, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func setWatchOnlyAddressArchive(_ coinType: TLCoinType, archive: Bool, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict(coinType)
        let watchOnlyAddressArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES) as! NSArray
        let addressDict = watchOnlyAddressArray.object(at: idx) as! NSMutableDictionary
        
        let status = archive ? TLAddressStatus.archived : TLAddressStatus.active
        addressDict.setObject(status.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    
    func getWatchOnlyAddressArray(_ coinType: TLCoinType) -> (NSArray) {
        let importedKeysDict = getImportedKeysDict(coinType)
        
        let importedAddresses = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES) as! NSArray
        let importedAddressesObjectArray = NSMutableArray(capacity: importedAddresses.count)
        
        for addressDict in importedAddresses as! [NSDictionary] {
            let importedAddressObject = TLImportedAddress(appWallet: self, dict: addressDict)
            importedAddressesObjectArray.add(importedAddressObject)
        }
        
        return importedAddressesObjectArray
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------------------------------------------------------
    
    func getAddressBook(_ coinType: TLCoinType) -> (NSArray) {
        return self.getCurrentWallet(coinType).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS_BOOK) as! NSArray
    }
    
    func addAddressBookEntry(_ coinType: TLCoinType, address: String, label: String) -> () {
        let addressBookArray = getCurrentWallet(coinType).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS_BOOK) as! NSMutableArray
        addressBookArray.add([TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS: address, TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL: label])
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func getLabelForAddress(_ coinType: TLCoinType, address: String) -> String? { //if duplicate labels return first one
        let addressBookArray = getCurrentWallet(coinType).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS_BOOK) as! NSMutableArray
        for i in stride(from: 0, to: addressBookArray.count, by: 1) {
            let addressBook: NSDictionary = addressBookArray.object(at: i) as! NSDictionary
            if address == addressBook.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String {
                return addressBook.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL) as? String
            }
        }
        return nil
    }
    
    func editAddressBookEntry(_ coinType: TLCoinType, index: Int, label: String) -> () {
        let addressBookArray = getCurrentWallet(coinType).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS_BOOK) as! NSMutableArray
        let oldEntry = addressBookArray.object(at: index) as! NSDictionary
        addressBookArray.replaceObject(at: index, with: [TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS: oldEntry.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String, TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL: label])
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func deleteAddressBookEntry(_ coinType: TLCoinType, idx: Int) -> () {
        let addressBookArray = getCurrentWallet(coinType).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS_BOOK) as! NSMutableArray
        addressBookArray.removeObject(at: idx)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func setTransactionTag(_ coinType: TLCoinType, txid: String, tag: String) -> () {
        let transactionLabelDict = getCurrentWallet(coinType).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TRANSACTION_TAGS) as! NSMutableDictionary
        transactionLabelDict.setObject(tag, forKey: txid as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func deleteTransactionTag(_ coinType: TLCoinType, txid: String) -> () {
        let transactionLabelDict = getCurrentWallet(coinType).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TRANSACTION_TAGS) as! NSMutableDictionary
        transactionLabelDict.removeObject(forKey: txid)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func getTransactionTag(_ coinType: TLCoinType, txid: String) -> String? {
        let transactionLabelDict = getCurrentWallet(coinType).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TRANSACTION_TAGS) as! NSDictionary
        return transactionLabelDict.object(forKey: txid) as! String?
    }
    
    
    fileprivate func createNewWallet(_ passphrase: String, masterHex: String, walletName: String) -> () {
        let walletsArray = getWallets()
        let walletDict = createWallet(passphrase, masterHex: masterHex, walletName: walletName)
        walletsArray.add(walletDict)
    }
    
    func createInitialWalletPayload(_ passphrase: String, masterHex: String) -> () {
        self.masterHex = masterHex
        
        rootDict = NSMutableDictionary()
        let walletsArray = NSMutableArray()
        rootDict!.setValue(TLWalletJSONKeys.getLastestVersion(), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_VERSION)
        
        let payload = NSMutableDictionary()
        rootDict!.setValue(payload, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYLOAD)
        
        payload.setValue(walletsArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_WALLETS)
        createNewWallet(passphrase, masterHex: masterHex, walletName: "default")
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func loadWalletPayload(_ walletPayload: NSDictionary, masterHex: String) -> () {
        self.masterHex = masterHex
        
        rootDict = NSMutableDictionary(dictionary: walletPayload)
        func loadWalletPayloadForCoin(_ coinType: TLCoinType) {
            let walletDict = getCurrentWallet(coinType).mutableCopy() as! NSMutableDictionary
            
            let accountsArray = getAccountsArray(coinType).mutableCopy() as! NSMutableArray
            for i in stride(from: 0, to: accountsArray.count, by: 1) {
                let accountDict: NSMutableDictionary = (accountsArray.object(at: i) as! NSDictionary).mutableCopy() as! NSMutableDictionary
                accountsArray.replaceObject(at: i, with: accountDict)
            }
            DLog(String(format: "loadWalletPayload rootDict: 1 \n%@", rootDict!.description))

            let importedKeysDict = getImportedKeysDict(coinType).mutableCopy() as! NSMutableDictionary
            
            walletDict.setObject(importedKeysDict, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTS as NSCopying)

            let coldWalletAccountsArray: AnyObject = (importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_COLD_WALLET_ACCOUNTS) as! NSArray).mutableCopy() as AnyObject
            importedKeysDict.setObject(coldWalletAccountsArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_COLD_WALLET_ACCOUNTS as NSCopying)
            
            let importedAccountsArray: AnyObject = (importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS) as! NSArray).mutableCopy() as AnyObject
            importedKeysDict.setObject(importedAccountsArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS as NSCopying)
            
            let watchOnlyAccountsArray: AnyObject = (importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS) as! NSArray).mutableCopy() as AnyObject
            importedKeysDict.setObject(watchOnlyAccountsArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS as NSCopying)
            
            let importedPrivateKeysArray: AnyObject = (importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSArray).mutableCopy() as AnyObject
            importedKeysDict.setObject(importedPrivateKeysArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS as NSCopying)
            
            let watchOnlyAddressesArray: AnyObject = (importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES) as! NSArray).mutableCopy() as AnyObject
            importedKeysDict.setObject(watchOnlyAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES as NSCopying)
        }
        let version = rootDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_VERSION) as! String
        if version == TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_VERSION_TWO {
            loadWalletPayloadForCoin(TLCoinType.BTC)
        } else {
            TLWalletUtils.SUPPORT_COIN_TYPES().forEach({ (coinType) in
                loadWalletPayloadForCoin(coinType)
            })
        }
    }
    
    func getWalletsJson() -> (NSDictionary?) {
        return rootDict?.copy() as? NSDictionary
    }
    
    func getWalletJsonVersion() -> String {
        return rootDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_VERSION) as! String
    }
    
    fileprivate func getWallets() -> (NSMutableArray) {
        return (rootDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYLOAD) as! NSDictionary).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_WALLETS) as! NSMutableArray
    }
    
    fileprivate func getFirstWallet(_ coinType: TLCoinType) -> (NSMutableDictionary) {
        let version = rootDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_VERSION) as! String
        if version == TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_VERSION_TWO {
            return getWallets().object(at: 0) as! NSMutableDictionary
        } else {
            if coinType == TLCoinType.BCH {
                return (getWallets().object(at: 0) as! NSMutableDictionary).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_BITCOIN_CASH) as! NSMutableDictionary
            } else {
                return (getWallets().object(at: 0) as! NSMutableDictionary).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_BITCOIN) as! NSMutableDictionary
            }
        }
    }
    
    
    fileprivate func getCurrentWallet(_ coinType: TLCoinType) -> (NSMutableDictionary) {
        return getFirstWallet(coinType)
    }
    
    fileprivate func getHDWallet(_ coinType: TLCoinType) -> (NSMutableDictionary) {
        return (getCurrentWallet(coinType).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_HDWALLETS) as! NSArray).object(at: 0) as! NSMutableDictionary
    }
    
    func renameAccount(_ coinType: TLCoinType, accountIdxNumber: Int, accountName: String) -> (Bool) {
        let accountsArray = getAccountsArray(coinType)
        let accountDict = accountsArray.object(at: accountIdxNumber) as! NSMutableDictionary
        accountDict.setObject(accountName, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
        
        return true
    }
    
    func getAccountObjectArray(_ coinType: TLCoinType) -> (NSArray) {
        let accountsArray = getAccountsArray(coinType)
        
        let accountObjectArray = NSMutableArray()
        for accountDict in accountsArray {
            let accountObject = TLAccountObject(appWallet: self, coinType: coinType, dict: accountDict as! NSDictionary, accountType: .hdWallet)
            accountObjectArray.add(accountObject)
        }
        return accountObjectArray
    }
    
    fileprivate func getAccountObjectForIdx(_ coinType: TLCoinType, accountIdx: Int) -> (TLAccountObject) {
        let accountsArray = getAccountsArray(coinType)
        let accountDict = accountsArray.object(at: accountIdx) as! NSDictionary
        return TLAccountObject(appWallet: self, coinType: coinType, dict: accountDict, accountType: .hdWallet)
    }
    
    func updateWalletJSONToV3() {
        let walletV2 = self.getFirstWallet(TLCoinType.BTC)
        let walletV3 = NSMutableDictionary()
        TLWalletUtils.SUPPORT_COIN_TYPES().forEach({ (coinType) in
            switch coinType {
            case .BTC:
                walletV3.setObject(walletV2, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_BITCOIN as NSCopying)
            case .BCH:
                let coinWalletDict = createWalletDictForCoin()
                walletV3.setObject(coinWalletDict, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_BITCOIN_CASH as NSCopying)
            }
        })
        let walletsArray = getWallets()
        walletsArray.removeAllObjects()
        walletsArray.add(walletV3)
        rootDict!.setValue(TLWalletJSONKeys.getLastestVersion(), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_VERSION)
    }
}



