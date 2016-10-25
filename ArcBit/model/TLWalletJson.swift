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
        
    class func generatePayloadChecksum(_ payload: String) -> String {
        return TLCrypto.doubleSHA256HashFor(payload)
    }
    
    class func getEncryptedWalletJsonContainer(_ walletJson: NSDictionary, password: String) -> (String) {
        assert(TLHDWalletWrapper.phraseIsValid(password), "phrase is invalid")
        var str = TLUtils.dictionaryToJSONString(false, dict: walletJson)
        //DLog("getEncryptedWalletJsonContainer str: %@", str)
        let encryptJSONPassword = TLCrypto.doubleSHA256HashFor(password)
        str = TLCrypto.encrypt(str, password: encryptJSONPassword)
        let walletJsonEncryptedWrapperDict = ["version":1, "payload":str]
        let walletJsonEncryptedWrapperString = TLUtils.dictionaryToJSONString(true, dict: walletJsonEncryptedWrapperDict)
        return walletJsonEncryptedWrapperString
    }
    
    class func getWalletJsonDict(_ encryptedWalletJSONFileContent: String?, password: String?) -> (NSDictionary?) {
        if encryptedWalletJSONFileContent == nil {
            return nil
        }
        
        let walletJsonEncryptedWrapperDict = TLUtils.JSONStringToDictionary(encryptedWalletJSONFileContent!)

        let version = walletJsonEncryptedWrapperDict.object(forKey: "version") as! Int
        assert(version == 1, "Incorrect encryption version")
        
        let encryptedWalletJSONPayloadString = walletJsonEncryptedWrapperDict.object(forKey: "payload") as! String
        
        let walletJsonString = decryptWalletJSONFile(encryptedWalletJSONPayloadString, password: password)
        if (walletJsonString == nil) {
            return nil
        }
        
        let walletJsonData = walletJsonString!.data(using: String.Encoding.utf8)
        
        let error: NSError? = nil
        let walletDict = (try! JSONSerialization.jsonObject(with: walletJsonData!,
            options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
        assert(error == nil, "Error serializing wallet json string")
        //DLog("getWalletJsonDict: %@", walletDict.description)
        return walletDict
    }
    
    class func decryptWalletJSONFile(_ encryptedWalletJSONFile: String?, password: String?) -> (String?) {
        if (encryptedWalletJSONFile == nil || password == nil) {
            return nil
        }
        assert(TLHDWalletWrapper.phraseIsValid(password!), "phrase is invalid")
        let encryptJSONPassword = TLCrypto.doubleSHA256HashFor(password!)
        let str = TLCrypto.decrypt(encryptedWalletJSONFile!, password: encryptJSONPassword)
        //DLog("getWalletJsonString: %@", str)
        return str
    }
    
    class func saveWalletJson(_ walletFile: String, date: Date) -> (Bool) {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray
        let documentsDirectory: AnyObject = paths.object(at: 0) as AnyObject
        let filePath = documentsDirectory.appendingPathComponent(TLWalletJson.getWalletJsonFileName())
        
        var error: NSError? = nil
        do {
            try walletFile.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
        } catch let error1 as NSError {
            error = error1
        }
        if (error != nil) {
            return false
        } else {
            return true
        }
    }
    
    class func getLocalWalletJSONFile() -> (String?) {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray
        let documentsDirectory: AnyObject = paths.object(at: 0) as AnyObject
        let filePath = documentsDirectory.appendingPathComponent(TLWalletJson.getWalletJsonFileName())
        
        let error: NSError? = nil
        if (error != nil) {
            DLog("TLWalletJson error getWalletJsonString: %@", function: error!.localizedDescription)
            return nil
        }
        
        do {
            let contents = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8)
            return contents as String
        } catch _ {
            return nil
        }
    }
}
