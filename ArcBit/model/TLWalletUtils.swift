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
    case MoveBetweenWallet = 2
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


@objc class TLWalletUtils {
    typealias Error = () -> ()
    typealias Success = () -> ()
    
    typealias SuccessWithDictionary = (NSDictionary) -> ()
    
    typealias SuccessWithString = (String!) -> ()
    typealias ErrorWithString = (String?) -> ()
    
    
    class func APP_NAME() -> String {
        return STATIC_MEMBERS.APP_NAME
    }
    
    class func IS_TESTNET() -> Bool {
        return STATIC_MEMBERS.IS_TESTNET
    }
    
    class func DEFAULT_FEE_AMOUNT() -> (String) {
        return STATIC_MEMBERS.DEFAULT_FEE_AMOUNT
    }
    
    class func MAX_FEE_AMOUNT() -> (String) {
        return STATIC_MEMBERS.MAX_FEE_AMOUNT
    }
    
    class func MIN_FEE_AMOUNT() -> (String) {
        return STATIC_MEMBERS.MIN_FEE_AMOUNT
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
    
    class func SETTINGS_ICON_IMAGE_NAME() -> (String) {
        return STATIC_MEMBERS.SETTINGS_ICON_IMAGE_NAME
    }
    
    struct STATIC_MEMBERS {
        static var _currencies: NSArray?
        static var _currencySymbols: NSArray?
        static var _bitcoinDisplays: NSArray?
        static var _bitcoinDisplayWords: NSArray?

        static let APP_NAME = "ArcBit Wallet"
        static let IS_TESTNET = false
        
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
    
    class func reverseTxidHexString(txHashHex: String) -> String {
        return dataToHexString(hexStringToData(txHashHex)!.reverse())
    }
    
    class func privateKeyFromEncryptedPrivateKey(encryptedPrivateKey: String, password: String) -> String? {
        return TLCoreBitcoinWrapper.privateKeyFromEncryptedPrivateKey(encryptedPrivateKey, password: password)
    }
    
    class func isValidInputTransactionFee(amount: TLCoin) -> Bool {
        let maxFeeAmount = TLCoin(bitcoinAmount: STATIC_MEMBERS.MAX_FEE_AMOUNT, bitcoinDenomination: TLBitcoinDenomination.Bitcoin)
        let minFeeAmount = TLCoin(bitcoinAmount: STATIC_MEMBERS.MIN_FEE_AMOUNT, bitcoinDenomination: TLBitcoinDenomination.Bitcoin)
        if (amount.greater(maxFeeAmount)) {
            return false
        }
        if (amount.less(minFeeAmount)) {
            return false
        }
        
        return true
    }
    
    class func bitcoinAmountStringToCoin(amount: String) -> TLCoin {
        return amountStringToCoin(amount, bitcoinDenomination: TLBitcoinDenomination.Bitcoin)
    }
    
    class func properBitcoinAmountStringToCoin(amount: String) -> TLCoin {
        return amountStringToCoin(amount, bitcoinDenomination: TLPreferences.getBitcoinDenomination())
    }
    
    private class func amountStringToCoin(amount: String, bitcoinDenomination: TLBitcoinDenomination) -> TLCoin {
        if count(amount) != 0 {
            if let range = amount.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "0123456789.").invertedSet) {
                return TLCoin.zero()
            } else {
                return TLCoin(bitcoinAmount: amount, bitcoinDenomination: bitcoinDenomination)
            }
        } else {
            return TLCoin.zero()
        }
    }
    
    class func coinToProperBitcoinAmountString(amount: TLCoin) -> String {
        return amount.bigIntegerToBitcoinAmountString(TLPreferences.getBitcoinDenomination())
    }
    
    class func getProperAmount(amount: TLCoin) -> NSString {
        var balance: NSString? = nil
        if (TLPreferences.isDisplayLocalCurrency()) {
            let currency = TLWalletUtils.getProperCurrency()
            balance = TLExchangeRate.instance().fiatAmountStringFromBitcoin(currency, bitcoinAmount: amount)
        } else {
            balance = coinToProperBitcoinAmountString(amount)
        }
        
