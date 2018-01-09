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

enum TLCoinDenomination:Int {
    case bitcoin  = 0
    case bitcoin_milliBit = 1
    case bitcoin_bits     = 2
    case bitcoinCash  = 3
    case bitcoinCash_milliBit = 4
    case bitcoinCash_bits     = 5
}

class TLCurrencyFormat {
    
    struct STATIC_MEMBERS {
        static var _currencies: NSArray?
        static var _currencySymbols: NSArray?
        static var _bitcoinDisplays: Array<String> = {
            return [
                "BTC",
                "mBTC",
                "uBTC",
                ]
        }()
        static var _bitcoinCashDisplays: Array<String> = {
            return [
                "BCH",
                "mBCH",
                "uBCH",
                ]
        }()
//        static var _bitcoinDisplayWords: NSArray?
    }

    class func DEFAULT_COIN_DENOMINATION_STARTING_IDX(_ coinType: TLCoinType) -> Int {
        switch coinType {
        case .BCH:
            return 3
        case .BTC:
            return 0
        }
    }
    
    class func coinAmountStringToCoin(_ amount: String, coinType: TLCoinType, locale: Locale=Locale.current) -> TLCoin {
        switch coinType {
        case .BCH:
            return amountStringToCoin(amount, coinType: coinType, coinDenomination: TLCoinDenomination.bitcoinCash, locale: locale)
        case .BTC:
            return amountStringToCoin(amount, coinType: coinType, coinDenomination: TLCoinDenomination.bitcoin, locale: locale)
        }
    }
    
    class func properBitcoinAmountStringToCoin(_ amount: String, coinType: TLCoinType, locale: Locale=Locale.current) -> TLCoin {
        switch coinType {
        case .BCH:
            return amountStringToCoin(amount, coinType: coinType, coinDenomination: TLPreferences.getBitcoinCashDenomination(), locale: locale)
        case .BTC:
            return amountStringToCoin(amount, coinType: coinType, coinDenomination: TLPreferences.getBitcoinDenomination(), locale: locale)
        }
    }
    
