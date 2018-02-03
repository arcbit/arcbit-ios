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
import JavaScriptCore

class TLCoreBitcoinWrapper {
    enum TLBitcoinCashAddressFormat: String { // raw string values needs to match thingy in bitcoinCashWrapper.js
        case LegacyFormat = "LegacyFormat"
        case CashAddrFormat = "CashAddrFormat"
    }
    
    struct STATIC_MEMBERS {
        static let DEFAULT_BITCOIN_CASH_ADDRESS_FORMAT = TLBitcoinCashAddressFormat.CashAddrFormat
        static var context: JSContext? = {
            let context = JSContext()
            
            guard let
                bitcoinCashLibraryJSPath = Bundle.main.path(forResource: "bitcoincash-0.1.10", ofType: "js"),
                let bitcoinCashWrapperJSPath = Bundle.main.path(forResource: "bitcoinCashWrapper", ofType: "js") else {
                    print("Unable to read resource files.")
                    return nil
            }
            
            do {
                let bitcoinCashLibrary = try String(contentsOfFile: bitcoinCashLibraryJSPath, encoding: String.Encoding.utf8)
                let bitcoinCashWrapper = try String(contentsOfFile: bitcoinCashWrapperJSPath, encoding: String.Encoding.utf8)
                
                _ = context?.evaluateScript(bitcoinCashLibrary)
                _ = context?.evaluateScript(bitcoinCashWrapper)
            } catch (let error) {
                print("Error while processing script file: \(error)")
            }
            
            return context
        }()
    }
    
    // WARNING: returns compressed address only
    class func getAddressFromOutputScript(_ coinType:TLCoinType, scriptHex:String, isTestnet:Bool) -> (String?) {
        switch coinType {
        case .BCH:
            let scriptData = TLWalletUtils.hexStringToData(scriptHex)!
            let script = BTCScript(data:scriptData)
            if let address = script?.standardAddress {
                if !isTestnet {
                    return TLCoreBitcoinWrapper.getBitcoinCashAddressFormat(address.string, format: STATIC_MEMBERS.DEFAULT_BITCOIN_CASH_ADDRESS_FORMAT)
                } else {
                    return TLCoreBitcoinWrapper.getBitcoinCashAddressFormat(BTCPublicKeyAddressTestnet(data: script?.standardAddress.data)!.string, format: STATIC_MEMBERS.DEFAULT_BITCOIN_CASH_ADDRESS_FORMAT)
                }
            }
            
            return nil
        case .BTC:
            let scriptData = TLWalletUtils.hexStringToData(scriptHex)!
            let script = BTCScript(data:scriptData)
            if let address = script?.standardAddress {
                if !isTestnet {
                    return address.string
                } else {
                    return BTCPublicKeyAddressTestnet(data: script?.standardAddress.data)!.string
                }
            }
            
            return nil
        }
    }
   
    class func getStandardPubKeyHashScriptFromAddress(_ coinType:TLCoinType, address:String, isTestnet:Bool) -> String {
        switch coinType {
        case .BCH:
            let legacyAddress = TLCoreBitcoinWrapper.getBitcoinCashAddressFormat(address, format: TLBitcoinCashAddressFormat.LegacyFormat)
            let scriptData = BTCScript(address: BTCAddress(base58String: legacyAddress))
            return scriptData!.hex
        case .BTC:
            let scriptData = BTCScript(address: BTCAddress(base58String: address))
            return scriptData!.hex
        }
    }
    
    class func getAddress(_ coinType:TLCoinType, privateKey:String, isTestnet:Bool) -> (String?){
        switch coinType {
        case .BCH:
            if let key = BTCKey(wif: privateKey) {
                if !isTestnet {
                    return TLCoreBitcoinWrapper.getBitcoinCashAddressFormat(key.address.string, format: STATIC_MEMBERS.DEFAULT_BITCOIN_CASH_ADDRESS_FORMAT)
                } else {
                    // TODO never tested isTestnet
                    return TLCoreBitcoinWrapper.getBitcoinCashAddressFormat(key.addressTestnet.string, format: STATIC_MEMBERS.DEFAULT_BITCOIN_CASH_ADDRESS_FORMAT)
                }
            } else {
                return nil
            }
        case .BTC:
            if let key = BTCKey(wif: privateKey) {
                if !isTestnet {
                    return key.address.string
                } else {
                    return key.addressTestnet.string
                }
            } else {
                return nil
            }
        }
    }
    
