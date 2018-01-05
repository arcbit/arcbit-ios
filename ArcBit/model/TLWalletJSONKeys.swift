//
//  TLWalletJsonKeys.swift
//  ArcBit
//
//  Created by Tim Lee on 9/22/15.
//  Copyright © 2015 ArcBit. All rights reserved.
//

import Foundation

enum TLAccount:Int {
    case normal       = 0
    case multisig     = 1
}

enum TLAddressStatus:Int {
    case archived = 0 //archived: passed window
    case active = 1
}

enum TLAddressType:Int {
    case main = 0
    case change = 1
    case stealth = 2
}

enum TLStealthPaymentStatus:Int {
    case unspent = 0 // >=0 confirmations for payment tx
    case claimed = 1 // 0-5 confirmations for payment tx and >=0 confirm for claimed tx
    case spent = 2 // > 6 confirmations for payment tx and >=0 confirm for claimed tx
}

class TLWalletJSONKeys {
    
    struct STATIC_MEMBERS {
        static let WALLET_PAYLOAD_VERSION_ONE = "1"
        static let WALLET_PAYLOAD_VERSION_TWO = "2"
        static let WALLET_PAYLOAD_VERSION_THREE = "3"

        static let WALLET_PAYLOAD_KEY_VERSION = "version"
        static let WALLET_PAYLOAD_KEY_PAYLOAD = "payload"
        static let WALLET_PAYLOAD_KEY_WALLETS = "wallets"
        static let WALLET_PAYLOAD_KEY_HDWALLETS = "hd_wallets"
        static let WALLET_PAYLOAD_KEY_ACCOUNTS = "accounts"
        static let WALLET_PAYLOAD_IMPORTS = "imports"
        static let WALLET_PAYLOAD_COLD_WALLET_ACCOUNTS = "cold_wallet_accounts"
        static let WALLET_PAYLOAD_IMPORTED_ACCOUNTS = "imported_accounts"
        static let WALLET_PAYLOAD_WATCH_ONLY_ACCOUNTS = "watch_only_accounts"
        static let WALLET_PAYLOAD_IMPORTED_PRIVATE_KEYS = "imported_private_keys"
        static let WALLET_PAYLOAD_WATCH_ONLY_ADDRESSES = "watch_only_addresses"
        static let WALLET_PAYLOAD_ACCOUNT_IDX = "account_idx"
        static let WALLET_PAYLOAD_EXTENDED_PRIVATE_KEY = "xprv"
        static let WALLET_PAYLOAD_EXTENDED_PUBLIC_KEY = "xpub"
        static let WALLET_PAYLOAD_ACCOUNT_NEEDS_RECOVERING = "needs_recovering"
        static let WALLET_PAYLOAD_KEY_MAIN_ADDRESSES = "main_addresses"
        static let WALLET_PAYLOAD_KEY_CHANGE_ADDRESSES = "change_addresses"
        static let WALLET_PAYLOAD_KEY_STEALTH_ADDRESSES = "stealth_addresses"
        static let WALLET_PAYLOAD_KEY_STEALTH_ADDRESS = "stealth_address"
        static let WALLET_PAYLOAD_KEY_STEALTH_ADDRESS_SCAN_KEY = "scan_key"
        static let WALLET_PAYLOAD_KEY_STEALTH_ADDRESS_SPEND_KEY = "spend_key"
        static let WALLET_PAYLOAD_KEY_PAYMENTS = "payments"
        static let WALLET_PAYLOAD_KEY_SERVERS = "servers"
        static let WALLET_PAYLOAD_KEY_WATCHING = "watching"
        static let WALLET_PAYLOAD_KEY_TXID = "txid"
        static let WALLET_PAYLOAD_KEY_MIN_MAIN_ADDRESS_IDX = "min_main_address_idx"
        static let WALLET_PAYLOAD_KEY_MIN_CHANGE_ADDRESS_IDX = "min_change_address_vidx"
        static let WALLET_PAYLOAD_KEY_TIME = "time"
        static let WALLET_PAYLOAD_KEY_CHECK_TIME = "check_time"
        static let WALLET_PAYLOAD_KEY_LAST_TX_TIME = "last_tx_time"
        static let WALLET_PAYLOAD_KEY_KEY = "key"
        static let WALLET_PAYLOAD_KEY_ADDRESS = "address"
        static let WALLET_PAYLOAD_KEY_STATUS = "status"
        static let WALLET_PAYLOAD_KEY_INDEX = "index"
        static let WALLET_PAYLOAD_KEY_LABEL = "label"
        static let WALLET_PAYLOAD_KEY_NAME = "name"
        static let WALLET_PAYLOAD_KEY_MAX_ACCOUNTS_CREATED = "max_account_id_created"
        static let WALLET_PAYLOAD_KEY_MASTER_HEX = "master_hex"
        static let WALLET_PAYLOAD_KEY_PASSPHRASE = "passphrase"
        static let WALLET_PAYLOAD_KEY_ADDRESS_BOOK = "address_book"
        static let WALLET_PAYLOAD_KEY_TRANSACTION_TAGS = "tx_tags"
        
        static let WALLET_PAYLOAD_KEY_BITCOIN = "BTC"
        static let WALLET_PAYLOAD_KEY_BITCOIN_CASH = "BCH"

    }
    
    // Notes:
    // version 2: Add 'cold_wallet_accounts' dictionary to 'imports' dictionary
    class func getLastestVersion () -> String { return STATIC_MEMBERS.WALLET_PAYLOAD_VERSION_THREE }

}
