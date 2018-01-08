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
    fileprivate var appWallet:TLWallet?
    fileprivate let importedAddresses = NSMutableArray()
    fileprivate let archivedImportedAddresses = NSMutableArray()
    fileprivate let addressToIdxDict = NSMutableDictionary()
    fileprivate let addressToPositionInWalletArrayDict = NSMutableDictionary()
    fileprivate var coinType:TLCoinType = TLWalletUtils.DEFAULT_COIN_TYPE()
    fileprivate var accountAddressType:TLAccountAddressType?
    var downloadState:TLDownloadState = .notDownloading

    init(appWallet: TLWallet, coinType: TLCoinType, importedAddresses:NSArray, accountAddressType:(TLAccountAddressType)) {
        super.init()
        self.appWallet = appWallet
        self.coinType = coinType
        self.accountAddressType = accountAddressType
        
        for i in stride(from: 0, to: importedAddresses.count, by: 1) {
            let importedAddressObject = importedAddresses.object(at: i) as! TLImportedAddress
            if (importedAddressObject.isArchived()) {
                self.archivedImportedAddresses.add(importedAddressObject)
            } else {
                var indexes = self.addressToIdxDict.object(forKey: importedAddressObject.getAddress()) as? NSMutableArray
                if (indexes == nil) {
                    indexes = NSMutableArray()
                    self.addressToIdxDict.setObject(indexes!, forKey:importedAddressObject.getAddress() as NSCopying)
                }
                
                indexes!.add(self.importedAddresses.count)
                
                self.importedAddresses.add(importedAddressObject)
            }
            
            importedAddressObject.setPositionInWalletArray(i)
            self.addressToPositionInWalletArrayDict.setObject(importedAddressObject, forKey:importedAddressObject.getPositionInWalletArrayNumber())
        }
    }
    
    func getAddressObjectAtIdx(_ idx:Int) -> TLImportedAddress {
        return self.importedAddresses.object(at: idx) as! TLImportedAddress
    }
    
    func getArchivedAddressObjectAtIdx(_ idx:Int) -> TLImportedAddress{
        return self.archivedImportedAddresses.object(at: idx) as! TLImportedAddress
    }
    
    func getCount() -> Int{
        return self.importedAddresses.count
    }
    
    func getArchivedCount() -> Int{
        return self.archivedImportedAddresses.count
    }
    
    func checkToGetAndSetAddressesData(_ fetchDataAgain:Bool, success:@escaping TLWalletUtils.Success, failure:@escaping TLWalletUtils.Error) -> () {
        let addresses = NSMutableSet()

        for importedAddressObject in self.importedAddresses {
            if (!(importedAddressObject as! TLImportedAddress).hasFetchedAccountData() || fetchDataAgain) {
                let address = (importedAddressObject as! TLImportedAddress).getAddress()
                addresses.add(address)
                
            }
        }
        
        if (addresses.count == 0) {
            success()
            return
        }

        TLBlockExplorerAPI.instance().getAddressesInfo(addresses.allObjects as! [String], success:{(jsonData:AnyObject!) in
            let addressesArray = jsonData.object(forKey: "addresses") as! NSArray
            let txArray = jsonData.object(forKey: "txs") as! NSArray
            for addressDict in addressesArray {
                let address = (addressDict as! NSDictionary).object(forKey: "address") as! String
                
                let indexes = self.addressToIdxDict.object(forKey: address) as! NSArray
                for idx in indexes {
                    let importedAddressObject = self.importedAddresses.object(at: idx as! Int) as! TLImportedAddress
                    let addressBalance = ((addressDict as AnyObject).object(forKey: "final_balance") as! NSNumber).uint64Value
                    importedAddressObject.balance = TLCoin(uint64: addressBalance)
                    importedAddressObject.processTxArray(txArray, shouldUpdateAccountBalance: false)
                    importedAddressObject.setHasFetchedAccountData(true)
                }
            }
            
            DLog("postNotificationName: EVENT_FETCHED_ADDRESSES_DATA importedAddresses")
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA()),
                object:nil, userInfo:nil)
            
            success()
            } , failure:{(code, status) in
                failure()
        })
    }
    
    func checkToGetAndSetAddressesDataO(_ fetchDataAgain:Bool) -> () {
        let addresses = NSMutableSet()
        
        for importedAddressObject in self.importedAddresses {
            if (!(importedAddressObject as! TLImportedAddress).hasFetchedAccountData() || fetchDataAgain) {
                let address = (importedAddressObject as! TLImportedAddress).getAddress()
                addresses.add(address)
                
            }
        }
        
        if (addresses.count == 0) {
            return
        }
        
        let jsonData = TLBlockExplorerAPI.instance().getAddressesInfoSynchronous(addresses.allObjects as! [String])
        if (jsonData.object(forKey: TLNetworking.STATIC_MEMBERS.HTTP_ERROR_CODE) != nil) {
            self.downloadState = .failed
            return
        }

        let addressesArray = jsonData.object(forKey: "addresses") as! NSArray
        let txArray = jsonData.object(forKey: "txs") as! NSArray
        for addressDict in addressesArray {
            let address = (addressDict as! NSDictionary).object(forKey: "address") as! String
            
            let indexes = (self.addressToIdxDict).object(forKey: address) as! NSArray
            for idx in indexes {
                let importedAddressObject = self.importedAddresses.object(at: idx as! Int) as! TLImportedAddress
                let addressBalance = ((addressDict as AnyObject).object(forKey: "final_balance") as! NSNumber).uint64Value
                importedAddressObject.balance = TLCoin(uint64: addressBalance)
                importedAddressObject.processTxArray(txArray, shouldUpdateAccountBalance: false)
                importedAddressObject.setHasFetchedAccountData(true)
            }
        }
        
        self.downloadState = .downloaded
        DispatchQueue.main.async(execute: {
            DLog("postNotificationName: EVENT_FETCHED_ADDRESSES_DATA importedAddresses")
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA()), object:nil, userInfo:nil)
        })
    }
    
    func addImportedPrivateKey(_ privateKey:String, encryptedPrivateKey:String?) -> (TLImportedAddress) {
        let importedPrivateKeyDict = self.appWallet!.addImportedPrivateKey(self.coinType, privateKey: privateKey, encryptedPrivateKey:encryptedPrivateKey)
        
        let importedAddressObject = TLImportedAddress(appWallet:self.appWallet!, coinType: self.coinType, dict:importedPrivateKeyDict)
        self.importedAddresses.add(importedAddressObject)
        
        importedAddressObject.setPositionInWalletArray(self.importedAddresses.count + self.archivedImportedAddresses.count - 1)
        self.addressToPositionInWalletArrayDict.setObject(importedAddressObject, forKey:importedAddressObject.getPositionInWalletArrayNumber())
        
        let address = TLCoreBitcoinWrapper.getAddress(privateKey, isTestnet: self.appWallet!.walletConfig.isTestnet)
        
        var indexes = self.addressToIdxDict.object(forKey: address!) as! NSMutableArray?
        if (indexes == nil) {
            indexes = NSMutableArray()
            self.addressToIdxDict.setObject(indexes!, forKey:importedAddressObject.getAddress() as NSCopying)
        }
        
        indexes!.add(self.importedAddresses.count-1)
        
        setLabel(importedAddressObject.getDefaultAddressLabel()!, positionInWalletArray:importedAddressObject.getPositionInWalletArray())
        
        return importedAddressObject
    }
    
    func addImportedWatchAddress(_ address:String) -> (TLImportedAddress) {
        let importedDict = self.appWallet!.addWatchOnlyAddress(self.coinType, address: address as NSString)
        let importedAddressObject = TLImportedAddress(appWallet:self.appWallet!, coinType: self.coinType, dict:importedDict)
        self.importedAddresses.add(importedAddressObject)
        
        importedAddressObject.setPositionInWalletArray(self.importedAddresses.count + self.archivedImportedAddresses.count - 1)
        self.addressToPositionInWalletArrayDict.setObject(importedAddressObject, forKey:importedAddressObject.getPositionInWalletArrayNumber())
        
        var indexes = self.addressToIdxDict.object(forKey: address) as? NSMutableArray
        if (indexes == nil) {
            indexes = NSMutableArray()
            self.addressToIdxDict.setObject(indexes!, forKey:address as NSCopying)
        }
        
        indexes!.add(self.importedAddresses.count-1)
        
        setLabel(importedAddressObject.getDefaultAddressLabel()!, positionInWalletArray:importedAddressObject.getPositionInWalletArray())
        
        return importedAddressObject
    }
    
    func setLabel(_ label:String, positionInWalletArray:Int) {
        let importedAddressObject = self.addressToPositionInWalletArrayDict.object(forKey: positionInWalletArray) as! TLImportedAddress
        
        importedAddressObject.setLabel(label as NSString)
        if (self.accountAddressType == .imported) {
            self.appWallet!.setImportedPrivateKeyLabel(self.coinType, label: label, idx:positionInWalletArray)
        } else if (self.accountAddressType! == .importedWatch) {
            self.appWallet!.setWatchOnlyAddressLabel(self.coinType, label: label, idx:positionInWalletArray)
        }
    }
    
    func archiveAddress(_ positionInWalletArray:Int) -> () {
        self.setArchived(positionInWalletArray, archive:true)
        
        let toMoveAddressObject = self.addressToPositionInWalletArrayDict.object(forKey: positionInWalletArray) as! TLImportedAddress
        var indexes = self.addressToIdxDict.object(forKey: toMoveAddressObject.getAddress()) as? NSMutableArray
        if (indexes == nil) {
            indexes = NSMutableArray()
            self.addressToIdxDict.setObject(indexes!, forKey:toMoveAddressObject.getAddress() as NSCopying)
        }
        let toMoveIndex = self.importedAddresses.index(of: toMoveAddressObject) as Int
        
        for key in self.addressToIdxDict {
            let indexes: AnyObject = (self.addressToIdxDict.object(forKey: key.key) as! NSArray).copy() as AnyObject
            
            for idx in indexes as! [Int] {
                if (idx > toMoveIndex) {
                    let indexes = self.addressToIdxDict.object(forKey: key.key) as! NSMutableArray
                    indexes.remove(idx)
                    indexes.add(UInt(idx)-1)
                }
            }
        }
        
        indexes!.remove(toMoveIndex)
        
        self.importedAddresses.remove(toMoveAddressObject)
        for i in stride(from: 0, to: self.archivedImportedAddresses.count, by: 1) {
            let importedAddressObject = self.archivedImportedAddresses.object(at: i) as! TLImportedAddress
            
            if (importedAddressObject.getPositionInWalletArray() > toMoveAddressObject.getPositionInWalletArray()) {
                self.archivedImportedAddresses.insert(toMoveAddressObject, at:i)
                return
            }
        }
        self.archivedImportedAddresses.add(toMoveAddressObject)
    }
    
    func unarchiveAddress(_ positionInWalletArray:Int) -> (){
        setArchived(positionInWalletArray, archive:false)
        
        let toMoveAddressObject = self.addressToPositionInWalletArrayDict.object(forKey: positionInWalletArray) as! TLImportedAddress
        
        self.archivedImportedAddresses.remove(toMoveAddressObject)
        for i in stride(from: 0, to: self.importedAddresses.count, by: 1) {
            let importedAddressObject = self.importedAddresses.object(at: i) as! TLImportedAddress
            if (importedAddressObject.getPositionInWalletArray() > toMoveAddressObject.getPositionInWalletArray()) {
                self.importedAddresses.insert(toMoveAddressObject, at:i)
                var indexes = self.addressToIdxDict.object(forKey: toMoveAddressObject.getAddress()) as? NSMutableArray
                if (indexes == nil) {
                    indexes = NSMutableArray()
                    indexes!.add(i)
                    self.addressToIdxDict.setObject(indexes!, forKey:toMoveAddressObject.getAddress() as NSCopying)
                }
                
                for key in self.addressToIdxDict {
                    let indexes: AnyObject = (self.addressToIdxDict.object(forKey: key.key) as! NSArray).copy() as AnyObject
                    for idx in indexes as! [Int] {
                        if (idx >= i) {
                            let indexes = self.addressToIdxDict.object(forKey: key.key) as! NSMutableArray
                            indexes.remove(idx)
                            indexes.add(UInt(idx)+1)
                        }
                    }
                }
                
                return
            }
        }
        self.importedAddresses.add(toMoveAddressObject)
    }
    
    fileprivate func setArchived(_ positionInWalletArray:Int, archive:Bool) -> Bool{
        let importedAddressObject = self.addressToPositionInWalletArrayDict.object(forKey: positionInWalletArray) as! TLImportedAddress
        
        importedAddressObject.setArchived(archive)
        if (self.accountAddressType! == .imported) {
            self.appWallet!.setImportedPrivateKeyArchive(self.coinType, archive: archive, idx:positionInWalletArray)
        } else if (self.accountAddressType == .importedWatch) {
            self.appWallet!.setWatchOnlyAddressArchive(self.coinType, archive: archive, idx:positionInWalletArray)
        }
        
        return true
    }
    
    func deleteAddress(_ idx:Int) -> Bool {
        let importedAddressObject = self.archivedImportedAddresses.object(at: idx) as! TLImportedAddress
        
        self.archivedImportedAddresses.removeObject(at: idx)
        if (self.accountAddressType == .imported) {
            self.appWallet!.deleteImportedPrivateKey(self.coinType, idx: importedAddressObject.getPositionInWalletArray())
        } else if (self.accountAddressType == .importedWatch) {
            self.appWallet!.deleteImportedWatchAddress(self.coinType, idx: importedAddressObject.getPositionInWalletArray())
        }
        
        self.addressToPositionInWalletArrayDict.removeObject(forKey: importedAddressObject.getPositionInWalletArrayNumber())
        let tmpDict = self.addressToPositionInWalletArrayDict.copy() as! NSDictionary
        for (key, _) in tmpDict {
            let ia = self.addressToPositionInWalletArrayDict.object(forKey: key as! NSNumber) as! TLImportedAddress
            if (ia.getPositionInWalletArray() > importedAddressObject.getPositionInWalletArray()) {
                ia.setPositionInWalletArray(ia.getPositionInWalletArray()-1)
                self.addressToPositionInWalletArrayDict.setObject(ia, forKey:ia.getPositionInWalletArrayNumber())
            }
        }
        

        if importedAddressObject.getPositionInWalletArray() < self.addressToPositionInWalletArrayDict.count - 1 {
            self.addressToPositionInWalletArrayDict.removeObject(forKey: self.addressToPositionInWalletArrayDict.count-1)
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

