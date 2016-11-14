//
//  TLColdWallet.swift
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

class TLColdWallet {
    
    enum TLColdWalletError: Error {
        case InvalidScannedData(String)
        case InvalidKey(String)
        case MisMatchExtendedPublicKey(String)
    }
    
    static let SPLIT_SUB_STRING_LENGTH = 100
    static let AIR_GAP_DATA_VERSION = "1"
    static let AIR_GAP_DATA_TRANSPORT_VERSION = "1"

    struct STATIC_MEMBERS {
        static var instance:TLSpaghettiGodSend?
    }

    class func createUnsignedTxAipGapData(_ unSignedTx: String, extendedPublicKey: String, inputScripts:NSArray, txInputsAccountHDIdxes:NSArray) -> String? {
        let data = TLWalletUtils.hexStringToData(unSignedTx)
        if let base64Encoded = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) {
            
            let dataDictionaryToAirGapPass = [
                "v": AIR_GAP_DATA_VERSION,
                "account_public_key": extendedPublicKey,
                "unsigned_tx_base64": base64Encoded,
                "input_scripts": inputScripts, //inputScripts in hex
                "tx_inputs_account_hd_idxes": txInputsAccountHDIdxes //[["idx":123, "is_change":false], ["idx":124, "is_change":true]]
            ] as [String : Any]
            
            return TLUtils.dictionaryToJSONString(false, dict: dataDictionaryToAirGapPass as NSDictionary)
        }
        return nil
    }

    class func createSerializedUnsignedTxAipGapData(_ unSignedTx: String, extendedPublicKey: String, inputScripts:NSArray, txInputsAccountHDIdxes:NSArray) -> String? {
        let aipGapDataJSONString = TLColdWallet.createUnsignedTxAipGapData(unSignedTx, extendedPublicKey: extendedPublicKey, inputScripts: inputScripts, txInputsAccountHDIdxes: txInputsAccountHDIdxes)
        let data = aipGapDataJSONString?.data(using: String.Encoding.utf8)
        return data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }

    class func splitStringToArray(_ str: String) -> Array<String> {
        var partsArray = [String]()
        var idx = 0
        let SPLIT_SUB_STRING_LENGTH = 100
        let nsString = str as NSString
        var partCount = 0
        while true {
            let subString:String
            
            
            partCount += 1
            if idx+SPLIT_SUB_STRING_LENGTH >= str.characters.count {
                subString = nsString.substring(with: NSRange(location: idx, length: nsString.length-idx))
                partsArray.append(subString+":"+String(partCount))

                break
            } else {
                subString = nsString.substring(with: NSRange(location: idx, length: SPLIT_SUB_STRING_LENGTH))
                partsArray.append(subString+":"+String(partCount))
            }

            idx += SPLIT_SUB_STRING_LENGTH
        }
        for i in stride(from: 0, to: partsArray.count, by: 1) {
            partsArray[i] = partsArray[i]+"."+String(partCount)
        }
        return partsArray
    }
    
    class func parseScannedPart(_ str: String) -> (String, Int, Int) {
        let parts = str.components(separatedBy: ":")
        let data = parts[0]
        let partCountAndTotal = parts[1]
        let partCountAndTotalArray = partCountAndTotal.components(separatedBy: ".")
        let partCount = partCountAndTotalArray[0]
        let totalParts = partCountAndTotalArray[1]
        return (data, Int(partCount)!, Int(totalParts)!)
    }

    class func convertDataToDictionary(_ data: Data) -> [String:AnyObject]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    class func createSerializedSignedTxAipGapData(_ aipGapDataBase64: String, mnemonicOrExtendedPrivateKey: String, isTestnet:Bool) throws -> String? {
        if let signedTxHexAndTxHash = try createSignedTxAipGapData(aipGapDataBase64, mnemonicOrExtendedPrivateKey: mnemonicOrExtendedPrivateKey, isTestnet: isTestnet) {
            DLog("createSerializedSignedTxAipGapData signedTxHexAndTxHash \(signedTxHexAndTxHash)");
            
            let aipGapDataJSONString = TLUtils.dictionaryToJSONString(false, dict: signedTxHexAndTxHash)
            let data = aipGapDataJSONString.data(using: String.Encoding.utf8)
            return data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        }
        return nil
    }

    class func createSignedTxAipGapData(_ aipGapDataBase64: String, mnemonicOrExtendedPrivateKey: String, isTestnet:Bool) throws -> NSDictionary? {
        let data = Data(base64Encoded: aipGapDataBase64, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        if data == nil {
            throw TLColdWalletError.InvalidScannedData("")
            return nil
        }
        if let result = convertDataToDictionary(data!) {
            DLog("createSignedTxAipGapData:  \(result)")
            let extendedPublicKey = result["account_public_key"] as! String
            
            
            let txInputsAccountHDIdxes = result["tx_inputs_account_hd_idxes"] as! NSArray
            
            let accountIdx = TLHDWalletWrapper.getAccountIdxForExtendedKey(extendedPublicKey)
            DLog("createSignedTxAipGapData accountIdx extendedPublicKey:  \(accountIdx) \(extendedPublicKey)")

            let mnemonicExtendedPrivateKey:String
            if TLHDWalletWrapper.phraseIsValid(mnemonicOrExtendedPrivateKey) {
                let masterHex = TLHDWalletWrapper.getMasterHex(mnemonicOrExtendedPrivateKey)
                mnemonicExtendedPrivateKey = TLHDWalletWrapper.getExtendPrivKey(masterHex, accountIdx: UInt(accountIdx))
                DLog("createSignedTxAipGapData xxxx1 : \(mnemonicExtendedPrivateKey)")
            } else if TLHDWalletWrapper.isValidExtendedPrivateKey(mnemonicOrExtendedPrivateKey) {
                mnemonicExtendedPrivateKey = mnemonicOrExtendedPrivateKey
                DLog("createSignedTxAipGapData xxxx2 : \(mnemonicExtendedPrivateKey)")
            } else {
                throw TLColdWalletError.InvalidKey("")
            }
            let mnemonicExtendedPublicKey = TLHDWalletWrapper.getExtendPubKey(mnemonicExtendedPrivateKey)
            DLog("createSignedTxAipGapData xxxx3 :  \(extendedPublicKey) \(mnemonicExtendedPublicKey)")
            if extendedPublicKey != mnemonicExtendedPublicKey {
                throw TLColdWalletError.MisMatchExtendedPublicKey("")
            }
            
            let privateKeysArray = NSMutableArray(capacity: txInputsAccountHDIdxes.count)
            for _txInputsAccountHDIdx in txInputsAccountHDIdxes {
                let txInputsAccountHDIdx = _txInputsAccountHDIdx as! NSDictionary
                let HDIndexNumber = txInputsAccountHDIdx["idx"] as! Int
                let isChange = txInputsAccountHDIdx["is_change"] as! Bool
                let addressSequence = [isChange ? Int(TLAddressType.change.rawValue) : Int(TLAddressType.main.rawValue), HDIndexNumber]
                let privateKey = TLHDWalletWrapper.getPrivateKey(mnemonicExtendedPrivateKey as NSString, sequence: addressSequence as NSArray, isTestnet: isTestnet)
                privateKeysArray.add(privateKey)
            }
            
            let base64UnsignedTx = result["unsigned_tx_base64"] as! String
            let txData = Data(base64Encoded: base64UnsignedTx, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            //                .map({ NSString(data: $0, encoding: NSUTF8StringEncoding) })
            DLog("Decoded:  \(txData!)")
            
            
            let inputHexScriptsArray = result["input_scripts"] as! NSArray
            let inputScriptsArray = NSMutableArray(capacity: inputHexScriptsArray.count)
            for hexScript in inputHexScriptsArray {
                inputScriptsArray.add(TLWalletUtils.hexStringToData(hexScript as! String)!)
            }

            for _ in 0...3 {
                let txHexAndTxHash = TLCoreBitcoinWrapper.createSignedSerializedTransactionHex(txData!, inputScripts: inputScriptsArray, privateKeys: privateKeysArray, isTestnet: isTestnet)
                DLog("createSignedTxAipGapData txHexAndTxHash: \(txHexAndTxHash.debugDescription as AnyObject)")
                //                break
                if txHexAndTxHash != nil {
                    return txHexAndTxHash!
                }
            }
        }
        return nil
    }
    
    
    class func getSignedTxData(_ aipGapDataBase64: String) -> NSDictionary? {
        let data = Data(base64Encoded: aipGapDataBase64, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        if data == nil {
            return nil
        }
        if let result = convertDataToDictionary(data!) {
            return result as NSDictionary?
        }
        return nil
    }
}
