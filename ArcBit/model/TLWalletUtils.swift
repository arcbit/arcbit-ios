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

enum TLCoinType: String {
    case BTC = "BTC"
    case BCH = "BCH"
}

enum TLSendFromType: Int {
    case hdWallet = 0
    case importedAccount = 1
    case importedWatchAccount = 2
    case importedAddress = 3
    case importedWatchAddress = 4
    case coldWalletAccount = 5
}

enum TLAccountTxType: Int {
    case send = 0
    case receive = 1
    case moveBetweenAccount = 2
}

enum TLAccountType: Int {
    case unknown = 0
    case hdWallet = 1
    case imported = 2
    case importedWatch = 3
    case coldWallet = 4
}

enum TLAccountAddressType: Int {
    case imported = 1
    case importedWatch = 2
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
    
    class func GET_CRYPTO_COIN_FULL_NAME(_ coinType: TLCoinType) ->String {
        switch coinType {
        case .BCH:
            return TLDisplayStrings.CRYPTO_COIN_BITCOIN_CASH()
        case .BTC:
            return TLDisplayStrings.CRYPTO_COIN_BITCOIN()
        }
    }
    
    class func DEFAULT_COIN_TYPE() ->TLCoinType {
        return TLCoinType.BTC
    }
    
    class func SUPPORT_COIN_TYPES() -> ([TLCoinType]) {
        return [TLCoinType.BCH, TLCoinType.BTC]
    }
    
    class func DEFAULT_FEE_AMOUNT_IN_BITCOIN() -> (String) {
        let coin = TLCurrencyFormat.coinAmountStringToCoin(STATIC_MEMBERS.DEFAULT_FEE_AMOUNT_BITCOIN, coinType: TLCoinType.BTC, locale: Locale(identifier: "en_US"))
        return TLCurrencyFormat.bigIntegerToBitcoinAmountString(coin, coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
    }
    
    class func DEFAULT_FEE_AMOUNT_IN_BITCOIN_CASH() -> (String) {
        let coin = TLCurrencyFormat.coinAmountStringToCoin(STATIC_MEMBERS.DEFAULT_FEE_AMOUNT_BITCOIN_CASH, coinType: TLCoinType.BCH, locale: Locale(identifier: "en_US"))
        return TLCurrencyFormat.bigIntegerToBitcoinAmountString(coin, coinType: TLCoinType.BCH, coinDenomination: TLCoinDenomination.bitcoinCash)
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
    
    class func VAULT_ICON_IMAGE_NAME() -> (String) {
        return STATIC_MEMBERS.VAULT_ICON_IMAGE_NAME
    }
    
    struct STATIC_MEMBERS {
        static let APP_NAME = "ArcBit Wallet"
        
        static let WALLET_JSON_CLOUD_BACKUP_FILE_NAME = "wallet.json.asc"
        static let WALLET_JSON_CLOUD_BACKUP_FILE_EXTENSION = "backup"
        
        static let SHOULD_SAVE_ARCHIVED_ADDRESSES_IN_JSON = false
        static let ENABLE_STEALTH_ADDRESS = false
        static let ALLOW_MANUAL_SCAN_FOR_STEALTH_PAYMENT = true

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
        static let VAULT_ICON_IMAGE_NAME = "vault.png"

        static let BITCOIN_URI_BASE = "bitcoin:"
        static let BITCOIN_ISO_CODE = "BTC"
        static let BITCOIN_SYMBOL = "B"
        
        static let DEFAULT_FEE_AMOUNT_BITCOIN = "0.0001"
        static let DEFAULT_FEE_AMOUNT_BITCOIN_CASH = "0.000001"
    }
    
    class func ENABLE_STEALTH_ADDRESS() -> (Bool) {
        return STATIC_MEMBERS.ENABLE_STEALTH_ADDRESS
    }
    
    class func ALLOW_MANUAL_SCAN_FOR_STEALTH_PAYMENT() -> (Bool) {
        return STATIC_MEMBERS.ALLOW_MANUAL_SCAN_FOR_STEALTH_PAYMENT
    }
    
    class func dataToHexString(_ data: Data) -> String {
        return (data as NSData).hex()
    }
    
    class func hexStringToData(_ hexString: String) -> Data? {
        return BTCDataFromHex(hexString)
    }
    
    class func reverseHexString(_ txHashHex: String) -> String {
        return dataToHexString((hexStringToData(txHashHex)! as NSData).reverse())
    }
    
    class func getBitcoinURI(_ address: String, amount: TLCoin,
        label: String?, message: String?) -> String {
            
            let bitcoinURI = NSMutableString(string: STATIC_MEMBERS.BITCOIN_URI_BASE)
            
            bitcoinURI.append(address)
            
            bitcoinURI.append("?amount=")
            bitcoinURI.append(amount.toString())
            
            if (label != nil && label! != "") {
                bitcoinURI.append("&label=")
                bitcoinURI.append(label!)
            }
            
            if (message != nil && message! != "") {
                bitcoinURI.append("&message=")
                bitcoinURI.append(message!)
            }
            
            return bitcoinURI as String
    }
    
    class func parseBitcoinURI(_ urlString: String) -> NSDictionary? {
        if !urlString.hasPrefix("bitcoin:") {
            return nil
        }
        
        var replaced = urlString.replacingOccurrences(of: "bitcoin:", with: "bitcoin://").replacingOccurrences(of: "////", with: "//")
        
        if replaced.range(of: "&") == nil && replaced.range(of: "?") == nil {
            replaced = replaced+"?"
        }
        
        let url = URL(string: replaced)
        
        let dict = parseBitcoinQueryString(url!.query!)
        
        if (url!.host != nil) {
            dict.setObject(url!.host!, forKey: "address" as NSCopying)
        }
        
        return dict
    }
    
    class func parseBitcoinQueryString(_ query: String) -> NSMutableDictionary {
        let dict = NSMutableDictionary(capacity: 6)
        let pairs = query.components(separatedBy: "&")
        
        for _pair in pairs {
            let pair = _pair as String
            let elements = pair.components(separatedBy: "=")
            if (elements.count >= 2) {
                let key = elements[0].replacingPercentEscapes(using: String.Encoding.utf8)!
                let val = elements[1].replacingPercentEscapes(using: String.Encoding.utf8)!
                
                dict.setObject(val, forKey: key as NSCopying)
            }
        }
        return dict
    }
    
    class func getQRCodeImage(_ data: String, imageDimension: Int) -> UIImage {
        let dataMatrix = QREncoder.encode(withECLevel: 1, version: 1, string: data)
        let image = QREncoder.renderDataMatrix(dataMatrix, imageDimension: Int32(imageDimension))
        return image!
    }
}
