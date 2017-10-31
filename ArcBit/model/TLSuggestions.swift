//
//  TLSuggestions.swift
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
import UIKit

class TLSuggestions {
    fileprivate var suggestions:NSMutableDictionary?
    let VIEW_RECEIVE_SCREEN_GAP_COUNT_TO_SHOW_SUGGESTION_TO_ENABLE_PIN = 13
    
    // use prime numbers to avoid multiple prompts to be displayed at once
    let VIEW_SEND_SCREEN_GAP_COUNT_TO_SHOW_SUGGESTION_TO_BACKUP_WALLET_PASSPHRASE = 3
    let VIEW_SEND_SCREEN_GAP_COUNT_TO_SHOW_WEB_WALLET = 31
    let VIEW_SEND_SCREEN_GAP_COUNT_TO_SHOW_TRY_COLD_WALLET = 37
    let VIEW_SEND_SCREEN_GAP_COUNT_TO_SHOW_RATE_APP_ONCE = 47
    let VIEW_SEND_SCREEN_GAP_COUNT_TO_SHOW_ANDROID_APP_INFO = 59 //temperary
    let VIEW_SEND_SCREEN_GAP_COUNT_TO_SHOW_RATE_APP = 89

    let ENABLE_SUGGESTED_ENABLE_PIN  = "enableSuggestedEnablePin"
    let ENABLE_SUGGESTED_BACKUP_WALLET_PASSPHRASE = "enableSuggestBackUpWalletPassphrase"
    let ENABLE_SUGGESTED_DONT_MANAGE_INDIVIDUAL_ACCOUNT_ADDRESSES  = "enableSuggestDontManageIndividualAccountAddresses"
    let ENABLE_SUGGESTED_DONT_MANAGE_INDIVIDUAL_ACCOUNT_PRIVATE_KEYS  = "enableSuggestDontManageIndividualAccountPrivateKeys"
    let ENABLE_SUGGESTED_DONT_ADD_falseRMAL_ADDRESS_TO_ADDRESS_BOOK  = "enableSuggestDontAddNormalAddressToAddressBook"
    let ENABLE_SHOW_MANUALLY_SCAN_TRANSACTION_FOR_STEALTH_TX_INFO  = "enableShowManuallyScanTransactionForStealthTxInfo"
    let ENABLE_SHOW_STEALTH_PAYMENT_DELAY_INFO  = "enableShowStealthPaymentDelayInfo"
    let ENABLE_SHOW_STEALTH_PAYMENT_NOTE  = "enableShowStealthPaymentNote"

    struct STATIC_MEMBERS {
        static var instance:TLSuggestions?
    }
    
    class func instance() -> (TLSuggestions) {
        if(STATIC_MEMBERS.instance == nil) {
            STATIC_MEMBERS.instance = TLSuggestions()
        }
        return STATIC_MEMBERS.instance!
    }
    
    init() {
        suggestions = NSMutableDictionary(dictionary:TLPreferences.getSuggestionsDict() ?? NSDictionary())
    }
    
    //Deprecated, just use TLPreferences, see method disabledShowFeeExplanationInfo/setDisableShowFeeExplanationInfo
    func enabledAllSuggestions() -> () {
        suggestions = NSMutableDictionary(dictionary:[
            ENABLE_SUGGESTED_ENABLE_PIN : true,
            ENABLE_SUGGESTED_BACKUP_WALLET_PASSPHRASE : true,
            ENABLE_SUGGESTED_DONT_MANAGE_INDIVIDUAL_ACCOUNT_ADDRESSES : true,
            ENABLE_SUGGESTED_DONT_MANAGE_INDIVIDUAL_ACCOUNT_PRIVATE_KEYS : true,
            ENABLE_SUGGESTED_DONT_ADD_falseRMAL_ADDRESS_TO_ADDRESS_BOOK : true,
            ENABLE_SHOW_MANUALLY_SCAN_TRANSACTION_FOR_STEALTH_TX_INFO : true,
            ENABLE_SHOW_STEALTH_PAYMENT_DELAY_INFO : true,
            ])
        TLPreferences.setSuggestionsDict(suggestions!)
    }

