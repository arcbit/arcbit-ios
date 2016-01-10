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
    private var appWallet:TLWallet?
    private var accountsDict:NSMutableDictionary?
    private let accountsArray = NSMutableArray()
    private let archivedAccountsArray = NSMutableArray()
    private var accountType:TLAccountType?

    init(appWallet: TLWallet, accountsArray: NSArray, accountType at:TLAccountType) {
        super.init()
        self.appWallet = appWallet
        accountType = at
        
        self.accountsDict = NSMutableDictionary(capacity: accountsArray.count)
        
        for (var i:Int = 0; i < accountsArray.count; i++) {
            let accountObject = accountsArray.objectAtIndex(i) as! TLAccountObject
            if (accountObject.isArchived()) {
                self.archivedAccountsArray.addObject(accountObject)
            } else {
                self.accountsArray.addObject(accountObject)
            }
            
            accountObject.setPositionInWalletArray(i)
            self.accountsDict!.setObject(accountObject, forKey:i)
        }
    }
    
    func addAccountWithExtendedKey(extendedPrivateKey:String) -> TLAccountObject {
        assert(accountType != TLAccountType.HDWallet, "accountType == TLAccountTypeHDWallet")
        let accountObject:TLAccountObject
        
        if (accountType == TLAccountType.Imported) {
            accountObject = self.appWallet!.addImportedAccount(extendedPrivateKey)
        } else {
            accountObject = self.appWallet!.addWatchOnlyAccount(extendedPrivateKey)
        }
        self.accountsArray.addObject(accountObject)
        let positionInWalletArray = self.getNumberOfAccounts()+getNumberOfArchivedAccounts()-1
        accountObject.setPositionInWalletArray(positionInWalletArray)
        self.accountsDict!.setObject(accountObject, forKey:accountObject.getPositionInWalletArray())
        
        renameAccount(positionInWalletArray, accountName: accountObject.getDefaultNameAccount())
        
        return accountObject
    }
    
    private func addAccount(accountObject: TLAccountObject) -> (Bool){
        assert(accountType == TLAccountType.HDWallet, "accountType != TLAccountTypeHDWallet")
        assert(self.accountsDict!.objectForKey(accountObject.getAccountIdxNumber()) == nil, "")
        
        self.accountsDict!.setObject(accountObject, forKey:accountObject.getAccountIdxNumber())
        self.accountsArray.addObject(accountObject)
        
        return true
    }
    
    func renameAccount(accountIdxNumber:Int, accountName:String) -> (Bool){
        if (accountType == TLAccountType.HDWallet) {
            let accountObject = self.accountsDict!.objectForKey(accountIdxNumber) as! TLAccountObject
            accountObject.renameAccount(accountName)
            self.appWallet!.renameAccount(accountObject.getAccountIdxNumber(), accountName:accountName)
        } else  {
            if (accountType == TLAccountType.Imported) {
                let accountObject = self.getAccountObjectForAccountIdxNumber(accountIdxNumber)
                accountObject.renameAccount(accountName)
                self.appWallet!.setImportedAccountName(accountName, idx:accountIdxNumber)
            } else if (accountType == TLAccountType.ImportedWatch) {
                let accountObject = self.getAccountObjectForAccountIdxNumber(accountIdxNumber)
                accountObject.renameAccount(accountName)
                self.appWallet!.setWatchOnlyAccountName(accountName, idx:accountIdxNumber)
            }
        }
        
        return true
    }
    
    //in this context accountIdx is not the accountID, accountIdx is simply the order in which i want to display the accounts, neccessary cuz accounts can be deleted and such,
    func getAccountObjectForIdx(idx:Int)-> (TLAccountObject) {
        return self.accountsArray.objectAtIndex(idx) as! TLAccountObject
    }
    
    func getArchivedAccountObjectForIdx(idx:Int) -> TLAccountObject {
        return self.archivedAccountsArray.objectAtIndex(idx) as! TLAccountObject
    }
    
    func getIdxForAccountObject(accountObject:TLAccountObject) -> (Int){
        return self.accountsArray.indexOfObject(accountObject) as Int
    }
    
    func getNumberOfAccounts() -> Int {
        return self.accountsArray.count
    }
    
    func getNumberOfArchivedAccounts() -> Int{
        return self.archivedAccountsArray.count
    }
    
    
    func getAccountObjectForAccountIdxNumber(accountIdxNumber:Int) ->TLAccountObject {
        return self.accountsDict!.objectForKey(accountIdxNumber) as! TLAccountObject
    }
    
    func archiveAccount(positionInWalletArray:Int) -> (){
        setArchiveAccount(positionInWalletArray, enabled:true)
        
        let toMoveAccountObject = self.accountsDict!.objectForKey(positionInWalletArray) as! TLAccountObject
        
        self.accountsArray.removeObject(toMoveAccountObject)
        for (var i = 0; i < self.archivedAccountsArray.count; i++) {
            let accountObject = self.archivedAccountsArray.objectAtIndex(i) as! TLAccountObject
            
            if (accountObject.getPositionInWalletArray() > toMoveAccountObject.getPositionInWalletArray()) {
                self.archivedAccountsArray.insertObject(toMoveAccountObject, atIndex:i)
                return
            }
        }
        self.archivedAccountsArray.addObject(toMoveAccountObject)
    }
    
    func unarchiveAccount(positionInWalletArray:Int) -> (){
        setArchiveAccount(positionInWalletArray, enabled:false)
        
        let toMoveAccountObject = self.accountsDict!.objectForKey(positionInWalletArray) as! TLAccountObject
        
        self.archivedAccountsArray.removeObject(toMoveAccountObject)
        for (var i = 0; i < self.accountsArray.count; i++) {
            let accountObject = self.accountsArray.objectAtIndex(i) as! TLAccountObject
            if (accountObject.getPositionInWalletArray() > toMoveAccountObject.getPositionInWalletArray()) {
                self.accountsArray.insertObject(toMoveAccountObject, atIndex:i)
                return
            }
        }
        self.accountsArray.addObject(toMoveAccountObject)
    }
    
    private func setArchiveAccount(accountIdxNumber:Int, enabled:Bool)  -> (){
        let accountObject = getAccountObjectForAccountIdxNumber(accountIdxNumber) as TLAccountObject
        accountObject.archiveAccount(enabled)
        
        if (accountType == TLAccountType.HDWallet) {
            self.appWallet!.archiveAccountHDWallet(accountIdxNumber, enabled:enabled)
        } else if (accountType == TLAccountType.Imported) {
            self.appWallet!.archiveAccountImportedAccount(accountIdxNumber, enabled:enabled)
        } else if (accountType == TLAccountType.ImportedWatch) {
            self.appWallet!.archiveAccountImportedWatchAccount(accountIdxNumber, enabled:enabled)
        }
    }
    
    private func getAccountWithAccountName(accountName:String?) -> TLAccountObject?{
        for key in self.accountsDict! {
            let accountObject = self.accountsDict!.objectForKey(key.key) as! TLAccountObject
            if (accountObject.getAccountName() == accountName)
            {
                return accountObject
            }
        }
        return nil
    }
    
    func accountNameExist(accountName:String) -> (Bool) {
        return getAccountWithAccountName(accountName) == nil ? false : true
    }
    
    func createNewAccount(accountName:String, accountType:TLAccount) -> TLAccountObject {
        let accountObject = self.appWallet!.createNewAccount(accountName, accountType:TLAccount.Normal,
            preloadStartingAddresses:true)
        accountObject.updateAccountNeedsRecovering(false)
        addAccount(accountObject)
        return accountObject
    }
    
    func createNewAccount(accountName:String, accountType:TLAccount, preloadStartingAddresses:Bool) -> TLAccountObject {
        let accountObject = self.appWallet!.createNewAccount(accountName, accountType:TLAccount.Normal, preloadStartingAddresses:preloadStartingAddresses)
        addAccount(accountObject)
        return accountObject
    }
    
    func popTopAccount() -> (Bool){
        if (self.accountsArray.count <= 0) {
            return false
        }
        
        let accountObject = self.accountsArray.lastObject as! TLAccountObject
        self.accountsDict!.removeObjectForKey(accountObject.getAccountIdxNumber())
        
        self.accountsArray.removeLastObject()
        self.appWallet!.removeTopAccount()
        return true
    }
    
    func deleteAccount(idx:Int) -> (Bool){
        assert(accountType != TLAccountType.HDWallet, "accountType == TLAccountTypeHDWallet")
        
        let accountObject = self.archivedAccountsArray.objectAtIndex(idx) as! TLAccountObject
        self.archivedAccountsArray.removeObjectAtIndex(idx)
        
        if (accountType == TLAccountType.Imported) {
            self.appWallet!.deleteImportedAccount(accountObject.getPositionInWalletArray())
        } else if (accountType == TLAccountType.ImportedWatch) {
            self.appWallet!.deleteWatchOnlyAccount(accountObject.getPositionInWalletArray())
        }
        
        self.accountsDict!.removeObjectForKey(accountObject.getPositionInWalletArray())
        
        let tmpDict = self.accountsDict!.copy() as! NSDictionary
        for (key, _) in tmpDict {
            let ao = self.accountsDict!.objectForKey(key) as! TLAccountObject
            if (ao.getPositionInWalletArray() > accountObject.getPositionInWalletArray()) {
                ao.setPositionInWalletArray(ao.getPositionInWalletArray()-1)
                self.accountsDict!.setObject(ao, forKey:ao.getPositionInWalletArray())
            }
        }
        
        if (accountObject.getPositionInWalletArray() < self.accountsDict!.count - 1) {
            self.accountsDict!.removeObjectForKey(self.accountsDict!.count-1)
        }
        
        return true
    }
}

