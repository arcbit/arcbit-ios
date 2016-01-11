//
//  TLWalletUtils.swift
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


enum TLSendFromType: Int {
    case HDWallet = 0
    case ImportedAccount = 1
    case ImportedWatchAccount = 2
    case ImportedAddress = 3
    case ImportedWatchAddress = 4
}

enum TLAccountTxType: Int {
    case Send = 0
    case Receive = 1
    case MoveBetweenAccount = 2
}

enum TLAccountType: Int {
    case Unknown = 0
    case HDWallet = 1
    case Imported = 2
    case ImportedWatch = 3
}

enum TLAccountAddressType: Int {
    case Imported = 1
    case ImportedWatch = 2
}


class TLWalletUtils {
    typealias Error = () -> ()
    typealias Success = () -> ()
    
    typealias SuccessWithDictionary = (NSDictionary) -> ()
    
    typealias SuccessWithString = (String!) -> ()
    typealias ErrorWithString = (String?) -> ()
    
    
    class func APP_NAME() -> String {
        return STATIC_MEMBERS.APP_NAME
    }
    
    class func DEFAULT_FEE_AMOUNT_IN_BITCOINS() -> (String) {
        return TLCurrencyFormat.bitcoinAmountStringToCoin(STATIC_MEMBERS.DEFAULT_FEE_AMOUNT, locale: NSLocale(localeIdentifier: "en_US")).bigIntegerToBitcoinAmountString(TLBitcoinDenomination.Bitcoin)
    }
    
    class func MAX_FEE_AMOUNT_IN_BITCOINS() -> (String) {
        return TLCurrencyFormat.bitcoinAmountStringToCoin(STATIC_MEMBERS.MAX_FEE_AMOUNT, locale: NSLocale(localeIdentifier: "en_US")).bigIntegerToBitcoinAmountString(TLBitcoinDenomination.Bitcoin)
    }
    
    class func MIN_FEE_AMOUNT_IN_BITCOINS() -> (String) {
        return TLCurrencyFormat.bitcoinAmountStringToCoin(STATIC_MEMBERS.MIN_FEE_AMOUNT, locale: NSLocale(localeIdentifier: "en_US")).bigIntegerToBitcoinAmountString(TLBitcoinDenomination.Bitcoin)
    }

    class func RECEIVE_ICON_IMAGE_NAME() -> (String) {
        return STATIC_MEMBERS.RECEIVE_ICON_IMAGE_NAME
    }
    
    class func SEND_ICON_IMAGE_NAME() -> (String) {
        return STATIC_MEMBERS.SEND_ICON_IMAGE_NAME
    }
    
    
    class func HISTORY_ICON_IMAGE_NAME() -> (String) {
        return STATIC_MEMBERS.HISTORY_ICON_IMAGE_NAME
    }
    
    class func ACCOUNT_ICON_IMAGE_NAME() -> (String) {
        return STATIC_MEMBERS.ACCOUNT_ICON_IMAGE_NAME
    }
    
    class func HELP_ICON_IMAGE_NAME() -> (String) {
        return STATIC_MEMBERS.HELP_ICON_IMAGE_NAME
    }
    
    class func LINK_ICON_IMAGE_NAME() -> (String) {
        return STATIC_MEMBERS.LINK_ICON_IMAGE_NAME
    }
    
    class func SETTINGS_ICON_IMAGE_NAME() -> (String) {
        return STATIC_MEMBERS.SETTINGS_ICON_IMAGE_NAME
    }
    
    struct STATIC_MEMBERS {
        static let APP_NAME = "ArcBit Wallet"
        
        static let WALLET_JSON_CLOUD_BACKUP_FILE_NAME = "wallet.json.asc"
        static let WALLET_JSON_CLOUD_BACKUP_FILE_EXTENSION = "backup"
        
        static let SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON = false
        static let ENABLE_STEALTH_ADDRESS = true
        