    //should have done negation of enabled as default for suggestions when first built app, instead now have to return true for any new suggestions
    func enabledShowStealthPaymentNote() -> (Bool) {
        if (suggestions!.object(forKey: ENABLE_SHOW_STEALTH_PAYMENT_NOTE) == nil) {
            return true;
        }
        return suggestions!.object(forKey: ENABLE_SHOW_STEALTH_PAYMENT_NOTE) as! Bool
    }
    
    func setEnableShowStealthPaymentNote(_ enabled:Bool) -> (){
        suggestions!.setObject(enabled, forKey:ENABLE_SHOW_STEALTH_PAYMENT_NOTE as NSCopying)
        TLPreferences.setSuggestionsDict(suggestions!)
    }
    
    func enabledShowStealthPaymentDelayInfo() -> (Bool){
        return suggestions!.object(forKey: ENABLE_SHOW_STEALTH_PAYMENT_DELAY_INFO) as! Bool
    }
    
    func setEnableShowStealthPaymentDelayInfo(_ enabled:Bool) -> (){
        suggestions!.setObject(enabled, forKey:ENABLE_SHOW_STEALTH_PAYMENT_DELAY_INFO as NSCopying)
        TLPreferences.setSuggestionsDict(suggestions!)
    }
    
    func enabledShowManuallyScanTransactionForStealthTxInfo() -> (Bool){
        return suggestions!.object(forKey: ENABLE_SHOW_MANUALLY_SCAN_TRANSACTION_FOR_STEALTH_TX_INFO) as! Bool
    }
    
    func setEnabledShowManuallyScanTransactionForStealthTxInfo(_ enabled:Bool) -> (){
        suggestions!.setObject(enabled, forKey:ENABLE_SHOW_MANUALLY_SCAN_TRANSACTION_FOR_STEALTH_TX_INFO as NSCopying)
        TLPreferences.setSuggestionsDict(suggestions!)
    }
    
    func conditionToPromptRateAppSatisfied() -> (Bool) {
        let userAnalyticsDict = NSMutableDictionary(dictionary:TLPreferences.getAnalyticsDict() ?? NSDictionary())
        let viewSendScreenCount = userAnalyticsDict.object(forKey: TLNotificationEvents.EVENT_VIEW_SEND_SCREEN()) as! Int? ?? 0
        if !TLPreferences.disabledPromptRateApp() &&
            viewSendScreenCount > 0 &&
            ((!TLPreferences.hasRatedOnce() && viewSendScreenCount % VIEW_SEND_SCREEN_GAP_COUNT_TO_SHOW_RATE_APP_ONCE == 0) ||
            (TLPreferences.hasRatedOnce() && viewSendScreenCount % VIEW_SEND_SCREEN_GAP_COUNT_TO_SHOW_RATE_APP == 0)) {
                return true
        } else {
            return false
        }
    }
    
    func conditionToPromptShowWebWallet() -> (Bool) {
        let userAnalyticsDict = NSMutableDictionary(dictionary:TLPreferences.getAnalyticsDict() ?? NSDictionary())
        let viewSendScreenCount = userAnalyticsDict.object(forKey: TLNotificationEvents.EVENT_VIEW_SEND_SCREEN()) as! Int? ?? 0
        if !TLPreferences.disabledPromptShowWebWallet() &&
            viewSendScreenCount > 0 &&
            viewSendScreenCount % VIEW_SEND_SCREEN_GAP_COUNT_TO_SHOW_WEB_WALLET == 0 {
            return true
        } else {
            return false
        }
    }
    
