//
//  TLCrypto.swift
//  ArcBit
//
//  Created by Tim Lee on 8/10/15.
//  Copyright (c) 2015 ArcBit. All rights reserved.
//

import Foundation

let kRNCryptorAES256Settings:RNCryptorSettings  = RNCryptorSettings(algorithm: CCAlgorithm(kCCAlgorithmAES128), blockSize: kCCBlockSizeAES128, IVSize: kCCBlockSizeAES128,
    options: CCOptions(kCCOptionPKCS7Padding), HMACAlgorithm: CCHmacAlgorithm(kCCHmacAlgSHA256), HMACLength: Int(CC_SHA256_DIGEST_LENGTH),
    keySettings: RNCryptorKeyDerivationSettings(keySize: kCCKeySizeAES256, saltSize: 8, PBKDFAlgorithm: CCPBKDFAlgorithm(kCCPBKDF2), PRF: CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1), rounds: 10000, hasV2Password: false),
    HMACKeySettings: RNCryptorKeyDerivationSettings(keySize: kCCKeySizeAES256, saltSize: 8, PBKDFAlgorithm: CCPBKDFAlgorithm(kCCPBKDF2), PRF: CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1), rounds: 10000, hasV2Password: false))


class TLCrypto {

    class func getDefaultPBKDF2Iterations() -> UInt32 {
        return 10000
    }
    
    class func encrypt(plainText: String, password: String) -> (String) {
        return TLCrypto.encrypt(plainText, password: password, PBKDF2Iterations: getDefaultPBKDF2Iterations())
    }
    
    class func decrypt(cipherText: String, password: String) -> (String?) {
        return TLCrypto.decrypt(cipherText, password: password, PBKDF2Iterations: getDefaultPBKDF2Iterations())
    }
    
    class func encrypt(plainText: String, password: String, PBKDF2Iterations: UInt32) -> String {
        var settings = kRNCryptorAES256Settings
        settings.keySettings.rounds = PBKDF2Iterations
        //DLog("saveWalletJson encrypt: %@", plainText)
        
        let data = plainText.dataUsingEncoding(NSUTF8StringEncoding)
        var error: NSError? = nil
        var encryptedData = RNEncryptor.encryptData(data, withSettings: settings, password: password, error: &error)
        
        if (error != nil) {
            DLog("TLCrypto encrypt error: %@", error!.localizedDescription)
            NSException(name: "Error", reason: "Error encrypting", userInfo: nil).raise()
        }
        
        let base64EncryptedString = encryptedData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        //DLog("TLCrypto encrypt base64EncryptedData: %@", base64EncryptedString)
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
        //DLog("TLCrypto decrypt decryptedString: %@", decryptedString!)
        return decryptedString as? String
    }

    
}