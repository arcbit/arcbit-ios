//
//  TLWalletPassphrase.swift
//  ArcBit
//
//  Created by Tim Lee on 8/10/15.
//  Copyright (c) 2015 ArcBit. All rights reserved.
//

import Foundation

class TLWalletPassphrase {

    class func getDecryptedWalletPassphrase() -> String? {
        let encryptedWalletPassphraseKey = TLPreferences.getEncryptedWalletPassphraseKey()
        if encryptedWalletPassphraseKey != nil {
            let encryptedWalletPassphrase = TLPreferences.getWalletPassphrase()
            return TLWalletPassphrase.decryptWalletPassphrase(encryptedWalletPassphrase!,
                key: encryptedWalletPassphraseKey!)
        } else {
            return TLPreferences.getWalletPassphrase()
        }
    }
    
    class func generateWalletPassphraseKey() -> String {
        return BTCKey().privateKeyAddress.base58String
    }
    
    class func decryptWalletPassphrase(encryptedWalletPassphrase: String, key: String)  -> String? {
        return TLCrypto.decrypt(encryptedWalletPassphrase, password: key)
    }
    
    class func encryptWalletPassphrase(walletPassphrase: String, key: String)  -> String {
        return TLCrypto.encrypt(walletPassphrase, password: key)
    }
    
    
    
}