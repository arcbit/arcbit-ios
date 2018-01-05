//
//  TLAccounts.swift
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

@objc class TLAccounts:NSObject {
    fileprivate var appWallet:TLWallet?
    fileprivate var accountsDict:NSMutableDictionary?
    fileprivate let accountsArray = NSMutableArray()
    fileprivate let archivedAccountsArray = NSMutableArray()
    fileprivate var coinType:TLCoinType = TLCoinType.BTC
    fileprivate var accountType:TLAccountType?

    init(appWallet: TLWallet, coinType: TLCoinType, accountsArray: NSArray, accountType at:TLAccountType) {
        super.init()
        self.appWallet = appWallet
        self.coinType = coinType
        accountType = at
        
        self.accountsDict = NSMutableDictionary(capacity: accountsArray.count)
        
        for i in stride(from: 0, to: accountsArray.count, by: 1) {
            let accountObject = accountsArray.object(at: i) as! TLAccountObject
            if (accountObject.isArchived()) {
                self.archivedAccountsArray.add(accountObject)
            } else {
                self.accountsArray.add(accountObject)
            }
            
            accountObject.setPositionInWalletArray(i)
            self.accountsDict!.setObject(accountObject, forKey:i as NSCopying)
        }
    }
    
    @discardableResult func addAccountWithExtendedKey(_ extendedKey:String, accountName:String) -> TLAccountObject {
        assert(accountType != TLAccountType.hdWallet, "accountType == TLAccountTypeHDWallet")
        let accountObject:TLAccountObject
        
        if (accountType == TLAccountType.coldWallet) {
            accountObject = self.appWallet!.addColdWalletAccount(self.coinType, extendedPublicKey: extendedKey)
        } else if (accountType == TLAccountType.imported) {
            accountObject = self.appWallet!.addImportedAccount(self.coinType, extendedPrivateKey: extendedKey)
        } else {
            accountObject = self.appWallet!.addWatchOnlyAccount(self.coinType, extendedPublicKey: extendedKey)
        }
        self.accountsArray.add(accountObject)
        let positionInWalletArray = self.getNumberOfAccounts()+getNumberOfArchivedAccounts()-1
        accountObject.setPositionInWalletArray(positionInWalletArray)
        self.accountsDict!.setObject(accountObject, forKey:accountObject.getPositionInWalletArray() as NSCopying)
        
        renameAccount(positionInWalletArray, accountName: accountName)
        
        return accountObject
    }
    
    fileprivate func addAccount(_ accountObject: TLAccountObject) -> (Bool){
        assert(accountType == TLAccountType.hdWallet, "accountType != TLAccountTypeHDWallet")
        assert(self.accountsDict!.object(forKey: accountObject.getAccountIdxNumber()) == nil, "")
        
        self.accountsDict!.setObject(accountObject, forKey:accountObject.getAccountIdxNumber() as NSCopying)
        self.accountsArray.add(accountObject)
        
        return true
    }
    
    @discardableResult func renameAccount(_ accountIdxNumber:Int, accountName:String) -> (Bool){
        if (accountType == TLAccountType.hdWallet) {
            let accountObject = self.accountsDict!.object(forKey: accountIdxNumber) as! TLAccountObject
            accountObject.renameAccount(accountName)
            self.appWallet!.renameAccount(self.coinType, accountIdxNumber: accountObject.getAccountIdxNumber(), accountName:accountName)
        } else  {
            let accountObject = self.getAccountObjectForAccountIdxNumber(accountIdxNumber)
            accountObject.renameAccount(accountName)
            if (accountType == TLAccountType.coldWallet) {
                self.appWallet!.setColdWalletAccountName(self.coinType, name: accountName, idx:accountIdxNumber)
            } else if (accountType == TLAccountType.imported) {
                self.appWallet!.setImportedAccountName(self.coinType, name: accountName, idx:accountIdxNumber)
            } else if (accountType == TLAccountType.importedWatch) {
                self.appWallet!.setWatchOnlyAccountName(self.coinType, name: accountName, idx:accountIdxNumber)
            }
        }
        
        return true
    }
    
    //in this context accountIdx is not the accountID, accountIdx is simply the order in which i want to display the accounts, neccessary cuz accounts can be deleted and such,
    func getAccountObjectForIdx(_ idx:Int)-> (TLAccountObject) {
        return self.accountsArray.object(at: idx) as! TLAccountObject
    }
    
    func getArchivedAccountObjectForIdx(_ idx:Int) -> TLAccountObject {
        return self.archivedAccountsArray.object(at: idx) as! TLAccountObject
    }
    
    func getIdxForAccountObject(_ accountObject:TLAccountObject) -> (Int){
        return self.accountsArray.index(of: accountObject) as Int
    }
    
    func getNumberOfAccounts() -> Int {
        return self.accountsArray.count
    }
    
    func getNumberOfArchivedAccounts() -> Int{
        return self.archivedAccountsArray.count
    }
    
    
    func getAccountObjectForAccountIdxNumber(_ accountIdxNumber:Int) ->TLAccountObject {
        return self.accountsDict!.object(forKey: accountIdxNumber) as! TLAccountObject
    }
    
