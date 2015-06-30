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
let kRNCryptorAES256Settings:RNCryptorSettings  = RNCryptorSettings(algorithm: CCAlgorithm(kCCAlgorithmAES128), blockSize: kCCBlockSizeAES128, IVSize: kCCBlockSizeAES128,
    options: CCOptions(kCCOptionPKCS7Padding), HMACAlgorithm: CCHmacAlgorithm(kCCHmacAlgSHA256), HMACLength: Int(CC_SHA256_DIGEST_LENGTH),
    keySettings: RNCryptorKeyDerivationSettings(keySize: kCCKeySizeAES256, saltSize: 8, PBKDFAlgorithm: CCPBKDFAlgorithm(kCCPBKDF2), PRF: CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1), rounds: 10000, hasV2Password: false),
    HMACKeySettings: RNCryptorKeyDerivationSettings(keySize: kCCKeySizeAES256, saltSize: 8, PBKDFAlgorithm: CCPBKDFAlgorithm(kCCPBKDF2), PRF: CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1), rounds: 10000, hasV2Password: false))


@objc class TLWalletJson {

    class func getWalletJsonFileName() -> (String) {
        return "wallet.json.asc"
    }
    
    class func getDefaultPBKDF2Iterations() -> UInt32 {        
        return 10000
    }
    
    class func encrypt(plainText: String, password: String) -> (String) {
        return TLWalletJson.encrypt(plainText, password: password, PBKDF2Iterations: getDefaultPBKDF2Iterations())
    }
    
    class func decrypt(cipherText: String, password: String) -> (String?) {
        return TLWalletJson.decrypt(cipherText, password: password, PBKDF2Iterations: getDefaultPBKDF2Iterations())
    }
    
    class func encrypt(plainText: String, password: String, PBKDF2Iterations: UInt32) -> String {
        var settings = kRNCryptorAES256Settings
        settings.keySettings.rounds = PBKDF2Iterations
        //DLog("saveWalletJson encrypt: %@", plainText)

        let data = plainText.dataUsingEncoding(NSUTF8StringEncoding)
        var error: NSError? = nil
        var encryptedData = RNEncryptor.encryptData(data, withSettings: settings, password: password, error: &error)
        
        if (error != nil) {
            DLog("TLWalletJson encrypt error: %@", error!.localizedDescription)
            NSException(name: "Error", reason: "Error encrypting", userInfo: nil).raise()
        }
        
        let base64EncryptedString = encryptedData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        //DLog("TLWalletJson encrypt base64EncryptedData: %@", base64EncryptedString)
        return base64EncryptedString
    }
    
    class func decrypt(cipherText: String, password: String, PBKDF2Iterations: UInt32) -> String? {
        var settings = kRNCryptorAES256Settings
        settings.keySettings.rounds = PBKDF2Iterations
        
        let encryptedData = NSData(base64EncodedString: cipherText, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        var error: NSError? = nil
        let decryptedData = RNDecryptor.decryptData(encryptedData,
            withSettings: settings,
            password: password,
            error: &error)
        
        // Note: there will only be error if password is incorrect, if PBKDF2Iterations dont match then there will be no error, just nil decryptedData
        if (error != nil) {
            return nil
        }
        
        let decryptedString = NSString(data: decryptedData!, encoding: NSUTF8StringEncoding)
        //DLog("TLWalletJson decrypt decryptedString: %@", decryptedString)
        return decryptedString as? String
    }
    
    class func generatePayloadChecksum(payload: String) -> String {
        return TLUtils.doubleSHA256HashFor(payload)
    }
    
    class func getEncryptedWalletJsonContainer(walletJson: NSDictionary, password: String) -> (String) {
        var str = TLUtils.dictionaryToJSONString(false, dict: walletJson)
        //DLog("getEncryptedWalletJsonContainer str: %@", str)
        let encryptJSONPassword = TLUtils.doubleSHA256HashFor(password)
        str = encrypt(str, password: encryptJSONPassword)
        let walletJsonEncryptedWrapperDict = ["version":1, "payload":str]
        let walletJsonEncryptedWrapperString = TLUtils.dictionaryToJSONString(true, dict: walletJsonEncryptedWrapperDict)
        return walletJsonEncryptedWrapperString
    }
    
    class func saveWalletJson(walletfile: String, date: NSDate) -> (Bool) {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
        let documentsDirectory: AnyObject = paths.objectAtIndex(0)
        let filePath = documentsDirectory.stringByAppendingPathComponent(TLWalletJson.getWalletJsonFileName())
        
        var error: NSError? = nil
        walletfile.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
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
        
        var error: NSError? = nil
        let walletDict = NSJSONSerialization.JSONObjectWithData(walletJsonData!,
            options: NSJSONReadingOptions.MutableContainers,
            error: &error) as! NSDictionary
        assert(error == nil, "Error serializing wallet json string")

        //DLog("getWalletJsonDict: %@", walletDict.description())
        return walletDict
    }
    
    class func getLocalWalletJSONFile() -> (String?) {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
        let documentsDirectory: AnyObject = paths.objectAtIndex(0)
        let filePath = documentsDirectory.stringByAppendingPathComponent(TLWalletJson.getWalletJsonFileName())
        
        var error: NSError? = nil
        if (error != nil) {
            DLog("TLWalletJson error getWalletJsonString: %@", error!.localizedDescription)
            return nil
        }
        
        return NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: &error) as? String
    }
    
    class func decryptWalletJSONFile(encryptedWalletJSONFile: String?, password: String?) -> (String?) {
        if (encryptedWalletJSONFile == nil || password == nil) {
            return nil
        }
        
        let encryptJSONPassword = TLUtils.doubleSHA256HashFor(password!)
        let str = decrypt(encryptedWalletJSONFile!, password: encryptJSONPassword)
        //DLog("getWalletJsonString: %@", str)
        return str
    }
}
