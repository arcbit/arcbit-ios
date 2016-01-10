//
//  TLStealthAddress.swift
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

class TLStealthAddress {
    
    struct STATIC_MEMBERS {
        static let STEALTH_ADDRESS_MSG_SIZE: UInt8 = 0x26
        static let STEALTH_ADDRESS_TRANSACTION_VERSION: UInt8 = 0x06
        static let BTC_MAGIC_BYTE: UInt8 = 0x2a
        static let BTC_TESTNET_MAGIC_BYTE: UInt8 = 0x2b
    }
    
    class func getStealthAddressTransacionVersion() -> UInt8 {
        return STATIC_MEMBERS.STEALTH_ADDRESS_TRANSACTION_VERSION
    }
    
    class func getMagicByte(isTestnet: Bool) -> UInt8 {
        if (isTestnet) {
            return STATIC_MEMBERS.BTC_TESTNET_MAGIC_BYTE
        } else {
            return STATIC_MEMBERS.BTC_MAGIC_BYTE
        }
    }
    
    class func getStealthAddressMsgSize() -> UInt8 {
        return STATIC_MEMBERS.STEALTH_ADDRESS_MSG_SIZE
    }
    
    class func isStealthAddress(stealthAddress: String, isTestnet: Bool) -> Bool {
        let data = BTCDataFromBase58Check(stealthAddress)
        if(data == nil) {
            return false
        }
        let stealthAddressHex = data.hex()
        
        if (stealthAddressHex != nil && stealthAddressHex.characters.count != 142) {
            return false
        }
        
        var bytes = [UInt8](count: data.length, repeatedValue: 0)
        data.getBytes(&bytes, length: data.length)
        
        if (bytes[0] != getMagicByte(isTestnet)) {
            return false
        }
        
        let scanPublicKey = (stealthAddressHex as NSString).substringWithRange(NSMakeRange(4, 66))
        let spendPublicKey = (stealthAddressHex as NSString).substringWithRange(NSMakeRange(72, 66))
        
        let stealthAddr = createStealthAddress(scanPublicKey, spendPublicKey: spendPublicKey, isTestnet: isTestnet)
        return stealthAddress == stealthAddr
    }
    
    class func createStealthAddress(scanPublicKey: NSString, spendPublicKey: NSString, isTestnet: (Bool)) -> (String) {
        let hexString = NSString(format: "%02x00%@01%@0100", getMagicByte(isTestnet), scanPublicKey, spendPublicKey)
        return BTCBase58CheckStringWithData(BTCDataFromHex(hexString as String))
    }
    
    class func generateEphemeralPrivkey() -> (String) {
        let key = BTCKey()
        let newKey: BTCKey = BTCKey(privateKey: key.privateKey)
        assert(newKey.privateKey.hex() == key.privateKey.hex(), "")
        return key.privateKey.hex()
    }
    
    class func generateNonce() -> UInt32 {
        return arc4random()
    }
    
    class func createDataScriptAndPaymentAddress(stealthAddress: String, isTestnet: Bool) -> (String, String) {
        let ephemeralPrivateKey = generateEphemeralPrivkey()
        let nonce = generateNonce()
        return createDataScriptAndPaymentAddress(stealthAddress, ephemeralPrivateKey: ephemeralPrivateKey, nonce: nonce, isTestnet: isTestnet)
    }
    
    class func createDataScriptAndPaymentAddress(stealthAddress: String, ephemeralPrivateKey: String, nonce: UInt32, isTestnet: Bool) -> (String, String) {
        let publicKeys = getScanPublicKeyAndSpendPublicKey(stealthAddress, isTestnet: isTestnet)
        let scanPublicKey = publicKeys.0
        let spendPublicKey = publicKeys.1
        
        assert(createStealthAddress(scanPublicKey, spendPublicKey: spendPublicKey, isTestnet: isTestnet) == stealthAddress, "Invalid stealth address")
        
        let key = BTCKey(privateKey: BTCDataFromHex(ephemeralPrivateKey))
        
        let ephemeralPublicKey = key.compressedPublicKey.hex()
        
        let stealthDataScript = NSString(format: "%02x%02x%02x%08x%@",
            BTCOpcode.OP_RETURN.rawValue,
            getStealthAddressMsgSize(),
            getStealthAddressTransacionVersion(),
            nonce,
            ephemeralPublicKey)
        
        let paymentPublicKey = getPaymentPublicKeySender(scanPublicKey, spendPublicKey: spendPublicKey, ephemeralPrivateKey: ephemeralPrivateKey)
        let paymentAddress: String
        if (!isTestnet) {
            let key = BTCKey(publicKey: BTCDataFromHex(paymentPublicKey!))
            paymentAddress = key.address.base58String
        } else {
            //TODO:
            let key = BTCKey(publicKey: BTCDataFromHex(paymentPublicKey!))
            paymentAddress = key.address.base58String
        }
        return (stealthDataScript as String, paymentAddress)
    }
    
    class func getEphemeralPublicKeyFromStealthDataScript(scriptHex: String) -> (String?) {
        if (scriptHex.characters.count != 80) {
            return nil
        }
        return (scriptHex as NSString).substringWithRange(NSMakeRange(14, scriptHex.characters.count - 14))
    }
    