    class func getAddressFromPublicKey(_ coinType:TLCoinType, publicKey:String, isTestnet:Bool) -> (String?){
        switch coinType {
        case .BCH:
            if !isTestnet {
                if let key = BTCKey(publicKey: TLWalletUtils.hexStringToData(publicKey)!) {
                    return TLCoreBitcoinWrapper.getBitcoinCashAddressFormat(key.address.string, format: STATIC_MEMBERS.DEFAULT_BITCOIN_CASH_ADDRESS_FORMAT)
                } else {
                    return nil
                }
            } else {
                if let key = BTCKey(publicKey:  TLWalletUtils.hexStringToData(publicKey)!) {
                    // TODO never tested isTestnet
                    return TLCoreBitcoinWrapper.getBitcoinCashAddressFormat(key.addressTestnet.string, format: STATIC_MEMBERS.DEFAULT_BITCOIN_CASH_ADDRESS_FORMAT)
                } else {
                    return nil
                }
            }
        case .BTC:
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
    }
    
    // WARNING: returns compressed address only
    class func getAddressFromSecret(_ coinType:TLCoinType, secret:String, isTestnet:Bool) -> (String?){
        switch coinType {
        case .BCH:
            if let key = BTCKey(privateKey: BTCDataFromHex(secret)) {
                if !isTestnet {
                    return TLCoreBitcoinWrapper.getBitcoinCashAddressFormat(key.compressedPublicKeyAddress.string, format: STATIC_MEMBERS.DEFAULT_BITCOIN_CASH_ADDRESS_FORMAT)
                } else {
                    key.isPublicKeyCompressed = true
                    // TODO never tested isTestnet
                    return TLCoreBitcoinWrapper.getBitcoinCashAddressFormat(key.addressTestnet.string, format: STATIC_MEMBERS.DEFAULT_BITCOIN_CASH_ADDRESS_FORMAT)
                }
            } else {
                return nil
            }
        case .BTC:
            if let key = BTCKey(privateKey: BTCDataFromHex(secret)) {
                if !isTestnet {
                    return key.compressedPublicKeyAddress.string
                } else {
                    key.isPublicKeyCompressed = true
                    return key.addressTestnet.string
                }
            } else {
                return nil
            }
        }
    }
    
    class func privateKeyFromEncryptedPrivateKey(_ coinType:TLCoinType, encryptedPrivateKey:String, password:String, isTestnet:Bool) -> (String?) {
        if let key = BRKey(bip38Key:encryptedPrivateKey, andPassphrase:password, isTestnet:isTestnet) {
            return key.privateKey
        }
        return nil
    }
    
    // WARNING: returns compressed address only
    class func privateKeyFromSecret(_ coinType:TLCoinType, secret:String, isTestnet:Bool) -> (String){
        let key = BTCKey(privateKey:BTCDataFromHex(secret))
        key?.isPublicKeyCompressed = true
        if !isTestnet {
            return key!.privateKeyAddress.string
        } else {
            return key!.privateKeyAddressTestnet.string
        }
    }
    
    class func isAddressVersion0(_ coinType:TLCoinType, address:String, isTestnet:Bool) -> (Bool){
        switch coinType {
        case .BCH:
            // TODO
            return true
        case .BTC:
            if !isTestnet {
                return address.hasPrefix("1")
            } else {
                return address.hasPrefix("m") || address.hasPrefix("n")
            }
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
    
    class func isValidAddress(_ coinType:TLCoinType, address:String, isTestnet:Bool) -> (Bool){
        switch coinType {
        case .BCH:
            if let legacyAddress = TLCoreBitcoinWrapper.getBitcoinCashAddressFormat(address, format: TLBitcoinCashAddressFormat.LegacyFormat) {
                return legacyAddress.isValidBitcoinAddress(isTestnet)
            }
            return false
        case .BTC:
            return address.isValidBitcoinAddress(isTestnet) || TLStealthAddress.isStealthAddress(address, isTestnet:isTestnet)
        }
    }
    
    class func isValidPrivateKey(_ coinType:TLCoinType, privateKey:String, isTestnet:Bool) -> Bool{
        return privateKey.isValidBitcoinPrivateKey(isTestnet)
    }
    
    class func isBIP38EncryptedKey(_ coinType:TLCoinType, privateKey:String, isTestnet:Bool) -> Bool{
        return (privateKey as NSString).substring(with: NSMakeRange(0, 2)) == "6P"
    }
    
    class func getSignature(_ coinType:TLCoinType, privateKey:String, message:String) -> String {
        let key = BTCKey(privateKey: BTCDataFromHex(privateKey))
        let signature = key?.signature(forMessage: message)
        assert((key?.isValidSignature(signature, forMessage: message))!, "")
        return signature!.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters);
    }
    