        balance = String(format: "%@ %@", balance!, getProperCurrency())
        
        return balance!
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
        
        let replaced = urlString.stringByReplacingOccurrencesOfString("bitcoin:", withString: "bitcoin://").stringByReplacingOccurrencesOfString("////", withString: "//")
        
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
    
    class func getCurrencySymbol() -> String {
        return getCurrencySymbolArray().objectAtIndex(TLPreferences.getCurrencyIdx()!.toInt()!) as! String
    }
    
    class func getFiatCurrency() -> String {
        return getCurrencyArray().objectAtIndex(TLPreferences.getCurrencyIdx()!.toInt()!) as! String
    }
    
    class func getProperCurrency() -> String {
        if (TLPreferences.isDisplayLocalCurrency()) {
            return getCurrencyArray().objectAtIndex(TLPreferences.getCurrencyIdx()!.toInt()!) as! String
        } else {
            return getBitcoinDisplay()
        }
    }
    
    class func getBitcoinDisplay() -> String {
        let bitcoinDenomination = TLPreferences.getBitcoinDenomination()
        
        if (bitcoinDenomination == TLBitcoinDenomination.Bitcoin) {
            return getBitcoinDisplayArray().objectAtIndex(0) as! String
        } else if (bitcoinDenomination == TLBitcoinDenomination.MilliBit) {
            return getBitcoinDisplayArray().objectAtIndex(1) as! String
        } else {
            return getBitcoinDisplayArray().objectAtIndex(2) as! String
        }
    }
    
    class func getBitcoinDisplayWord() -> String {
        let bitcoinDenomination = TLPreferences.getBitcoinDenomination()
        
        if (bitcoinDenomination == TLBitcoinDenomination.Bitcoin) {
            return getBitcoinDisplayWordArray().objectAtIndex(0) as! String
        } else if (bitcoinDenomination == TLBitcoinDenomination.MilliBit) {
            return getBitcoinDisplayWordArray().objectAtIndex(1) as! String
        } else {
            return getBitcoinDisplayWordArray().objectAtIndex(2) as! String
        }
    }
    
    class func getBitcoinDisplayArray() -> NSArray {
        if (STATIC_MEMBERS._bitcoinDisplays == nil) {
            STATIC_MEMBERS._bitcoinDisplays = [
                "BTC",
                "mBTC",
                "uBTC",
            ]
        }
        return STATIC_MEMBERS._bitcoinDisplays!
    }
    
    class func getBitcoinDisplayWordArray() -> NSArray {
        if (STATIC_MEMBERS._bitcoinDisplayWords == nil) {
            STATIC_MEMBERS._bitcoinDisplayWords = [
                "Bitcoin",
                "MilliBit",
                "Bits",
            ]
        }
        return STATIC_MEMBERS._bitcoinDisplayWords!
    }
    
    class func getCurrencySymbolArray() -> (NSArray) {
        if (STATIC_MEMBERS._currencySymbols == nil) {
            STATIC_MEMBERS._currencySymbols = [
                "$",
                "R$",
                "$",
                "CHF",
                "$",
                "¥",
                "kr",
                "€",
                "£",
                "$",
                "kr",
                "¥",
                "₩",
                "$",
                "zł",
                "RUB",
                "kr",
                "$",
                "฿",
                "$",
                "$",
                
                "D",
                "N",
                "L",
                "D",
                "G",
                "A",
                "S",
                "G",
                "N",
                "M",
                "D",
                "T",
                "N",
                "D",
                "F",
                "D",
                "D",
                "B",
                "D",
                "N",
                "P",
                "R",
                "D",
                "F",
                "F",
                "P",
                "C",
                "E",
                "K",
                "F",
                "P",
                "D",
                "K",
                "P",
                "B",
                "D",
                "P",
                "L",
                "S",
                "P",
                "D",
                "F",
                "Q",
                "D",
                "L",
                "K",
                "G",
                "F",
                "R",
                "S",
                "R",
                "D",
                "P",
                "D",
                "D",
                "S",
                "S",
                "R",
                "F",
                "D",
                "D",
                "T",
                "K",
                "P",
                "R",
                "D",
                "L",
                "L",
                "L",
                "D",
                "D",
                "L",
                "A",
                "D",
                "K",
                "T",
                "P",
                "O",
                "R",
                "R",
                "K",
                "N",
                "R",
                "N",
                "D",
                "N",
                "O",
                "K",
                "R",
                "R",
                "B",
                "N",
                "K",
                "P",
                "R",
                "G",
                "R",
                "N",
                "D",
                "F",
                "R",
                "D",
                "R",
                "G",
                "P",
                "L",
                "S",
                "D",
                "D",
                "C",
                "P",
                "L",
                "S",
                "T",
                "D",
                "P",
                "Y",
                "D",
                "S",
                "H",
                "X",
                "U",
                "S",
                "F",
                "D",
                "V",
                "T",
                "F",
                "G",
                "U",
                "D",
                "F",
                "F",
                "R",
                "R",
                "W",
                "L"]
        }
        return STATIC_MEMBERS._currencySymbols!
    }
    
