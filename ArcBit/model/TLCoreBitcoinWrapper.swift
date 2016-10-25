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

class TLCoreBitcoinWrapper {
    
    // WARNING: returns compressed address only
    class func getAddressFromOutputScript(scriptHex:String, isTestnet:Bool) -> (String?){
        let scriptData = TLWalletUtils.hexStringToData(scriptHex)!
        let script = BTCScript(data:scriptData)
        if let address = script.standardAddress {
            if !isTestnet {
                return address.string
            } else {
                return BTCPublicKeyAddressTestnet(data: script.standardAddress.data)!.string
            }
        }
        
        return nil
    }
   
    class func getStandardPubKeyHashScriptFromAddress(address:String, isTestnet:Bool) -> String {
        let scriptData = BTCScript(address: BTCAddress(base58String: address))
        return scriptData.hex
    }
    
    class func getAddress(privateKey:String, isTestnet:Bool) -> (String?){
        if let key = BTCKey(WIF: privateKey) {
            if !isTestnet {
                return key.address.string
            } else {
                return key.addressTestnet.string
            }
        } else {
            return nil
        }
    }
    
    class func getAddressFromPublicKey(publicKey:String, isTestnet:Bool) -> (String?){
        if !isTestnet {
            if let key = BTCKey(publicKey: TLWalletUtils.hexStringToData(publicKey)!) {
                return key.address.string
            } else {
                return nil
            }
        } else {
            if let key = BTCKey(publicKey:  TLWalletUtils.hexStringToData(publicKey)!) {
                return key.addressTestnet.string
            } else {
                return nil
            }
        }
    }
    
    // WARNING: returns compressed address only
    class func getAddressFromSecret(secret:String, isTestnet:Bool) -> (String?){
        if let key = BTCKey(privateKey: BTCDataFromHex(secret)) {
            if !isTestnet {
                return key.compressedPublicKeyAddress.string
            } else {
                key.publicKeyCompressed = true
                return key.addressTestnet.string
            }
        } else {
            return nil
        }
    }
    
    class func privateKeyFromEncryptedPrivateKey(encryptedPrivateKey:String, password:String, isTestnet:Bool) -> (String?) {
        if let key = BRKey(BIP38Key:encryptedPrivateKey, andPassphrase:password, isTestnet:isTestnet) {
            return key.privateKey
        }
        return nil
    }
    
    // WARNING: returns compressed address only
    class func privateKeyFromSecret(secret:String, isTestnet:Bool) -> (String){
        let key = BTCKey(privateKey:BTCDataFromHex(secret))
        key.publicKeyCompressed = true
        if !isTestnet {
            return key.privateKeyAddress.string
        } else {
            return key.privateKeyAddressTestnet.string
        }
    }
    
    class func isAddressVersion0(address:String, isTestnet:Bool) -> (Bool){
        if !isTestnet {
            return address.hasPrefix("1")
        } else {
            return address.hasPrefix("m") || address.hasPrefix("n")
        }
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
        return address.isValidBitcoinAddress(isTestnet) || TLStealthAddress.isStealthAddress(address, isTestnet:isTestnet)
    }
    
    class func isValidPrivateKey(privateKey:String, isTestnet:Bool) -> Bool{
        return privateKey.isValidBitcoinPrivateKey(isTestnet)
    }
    
    class func isBIP38EncryptedKey(privateKey:String, isTestnet:Bool) -> Bool{
        return (privateKey as NSString).substringWithRange(NSMakeRange(0, 2)) == "6P"
    }
    
    class func getSignature(privateKey:String, message:String) -> String {
        let key = BTCKey(privateKey: BTCDataFromHex(privateKey))
        let signature = key.signatureForMessage(message)
        assert(key.isValidSignature(signature, forMessage: message), "")
        return signature.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength);
    }
    
    class func createSignedSerializedTransactionHex(hashes:NSArray, inputIndexes indexes:NSArray, inputScripts scripts:NSArray,
                                                    outputAddresses:NSArray, outputAmounts amounts:NSArray, privateKeys:NSArray,
                                                    outputScripts:NSArray?, isTestnet:Bool) -> NSDictionary? {
        return createSignedSerializedTransactionHex(hashes, inputIndexes: indexes, inputScripts: scripts, outputAddresses: outputAddresses, outputAmounts: amounts, privateKeys: privateKeys, outputScripts: outputScripts, signTx: true, isTestnet: isTestnet)
    }
    
    class func createSignedSerializedTransactionHex(hashes:NSArray, inputIndexes indexes:NSArray, inputScripts scripts:NSArray,
                                                    outputAddresses:NSArray, outputAmounts amounts:NSArray, privateKeys:NSArray,
                                                    outputScripts:NSArray?, signTx: Bool, isTestnet:Bool) -> NSDictionary? {
            
            let tx = BRTransaction(inputHashes:hashes as [AnyObject], inputIndexes:indexes as [AnyObject],inputScripts:scripts as [AnyObject],
                outputAddresses:outputAddresses as [AnyObject], outputAmounts:amounts as [AnyObject], isTestnet:isTestnet)
            
            if (outputScripts != nil) {
                for (var i = 0; i < outputScripts!.count; i++) {
                    let outputScript = outputScripts!.objectAtIndex(i) as! String
                    tx.insertOutputScript(TLWalletUtils.hexStringToData(outputScript), amount:UInt64(0), isTestnet:isTestnet)
                }
            }
        
            if signTx {
                tx.signWithPrivateKeys(privateKeys as [AnyObject], isTestnet:isTestnet)
            } else {
                return [
                    "txHex": TLWalletUtils.dataToHexString(tx.data),
                ]
            }
            assert(tx.isSigned, "tx is not signed")
            let txFromHexData = BRTransaction(message: tx.data, isTestnet: isTestnet)

            var expectedOutputCount = outputAddresses.count
            if outputScripts != nil {
                expectedOutputCount += outputScripts!.count
            }
            if txFromHexData.outputScripts.count != expectedOutputCount {
                return nil
            }

            return [
                "txHex": TLWalletUtils.dataToHexString(tx.data),
                "txHash": TLWalletUtils.reverseHexString(TLWalletUtils.dataToHexString(tx.txHash)),
                "txSize": tx.size
            ]
    }

    class func createSignedSerializedTransactionHex(unsignedTx:NSData, privateKeys:NSArray, isTestnet:Bool) -> NSDictionary? {
        let tx = BRTransaction(message: unsignedTx, isTestnet: isTestnet)
//        let tx = BRTransaction.transactionWithMessage(unsignedTx, isTestnet: isTestnet)
        tx.signWithPrivateKeys(privateKeys as [AnyObject], isTestnet:isTestnet)
        DLog("createSignedSerializedTransactionHex x.isSigned: \(tx.isSigned)")

        
        let txFromHexData = BRTransaction(message: tx.data, isTestnet: isTestnet)
        DLog("createSignedSerializedTransactionHex txFromHexData: %@", function: TLWalletUtils.dataToHexString(txFromHexData.data))
        DLog("createSignedSerializedTransactionHex txFromHexData: %@", function: TLWalletUtils.reverseHexString(TLWalletUtils.dataToHexString(txFromHexData.txHash)))
        DLog("createSignedSerializedTransactionHex txFromHexData: %@", function: txFromHexData.size)

        
//        assert(tx.isSigned, "tx is not signed")
        return [
            "txHex": TLWalletUtils.dataToHexString(tx.data),
            "txHash": TLWalletUtils.reverseHexString(TLWalletUtils.dataToHexString(tx.txHash)),
            "txSize": tx.size
        ]
    }

}
