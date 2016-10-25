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
        
        static let FAQ_TRANSACTION_CONFIRMATIONS = "Transaction confirmations".localized
        static let FAQ_HD_WALLET = "HD Wallet".localized
        static let FAQ_STEALTH_ADDRESS = "Stealth/Reusable Addresses".localized
        
        static let ACCOUNT_ACTION_CREATE_NEW_ACCOUNT = "Create New Account".localized
        static let ACCOUNT_ACTION_IMPORT_COLD_WALLET_ACCOUNT = "Import Cold Wallet Account".localized
        static let ACCOUNT_ACTION_IMPORT_ACCOUNT = "Import Account".localized
        static let ACCOUNT_ACTION_IMPORT_WATCH_ONLY_ACCOUNT = "Import Watch Only Account".localized
        static let ACCOUNT_ACTION_IMPORT_PRIVATE_KEY = "Import Private Key".localized
        static let ACCOUNT_ACTION_IMPORT_WATCH_ONLY_ADDRESS = "Import Watch Only Address".localized
        
        static let ACTION_SEND_PAYMENT = "Send Payment".localized
        static let ACTION_RECEIVE_PAYMENT = "Receive Payment".localized
        static let ACTION_RECEIVE_PAYMENT_FROM_STEALTH_ADDRESS = "Receive Payment From Reusable Address".localized
        static let ACTION_VIEW_HISTORY = "View History".localized
        static let ACTION_CREATE_NEW_ACCOUNT = "Create New Account".localized
        static let ACTION_EDIT_ACCOUNT_NAME = "Edit Account Name".localized
        static let ACTION_ARCHIVE_ACCOUNT = "Archive Account".localized
        static let ACTION_ENABLE_PIN_CODE = "Enable PIN Code".localized
        static let ACTION_BACKUP_PASSPHRASE = "Back Up Passphrase".localized
        static let ACTION_RESTORE_WALLET = "Start/Restore Another Wallet".localized
        static let ACTION_ADD_TO_ADDRESS_BOOK = "Add Contacts Entry".localized
        static let ACTION_EDIT_ENTRY_ADDRESS_BOOK = "Edit Contacts Entry".localized
        static let ACTION_DELETE_ENTRY_ADDRESS_BOOK = "Delete Contacts Entry".localized
        static let ACTION_SEND_TO_ADDRESS_IN_ADDRESS_BOOK = "Send To Address In Contacts".localized
        static let ACTION_TAG_TRANSACTION = "Tag transaction".localized
        static let ACTION_TOGGLE_AUTOMATIC_TX_FEE = "Toggle Automatic Transaction Fee".localized
        static let ACTION_CHANGE_AUTOMATIC_TX_FEE = "Change Automatic Transaction Fee".localized
        static let ACTION_VIEW_ACCOUNT_ADDRESSES = "View Account Addresses".localized
        static let ACTION_VIEW_ACCOUNT_ADDRESS_IN_WEB = "View Account Address In Web".localized
        static let ACTION_VIEW_TRANSACTION_IN_WEB = "View Transaction In Web".localized
        static let ACTION_ENABLE_ADVANCE_MODE = "Enable advanced mode".localized
        
        static let ACTION_IMPORT_ACCOUNT = "Import Account".localized
        static let ACTION_IMPORT_WATCH_ONLY_ACCOUNT = "Import Watch Only Account".localized
        static let ACTION_IMPORT_PRIVATE_KEY = "Import Private/Encrypted Key".localized
        static let ACTION_IMPORT_WATCH_ONLY_ADDRESS = "Import Watch Only Address".localized
        static let ACTION_CHANGE_BLOCKEXPLORER_TYPE = "Change Blockexplorer Type".localized
        static let ACTION_VIEW_EXTENDED_PUBLIC_KEY = "View Account Public Key".localized
        static let ACTION_VIEW_EXTENDED_PRIVATE_KEY = "View Account Private Key".localized
        static let ACTION_VIEW_ACCOUNT_PRIVATE_KEY = "View Private Key".localized
        static let ACTION_VIEW_ACCOUNT_ADDRESS = "View Account Address".localized
        
    }
    
    class func getBasicActionInstructionStepsArray(_ idx: Int) -> NSArray {
        if (STATIC_MEMBERS._actionEventToInstructionStepsTitleArray == nil) {
            STATIC_MEMBERS._actionEventToInstructionStepsTitleArray = [
                [
                    "Go to the side menu".localized,
                    "Click ‘Send’".localized,
                    "Fill address field".localized,
                    "Input amount".localized,
                    "Click ‘Review Payment’".localized,
                    "Click ’Send’".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Receive’".localized,
                    "Click the button with the arrow".localized,
                    "Select and click an account to receive from".localized,
                    "Have sender scan QR code".localized,
                    "Have sender send you payment".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Receive’".localized,
                    "Click the button with the arrow".localized,
                    "Select and click an account to receive from".localized,
                    "Have sender scan QR code".localized,
                    "Swipe to the right on the QR Code Image until you see the reusable address".localized,
                    "Have sender send you payment".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘History’".localized,
                    "Click the button with the arrow".localized,
                    "Select and click an account to view it’s transaction history".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Accounts’".localized,
                    "Scroll down to the section ‘Account Actions’".localized,
                    "Click ‘Create New Account’".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Accounts’".localized,
                    "Select and click an account".localized,
                    "Click ‘Edit Account Name’".localized,
                    "Input new account name".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Accounts’".localized,
                    "Select and click an account".localized,
                    "Click ‘Archive Account’".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Settings’".localized,
                    "Click ‘Enable PIN Code’".localized,
                    "Enter Pin Code".localized,
                    "Confirm Pin Code".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Settings’".localized,
                    "Click ‘Show Backup Passphrase’".localized,
                    "Write down backup passphrase".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Settings’".localized,
                    "Click ‘Restore Wallet’".localized,
                    "Enter backup passphrase".localized,
                    "Click ‘Done’".localized,
                    "Click ‘Restore’".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Send’".localized,
                    "Click the ‘Contacts’ button".localized,
                    "Click the plus button at the top right".localized,
                    "Input a bitcoin address".localized,
                    "Input a label".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Send’".localized,
                    "Swipe right on an address".localized,
                    "Click ‘Edit’".localized,
                    "Input a new label".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Send’".localized,
                    "Click the ‘Contacts’ button".localized,
                    "Swipe right on an address".localized,
                    "Click ‘Delete’".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Send’".localized,
                    "Click the ‘Contacts’ button".localized,
                    "Click an address".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘History’".localized,
                    "Select and click a transaction".localized,
                    "Click ‘Label transaction’".localized,
                    "Input label".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Settings’".localized,
                    "Toggle ‘Enable Transaction Fee’".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Settings’".localized,
                    "Enable Transaction Fee".localized,
                    "Click ‘Set Transaction Fee’".localized,
                    "Input transaction fee in bitcoins".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Accounts’".localized,
                    "Select and click an account".localized,
                    "Click ‘View Addresses’".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Accounts’".localized,
                    "Select and click an account".localized,
                    "Click ‘View Addresses’".localized,
                    "Select and click an address".localized,
                    "Click ‘View address QR code’".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘History’".localized,
                    "Select and click a transaction".localized,
                    "Click ‘View in web’".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Accounts’".localized,
                    "Select and click an account".localized,
                    "Click ‘View Addresses’".localized,
                    "Select and click an address".localized,
                    "Click ‘View in web’".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Settings’".localized,
                    "Click ‘Advanced options’".localized,
                    "Toggle ’Enable advanced mode’".localized,
                ],
            ]
        }
        return STATIC_MEMBERS._actionEventToInstructionStepsTitleArray!.object(at: idx) as! NSArray
        
    }
    
    
    class func getAdvanceActionInstructionStepsArray(_ idx: Int) -> NSArray {
        if (STATIC_MEMBERS._advanceActionInstructionStepsArray == nil) {
            STATIC_MEMBERS._advanceActionInstructionStepsArray = [
                [
                    "Go to the side menu".localized,
                    "Click ‘Accounts’".localized,
                    "Scroll down to the section ‘Account Actions’".localized,
                    "Click ‘Import Account’".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Accounts’".localized,
                    "Scroll down to the section ‘Account Actions’".localized,
                    "Click ‘Import Watch Only Account’".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Accounts’".localized,
                    "Scroll down to the section ‘Account Actions’".localized,
                    "Click ‘Import Private Key’".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Accounts’".localized,
                    "Scroll down to the section ‘Account Actions’".localized,
                    "Click ‘Import Watch Only Address’".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Settings’".localized,
                    "Click ‘Advanced options’".localized,
                    "Click ‘blockexplorer API type’".localized,
                    "Select and click a blockexplorer API".localized,
                    "Quit and re-enter app".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Accounts’".localized,
                    "Select and click an account".localized,
                    "Click ‘View account public key QR code’".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Accounts’".localized,
                    "Select and click an account".localized,
                    "Click ‘View account private key QR code’".localized,
                ],
                [
                    "Go to the side menu".localized,
                    "Click ‘Accounts’".localized,
                    "Select and click an account".localized,
                    "Click ‘View Addresses’".localized,
                    "Select and click an address".localized,
                    "Click ‘View private key QR code’".localized,
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
                "What is Bitcoin?".localized,
                "What are the benefits and advantages of Bitcoin?".localized,
                "How do I get bitcoins?".localized,
                "What is a bitcoin wallet?".localized,
                "How does ArcBit Wallet work?".localized,
                "What makes ArcBit different from other bitcoin wallets?".localized,
                "What are transaction confirmations?".localized,
                "What are accounts?".localized,
                "What are stealth/reusable addresses?".localized,
            ]
        }
        return _faqArray!
    }
    
    class func getExplanation(_ idx: Int) -> String {
        if (STATIC_MEMBERS._explanationArray == nil) {
            STATIC_MEMBERS._explanationArray = [
                "Bitcoin, uppercase 'B', is an online payment system invented in 2008, and released as open-source software in 2009 by a programmer name Satoshi Nakamoto. The system is decentralized and peer-to-peer, users can transact directly without needing an intermediary.\nBitcoin is also a platform where other decentralized applications can be built on top of. Bitcoin, lowercase 'b' is the currency unit that Bitcoin uses.".localized,
                "Bitcoin allows you to send money to anyone, anywhere in world that has an internet connections with minimum to zero fees, with no middlemen.".localized,
                "Bitcoins can be purchase from various bitcoin exchanges. ArcBit is not a bitcoin exchange. ArcBit is a bitcoin wallet. After you purchase some bitcoins from an exchange, you can move it to a bitcoin wallet.".localized,
                "A bitcoin wallet is a software application that allows people to send, receive and manage their bitcoins.\nBe aware of how other bitcoin applications store your bitcoins' private keys, which are needed to spend your bitcoins.\nThere are generally three different ways applications can your store your bitcoins.\n1.\nThe banking model where your bitcoin private keys are held for you by someone else.\n2.\nThe security box model where your bitcoin private keys are stored encrypted on someone else’s servers.\n3.\nThe wallet model where your bitcoin private keys are stored only on your device.".localized,
                "ArcBit used the the bitcoin wallet model (See the section ’What is a bitcoin wallet?’ to understand the 3 different security models of bitcoin software). However if you use iCloud to back up your wallet, you will be using the security box model. It is recommended that you do not use iCloud, and be responsible for your bitcoins yourself, but for those who don’t want to remember a simple backup passphrase, iCloud backup is a good alternative.".localized,
                "Here are some features that no other mobile bitcoin wallet supports.\n- Forwarding address support\n- Ability to import individual account (extended) keys\n- iCloud backup support\n- Over 150 local currencies supported".localized,
                "After a transaction is broadcast to the Bitcoin network, it may be included in a block that is published to the network. When that happens it is said that the transaction has been mined at a depth of 1 block. With each subsequent block that is found, the number of blocks deep is increased by one. To be secure against double spending, a transaction should not be considered as confirmed until it is a certain number of blocks deep.\nA good rule of thumb is that 1 confirmations is good for small value amounts of bitcoins, and a user should wait for more confirmations for larger value amounts.\nArcBit will display the confirmation number up until the 6th confirmation.".localized,
                "An account is a collection of bitcoin addresses. With accounts, you will no longer have to manage bitcoin addresses directly anymore. Since address reuse results in a loss of privacy for people using Bitcoin, ArcBit’s HD wallet account system will automatically handle the cycling of bitcoin addresses for you, so that you don’t use the same bitcoin address more then once.\nEach account also has a reusable address. You can find it in your receive screen. Swipe all the way to right on the QRCode in your receive screen and you will find a reusable address.\nYou can create an unlimited amount of accounts with ArcBit. See the help section on how to create a new account in ArcBit.".localized,
                "Some people has compared bitcoin addresses to a bank routing number. It is a good analogy, however bitcoin addresses are public. So if you reuse the same bitcoin address for multiple payments like you would a routing number, people will be able to figure out how much bitcoins you have. Thus it is recommended that you only use one address per payment.\nThis causes usability issues because making the user use a new address whenever receiving a payment is cumbersome.\nStealth/reusable addresses provides a better solution. When you give a sender a reusable address, the sender will derive a one time regular bitcoin address from the reusable address. Then the sender will send a payment to that regular bitcoin address. Now you can give many people just one reusable address and have them all send you payments without letting other people know how much bitcoins you have.\nA reusable address looks sometime like this vJmxthatTBXibYe9aZavx18iAT9gyiJETGkhwPX2WbHQGuzX83YvQXynD2t8yHU4Xjfonu5x9m6B4yxquytFP1c2CRbVR9mecxesvE. A reusable address is a lot longer then a regular bitcoin address, it is 102 characters in length.\nForwarding addresses are great, however there are no other mobile bitcoin wallets but ArcBit that supports reusable addresses for now. Which is why ArcBit support receiving payments from both regular bitcoin addresses and reusable addresses.\nFor each account, you have one reusable address. You can find it in your receive screen. Swipe all the way to right on the QRCode in your receive screen and you will find a reusable address.".localized,
            ]
        }
        return STATIC_MEMBERS._explanationArray!.object(at: idx) as! String
    }
    
    class func getAdvanceFAQArray() -> NSArray {
        var _faqArray: NSArray?
        if (_faqArray == nil) {
            _faqArray = [
                "What are Account/Extended Keys?".localized,
                "Import Feature".localized,
                "Importing an Account".localized,
                "Importing a Watch Only Account".localized,
                "Importing a Private Key".localized,
                "Importing a Watch Only Address".localized,
            ]
        }
        return _faqArray!
    }
    
    class func getAdvanceExplanation(_ idx: Int) -> String {
        if (STATIC_MEMBERS._advanceExplanationArray == nil) {
            STATIC_MEMBERS._advanceExplanationArray = [
                "Each account has a public and private account/extended key. Accounts keys should be kept secret as they are used to view the account's transactions, and spend the accounts bitcoins.".localized,
                "In advanced mode, you can import bitcoin keys and addresses from other sources. You can import account private keys, account public keys, private keys, and addresses.\nPlease note that your 12 word backphrase cannot recover your bitcoins, so it is recommended that you back up imported keys and addresses separately.".localized,
                "An account private key begins with the letters 'xprv'. You can see, spend and recover the transactions and bitcoins of an entire account from an account private key.".localized,
                "An account public key begins with the letters 'xpub'. You can see the transactions and bitcoins of an entire account from an account private key, with the exception of reusable address payments. Future releases will address this issue.\nYou can however temporary import the corresponding account private key for this accounts' account public key to spend your watch only accounts' bitcoins. Simply go the send screen and select a watch only account to spend from and you will be prompt to temporary import your account's private key when you click 'Review Payment' in the Send screen. The private key will stay in memory until the app exits or until you remove it manually in the Accounts screen.".localized,
                "A private key begins with an 'L', 'K', or '5'.\nBIP 38 encrypted private keys can also be imported. They can either be imported encrypted or unencrypted. If you choose to import it encrypted, you will need to input the password each time you spend from your encrypted private key.".localized,
                "A bitcoin address typically begins with a '1' or '3'. You can see the transactions, and track the balance of an address, but you cannot spend from just an imported address.\nYou can however temporary import this watch only addresses' private key to spend its bitcoins. Simply go the send screen and select a watch only address to spend from and you will be prompt to temporary import your addresses' private key when you click 'Review Payment' in the Send screen. The private key will stay in memory until the app exits or until you remove it manually in the Accounts screen.".localized,
            ]
        }
        
        return STATIC_MEMBERS._advanceExplanationArray!.object(at: idx) as! String
    }
}