    func conditionToPromptTryColdWallet() -> (Bool) {
        let userAnalyticsDict = NSMutableDictionary(dictionary:TLPreferences.getAnalyticsDict() ?? NSDictionary())
        let viewSendScreenCount = userAnalyticsDict.object(forKey: TLNotificationEvents.EVENT_VIEW_SEND_SCREEN()) as! Int? ?? 0
        if TLPreferences.getInstallDate() == nil {
            return false
        }
        if !TLPreferences.disabledPromptShowTryColdWallet() &&
            !TLPreferences.enabledColdWallet() &&
            TLUtils.daysSinceDate(TLPreferences.getInstallDate()!) > 60 && // 60 days
            viewSendScreenCount > 0 &&
            viewSendScreenCount % VIEW_SEND_SCREEN_GAP_COUNT_TO_SHOW_TRY_COLD_WALLET == 0 {
            return true
        } else {
            return false
        }
    }

// can rid
//    func conditionToPromptCheckoutAndroidWallet() -> (Bool) {
//        let userAnalyticsDict = NSMutableDictionary(dictionary:TLPreferences.getAnalyticsDict() ?? NSDictionary())
//        let viewSendScreenCount = userAnalyticsDict.object(forKey: TLNotificationEvents.EVENT_VIEW_SEND_SCREEN()) as! Int? ?? 0
//        if !TLPreferences.disabledPromptCheckoutAndroidWallet() &&
//            viewSendScreenCount > 0 &&
//            viewSendScreenCount % VIEW_SEND_SCREEN_GAP_COUNT_TO_SHOW_ANDROID_APP_INFO == 0 {
//            return true
//        } else {
//            return false
//        }
//    }
    
    fileprivate func setEnabledSuggestedEnablePin(_ enabled:Bool) -> (){
        suggestions!.setObject(enabled, forKey:ENABLE_SUGGESTED_ENABLE_PIN as NSCopying)
        TLPreferences.setSuggestionsDict(suggestions!)
    }
    
    fileprivate func enabledSuggestedEnablePin() -> (Bool) {
        return suggestions!.object(forKey: ENABLE_SUGGESTED_ENABLE_PIN) as! Bool
    }
    
    func conditionToPromptToSuggestEnablePinSatisfied() -> (Bool) {
        let userAnalyticsDict = NSMutableDictionary(dictionary:TLPreferences.getAnalyticsDict() ?? NSDictionary())
        let viewReceiveScreenCount = (userAnalyticsDict.object(forKey: TLNotificationEvents.EVENT_VIEW_RECEIVE_SCREEN()) as! Int? ?? 0)
        if (enabledSuggestedEnablePin() &&
            viewReceiveScreenCount > 0 &&
            viewReceiveScreenCount % VIEW_RECEIVE_SCREEN_GAP_COUNT_TO_SHOW_SUGGESTION_TO_ENABLE_PIN == 0) {
                return true
        } else {
            return false
        }
    }
    
