//
//  TLCoreBitcoinWrapper.swift
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

@objc class TLCoreBitcoinWrapper {
    
    class func getAddressFromOutputScript(scriptHex:String) -> (String?){
        let scriptData = TLWalletUtils.hexStringToData(scriptHex)!
        let script = BTCScript(data:scriptData)
        if let address = script.standardAddress {
            return address.base58String
        }
        
        return nil
    }
   
    class func getStandardPubKeyHashScriptFromAddress(address:String) -> String {
        let scriptData = BTCScript(address: BTCAddress(base58String: address))
        return scriptData.hex
    }
    
    class func getAddress(privateKey:String) -> (String?){
        let key = BRKey(privateKey:privateKey)
        if (key == nil) {
            return nil
        } else {
            return key.address
        }
    }
    
    class func getAddressFromPublicKey(publicKey:String) -> (String?){
        if let address = BTCAddress(data: TLWalletUtils.hexStringToData(publicKey)!) {
            return address.base58String
        } else {
            return nil
        }
    }
    
    class func getAddressFromSecret(secret:String) -> (String?){
        if let key = BTCKey(privateKey: BTCDataFromHex(secret)) {
            return key.compressedPublicKeyAddress.base58String
        } else {
            return nil
        }
    }
    
    class func privateKeyFromEncryptedPrivateKey(encryptedPrivateKey:String, password:String) -> (String?) {
        if let key = BRKey(BIP38Key:encryptedPrivateKey, andPassphrase:password) {
            return key.privateKey
        }
        return nil
    }
    
    class func privateKeyFromSecret(secret:String) -> (String){
        let key = BTCKey(privateKey:BTCDataFromHex(secret))
        key.publicKeyCompressed = true
        return key.privateKeyAddress.base58String
    }
    
    class func isAddressVersion0(address:String) -> (Bool){
        return address.hasPrefix("1")
    }
    
    /*
    class func getBitcoinURL(address:String, amount:TLCoin, label:String) -> (String?){
        assert(amount.greater(TLCoin.zero()), "BTCBitcoinURL does not allow <= 0 value")
        let btcAddress = BTCPublicKeyAddress.addressWithBase58String(address) as BTCAddress
        // not useable because BTCBitcoinURL does not allow 0 amount
        //let bitcoinURL = BTCBitcoinURL.URLWithAddress(btcAddress, amount:1, label:label)
        let bitcoinURL = BTCBitcoinURL.URLWithAddress(btcAddress, amount:BTCSatoshi(amount.toUInt64()), label:label)
        return bitcoinURL.absoluteString?
    }
    */
    
    class func isValidAddress(address:String, isTestnet:Bool) -> (Bool){
        return address.isValidBitcoinAddress() || TLStealthAddress.isStealthAddress(address, isTestnet:isTestnet)
    }
    
    class func isValidPrivateKey(privateKey:String) -> Bool{
        return privateKey.isValidBitcoinPrivateKey()
    }
    
    class func isBIP38EncryptedKey(privateKey:String) -> Bool{
        return (privateKey as NSString).substringWithRange(NSMakeRange(0, 2)) == "6P"
    }
    
    class func createSignedSerializedTransactionHex(hashes:NSArray, inputIndexes indexes:NSArray, inputScripts scripts:NSArray,
        outputAddresses:NSArray, outputAmounts amounts:NSArray, privateKeys:NSArray,
        outputScripts:NSArray?) -> NSDictionary? {
            
            let tx = BRTransaction(inputHashes:hashes as [AnyObject], inputIndexes:indexes as [AnyObject],inputScripts:scripts as [AnyObject],
                outputAddresses:outputAddresses as [AnyObject], outputAmounts:amounts as [AnyObject])
            
            if (outputScripts != nil) {
                for (var i = 0; i < outputScripts!.count; i++) {
                    let outputScript = outputScripts!.objectAtIndex(i) as! String
                    tx.insertOutputScript(TLWalletUtils.hexStringToData(outputScript), amount:UInt64(0))
                }
            }
            
            tx.signWithPrivateKeys(privateKeys as [AnyObject])
            assert(tx.isSigned, "tx is not signed")
            let txFromHexData = BRTransaction(message: tx.data)

            var expectedOutputCount = outputAddresses.count
            if outputScripts != nil {
                expectedOutputCount += outputScripts!.count
            }
            if txFromHexData.outputScripts.count != expectedOutputCount {
                return nil
            }

            return [
                "txHex": TLWalletUtils.dataToHexString(tx.data),
                "txHash": TLWalletUtils.reverseTxidHexString(TLWalletUtils.dataToHexString(tx.txHash))
            ]
    }
}
