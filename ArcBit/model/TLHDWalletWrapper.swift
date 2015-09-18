//
//  TLHDWalletWrapper.swift
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

class TLHDWalletWrapper {
    
    class func getBIP44KeyChain(masterHex:NSString, accountIdx:UInt) -> BTCKeychain{
        let seed = BTCDataWithHexCString(masterHex.UTF8String)
        let masterChain = BTCKeychain(seed:seed)
        let purposeKeychain = masterChain.derivedKeychainAtIndex(44, hardened:true)
        let coinTypeKeychain = purposeKeychain.derivedKeychainAtIndex(0, hardened:true)
        let accountKeychain = coinTypeKeychain.derivedKeychainAtIndex(UInt32(accountIdx), hardened:true)
        return accountKeychain
    }
    
    class func generateMnemonicPassphrase() -> String? {
        if let mnemonic = BTCMnemonic(entropy: BTCRandomDataWithLength(16), password: nil, wordListType: .English) {
            return (mnemonic.words as NSArray).componentsJoinedByString(" ")
        } else {
            return nil
        }
    }
    
    class func phraseIsValid(phrase:String) -> (Bool){
        return BTCMnemonic(words: phrase.componentsSeparatedByString(" "), password: nil, wordListType: .English) != nil
    }
    
    class func getMasterHex(mnemonic: String) -> String {
        assert(phraseIsValid(mnemonic), "mnemonic is invalid")
        let mnemonicData = mnemonic.dataUsingEncoding(NSUTF8StringEncoding)
        let salt = "mnemonic".dataUsingEncoding(NSUTF8StringEncoding)
        
        let rounds:UInt = 2048
        let derivedKeyLen:Int = 64
        
        let key = [CUnsignedChar](count: derivedKeyLen, repeatedValue: 0)
        
        let unsafeMutablePointerOfPassData: UnsafePointer<Int8> = UnsafePointer(mnemonicData!.bytes)
        let unsafeMutablePointerOfSaltData: UnsafePointer<UInt8> = UnsafePointer(salt!.bytes)
        let unsafeMutablePointerOfKey: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer(key)
        CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),unsafeMutablePointerOfPassData,mnemonicData!.length,unsafeMutablePointerOfSaltData,salt!.length,CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512),CUnsignedInt(rounds),unsafeMutablePointerOfKey,derivedKeyLen)
        
        let len = sizeof(CUnsignedChar) * Int(derivedKeyLen)
        
        let masterSeedData = NSData(bytes:unsafeMutablePointerOfKey, length: len)
        return masterSeedData.hex()
    }
    
    
    class func getStealthAddress(extendedKey:String, isTestnet:Bool) -> (NSDictionary) {
        
        // hd wallet
        // m / purpose' / coin_type' / account' / change / address_index
        // stealth
        // m / purpose' / coin_type' / account' / 100' / scan|spend / 0
        // 100' because 0 and 1 are change, and is hardened because if it is not then if an attacker knows a xpub,
        // then he can can hack stealth server, take scan keys and compromise whole account
        
        var scanKeyChain = BTCKeychain(extendedKey:extendedKey)
        let scanPrivSequence = [["idx":100, "hardened":true],
            ["idx":0, "hardened":false]]
        for _idxHardened in scanPrivSequence {
            let idxHardened = _idxHardened as NSDictionary
            scanKeyChain = scanKeyChain.derivedKeychainAtIndex(UInt32(idxHardened.objectForKey("idx") as! Int),
                hardened:idxHardened.objectForKey("hardened") as! Bool)
        }
        
        var spendKeyChain = BTCKeychain(extendedKey:extendedKey)
        let spendPrivSequence = [["idx":100, "hardened":true],
            ["idx":1, "hardened":false]]
        for idxHardened in spendPrivSequence as [NSDictionary] {
            spendKeyChain = spendKeyChain.derivedKeychainAtIndex(UInt32(idxHardened.objectForKey("idx") as! Int),
                hardened:idxHardened.objectForKey("hardened") as! Bool)
        }
        
        
        let scanKey = scanKeyChain.key
        let scanPriv = scanKey.privateKey.hex() as String
        let scanPublicKey = scanKey.compressedPublicKey.hex() as String
        
        let spendKey = spendKeyChain.key
        let spendPriv = spendKey.privateKey.hex() as String
        let spendPublicKey = spendKey.compressedPublicKey.hex() as String
        
        let stealthAddress = TLStealthAddress.createStealthAddress(scanPublicKey, spendPublicKey:spendPublicKey, isTestnet:isTestnet)
        return ["stealthAddress":stealthAddress, "scanPriv":scanPriv, "spendPriv":spendPriv]
    }
    
    class func getAccountIdxForExtendedKey(extendedKey:String) -> UInt32 {
        let keyChain = BTCKeychain(extendedKey:extendedKey)
        return keyChain.index    }
    
    
    class func isValidExtendedPublicKey(extendedPublicKey:String) -> Bool {
        let keyChain = BTCKeychain(extendedKey:extendedPublicKey)
        return (keyChain != nil && !keyChain.isPrivate)
    }
    
    class func isValidExtendedPrivateKey(extendedPrivateKey:String) -> Bool {
        let keyChain = BTCKeychain(extendedKey:extendedPrivateKey)
        return (keyChain != nil && keyChain.isPrivate)
    }
    
    class func getExtendPubKey(extendPrivKey:String) -> String{
        let keyChain = BTCKeychain(extendedKey:extendPrivKey)
        return keyChain.extendedPublicKey
    }
    
    class func getExtendPubKeyFromMasterHex(masterHex:String, accountIdx:UInt) -> String{
        let accountKeychain = getBIP44KeyChain(masterHex, accountIdx:accountIdx)
        return accountKeychain.extendedPublicKey
    }
    
    class func getExtendPrivKey(masterHex:String, accountIdx:UInt) -> String{
        let accountKeychain = getBIP44KeyChain(masterHex, accountIdx:accountIdx)
        
        return accountKeychain.extendedPrivateKey
    }
    
    class func getAddress(extendPubKey:String, sequence:NSArray, isTestnet:Bool) -> String{
        var keyChain = BTCKeychain(extendedKey:extendPubKey)
        
        for _idx in sequence {
            let idx = _idx as! Int
            keyChain = keyChain.derivedKeychainAtIndex(UInt32(idx), hardened:false)
        }
        
        if !isTestnet {
            return keyChain.key.compressedPublicKeyAddress.string
        } else {
            return keyChain.key.addressTestnet.string
        }
    }
    
    class func getPrivateKey(extendPrivKey:NSString, sequence:NSArray, isTestnet:Bool) -> String{
        var keyChain = BTCKeychain(extendedKey:extendPrivKey as String)
        
        for _idx in sequence {
            let idx = _idx as! Int
            keyChain = keyChain.derivedKeychainAtIndex(UInt32(idx), hardened:false)
        }
        
        keyChain.key.publicKeyCompressed = true
        if !isTestnet {
            return keyChain.key.WIF
        } else {
            return keyChain.key.WIFTestnet
        }
    }
}