    class func amountStringToCoin(_ amount: String, coinType: TLCoinType, coinDenomination: TLCoinDenomination, locale: Locale=Locale.current) -> TLCoin {
        if amount.characters.count != 0 {
            if let _ = amount.rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789.,").inverted) {
                return TLCoin.zero()
            } else {
                let bitcoinFormatter = NumberFormatter()
                bitcoinFormatter.numberStyle = .decimal
                bitcoinFormatter.maximumFractionDigits = 8
                bitcoinFormatter.locale = locale
                guard let _ = bitcoinFormatter.number(from: amount) else {
                    return TLCoin.zero()
                }
                
                let satoshis:UInt64
                let mericaFormatter = NumberFormatter()
                mericaFormatter.maximumFractionDigits = 8
                mericaFormatter.locale = Locale(identifier: "en_US")
                let decimalAmount = NSDecimalNumber(string: mericaFormatter.string(from: bitcoinFormatter.number(from: amount)!))
                switch coinType {
                case .BCH:
                    if (coinDenomination == TLCoinDenomination.bitcoinCash) {
                        satoshis = decimalAmount.multiplying(by: NSDecimalNumber(string: "100000000")).uint64Value
                    } else if (coinDenomination == TLCoinDenomination.bitcoinCash_milliBit) {
                        satoshis = (decimalAmount.multiplying(by: NSDecimalNumber(value: 100000 as UInt64))).uint64Value
                    } else {
                        satoshis = (decimalAmount.multiplying(by: NSDecimalNumber(value: 100 as UInt64))).uint64Value
                    }
                    return TLCoin(uint64:satoshis)
                case .BTC:
                    if (coinDenomination == TLCoinDenomination.bitcoin) {
                        satoshis = decimalAmount.multiplying(by: NSDecimalNumber(string: "100000000")).uint64Value
                    } else if (coinDenomination == TLCoinDenomination.bitcoin_milliBit) {
                        satoshis = (decimalAmount.multiplying(by: NSDecimalNumber(value: 100000 as UInt64))).uint64Value
                    } else {
                        satoshis = (decimalAmount.multiplying(by: NSDecimalNumber(value: 100 as UInt64))).uint64Value
                    }
                    return TLCoin(uint64:satoshis)
                }
            }
        } else {
            return TLCoin.zero()
        }
    }
    
    class func bigIntegerToBitcoinAmountString(_ coin: TLCoin, coinType: TLCoinType, coinDenomination: TLCoinDenomination) -> (String) {
        let bitcoinFormatter = NumberFormatter()
        bitcoinFormatter.numberStyle = .decimal
        switch coinType {
        case .BCH:
            if (coinDenomination == TLCoinDenomination.bitcoinCash) {
                bitcoinFormatter.maximumFractionDigits = 8
                return bitcoinFormatter.string(from: NSNumber(value: coin.bigIntegerToBitcoin() as Double))!
            } else if (coinDenomination == TLCoinDenomination.bitcoinCash_milliBit) {
                bitcoinFormatter.maximumFractionDigits = 5
                return bitcoinFormatter.string(from: NSNumber(value: coin.bigIntegerToMilliBit() as Double))!
            } else {
                bitcoinFormatter.maximumFractionDigits = 2
                return bitcoinFormatter.string(from: NSNumber(value: coin.bigIntegerToBits() as Double))!
            }
        case .BTC:
            if (coinDenomination == TLCoinDenomination.bitcoin) {
                bitcoinFormatter.maximumFractionDigits = 8
                return bitcoinFormatter.string(from: NSNumber(value: coin.bigIntegerToBitcoin() as Double))!
            } else if (coinDenomination == TLCoinDenomination.bitcoin_milliBit) {
                bitcoinFormatter.maximumFractionDigits = 5
                return bitcoinFormatter.string(from: NSNumber(value: coin.bigIntegerToMilliBit() as Double))!
            } else {
                bitcoinFormatter.maximumFractionDigits = 2
                return bitcoinFormatter.string(from: NSNumber(value: coin.bigIntegerToBits() as Double))!
            }
        }
    }
    
    class func coinToProperBitcoinAmountString(_ amount: TLCoin, coinType: TLCoinType, withCode: Bool = false) -> String {
        switch coinType {
        case .BCH:
            if withCode {
                return self.bigIntegerToBitcoinAmountString(amount, coinType: coinType, coinDenomination: TLPreferences.getBitcoinDenomination()) + " " + TLCurrencyFormat.getBitcoinDisplay(coinType)
            } else {
                return self.bigIntegerToBitcoinAmountString(amount, coinType: coinType, coinDenomination: TLPreferences.getBitcoinDenomination())
            }
        case .BTC:
            if withCode {
                return self.bigIntegerToBitcoinAmountString(amount, coinType: coinType, coinDenomination: TLPreferences.getBitcoinCashDenomination()) + " " + TLCurrencyFormat.getBitcoinDisplay(coinType)
            } else {
                return self.bigIntegerToBitcoinAmountString(amount, coinType: coinType, coinDenomination: TLPreferences.getBitcoinCashDenomination())
            }
        }
    }
    
    class func coinToProperFiatAmountString(_ amount: TLCoin, coinType: TLCoinType, withCode: Bool = false) -> String {
        let currency = TLCurrencyFormat.getFiatCurrency()
        if withCode {
            return TLExchangeRate.instance().fiatAmountStringFromBitcoin(currency, amount: amount, coinType: coinType) + " " + TLCurrencyFormat.getFiatCurrency()
        } else {
            return TLExchangeRate.instance().fiatAmountStringFromBitcoin(currency, amount: amount, coinType: coinType)
        }
    }
    
    class func getProperAmount(_ amount: TLCoin, coinType: TLCoinType) -> NSString {
        var balance: NSString? = nil
        if (TLPreferences.isDisplayLocalCurrency()) {
            let currency = TLCurrencyFormat.getProperCurrency(coinType)
            balance = TLExchangeRate.instance().fiatAmountStringFromBitcoin(currency, amount: amount, coinType: coinType) as NSString?
        } else {
            balance = coinToProperBitcoinAmountString(amount, coinType: coinType) as NSString?
        }
        
        balance = String(format: "%@ %@", balance!, getProperCurrency(coinType)) as NSString?
        
        return balance!
    }
    
    class func getCurrencySymbol() -> String {
        return getCurrencySymbolArray().object(at: Int(TLPreferences.getCurrencyIdx()!)!) as! String
    }
    
    class func getFiatCurrency() -> String {
        return getCurrencyArray().object(at: Int(TLPreferences.getCurrencyIdx()!)!) as! String
    }
    
    class func getProperCurrency(_ coinType: TLCoinType) -> String {
        if (TLPreferences.isDisplayLocalCurrency()) {
            return getCurrencyArray().object(at: Int(TLPreferences.getCurrencyIdx()!)!) as! String
        } else {
            return getBitcoinDisplay(coinType)
        }
    }
    
    class func getBitcoinDisplay(_ coinType: TLCoinType) -> String {
        switch coinType {
        case .BCH:
            let coinDenomination = TLPreferences.getBitcoinCashDenomination()
            if (coinDenomination == TLCoinDenomination.bitcoinCash) {
                return getBitcoinDisplayArray(coinType)[0]
            } else if (coinDenomination == TLCoinDenomination.bitcoinCash_milliBit) {
                return getBitcoinDisplayArray(coinType)[1]
            } else {
                return getBitcoinDisplayArray(coinType)[2]
            }
        case .BTC:
            let bitcoinDenomination = TLPreferences.getBitcoinDenomination()
            if (bitcoinDenomination == TLCoinDenomination.bitcoin) {
                return getBitcoinDisplayArray(coinType)[0]
            } else if (bitcoinDenomination == TLCoinDenomination.bitcoin_milliBit) {
                return getBitcoinDisplayArray(coinType)[1]
            } else {
                return getBitcoinDisplayArray(coinType)[2]
            }
        }
    }
    
