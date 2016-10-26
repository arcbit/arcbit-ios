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
    
    class func encrypt(_ plainText: String, password: String) -> (String) {
        return TLCrypto.encrypt(plainText, password: password, PBKDF2Iterations: getDefaultPBKDF2Iterations())
    }
    
    class func decrypt(_ cipherText: String, password: String) -> (String?) {
        return TLCrypto.decrypt(cipherText, password: password, PBKDF2Iterations: getDefaultPBKDF2Iterations())
    }
    
    class func encrypt(_ plainText: String, password: String, PBKDF2Iterations: UInt32) -> String {
        var settings = kRNCryptorAES256Settings
        settings.keySettings.rounds = PBKDF2Iterations
        //DLog("saveWalletJson encrypt: %@", plainText)
        
        let data = plainText.data(using: String.Encoding.utf8)
        var error: NSError? = nil
        var encryptedData: Data!
        do {
            encryptedData = try RNEncryptor.encryptData(data, with: settings, password: password)
        } catch let error1 as NSError {
            error = error1
            encryptedData = nil
        }
        
        if (error != nil) {
            DLog("TLCrypto encrypt error: \(error!.localizedDescription)")
            NSException(name: NSExceptionName(rawValue: "Error"), reason: "Error encrypting", userInfo: nil).raise()
        }
        
        let base64EncryptedString = encryptedData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        //DLog("TLCrypto encrypt base64EncryptedData: %@", base64EncryptedString)
        return base64EncryptedString
    }
    
    class func decrypt(_ cipherText: String, password: String, PBKDF2Iterations: UInt32) -> String? {
        var settings = kRNCryptorAES256Settings
        settings.keySettings.rounds = PBKDF2Iterations
        
        let encryptedData = Data(base64Encoded: cipherText, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        var error: NSError? = nil
        let decryptedData: Data!
        do {
            decryptedData = try RNDecryptor.decryptData(encryptedData,
                        with: settings,
                        password: password)
        } catch let error1 as NSError {
            error = error1
            decryptedData = nil
        }
        
        // Note: there will only be error if password is incorrect, if PBKDF2Iterations dont match then there will be no error, just nil decryptedData
        if (error != nil) {
            return nil
        }
        
        let decryptedString = NSString(data: decryptedData!, encoding: String.Encoding.utf8.rawValue)
        //DLog("TLCrypto decrypt decryptedString: %@", decryptedString!)
        return decryptedString as? String
    }

    class func SHA256HashFor(_ input: NSString) -> String {
        let str = input.utf8String
        
        let result = [CUnsignedChar](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        let resultBytes: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer(mutating: result)
        
        CC_SHA256(str, CC_LONG(strlen(str)), resultBytes)
        
        let ret = NSMutableString(capacity:Int(CC_SHA256_DIGEST_LENGTH)*2)
        for i in stride(from: 0, through: Int(CC_SHA256_DIGEST_LENGTH), by: 1) {
            ret.appendFormat("%02x",result[i])
        }
        return ret as String
    }
    
    class func doubleSHA256HashFor(_ input: NSString) -> String {
        let str = input.utf8String
        let result = [CUnsignedChar](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        let resultBytes: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer(mutating: result)
        
        CC_SHA256(str, CC_LONG(strlen(str)), resultBytes)
        let result2 = [CUnsignedChar](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        let result2Bytes: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer(mutating: result2)
        
        CC_SHA256(result, CC_LONG(CC_SHA256_DIGEST_LENGTH), result2Bytes)
        
        let ret = NSMutableString(capacity:Int(CC_SHA256_DIGEST_LENGTH*2))
        for i in stride(from: 0, through: Int(CC_SHA256_DIGEST_LENGTH), by: 1) {
            ret.appendFormat("%02x",result2[i])
        }
        return ret as String
    }
}
