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
    
    func setStealthAddressServerStatus(accountDict: NSMutableDictionary, serverURL: String, isWatching: Bool) -> () {
        let stealthAddressArray = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES) as! NSMutableArray
        let stealthAddressServersDict = (stealthAddressArray.objectAtIndex(0) as! NSDictionary).objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_SERVERS) as! NSMutableDictionary
        
        if let stealthServerDict = stealthAddressServersDict.objectForKey(serverURL) as? NSMutableDictionary  {
            stealthServerDict.setObject(isWatching, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_WATCHING)
        } else {
            let serverAttributes = [
                TLWallet.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_WATCHING: isWatching,
            ]
            let serverAttributesDict = NSMutableDictionary(dictionary: serverAttributes)
            stealthAddressServersDict.setObject(serverAttributesDict, forKey: serverURL)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func setStealthAddressServerStatusHDWallet(accountIdx: Int, serverURL: String, isWatching: Bool) -> () {
        let accountDict = getAccountDict(accountIdx)
        setStealthAddressServerStatus(accountDict, serverURL: serverURL, isWatching:isWatching)
    }
    
    func setStealthAddressServerStatusImportedAccount(idx: Int, serverURL: String, isWatching: Bool) -> () {
        let accountDict = getImportedAccountAtIndex(idx)
        setStealthAddressServerStatus(accountDict, serverURL: serverURL, isWatching: isWatching)
    }
    
    func setStealthAddressServerStatusImportedWatchAccount(idx: Int, serverURL: String, isWatching: Bool) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        setStealthAddressServerStatus(accountDict, serverURL: serverURL, isWatching: isWatching)
    }


    func setStealthAddressLastTxTime(accountDict: NSMutableDictionary, serverURL: String, lastTxTime: UInt64) -> () {
        let stealthAddressArray = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES) as! NSMutableArray
        let stealthAddressDict = (stealthAddressArray.objectAtIndex(0) as! NSMutableDictionary)
        stealthAddressDict.setObject(NSNumber(unsignedLongLong: lastTxTime), forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LAST_TX_TIME)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func setStealthAddressLastTxTimeHDWallet(accountIdx: Int, serverURL: String, lastTxTime: UInt64) -> () {
        let accountDict = getAccountDict(accountIdx)
        setStealthAddressLastTxTime(accountDict, serverURL: serverURL, lastTxTime: lastTxTime)
    }
    
    func setStealthAddressLastTxTimeImportedAccount(idx: Int, serverURL: String, lastTxTime: UInt64) -> () {
        let accountDict = getImportedAccountAtIndex(idx)
        setStealthAddressLastTxTime(accountDict, serverURL: serverURL, lastTxTime: lastTxTime)
    }
    
    func setStealthAddressLastTxTimeImportedWatchAccount(idx: Int, serverURL: String, lastTxTime: UInt64) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        setStealthAddressLastTxTime(accountDict, serverURL: serverURL, lastTxTime: lastTxTime)
    }
    

    private func addStealthAddressPaymentKey(accountDict: NSMutableDictionary, privateKey: String,
        address: String, txid: String, txTime: UInt64, stealthPaymentStatus: TLStealthPaymentStatus) -> () {
        let paymentDict = [
            STATIC_MEMBERS.WALLET_PAYLOAD_KEY_KEY: privateKey,
            STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS: address,
            STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TXID: txid,
            STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TIME: NSNumber(unsignedLongLong: txTime),
            STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHECK_TIME: NSNumber(unsignedLongLong: 0),
            STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS: stealthPaymentStatus.rawValue
        ]
        
        let stealthAddressPaymentDict = NSMutableDictionary(dictionary: paymentDict)
        let lock = NSLock()
        lock.lock()
        let stealthAddressArray = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES) as! NSMutableArray
        let stealthAddressPaymentsArray = (stealthAddressArray.objectAtIndex(0) as! NSDictionary).objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYMENTS) as! NSMutableArray
        var indexToInsert = stealthAddressPaymentsArray.count-1            
        for ; indexToInsert >= 0; indexToInsert-- {
            let currentStealthAddressPaymentDict = stealthAddressPaymentsArray.objectAtIndex(indexToInsert) as! NSDictionary
            if (currentStealthAddressPaymentDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TIME) as! NSNumber).unsignedLongLongValue < txTime {
                break
            }
        }
            
        stealthAddressPaymentsArray.insertObject(stealthAddressPaymentDict, atIndex: indexToInsert+1)
        lock.unlock()
            
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
        }
    }
    
    func addStealthAddressPaymentKeyHDWallet(accountIdx: Int, privateKey: String, address: String,
        txid: String, txTime: UInt64, stealthPaymentStatus: TLStealthPaymentStatus) -> () {
            let accountDict = getAccountDict(accountIdx)
            addStealthAddressPaymentKey(accountDict, privateKey: privateKey, address: address,
                txid: txid, txTime: txTime, stealthPaymentStatus: stealthPaymentStatus)
    }
    
    func addStealthAddressPaymentKeyImportedAccount(idx: Int, privateKey: String, address: String,
        txid: String, txTime: UInt64, stealthPaymentStatus: TLStealthPaymentStatus) -> () {
            let accountDict = getImportedAccountAtIndex(idx)
            addStealthAddressPaymentKey(accountDict, privateKey: privateKey, address: address,
                txid: txid, txTime: txTime, stealthPaymentStatus: stealthPaymentStatus)
    }
    
    func addStealthAddressPaymentKeyImportedWatchAccount(idx: Int, privateKey: String, address: String,
        txid: String, txTime: UInt64, stealthPaymentStatus: TLStealthPaymentStatus) -> () {
            let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
            addStealthAddressPaymentKey(accountDict, privateKey: privateKey, address: address,
                txid: txid, txTime: txTime, stealthPaymentStatus: stealthPaymentStatus)
    }
    
    
    func setStealthPaymentLastCheckTime(accountDict: NSMutableDictionary, txid: String, lastCheckTime: UInt64) -> () {
        let stealthAddressArray = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES) as! NSMutableArray
        let paymentsArray = (stealthAddressArray.objectAtIndex(0) as! NSDictionary).objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYMENTS) as! NSMutableArray
        
        for _payment in paymentsArray {
            let payment = _payment as! NSMutableDictionary
            if payment.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TXID) as? String == txid {
                payment.setObject(NSNumber(unsignedLongLong: lastCheckTime), forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHECK_TIME)
                break
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func setStealthPaymentLastCheckTimeHDWallet(accountIdx: Int, txid: String, lastCheckTime: UInt64) -> () {
        let accountDict = getAccountDict(accountIdx)
        setStealthPaymentLastCheckTime(accountDict, txid: txid, lastCheckTime: lastCheckTime)
    }
    
    func setStealthPaymentLastCheckTimeImportedAccount(idx: Int, txid: String, lastCheckTime: UInt64) -> () {
        let accountDict = getImportedAccountAtIndex(idx)
        setStealthPaymentLastCheckTime(accountDict, txid: txid, lastCheckTime: lastCheckTime)
    }
    
    func setStealthPaymentLastCheckTimeImportedWatchAccount(idx: Int, txid: String, lastCheckTime: UInt64) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        setStealthPaymentLastCheckTime(accountDict, txid: txid, lastCheckTime: lastCheckTime)
    }
    
    func setStealthPaymentStatus(accountDict: NSMutableDictionary, txid: String,
        stealthPaymentStatus: TLStealthPaymentStatus, lastCheckTime: UInt64) -> () {
        let stealthAddressArray = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES) as! NSMutableArray
        let paymentsArray = (stealthAddressArray.objectAtIndex(0) as! NSDictionary).objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYMENTS) as! NSMutableArray
        
        for _payment in paymentsArray {
            let payment = _payment as! NSMutableDictionary
            if payment.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_TXID) as? String == txid {
                payment.setObject(stealthPaymentStatus.rawValue, forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS)
                payment.setObject(NSNumber(unsignedLongLong: lastCheckTime), forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_CHECK_TIME)
                break
            }
        }
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
        }
    }
    
    func setStealthPaymentStatusHDWallet(accountIdx: Int, txid: String, stealthPaymentStatus: TLStealthPaymentStatus, lastCheckTime: UInt64) -> () {
        let accountDict = getAccountDict(accountIdx)
        setStealthPaymentStatus(accountDict, txid: txid, stealthPaymentStatus: stealthPaymentStatus, lastCheckTime: lastCheckTime)
    }
    
    func setStealthPaymentStatusImportedAccount(idx: Int, txid: String, stealthPaymentStatus: TLStealthPaymentStatus, lastCheckTime: UInt64) -> () {
        let accountDict = getImportedAccountAtIndex(idx)
        setStealthPaymentStatus(accountDict, txid: txid, stealthPaymentStatus: stealthPaymentStatus, lastCheckTime: lastCheckTime)
    }
    
    func setStealthPaymentStatusImportedWatchAccount(idx: Int, txid: String, stealthPaymentStatus: TLStealthPaymentStatus, lastCheckTime: UInt64) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        setStealthPaymentStatus(accountDict, txid: txid, stealthPaymentStatus: stealthPaymentStatus, lastCheckTime: lastCheckTime)
    }
    

    func removeOldStealthPayments(accountDict: NSMutableDictionary) -> () {
        let stealthAddressArray = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES) as! NSMutableArray
        let stealthAddressPaymentsArray = (stealthAddressArray.objectAtIndex(0) as! NSDictionary).objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYMENTS) as! NSMutableArray

        let startCount = stealthAddressPaymentsArray.count
        var stealthAddressPaymentsArrayCount = stealthAddressPaymentsArray.count
        while (stealthAddressPaymentsArray.count > TLWallet.STATIC_MEMBERS.STEALTH_PAYMENTS_FETCH_COUNT) {
            let stealthAddressPaymentDict = stealthAddressPaymentsArray.objectAtIndex(0) as! NSDictionary
            if (stealthAddressPaymentDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STATUS) as! Int == TLStealthPaymentStatus.Spent.rawValue) {
                stealthAddressPaymentsArray.removeObjectAtIndex(0)
                stealthAddressPaymentsArrayCount--
            } else {
                break
            }
        }

        if startCount != stealthAddressPaymentsArrayCount {
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
            }
        }
    }
    
    func removeOldStealthPaymentsHDWallet(accountIdx: Int) -> () {
        let accountDict = getAccountDict(accountIdx)
        removeOldStealthPayments(accountDict)
    }
    
    func removeOldStealthPaymentsImportedAccount(idx: Int) -> () {
        let accountDict = getImportedAccountAtIndex(idx)
        removeOldStealthPayments(accountDict)
    }
    
    func removeOldStealthPaymentsImportedWatchAccount(idx: Int) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        removeOldStealthPayments(accountDict)
    }
    
    
    func clearAllStealthPayments(accountDict: NSMutableDictionary) -> () {
        let stealthAddressArray = accountDict.objectForKey(STATIC_MEMBERS.WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES) as! NSMutableArray
        let stealthAddressDict = stealthAddressArray.objectAtIndex(0) as! NSMutableDictionary
        stealthAddressDict.setObject(NSMutableArray(), forKey: STATIC_MEMBERS.WALLET_PAYLOAD_KEY_PAYMENTS)
        NSNotificationCenter.defaultCenter().postNotificationName(STATIC_MEMBERS.EVENT_WALLET_PAYLOAD_UPDATED, object: nil, userInfo: nil)
    }
    
    func clearAllStealthPaymentsFromHDWallet(accountIdx: Int) -> () {
        let accountDict = getAccountDict(accountIdx)
        clearAllStealthPayments(accountDict)
    }
    
    func clearAllStealthPaymentsFromImportedAccount(idx: Int) -> () {
        let accountDict = getImportedAccountAtIndex(idx)
        clearAllStealthPayments(accountDict)
    }
    
    func clearAllStealthPaymentsFromImportedWatchAccount(idx: Int) -> () {
        let accountDict = getImportedWatchOnlyAccountAtIndex(idx)
        clearAllStealthPayments(accountDict)
    }
}