    class func getPaymentAddressPrivateKeySecretFromScript(stealthDataScript: String, scanPrivateKey: String, spendPrivateKey: String) -> (String?) {
        let ephemeralPublicKey = getEphemeralPublicKeyFromStealthDataScript(stealthDataScript)
        if (ephemeralPublicKey == nil) {
            return nil
        }

        return getPaymentPrivateKey(scanPrivateKey, spendPrivateKey: spendPrivateKey, ephemeralPublicKey: ephemeralPublicKey!)
    }
    
    class func getPaymentAddressPublicKeyFromScript(stealthDataScript: String, scanPrivateKey: String, spendPublicKey: String) -> (String?) {
        let ephemeralPublicKey = getEphemeralPublicKeyFromStealthDataScript(stealthDataScript)
        if (ephemeralPublicKey == nil) {
            return nil
        }
        return getPaymentPublicKeyForReceiver(scanPrivateKey, spendPublicKey: spendPublicKey, ephemeralPublicKey: ephemeralPublicKey!)
    }
    
    class func getScanPublicKeyAndSpendPublicKey(stealthAddress: (String), isTestnet: (Bool)) -> (String, String) {
        let data = BTCDataFromBase58Check(stealthAddress)
        let stealthAddressHex = data.hex()
        
        assert(stealthAddressHex.characters.count == 142, "stealthAddressHex.length != 142")
        var bytes = [UInt8](count: data.length, repeatedValue: 0)
        data.getBytes(&bytes, length: data.length)
        assert(bytes[0] == getMagicByte(isTestnet), "stealth address contains invalid magic byte")
        
        let scanPublicKey = (stealthAddressHex as NSString).substringWithRange(NSMakeRange(4, 66))
        let spendPublicKey = (stealthAddressHex as NSString).substringWithRange(NSMakeRange(72, 66))
        
        return (scanPublicKey, spendPublicKey)
    }
    
    class func getSharedSecretForSender(scanPublicKey: String, ephemeralPrivateKey: String) -> (String?) {
        let scanPublicKeyPoint = BTCCurvePoint(data: BTCDataFromHex(scanPublicKey))
        let ephemeralPrivateKeySecret = BTCBigNumber(string: ephemeralPrivateKey, base: 16)
        let key = BTCKey(curvePoint: scanPublicKeyPoint.multiply(ephemeralPrivateKeySecret))
        return key.compressedPublicKey.SHA256().hex()
    }
    
    class func getSharedSecretForReceiver(ephemeralPublicKey: String, scanPrivateKey: String) -> (String?) {
        let ephemeralPublicKeyPoint = BTCCurvePoint(data: BTCDataFromHex(ephemeralPublicKey))
        let scanPrivateKeySecret = BTCBigNumber(string: scanPrivateKey, base: 16)
        let key = BTCKey(curvePoint: ephemeralPublicKeyPoint.multiply(scanPrivateKeySecret))
        return key.compressedPublicKey.SHA256().hex()
    }
    
    class func getPaymentPublicKeyForReceiver(scanPrivateKey: String, spendPublicKey: String, ephemeralPublicKey: String) -> (String?) {
        let sharedSecret = getSharedSecretForReceiver(ephemeralPublicKey, scanPrivateKey: scanPrivateKey)
        if (sharedSecret == nil) {
            return nil
        } else {
            let key = BTCKey(privateKey: BTCDataFromHex(sharedSecret))
            return addPublicKeys(spendPublicKey, rhsPublicKey: key.compressedPublicKey.hex())
        }
    }
    
    class func getPaymentPublicKeySender(scanPublicKey: String, spendPublicKey: String, ephemeralPrivateKey: String) -> (String?) {
        let sharedSecret = getSharedSecretForSender(scanPublicKey, ephemeralPrivateKey: ephemeralPrivateKey)
        if (sharedSecret == nil) {
            return nil
        } else {
            let key = BTCKey(privateKey: BTCDataFromHex(sharedSecret))
            return addPublicKeys(spendPublicKey, rhsPublicKey: key.compressedPublicKey.hex())
        }
    }
    
    class func getPaymentPrivateKey(scanPrivateKey:String, spendPrivateKey:String, ephemeralPublicKey:String) -> (String?) {
        let sharedSecret = getSharedSecretForReceiver(ephemeralPublicKey, scanPrivateKey:scanPrivateKey)
        if (sharedSecret == nil) {
            return nil	
        } else {
            return addPrivateKeys(spendPrivateKey, rhsPrivateKey:sharedSecret!)
        }
    }
    
    class func addPublicKeys(lhsPublicKey:String, rhsPublicKey:String) -> (String) {
        let lhsPoint = BTCCurvePoint(data: BTCDataFromHex(lhsPublicKey))
        let rhsPoint = BTCCurvePoint(data: BTCDataFromHex(rhsPublicKey))
        return lhsPoint.add(rhsPoint).data.hex()
    }
    
    class func addPrivateKeys(lhsPrivateKey:String, rhsPrivateKey:String) -> (String) {
        let lhsBigNumber = BTCBigNumber(unsignedBigEndian: BTCDataFromHex(lhsPrivateKey))
        let rhsBigNumber = BTCBigNumber(unsignedBigEndian: BTCDataFromHex(rhsPrivateKey))
        var hexString = lhsBigNumber.mutableCopy().add(rhsBigNumber, mod:BTCCurvePoint.curveOrder()).hexString as String
        while hexString.characters.count < 64 {
            hexString = "0" + hexString
        }
        return hexString
    }
}