//    class func getBitcoinDisplayWord(_ coinType: TLCoinType) -> String {
//        switch coinType {
//        case .BCH:
//            let coinDenomination = TLPreferences.getBitcoinDenomination()
//
//            if (coinDenomination == TLCoinDenomination.bitcoinCash) {
//                return getBitcoinDisplayWordArray().object(at: 0) as! String
//            } else if (coinDenomination == TLCoinDenomination.bitcoinCash_milliBit) {
//                return getBitcoinDisplayWordArray().object(at: 1) as! String
//            } else {
//                return getBitcoinDisplayWordArray().object(at: 2) as! String
//            }
//        case .BTC:
//            let bitcoinDenomination = TLPreferences.getBitcoinDenomination()
//
//            if (bitcoinDenomination == TLCoinDenomination.bitcoin) {
//                return getBitcoinDisplayWordArray().object(at: 0) as! String
//            } else if (bitcoinDenomination == TLCoinDenomination.bitcoin_milliBit) {
//                return getBitcoinDisplayWordArray().object(at: 1) as! String
//            } else {
//                return getBitcoinDisplayWordArray().object(at: 2) as! String
//            }
//        }
//    }
    
    class func getBitcoinDisplayArray(_ coinType: TLCoinType) -> Array<String> {
        switch coinType {
        case .BCH:
            return STATIC_MEMBERS._bitcoinCashDisplays
        case .BTC:
            return STATIC_MEMBERS._bitcoinDisplays
        }

    }

//    class func getBitcoinDisplayWordArray() -> NSArray {
//        if (STATIC_MEMBERS._bitcoinDisplayWords == nil) {
//            STATIC_MEMBERS._bitcoinDisplayWords = [
//                "Bitcoin",
//                "MilliBit",
//                "Bits",
//            ]
//        }
//        return STATIC_MEMBERS._bitcoinDisplayWords!
//    }
    
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
