//
//  TLCurrencyFormat.swift
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

class TLCurrencyFormat {
    
    struct STATIC_MEMBERS {
        static var _currencies: NSArray?
        static var _currencySymbols: NSArray?
        static var _bitcoinDisplays: NSArray?
        static var _bitcoinDisplayWords: NSArray?
    }
    
    class func bitcoinAmountStringToCoin(amount: String, locale: NSLocale=NSLocale.currentLocale()) -> TLCoin {
        return amountStringToCoin(amount, bitcoinDenomination: TLBitcoinDenomination.Bitcoin, locale: locale)
    }
    
    class func properBitcoinAmountStringToCoin(amount: String, locale: NSLocale=NSLocale.currentLocale()) -> TLCoin {
        return amountStringToCoin(amount, bitcoinDenomination: TLPreferences.getBitcoinDenomination(), locale: locale)
    }
    
    private class func amountStringToCoin(amount: String, bitcoinDenomination: TLBitcoinDenomination, locale: NSLocale) -> TLCoin {
        if amount.characters.count != 0 {
            if let _ = amount.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "0123456789.,").invertedSet) {
                return TLCoin.zero()
            } else {
                return TLCoin(bitcoinAmount: amount, bitcoinDenomination: bitcoinDenomination, locale: locale)
            }
        } else {
            return TLCoin.zero()
        }
    }
    
    class func coinToProperBitcoinAmountString(amount: TLCoin, withCode: Bool = false) -> String {
        if withCode {
            return amount.bigIntegerToBitcoinAmountString(TLPreferences.getBitcoinDenomination()) + " " + TLCurrencyFormat.getBitcoinDisplay()
        } else {
            return amount.bigIntegerToBitcoinAmountString(TLPreferences.getBitcoinDenomination())
        }
    }
    
    class func coinToProperFiatAmountString(amount: TLCoin, withCode: Bool = false) -> String {
        let currency = TLCurrencyFormat.getFiatCurrency()
        if withCode {
            return TLExchangeRate.instance().fiatAmountStringFromBitcoin(currency, bitcoinAmount: amount) + " " + TLCurrencyFormat.getFiatCurrency()
        } else {
            return TLExchangeRate.instance().fiatAmountStringFromBitcoin(currency, bitcoinAmount: amount)
        }
    }
    
    class func getProperAmount(amount: TLCoin) -> NSString {
        var balance: NSString? = nil
        if (TLPreferences.isDisplayLocalCurrency()) {
            let currency = TLCurrencyFormat.getProperCurrency()
            balance = TLExchangeRate.instance().fiatAmountStringFromBitcoin(currency, bitcoinAmount: amount)
        } else {
            balance = coinToProperBitcoinAmountString(amount)
        }
        
        balance = String(format: "%@ %@", balance!, getProperCurrency())
        
        return balance!
    }
    
    class func getCurrencySymbol() -> String {
        return getCurrencySymbolArray().objectAtIndex(Int(TLPreferences.getCurrencyIdx()!)!) as! String
    }
    
    class func getFiatCurrency() -> String {
        return getCurrencyArray().objectAtIndex(Int(TLPreferences.getCurrencyIdx()!)!) as! String
    }
    
    class func getProperCurrency() -> String {
        if (TLPreferences.isDisplayLocalCurrency()) {
            return getCurrencyArray().objectAtIndex(Int(TLPreferences.getCurrencyIdx()!)!) as! String
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