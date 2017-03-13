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
    
    class func getBIP44KeyChain(_ masterHex:NSString, accountIdx:UInt) -> BTCKeychain{
        let seed = BTCDataWithHexCString(masterHex.utf8String)
        let masterChain = BTCKeychain(seed:seed)
        let purposeKeychain = masterChain?.derivedKeychain(at: 44, hardened:true)
        let coinTypeKeychain = purposeKeychain?.derivedKeychain(at: 0, hardened:true)
        let accountKeychain = coinTypeKeychain?.derivedKeychain(at: UInt32(accountIdx), hardened:true)
        return accountKeychain!
    }
    
    class func generateMnemonicPassphrase() -> String? {
        if let mnemonic = BTCMnemonic(entropy: BTCRandomDataWithLength(16) as Data!, password: nil, wordListType: .english) {
            return (mnemonic.words as NSArray).componentsJoined(by: " ")
        } else {
            return nil
        }
    }
    
    class func phraseIsValid(_ phrase:String) -> (Bool){
        return BTCMnemonic(words: phrase.components(separatedBy: " "), password: nil, wordListType: .english) != nil
    }

    class func getMasterHex(_ mnemonic: String) -> String {
        assert(phraseIsValid(mnemonic), "mnemonic is invalid")
        let mnemonicData = mnemonic.data(using: String.Encoding.utf8)
        let salt = "mnemonic".data(using: String.Encoding.utf8)
        
        let rounds:UInt = 2048
        let derivedKeyLen:Int = 64
        
        let key = [CUnsignedChar](repeating: 0, count: derivedKeyLen)
        
        let unsafeMutablePointerOfPassData: UnsafePointer<Int8> = (mnemonicData! as NSData).bytes.bindMemory(to: Int8.self, capacity: mnemonicData!.count)
        let unsafeMutablePointerOfSaltData: UnsafePointer<UInt8> = (salt! as NSData).bytes.bindMemory(to: UInt8.self, capacity: salt!.count)
        let unsafeMutablePointerOfKey: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer(mutating: key)
        CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),unsafeMutablePointerOfPassData,mnemonicData!.count,unsafeMutablePointerOfSaltData,salt!.count,CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512),CUnsignedInt(rounds),unsafeMutablePointerOfKey,derivedKeyLen)
        
        let len = MemoryLayout<CUnsignedChar>.size * Int(derivedKeyLen)
        
        let masterSeedData = Data(bytes: UnsafePointer<UInt8>(unsafeMutablePointerOfKey), count: len)
        return (masterSeedData as NSData).hex()
    }
    
    
    class func getStealthAddress(_ extendedKey:String, isTestnet:Bool) -> (NSDictionary) {
        
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
            scanKeyChain = scanKeyChain?.derivedKeychain(at: UInt32(idxHardened.object(forKey: "idx") as! Int),
                hardened:idxHardened.object(forKey: "hardened") as! Bool)
        }
        
        var spendKeyChain = BTCKeychain(extendedKey:extendedKey)
        let spendPrivSequence = [["idx":100, "hardened":true],
            ["idx":1, "hardened":false]]
        for idxHardened in spendPrivSequence as [NSDictionary] {
            spendKeyChain = spendKeyChain?.derivedKeychain(at: UInt32(idxHardened.object(forKey: "idx") as! Int),
                hardened:idxHardened.object(forKey: "hardened") as! Bool)
        }
        
        
        let scanKey = scanKeyChain?.key
        let scanPriv = (scanKey?.privateKey.hex())! as String
        let scanPublicKey = (scanKey?.compressedPublicKey.hex())! as String
        
        let spendKey = spendKeyChain?.key
        let spendPriv = (spendKey?.privateKey.hex())! as String
        let spendPublicKey = (spendKey?.compressedPublicKey.hex())! as String
        
        let stealthAddress = TLStealthAddress.createStealthAddress(scanPublicKey as NSString, spendPublicKey:spendPublicKey as NSString, isTestnet:isTestnet)
        return ["stealthAddress":stealthAddress, "scanPriv":scanPriv, "spendPriv":spendPriv]
    }
    
    class func getAccountIdxForExtendedKey(_ extendedKey:String) -> UInt32 {
        let keyChain = BTCKeychain(extendedKey:extendedKey)
        return keyChain!.index    }
    
    
    class func isValidExtendedPublicKey(_ extendedPublicKey:String) -> Bool {
        let keyChain = BTCKeychain(extendedKey:extendedPublicKey)
        return (keyChain != nil && !keyChain!.isPrivate)
    }
    
    class func isValidExtendedPrivateKey(_ extendedPrivateKey:String) -> Bool {
        let keyChain = BTCKeychain(extendedKey:extendedPrivateKey)
        return (keyChain != nil && keyChain!.isPrivate)
    }
    
    class func getExtendPubKey(_ extendPrivKey:String) -> String{
        let keyChain = BTCKeychain(extendedKey:extendPrivKey)
        return keyChain!.extendedPublicKey
    }
    
    class func getExtendPubKeyFromMasterHex(_ masterHex:String, accountIdx:UInt) -> String{
        let accountKeychain = getBIP44KeyChain(masterHex as NSString, accountIdx:accountIdx)
        return accountKeychain.extendedPublicKey
    }
    
    class func getExtendPrivKey(_ masterHex:String, accountIdx:UInt) -> String{
        let accountKeychain = getBIP44KeyChain(masterHex as NSString, accountIdx:accountIdx)
        
        return accountKeychain.extendedPrivateKey
    }
    
    class func getAddress(_ extendPubKey:String, sequence:NSArray, isTestnet:Bool) -> String{
        var keyChain = BTCKeychain(extendedKey:extendPubKey)
        
        for _idx in sequence {
            let idx = _idx as! Int
            keyChain = keyChain?.derivedKeychain(at: UInt32(idx), hardened:false)
        }
        
        if !isTestnet {
            return keyChain!.key.compressedPublicKeyAddress.string
        } else {
            return keyChain!.key.addressTestnet.string
        }
    }
    
    class func getPrivateKey(_ extendPrivKey:NSString, sequence:NSArray, isTestnet:Bool) -> String{
        var keyChain = BTCKeychain(extendedKey:extendPrivKey as String)
        
        for _idx in sequence {
            let idx = _idx as! Int
            keyChain = keyChain?.derivedKeychain(at: UInt32(idx), hardened:false)
        }
        
        keyChain?.key.isPublicKeyCompressed = true
        if !isTestnet {
            return keyChain!.key.wif
        } else {
            return keyChain!.key.wifTestnet
        }
    }
}
