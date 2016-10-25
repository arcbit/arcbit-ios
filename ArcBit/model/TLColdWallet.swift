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
    static let SPLIT_SUB_STRING_LENGTH = 100
    static let AIR_GAP_DATA_VERSION = "1"
    static let AIR_GAP_DATA_TRANSPORT_VERSION = "1"

    struct STATIC_MEMBERS {
        static var instance:TLSpaghettiGodSend?
    }

    class func dictionaryToJsonString(_ dict: NSDictionary) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            
            let JSONString = NSString(data: jsonData, encoding: String.Encoding.ascii.rawValue)
            
            DLog("theJSONText:  \(JSONString)")
            return JSONString as! String
            
        } catch let error as NSError {
            DLog("error:  \(error)")
        }
        return nil
    }

    class func createAipGapData(_ unSignedTx: String, extendedPublicKey: String, txInputsAccountHDIdxes:NSArray) -> String? {
        let data = TLWalletUtils.hexStringToData(unSignedTx)
        if let base64Encoded = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) {
            
            let dataDictionaryToAirGapPass = [
                "v": AIR_GAP_DATA_VERSION,
                "account_public_key": extendedPublicKey,
                "unsigned_tx_base64": base64Encoded,
                "tx_inputs_account_hd_idxes": txInputsAccountHDIdxes //[["idx":123, "is_change":false], ["idx":124, "is_change":true]]
            ]
            
            return dictionaryToJsonString(dataDictionaryToAirGapPass)
        }
        return nil
    }

    class func createSerializedAipGapData(_ unSignedTx: String, extendedPublicKey: String, txInputsAccountHDIdxes:NSArray) -> String? {
        let aipGapDataJSONString = TLColdWallet.createAipGapData(unSignedTx, extendedPublicKey: extendedPublicKey, txInputsAccountHDIdxes: txInputsAccountHDIdxes)
        let data = aipGapDataJSONString?.data(using: String.Encoding.utf8)
        return data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }

    class func splitStringToAray(_ str: String) -> Array<String> {
        var partsArray = [String]()
        var idx = 0
//        let SPLIT_SUB_STRING_LENGTH = 268
        let SPLIT_SUB_STRING_LENGTH = 100
        let nsString = str as NSString
        while true {
//            DLog("bbbbb \(idx) \(SUB_STRING_LENGTH)")
            let subString:String
            
            
            
            if idx+SPLIT_SUB_STRING_LENGTH >= str.characters.count {
                subString = nsString.substring(with: NSRange(location: idx, length: nsString.length-idx))
                partsArray.append(subString)
                
//                if subString.characters.count == SPLIT_SUB_STRING_LENGTH {
//                    partsArray.append("")
//                }
                break
            } else {
                subString = nsString.substring(with: NSRange(location: idx, length: SPLIT_SUB_STRING_LENGTH))
                partsArray.append(subString)
            }
            
//            if idx+SPLIT_SUB_STRING_LENGTH >= str.characters.count {
//                subString = nsString.substringWithRange(NSRange(location: idx, length: nsString.length-idx))
//                let airGapDataPart = [
//                    "v": AIR_GAP_DATA_TRANSPORT_VERSION, //version
//                    "d": subString, //data
//                    "l": 1, //last
//                ]
//                let JSONString = dictionaryToJsonString(airGapDataPart)
//                let data = JSONString!.dataUsingEncoding(NSUTF8StringEncoding)
//                let base64DataPart = data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
//                
//                partsArray.append(base64DataPart)
//                break
//            } else {
//                subString = nsString.substringWithRange(NSRange(location: idx, length: SPLIT_SUB_STRING_LENGTH))
//                let airGapDataPart = [
//                    "v": AIR_GAP_DATA_TRANSPORT_VERSION, //version
//                    "d": subString, //data
//                    "l": 0, //last
//                ]
//                let JSONString = dictionaryToJsonString(airGapDataPart)
//                let data = JSONString!.dataUsingEncoding(NSUTF8StringEncoding)
//                let base64DataPart = data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
//                
//                partsArray.append(base64DataPart)
//            }
//            
            
            
//            DLog("ccccc \(partsArray)")
            idx += SPLIT_SUB_STRING_LENGTH
        }
        return partsArray
    }
    
    class func convertDataToDictionary(_ data: Data) -> [String:AnyObject]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    class func createSignedAipGapData(_ aipGapDataBase64: String, isTestnet:Bool) -> String? {
        let data = Data(base64Encoded: aipGapDataBase64, options: NSData.Base64DecodingOptions(rawValue: 0))
        if data == nil {
            return nil
        }
        if let result = convertDataToDictionary(data!) {
            DLog("createSignedAipGapData:  \(result)")
            let extendedPublicKey = result["account_public_key"] as! String
            
            
            let txInputsAccountHDIdxes = result["tx_inputs_account_hd_idxes"] as! NSArray
            
            let accountIdx = TLHDWalletWrapper.getAccountIdxForExtendedKey(extendedPublicKey)
            let mnemonic = "merit wrong glass error pond response eye impulse welcome ring super message"
            let masterHex = TLHDWalletWrapper.getMasterHex(mnemonic)
            let extendedPrivateKey = TLHDWalletWrapper.getExtendPrivKey(masterHex, accountIdx: UInt(accountIdx))
            let privateKeysArray = NSMutableArray(capacity: txInputsAccountHDIdxes.count)
            for _txInputsAccountHDIdx in txInputsAccountHDIdxes {
                let txInputsAccountHDIdx = _txInputsAccountHDIdx as! NSDictionary
                let HDIndexNumber = txInputsAccountHDIdx["idx"] as! Int
                let isChange = txInputsAccountHDIdx["is_change"] as! Bool
                let addressSequence = [isChange ? Int(TLAddressType.change.rawValue) : Int(TLAddressType.main.rawValue), HDIndexNumber]
                let privateKey = TLHDWalletWrapper.getPrivateKey(extendedPrivateKey, sequence: addressSequence, isTestnet: isTestnet)
                privateKeysArray.add(privateKey)
            }
            
            let base64UnsignedTx = result["unsigned_tx_base64"] as! String
            let txData = Data(base64Encoded: base64UnsignedTx, options: NSData.Base64DecodingOptions(rawValue: 0))
            //                .map({ NSString(data: $0, encoding: NSUTF8StringEncoding) })
            DLog("Decoded:  \(txData!)")
            
            for _ in 0...3 {
                let txHexAndTxHash = TLCoreBitcoinWrapper.createSignedSerializedTransactionHex(txData!, privateKeys: privateKeysArray, isTestnet: isTestnet)
                DLog("createSignedAipGapData txHexAndTxHash: %@", function: txHexAndTxHash.debugDescription)
                //                break
                if txHexAndTxHash != nil {
                    //                    return txHexAndTxHash!
                }
            }
        }
        return nil
    }
}
