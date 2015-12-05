//
//  TLImportedAddresses.swift
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

@objc class TLImportedAddresses:NSObject
{
    private var appWallet:TLWallet?
    private let importedAddresses = NSMutableArray()
    private let archivedImportedAddresses = NSMutableArray()
    private let addressToIdxDict = NSMutableDictionary()
    private let addressToPositionInWalletArrayDict = NSMutableDictionary()
    private var accountAddressType:TLAccountAddressType?
    var downloadState:TLDownloadState = .NotDownloading

    init(appWallet: TLWallet, importedAddresses:NSArray, accountAddressType:(TLAccountAddressType)) {
        super.init()
        self.appWallet = appWallet
        self.accountAddressType = accountAddressType
        
        for (var i = 0; i < importedAddresses.count; i++) {
            let importedAddressObject = importedAddresses.objectAtIndex(i) as! TLImportedAddress
            if (importedAddressObject.isArchived()) {
                self.archivedImportedAddresses.addObject(importedAddressObject)
            } else {
                var indexes = self.addressToIdxDict.objectForKey(importedAddressObject.getAddress()) as? NSMutableArray
                if (indexes == nil) {
                    indexes = NSMutableArray()
                    self.addressToIdxDict.setObject(indexes!, forKey:importedAddressObject.getAddress())
                }
                
                indexes!.addObject(self.importedAddresses.count)
                
                self.importedAddresses.addObject(importedAddressObject)
            }
            
            importedAddressObject.setPositionInWalletArray(i)
            self.addressToPositionInWalletArrayDict.setObject(importedAddressObject, forKey:importedAddressObject.getPositionInWalletArrayNumber())
        }
    }
    
    func getAddressObjectAtIdx(idx:Int) -> TLImportedAddress {
        return self.importedAddresses.objectAtIndex(idx) as! TLImportedAddress
    }
    
    func getArchivedAddressObjectAtIdx(idx:Int) -> TLImportedAddress{
        return self.archivedImportedAddresses.objectAtIndex(idx) as! TLImportedAddress
    }
    
    func getCount() -> Int{
        return self.importedAddresses.count
    }
    
    func getArchivedCount() -> Int{
        return self.archivedImportedAddresses.count
    }
    
