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
            for i in stride(from: 0, through: TLAccountObject.MAX_ACCOUNT_WAIT_TO_RECEIVE_ADDRESS(), by: 1) {
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
    
    
    internal func getAccountDict(_ accountIdx: Int) -> (NSMutableDictionary) {
        let accountsArray = getAccountsArray()
        let accountDict = accountsArray.object(at: accountIdx) as! NSMutableDictionary
        return accountDict
    }
    
    //----------------------------------------------------------------------------------------------------------------
    
    func clearAllAddressesFromHDWallet(_ accountIdx: Int) -> () {
        let accountDict = getAccountDict(accountIdx)
        let mainAddressesArray = NSMutableArray()
        accountDict.setObject(mainAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES as NSCopying)
        let changeAddressesArray = NSMutableArray()
        accountDict.setObject(changeAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES as NSCopying)
        accountDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX as NSCopying)
        accountDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX as NSCopying)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func clearAllAddressesFromColdWalletAccount(_ idx: Int) -> () {
        let accountDict = getColdWalletAccountAtIndex(idx)
        let mainAddressesArray = NSMutableArray()
        accountDict.setObject(mainAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES as NSCopying)
        let changeAddressesArray = NSMutableArray()
        accountDict.setObject(changeAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES as NSCopying)
        accountDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX as NSCopying)
        accountDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func clearAllAddressesFromImportedAccount(_ idx: Int) -> () {
        let accountDict = getImportedAccountAtIndex(idx)
        let mainAddressesArray = NSMutableArray()
        accountDict.setObject(mainAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES as NSCopying)
        let changeAddressesArray = NSMutableArray()
        accountDict.setObject(changeAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES as NSCopying)
        accountDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX as NSCopying)
        accountDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func clearAllAddressesFromImportedWatchAccount(_ idx: Int) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        let mainAddressesArray = NSMutableArray()
        accountDict.setObject(mainAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAIN_ADDRESSES as NSCopying)
        let changeAddressesArray = NSMutableArray()
        accountDict.setObject(changeAddressesArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES as NSCopying)
        accountDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX as NSCopying)
        accountDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    //----------------------------------------------------------------------------------------------------------------
    func updateAccountNeedsRecoveringFromHDWallet(_ accountIdx: Int, accountNeedsRecovering: Bool) -> () {
        let accountDict = getAccountDict(accountIdx)
        accountDict.setObject(accountNeedsRecovering, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func updateAccountNeedsRecoveringFromColdWalletAccount(_ idx: Int, accountNeedsRecovering: Bool) -> () {
        let accountDict = getColdWalletAccountAtIndex(idx)
        accountDict.setObject(accountNeedsRecovering, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func updateAccountNeedsRecoveringFromImportedAccount(_ idx: Int, accountNeedsRecovering: Bool) -> () {
        let accountDict = getImportedAccountAtIndex(idx)
        accountDict.setObject(accountNeedsRecovering, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func updateAccountNeedsRecoveringFromImportedWatchAccount(_ idx: Int, accountNeedsRecovering: Bool) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        accountDict.setObject(accountNeedsRecovering, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    //----------------------------------------------------------------------------------------------------------------
    
    
    func updateMainAddressStatusFromHDWallet(_ accountIdx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            let accountDict = getAccountDict(accountIdx)
            self.updateMainAddressStatus(accountDict,
                addressIdx: addressIdx,
                addressStatus: addressStatus)
    }
    
    func updateMainAddressStatusFromColdWalletAccount(_ idx: Int, addressIdx: Int,
                                                         addressStatus: TLAddressStatus) -> () {
        let accountDict = getColdWalletAccountAtIndex(idx)
        self.updateMainAddressStatus(accountDict,
                                     addressIdx: addressIdx,
                                     addressStatus: addressStatus)
    }
    
    func updateMainAddressStatusFromImportedAccount(_ idx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            let accountDict = getImportedAccountAtIndex(idx)
            self.updateMainAddressStatus(accountDict,
                addressIdx: addressIdx,
                addressStatus: addressStatus)
    }
    
    func updateMainAddressStatusFromImportedWatchAccount(_ idx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
            self.updateMainAddressStatus(accountDict,
                addressIdx: addressIdx,
                addressStatus: addressStatus)
    }
    
    func updateMainAddressStatus(_ accountDict: NSMutableDictionary, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            
            let minMainAddressIdx = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX) as! UInt
            
            DLog("updateMainAddressStatus accountIdx \(accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int)")
            DLog("updateMainAddressStatus minMainAddressIdx \(minMainAddressIdx) addressIdx: \(addressIdx)")
            
            assert(UInt(addressIdx) == minMainAddressIdx, "addressIdx != minMainAddressIdx")
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
    
    func updateChangeAddressStatusFromHDWallet(_ accountIdx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            let accountDict = getAccountDict(accountIdx)
            self.updateChangeAddressStatus(accountDict,
                addressIdx: addressIdx,
                addressStatus: addressStatus)
    }
    
    func updateChangeAddressStatusFromImportedAccount(_ idx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            let accountDict = getImportedAccountAtIndex(idx)
            self.updateChangeAddressStatus(accountDict,
                addressIdx: addressIdx,
                addressStatus: addressStatus)
    }
    
    func updateChangeAddressStatusFromColdWalletAccount(_ idx: Int, addressIdx: Int,
                                                           addressStatus: TLAddressStatus) -> () {
        let accountDict = getColdWalletAccountAtIndex(idx)
        self.updateChangeAddressStatus(accountDict,
                                       addressIdx: addressIdx,
                                       addressStatus: addressStatus)
    }
    
    func updateChangeAddressStatusFromImportedWatchAccount(_ idx: Int, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
            self.updateChangeAddressStatus(accountDict,
                addressIdx: addressIdx,
                addressStatus: addressStatus)
    }
    
    func updateChangeAddressStatus(_ accountDict: NSMutableDictionary, addressIdx: Int,
        addressStatus: TLAddressStatus) -> () {
            
            let minChangeAddressIdx = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX) as! UInt
            
            DLog("updateChangeAddressStatus accountIdx \(accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_ACCOUNT_IDX) as! Int)")
            DLog("updateChangeAddressStatus minChangeAddressIdx \(minChangeAddressIdx) addressIdx: \(addressIdx)")
            
            assert(UInt(addressIdx) == minChangeAddressIdx, "addressIdx != minChangeAddressIdx")
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
    func getMinMainAddressIdxFromHDWallet(_ accountIdx: Int) -> Int {
        let accountDict = getAccountDict(accountIdx)
        return self.getMinMainAddressIdx(accountDict)
    }
    
    func getMinMainAddressIdxFromColdWalletAccount(_ idx: Int) -> (Int) {
        let accountDict = getColdWalletAccountAtIndex(idx)
        return self.getMinMainAddressIdx(accountDict)
    }
    
    func getMinMainAddressIdxFromImportedAccount(_ idx: Int) -> (Int) {
        let accountDict = getImportedAccountAtIndex(idx)
        return self.getMinMainAddressIdx(accountDict)
    }
    
    func getMinMainAddressIdxFromImportedWatchAccount(_ idx: Int) -> (Int) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        return self.getMinMainAddressIdx(accountDict)
    }
    
    func getMinMainAddressIdx(_ accountDict: NSMutableDictionary) -> (Int) {
        return accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX) as! Int
    }
    
    func getMinChangeAddressIdxFromHDWallet(_ accountIdx: Int) -> (Int) {
        let accountDict = getAccountDict(accountIdx)
        return self.getMinChangeAddressIdx(accountDict) as Int
    }
    
    func getMinChangeAddressIdxFromColdWalletAccount(_ idx: Int) -> (Int) {
        let accountDict = getColdWalletAccountAtIndex(idx)
        return self.getMinChangeAddressIdx(accountDict) as Int
    }
    
    func getMinChangeAddressIdxFromImportedAccount(_ idx: Int) -> (Int) {
        let accountDict = getImportedAccountAtIndex(idx)
        return self.getMinChangeAddressIdx(accountDict) as Int
    }
    
    func getMinChangeAddressIdxFromImportedWatchAccount(_ idx: Int) -> (Int) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        return self.getMinChangeAddressIdx(accountDict) as Int
    }
    
    func getMinChangeAddressIdx(_ accountDict: NSMutableDictionary) -> (Int) {
        return accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX) as! Int
    }
    
    //----------------------------------------------------------------------------------------------------------------
    
    func getNewMainAddressFromHDWallet(_ accountIdx: Int, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getAccountDict(accountIdx)
        return getNewMainAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    func getNewMainAddressFromColdWalletAccount(_ idx: Int, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getColdWalletAccountAtIndex(idx)
        return getNewMainAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    func getNewMainAddressFromImportedAccount(_ idx: Int, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getImportedAccountAtIndex(idx)
        return getNewMainAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    func getNewMainAddressFromImportedWatchAccount(_ idx: Int, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
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
    func getNewChangeAddressFromHDWallet(_ accountIdx: Int, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getAccountDict(accountIdx)
        return getNewChangeAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    func getNewChangeAddressFromColdWalletAccount(_ idx: UInt, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getColdWalletAccountAtIndex(Int(idx))
        return getNewChangeAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    func getNewChangeAddressFromImportedAccount(_ idx: Int, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getImportedAccountAtIndex(idx)
        return getNewChangeAddress(accountDict, expectedAddressIndex: expectedAddressIndex)
    }
    
    func getNewChangeAddressFromImportedWatchAccount(_ idx: UInt, expectedAddressIndex: Int) -> (NSDictionary) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(Int(idx))
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
    func removeTopMainAddressFromHDWallet(_ accountIdx: Int) -> (String?) {
        let accountDict = getAccountDict(accountIdx)
        return removeTopMainAddress(accountDict)
    }
    
    func removeTopMainAddressFromColdWalletAccount(_ idx: Int) -> (String?) {
        let accountDict = getColdWalletAccountAtIndex(idx)
        return removeTopMainAddress(accountDict)
    }
    
    func removeTopMainAddressFromImportedAccount(_ idx: Int) -> (String?) {
        let accountDict = getImportedAccountAtIndex(idx)
        return removeTopMainAddress(accountDict)
    }
    
    func removeTopMainAddressFromImportedWatchAccount(_ idx: Int) -> (String?) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
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
    func removeTopChangeAddressFromHDWallet(_ accountIdx: Int) -> (String?) {
        let accountDict = getAccountDict(accountIdx)
        return removeTopChangeAddress(accountDict)
    }
    
    func removeTopChangeAddressFromColdWalletAccount(_ idx: Int) -> (String?) {
        let accountDict = getColdWalletAccountAtIndex(idx)
        return removeTopChangeAddress(accountDict)
    }

    func removeTopChangeAddressFromImportedAccount(_ idx: Int) -> (String?) {
        let accountDict = getImportedAccountAtIndex(idx)
        return removeTopChangeAddress(accountDict)
    }
    
    func removeTopChangeAddressFromImportedWatchAccount(_ idx: Int) -> (String?) {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
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
    
    func archiveAccountHDWallet(_ accountIdx: Int, enabled: Bool) -> () {
        let accountsArray = getAccountsArray()
        assert(accountsArray.count > 1, "")
        let accountDict = accountsArray.object(at: accountIdx) as! NSDictionary
        let status = enabled ? TLAddressStatus.archived : TLAddressStatus.active
        accountDict.setValue(status.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func archiveAccountColdWalletAccount(_ idx: Int, enabled: Bool) -> () {
        let accountDict = getColdWalletAccountAtIndex(idx)
        let status = enabled ? TLAddressStatus.archived : TLAddressStatus.active
        accountDict.setValue(status.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func archiveAccountImportedAccount(_ idx: Int, enabled: Bool) -> () {
        let accountDict = getImportedAccountAtIndex(idx)
        let status = enabled ? TLAddressStatus.archived : TLAddressStatus.active
        accountDict.setValue(status.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func archiveAccountImportedWatchAccount(_ idx: Int, enabled: Bool) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        let status = enabled ? TLAddressStatus.archived : TLAddressStatus.active
        accountDict.setValue(status.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }

    //----------------------------------------------------------------------------------------------------------------
    
    fileprivate func getAccountsArray() -> NSMutableArray {
        let hdWalletDict = getHDWallet()
        let accountsArray = hdWalletDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ACCOUNTS) as! NSMutableArray
        return accountsArray
    }
    
    func removeTopAccount() -> (Bool) {
        let accountsArray = getAccountsArray()
        if (accountsArray.count > 0) {
            accountsArray.removeLastObject()
            let hdWalletDict = getHDWallet()
            let maxAccountIDCreated = hdWalletDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAX_ACCOUNTS_CREATED) as! Int
            hdWalletDict.setObject((maxAccountIDCreated - 1), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAX_ACCOUNTS_CREATED as NSCopying)
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
            return true
        }
        
        return false
    }
    
    fileprivate func createNewAccount(_ accountName: String, accountType: TLAccount) -> (TLAccountObject) {
        return createNewAccount(accountName, accountType: accountType, preloadStartingAddresses: true)
    }
    
    func createNewAccount(_ accountName: String, accountType: TLAccount, preloadStartingAddresses: Bool) -> TLAccountObject {
            assert(self.masterHex != nil, "")
            let hdWalletDict = getHDWallet()
            let accountsArray = getAccountsArray()
            let maxAccountIDCreated = hdWalletDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAX_ACCOUNTS_CREATED) as! UInt
            let extendPrivKey = TLHDWalletWrapper.getExtendPrivKey(self.masterHex!, accountIdx: maxAccountIDCreated)
            let accountDict = createAccountDictWithPreload(accountName, extendedKey: extendPrivKey,
                isPrivateExtendedKey: true, accountIdx: Int(maxAccountIDCreated), preloadStartingAddresses: preloadStartingAddresses)
            accountsArray.add(accountDict)
            hdWalletDict.setObject((maxAccountIDCreated + 1), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAX_ACCOUNTS_CREATED as NSCopying)
        
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
        
            if (getCurrentAccountID() == nil) {
                setCurrentAccountID("0")
            }
            
            return TLAccountObject(appWallet: self, dict: accountDict, accountType: .hdWallet)
    }
    
    fileprivate func createWallet(_ passphrase: String, masterHex: String, walletName: String) -> (NSMutableDictionary) {
        let createdWalletDict = NSMutableDictionary()
        
        let hdWalletDict = NSMutableDictionary()
        hdWalletDict.setObject(walletName, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME as NSCopying)
        hdWalletDict.setObject(masterHex, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MASTER_HEX as NSCopying)
        hdWalletDict.setObject(passphrase, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PASSPHRASE as NSCopying)
        
        hdWalletDict.setObject(0, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_MAX_ACCOUNTS_CREATED as NSCopying)
        
        let accountsArray = NSMutableArray()
        hdWalletDict.setObject(accountsArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ACCOUNTS as NSCopying)
        let hdWalletsArray = NSMutableArray()
        hdWalletsArray.add(hdWalletDict)
        
        createdWalletDict.setValue(hdWalletsArray, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_HDWALLETS)
        
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
        
        
        createdWalletDict.setObject(importedKeysDict, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTS as NSCopying)
        
        return createdWalletDict
    }
    
    fileprivate func getImportedKeysDict() -> (NSMutableDictionary) {
        let hdWallet = getCurrentWallet()
        return hdWallet.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTS) as! NSMutableDictionary
    }
    
    internal func getColdWalletAccountAtIndex(_ idx: Int) -> (NSMutableDictionary) {
        let importedKeysDict = getImportedKeysDict()
        let coldWalletAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_COLD_WALLET_ACCOUNTS) as! NSArray
        let accountDict = coldWalletAccountsArray.object(at: idx) as! NSMutableDictionary
        return accountDict
    }
    
    internal func getImportedAccountAtIndex(_ idx: Int) -> (NSMutableDictionary) {
        let importedKeysDict = getImportedKeysDict()
        let importedAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS) as! NSArray
        
        let accountDict = importedAccountsArray.object(at: idx) as! NSMutableDictionary
        return accountDict
    }
    
    internal func getImportedWatchOnlyAccountAtIndex(_ idx: Int) -> (NSMutableDictionary) {
        let importedKeysDict = getImportedKeysDict()
        let watchOnlyAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS) as! NSArray
        let accountDict = watchOnlyAccountsArray.object(at: idx) as! NSMutableDictionary
        return accountDict
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------------------------------------------------------
    
    func addColdWalletAccount(_ extendedPublicKey: String) -> (TLAccountObject) {
        let importedKeysDict = getImportedKeysDict()
        let coldWalletAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_COLD_WALLET_ACCOUNTS) as! NSMutableArray
        
        let accountIdx = coldWalletAccountsArray.count // "accountIdx" key is different for ImportedAccount then hdwallet account
        let coldWalletAccountDict = createAccountDictWithPreload("", extendedKey: extendedPublicKey, isPrivateExtendedKey: false, accountIdx: accountIdx, preloadStartingAddresses: false)
        coldWalletAccountsArray.add(coldWalletAccountDict)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
        return TLAccountObject(appWallet: self, dict: coldWalletAccountDict, accountType: .coldWallet)
    }
    
    func deleteColdWalletAccount(_ idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let coldWalletAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_COLD_WALLET_ACCOUNTS) as! NSMutableArray
        
        coldWalletAccountsArray.removeObject(at: idx)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func setColdWalletAccountName(_ name: String, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let coldWalletAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_COLD_WALLET_ACCOUNTS) as! NSArray
        
        let accountDict = coldWalletAccountsArray.object(at: idx) as! NSMutableDictionary
        accountDict.setObject(name, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func getColdWalletAccountArray() -> (NSArray) {
        let importedKeysDict = getImportedKeysDict()
        let accountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_COLD_WALLET_ACCOUNTS) as! NSArray
        
        
        let accountObjectArray = NSMutableArray()
        for accountDict in accountsArray as! [NSDictionary] {
            let accountObject = TLAccountObject(appWallet: self, dict: accountDict, accountType: .coldWallet)
            accountObjectArray.add(accountObject)
        }
        return accountObjectArray
    }

    func addImportedAccount(_ extendedPrivateKey: String) -> (TLAccountObject) {
        let importedKeysDict = getImportedKeysDict()
        let importedAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS) as! NSMutableArray
        
        let accountIdx = importedAccountsArray.count // "accountIdx" key is different for ImportedAccount then hdwallet account
        let accountDict = createAccountDictWithPreload("", extendedKey: extendedPrivateKey, isPrivateExtendedKey: true, accountIdx: accountIdx, preloadStartingAddresses: false)
        importedAccountsArray.add(accountDict)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
        
        return TLAccountObject(appWallet: self, dict: accountDict, accountType: .imported)
    }
    
    func deleteImportedAccount(_ idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let importedAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS) as! NSMutableArray
        
        importedAccountsArray.removeObject(at: idx)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func setImportedAccountName(_ name: String, idx: Int) -> () {
        let accountDict = getImportedAccountAtIndex(idx)
        accountDict.setObject(name, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func getImportedAccountArray() -> (NSArray) {
        let importedKeysDict = getImportedKeysDict()
        let accountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_ACCOUNTS) as! NSArray
        
        
        let accountObjectArray = NSMutableArray()
        for accountDict in accountsArray as! [NSDictionary] {
            let accountObject = TLAccountObject(appWallet: self, dict: accountDict, accountType: .imported)
            accountObjectArray.add(accountObject)
            
            
        }
        return accountObjectArray
    }
    
    func addWatchOnlyAccount(_ extendedPublicKey: String) -> (TLAccountObject) {
        let importedKeysDict = getImportedKeysDict()
        let watchOnlyAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS) as! NSMutableArray
        
        let accountIdx = watchOnlyAccountsArray.count // "accountIdx" key is different for ImportedAccount then hdwallet account
        let watchOnlyAccountDict = createAccountDictWithPreload("", extendedKey: extendedPublicKey, isPrivateExtendedKey: false, accountIdx: accountIdx, preloadStartingAddresses: false)
        watchOnlyAccountsArray.add(watchOnlyAccountDict)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
        return TLAccountObject(appWallet: self, dict: watchOnlyAccountDict, accountType: .importedWatch)
    }
    
    func deleteWatchOnlyAccount(_ idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let watchOnlyAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS) as! NSMutableArray
        
        watchOnlyAccountsArray.removeObject(at: idx)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func setWatchOnlyAccountName(_ name: String, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let watchOnlyAccountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS) as! NSArray
        
        let accountDict = watchOnlyAccountsArray.object(at: idx) as! NSMutableDictionary
        accountDict.setObject(name, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func getWatchOnlyAccountArray() -> (NSArray) {
        let importedKeysDict = getImportedKeysDict()
        let accountsArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS) as! NSArray
        
        
        let accountObjectArray = NSMutableArray()
        for accountDict in accountsArray as! [NSDictionary] {
            let accountObject = TLAccountObject(appWallet: self, dict: accountDict, accountType: .importedWatch)
            accountObjectArray.add(accountObject)
        }
        return accountObjectArray
    }
    
    func addImportedPrivateKey(_ privateKey: String, encryptedPrivateKey: String?) -> (NSDictionary) {
        let importedKeysDict = getImportedKeysDict()
        let importedPrivateKeyArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSMutableArray
        
        var importedPrivateKey = NSDictionary()
        if (encryptedPrivateKey == nil) {
            importedPrivateKey = [
                TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_KEY: privateKey,
                TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS: TLCoreBitcoinWrapper.getAddress(privateKey, isTestnet: self.walletConfig.isTestnet)!,
                TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL: String(""),
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
    
    func deleteImportedPrivateKey(_ idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let importedPrivateKeyArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSMutableArray
        
        importedPrivateKeyArray.removeObject(at: idx)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func setImportedPrivateKeyLabel(_ label: String, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let importedPrivateKeyArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSArray
        
        let privateKeyDict = importedPrivateKeyArray.object(at: idx) as! NSMutableDictionary
        privateKeyDict.setObject(label, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func setImportedPrivateKeyArchive(_ archive: Bool, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let importedPrivateKeyArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSArray
        let privateKeyDict = importedPrivateKeyArray.object(at: idx) as! NSMutableDictionary
        
        let status = archive ? TLAddressStatus.archived : TLAddressStatus.active
        privateKeyDict.setObject(status.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func getImportedPrivateKeyArray() -> (NSArray) {
        let importedKeysDict = getImportedKeysDict()
        
        let importedAddresses = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS) as! NSArray
        let importedAddressesObjectArray = NSMutableArray(capacity: importedAddresses.count)
        
        for addressDict in importedAddresses as! [NSDictionary] {
            let importedAddressObject = TLImportedAddress(appWallet: self, dict: addressDict)
            importedAddressesObjectArray.add(importedAddressObject)
        }
        return importedAddressesObjectArray
    }
    
    func addWatchOnlyAddress(_ address: NSString) -> (NSDictionary) {
        let importedKeysDict = getImportedKeysDict()
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
    
    func deleteImportedWatchAddress(_ idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let watchOnlyAddressArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES) as! NSMutableArray
        
        watchOnlyAddressArray.removeObject(at: idx)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    
    func setWatchOnlyAddressLabel(_ label: String, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let watchOnlyAddressArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES) as! NSArray
        let addressDict = watchOnlyAddressArray.object(at: idx) as! NSMutableDictionary
        addressDict.setObject(label, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func setWatchOnlyAddressArchive(_ archive: Bool, idx: Int) -> () {
        let importedKeysDict = getImportedKeysDict()
        let watchOnlyAddressArray = importedKeysDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES) as! NSArray
        let addressDict = watchOnlyAddressArray.object(at: idx) as! NSMutableDictionary
        
        let status = archive ? TLAddressStatus.archived : TLAddressStatus.active
        addressDict.setObject(status.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    
    func getWatchOnlyAddressArray() -> (NSArray) {
        let importedKeysDict = getImportedKeysDict()
        
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
    
    func getAddressBook() -> (NSArray) {
        return self.getCurrentWallet().object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS_BOOK) as! NSArray
    }
    
    func addAddressBookEntry(_ address: String, label: String) -> () {
        let addressBookArray = getCurrentWallet().object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS_BOOK) as! NSMutableArray
        addressBookArray.add([TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS: address, TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL: label])
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func getLabelForAddress(_ address: String) -> String? { //if duplicate labels return first one
        let addressBookArray = getCurrentWallet().object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS_BOOK) as! NSMutableArray
        for i in stride(from: 0, through: addressBookArray.count, by: 1) {
            let addressBook: NSDictionary = addressBookArray.object(at: i) as! NSDictionary
            if address == addressBook.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String {
                return addressBook.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL) as? String
            }
        }
        return nil
    }
    
    func editAddressBookEntry(_ index: Int, label: String) -> () {
        let addressBookArray = getCurrentWallet().object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS_BOOK) as! NSMutableArray
        let oldEntry = addressBookArray.object(at: index) as! NSDictionary
        addressBookArray.replaceObject(at: index, with: [TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS: oldEntry.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as! String, TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL: label])
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func deleteAddressBookEntry(_ idx: Int) -> () {
        let addressBookArray = getCurrentWallet().object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS_BOOK) as! NSMutableArray
        addressBookArray.removeObject(at: idx)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func setTransactionTag(_ txid: String, tag: String) -> () {
        let transactionLabelDict = getCurrentWallet().object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TRANSACTION_TAGS) as! NSMutableDictionary
        transactionLabelDict.setObject(tag, forKey: txid as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func deleteTransactionTag(_ txid: String) -> () {
        let transactionLabelDict = getCurrentWallet().object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TRANSACTION_TAGS) as! NSMutableDictionary
        transactionLabelDict.removeObject(forKey: txid)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func getTransactionTag(_ txid: String) -> String? {
        let transactionLabelDict = getCurrentWallet().object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TRANSACTION_TAGS) as! NSDictionary
        return transactionLabelDict.object(forKey: txid) as! String?
    }
    
    
    fileprivate func createNewWallet(_ passphrase: String, masterHex: String, walletName: String) -> () {
        let walletsArray = getWallets()
        
        let walletDict = createWallet(passphrase, masterHex: masterHex, walletName: walletName)
        walletDict.setValue(NSMutableArray(), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS_BOOK)
        walletDict.setValue(NSMutableDictionary(), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TRANSACTION_TAGS)
        
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
        let walletDict = getCurrentWallet().mutableCopy() as! NSMutableDictionary
        
        let accountsArray = getAccountsArray().mutableCopy() as! NSMutableArray
        for i in stride(from: 0, through: accountsArray.count, by: 1) {
            let accountDict: NSMutableDictionary = (accountsArray.object(at: i) as! NSDictionary).mutableCopy() as! NSMutableDictionary
            accountsArray.replaceObject(at: i, with: accountDict)
        }
        DLog(String(format: "loadWalletPayload rootDict: 1 \n%@", rootDict!.description))

        // migrate to version 2 of wallet payload
        let version = rootDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_VERSION) as! String
        if version == TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_VERSION_ONE {
            rootDict!.setObject(TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_VERSION_TWO, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_VERSION as NSCopying)
            getImportedKeysDict().setObject(NSMutableArray(), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_COLD_WALLET_ACCOUNTS as NSCopying)
            getCurrentWallet().setObject(getImportedKeysDict(), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_IMPORTS as NSCopying)
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
        }
        
        let importedKeysDict = getImportedKeysDict().mutableCopy() as! NSMutableDictionary
        
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
    
    func getWalletsJson() -> (NSDictionary?) {
        return rootDict?.copy() as? NSDictionary
    }
    
    fileprivate func getWallets() -> (NSMutableArray) {
        return (rootDict!.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYLOAD) as! NSDictionary).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_WALLETS) as! NSMutableArray
    }
    
    fileprivate func getFirstWallet() -> (NSMutableDictionary) {
        return getWallets().object(at: 0) as! NSMutableDictionary
    }
    
    
    fileprivate func getCurrentWallet() -> (NSMutableDictionary) {
        return getFirstWallet()
    }
    
    fileprivate func getHDWallet() -> (NSMutableDictionary) {
        return (getCurrentWallet().object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_HDWALLETS) as! NSArray).object(at: 0) as! NSMutableDictionary
    }
    
    fileprivate func getCurrentAccountID() -> (String?) {
        let hdWallet = getHDWallet()
        return hdWallet.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_CURRENT_ACCOUNT_ID) as? String
    }
    
    fileprivate func setCurrentAccountID(_ accountID: String) -> () {
        let hdWallet = getHDWallet()
        hdWallet.setObject(accountID, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_CURRENT_ACCOUNT_ID as NSCopying)
    }
    
    func renameAccount(_ accountIdxNumber: Int, accountName: String) -> (Bool) {
        let accountsArray = getAccountsArray()
        let accountDict = accountsArray.object(at: accountIdxNumber) as! NSMutableDictionary
        accountDict.setObject(accountName, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_NAME as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
        
        return true
    }
    
    func getAccountObjectArray() -> (NSArray) {
        let accountsArray = getAccountsArray()
        
        let accountObjectArray = NSMutableArray()
        for accountDict in accountsArray {
            let accountObject = TLAccountObject(appWallet: self, dict: accountDict as! NSDictionary, accountType: .hdWallet)
            accountObjectArray.add(accountObject)
        }
        return accountObjectArray
    }
    
    fileprivate func getAccountObjectForIdx(_ accountIdx: Int) -> (TLAccountObject) {
        let accountsArray = getAccountsArray()
        let accountDict = accountsArray.object(at: accountIdx) as! NSDictionary
        return TLAccountObject(appWallet: self, dict: accountDict, accountType: .hdWallet)
    }
}



