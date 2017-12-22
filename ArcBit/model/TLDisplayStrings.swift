//
//  TLDisplayStrings.swift
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


class TLDisplayStrings {
    class func DISMISS_STRING() -> String { return "".localized }
    class func X_NOT_ALLOWED_TO_ACCESS_THE_CAMERA_STRING() -> String { return "%@ is not allowed to access the camera".localized }
    class func X_SERVERS_NOT_REACHABLE_STRING() -> String { return "%@ servers not reachable.".localized }
    class func X_SLASH_Y_PARTS_SCANNED_STRING() -> String { return "%d/%d parts scanned.".localized }
    class func ONE_CONFIRMATION_STRING() -> String { return "1 Confirmation".localized }
    class func X_CONFIRMATIONS_STRING() -> String { return "%llu confirmations".localized }
    class func IMPORTING_A_WATCH_ONLY_ADDRESS_DESC_STRING() -> String { return "A bitcoin address typically begins with a '1' or '3'. You can see the transactions and track the balance of an address, but you cannot spend from an imported address.\nYou can temporarily import this watch addresses private key to spend its bitcoins. Simply go the Send screen and select a watch address to spend from and you will be prompted to temporarily import your addresses' private key when you click 'Review Payment' in the Send screen. The private key will stay in memory until the app exits or until you remove it manually in the Accounts screen.".localized }
    class func WHAT_IS_A_BITCOIN_WALLET_DESC_STRING() -> String { return "A bitcoin wallet is a software application that allows people to send, receive and manage their bitcoins.\nBe aware of how other bitcoin applications store your bitcoins' private keys, which are needed to spend your bitcoins.\nThere are generally three different ways applications can your store your bitcoins.\n1.\nThe banking model, where your bitcoin private keys are held for you by someone else.\n2.\nThe security box model, where your bitcoin private keys are stored encrypted on someone else’s servers.\n3.\nThe wallet model, where your bitcoin private keys are stored only on your device.".localized }
    class func IMPORTING_A_PRIVATE_KEY_DESC_STRING() -> String { return "A private key begins with an 'L', 'K', or '5'.\nBIP 38 encrypted private keys can also be imported. They can either be imported encrypted or unencrypted. If you choose to import it encrypted, you will need to input the password each time you spend from your encrypted private key.".localized }
    class func ACCOUNT_X_IMPORTED_STRING() -> String { return "Account %@ imported".localized }
    class func ACCOUNT_X_STRING() -> String { return "Account %lu".localized }
    class func ACCOUNT_1_STRING() -> String { return "Account 1".localized }
    class func ACCOUNT_ACTIONS_STRING() -> String { return "Actions".localized }
    class func ACCOUNT_ID_COLON_X_STRING() -> String { return "Account ID: %u".localized }
    class func ACCOUNT_PRIVATE_KEY_STRING() -> String { return "Account Private Key".localized }
    class func ACCOUNT_PUBLIC_KEY_STRING() -> String { return "Account Public Key".localized }
    class func ACCOUNT_NAME_STRING() -> String { return "Name".localized }
    class func ACCOUNT_PRIVATE_KEY_DOES_NOT_MATCH_STRING() -> String { return "Account private key does not match imported account public key".localized }
    class func ACCOUNT_PRIVATE_KEY_MISSING_STRING() -> String { return "Account private key missing".localized }
    class func ACCOUNTS_STRING() -> String { return "Accounts".localized }
    class func ACHIEVEMENT_LIST_STRING() -> String { return "Achievement List".localized }
    class func ACHIEVEMENTS_STRING() -> String { return "Achievements".localized }
    class func ACTIVE_CHANGE_ADDRESSES_STRING() -> String { return "Active Change Addresses".localized }
    class func ACTIVE_MAIN_ADDRESSES_STRING() -> String { return "Active Main Addresses".localized }
    class func ADD_CONTACTS_ENTRY_STRING() -> String { return "Add Contacts Entry".localized }
    class func ADDRESS_STRING() -> String { return "Address".localized }
    class func IMPORTED_ADDRESS_STRING() -> String { return "Imported Address".localized }
    class func ADDRESS_ID_STRING() -> String { return "Address ID ".localized }
    class func ADDRESS_ID_X_STRING_STRING() -> String { return "Address ID: %lu".localized }
    class func ADDRESSES_STRING() -> String { return "Addresses".localized }
    class func ADVANCE_ACHIEVEMENT_LIST_STRING() -> String { return "Advanced Achievement List".localized }
    class func ADVANCE_FAQ_STRING() -> String { return "Advanced FAQ".localized }
    class func ADVANCE_HOW_TO_COLON_STRING_STRING() -> String { return "Advanced how To:".localized }
    class func WHAT_ARE_TRANSACTION_CONFIRMATIONS_DESC_STRING() -> String { return "After a transaction is broadcast to the Bitcoin network, it may be included in a block that is published to the network. When that happens, it is said that the transaction has been mined at a depth of 1 block. With each subsequent block that is found, the number of blocks deep is increased by one. To be secure against double spending, a transaction should not be considered as confirmed until it is a certain number of blocks deep.\nA good rule of thumb is that 1 confirmation is good for small value amounts of bitcoins and a user should wait for more confirmations for larger value amounts.\nArcBit will display the confirmation number up until the 6th confirmation.".localized }
    class func INVALID_AMOUNT_STRING() -> String { return "Invalid amount".localized }
    class func WHAT_ARE_ACCOUNTS_DESC_STRING() -> String { return "An account is a collection of bitcoin addresses. With accounts, you will no longer have to manage bitcoin addresses directly anymore. Since address reuse results in a loss of privacy for people using Bitcoin, ArcBit’s HD wallet account system will automatically handle the cycling of bitcoin addresses for you. This ensures you don’t use the same bitcoin address more then once.\nEach account also has a reusable address. You can find it in your Receive screen. Swipe all the way to right on the QRCode in your Receive screen and you will find a reusable address.\nYou can create an unlimited amount of accounts with ArcBit. See the help section on how to create a new account in ArcBit.".localized }
    class func IMPORTING_AN_ACCOUNT_DESC_STRING() -> String { return "An account private key begins with the letters 'xprv'. You can see, spend and recover the transactions and bitcoins of an entire account from an account private key.".localized }
    class func IMPORTING_A_WATCH_ONLY_ACCOUNT_DESC_STRING() -> String { return "An account public key begins with the letters 'xpub'. You can see the transactions and bitcoins of an entire account from an account private key, with the exception of reusable address payments. Future releases will address this issue.\nYou can temporarily import the corresponding account private key for this accounts' account public key to spend your watch accounts' bitcoins. Simply go to the Send screen and select a watch account to spend from and you will be prompted to temporarily import your account's private key when you click 'Review Payment' on the Send screen. The private key will stay in memory until the app exits or until you remove it manually on the Accounts screen.".localized }
    class func ARCBIT_BRAIN_WALLET_STRING() -> String { return "ArcBit Brain Wallet".localized }
    class func ARCBIT_WEB_WALLET_STRING() -> String { return "ArcBit Web Wallet".localized }
    class func HOW_DOES_ARCBIT_WALLET_WORK_DESC_STRING() -> String { return "ArcBit uses the the bitcoin wallet model (See the section ’What is a bitcoin wallet?’ to understand the 3 different security models of bitcoin software). However, if you use iCloud to backup your wallet, you will be using the security box model. It is recommended that you do not use iCloud and be responsible for your bitcoins yourself. For those who don’t want to remember a simple backup passphrase, iCloud backup is a good alternative.".localized }
    class func ARCHIVE_ACCOUNT_STRING() -> String { return "Archive Account".localized }
    class func ARCHIVE_ADDRESS_STRING() -> String { return "Archive address".localized }
    class func ARCHIVED_ACCOUNTS_STRING() -> String { return "Archived Accounts".localized }
    class func ARCHIVED_CHANGE_ADDRESSES_STRING() -> String { return "Archived Change Addresses".localized }
    class func ARCHIVED_COLD_WALLET_ACCOUNTS_STRING() -> String { return "Archived Cold Wallet Accounts".localized }
    class func ARCHIVED_IMPORTED_ACCOUNTS_STRING() -> String { return "Archived Imported Accounts".localized }
    class func ARCHIVED_IMPORTED_ADDRESSES_STRING() -> String { return "Archived Imported Addresses".localized }
    class func ARCHIVED_IMPORTED_WATCH_ACCOUNTS_STRING() -> String { return "Archived Imported Watch Accounts".localized }
    class func ARCHIVED_IMPORTED_WATCH_ADDRESSES_STRING() -> String { return "Archived Imported Watch Addresses".localized }
    class func ARCHIVED_MAIN_ADDRESSES_STRING() -> String { return "Archived Main Addresses".localized }
    class func ARE_YOU_SURE_YOU_WANT_TO_ARCHIVE_ACCOUNT_X_STRING() -> String { return "Are you sure you want to archive account %@?".localized }
    class func ARE_YOU_SURE_YOU_WANT_TO_ARCHIVE_ADDRESS_X_STRING() -> String { return "Are you sure you want to archive address %@?".localized }
    class func ARE_YOU_SURE_YOU_WANT_TO_DELETE_THIS_ACCOUNT_STRING() -> String { return "Are you sure you want to delete this account?".localized }
    class func ARE_YOU_SURE_YOU_WANT_TO_UNARCHIVE_ACCOUNT_X_STRING() -> String { return "Are you sure you want to unarchive account %@".localized }
    class func ARE_YOU_SURE_YOU_WANT_TO_UNARCHIVE_ADDRESS_X_STRING() -> String { return "Are you sure you want to unarchive address %@?".localized }
    class func AUTHORIZE_COLD_WALLET_ACCOUNT_PAYMENT_STRING() -> String { return "Authorize Cold Wallet Account Payment".localized }
    class func AUTHORIZE_PAYMENT_STRING() -> String { return "Authorize Payment".localized }
    class func BACK_UP_PASSPHRASE_STRING() -> String { return "Backup Passphrase".localized }
    class func BACK_UP_WALLET_STRING() -> String { return "Backup wallet".localized }
    class func BACKUP_LOCAL_WALLET_STRING() -> String { return "Backup local wallet".localized }
    class func BACKUP_PASSPHRASE_FOUND_IN_KEYCHAIN_STRING() -> String { return "Backup passphrase found in keychain".localized }
    class func WHAT_ARE_THE_BENEFITS_AND_ADVANTAGES_OF_BITCOIN_DESC_STRING() -> String { return "Bitcoin cuts out the middleman and allows you to send money anywhere in the world with an internet connection with minimum to zero fees.".localized }
    class func WHAT_IS_BITCOIN_DESC_STRING() -> String { return "Bitcoin, uppercase 'B', is an online payment system invented in 2008 and released as open-source software in 2009 by a programmer named Satoshi Nakamoto. The system is decentralized and peer-to-peer allowing users to transact directly without needing an intermediary.\nBitcoin is also a platform of which other decentralized applications can be built upon. Bitcoin, lowercase 'b' is the currency unit that Bitcoin uses.".localized }
    class func HOW_DO_I_GET_BITCOINS_DESC_STRING() -> String { return "Bitcoins can be purchased from various bitcoin exchanges. ArcBit is not a bitcoin exchange. ArcBit is a bitcoin wallet. After you purchase some bitcoins from an exchange, you can move it to a bitcoin wallet.".localized }
    class func CANCEL_STRING() -> String { return "Cancel".localized }
    class func CANNOT_ARCHIVE_YOUR_DEFAULT_ACCOUNT_STRING() -> String { return "Cannot archive your default account".localized }
    class func CANNOT_ARCHIVE_YOUR_ONE_AND_ONLY_ACCOUNT_STRING() -> String { return "Cannot archive your one and only account".localized }
    class func CANNOT_CREATE_TRANSACTIONS_WITH_OUTPUTS_LESS_THEN_X_BITCOINS_STRING() -> String { return "Cannot create transactions with outputs less then %@".localized }
    class func CANNOT_DECRYPT_ICLOUD_BACKUP_WALLET_STRING() -> String { return "Cannot decrypt iCloud backup wallet.".localized }
    class func CANNOT_IMPORT_REUSABLE_ADDRESS_STRING() -> String { return "Cannot import reusable address".localized }
    class func CHANGE_ADDRESS_ID_STRING() -> String { return "Change Address ID ".localized }
    class func CHANGE_AUTOMATIC_TRANSACTION_FEE_STRING() -> String { return "Change Automatic Transaction Fee".localized }
    class func CHANGE_BLOCKEXPLORER_TYPE_STRING() -> String { return "Change Blockexplorer Type".localized }
    class func CHECK_OUT_THE_ARCBIT_BRAIN_WALLET_STRING() -> String { return "Check out the ArcBit Brain Wallet".localized }
    class func CHECK_OUT_THE_ARCBIT_WEB_WALLET_STRING() -> String { return "Check out the ArcBit Web Wallet".localized }
    class func CHECK_OUT_THE_ARCBIT_WEB_WALLET_EXCLAMATION_STRING() -> String { return "Check out the ArcBit Web Wallet!".localized }
    class func CHECKING_TRANSACTION_STRING() -> String { return "Checking Transaction".localized }
    class func CLEAR_ACCOUNT_PRIVATE_KEY_FROM_MEMORY_STRING() -> String { return "Clear account private key from memory".localized }
    class func CLEAR_PRIVATE_KEY_FROM_MEMORY_STRING() -> String { return "Clear private key from memory".localized }
    class func CLICK_AN_ADDRESS_STRING() -> String { return "Click an address".localized }
    class func CLICK_THE_BUTTON_WITH_THE_ARROW_STRING() -> String { return "Click the button with the arrow".localized }
    class func CLICK_THE_PLUS_BUTTON_AT_THE_TOP_RIGHT_STRING() -> String { return "Click the plus button at the top right".localized }
    class func CLICK_THE_CONTACTS_BUTTON_STRING() -> String { return "Click the ‘Contacts’ button".localized }
    class func CLICK_ACCOUNTS_STRING() -> String { return "Click ‘Accounts’".localized }
    class func CLICK_ADVANCED_SETTINGS_STRING() -> String { return "Click ‘Advanced settings’".localized }
    class func CLICK_ARCHIVE_ACCOUNT_STRING() -> String { return "Click ‘Archive Account’".localized }
    class func CLICK_CREATE_NEW_ACCOUNT_STRING() -> String { return "Click ‘Create New Account’".localized }
    class func CLICK_DELETE_STRING() -> String { return "Click ‘Delete’".localized }
    class func CLICK_DONE_STRING() -> String { return "Click ‘Done’".localized }
    class func CLICK_EDIT_ACCOUNT_NAME_STRING() -> String { return "Click ‘Edit Account Name’".localized }
    class func CLICK_EDIT_STRING() -> String { return "Click ‘Edit’".localized }
    class func CLICK_ENABLE_PIN_CODE_STRING() -> String { return "Click ‘Enable PIN Code’".localized }
    class func CLICK_HISTORY_STRING() -> String { return "Click ‘History’".localized }
    class func CLICK_IMPORT_ACCOUNT_STRING() -> String { return "Click ‘Import Account’".localized }
    class func CLICK_IMPORT_PRIVATE_KEY_STRING() -> String { return "Click ‘Import Private Key’".localized }
    class func CLICK_IMPORT_WATCH_ACCOUNT_STRING() -> String { return "Click ‘Import Watch Only Account’".localized }
    class func CLICK_IMPORT_WATCH_ADDRESS_STRING() -> String { return "Click ‘Import Watch Only Address’".localized }
    class func CLICK_LABEL_TRANSACTION_STRING() -> String { return "Click ‘Label transaction’".localized }
    class func CLICK_RESTORE_WALLET_STRING() -> String { return "Click ‘Restore Wallet’".localized }
    class func CLICK_RESTORE_STRING() -> String { return "Click ‘Restore’".localized }
    class func CLICK_REVIEW_PAYMENT_STRING() -> String { return "Click ‘Review Payment’".localized }
    class func CLICK_SEND_STRING() -> String { return "Click ‘Send’".localized }
    class func CLICK_SET_TRANSACTION_FEE_STRING() -> String { return "Click ‘Set Transaction Fee’".localized }
    class func CLICK_SETTINGS_STRING() -> String { return "Click ‘Settings’".localized }
    class func CLICK_SHOW_BACKUP_PASSPHRASE_STRING() -> String { return "Click ‘Show Backup Passphrase’".localized }
    class func CLICK_VIEW_ADDRESSES_STRING() -> String { return "Click ‘View Addresses’".localized }
    class func CLICK_VIEW_ACCOUNT_PRIVATE_KEY_QR_CODE_STRING() -> String { return "Click ‘View account private key QR code’".localized }
    class func CLICK_VIEW_ACCOUNT_PUBLIC_KEY_QR_CODE_STRING() -> String { return "Click ‘View account public key QR code’".localized }
    class func CLICK_VIEW_ADDRESS_QR_CODE_STRING() -> String { return "Click ‘View address QR code’".localized }
    class func CLICK_VIEW_IN_WEB_STRING() -> String { return "Click ‘View in web’".localized }
    class func CLICK_VIEW_PRIVATE_KEY_QR_CODE_STRING() -> String { return "Click ‘View private key QR code’".localized }
    class func CLICK_BLOCKEXPLORER_API_TYPE_STRING() -> String { return "Click ‘blockexplorer API type’".localized }
    class func CLICK_RECEIVE_STRING() -> String { return "Click ’Receive’".localized }
    class func CLOSE_STRING() -> String { return "Close".localized }
    class func COLD_WALLET_STRING() -> String { return "Cold Wallet".localized }
    class func COLD_WALLET_ACCOUNTS_STRING() -> String { return "Cold Wallet Accounts".localized }
    class func IMPORTED_COLD_WALLET_ACCOUNTS_REUSABLE_ADDRESS_INFO_DESC_STRING() -> String { return "Cold Wallet Accounts can't see reusable address payments, thus this accounts' reusable address is not available.".localized }
    class func COLD_WALLET_OVERVIEW_STRING() -> String { return "Cold Wallet Overview".localized }
    class func COLD_WALLET_PRIVATE_KEYS_ARE_NOT_STORED_HERE_STRING() -> String { return "Cold wallet private keys are not stored here and cannot be viewed".localized }
    class func COMPLETE_STRING() -> String { return "Complete".localized }
    class func COMPLETE_STEP_1_STRING() -> String { return "Complete step 1".localized }
    class func CONFIRM_PIN_CODE_STRING() -> String { return "Confirm Pin Code".localized }
    class func CONTINUE_STRING() -> String { return "Continue".localized }
    class func COPIED_TO_CLIPBOARD_STRING() -> String { return "Copied To clipboard".localized }
    class func COPY_TO_CLIPBOARD_STRING() -> String { return "Copy".localized }
    class func COPY_TRANSACTION_ID_TO_CLIPBOARD_STRING() -> String { return "Copy Transaction ID to Clipboard".localized }
    class func CREATE_COLD_WALLET_STRING() -> String { return "Create Cold Wallet".localized }
    class func CREATE_NEW_ACCOUNT_STRING() -> String { return "Create New Account".localized }
    class func CREATE_NEW_CONTACT_STRING() -> String { return "Create new contact".localized }
    class func DECRYPTING_PRIVATE_KEY_STRING() -> String { return "Decrypting".localized }
    class func DELETE_STRING() -> String { return "Delete".localized }
    class func DELETE_X_STRING() -> String { return "Delete %@".localized }
    class func DELETE_ACCOUNT_STRING() -> String { return "Delete Account".localized }
    class func DELETE_CONTACTS_ENTRY_STRING() -> String { return "Delete Contact".localized }
    class func DELETE_ADDRESS_STRING() -> String { return "Delete address".localized }
    class func DONT_MANAGE_INDIVIDUAL_ACCOUNT_ADDRESS_WARNING_DESC_STRING() -> String { return "Do not use the QR code from here to receive bitcoins. Go to the Receive screen to get a QR code to receive bitcoins.".localized }
    class func ICLOUD_BACKUP_NOT_FOUND_DESC_STRING() -> String { return "Do you want to load and backup your current local wallet file?".localized }
    class func DO_YOU_WANT_TO_LOAD_LOCAL_WALLET_FILE_STRING() -> String { return "Do you want to load local wallet file?".localized }
    class func BACKUP_PASSPHRASE_FOUND_IN_KEYCHAIN_DESC_STRING() -> String { return "Do you want to restore from your backup passphrase or start a new wallet?".localized }
    class func ASK_TEMPORARY_IMPORT_ACCOUNT_PRIVATE_KEY_STRING() -> String { return "Do you want to temporary import your account private key?".localized }
    class func DO_YOU_WANT_TO_TEMPORARY_IMPORT_YOUR_PRIVATE_KEY_STRING() -> String { return "Do you want to temporary import your private key?".localized }
    class func DONT_REMIND_ME_STRING() -> String { return "Don't remind me".localized }
    class func DONE_STRING() -> String { return "Done".localized }
    class func WHAT_ARE_ACCOUNT_EXTENDED_KEYS_DESC_STRING() -> String { return "Each account has a public and private account key. Account keys should be kept secret as they are used to view the account's transactions and spend the account's bitcoins.".localized }
    class func EDIT_STRING() -> String { return "Edit".localized }
    class func EDIT_ACCOUNT_NAME_STRING() -> String { return "Edit Account Name".localized }
    class func EDIT_CONTACTS_ENTRY_STRING() -> String { return "Edit Contact Name".localized }
    class func EDIT_LABEL_STRING() -> String { return "Edit Label".localized }
    class func EDIT_TRANSACTION_LABEL_STRING() -> String { return "Edit Transaction label".localized }
    class func EMAIL_SUPPORT_STRING() -> String { return "Email Support".localized }
    class func ENABLE_PIN_CODE_TO_BETTER_SECURE_WALLET_STRING() -> String { return "Enable PIN code in settings to better secure your wallet.".localized }
    class func ENABLE_PIN_CODE_STRING() -> String { return "Enable Pin Code".localized }
    class func ENABLE_TRANSACTION_FEE_STRING() -> String { return "Enable Transaction Fee".localized }
    class func ENABLE_ADVANCED_MODE_STRING() -> String { return "Enable advanced mode".localized }
    class func ENCOUNTERED_ERROR_CREATING_TRANSACTION_TRY_AGAIN_STRING() -> String { return "Encountered error creating transaction. Please try again.".localized }
    class func ENCRYPTED_STRING() -> String { return "Encrypted".localized }
    class func ENTER_LABEL_STRING() -> String { return "Enter Label".localized }
    class func ENTER_PIN_CODE_STRING() -> String { return "Enter PIN".localized }
    class func ENTER_BACKUP_PASSPHRASE_STRING() -> String { return "Enter backup passphrase".localized }
    class func ENTER_PASSPHRASE_FOR_ICLOUD_BACKUP_WALLET_STRING() -> String { return "Enter passphrase for your iCloud backup wallet.".localized }
    class func ENTER_PASSWORD_FOR_ENCRYPTED_PRIVATE_KEY_STRING() -> String { return "Enter password for encrypted private key".localized }
    class func ERROR_STRING() -> String { return "Error".localized }
    class func ERROR_FETCHING_TRANSACTION_STRING() -> String { return "Error fetching Transaction.".localized }
    class func ERROR_FETCHING_UNSPENT_OUTPUTS_TRY_AGAIN_LATER_STRING() -> String { return "Error fetching unspent outputs. Try again later.".localized }
    class func ERROR_FETCHING_UNSPENT_OUTPUTS_TRY_AGAIN_STRING() -> String { return "Error fetching unspent outputs. Try again.".localized }
    class func ERROR_GETTING_BLOCK_HEIGHT_STRING() -> String { return "Error getting block height.".localized }
    class func ERROR_IMPORTING_ACCOUNT_STRING() -> String { return "Error importing account".localized }
    class func ERROR_LOADING_WALLET_JSON_FILE_STRING() -> String { return "Error loading wallet JSON file".localized }
    class func EXPLANATION_STRING() -> String { return "Explanation".localized }
    class func FAQ_STRING() -> String { return "FAQ".localized }
    class func FILL_ADDRESS_FIELD_STRING() -> String { return "Fill address field".localized }
    class func FINISHED_PASSING_TRANSACTION_DATA_STRING() -> String { return "Finished Passing Transaction Data".localized }
    class func MNEMONIC_INFO_STRING() -> String { return "First make sure you are using your secondary offline device for this screen (as mentioned in the overview on the previous screen). Click 'New Wallet' and write down or memorize the generated 12 word passphrase. This passphrase can recover and generate all your accounts and the bitcoins associated with it, so keep it safe and to yourself. Also instead of creating a new wallet, you can also input an existing 12 word passphrase that was generated here to create additional accounts.".localized }
    class func ACCOUNT_ID_INFO_STRING() -> String { return "Enter an account ID and click 'QR Code'. Then on your primary online device, enable Cold Wallet in settings. Then go to the Accounts screen and click 'Import Cold Wallet Account' and scan the Account Public Key QR Code. Afterwards use this cold wallet account as you would a normal account and deposit bitcoins into it. When you want to make a payment from a cold wallet account, go to the next section on the previous screen and follow the step by step instructions there.".localized }
    class func FOLLOW_US_ON_TWITTER_STRING() -> String { return "Follow us on Twitter".localized }
    class func FUNDS_HAVE_BEEN_CLAIMED_ALREADY_STRING() -> String { return "Funds have been claimed already.".localized }
    class func GO_STRING() -> String { return "Go".localized }
    class func GO_TO_THE_SIDE_MENU_STRING() -> String { return "Go to the side menu".localized }
    class func HAVE_SENDER_SCAN_QR_CODE_STRING() -> String { return "Have sender scan QR code".localized }
    class func HAVE_SENDER_SEND_YOU_PAYMENT_STRING() -> String { return "Have sender send you payment".localized }
    class func HELP_STRING() -> String { return "Help".localized }
    class func WHAT_MAKES_ARCBIT_DIFFERENT_FROM_OTHER_BITCOIN_WALLETS_DESC_STRING() -> String { return "Here are some features that no other mobile bitcoin wallet supports.\n- Reusable address support\n- Ability to import individual account (extended) keys\n- iCloud backup support\n- Over 150 local currencies supported".localized }
    class func HIERARCHICAL_DETERMINISTIC_WALLET_STRING() -> String { return "Hierarchical Deterministic Wallet".localized }
    class func HISTORY_STRING() -> String { return "History".localized }
    class func HOW_TO_COLON_STRING() -> String { return "How To:".localized }
    class func HOW_DO_I_GET_BITCOINS_STRING() -> String { return "How do I get bitcoins?".localized }
    class func HOW_DOES_ARCBIT_WALLET_WORK_STRING() -> String { return "How does ArcBit Wallet work?".localized }
    class func IMPORT_ACCOUNT_STRING() -> String { return "Import Account".localized }
    class func IMPORT_COLD_WALLET_ACCOUNT_STRING() -> String { return "Import Cold Wallet Account".localized }
    class func IMPORT_FEATURE_STRING() -> String { return "Import Feature".localized }
    class func IMPORT_PRIVATE_KEY_STRING() -> String { return "Import Private Key".localized }
    class func IMPORT_PRIVATE_ENCRYPTED_KEY_STRING() -> String { return "Import Private/Encrypted Key".localized }
    class func IMPORT_WATCH_ACCOUNT_STRING() -> String { return "Import Watch Account".localized }
    class func IMPORT_WATCH_ADDRESS_STRING() -> String { return "Import Watch Address".localized }
    class func IMPORT_PRIVATE_KEY_ENCRYPTED_OR_UNENCRYPTED_STRING() -> String { return "Import private key encrypted or unencrypted?".localized }
    class func IMPORT_WITH_QR_CODE_STRING() -> String { return "Import with QR code".localized }
    class func IMPORT_WITH_TEXT_INPUT_STRING() -> String { return "Import with text input".localized }
    class func IMPORTED_ACCOUNTS_STRING() -> String { return "Imported Accounts".localized }
    class func IMPORTED_ADDRESSES_STRING() -> String { return "Imported Addresses".localized }
    class func IMPORTED_WATCH_ACCOUNTS_STRING() -> String { return "Imported Watch Accounts".localized }
    class func IMPORTED_WATCH_ADDRESSES_STRING() -> String { return "Imported Watch Addresses".localized }
    class func IMPORTED_WATCH_ONLY_ACCOUNTS_REUSABLE_ADDRESS_INFO_DESC_STRING() -> String { return "Imported Watch Only Accounts can't see reusable address payments, thus this accounts' reusable address is not available. If you want see the reusable address for this account, import the account private key that corresponds to this accounts public key.".localized }
    class func IMPORTING_ACCOUNT_STRING() -> String { return "Importing Account".localized }
    class func IMPORTING_COLD_WALLET_ACCOUNT_STRING() -> String { return "Importing Cold Wallet Account".localized }
    class func IMPORTING_A_PRIVATE_KEY_STRING() -> String { return "Importing a Private Key".localized }
    class func IMPORTING_A_WATCH_ONLY_ACCOUNT_STRING() -> String { return "Importing a Watch Only Account".localized }
    class func IMPORTING_A_WATCH_ONLY_ADDRESS_STRING() -> String { return "Importing a Watch Only Address".localized }
    class func IMPORTING_AN_ACCOUNT_STRING() -> String { return "Importing an Account".localized }
    class func IMPORT_PRIVATE_KEY_ENCRYPTED_OR_UNENCRYPTED_DESC_STRING() -> String { return "Importing an encrypted key will require you to input the password every time you want to send bitcoins from it.".localized }
    class func IMPORT_FEATURE_DESC_STRING() -> String { return "In advanced mode, you can import bitcoin keys and addresses from other sources. You can import account private keys, account public keys, private keys, and addresses.\nPlease note that your 12 word passphrase cannot recover your bitcoins, so it is recommended that you backup imported keys and addresses separately.".localized }
    class func INCOMPLETE_STRING() -> String { return "Incomplete".localized }
    class func INCORRECT_PASSPHRASE_FOR_ICLOUD_WALLET_BACKUP_STRING() -> String { return "Incorrect passphrase, could not decrypt iCloud wallet backup.".localized }
    class func INPUT_A_BITCOIN_ADDRESS_STRING() -> String { return "Input a bitcoin address".localized }
    class func INPUT_A_LABEL_STRING() -> String { return "Input a label".localized }
    class func INPUT_A_NEW_LABEL_STRING() -> String { return "Input a new label".localized }
    class func INPUT_ACCOUNT_PRIVATE_KEY_STRING() -> String { return "Enter account private key".localized }
    class func INPUT_ACCOUNT_PUBLIC_KEY_STRING() -> String { return "Enter account public key".localized }
    class func INPUT_ADDRESS_STRING() -> String { return "Enter address".localized }
    class func INPUT_AMOUNT_STRING() -> String { return "Input amount".localized }
    class func INPUT_LABEL_STRING() -> String { return "Input label".localized }
    class func INPUT_NEW_ACCOUNT_NAME_STRING() -> String { return "Input new account name".localized }
    class func INPUT_COLD_WALLET_KEY_INFO_STRING() -> String { return "Enter the 12 word passphrase that belongs to the cold wallet account that you want to make a payment from. This is the passphrase that was used to generate your account public key that was generated in the \'Create Cold Wallet\' section found in the previous screen.".localized }
    class func INPUT_TRANSACTION_FEE_IN_BITCOINS_STRING() -> String { return "Input transaction fee in bitcoins".localized }
    class func INPUT_YOUR_CUSTOM_FEE_IN_X_STRING() -> String { return "Input your custom fee in %@".localized }
    class func INVALID_TRANSACTION_ID() -> String { return "Invalid transaction ID".localized }
    class func INSTRUCTIONS_STRING() -> String { return "Instructions".localized }
    class func INSUFFICIENT_FUNDS_STRING() -> String { return "Insufficient Funds".localized }
    class func INSUFFICIENT_FUNDS_ACCOUNT_BALANCE_IS_STRING() -> String { return "Insufficient Funds. Account balance is %@ when %@ is required.".localized }
    class func INSUFFICIENT_FUNDS_ACCOUNT_CONTAINS_BITCOIN_DUST_STRING() -> String { return "Insufficient Funds. Account contains bitcoin dust. You can only send up to %@ for now.".localized }
    class func INTERNAL_ACCOUNT_TRANSFER_STRING() -> String { return "Internal account transfer".localized }
    class func INVALID_ADDRESS_STRING() -> String { return "Invalid Address".localized }
    class func INVALID_URL_STRING() -> String { return "Invalid URL".localized }
    class func INVALID_ACCOUNT_PRIVATE_KEY_STRING() -> String { return "Invalid account private key".localized }
    class func INVALID_ACCOUNT_PUBLIC_KEY_STRING() -> String { return "Invalid account public Key".localized }
    class func INVALID_BACKUP_PASSPHRASE_STRING() -> String { return "Invalid backup passphrase".localized }
    class func INVALID_PASSPHRASE_STRING() -> String { return "Invalid passphrase".localized }
    class func INVALID_PRIVATE_KEY_STRING() -> String { return "Invalid private key".localized }
    class func INVALID_SCANNED_DATA_STRING() -> String { return "Invalid scanned data".localized }
    class func DONT_MANAGE_INDIVIDUAL_ACCOUNT_PRIVATE_KEY_WARNING_DESC_STRING() -> String { return "It is not recommended that you manually manage private keys yourself. A leak of a private key can lead to the compromise of your accounts.".localized }
    class func ADD_ADDRESS_TO_CONTACT_WARNING_DESC_STRING() -> String { return "It is not recommended that you use a regular bitcoin address for multiple payments, but instead you should import a reusable address. Add address anyways?".localized }
    class func LABEL_STRING() -> String { return "Label".localized }
    class func LABEL_TRANSACTION_STRING() -> String { return "Label Transaction".localized }
    class func LIKE_USING_ARCBIT_STRING() -> String { return "Do you like using ArcBit?".localized }
    class func LOCAL_BACK_UP_TO_WALLET_FAILED_STRING() -> String { return "Local backup to wallet failed!".localized }
    class func RESTORE_WALLET_FROM_ICLOUD_STRING() -> String { return "Local wallet will be lost. Are you sure you want to restore wallet from iCloud?".localized }
    class func SCAN_REUSABLE_ADDRESS_PAYMENT_STRING() -> String { return "Scan For Reusable Address Payment".localized }
    class func MAXIMUM_ACCOUNTS_REACHED_STRING() -> String { return "Maximum accounts reached".localized }
    class func MORE_STRING() -> String { return "More".localized }
    class func NETWORK_ERROR_STRING() -> String { return "Network Error".localized }
    class func NEW_ADDRESSES_WILL_BE_AUTOMATICALLY_GENERATED_DESC_STRING() -> String { return "New addresses will be automatically generated and cycled for you as you use your current available addresses.".localized }
    class func NEXT_STRING() -> String { return "Next".localized }
    class func NO_STRING() -> String { return "No".localized }
    class func NONE_CURRENTLY_STRING() -> String { return "None currently".localized }
    class func NOT_NOW_STRING() -> String { return "Not now".localized }
    class func FINISHED_PASSING_TRANSACTION_DATA_DESC_STRING() -> String { return "Now authorize the transaction on your air gap device. When you have done so, click continue on this device to scan the authorized transaction data and make your payment.".localized }
    class func OK_STRING() -> String { return "OK".localized }
    class func SCAN_UNSIGNED_TX_INFO_STRING() -> String { return "On your primary online device, when you want to make a payment from a cold wallet account, simply do it as you normally would on a normal account. When you click 'Send' on the Review Payment screen, instead of the payment going out immediately, you will be prompted to pass the unauthorized transaction data. Then on your secondary offline device, within this screen click 'Scan' to import the transaction so it can be authorized.".localized }
    class func PASS_SIGNED_TX_INFO_STRING() -> String { return "Once the transaction has been authorized by completing the above two steps, pass the authorized transaction back to your primary online device to finalize your payment.".localized }
    class func OTHER_LINKS_STRING() -> String { return "Other Links".localized }
    class func PASSPHRASE_DOES_NOT_MATCH_THE_TRANSACTION_STRING() -> String { return "Passphrase does not match the transaction".localized }
    class func PASSWORD_STRING() -> String { return "Password".localized }
    class func PAYMENT_INDEX_X_STRING() -> String { return "Payment Index: %lu".localized }
    class func CLEARED_FROM_MEMORY_STRING() -> String { return "Cleared from memory".localized }
    class func PRIVATE_KEY_DOES_NOT_MATCH_ADDRESS_STRING() -> String { return "Private key does not match address".localized }
    class func PRIVATE_KEY_MISSING_STRING() -> String { return "Private key missing".localized }
    class func QR_CODE_STRING() -> String { return "QR code".localized }
    class func QUIT_AND_RE_ENTER_APP_STRING() -> String { return "Quit and re-enter app".localized }
    class func RATE_STRING() -> String { return "Rate".localized }
    class func RATE_US_IN_THE_APP_STORE_STRING() -> String { return "Rate us in the App Store!".localized }
    class func RECEIVE_STRING() -> String { return "Receive".localized }
    class func RECEIVE_PAYMENT_STRING() -> String { return "Receive Payment".localized }
    class func RECEIVE_PAYMENT_FROM_REUSABLE_ADDRESS_STRING() -> String { return "Receive Payment From Reusable Address".localized }
    class func REMIND_ME_LATER_STRING() -> String { return "Remind me Later".localized }
    class func RESTORE_STRING() -> String { return "Restore".localized }
    class func RESTORE_FROM_ICLOUD_STRING() -> String { return "Restore from iCloud".localized }
    class func RESTORING_WALLET_STRING() -> String { return "Restoring Wallet".localized }
    class func RETRY_STRING() -> String { return "Retry".localized }
    class func REUSABLE_ADDRESS_PAYMENT_ADDRESSES_STRING() -> String { return "Reusable Address Payment Addresses".localized }
    class func REUSABLE_ADDRESS_COLON_STRING() -> String { return "Reusable Address:".localized }
    class func REUSABLE_ADDRESSES_STRING() -> String { return "Reusable Addresses".localized }
    class func SAVE_STRING() -> String { return "Save".localized }
    class func SCAN_STRING() -> String { return "Scan".localized }
    class func SCAN_FOR_REUSABLE_ADDRESS_PAYMENT_STRING() -> String { return "Scan For Reusable Address Payment".localized }
    class func SCAN_FOR_REUSABLE_ADDRESS_TRANSACTION_STRING() -> String { return "Scan for reusable address transaction".localized }
    class func SCAN_NEXT_PART_STRING() -> String { return "Scan next part".localized }
    class func SCROLL_DOWN_TO_THE_SECTION_ACCOUNT_ACTIONS_STRING() -> String { return "Scroll down to the section ‘Account Actions’".localized }
    class func INTERNAL_WALLET_DATA_STRING() -> String { return "Internal Wallet Data".localized }
    class func SELECT_ACCOUNT_STRING() -> String { return "Select Account".localized }
    class func SELECT_AND_CLICK_A_BLOCKEXPLORER_API_STRING() -> String { return "Select and click a blockexplorer API".localized }
    class func SELECT_AND_CLICK_A_TRANSACTION_STRING() -> String { return "Select and click a transaction".localized }
    class func SELECT_AND_CLICK_AN_ACCOUNT_STRING() -> String { return "Select and click an account".localized }
    class func SELECT_AND_CLICK_AN_ACCOUNT_TO_RECEIVE_FROM_STRING() -> String { return "Select and click an account to receive from".localized }
    class func SELECT_AND_CLICK_AN_ACCOUNT_TO_VIEW_TRANSACTION_HISTORY_STRING() -> String { return "Select and click an account to view it’s transaction history".localized }
    class func SELECT_AND_CLICK_AN_ADDRESS_STRING() -> String { return "Select and click an address".localized }
    class func SEND_STRING() -> String { return "Send".localized }
    class func SEND_PAYMENT_STRING() -> String { return "Send Payment".localized }
    class func SEND_TO_ADDRESS_IN_CONTACTS_STRING() -> String { return "Send To Address In Contacts".localized }
    class func SEND_AUTHORIZED_PAYMENT_STRING() -> String { return "Send authorized payment?".localized }
    class func SENDING_STRING() -> String { return "Sending".localized }
    class func REUSABLE_ADDRESS_BLOCKCHAIN_API_WARNING_STRING() -> String { return "Sending payment to a reusable address might take longer to show up then a normal transaction with the blockchain.info API. You might have to wait until at least 1 confirmation for the transaction to show up. This is due to the limitations of the blockchain.info API. For reusable address payments to show up faster, configure your app to use the Insight API in advance settings.".localized }
    class func SENT_X_TO_Y_STRING() -> String { return "Sent %@ to %@".localized }
    class func CHANGE_BLOCK_EXPLORER_URL_STRING() -> String { return "Change Block Explorer URL".localized }
    class func SET_TRANSACTION_FEE_IN_X_STRING() -> String { return "Set Transaction Fee in %@".localized }
    class func SETTINGS_STRING() -> String { return "Settings".localized }
    class func SOME_FUNDS_MAY_BE_PENDING_CONFIRMATION_DESC_STRING() -> String { return "Some funds may be pending confirmation and cannot be spent yet. (Check your account history) Account only has a spendable balance of %@".localized }
    class func WHAT_ARE_REUSABLE_ADDRESSES_DESC_STRING() -> String { return "Some people have compared bitcoin addresses to a bank routing number. It is a good analogy, however bitcoin addresses are public. So if you reuse the same bitcoin address for multiple payments like you would a routing number, people will be able to figure out how much bitcoin you have. Thus it is recommended that you only use one address per payment.\nThis causes usability issues making the user use a new address whenever receiving a payment is cumbersome.\nStealth/reusable addresses provides a better solution. When you give a sender a reusable address, the sender will derive a one time regular bitcoin address from the reusable address. Then the sender will send a payment to that regular bitcoin address. Now you can give many people just one reusable address and have them all send you payments without letting other people know how much bitcoin you have.\nA reusable address looks like this vJmxthatTBXibYe9aZavx18iAT9gyiJETGkhwPX2WbHQGuzX83YvQXynD2t8yHU4Xjfonu5x9m6B4yxquytFP1c2CRbVR9mecxesvE. A reusable address is a lot longer then a regular bitcoin address, it is 102 characters in length.\nReusable addresses are great, however there are no other mobile bitcoin wallets but ArcBit that supports reusable addresses for now. Which is why ArcBit supports receiving payments from both regular bitcoin addresses and reusable addresses.\nFor each account, you have one reusable address. You can find it on your Receive screen. Swipe all the way to right on the QRCode on your Receive screen and you will find a reusable address.".localized }
    class func SPENDING_FROM_A_COLD_WALLET_ACCOUNT_STRING() -> String { return "Spending from a cold wallet account".localized }
    class func START_FRESH_STRING() -> String { return "Start fresh".localized }
    class func START_RESTORE_ANOTHER_WALLET_STRING() -> String { return "Start/Restore Another Wallet".localized }
    class func STEPS_STRING() -> String { return "Steps".localized }
    class func SUCCESS_STRING() -> String { return "Success".localized }
    class func SWIPE_RIGHT_ON_AN_ADDRESS_STRING() -> String { return "Swipe right on an address".localized }
    class func SWIPE_UNTIL_YOU_SEE_THE_REUSABLE_ADDRESS_STRING() -> String { return "Swipe to the right on the QR Code Image until you see the reusable address".localized }
    class func TEMPORARY_IMPORT_ACCOUNT_PRIVATE_KEY_STRING() -> String { return "Temporarily import account private key".localized }
    class func TEMPORARY_IMPORT_PRIVATE_KEY_STRING() -> String { return "Temporarily import private key".localized }
    class func COLD_WALLET_OVERVIEW_DESC_STRING() -> String { return "The cold wallet feature will allow you to create accounts which offer better security compared to normal online wallets. You will need 2 devices to use this feature. Your normal day to day device that is connected to the internet and a secondary device that is not connected to the internet (Your secondary device would need to be online once to download the ArcBit app. Afterwards keep the secondary device offline for maximum security). This feature allows you to authorize bitcoin payments from an offline device so that the keys to your bitcoins will never need to be stored on your online device. Follow the step by step instructions by clicking the info buttons within the below sections.".localized }
    class func WHAT_IS_ARCBITS_COLD_WALLET_FEATURE_DESC_STRING() -> String { return "The cold wallet feature will allow you to create accounts which offer better security compared to normal online wallets. You will need 2 devices to use this feature. Your normal day to day device that is connected to the internet and a secondary device that is not connected to the internet (Your secondary device would need to be online once to download the ArcBit app. Afterwards keep the secondary device offline for maximum security). This feature allows you to authorize bitcoin payments from an offline device so that the keys to your bitcoins will never need to be stored on your online device. You can enable the cold wallet feature by going into advanced settings.".localized }
    class func CANT_SEE_REUSABLE_ADDRESS_PAYMENTS_STRING() -> String { return "This account type can't see reusable address payments".localized }
    class func MANUALLY_SCAN_TRANSACTION_FOR_STEALTH_TX_INFO_STRING() -> String { return "This feature allows you to manually input a transaction ID and see if the corresponding transaction contains a reusable address payment to your reusable address. If so, then the funds will be added to your wallet. Normally the app will discover reusable address payments automatically for you, but if you believe a payment is missing you can use this feature.".localized }
    class func TOGGLE_AUTOMATIC_TRANSACTION_FEE_STRING() -> String { return "Toggle Automatic Transaction Fee".localized }
    class func TOGGLE_ENABLE_TRANSACTION_FEE_STRING() -> String { return "Toggle ‘Enable Transaction Fee’".localized }
    class func TOGGLE_ENABLE_ADVANCED_MODE_STRING() -> String { return "Toggle ’Enable advanced mode’".localized }
    class func TRANSACTION_X_ALREADY_ACCOUNTED_FOR_STRING() -> String { return "Transaction %@ already accounted for.".localized }
    class func FUNDS_IMPORTED() -> String { return "Funds imported".localized }
    class func TRANSACTION_X_DOES_NOT_BELONG_TO_THIS_ACCOUNT_STRING() -> String { return "Transaction %@ does not belong to this account.".localized }
    class func TRANSACTION_FEE_STRING() -> String { return "Transaction Fee".localized }
    class func TRANSACTION_ID_STRING() -> String { return "Transaction ID".localized }
    class func TRANSACTION_ID_COLON_X_STRING() -> String { return "Transaction ID: %@".localized }
    class func TRANSACTION_AUTHORIZED_STRING() -> String { return "Transaction authorized".localized }
    class func TRANSACTION_CONFIRMATIONS_STRING() -> String { return "Transaction confirmations".localized }
    class func FEE_INFO_DESC_STRING() -> String { return "Transaction fees impact how quickly the Bitcoin network will confirm your transactions. Higher fees means faster confirmation times. Default fee behavior can be configured in settings.".localized }
    class func SPENDING_FROM_A_COLD_WALLET_ACCOUNT_DESC_STRING() -> String { return "Transaction needs to be authorized by an offline and air gap device. Send transaction to an offline device for authorization?".localized }
    class func TRANSACTION_AUTHORIZED_DESC_STRING() -> String { return "Transaction needs to be passed back to your online device in order for the payment to be sent".localized }
    class func TRY_AGAIN_STRING() -> String { return "Try Again".localized }
    class func TRY_OUR_NEW_COLD_WALLET_FEATURE_STRING() -> String { return "Try our new cold wallet feature!".localized }
    class func TRANSACTION_NOT_REUSABLE_ADDRESS_TRANSACTION_STRING() -> String { return "Transaction is not a reusable address transaction.".localized }
    class func URL_DOES_NOT_CONTAIN_AN_ADDRESS_STRING() -> String { return "URL does not contain an address.".localized }
    class func UNABLE_TO_GET_DYNAMIC_FEES_STRING() -> String { return "Unable to get dynamic fees. Falling back on fixed transaction fee. (fee can be configured on review payment)".localized }
    class func UNARCHIVE_ACCOUNT_STRING() -> String { return "Unarchive Account".localized }
    class func UNARCHIVE_ADDRESS_STRING() -> String { return "Unarchive address".localized }
    class func UNARCHIVED_ADDRESS_STRING() -> String { return "Unarchived address".localized }
    class func UNCONFIRMED_STRING() -> String { return "Unconfirmed".localized }
    class func UNENCRYPTED_STRING() -> String { return "Unencrypted".localized }
    class func CHECK_OUT_THE_ARCBIT_WEB_WALLET_DESC_STRING() -> String { return "Use ArcBit on your browser to complement the mobile app. The web wallet has all the features that the mobile wallet has plus more!".localized }
    class func USE_ALL_FUNDS_STRING() -> String { return "Use all funds".localized }
    class func VIEW_ACCOUNT_ADDRESS_STRING() -> String { return "View Account Address".localized }
    class func VIEW_ACCOUNT_ADDRESS_IN_WEB_STRING() -> String { return "View Account Address In Web".localized }
    class func VIEW_ACCOUNT_ADDRESSES_STRING() -> String { return "View Account Addresses".localized }
    class func VIEW_ACCOUNT_PRIVATE_KEY_STRING() -> String { return "View Account Private Key".localized }
    class func VIEW_ACCOUNT_PUBLIC_KEY_STRING() -> String { return "View Account Public Key".localized }
    class func VIEW_ACHIEVEMENTS_STRING() -> String { return "View Achievements".localized }
    class func VIEW_ADDRESSES_STRING() -> String { return "View Addresses".localized }
    class func VIEW_ARCBIT_BRAIN_WALLET_DETAILS_STRING() -> String { return "View ArcBit Brain Wallet Details".localized }
    class func VIEW_ARCBIT_WEB_WALLET_DETAILS_STRING() -> String { return "View ArcBit Web Wallet Details".localized }
    class func VIEW_HISTORY_STRING() -> String { return "View History".localized }
    class func VIEW_PRIVATE_KEY_STRING() -> String { return "View Private Key".localized }
    class func VIEW_TRANSACTION_IN_WEB_STRING() -> String { return "View Transaction In Web".localized }
    class func VIEW_ACCOUNT_PRIVATE_KEY_QR_CODE_STRING() -> String { return "View account private key QR code".localized }
    class func VIEW_ACCOUNT_PUBLIC_KEY_QR_CODE_STRING() -> String { return "View account public key QR code".localized }
    class func VIEW_ADDRESS_QR_CODE_STRING() -> String { return "View address QR code".localized }
    class func VIEW_ADDRESS_IN_WEB_STRING() -> String { return "View address in web".localized }
    class func VIEW_IN_WEB_STRING() -> String { return "View in web".localized }
    class func VIEW_PRIVATE_KEY_QR_CODE_STRING() -> String { return "View private key QR code".localized }
    class func VISIT_OUR_HOME_PAGE_STRING() -> String { return "Visit our home page".localized }
    class func WARNING_STRING() -> String { return "Warning".localized }
    class func WELCOME_DESC_STRING() -> String { return "Welcome to ArcBit, a user only controlled Bitcoin wallet. Start using the app now by depositing your Bitcoins here.".localized }
    class func WELCOME_EXCLAMATION_STRING() -> String { return "Welcome!".localized }
    class func WHAT_ARE_ACCOUNT_EXTENDED_KEYS_STRING() -> String { return "What are Account/Extended Keys?".localized }
    class func WHAT_ARE_ACCOUNTS_STRING() -> String { return "What are accounts?".localized }
    class func WHAT_ARE_REUSABLE_ADDRESSES_STRING() -> String { return "What are reusable addresses?".localized }
    class func WHAT_ARE_THE_BENEFITS_AND_ADVANTAGES_OF_BITCOIN_STRING() -> String { return "What are the benefits and advantages of Bitcoin?".localized }
    class func WHAT_ARE_TRANSACTION_CONFIRMATIONS_STRING() -> String { return "What are transaction confirmations?".localized }
    class func WHAT_IS_ARCBITS_COLD_WALLET_FEATURE_STRING() -> String { return "What is ArcBit's cold wallet feature?".localized }
    class func WHAT_IS_BITCOIN_STRING() -> String { return "What is Bitcoin?".localized }
    class func WHAT_IS_A_BITCOIN_WALLET_STRING() -> String { return "What is a bitcoin wallet?".localized }
    class func WHAT_MAKES_ARCBIT_DIFFERENT_FROM_OTHER_BITCOIN_WALLETS_STRING() -> String { return "What makes ArcBit different from other bitcoin wallets?".localized }
    class func TRY_OUR_NEW_COLD_WALLET_FEATURE_DESC_STRING() -> String { return "With an ArcBit cold wallet feature, you can create wallets and make payments offline without exposing your private keys to an internet connected device. This feature is great for storing large amounts of bitcoin or for the security conscious minded. Check out this feature in the cold wallet section in the side menu.".localized }
    class func WRITE_DOWN_BACKUP_PASSPHRASE_STRING() -> String { return "Write down backup passphrase".localized }
    class func SUGGEST_BACK_UP_WALLET_PASSPHRASE_DESC_STRING() -> String { return "Write down or memorize your 12 word wallet backup passphrase. You can view it by clicking \"Show backup passphrase\" in Settings. Your wallet backup passphrase is needed to recover your bitcoins.".localized }
    class func BACKUP_PASSPHRASE_ADVANCED_EXPLANATION_STRING() -> String { return "Write down the 12 word passphrase below and keep it safe. This passphrase alone can restore your entire wallets\' bitcoins (excluding imports).".localized }
    class func BACKUP_PASSPHRASE_EXPLANATION_STRING() -> String { return "Write down the 12 word passphrase below and keep it safe. This passphrase alone can restore your entire wallets\' bitcoins.".localized }
    class func YES_STRING() -> String { return "Yes".localized }
    class func STEALTH_PAYMENT_NOTE_STRING() -> String { return "You are making a payment to a reusable address. Make sure that the receiver can see the payment made to them. (All ArcBit reusable addresses are compatible with other ArcBit wallets)".localized }
    class func YOU_HAVE_X_Y_BUT_Z_IS_NEEDED_STRING() -> String { return "You have %@, but %@ is needed. (This includes the transactions fee)".localized }
    class func KILL_THIS_APP_DESC_STRING() -> String { return "You must exit and kill this app in order for this to take effect.".localized }
    class func RESTORING_WALLET_DESC_STRING() -> String { return "Your current wallet will be deleted. Your can restore your current wallet later with the wallet passphrase, but any imported accounts or addresses created in advanced mode cannot be recovered. Do you wish to continue?".localized }
    class func YOUR_ICLOUD_BACKUP_WAS_LAST_SAVED_ON_X_DATE_STRING() -> String { return "Your iCloud backup was last saved on %@. Do you want to restore your wallet from iCloud or backup your local wallet to iCloud?".localized }
    class func YOUR_NEW_TRANSACTION_FEE_IS_TOO_HIGH_STRING() -> String { return "Your new transaction fee is too high".localized }
    class func YOUR_WALLET_IS_NOW_RESTORED_STRING() -> String { return "Your wallet is now restored".localized }
    class func ALLOW_CAMERA_ACCESS_IN_STRING() -> String { return "\nAllow camera access in\n Settings->Privacy->Camera->%@".localized }
    class func ARCBIT_WEB_WALLET_DESC_STRING() -> String { return "\tArcBit Web Wallet is a Chrome extension. It has all the features of the mobile wallet plus more. Highlights include the ability to create multiple wallets instead of just one, and a new non-cumbersome way to generate wallets, store and spend bitcoins all from cold storage! ArcBit's new way to manage your cold storage bitcoins also offers a more compelling reason to use ArcBit's watch account feature. Now you can safely watch the balance of your cold storage bitcoins by enabling advance mode in ArcBit and importing your cold storage account public keys.\n\tUse ArcBit Web Wallet in whatever way you wish. You can create a new wallet, or you can input your current 12 word backup passphrase to manage the same bitcoins across different devices. Check out the ArcBit Web Wallet in the Chrome Web Store for more details!\n".localized }
    class func ARCBIT_BRAIN_WALLET_STRING_DESC_STRING() -> String { return "\tWith the Arcbit Brain Wallet you can safely spend your bitcoins without ever having your private keys be exposed to the internet. It can be use in conjunction with your Arcbit Wallet or as a stand alone wallet.\n".localized }
    class func ICLOUD_ERROR_COLON_X_STRING() -> String { return "iCloud Error: %@".localized }
    class func ICLOUD_BACKUP_FOUND_STRING() -> String { return "iCloud backup found".localized }
    class func ICLOUD_BACKUP_NOT_FOUND_STRING() -> String { return "iCloud backup not found".localized }
    class func BACKUP_IYOUR_LOCAL_WALLET_TO_ICLOUD_STRING() -> String { return "iCloud backup will be lost. Are you sure you want to backup your local wallet to iCloud?".localized }
    
