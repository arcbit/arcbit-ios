//
//  TLHelpDoc.swift
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

class TLHelpDoc {
    struct STATIC_MEMBERS {
        static var _actionEventToInstructionStepsTitleArray: NSArray?
        static var _advanceActionInstructionStepsArray: NSArray?
        static var _actionEventToInstructionsTitleDict: NSDictionary?
        static var _explanationArray: NSArray?
        static var _advanceExplanationArray: NSArray?
        static var _howToDoAdvanceAchievementsArray: NSArray?
        static var _eventsArray: NSArray?
        
        static let FAQ_TRANSACTION_CONFIRMATIONS = TLDisplayStrings.TRANSACTION_CONFIRMATIONS_STRING()
        static let FAQ_HD_WALLET = TLDisplayStrings.HIERARCHICAL_DETERMINISTIC_WALLET_STRING()
        static let FAQ_STEALTH_ADDRESS = TLDisplayStrings.REUSABLE_ADDRESSES_STRING()
        
        static let ACCOUNT_ACTION_CREATE_NEW_ACCOUNT = TLDisplayStrings.CREATE_NEW_ACCOUNT_STRING()
        static let ACCOUNT_ACTION_IMPORT_COLD_WALLET_ACCOUNT = TLDisplayStrings.IMPORT_COLD_WALLET_ACCOUNT_STRING()
        static let ACCOUNT_ACTION_IMPORT_ACCOUNT = TLDisplayStrings.IMPORT_ACCOUNT_STRING()
        static let ACCOUNT_ACTION_IMPORT_WATCH_ONLY_ACCOUNT = TLDisplayStrings.IMPORT_WATCH_ONLY_ACCOUNT_STRING()
        static let ACCOUNT_ACTION_IMPORT_PRIVATE_KEY = TLDisplayStrings.IMPORT_PRIVATE_KEY_STRING()
        static let ACCOUNT_ACTION_IMPORT_WATCH_ONLY_ADDRESS = TLDisplayStrings.IMPORT_WATCH_ONLY_ADDRESS_STRING()
        
        static let ACTION_SEND_PAYMENT = TLDisplayStrings.SEND_PAYMENT_STRING()
        static let ACTION_RECEIVE_PAYMENT = TLDisplayStrings.RECEIVE_PAYMENT_STRING()
        static let ACTION_RECEIVE_PAYMENT_FROM_STEALTH_ADDRESS = TLDisplayStrings.RECEIVE_PAYMENT_FROM_REUSABLE_ADDRESS_STRING()
        static let ACTION_VIEW_HISTORY = TLDisplayStrings.VIEW_HISTORY_STRING()
        static let ACTION_CREATE_NEW_ACCOUNT = TLDisplayStrings.CREATE_NEW_ACCOUNT_STRING()
        static let ACTION_EDIT_ACCOUNT_NAME = TLDisplayStrings.EDIT_ACCOUNT_NAME_STRING()
        static let ACTION_ARCHIVE_ACCOUNT = TLDisplayStrings.ARCHIVE_ACCOUNT_STRING()
        static let ACTION_ENABLE_PIN_CODE = TLDisplayStrings.ENABLE_PIN_CODE_STRING()
        static let ACTION_BACKUP_PASSPHRASE = TLDisplayStrings.BACK_UP_PASSPHRASE_STRING()
        static let ACTION_RESTORE_WALLET = TLDisplayStrings.START_RESTORE_ANOTHER_WALLET_STRING()
        static let ACTION_ADD_TO_ADDRESS_BOOK = TLDisplayStrings.ADD_CONTACTS_ENTRY_STRING()
        static let ACTION_EDIT_ENTRY_ADDRESS_BOOK = TLDisplayStrings.EDIT_CONTACTS_ENTRY_STRING()
        static let ACTION_DELETE_ENTRY_ADDRESS_BOOK = TLDisplayStrings.DELETE_CONTACTS_ENTRY_STRING()
        static let ACTION_SEND_TO_ADDRESS_IN_ADDRESS_BOOK = TLDisplayStrings.SEND_TO_ADDRESS_IN_CONTACTS_STRING()
        static let ACTION_TAG_TRANSACTION = TLDisplayStrings.LABEL_TRANSACTION_STRING()
        static let ACTION_TOGGLE_AUTOMATIC_TX_FEE = TLDisplayStrings.TOGGLE_AUTOMATIC_TRANSACTION_FEE_STRING()
        static let ACTION_CHANGE_AUTOMATIC_TX_FEE = TLDisplayStrings.CHANGE_AUTOMATIC_TRANSACTION_FEE_STRING()
        static let ACTION_VIEW_ACCOUNT_ADDRESSES = TLDisplayStrings.VIEW_ACCOUNT_ADDRESSES_STRING()
        static let ACTION_VIEW_ACCOUNT_ADDRESS_IN_WEB = TLDisplayStrings.VIEW_ACCOUNT_ADDRESS_IN_WEB_STRING()
        static let ACTION_VIEW_TRANSACTION_IN_WEB = TLDisplayStrings.VIEW_TRANSACTION_IN_WEB_STRING()
        static let ACTION_ENABLE_ADVANCE_MODE = TLDisplayStrings.ENABLE_ADVANCED_MODE_STRING()
        
