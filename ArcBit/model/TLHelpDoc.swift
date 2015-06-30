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
        
        static let FAQ_TRANSACTION_CONFIRMATIONS = "Transaction confirmations"
        static let FAQ_HD_WALLET = "HD Wallet"
        static let FAQ_STEALTH_ADDRESS = "Stealth/Reusable Addresses"
        
        static let ACCOUNT_ACTION_CREATE_NEW_ACCOUNT = "Create New Account"
        static let ACCOUNT_ACTION_IMPORT_ACCOUNT = "Import Account"
        static let ACCOUNT_ACTION_IMPORT_WATCH_ONLY_ACCOUNT = "Import Watch Only Account"
        static let ACCOUNT_ACTION_IMPORT_PRIVATE_KEY = "Import Private Key"
        static let ACCOUNT_ACTION_IMPORT_WATCH_ONLY_ADDRESS = "Import Watch Only Address"
        
        static let ACTION_SEND_PAYMENT = "Send Payment"
        static let ACTION_RECEIVE_PAYMENT = "Receive Payment"
        static let ACTION_RECEIVE_PAYMENT_FROM_STEALTH_ADDRESS = "Receive Payment From Forward Address"
        static let ACTION_VIEW_HISTORY = "View History"
        static let ACTION_CREATE_NEW_ACCOUNT = "Create New Account"
        static let ACTION_EDIT_ACCOUNT_NAME = "Edit Account Name"
        static let ACTION_ARCHIVE_ACCOUNT = "Archive Account"
        static let ACTION_ENABLE_PIN_CODE = "Enable PIN Code"
        static let ACTION_BACKUP_PASSPHRASE = "Back Up Passphrase"
        static let ACTION_RESTORE_WALLET = "Start/Restore Another Wallet"
        static let ACTION_ADD_TO_ADDRESS_BOOK = "Add Address Book Entry"
        static let ACTION_EDIT_ENTRY_ADDRESS_BOOK = "Edit Address Book Entry"
        static let ACTION_DELETE_ENTRY_ADDRESS_BOOK = "Delete Address Book Entry"
        static let ACTION_SEND_TO_ADDRESS_IN_ADDRESS_BOOK = "Send To Address In Address Book"
        static let ACTION_TAG_TRANSACTION = "Tag transaction"
        static let ACTION_TOGGLE_AUTOMATIC_TX_FEE = "Toggle Automatic Transaction Fee"
        static let ACTION_CHANGE_AUTOMATIC_TX_FEE = "Change Automatic Transaction Fee"
        static let ACTION_VIEW_ACCOUNT_ADDRESSES = "View Account Addresses"
        static let ACTION_VIEW_ACCOUNT_ADDRESS_IN_WEB = "View Account Address In Web"
        static let ACTION_VIEW_TRANSACTION_IN_WEB = "View Transaction Web"
        static let ACTION_ENABLE_ADVANCE_MODE = "Enable advance mode"
        
        static let ACTION_IMPORT_ACCOUNT = "Import Account"
        static let ACTION_IMPORT_WATCH_ONLY_ACCOUNT = "Import Watch Only Account"
        static let ACTION_IMPORT_PRIVATE_KEY = "Import Private/Encrypted Key"
        static let ACTION_IMPORT_WATCH_ONLY_ADDRESS = "Import Watch Only Address"
        static let ACTION_CHANGE_BLOCKEXPLORER_TYPE = "Change Blockexplorer Type"
        static let ACTION_VIEW_EXTENDED_PUBLIC_KEY = "View Account Public Key"
        static let ACTION_VIEW_EXTENDED_PRIVATE_KEY = "View Account Private Key"
        static let ACTION_VIEW_ACCOUNT_PRIVATE_KEY = "View Private Key"
        static let ACTION_VIEW_ACCOUNT_ADDRESS = "View Account Address"
        
    }
    
    class func getBasicActionInstructionStepsArray(idx: Int) -> NSArray {
        if (STATIC_MEMBERS._actionEventToInstructionStepsTitleArray == nil) {
            STATIC_MEMBERS._actionEventToInstructionStepsTitleArray = [
                [
                    "Go to the side menu",
                    "Click ‘Send’",
                    "Fill address field",
                    "Input amount",
                    "Click ‘Review Payment’",
                    "Click ’Send’",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Receive’",
                    "Click the button with the arrow",
                    "Select and click an account to receive from",
                    "Have sender scan QR code",
                    "Have sender send you payment",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Receive’",
                    "Click the button with the arrow",
                    "Select and click an account to receive from",
                    "Have sender scan QR code",
                    "Swipe to the right on the QR Code Image until you see the forward address",
                    "Have sender send you payment",
                ],
                [
                    "Go to the side menu",
                    "Click ‘History’",
                    "Click the button with the arrow",
                    "Select and click an account to view it’s transaction history",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Accounts’",
                    "Scroll down to the section ‘Account Actions’",
                    "Click ‘Create New Account’",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Accounts’",
                    "Select and click an account",
                    "Click ‘Edit Account Name’",
                    "Input new account name",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Accounts’",
                    "Select and click an account",
                    "Click ‘Archive Account’",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Settings’",
                    "Click ‘Enable PIN Code’",
                    "Enter Pin Code",
                    "Confirm Pin Code",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Settings’",
                    "Click ‘Show Backup Passphrase’",
                    "Write down backup passphrase",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Settings’",
                    "Click ‘Restore Wallet’",
                    "Enter backup passphrase",
                    "Click ‘Done’",
                    "Click ‘Restore’",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Send’",
                    "Click the ‘Address Book’ button",
                    "Click the plus button at the top right",
                    "Input a bitcoin address",
                    "Input a label",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Send’",
                    "Swipe right on an address",
                    "Click ‘Edit’",
                    "Input a new label",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Send’",
                    "Click the ‘Address Book’ button",
                    "Swipe right on an address",
                    "Click ‘Delete’",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Send’",
                    "Click the ‘Address Book’ button",
                    "Click an address",
                ],
                [
                    "Go to the side menu",
                    "Click ‘History’",
                    "Select and click a transaction",
                    "Click ‘Label transaction’",
                    "Input label",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Settings’",
                    "Toggle ‘Enable Transaction Fee’",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Settings’",
                    "Enable Transaction Fee",
                    "Click ‘Set Transaction Fee’",
                    "Input transaction fee in bitcoins",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Accounts’",
                    "Select and click an account",
                    "Click ‘View Addresses’",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Accounts’",
                    "Select and click an account",
                    "Click ‘View Addresses’",
                    "Select and click an address",
                    "Click ‘View address QR code’",
                ],
                [
                    "Go to the side menu",
                    "Click ‘History’",
                    "Select and click a transaction",
                    "Click ‘View in web’",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Accounts’",
                    "Select and click an account",
                    "Click ‘View Addresses’",
                    "Select and click an address",
                    "Click ‘View in web’",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Settings’",
                    "Click ‘Advance options’",
                    "Toggle ’Enable advance mode’",
                ],
            ]
        }
        return STATIC_MEMBERS._actionEventToInstructionStepsTitleArray!.objectAtIndex(idx) as! NSArray
        
    }
    
    
    class func getAdvanceActionInstructionStepsArray(idx: Int) -> NSArray {
        if (STATIC_MEMBERS._advanceActionInstructionStepsArray == nil) {
            STATIC_MEMBERS._advanceActionInstructionStepsArray = [
                [
                    "Go to the side menu",
                    "Click ‘Accounts’",
                    "Scroll down to the section ‘Account Actions’",
                    "Click ‘Import Account’",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Accounts’",
                    "Scroll down to the section ‘Account Actions’",
                    "Click ‘Import Watch Only Account’",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Accounts’",
                    "Scroll down to the section ‘Account Actions’",
                    "Click ‘Import Private Key’",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Accounts’",
                    "Scroll down to the section ‘Account Actions’",
                    "Click ‘Import Watch Only Address’",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Settings’",
                    "Click ‘Advance options’",
                    "Click ‘blockexplorer API type’",
                    "Select and click a blockexplorer API",
                    "Quit and re-enter app",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Accounts’",
                    "Select and click an account",
                    "Click ‘View account public key QR code’",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Accounts’",
                    "Select and click an account",
                    "Click ‘View account private key QR code’",
                ],
                [
                    "Go to the side menu",
                    "Click ‘Accounts’",
                    "Select and click an account",
                    "Click ‘View Addresses’",
                    "Select and click an address",
                    "Click ‘View private key QR code’",
                ],
            ]
        }
        return STATIC_MEMBERS._advanceActionInstructionStepsArray!.objectAtIndex(idx) as! NSArray
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
        if (TLPreferences.enabledAdvanceMode()) {
            return getAdvanceAccountActionsArray()
        } else {
            return getBasicAccountActionsArray()
        }
    }
    
    class func getBasicAccountActionsArray() -> NSArray {
        var _accountActionsArray: NSArray?
        if (_accountActionsArray == nil) {
            _accountActionsArray = [
                STATIC_MEMBERS.ACCOUNT_ACTION_CREATE_NEW_ACCOUNT]
        }
        return _accountActionsArray!
    }
    
    class func getAdvanceAccountActionsArray() -> NSArray {
        var _accountActionsArray: NSArray?
        if (_accountActionsArray == nil) {
            _accountActionsArray = [
                STATIC_MEMBERS.ACCOUNT_ACTION_CREATE_NEW_ACCOUNT,
                STATIC_MEMBERS.ACCOUNT_ACTION_IMPORT_ACCOUNT,
                STATIC_MEMBERS.ACCOUNT_ACTION_IMPORT_WATCH_ONLY_ACCOUNT,
                STATIC_MEMBERS.ACCOUNT_ACTION_IMPORT_PRIVATE_KEY,
                STATIC_MEMBERS.ACCOUNT_ACTION_IMPORT_WATCH_ONLY_ADDRESS]
        }
        return _accountActionsArray!
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
                "What is Bitcoin?",
                "What are the benefits and advantages of Bitcoin?",
                "How do I get bitcoins?",
                "What is a bitcoin wallet?",
                "How does ArcBit Wallet work?",
                "What makes ArcBit different from other bitcoin wallets?",
                "What are transaction confirmations?",
                "What are accounts?",
                "What are stealth/forward addresses?",
            ]
        }
        return _faqArray!
    }
    
    class func getExplanation(idx: Int) -> String {
        if (STATIC_MEMBERS._explanationArray == nil) {
            STATIC_MEMBERS._explanationArray = [
                "Bitcoin, uppercase 'B', is an online payment system invented in 2008, and released as open-source software in 2009 by a programmer name Satoshi Nakamoto. The system is decentralized and peer-to-peer, users can transact directly without needing an intermediary.\nBitcoin is also a platform where other decentralized applications can be built on top of. Bitcoin, lowercase 'b' is the currency unit that Bitcoin uses.",
                "Bitcoin allows you to send money to anyone, anywhere in world that has an internet connections with minimum to zero fees, with no middlemen.",
                "Bitcoins can be purchase from various bitcoin exchanges. ArcBit is not a bitcoin exchange. ArcBit is a bitcoin wallet. After you purchase some bitcoins from an exchange, you can move it to a bitcoin wallet.",
                "A bitcoin wallet is a software application that allows people to send, receive and manage their bitcoins.\nBe aware of how other bitcoin applications store your bitcoins' private keys, which are needed to spend your bitcoins.\nThere are generally three different ways applications can your store your bitcoins.\n1.\nThe banking model where your bitcoin private keys are held for you by someone else.\n2.\nThe security box model where your bitcoin private keys are stored encrypted on someone else’s servers.\n3.\nThe wallet model where your bitcoin private keys are stored only on your device.",
                "ArcBit used the the bitcoin wallet model (See the section ’What is a bitcoin wallet?’ to understand the 3 different security models of bitcoin software). However if you use iCloud to back up your wallet, you will be using the security box model. It is recommended that you do not use iCloud, and be responsible for your bitcoins yourself, but for those who don’t want to remember a simple backup passphrase, iCloud backup is a good alternative.",
                "Here are some features that no other mobile bitcoin wallet supports.\n- Forwarding address support\n- Ability to import individual account (extended) keys\n- iCloud backup support\n- Over 150 local currencies supported",
                "After a transaction is broadcast to the Bitcoin network, it may be included in a block that is published to the network. When that happens it is said that the transaction has been mined at a depth of 1 block. With each subsequent block that is found, the number of blocks deep is increased by one. To be secure against double spending, a transaction should not be considered as confirmed until it is a certain number of blocks deep.\nA good rule of thumb is that 1 confirmations is good for small value amounts of bitcoins, and a user should wait for more confirmations for larger value amounts.\nArcBit will display the confirmation number up until the 6th confirmation.",
                "An account is a collection of bitcoin addresses. With accounts, you will no longer have to manage bitcoin addresses directly anymore. Since address reuse results in a loss of privacy for people using Bitcoin, ArcBit’s HD wallet account system will automatically handle the cycling of bitcoin addresses for you, so that you don’t use the same bitcoin address more then once.\nEach account also has a forward address. You can find it in your receive screen. Swipe all the way to right on the QRCode in your receive screen and you will find a forward address.\nYou can create an unlimited amount of accounts with ArcBit. See the help section on how to create a new account in ArcBit. ",
                "Some people has compared bitcoin addresses to a bank routing number. It is a good analogy, however bitcoin addresses are public. So if you reuse the same bitcoin address for multiple payments like you would a routing number, people will be able to figure out how much bitcoins you have. Thus it is recommended that you only use one address per payment.\nThis causes usability issues because making the user use a new address whenever receiving a payment is cumbersome.\nStealth/forward addresses provides a better solution. When you give a sender a forward address, the sender will derive a one time regular bitcoin address from the forward address. Then the sender will send a payment to that regular bitcoin address. Now you can give many people just one forward address and have them all send you payments without letting other people know how much bitcoins you have.\nA forward address looks sometime like this vJmxthatTBXibYe9aZavx18iAT9gyiJETGkhwPX2WbHQGuzX83YvQXynD2t8yHU4Xjfonu5x9m6B4yxquytFP1c2CRbVR9mecxesvE. A forward address is a lot longer then a regular bitcoin address, it is 102 characters in length.\nForwarding addresses are great, however there are no other mobile bitcoin wallets but ArcBit that supports forward addresses for now. Which is why ArcBit support receiving payments from both regular bitcoin addresses and forward addresses.\nFor each account, you have one forward address. You can find it in your receive screen. Swipe all the way to right on the QRCode in your receive screen and you will find a forward address.",
            ]
        }
        return STATIC_MEMBERS._explanationArray!.objectAtIndex(idx) as! String
    }
    
    class func getAdvanceFAQArray() -> NSArray {
        var _faqArray: NSArray?
        if (_faqArray == nil) {
            _faqArray = [
                "What are Account/Extended Keys?",
                "Import Feature",
                "Importing an Account",
                "Importing a Watch Only Account",
                "Importing a Private Key",
                "Importing a Watch Only Address",
            ]
        }
        return _faqArray!
    }
    
    class func getAdvanceExplanation(idx: Int) -> String {
        if (STATIC_MEMBERS._advanceExplanationArray == nil) {
            STATIC_MEMBERS._advanceExplanationArray = [
                "Each account has a public and private account/extended key. Accounts keys should be kept secret as they are used to view the account's transactions, and spend the accounts bitcoins.",
                "In advance mode, you can import bitcoin keys and addresses from other sources. You can import account private keys, account public keys, private keys, and addresses.\nPlease note that your 12 word backphrase cannot recover your bitcoins, so it is recommended that you back up imported keys and addresses separately.",
                "An account private key begins with the letters 'xprv'. You can see, spend and recover the transactions and bitcoins of an entire account from an account private key.",
                "An account public key begins with the letters 'xpub'. You can see the transactions and bitcoins of an entire account from an account private key, with the exception of forward address payments. Future releases will address this issue.\nYou can however temporary import the corresponding account private key for this accounts' account public key to spend your watch only accounts' bitcoins. Simply go the send screen and select a watch only account to spend from and you will be prompt to temporary import your account's private key when you click 'Review Payment' in the Send screen. The private key will stay in memory until the app exits or until you remove it manually in the Accounts screen.",
                "A private key begins with an 'L', 'K', or '5'.\nBIP 38 encrypted private keys can also be imported. They can either be imported encrypted or unencrypted. If you choose to import it encrypted, you will need to input the password each time you spend from your encrypted private key.",
                "A bitcoin address typically begins with a '1' or '3'. You can see the transactions, and track the balance of an address, but you cannot spend from just an imported address.\nYou can however temporary import this watch only addresses' private key to spend its bitcoins. Simply go the send screen and select a watch only address to spend from and you will be prompt to temporary import your addresses' private key when you click 'Review Payment' in the Send screen. The private key will stay in memory until the app exits or until you remove it manually in the Accounts screen.",
            ]
        }
        
        return STATIC_MEMBERS._advanceExplanationArray!.objectAtIndex(idx) as! String
    }
}