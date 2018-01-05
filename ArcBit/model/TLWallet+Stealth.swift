//
//  TLWallet+Stealth.swift
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

extension TLWallet {
    
    func setStealthAddressServerStatus(_ accountDict: NSMutableDictionary, serverURL: String, isWatching: Bool) -> () {
        let stealthAddressArray = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES) as! NSMutableArray
        let stealthAddressServersDict = (stealthAddressArray.object(at: 0) as! NSDictionary).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_SERVERS) as! NSMutableDictionary
        
        if let stealthServerDict = stealthAddressServersDict.object(forKey: serverURL) as? NSMutableDictionary  {
            stealthServerDict.setObject(isWatching, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_WATCHING as NSCopying)
        } else {
            let serverAttributes = [
                TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_WATCHING: isWatching,
            ]
            let serverAttributesDict = NSMutableDictionary(dictionary: serverAttributes)
            stealthAddressServersDict.setObject(serverAttributesDict, forKey: serverURL as NSCopying)
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func setStealthAddressServerStatusHDWallet(_ coinType: TLCoinType, accountIdx: Int, serverURL: String, isWatching: Bool) -> () {
        let accountDict = getAccountDict(coinType, accountIdx: accountIdx)
        setStealthAddressServerStatus(accountDict, serverURL: serverURL, isWatching:isWatching)
    }
    
    func setStealthAddressServerStatusColdWalletAccount(_ coinType: TLCoinType, idx: Int, serverURL: String, isWatching: Bool) -> () {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: idx)
        setStealthAddressServerStatus(accountDict, serverURL: serverURL, isWatching: isWatching)
    }
    
    func setStealthAddressServerStatusImportedAccount(_ coinType: TLCoinType, idx: Int, serverURL: String, isWatching: Bool) -> () {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
        setStealthAddressServerStatus(accountDict, serverURL: serverURL, isWatching: isWatching)
    }
    
    func setStealthAddressServerStatusImportedWatchAccount(_ coinType: TLCoinType, idx: Int, serverURL: String, isWatching: Bool) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: idx)
        setStealthAddressServerStatus(accountDict, serverURL: serverURL, isWatching: isWatching)
    }

    
    func setStealthAddressLastTxTime(_ accountDict: NSMutableDictionary, serverURL: String, lastTxTime: UInt64) -> () {
        let stealthAddressArray = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES) as! NSMutableArray
        let stealthAddressDict = (stealthAddressArray.object(at: 0) as! NSMutableDictionary)
        stealthAddressDict.setObject(NSNumber(value: lastTxTime as UInt64), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LAST_TX_TIME as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func setStealthAddressLastTxTimeHDWallet(_ coinType: TLCoinType, accountIdx: Int, serverURL: String, lastTxTime: UInt64) -> () {
        let accountDict = getAccountDict(coinType, accountIdx: accountIdx)
        setStealthAddressLastTxTime(accountDict, serverURL: serverURL, lastTxTime: lastTxTime)
    }
    
    func setStealthAddressLastTxTimeColdWalletAccount(_ coinType: TLCoinType, idx: Int, serverURL: String, lastTxTime: UInt64) -> () {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: idx)
        setStealthAddressLastTxTime(accountDict, serverURL: serverURL, lastTxTime: lastTxTime)
    }
    
    func setStealthAddressLastTxTimeImportedAccount(_ coinType: TLCoinType, idx: Int, serverURL: String, lastTxTime: UInt64) -> () {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
        setStealthAddressLastTxTime(accountDict, serverURL: serverURL, lastTxTime: lastTxTime)
    }
    
    func setStealthAddressLastTxTimeImportedWatchAccount(_ coinType: TLCoinType, idx: Int, serverURL: String, lastTxTime: UInt64) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: idx)
        setStealthAddressLastTxTime(accountDict, serverURL: serverURL, lastTxTime: lastTxTime)
    }
    
    
    fileprivate func addStealthAddressPaymentKey(_ accountDict: NSMutableDictionary, privateKey: String,
        address: String, txid: String, txTime: UInt64, stealthPaymentStatus: TLStealthPaymentStatus) -> () {
        let paymentDict = [
            TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_KEY: privateKey,
            TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS: address,
            TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TXID: txid,
            TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TIME: NSNumber(value: txTime as UInt64),
            TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHECK_TIME: NSNumber(value: 0 as UInt64),
            TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS: stealthPaymentStatus.rawValue
        ] as [String : Any]
        
        let stealthAddressPaymentDict = NSMutableDictionary(dictionary: paymentDict)
        let lock = NSLock()
        lock.lock()
        let stealthAddressArray = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES) as! NSMutableArray
        let stealthAddressPaymentsArray = (stealthAddressArray.object(at: 0) as! NSDictionary).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYMENTS) as! NSMutableArray
        var indexToInsert = stealthAddressPaymentsArray.count-1            

        while indexToInsert >= 0 {
            if let currentStealthAddressPaymentDict = stealthAddressPaymentsArray.object(at: indexToInsert) as? NSDictionary {
                if (currentStealthAddressPaymentDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TIME) as! NSNumber).uint64Value < txTime {
                    break
                }
            }
            indexToInsert -= 1
        }
        
        if stealthAddressPaymentDict != nil {
            stealthAddressPaymentsArray.insert(stealthAddressPaymentDict, at: indexToInsert+1)
        }
        lock.unlock()
            
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
        }
    }
    
    func addStealthAddressPaymentKeyHDWallet(_ coinType: TLCoinType, accountIdx: Int, privateKey: String, address: String,
        txid: String, txTime: UInt64, stealthPaymentStatus: TLStealthPaymentStatus) -> () {
            let accountDict = getAccountDict(coinType, accountIdx: accountIdx)
            addStealthAddressPaymentKey(accountDict, privateKey: privateKey, address: address,
                txid: txid, txTime: txTime, stealthPaymentStatus: stealthPaymentStatus)
    }
    
    func addStealthAddressPaymentKeyColdWalletAccount(_ coinType: TLCoinType, idx: Int, privateKey: String, address: String,
                                                         txid: String, txTime: UInt64, stealthPaymentStatus: TLStealthPaymentStatus) -> () {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: idx)
        addStealthAddressPaymentKey(accountDict, privateKey: privateKey, address: address,
                                    txid: txid, txTime: txTime, stealthPaymentStatus: stealthPaymentStatus)
    }
    
    func addStealthAddressPaymentKeyImportedAccount(_ coinType: TLCoinType, idx: Int, privateKey: String, address: String,
        txid: String, txTime: UInt64, stealthPaymentStatus: TLStealthPaymentStatus) -> () {
            let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
            addStealthAddressPaymentKey(accountDict, privateKey: privateKey, address: address,
                txid: txid, txTime: txTime, stealthPaymentStatus: stealthPaymentStatus)
    }
    
    func addStealthAddressPaymentKeyImportedWatchAccount(_ coinType: TLCoinType, idx: Int, privateKey: String, address: String,
        txid: String, txTime: UInt64, stealthPaymentStatus: TLStealthPaymentStatus) -> () {
            let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: idx)
            addStealthAddressPaymentKey(accountDict, privateKey: privateKey, address: address,
                txid: txid, txTime: txTime, stealthPaymentStatus: stealthPaymentStatus)
    }
    
    
    func setStealthPaymentLastCheckTime(_ accountDict: NSMutableDictionary, txid: String, lastCheckTime: UInt64) -> () {
        let stealthAddressArray = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES) as! NSMutableArray
        let paymentsArray = (stealthAddressArray.object(at: 0) as! NSDictionary).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYMENTS) as! NSMutableArray
        
        for _payment in paymentsArray {
            let payment = _payment as! NSMutableDictionary
            if payment.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TXID) as? String == txid {
                payment.setObject(NSNumber(value: lastCheckTime as UInt64), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHECK_TIME as NSCopying)
                break
            }
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func setStealthPaymentLastCheckTimeHDWallet(_ coinType: TLCoinType, accountIdx: Int, txid: String, lastCheckTime: UInt64) -> () {
        let accountDict = getAccountDict(coinType, accountIdx: accountIdx)
        setStealthPaymentLastCheckTime(accountDict, txid: txid, lastCheckTime: lastCheckTime)
    }
    
    func setStealthPaymentLastCheckTimeColdWalletAccount(_ coinType: TLCoinType, idx: Int, txid: String, lastCheckTime: UInt64) -> () {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: idx)
        setStealthPaymentLastCheckTime(accountDict, txid: txid, lastCheckTime: lastCheckTime)
    }
    
    func setStealthPaymentLastCheckTimeImportedAccount(_ coinType: TLCoinType, idx: Int, txid: String, lastCheckTime: UInt64) -> () {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
        setStealthPaymentLastCheckTime(accountDict, txid: txid, lastCheckTime: lastCheckTime)
    }
    
    func setStealthPaymentLastCheckTimeImportedWatchAccount(_ coinType: TLCoinType, idx: Int, txid: String, lastCheckTime: UInt64) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: idx)
        setStealthPaymentLastCheckTime(accountDict, txid: txid, lastCheckTime: lastCheckTime)
    }
    
    func setStealthPaymentStatus(_ accountDict: NSMutableDictionary, txid: String,
        stealthPaymentStatus: TLStealthPaymentStatus, lastCheckTime: UInt64) -> () {
        let stealthAddressArray = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES) as! NSMutableArray
        let paymentsArray = (stealthAddressArray.object(at: 0) as! NSDictionary).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYMENTS) as! NSMutableArray
        
        for _payment in paymentsArray {
            let payment = _payment as! NSMutableDictionary
            if payment.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TXID) as? String == txid {
                payment.setObject(stealthPaymentStatus.rawValue, forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS as NSCopying)
                payment.setObject(NSNumber(value: lastCheckTime as UInt64), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHECK_TIME as NSCopying)
                break
            }
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
        }
    }
    
    func setStealthPaymentStatusHDWallet(_ coinType: TLCoinType, accountIdx: Int, txid: String, stealthPaymentStatus: TLStealthPaymentStatus, lastCheckTime: UInt64) -> () {
        let accountDict = getAccountDict(coinType, accountIdx: accountIdx)
        setStealthPaymentStatus(accountDict, txid: txid, stealthPaymentStatus: stealthPaymentStatus, lastCheckTime: lastCheckTime)
    }
    
    func setStealthPaymentStatusColdWalletAccount(_ coinType: TLCoinType, idx: Int, txid: String, stealthPaymentStatus: TLStealthPaymentStatus, lastCheckTime: UInt64) -> () {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: idx)
        setStealthPaymentStatus(accountDict, txid: txid, stealthPaymentStatus: stealthPaymentStatus, lastCheckTime: lastCheckTime)
    }
    
    func setStealthPaymentStatusImportedAccount(_ coinType: TLCoinType, idx: Int, txid: String, stealthPaymentStatus: TLStealthPaymentStatus, lastCheckTime: UInt64) -> () {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
        setStealthPaymentStatus(accountDict, txid: txid, stealthPaymentStatus: stealthPaymentStatus, lastCheckTime: lastCheckTime)
    }
    
    func setStealthPaymentStatusImportedWatchAccount(_ coinType: TLCoinType, idx: Int, txid: String, stealthPaymentStatus: TLStealthPaymentStatus, lastCheckTime: UInt64) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: idx)
        setStealthPaymentStatus(accountDict, txid: txid, stealthPaymentStatus: stealthPaymentStatus, lastCheckTime: lastCheckTime)
    }
    

    func removeOldStealthPayments(_ accountDict: NSMutableDictionary) -> () {
        let stealthAddressArray = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES) as! NSMutableArray
        let stealthAddressPaymentsArray = (stealthAddressArray.object(at: 0) as! NSDictionary).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYMENTS) as! NSMutableArray

        let startCount = stealthAddressPaymentsArray.count
        var stealthAddressPaymentsArrayCount = stealthAddressPaymentsArray.count
        while (stealthAddressPaymentsArray.count > TLStealthExplorerAPI.STATIC_MEMBERS.STEALTH_PAYMENTS_FETCH_COUNT) {
            if let stealthAddressPaymentDict = stealthAddressPaymentsArray.object(at: 0) as? NSDictionary {
                if (stealthAddressPaymentDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS) as! Int == TLStealthPaymentStatus.spent.rawValue) {
                    stealthAddressPaymentsArray.removeObject(at: 0)
                    stealthAddressPaymentsArrayCount -= 1
                } else {
                    break
                }
            } else {
                stealthAddressPaymentsArray.removeObject(at: 0)
                stealthAddressPaymentsArrayCount -= 1
            }
        }

        if startCount != stealthAddressPaymentsArrayCount {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
            }
        }
    }
    
    func removeOldStealthPaymentsHDWallet(_ coinType: TLCoinType, accountIdx: Int) -> () {
        let accountDict = getAccountDict(coinType, accountIdx: accountIdx)
        removeOldStealthPayments(accountDict)
    }
    
    func removeOldStealthPaymentsColdWalletAccount(_ coinType: TLCoinType, idx: Int) -> () {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: idx)
        removeOldStealthPayments(accountDict)
    }
    
    func removeOldStealthPaymentsImportedAccount(_ coinType: TLCoinType, idx: Int) -> () {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
        removeOldStealthPayments(accountDict)
    }
    
    func removeOldStealthPaymentsImportedWatchAccount(_ coinType: TLCoinType, idx: Int) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: idx)
        removeOldStealthPayments(accountDict)
    }
    
    
    func clearAllStealthPayments(_ accountDict: NSMutableDictionary) -> () {
        let stealthAddressArray = accountDict.object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES) as! NSMutableArray
        let stealthAddressDict = stealthAddressArray.object(at: 0) as! NSMutableDictionary
        stealthAddressDict.setObject(NSMutableArray(), forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYMENTS as NSCopying)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_WALLET_PAYLOAD_UPDATED()), object: nil, userInfo: nil)
    }
    
    func clearAllStealthPaymentsFromHDWallet(_ coinType: TLCoinType, accountIdx: Int) -> () {
        let accountDict = getAccountDict(coinType, accountIdx: accountIdx)
        clearAllStealthPayments(accountDict)
    }

    func clearAllStealthPaymentsFromColdWalletAccount(_ coinType: TLCoinType, idx: Int) -> () {
        let accountDict = getColdWalletAccountAtIndex(coinType, idx: idx)
        clearAllStealthPayments(accountDict)
    }
    
    func clearAllStealthPaymentsFromImportedAccount(_ coinType: TLCoinType, idx: Int) -> () {
        let accountDict = getImportedAccountAtIndex(coinType, idx: idx)
        clearAllStealthPayments(accountDict)
    }
    
    func clearAllStealthPaymentsFromImportedWatchAccount(_ coinType: TLCoinType, idx: Int) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(coinType, idx: idx)
        clearAllStealthPayments(accountDict)
    }
}