        static let ACTION_IMPORT_ACCOUNT = TLDisplayStrings.IMPORT_ACCOUNT_STRING()
        static let ACTION_IMPORT_WATCH_ONLY_ACCOUNT = TLDisplayStrings.IMPORT_WATCH_ONLY_ACCOUNT_STRING()
        static let ACTION_IMPORT_PRIVATE_KEY = TLDisplayStrings.IMPORT_PRIVATE_ENCRYPTED_KEY_STRING()
        static let ACTION_IMPORT_WATCH_ONLY_ADDRESS = TLDisplayStrings.IMPORT_WATCH_ONLY_ADDRESS_STRING()
        static let ACTION_CHANGE_BLOCKEXPLORER_TYPE = TLDisplayStrings.CHANGE_BLOCKEXPLORER_TYPE_STRING()
        static let ACTION_VIEW_EXTENDED_PUBLIC_KEY = TLDisplayStrings.VIEW_ACCOUNT_PUBLIC_KEY_STRING()
        static let ACTION_VIEW_EXTENDED_PRIVATE_KEY = TLDisplayStrings.VIEW_ACCOUNT_PRIVATE_KEY_STRING()
        static let ACTION_VIEW_ACCOUNT_PRIVATE_KEY = TLDisplayStrings.VIEW_PRIVATE_KEY_STRING()
        static let ACTION_VIEW_ACCOUNT_ADDRESS = TLDisplayStrings.VIEW_ACCOUNT_ADDRESS_STRING()
        
    }
    