    func archiveAccount(_ positionInWalletArray:Int) -> (){
        setArchiveAccount(positionInWalletArray, enabled:true)
        
        let toMoveAccountObject = self.accountsDict!.object(forKey: positionInWalletArray) as! TLAccountObject
        
        self.accountsArray.remove(toMoveAccountObject)
        for i in stride(from: 0, to: self.archivedAccountsArray.count, by: 1) {
            let accountObject = self.archivedAccountsArray.object(at: i) as! TLAccountObject
            
            if (accountObject.getPositionInWalletArray() > toMoveAccountObject.getPositionInWalletArray()) {
                self.archivedAccountsArray.insert(toMoveAccountObject, at:i)
                return
            }
        }
        self.archivedAccountsArray.add(toMoveAccountObject)
    }
    
    func unarchiveAccount(_ positionInWalletArray:Int) -> (){
        setArchiveAccount(positionInWalletArray, enabled:false)
        
        let toMoveAccountObject = self.accountsDict!.object(forKey: positionInWalletArray) as! TLAccountObject
        
        self.archivedAccountsArray.remove(toMoveAccountObject)
        for i in stride(from: 0, to: self.accountsArray.count, by: 1) {
            let accountObject = self.accountsArray.object(at: i) as! TLAccountObject
            if (accountObject.getPositionInWalletArray() > toMoveAccountObject.getPositionInWalletArray()) {
                self.accountsArray.insert(toMoveAccountObject, at:i)
                return
            }
        }
        self.accountsArray.add(toMoveAccountObject)
    }
    
    fileprivate func setArchiveAccount(_ accountIdxNumber:Int, enabled:Bool)  -> (){
        let accountObject = getAccountObjectForAccountIdxNumber(accountIdxNumber) as TLAccountObject
        accountObject.archiveAccount(enabled)
        
        if (accountType == TLAccountType.hdWallet) {
            self.appWallet!.archiveAccountHDWallet(self.coinType, accountIdx: accountIdxNumber, enabled:enabled)
        } else if (accountType == TLAccountType.coldWallet) {
            self.appWallet!.archiveAccountColdWalletAccount(self.coinType, idx: accountIdxNumber, enabled:enabled)
        } else if (accountType == TLAccountType.imported) {
            self.appWallet!.archiveAccountImportedAccount(self.coinType, idx: accountIdxNumber, enabled:enabled)
        } else if (accountType == TLAccountType.importedWatch) {
            self.appWallet!.archiveAccountImportedWatchAccount(self.coinType, idx: accountIdxNumber, enabled:enabled)
        }
    }
    
    @discardableResult func createNewAccount(_ accountName:String, accountType:TLAccount) -> TLAccountObject {
        let accountObject = self.appWallet!.createNewAccount(self.coinType, accountName: accountName, accountType:TLAccount.normal,
            preloadStartingAddresses:true)
        accountObject.updateAccountNeedsRecovering(false)
        addAccount(accountObject)
        return accountObject
    }
    
    func createNewAccount(_ accountName:String, accountType:TLAccount, preloadStartingAddresses:Bool) -> TLAccountObject {
        let accountObject = self.appWallet!.createNewAccount(self.coinType, accountName: accountName, accountType:TLAccount.normal, preloadStartingAddresses:preloadStartingAddresses)
        addAccount(accountObject)
        return accountObject
    }
    
    @discardableResult func popTopAccount() -> (Bool){
        if (self.accountsArray.count <= 0) {
            return false
        }
        
        let accountObject = self.accountsArray.lastObject as! TLAccountObject
        self.accountsDict!.removeObject(forKey: accountObject.getAccountIdxNumber())
        
        self.accountsArray.removeLastObject()
        self.appWallet!.removeTopAccount(self.coinType)
        return true
    }
    
    func deleteAccount(_ idx:Int) -> (Bool){
        assert(accountType != TLAccountType.hdWallet, "accountType == TLAccountTypeHDWallet")
        
        let accountObject = self.archivedAccountsArray.object(at: idx) as! TLAccountObject
        self.archivedAccountsArray.removeObject(at: idx)
        
        if (accountType == TLAccountType.coldWallet) {
            self.appWallet!.deleteColdWalletAccount(self.coinType, idx: accountObject.getPositionInWalletArray())
        } else if (accountType == TLAccountType.imported) {
            self.appWallet!.deleteImportedAccount(self.coinType, idx: accountObject.getPositionInWalletArray())
        } else if (accountType == TLAccountType.importedWatch) {
            self.appWallet!.deleteWatchOnlyAccount(self.coinType, idx: accountObject.getPositionInWalletArray())
        }
        
        self.accountsDict!.removeObject(forKey: accountObject.getPositionInWalletArray())
        
        let tmpDict = self.accountsDict!.copy() as! NSDictionary
        for (key, _) in tmpDict {
            let ao = self.accountsDict!.object(forKey: key) as! TLAccountObject
            if (ao.getPositionInWalletArray() > accountObject.getPositionInWalletArray()) {
                ao.setPositionInWalletArray(ao.getPositionInWalletArray()-1)
                self.accountsDict!.setObject(ao, forKey:ao.getPositionInWalletArray() as NSCopying)
            }
        }
        
        if (accountObject.getPositionInWalletArray() < self.accountsDict!.count - 1) {
            self.accountsDict!.removeObject(forKey: self.accountsDict!.count-1)
        }
        
        return true
    }
}

