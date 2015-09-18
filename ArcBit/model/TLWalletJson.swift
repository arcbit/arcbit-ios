//
//  TLWalletJson.swift
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

class TLWalletJson {

    class func getDecryptedEncryptedWalletJSONPassphrase() -> String? {
        let encryptedWalletPassphraseKey = TLPreferences.getEncryptedWalletPassphraseKey()
        if encryptedWalletPassphraseKey != nil {
            let encryptedWalletPassphrase = TLPreferences.getEncryptedWalletJSONPassphrase(TLPreferences.canRestoreDeletedApp())
            let decryptedEncryptedWalletPassphrase = TLWalletPassphrase.decryptWalletPassphrase(encryptedWalletPassphrase!,
                key: encryptedWalletPassphraseKey!)
            assert(decryptedEncryptedWalletPassphrase != nil)
            return decryptedEncryptedWalletPassphrase
        } else {
            return TLPreferences.getEncryptedWalletJSONPassphrase(TLPreferences.canRestoreDeletedApp())
        }
    }
    
    class func getWalletJsonFileName() -> (String) {
        return "wallet.json.asc"
    }
        
    class func generatePayloadChecksum(payload: String) -> String {
        return TLCrypto.doubleSHA256HashFor(payload)
    }
    
    class func getEncryptedWalletJsonContainer(walletJson: NSDictionary, password: String) -> (String) {
        assert(TLHDWalletWrapper.phraseIsValid(password), "phrase is invalid")
        var str = TLUtils.dictionaryToJSONString(false, dict: walletJson)
        //DLog("getEncryptedWalletJsonContainer str: %@", str)
        let encryptJSONPassword = TLCrypto.doubleSHA256HashFor(password)
        str = TLCrypto.encrypt(str, password: encryptJSONPassword)
        let walletJsonEncryptedWrapperDict = ["version":1, "payload":str]
        let walletJsonEncryptedWrapperString = TLUtils.dictionaryToJSONString(true, dict: walletJsonEncryptedWrapperDict)
        return walletJsonEncryptedWrapperString
    }
    
    class func saveWalletJson(walletfile: String, date: NSDate) -> (Bool) {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
        let documentsDirectory: AnyObject = paths.objectAtIndex(0)
        let filePath = documentsDirectory.stringByAppendingPathComponent(TLWalletJson.getWalletJsonFileName())
        
        var error: NSError? = nil
        do {
            try walletfile.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch let error1 as NSError {
            error = error1
        }
        if (error != nil) {
            return false
        } else {
            return true
        }
    }
    
    class func getWalletJsonDict(encryptedWalletJSONFileContent: String?, password: String?) -> (NSDictionary?) {
        if encryptedWalletJSONFileContent == nil {
            return nil
        }
        
        let walletJsonEncryptedWrapperDict = TLUtils.JSONStringToDictionary(encryptedWalletJSONFileContent!)

        let version = walletJsonEncryptedWrapperDict.objectForKey("version") as! Int
        assert(version == 1, "Incorrect encryption version")
        
        let encryptedWalletJSONPayloadString = walletJsonEncryptedWrapperDict.objectForKey("payload") as! String
        
        let walletJsonString = decryptWalletJSONFile(encryptedWalletJSONPayloadString, password: password)
        if (walletJsonString == nil) {
            return nil
        }
        
        let walletJsonData = walletJsonString!.dataUsingEncoding(NSUTF8StringEncoding)
        
        let error: NSError? = nil
        let walletDict = (try! NSJSONSerialization.JSONObjectWithData(walletJsonData!,
            options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
        assert(error == nil, "Error serializing wallet json string")
        //DLog("getWalletJsonDict: %@", walletDict.description)
        return walletDict
    }
    
    class func getLocalWalletJSONFile() -> (String?) {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
        let documentsDirectory: AnyObject = paths.objectAtIndex(0)
        let filePath = documentsDirectory.stringByAppendingPathComponent(TLWalletJson.getWalletJsonFileName())
        
        let error: NSError? = nil
        if (error != nil) {
            DLog("TLWalletJson error getWalletJsonString: %@", function: error!.localizedDescription)
            return nil
        }
        
        do {
            let contents = try NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
            return contents as? String
        } catch _ {
            return nil
        }
    }
    
    class func decryptWalletJSONFile(encryptedWalletJSONFile: String?, password: String?) -> (String?) {
        if (encryptedWalletJSONFile == nil || password == nil) {
            return nil
        }
        assert(TLHDWalletWrapper.phraseIsValid(password!), "phrase is invalid")
        let encryptJSONPassword = TLCrypto.doubleSHA256HashFor(password!)
        let str = TLCrypto.decrypt(encryptedWalletJSONFile!, password: encryptJSONPassword)
        //DLog("getWalletJsonString: %@", str)
        return str
    }
}