        static let SEND_ICON_IMAGE_NAME = "upload.png"
        static let RECEIVE_ICON_IMAGE_NAME = "download.png"
        static let SEND_ICON_2_IMAGE_NAME = "upload2.png"
        static let RECEIVE_ICON_2_IMAGE_NAME = "download2.png"
        static let HISTORY_ICON_IMAGE_NAME = "newspaper-alt.png"
        static let ACCOUNT_ICON_IMAGE_NAME = "data.png"
        static let HELP_ICON_IMAGE_NAME = "book.png"
        static let LINK_ICON_IMAGE_NAME = "link.png"
        static let SETTINGS_ICON_IMAGE_NAME = "settings.png"
        static let SELECT_ACCOUNT_ICON_IMAGE_NAME = "arrow-right7.png"
        
        static let BITCOIN_URI_BASE = "bitcoin:"
        static let BITCOIN_ISO_CODE = "BTC"
        static let BITCOIN_SYMBOL = "B"
        
        static let DEFAULT_FEE_AMOUNT = "0.0001"
        
        //use to prevent user input error of too high a fee
        static let MAX_FEE_AMOUNT = "0.01"
        //use to prevent user input error of too low a fee
        static let MIN_FEE_AMOUNT = "0.0001"
    }
    
    class func ENABLE_STEALTH_ADDRESS() -> (Bool) {
        return STATIC_MEMBERS.ENABLE_STEALTH_ADDRESS
    }
    
    class func dataToHexString(data: NSData) -> String {
        return data.hex()
    }
    
    class func hexStringToData(hexString: String) -> NSData? {
        return BTCDataFromHex(hexString)
    }
    
    class func reverseHexString(txHashHex: String) -> String {
        return dataToHexString(hexStringToData(txHashHex)!.reverse())
    }
    
    class func isValidInputTransactionFee(amount: TLCoin) -> Bool {
        let maxFeeAmount = TLCoin(bitcoinAmount: MAX_FEE_AMOUNT_IN_BITCOINS(), bitcoinDenomination: TLBitcoinDenomination.Bitcoin)
        let minFeeAmount = TLCoin(bitcoinAmount: MIN_FEE_AMOUNT_IN_BITCOINS(), bitcoinDenomination: TLBitcoinDenomination.Bitcoin)
        if (amount.greater(maxFeeAmount)) {
            return false
        }
        if (amount.less(minFeeAmount)) {
            return false
        }
        
        return true
    }
    
    class func getBitcoinURI(address: String, amount: TLCoin,
        label: String?, message: String?) -> String {
            
            let bitcoinURI = NSMutableString(string: STATIC_MEMBERS.BITCOIN_URI_BASE)
            
            bitcoinURI.appendString(address)
            
            bitcoinURI.appendString("?amount=")
            bitcoinURI.appendString(amount.toString())
            
            if (label != nil && label! != "") {
                bitcoinURI.appendString("&label=")
                bitcoinURI.appendString(label!)
            }
            
            if (message != nil && message! != "") {
                bitcoinURI.appendString("&message=")
                bitcoinURI.appendString(message!)
            }
            
            return bitcoinURI as String
    }
    
    class func parseBitcoinURI(urlString: String) -> NSDictionary? {
        if !urlString.hasPrefix("bitcoin:") {
            return nil
        }
        
        var replaced = urlString.stringByReplacingOccurrencesOfString("bitcoin:", withString: "bitcoin://").stringByReplacingOccurrencesOfString("////", withString: "//")
        
        if replaced.rangeOfString("&") == nil && replaced.rangeOfString("?") == nil {
            replaced = replaced+"?"
        }
        
        let url = NSURL(string: replaced)
        
        let dict = parseBitcoinQueryString(url!.query!)
        
        if (url!.host != nil) {
            dict.setObject(url!.host!, forKey: "address")
        }
        
        return dict
    }
    
    class func parseBitcoinQueryString(query: String) -> NSMutableDictionary {
        let dict = NSMutableDictionary(capacity: 6)
        let pairs = query.componentsSeparatedByString("&")
        
        for _pair in pairs {
            let pair = _pair as String
            let elements = pair.componentsSeparatedByString("=")
            if (elements.count >= 2) {
                let key = elements[0].stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                let val = elements[1].stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                
                dict.setObject(val, forKey: key)
            }
        }
        return dict
    }
    
    class func getQRCodeImage(data: String, imageDimension: Int) -> UIImage {
        let dataMatrix = QREncoder.encodeWithECLevel(1, version: 1, string: data)
        let image = QREncoder.renderDataMatrix(dataMatrix, imageDimension: Int32(imageDimension))
        return image
    }
}