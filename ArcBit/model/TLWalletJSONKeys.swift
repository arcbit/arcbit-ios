//
//  TLWalletJsonKeys.swift
//  ArcBit
//
//  Created by Tim Lee on 9/22/15.
//  Copyright © 2015 ArcBit. All rights reserved.
//

import Foundation

class TLWalletJSONKeys {

    
    struct STATIC_MEMBERS {
        static let STEALTH_PAYMENTS_FETCH_COUNT = 50
                
        static let WALLET_PAYLOAD_VERSION = "1"
        static let WALLET_PAYLOAD_KEY_VERSION = "version"
        static let WALLET_PAYLOAD_KEY_PAYLOAD = "payload"
        static let WALLET_PAYLOAD_KEY_WALLETS = "wallets"
        static let WALLET_PAYLOAD_KEY_HDWALLETS = "hd_wallets"
        static let WALLET_PAYLOAD_KEY_ACCOUNTS = "accounts"
        static let WALLET_PAYLOAD_CURRENT_ACCOUNT_ID = "current_account_id"
        static let WALLET_PAYLOAD_IMPORTS = "imports"
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
    }
}