    class func getBasicActionInstructionStepsArray(_ idx: Int) -> NSArray {
        if (STATIC_MEMBERS._actionEventToInstructionStepsTitleArray == nil) {
            STATIC_MEMBERS._actionEventToInstructionStepsTitleArray = [
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_SEND_STRING(),
                    TLDisplayStrings.FILL_ADDRESS_FIELD_STRING(),
                    TLDisplayStrings.INPUT_AMOUNT_STRING(),
                    TLDisplayStrings.CLICK_REVIEW_PAYMENT_STRING(),
                    TLDisplayStrings.CLICK_SEND_STRING(),
                ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_RECEIVE_STRING(),
                    TLDisplayStrings.CLICK_THE_BUTTON_WITH_THE_ARROW_STRING(),
                    TLDisplayStrings.SELECT_AND_CLICK_AN_ACCOUNT_TO_RECEIVE_FROM_STRING(),
                    TLDisplayStrings.HAVE_SENDER_SCAN_QR_CODE_STRING(),
                    TLDisplayStrings.HAVE_SENDER_SEND_YOU_PAYMENT_STRING(),
                ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_RECEIVE_STRING(),
                    TLDisplayStrings.CLICK_THE_BUTTON_WITH_THE_ARROW_STRING(),
                    TLDisplayStrings.SELECT_AND_CLICK_AN_ACCOUNT_TO_RECEIVE_FROM_STRING(),
                    TLDisplayStrings.HAVE_SENDER_SCAN_QR_CODE_STRING(),
                    TLDisplayStrings.SWIPE_UNTIL_YOU_SEE_THE_REUSABLE_ADDRESS_STRING(),
                    TLDisplayStrings.HAVE_SENDER_SEND_YOU_PAYMENT_STRING(),
                ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_HISTORY_STRING(),
                    TLDisplayStrings.CLICK_THE_BUTTON_WITH_THE_ARROW_STRING(),
                    TLDisplayStrings.SELECT_AND_CLICK_AN_ACCOUNT_TO_VIEW_TRANSACTION_HISTORY_STRING(),
                ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_ACCOUNTS_STRING(),
                    TLDisplayStrings.SCROLL_DOWN_TO_THE_SECTION_ACCOUNT_ACTIONS_STRING(),
                    TLDisplayStrings.CLICK_CREATE_NEW_ACCOUNT_STRING(),
                ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_ACCOUNTS_STRING(),
                    TLDisplayStrings.SELECT_AND_CLICK_AN_ACCOUNT_STRING(),
                    TLDisplayStrings.CLICK_EDIT_ACCOUNT_NAME_STRING(),
                    TLDisplayStrings.INPUT_NEW_ACCOUNT_NAME_STRING(),
                ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_ACCOUNTS_STRING(),
                    TLDisplayStrings.SELECT_AND_CLICK_AN_ACCOUNT_STRING(),
                    TLDisplayStrings.CLICK_ARCHIVE_ACCOUNT_STRING(),
                ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_SETTINGS_STRING(),
                    TLDisplayStrings.CLICK_ENABLE_PIN_CODE_STRING(),
                    TLDisplayStrings.ENTER_PIN_CODE_STRING(),
                    TLDisplayStrings.CONFIRM_PIN_CODE_STRING(),
                ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_SETTINGS_STRING(),
                    TLDisplayStrings.CLICK_SHOW_BACKUP_PASSPHRASE_STRING(),
                    TLDisplayStrings.WRITE_DOWN_BACKUP_PASSPHRASE_STRING(),
                ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_SETTINGS_STRING(),
                    TLDisplayStrings.CLICK_RESTORE_WALLET_STRING(),
                    TLDisplayStrings.ENTER_BACKUP_PASSPHRASE_STRING(),
                    TLDisplayStrings.CLICK_DONE_STRING(),
                    TLDisplayStrings.CLICK_RESTORE_STRING(),
                    ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_SEND_STRING(),
                    TLDisplayStrings.CLICK_THE_CONTACTS_BUTTON_STRING(),
                    TLDisplayStrings.CLICK_THE_PLUS_BUTTON_AT_THE_TOP_RIGHT_STRING(),
                    TLDisplayStrings.INPUT_A_BITCOIN_ADDRESS_STRING(),
                    TLDisplayStrings.INPUT_A_LABEL_STRING(),
                    ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_SEND_STRING(),
                    TLDisplayStrings.SWIPE_RIGHT_ON_AN_ADDRESS_STRING(),
                    TLDisplayStrings.CLICK_EDIT_STRING(),
                    TLDisplayStrings.INPUT_A_NEW_LABEL_STRING(),
                    ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_SEND_STRING(),
                    TLDisplayStrings.CLICK_THE_CONTACTS_BUTTON_STRING(),
                    TLDisplayStrings.SWIPE_RIGHT_ON_AN_ADDRESS_STRING(),
                    TLDisplayStrings.CLICK_DELETE_STRING(),
                    ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_SEND_STRING(),
                    TLDisplayStrings.CLICK_THE_CONTACTS_BUTTON_STRING(),
                    TLDisplayStrings.CLICK_AN_ADDRESS_STRING(),
                    ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_HISTORY_STRING(),
                    TLDisplayStrings.SELECT_AND_CLICK_A_TRANSACTION_STRING(),
                    TLDisplayStrings.CLICK_LABEL_TRANSACTION_STRING(),
                    TLDisplayStrings.INPUT_LABEL_STRING(),
                    ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_SETTINGS_STRING(),
                    TLDisplayStrings.TOGGLE_ENABLE_TRANSACTION_FEE_STRING(),
                    ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_SETTINGS_STRING(),
                    TLDisplayStrings.ENABLE_TRANSACTION_FEE_STRING(),
                    TLDisplayStrings.CLICK_SET_TRANSACTION_FEE_STRING(),
                    TLDisplayStrings.INPUT_TRANSACTION_FEE_IN_BITCOINS_STRING(),
                    ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_ACCOUNTS_STRING(),
                    TLDisplayStrings.SELECT_AND_CLICK_AN_ACCOUNT_STRING(),
                    TLDisplayStrings.CLICK_VIEW_ADDRESSES_STRING(),
                    ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_ACCOUNTS_STRING(),
                    TLDisplayStrings.SELECT_AND_CLICK_AN_ACCOUNT_STRING(),
                    TLDisplayStrings.CLICK_VIEW_ADDRESSES_STRING(),
                    TLDisplayStrings.SELECT_AND_CLICK_AN_ADDRESS_STRING(),
                    TLDisplayStrings.CLICK_VIEW_ADDRESS_QR_CODE_STRING(),
                    ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_HISTORY_STRING(),
                    TLDisplayStrings.SELECT_AND_CLICK_A_TRANSACTION_STRING(),
                    TLDisplayStrings.CLICK_VIEW_IN_WEB_STRING(),
                    ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_ACCOUNTS_STRING(),
                    TLDisplayStrings.SELECT_AND_CLICK_AN_ACCOUNT_STRING(),
                    TLDisplayStrings.CLICK_VIEW_ADDRESSES_STRING(),
                    TLDisplayStrings.SELECT_AND_CLICK_AN_ADDRESS_STRING(),
                    TLDisplayStrings.CLICK_VIEW_IN_WEB_STRING(),
                    ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_SETTINGS_STRING(),
                    TLDisplayStrings.CLICK_ADVANCED_SETTINGS_STRING(),
                    TLDisplayStrings.TOGGLE_ENABLE_ADVANCED_MODE_STRING(),
                    ],
            ]
        }
        return STATIC_MEMBERS._actionEventToInstructionStepsTitleArray!.object(at: idx) as! NSArray
        
    }
    
    
    class func getAdvanceActionInstructionStepsArray(_ idx: Int) -> NSArray {
        if (STATIC_MEMBERS._advanceActionInstructionStepsArray == nil) {
            STATIC_MEMBERS._advanceActionInstructionStepsArray = [
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_ACCOUNTS_STRING(),
                    TLDisplayStrings.SCROLL_DOWN_TO_THE_SECTION_ACCOUNT_ACTIONS_STRING(),
                    TLDisplayStrings.CLICK_IMPORT_ACCOUNT_STRING(),
                ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_ACCOUNTS_STRING(),
                    TLDisplayStrings.SCROLL_DOWN_TO_THE_SECTION_ACCOUNT_ACTIONS_STRING(),
                    TLDisplayStrings.CLICK_IMPORT_WATCH_ONLY_ACCOUNT_STRING(),
                ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_ACCOUNTS_STRING(),
                    TLDisplayStrings.SCROLL_DOWN_TO_THE_SECTION_ACCOUNT_ACTIONS_STRING(),
                    TLDisplayStrings.CLICK_IMPORT_PRIVATE_KEY_STRING(),
                ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_ACCOUNTS_STRING(),
                    TLDisplayStrings.SCROLL_DOWN_TO_THE_SECTION_ACCOUNT_ACTIONS_STRING(),
                    TLDisplayStrings.CLICK_IMPORT_WATCH_ONLY_ADDRESS_STRING(),
                ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_SETTINGS_STRING(),
                    TLDisplayStrings.CLICK_ADVANCED_SETTINGS_STRING(),
                    TLDisplayStrings.CLICK_BLOCKEXPLORER_API_TYPE_STRING(),
                    TLDisplayStrings.SELECT_AND_CLICK_A_BLOCKEXPLORER_API_STRING(),
                    TLDisplayStrings.QUIT_AND_RE_ENTER_APP_STRING(),
                ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_ACCOUNTS_STRING(),
                    TLDisplayStrings.SELECT_AND_CLICK_AN_ACCOUNT_STRING(),
                    TLDisplayStrings.CLICK_VIEW_ACCOUNT_PUBLIC_KEY_QR_CODE_STRING(),
                ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_ACCOUNTS_STRING(),
                    TLDisplayStrings.SELECT_AND_CLICK_AN_ACCOUNT_STRING(),
                    TLDisplayStrings.CLICK_VIEW_ACCOUNT_PRIVATE_KEY_QR_CODE_STRING(),
                ],
                [
                    TLDisplayStrings.GO_TO_THE_SIDE_MENU_STRING(),
                    TLDisplayStrings.CLICK_ACCOUNTS_STRING(),
                    TLDisplayStrings.SELECT_AND_CLICK_AN_ACCOUNT_STRING(),
                    TLDisplayStrings.CLICK_VIEW_ADDRESSES_STRING(),
                    TLDisplayStrings.SELECT_AND_CLICK_AN_ADDRESS_STRING(),
                    TLDisplayStrings.CLICK_VIEW_PRIVATE_KEY_QR_CODE_STRING(),
                ],
            ]
        }
        return STATIC_MEMBERS._advanceActionInstructionStepsArray!.object(at: idx) as! NSArray
    }
    
    class func getActionEventToHowToActionTitleDict() -> NSDictionary {
        if (STATIC_MEMBERS._actionEventToInstructionsTitleDict == nil) {
            STATIC_MEMBERS._actionEventToInstructionsTitleDict = [
                TLNotificationEvents.EVENT_SEND_PAYMENT(): STATIC_MEMBERS.ACTION_SEND_PAYMENT,
                TLNotificationEvents.EVENT_RECEIVE_PAYMENT(): STATIC_MEMBERS.ACTION_RECEIVE_PAYMENT,
                TLNotificationEvents.EVENT_RECEIVE_PAYMENT_FROM_STEALTH_ADDRESS(): STATIC_MEMBERS.ACTION_RECEIVE_PAYMENT_FROM_STEALTH_ADDRESS,
                TLNotificationEvents.EVENT_VIEW_HISTORY(): STATIC_MEMBERS.ACTION_VIEW_HISTORY,
                TLNotificationEvents.EVENT_CREATE_NEW_ACCOUNT(): STATIC_MEMBERS.ACTION_CREATE_NEW_ACCOUNT,
                TLNotificationEvents.EVENT_EDIT_ACCOUNT_NAME(): STATIC_MEMBERS.ACTION_EDIT_ACCOUNT_NAME,
                TLNotificationEvents.EVENT_ARCHIVE_ACCOUNT(): STATIC_MEMBERS.ACTION_ARCHIVE_ACCOUNT,
                TLNotificationEvents.EVENT_ENABLE_PIN_CODE(): STATIC_MEMBERS.ACTION_ENABLE_PIN_CODE,
                TLNotificationEvents.EVENT_BACKUP_PASSPHRASE(): STATIC_MEMBERS.ACTION_BACKUP_PASSPHRASE,
                TLNotificationEvents.EVENT_RESTORE_WALLET(): STATIC_MEMBERS.ACTION_RESTORE_WALLET,
                TLNotificationEvents.EVENT_ADD_TO_ADDRESS_BOOK(): STATIC_MEMBERS.ACTION_ADD_TO_ADDRESS_BOOK,
                TLNotificationEvents.EVENT_EDIT_ENTRY_ADDRESS_BOOK(): STATIC_MEMBERS.ACTION_EDIT_ENTRY_ADDRESS_BOOK,
                TLNotificationEvents.EVENT_DELETE_ENTRY_ADDRESS_BOOK(): STATIC_MEMBERS.ACTION_DELETE_ENTRY_ADDRESS_BOOK,
                TLNotificationEvents.EVENT_SEND_TO_ADDRESS_IN_ADDRESS_BOOK(): STATIC_MEMBERS.ACTION_SEND_TO_ADDRESS_IN_ADDRESS_BOOK,
                TLNotificationEvents.EVENT_TAG_TRANSACTION(): STATIC_MEMBERS.ACTION_TAG_TRANSACTION,
                TLNotificationEvents.EVENT_TOGGLE_AUTOMATIC_TX_FEE(): STATIC_MEMBERS.ACTION_TOGGLE_AUTOMATIC_TX_FEE,
                TLNotificationEvents.EVENT_CHANGE_AUTOMATIC_TX_FEE(): STATIC_MEMBERS.ACTION_CHANGE_AUTOMATIC_TX_FEE,
                TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESSES(): STATIC_MEMBERS.ACTION_VIEW_ACCOUNT_ADDRESSES,
                TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESS(): STATIC_MEMBERS.ACTION_VIEW_ACCOUNT_ADDRESS,
                TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESS_IN_WEB(): STATIC_MEMBERS.ACTION_VIEW_ACCOUNT_ADDRESS_IN_WEB,
                TLNotificationEvents.EVENT_VIEW_TRANSACTION_IN_WEB(): STATIC_MEMBERS.ACTION_VIEW_TRANSACTION_IN_WEB,
                TLNotificationEvents.EVENT_ENABLE_ADVANCE_MODE(): STATIC_MEMBERS.ACTION_ENABLE_ADVANCE_MODE,
                
                TLNotificationEvents.EVENT_IMPORT_ACCOUNT(): STATIC_MEMBERS.ACTION_IMPORT_ACCOUNT,
                TLNotificationEvents.EVENT_IMPORT_WATCH_ONLY_ACCOUNT(): STATIC_MEMBERS.ACTION_IMPORT_WATCH_ONLY_ACCOUNT,
                TLNotificationEvents.EVENT_IMPORT_PRIVATE_KEY(): STATIC_MEMBERS.ACTION_IMPORT_PRIVATE_KEY,
                TLNotificationEvents.EVENT_IMPORT_WATCH_ONLY_ADDRESS(): STATIC_MEMBERS.ACTION_IMPORT_WATCH_ONLY_ADDRESS,
                TLNotificationEvents.EVENT_CHANGE_BLOCKEXPLORER_TYPE(): STATIC_MEMBERS.ACTION_CHANGE_BLOCKEXPLORER_TYPE,
                TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY(): STATIC_MEMBERS.ACTION_VIEW_EXTENDED_PUBLIC_KEY,
                TLNotificationEvents.EVENT_VIEW_EXTENDED_PRIVATE_KEY(): STATIC_MEMBERS.ACTION_VIEW_EXTENDED_PRIVATE_KEY,
                TLNotificationEvents.EVENT_VIEW_ACCOUNT_PRIVATE_KEY(): STATIC_MEMBERS.ACTION_VIEW_ACCOUNT_PRIVATE_KEY,
            ]
        }
        return STATIC_MEMBERS._actionEventToInstructionsTitleDict!
    }
    
    class func getAccountActionsArray() -> NSArray {
        if (TLPreferences.enabledAdvancedMode()) {
            return getAdvanceAccountActionsArray()
        } else {
            return getBasicAccountActionsArray()
        }
    }
    
    class func getBasicAccountActionsArray() -> NSArray {
        var accountActionsArray: NSArray?
        if TLPreferences.enabledColdWallet() {
            accountActionsArray = [
                STATIC_MEMBERS.ACCOUNT_ACTION_CREATE_NEW_ACCOUNT,
                STATIC_MEMBERS.ACCOUNT_ACTION_IMPORT_COLD_WALLET_ACCOUNT
            ]
        } else {
            accountActionsArray = [
                STATIC_MEMBERS.ACCOUNT_ACTION_CREATE_NEW_ACCOUNT
            ]
        }
        return accountActionsArray!
    }
    
    class func getAdvanceAccountActionsArray() -> NSArray {
        var accountActionsArray: NSArray?
        if TLPreferences.enabledColdWallet() {
            accountActionsArray = [
                STATIC_MEMBERS.ACCOUNT_ACTION_CREATE_NEW_ACCOUNT,
                STATIC_MEMBERS.ACCOUNT_ACTION_IMPORT_COLD_WALLET_ACCOUNT,
                STATIC_MEMBERS.ACCOUNT_ACTION_IMPORT_ACCOUNT,
                STATIC_MEMBERS.ACCOUNT_ACTION_IMPORT_WATCH_ONLY_ACCOUNT,
                STATIC_MEMBERS.ACCOUNT_ACTION_IMPORT_PRIVATE_KEY,
                STATIC_MEMBERS.ACCOUNT_ACTION_IMPORT_WATCH_ONLY_ADDRESS
            ]
        } else {
            accountActionsArray = [
                STATIC_MEMBERS.ACCOUNT_ACTION_CREATE_NEW_ACCOUNT,
                STATIC_MEMBERS.ACCOUNT_ACTION_IMPORT_ACCOUNT,
                STATIC_MEMBERS.ACCOUNT_ACTION_IMPORT_WATCH_ONLY_ACCOUNT,
                STATIC_MEMBERS.ACCOUNT_ACTION_IMPORT_PRIVATE_KEY,
                STATIC_MEMBERS.ACCOUNT_ACTION_IMPORT_WATCH_ONLY_ADDRESS
            ]
        }
        return accountActionsArray!
    }
    
    class func getEventsArray() -> NSArray {
        if (STATIC_MEMBERS._eventsArray == nil) {
            STATIC_MEMBERS._eventsArray = [
                TLNotificationEvents.EVENT_SEND_PAYMENT(),
                TLNotificationEvents.EVENT_RECEIVE_PAYMENT(),
                TLNotificationEvents.EVENT_RECEIVE_PAYMENT_FROM_STEALTH_ADDRESS(),
                TLNotificationEvents.EVENT_VIEW_HISTORY(),
                TLNotificationEvents.EVENT_CREATE_NEW_ACCOUNT(),
                TLNotificationEvents.EVENT_EDIT_ACCOUNT_NAME(),
                TLNotificationEvents.EVENT_ARCHIVE_ACCOUNT(),
                TLNotificationEvents.EVENT_ENABLE_PIN_CODE(),
                TLNotificationEvents.EVENT_BACKUP_PASSPHRASE(),
                TLNotificationEvents.EVENT_RESTORE_WALLET(),
                TLNotificationEvents.EVENT_ADD_TO_ADDRESS_BOOK(),
                TLNotificationEvents.EVENT_EDIT_ENTRY_ADDRESS_BOOK(),
                TLNotificationEvents.EVENT_DELETE_ENTRY_ADDRESS_BOOK(),
                TLNotificationEvents.EVENT_SEND_TO_ADDRESS_IN_ADDRESS_BOOK(),
                TLNotificationEvents.EVENT_TAG_TRANSACTION(),
                TLNotificationEvents.EVENT_TOGGLE_AUTOMATIC_TX_FEE(),
                TLNotificationEvents.EVENT_CHANGE_AUTOMATIC_TX_FEE(),
                TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESSES(),
                TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESS(),
                TLNotificationEvents.EVENT_VIEW_TRANSACTION_IN_WEB(),
                TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESS_IN_WEB(),
                TLNotificationEvents.EVENT_ENABLE_ADVANCE_MODE(),
            ]
        }
        return STATIC_MEMBERS._eventsArray!
    }
    
    class func getAdvanceEventsArray() -> NSArray {
        if (STATIC_MEMBERS._howToDoAdvanceAchievementsArray == nil) {
            STATIC_MEMBERS._howToDoAdvanceAchievementsArray = [
                
                TLNotificationEvents.EVENT_IMPORT_ACCOUNT(),
                TLNotificationEvents.EVENT_IMPORT_WATCH_ONLY_ACCOUNT(),
                TLNotificationEvents.EVENT_IMPORT_PRIVATE_KEY(),
                TLNotificationEvents.EVENT_IMPORT_WATCH_ONLY_ADDRESS(),
                TLNotificationEvents.EVENT_CHANGE_BLOCKEXPLORER_TYPE(),
                TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY(),
                TLNotificationEvents.EVENT_VIEW_EXTENDED_PRIVATE_KEY(),
                TLNotificationEvents.EVENT_VIEW_ACCOUNT_PRIVATE_KEY(),
            ]
        }
        return STATIC_MEMBERS._howToDoAdvanceAchievementsArray!
    }
    
    class func getFAQArray() -> NSArray {
        var _faqArray: NSArray?
        if (_faqArray == nil) {
            _faqArray = [
                TLDisplayStrings.WHAT_IS_BITCOIN_STRING(),
                TLDisplayStrings.WHAT_ARE_THE_BENEFITS_AND_ADVANTAGES_OF_BITCOIN_STRING(),
                TLDisplayStrings.HOW_DO_I_GET_BITCOINS_STRING(),
                TLDisplayStrings.WHAT_IS_A_BITCOIN_WALLET_STRING(),
                TLDisplayStrings.HOW_DOES_ARCBIT_WALLET_WORK_STRING(),
                TLDisplayStrings.WHAT_MAKES_ARCBIT_DIFFERENT_FROM_OTHER_BITCOIN_WALLETS_STRING(),
                TLDisplayStrings.WHAT_ARE_TRANSACTION_CONFIRMATIONS_STRING(),
                TLDisplayStrings.WHAT_ARE_ACCOUNTS_STRING(),
                TLDisplayStrings.WHAT_ARE_REUSABLE_ADDRESSES_STRING(),
                TLDisplayStrings.WHAT_IS_ARCBITS_COLD_WALLET_FEATURE_STRING(),
            ]
        }
        return _faqArray!
    }
    
    class func getExplanation(_ idx: Int) -> String {
        if (STATIC_MEMBERS._explanationArray == nil) {
            STATIC_MEMBERS._explanationArray = [
                TLDisplayStrings.WHAT_IS_BITCOIN_DESC_STRING(),
                TLDisplayStrings.WHAT_ARE_THE_BENEFITS_AND_ADVANTAGES_OF_BITCOIN_DESC_STRING(),
                TLDisplayStrings.HOW_DO_I_GET_BITCOINS_DESC_STRING(),
                TLDisplayStrings.WHAT_IS_A_BITCOIN_WALLET_DESC_STRING(),
                TLDisplayStrings.HOW_DOES_ARCBIT_WALLET_WORK_DESC_STRING(),
                TLDisplayStrings.WHAT_MAKES_ARCBIT_DIFFERENT_FROM_OTHER_BITCOIN_WALLETS_DESC_STRING(),
                TLDisplayStrings.WHAT_ARE_TRANSACTION_CONFIRMATIONS_DESC_STRING(),
                TLDisplayStrings.WHAT_ARE_ACCOUNTS_DESC_STRING(),
                TLDisplayStrings.WHAT_ARE_REUSABLE_ADDRESSES_DESC_STRING(),
                TLDisplayStrings.WHAT_IS_ARCBITS_COLD_WALLET_FEATURE_DESC_STRING(),
            ]
        }
        return STATIC_MEMBERS._explanationArray!.object(at: idx) as! String
    }
    
    class func getAdvanceFAQArray() -> NSArray {
        var _faqArray: NSArray?
        if (_faqArray == nil) {
            _faqArray = [
                TLDisplayStrings.WHAT_ARE_ACCOUNT_EXTENDED_KEYS_STRING(),
                TLDisplayStrings.IMPORT_FEATURE_STRING(),
                TLDisplayStrings.IMPORTING_AN_ACCOUNT_STRING(),
                TLDisplayStrings.IMPORTING_A_WATCH_ONLY_ACCOUNT_STRING(),
                TLDisplayStrings.IMPORTING_A_PRIVATE_KEY_STRING(),
                TLDisplayStrings.IMPORTING_A_WATCH_ONLY_ADDRESS_STRING(),
            ]
        }
        return _faqArray!
    }
    
    class func getAdvanceExplanation(_ idx: Int) -> String {
        if (STATIC_MEMBERS._advanceExplanationArray == nil) {
            STATIC_MEMBERS._advanceExplanationArray = [
                TLDisplayStrings.WHAT_ARE_ACCOUNT_EXTENDED_KEYS_DESC_STRING(),
                TLDisplayStrings.IMPORT_FEATURE_DESC_STRING(),
                TLDisplayStrings.IMPORTING_AN_ACCOUNT_DESC_STRING(),
                TLDisplayStrings.IMPORTING_A_WATCH_ONLY_ACCOUNT_DESC_STRING(),
                TLDisplayStrings.IMPORTING_A_PRIVATE_KEY_DESC_STRING(),
                TLDisplayStrings.IMPORTING_A_WATCH_ONLY_ADDRESS_DESC_STRING(),
            ]
        }
        
        return STATIC_MEMBERS._advanceExplanationArray!.object(at: idx) as! String
    }
}