    func checkToGetAndSetAddressesData(fetchDataAgain:Bool, success:TLWalletUtils.Success, failure:TLWalletUtils.Error) -> () {
        let addresses = NSMutableSet()

        for importedAddressObject in self.importedAddresses {
            if (!(importedAddressObject as! TLImportedAddress).hasFetchedAccountData() || fetchDataAgain) {
                let address = (importedAddressObject as! TLImportedAddress).getAddress()
                addresses.addObject(address)
                
            }
        }
        
        if (addresses.count == 0) {
            success()
            return
        }

        TLBlockExplorerAPI.instance().getAddressesInfo(addresses.allObjects as! [String], success:{(jsonData:AnyObject!) in
            let addressesArray = jsonData.objectForKey("addresses") as! NSArray
            let txArray = jsonData.objectForKey("txs") as! NSArray
            for addressDict in addressesArray {
                let address = (addressDict as! NSDictionary).objectForKey("address") as! String
                
                let indexes = self.addressToIdxDict.objectForKey(address) as! NSArray
                for idx in indexes {
                    let importedAddressObject = self.importedAddresses.objectAtIndex(idx as! Int) as! TLImportedAddress
                    let addressBalance = (addressDict.objectForKey("final_balance") as! NSNumber).unsignedLongLongValue
                    importedAddressObject.balance = TLCoin(uint64: addressBalance)
                    importedAddressObject.processTxArray(txArray, shouldUpdateAccountBalance: false)
                    importedAddressObject.setHasFetchedAccountData(true)
                }
            }
            
            DLog("postNotificationName: EVENT_FETCHED_ADDRESSES_DATA importedAddresses")
            NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA(),
                object:nil, userInfo:nil)
            
            success()
            } , failure:{(code:NSInteger, status:String!) in
                failure()
        })
    }
    
    func checkToGetAndSetAddressesDataO(fetchDataAgain:Bool) -> () {
        let addresses = NSMutableSet()
        
        for importedAddressObject in self.importedAddresses {
            if (!(importedAddressObject as! TLImportedAddress).hasFetchedAccountData() || fetchDataAgain) {
                let address = (importedAddressObject as! TLImportedAddress).getAddress()
                addresses.addObject(address)
                
            }
        }
        
        if (addresses.count == 0) {
            return
        }
        
        let jsonData = TLBlockExplorerAPI.instance().getAddressesInfoSynchronous(addresses.allObjects as! [String])
        if (jsonData.objectForKey(TLNetworking.STATIC_MEMBERS.HTTP_ERROR_CODE) != nil) {
            self.downloadState = .Failed
            return
        }

        let addressesArray = jsonData.objectForKey("addresses") as! NSArray
        let txArray = jsonData.objectForKey("txs") as! NSArray
        for addressDict in addressesArray {
            let address = (addressDict as! NSDictionary).objectForKey("address") as! String
            
            let indexes = (self.addressToIdxDict).objectForKey(address) as! NSArray
            for idx in indexes {
                let importedAddressObject = self.importedAddresses.objectAtIndex(idx as! Int) as! TLImportedAddress
                let addressBalance = (addressDict.objectForKey("final_balance") as! NSNumber).unsignedLongLongValue
                importedAddressObject.balance = TLCoin(uint64: addressBalance)
                importedAddressObject.processTxArray(txArray, shouldUpdateAccountBalance: false)
                importedAddressObject.setHasFetchedAccountData(true)
            }
        }
        
        self.downloadState = .Downloaded
        dispatch_async(dispatch_get_main_queue(), {
            DLog("postNotificationName: EVENT_FETCHED_ADDRESSES_DATA importedAddresses")
            NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA(), object:nil, userInfo:nil)
        })
    }
    
    func addImportedPrivateKey(privateKey:String, encryptedPrivateKey:String?) -> (TLImportedAddress) {
        let importedPrivateKeyDict = self.appWallet!.addImportedPrivateKey(privateKey, encryptedPrivateKey:encryptedPrivateKey)
        
        let importedAddressObject = TLImportedAddress(appWallet:self.appWallet!, dict:importedPrivateKeyDict)
        self.importedAddresses.addObject(importedAddressObject)
        
        importedAddressObject.setPositionInWalletArray(self.importedAddresses.count - 1)
        self.addressToPositionInWalletArrayDict.setObject(importedAddressObject, forKey:importedAddressObject.getPositionInWalletArrayNumber())
        
        let address = TLCoreBitcoinWrapper.getAddress(privateKey, isTestnet: self.appWallet!.walletConfig.isTestnet)
        
        var indexes = self.addressToIdxDict.objectForKey(address!) as! NSMutableArray?
        if (indexes == nil) {
            indexes = NSMutableArray()
            self.addressToIdxDict.setObject(indexes!, forKey:importedAddressObject.getAddress())
        }
        
        indexes!.addObject(self.importedAddresses.count-1)
        
        setLabel(importedAddressObject.getDefaultAddressLabel()!, positionInWalletArray:self.importedAddresses.count-1)
        
        return importedAddressObject
    }
    
    func addImportedWatchAddress(address:String) -> (TLImportedAddress) {
        let importedDict = self.appWallet!.addWatchOnlyAddress(address)
        let importedAddressObject = TLImportedAddress(appWallet:self.appWallet!, dict:importedDict)
        self.importedAddresses.addObject(importedAddressObject)
        
        importedAddressObject.setPositionInWalletArray(self.importedAddresses.count - 1)
        self.addressToPositionInWalletArrayDict.setObject(importedAddressObject, forKey:importedAddressObject.getPositionInWalletArrayNumber())
        
        var indexes = self.addressToIdxDict.objectForKey(address) as? NSMutableArray
        if (indexes == nil) {
            indexes = NSMutableArray()
            self.addressToIdxDict.setObject(indexes!, forKey:address)
        }
        
        indexes!.addObject(self.importedAddresses.count-1)
        
        setLabel(importedAddressObject.getDefaultAddressLabel()!, positionInWalletArray:self.importedAddresses.count-1)
        
        return importedAddressObject
    }
    
    func setLabel(label:String, positionInWalletArray:Int) -> Bool {
        let importedAddressObject = self.addressToPositionInWalletArrayDict.objectForKey(positionInWalletArray) as! TLImportedAddress
        
        importedAddressObject.setLabel(label)
        if (self.accountAddressType == .Imported) {
            self.appWallet!.setImportedPrivateKeyLabel(label, idx:positionInWalletArray)
        } else if (self.accountAddressType! == .ImportedWatch) {
            self.appWallet!.setWatchOnlyAddressLabel(label, idx:positionInWalletArray)
        }
        
        return true
    }
    
    func archiveAddress(positionInWalletArray:Int) -> () {
        self.setArchived(positionInWalletArray, archive:true)
        
        let toMoveAddressObject = self.addressToPositionInWalletArrayDict.objectForKey(positionInWalletArray) as! TLImportedAddress
        var indexes = self.addressToIdxDict.objectForKey(toMoveAddressObject.getAddress()) as? NSMutableArray
        if (indexes == nil) {
            indexes = NSMutableArray()
            self.addressToIdxDict.setObject(indexes!, forKey:toMoveAddressObject.getAddress())
        }
        let toMoveIndex = self.importedAddresses.indexOfObject(toMoveAddressObject) as Int
        
        for key in self.addressToIdxDict {
            let indexes: AnyObject = (self.addressToIdxDict.objectForKey(key.key) as! NSArray).copy()
            
            for idx in indexes as! [Int] {
                if (idx > toMoveIndex) {
                    let indexes = self.addressToIdxDict.objectForKey(key.key) as! NSMutableArray
                    indexes.removeObject(idx)
                    indexes.addObject(UInt(idx)-1)
                }
            }
        }
        
        indexes!.removeObject(toMoveIndex)
        
        self.importedAddresses.removeObject(toMoveAddressObject)
        for (var i = 0; i < self.archivedImportedAddresses.count; i++) {
            let importedAddressObject = self.archivedImportedAddresses.objectAtIndex(i) as! TLImportedAddress
            
            if (importedAddressObject.getPositionInWalletArray() > toMoveAddressObject.getPositionInWalletArray()) {
                self.archivedImportedAddresses.insertObject(toMoveAddressObject, atIndex:i)
                return
            }
        }
        self.archivedImportedAddresses.addObject(toMoveAddressObject)
    }
    
    func unarchiveAddress(positionInWalletArray:Int) -> (){
        setArchived(positionInWalletArray, archive:false)
        
        let toMoveAddressObject = self.addressToPositionInWalletArrayDict.objectForKey(positionInWalletArray) as! TLImportedAddress
        
        self.archivedImportedAddresses.removeObject(toMoveAddressObject)
        for (var i = 0; i < self.importedAddresses.count; i++) {
            let importedAddressObject = self.importedAddresses.objectAtIndex(i) as! TLImportedAddress
            if (importedAddressObject.getPositionInWalletArray() > toMoveAddressObject.getPositionInWalletArray()) {
                self.importedAddresses.insertObject(toMoveAddressObject, atIndex:i)
                var indexes = self.addressToIdxDict.objectForKey(toMoveAddressObject.getAddress()) as? NSMutableArray
                if (indexes == nil) {
                    indexes = NSMutableArray()
                    indexes!.addObject(i)
                    self.addressToIdxDict.setObject(indexes!, forKey:toMoveAddressObject.getAddress())
                }
                
                for key in self.addressToIdxDict {
                    let indexes: AnyObject = (self.addressToIdxDict.objectForKey(key.key) as! NSArray).copy()
                    for idx in indexes as! [Int] {
                        if (idx >= i) {
                            let indexes = self.addressToIdxDict.objectForKey(key.key) as! NSMutableArray
                            indexes.removeObject(idx)
                            indexes.addObject(UInt(idx)+1)
                        }
                    }
                }
                
                return
            }
        }
        self.importedAddresses.addObject(toMoveAddressObject)
    }
    
    private func setArchived(positionInWalletArray:Int, archive:Bool) -> Bool{
        let importedAddressObject = self.addressToPositionInWalletArrayDict.objectForKey(positionInWalletArray) as! TLImportedAddress
        
        importedAddressObject.setArchived(archive)
        if (self.accountAddressType! == .Imported) {
            self.appWallet!.setImportedPrivateKeyArchive(archive, idx:positionInWalletArray)
        } else if (self.accountAddressType == .ImportedWatch) {
            self.appWallet!.setWatchOnlyAddressArchive(archive, idx:positionInWalletArray)
        }
        
        return true
    }
    
    func deleteAddress(idx:Int) -> Bool {
        let importedAddressObject = self.archivedImportedAddresses.objectAtIndex(idx) as! TLImportedAddress
        
        self.archivedImportedAddresses.removeObjectAtIndex(idx)
        if (self.accountAddressType == .Imported) {
            self.appWallet!.deleteImportedPrivateKey(importedAddressObject.getPositionInWalletArray())
        } else if (self.accountAddressType == .ImportedWatch) {
            self.appWallet!.deleteImportedWatchAddress(importedAddressObject.getPositionInWalletArray())
        }
        
        self.addressToPositionInWalletArrayDict.removeObjectForKey(importedAddressObject.getPositionInWalletArrayNumber())
        let tmpDict = self.addressToPositionInWalletArrayDict.copy() as! NSDictionary
        for (key, _) in tmpDict {
            let ia = self.addressToPositionInWalletArrayDict.objectForKey(key as! NSNumber) as! TLImportedAddress
            if (ia.getPositionInWalletArray() > importedAddressObject.getPositionInWalletArray()) {
                ia.setPositionInWalletArray(ia.getPositionInWalletArray()-1)
                self.addressToPositionInWalletArrayDict.setObject(ia, forKey:ia.getPositionInWalletArrayNumber())
            }
        }
        

        if importedAddressObject.getPositionInWalletArray() < self.addressToPositionInWalletArrayDict.count - 1 {
            self.addressToPositionInWalletArrayDict.removeObjectForKey(self.addressToPositionInWalletArrayDict.count-1)
        }
        
        return true
    }
    
    func hasFetchedAddressesData() -> Bool {
        for importedAddressObject in self.importedAddresses {
            if (!((importedAddressObject as! TLImportedAddress).hasFetchedAccountData())) {
                return false
            }
        }
        return true
    }
}