    class func createSignedSerializedTransactionHex(_ coinType:TLCoinType, hashes:NSArray, inputIndexes:NSArray, inputScripts:NSArray,
                                                    outputAddresses:NSArray, outputAmounts:NSArray, privateKeys:NSArray,
                                                    outputScripts:NSArray?, isTestnet:Bool) -> NSDictionary? {
        return createSignedSerializedTransactionHex(coinType, hashes: hashes, inputIndexes: inputIndexes, inputScripts: inputScripts, outputAddresses: outputAddresses, outputAmounts: outputAmounts, privateKeys: privateKeys, outputScripts: outputScripts, signTx: true, isTestnet: isTestnet)
    }
    
    class func createSignedSerializedTransactionHex(_ coinType:TLCoinType, hashes:NSArray, inputIndexes:NSArray, inputScripts:NSArray,
                                                    outputAddresses:NSArray, outputAmounts:NSArray, privateKeys:NSArray,
                                                    outputScripts:NSArray?, signTx: Bool, isTestnet:Bool) -> NSDictionary? {
        switch coinType {
        case .BCH:
            return createBitcoinCashSerializedTransactionHex(hashes, inputIndexes: inputIndexes, inputScripts: inputScripts, outputAddresses: outputAddresses, outputAmounts: outputAmounts, privateKeys: privateKeys, outputScripts: outputScripts, signTx: signTx, isTestnet: isTestnet)
        case .BTC:
            let tx = BRTransaction(inputHashes:hashes as [AnyObject], inputIndexes:inputIndexes as [AnyObject],inputScripts:inputScripts as [AnyObject],
                                   outputAddresses:outputAddresses as [AnyObject], outputAmounts:outputAmounts as [AnyObject], isTestnet:isTestnet)
            
            if (outputScripts != nil) {
                for i in stride(from: 0, to: outputScripts!.count, by: 1) {
                    let outputScript = outputScripts!.object(at: i) as! String
                    tx?.insertOutputScript(TLWalletUtils.hexStringToData(outputScript), amount:UInt64(0), isTestnet:isTestnet)
                }
            }
            
            if !signTx {
                let inputHexScripts = NSMutableArray(capacity: tx!.inputScripts.count)
                for script in tx!.inputScripts {
                    inputHexScripts.add(TLWalletUtils.dataToHexString(script as! Data))
                }
                return [
                    "inputScripts": inputHexScripts,
                    "txHex": TLWalletUtils.dataToHexString(tx!.data),
                ]
            }
            
            tx?.sign(withPrivateKeys: privateKeys as [AnyObject], isTestnet:isTestnet)
            assert((tx?.isSigned)!, "tx is not signed")
            
            let txFromHexData = BRTransaction(message: tx?.data, isTestnet: isTestnet)
            
            var expectedOutputCount = outputAddresses.count
            if outputScripts != nil {
                expectedOutputCount += outputScripts!.count
            }
            if txFromHexData?.outputScripts.count != expectedOutputCount {
                return nil
            }
            
            return [
                "txHex": TLWalletUtils.dataToHexString(tx!.data),
                "txHash": TLWalletUtils.reverseHexString(TLWalletUtils.dataToHexString(tx!.txHash)),
                "txSize": tx!.size
            ]
        }
    }

    class func createSignedSerializedTransactionHex(_ coinType:TLCoinType, unsignedTx:Data, inputScripts:NSArray, privateKeys:NSArray, isTestnet:Bool) -> NSDictionary? {
        let tx = BRTransaction(message: unsignedTx, isTestnet: isTestnet)
        let inputHashes = tx!.inputHashes as NSArray
        let inputIndexes = tx!.inputIndexes as NSArray
        let outputAmounts = tx!.outputAmounts as NSArray
        let outputAddresses = tx!.outputAddresses as NSArray
        let txHexAndTxHash = TLCoreBitcoinWrapper.createSignedSerializedTransactionHex(coinType, hashes:inputHashes, inputIndexes:inputIndexes, inputScripts:inputScripts,
                                                                                       outputAddresses:outputAddresses, outputAmounts:outputAmounts, privateKeys:privateKeys,
                                                                                       outputScripts:nil, signTx: true, isTestnet: isTestnet)
        return txHexAndTxHash
    }

