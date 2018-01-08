//
//  TLSelectedObject.swift
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
@objc class TLSelectedObject:NSObject {
    fileprivate var accountObject:TLAccountObject?
    fileprivate var importedAddress:TLImportedAddress?
    
    func getSelectedObjectCoinType() -> TLCoinType {
        if (self.accountObject != nil) {
            return self.accountObject!.coinType
        } else {
            return self.importedAddress!.coinType
        }
    }

    func setSelectedAccount(_ accountObject: TLAccountObject) -> () {
        self.accountObject = accountObject
        self.importedAddress = nil
    }
    
    func setSelectedAddress(_ importedAddress: TLImportedAddress) -> () {
        self.importedAddress = importedAddress
        self.accountObject = nil
    }
    
    func getDownloadState() -> (TLDownloadState) {
        if (self.accountObject != nil) {
            return self.accountObject!.downloadState
        } else if (self.importedAddress != nil) {
            return self.importedAddress!.downloadState
        }
        
        return .failed
    }
    
    func getBalanceForSelectedObject() -> (TLCoin?) {
        if (self.accountObject != nil) {
            return self.accountObject!.getBalance()
        } else if (self.importedAddress != nil) {
            return self.importedAddress!.getBalance()
        }
        return nil
    }
    
    func getLabelForSelectedObject() -> (String?) {
        if (self.accountObject != nil) {
            return self.accountObject!.getAccountName()
        } else if (self.importedAddress != nil) {
            return self.importedAddress!.getLabel()
        }
        return nil
    }
    
    func getReceivingAddressesCount() -> (UInt) {
        if (self.accountObject != nil) {
            return UInt(self.accountObject!.getReceivingAddressesCount())
        } else if (self.importedAddress != nil) {
            return 1
        }
        return 0
    }
    
    func getReceivingAddressForSelectedObject(_ idx:Int) -> (String?) {
        if (self.accountObject != nil) {
            return self.accountObject!.getReceivingAddress(idx)
        } else if (self.importedAddress != nil) {
            return self.importedAddress!.getAddress()
        }
        
        return nil
    }
    
    func getStealthAddress() -> String? {
        if self.accountObject != nil && self.accountObject!.getAccountType() != .importedWatch {
            if self.accountObject!.stealthWallet != nil {
                return self.accountObject!.stealthWallet!.getStealthAddress()
            }
        }
        return nil
    }
    
    func hasFetchedCurrentFromData() -> (Bool) {
        if (self.accountObject != nil) {
            return self.accountObject!.hasFetchedAccountData()
        } else if (self.importedAddress != nil) {
            return self.importedAddress!.hasFetchedAccountData()
        }
        
        return true
    }
    
    
    func isAddressPartOfAccount(_ address: String) -> (Bool) {
        if (self.accountObject != nil) {
            return self.accountObject!.isAddressPartOfAccount(address)
        } else if (self.importedAddress != nil) {
            return self.importedAddress!.getAddress() == address
        }
        
        return true
    }
    
    func getTxObjectCount() -> (UInt) {
        if (self.accountObject != nil) {
            return UInt(self.accountObject!.getTxObjectCount())
        } else if (self.importedAddress != nil) {
            return UInt(self.importedAddress!.getTxObjectCount())
        }
        
        return 1
    }
    
    func getTxObject(_ txIdx:Int) -> (TLTxObject?) {
        if (self.accountObject != nil) {
            return self.accountObject!.getTxObject(txIdx)
        } else if (self.importedAddress != nil) {
            return self.importedAddress!.getTxObject(txIdx)
        }
        
        return nil
    }
    
    func getAccountAmountChangeForTx(_ txHash: String) -> (TLCoin?) {
        if (self.accountObject != nil) {
            return self.accountObject!.getAccountAmountChangeForTx(txHash)!
        } else if (self.importedAddress != nil) {
            return self.importedAddress!.getAccountAmountChangeForTx(txHash)
        }
        
        return nil
    }
    
    func getAccountAmountChangeTypeForTx(_ txHash: String) -> (TLAccountTxType) {
        if (self.accountObject != nil) {
            return self.accountObject!.getAccountAmountChangeTypeForTx(txHash)
        } else if (self.importedAddress != nil) {
            return self.importedAddress!.getAccountAmountChangeTypeForTx(txHash)
        }
        
        return TLAccountTxType(rawValue: 0)!
    }
    
    func getSelectedObjectType() -> (TLSelectObjectType) {
        if (self.accountObject != nil) {
            return TLSelectObjectType.account
        } else {
            return TLSelectObjectType.address
        }
    }
    
    func getSelectedObject() -> AnyObject? {
        if (self.accountObject != nil) {
            return self.accountObject
        } else {
            return self.importedAddress
        }
    }
    
    func getAccountType() -> (TLAccountType) {
        if (self.accountObject != nil) {
            return self.accountObject!.getAccountType()
        } else {
            return TLAccountType.unknown
        }
    }
}