    class func TODAY_STRING() -> String { return "Today".localized }
    class func CONFIRM_PAYMENT_STRING() -> String { return "Confirm Payment".localized }
    class func FEE_COLON_STRING() -> String { return "Fee:".localized }
    class func TOTAL_COLON_STRING() -> String { return "Total:".localized }
    class func CUSTOMIZE_FEE_STRING() -> String { return "Customize Fee".localized }
    class func ENTER_A_WALLET_BACKUP_PASSPHRASE_STRING() -> String { return "Enter a wallet backup passphrase to wipe the current wallet and start/restore another.".localized }
    class func PASSPHRASE_STRING() -> String { return "Passphrase".localized }
    class func RESTORE_WALLET_STRING() -> String { return "Restore Wallet".localized }
    class func WALLET_BACKUP_PASSPHRASE_STRING() -> String { return "Wallet backup passphrase".localized }
    class func FROM_COLON_STRING() -> String { return "From:".localized }
    class func AMOUNT_COLON_STRING() -> String { return "Amount:".localized }
    class func TO_COLON_STRING() -> String { return "To:".localized }
    class func SCAN_QR_STRING() -> String { return "Scan QR Code".localized }
    class func CONTACTS_STRING() -> String { return "Contacts".localized }
    class func REVIEW_PAYMENT_STRING() -> String { return "Review Payment".localized }
    class func ACCOUNT_ID_STRING() -> String { return "Account ID".localized }
    class func AUTHORIZE_PAYMENT_STEP_1() -> String { return "Step 1: Scan transaction to authorize".localized }
    class func AUTHORIZE_PAYMENT_STEP_2() -> String { return "Step 2: Input 12 word backup passphrase".localized }
    class func AUTHORIZE_PAYMENT_STEP_3() -> String { return "Step 3: Pass authorized transaction data".localized }
    class func STARTING_RECEIVING_ADDRESS_ID() -> String { return "Starting Receiving Address ID:".localized }
    class func STARTING_CHANGE_ADDRESS_ID() -> String { return "Starting Change address ID:".localized }
    class func NEW_WALLET() -> String { return "New Wallet".localized }
    class func SCAN() -> String { return "Scan".localized }
    class func PASS() -> String { return "Pass".localized }

    class func IMPORTED_COLD_WALLET_ACCOUNT_STRING() -> String { return "Imported Cold Wallet Account %@".localized }
    class func IMPORTED_ACCOUNT_STRING() -> String { return "Imported Account %@".localized }
    class func IMPORTED_WATCH_ACCOUNT_STRING() -> String { return "Imported Watch Account %@".localized }

    
    class func WALLET_BACKUP_PASSPHRASE_WILL_BE_SHOWN() -> String { return "Wallet backup passphrase will be shown".localized }
    class func PLEASE_WRITE_DOWN_OR_MEMORIZE_YOUR_WALLET_BACKUP_PASSPHRASE() -> String { return "Write down or memorize your wallet backup passphrase. If you lose your backup passphrase, your wallet cannot be recovered. Backup can be done later. The backup passphrase can always be found in settings.".localized }
    class func I_UNDERSTAND() -> String { return "I understand".localized }
    class func ICLOUD_SUPPORT_DISCONTINUED() -> String { return "iCloud support for ArcBit discontinued".localized }
    class func ICLOUD_SUPPORT_DISCONTINUED_DESCRIPTION() -> String { return "iCloud support for ArcBit is being discontinued. If your backup passphrase has not been backed up already, please do so.".localized }

}