    class func createBitcoinCashSerializedTransactionHex(_ hashes:NSArray, inputIndexes:NSArray, inputScripts:NSArray,
                                                                 outputAddresses:NSArray, outputAmounts:NSArray, privateKeys:NSArray,
                                                                 outputScripts:NSArray?, signTx: Bool, isTestnet:Bool) -> NSDictionary? {

        if outputScripts != nil {
            // TODO have not handled outputScripts yet, remove stealth txs feature so ok for now
            return nil
        }
        guard let context = STATIC_MEMBERS.context else {
            DLog("JSContext not found.")
            return nil
        }
        let hexStringHashes = NSMutableArray()
        for hash in hashes {
            hexStringHashes.add(TLWalletUtils.dataToHexString(hash as! Data))
        }
        let hexStringInputScripts = NSMutableArray()
        for inputScript in inputScripts {
            hexStringInputScripts.add(TLWalletUtils.dataToHexString(inputScript as! Data))
        }
//        NSLog("createBitcoinCashSerializedTransactionHex hashes: \(hashes.debugDescription)")
        NSLog("createBitcoinCashSerializedTransactionHex hashes: \(hexStringHashes.debugDescription)")
        NSLog("createBitcoinCashSerializedTransactionHex inputIndexes: \(inputIndexes.debugDescription)")
        NSLog("createBitcoinCashSerializedTransactionHex inputScripts: \(hexStringInputScripts.debugDescription)")
//        NSLog("createBitcoinCashSerializedTransactionHex inputScripts: \(inputScripts.debugDescription)")
        NSLog("createBitcoinCashSerializedTransactionHex outputAddresses: \(outputAddresses.debugDescription)")
        NSLog("createBitcoinCashSerializedTransactionHex outputAmounts: \(outputAmounts.debugDescription)")
        NSLog("createBitcoinCashSerializedTransactionHex privateKeys: \(privateKeys.debugDescription)")
        NSLog("createBitcoinCashSerializedTransactionHex signTx: \(signTx)")

        let createBitcoinCashSerializedTransactionHexFunction = context.objectForKeyedSubscript("createSerializedTransactionHex")
//        guard let result = createBitcoinCashSerializedTransactionHexFunction?.call(withArguments: [hashes, inputIndexes, inputScripts, outputAddresses, outputAmounts, privateKeys, signTx, isTestnet]).toDictionary() else {
        guard let result = createBitcoinCashSerializedTransactionHexFunction?.call(withArguments: [hexStringHashes, inputIndexes, hexStringInputScripts, outputAddresses, outputAmounts, privateKeys, signTx, isTestnet]).toDictionary() else {
            NSLog("createBitcoinCashSerializedTransactionHexFunction no result")
            return nil
        }
        DLog("createBitcoinCashSerializedTransactionHexFunction result \(result)")
        
        let txHex = result["txHex"] as! String
        let txHash = result["txHash"] as! String
        let txSize = result["txSize"] as! UInt64
        NSLog("createBitcoinCashSerializedTransactionHexFunction txHex \(txHex)")
        NSLog("createBitcoinCashSerializedTransactionHexFunction txHash \(txHash)")
        NSLog("createBitcoinCashSerializedTransactionHexFunction txSize \(txSize)")
        return [
            "txHex": txHex,
            "txHash": txHash,
            "txSize": txSize
        ]
    }
    
    class func getBitcoinCashAddressFormat(_ address:String, format: TLBitcoinCashAddressFormat) -> String? {
        guard let context = STATIC_MEMBERS.context else {
            DLog("JSContext not found.")
            return nil
        }
        let getBitcoinCashAddressFormatFunction = context.objectForKeyedSubscript("getBitcoinCashAddressFormat")
        guard let result = getBitcoinCashAddressFormatFunction?.call(withArguments: [address, format.rawValue]).toString() else {
            DLog("getBitcoinCashAddressFormat no result")
            return nil
        }
        DLog("getBitcoinCashAddressFormat result \(result)")
        return result
    }
}