    func promptToSuggestEnablePin(_ vc:UIViewController) -> () {
        
        UIAlertController.showAlert(in: vc,
            withTitle: TLDisplayStrings.ENABLE_PIN_CODE_STRING(),
            message: TLDisplayStrings.ENABLE_PIN_CODE_TO_BETTER_SECURE_WALLET_STRING(),
            cancelButtonTitle: TLDisplayStrings.REMIND_ME_LATER_STRING(),
            destructiveButtonTitle: nil,
            otherButtonTitles: [TLDisplayStrings.DONT_REMIND_ME_STRING()],
            
            tap: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView?.firstOtherButtonIndex) {
                    self.setEnabledSuggestedEnablePin(false)
                } else if (buttonIndex == alertView?.cancelButtonIndex) {
                }
        })
    }
    
    fileprivate func setEnabledSuggestedBackUpWalletPassphrase(_ enabled:Bool) -> (){
        suggestions!.setObject(enabled, forKey:ENABLE_SUGGESTED_BACKUP_WALLET_PASSPHRASE as NSCopying)
        TLPreferences.setSuggestionsDict(suggestions!)
    }
    
    fileprivate func enabledSuggestedBackUpWalletPassphrase() -> (Bool) {
        return (suggestions!.object(forKey: ENABLE_SUGGESTED_BACKUP_WALLET_PASSPHRASE) as! Bool)
    }
    
    func conditionToPromptToSuggestedBackUpWalletPassphraseSatisfied() -> (Bool) {
        let userAnalyticsDict = NSMutableDictionary(dictionary:TLPreferences.getAnalyticsDict() ?? NSDictionary())
        let viewSendScreenCount = userAnalyticsDict.object(forKey: TLNotificationEvents.EVENT_VIEW_SEND_SCREEN()) as! Int? ?? 0
        if (enabledSuggestedBackUpWalletPassphrase() &&
            viewSendScreenCount > 0 &&
            viewSendScreenCount % VIEW_SEND_SCREEN_GAP_COUNT_TO_SHOW_SUGGESTION_TO_BACKUP_WALLET_PASSPHRASE == 0 &&
            !TLPreferences.getEnableBackupWithiCloud()) {
                return true
        } else {
            return false
        }
    }
    
    func promptToSuggestBackUpWalletPassphrase(_ vc:UIViewController) -> () {
        UIAlertController.showAlert(in: vc, withTitle: TLDisplayStrings.BACK_UP_WALLET_STRING(),
            message: TLDisplayStrings.SUGGEST_BACK_UP_WALLET_PASSPHRASE_DESC_STRING(),
            cancelButtonTitle: TLDisplayStrings.REMIND_ME_LATER_STRING(),
            destructiveButtonTitle: nil,
            otherButtonTitles: [TLDisplayStrings.DONT_REMIND_ME_STRING()],
            tap: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView?.firstOtherButtonIndex) {
                    self.setEnabledSuggestedBackUpWalletPassphrase(false)
                } else if (buttonIndex == alertView?.cancelButtonIndex) {
                }
        })}
    
    
    func setEnableSuggestDontManageIndividualAccountAddress(_ enabled:Bool) -> () {
        suggestions!.setObject(enabled, forKey:ENABLE_SUGGESTED_DONT_MANAGE_INDIVIDUAL_ACCOUNT_ADDRESSES as NSCopying)
        TLPreferences.setSuggestionsDict(suggestions!)
    }
    
    func enabledSuggestDontManageIndividualAccountAddress() -> (Bool) {
        return suggestions!.object(forKey: ENABLE_SUGGESTED_DONT_MANAGE_INDIVIDUAL_ACCOUNT_ADDRESSES) as! Bool
    }
    
    
    func setEnableSuggestDontManageIndividualAccountPrivateKeys(_ enabled:Bool) -> () {
        suggestions!.setObject(enabled, forKey:ENABLE_SUGGESTED_DONT_MANAGE_INDIVIDUAL_ACCOUNT_PRIVATE_KEYS as NSCopying)
        TLPreferences.setSuggestionsDict(suggestions!)
    }
    
    func enabledSuggestDontManageIndividualAccountPrivateKeys() -> (Bool) {
        return suggestions!.object(forKey: ENABLE_SUGGESTED_DONT_MANAGE_INDIVIDUAL_ACCOUNT_PRIVATE_KEYS) as! Bool
    }
    
    func setEnableSuggestDontAddNormalAddressToAddressBook(_ enabled:Bool) -> () {
        suggestions!.setObject(enabled, forKey:ENABLE_SUGGESTED_DONT_ADD_falseRMAL_ADDRESS_TO_ADDRESS_BOOK as NSCopying)
        TLPreferences.setSuggestionsDict(suggestions!)
    }
    
    func enabledSuggestDontAddNormalAddressToAddressBook() -> (Bool) {
        return suggestions!.object(forKey: ENABLE_SUGGESTED_DONT_ADD_falseRMAL_ADDRESS_TO_ADDRESS_BOOK) as! Bool
    }
}