    class func getCurrencyArray() -> NSArray {
        if (STATIC_MEMBERS._currencies == nil) {
            STATIC_MEMBERS._currencies = [
                
                "AUD",
                "BRL",
                "CAD",
                "CHF",
                "CLP",
                "CNY",
                "DKK",
                "EUR",
                "GBP",
                "HKD",
                "ISK",
                "JPY",
                "KRW",
                "NZD",
                "PLN",
                "RUB",
                "SEK",
                "SGD",
                "THB",
                "TWD",
                "USD",
                
                "AED",
                "AFN",
                "ALL",
                "AMD",
                "ANG",
                "AOA",
                "ARS",
                "AWG",
                "AZN",
                "BAM",
                "BBD",
                "BDT",
                "BGN",
                "BHD",
                "BIF",
                "BMD",
                "BND",
                "BOB",
                "BSD",
                "BTN",
                "BWP",
                "BYR",
                "BZD",
                "CDF",
                "CLF",
                "COP",
                "CRC",
                "CVE",
                "CZK",
                "DJF",
                "DOP",
                "DZD",
                "EEK",
                "EGP",
                "ETB",
                "FJD",
                "FKP",
                "GEL",
                "GHS",
                "GIP",
                "GMD",
                "GNF",
                "GTQ",
                "GYD",
                "HNL",
                "HRK",
                "HTG",
                "HUF",
                "IDR",
                "ILS",
                "INR",
                "IQD",
                "JEP",
                "JMD",
                "JOD",
                "KES",
                "KGS",
                "KHR",
                "KMF",
                "KWD",
                "KYD",
                "KZT",
                "LAK",
                "LBP",
                "LKR",
                "LRD",
                "LSL",
                "LTL",
                "LVL",
                "LYD",
                "MAD",
                "MDL",
                "MGA",
                "MKD",
                "MMK",
                "MNT",
                "MOP",
                "MRO",
                "MUR",
                "MVR",
                "MWK",
                "MXN",
                "MYR",
                "MZN",
                "NAD",
                "NGN",
                "NIO",
                "NOK",
                "NPR",
                "OMR",
                "PAB",
                "PEN",
                "PGK",
                "PHP",
                "PKR",
                "PYG",
                "QAR",
                "RON",
                "RSD",
                "RWF",
                "SAR",
                "SBD",
                "SCR",
                "SDG",
                "SHP",
                "SLL",
                "SOS",
                "SRD",
                "STD",
                "SVC",
                "SYP",
                "SZL",
                "TJS",
                "TMT",
                "TND",
                "TOP",
                "TRY",
                "TTD",
                "TZS",
                "UAH",
                "UGX",
                "UYU",
                "UZS",
                "VEF",
                "VND",
                "VUV",
                "WST",
                "XAF",
                "XAG",
                "XAU",
                "XCD",
                "XOF",
                "XPF",
                "YER",
                "ZAR",
                "ZMW",
                "ZWL"]
        }
        return STATIC_MEMBERS._currencies!
    }
}