//
//  TLWalletPassphrase.swift
//  ArcBit
//
//  Created by Tim Lee on 8/10/15.
//  Copyright (c) 2015 ArcBit. All rights reserved.
//

import Foundation

class TLWalletPassphrase {

    class func enableRecoverableFeature(_ useKeychain:Bool) {
        let encryptedWalletPassphraseKey = TLPreferences.getEncryptedWalletPassphraseKey()
        let encryptedWalletPassphrase = TLPreferences.getWalletPassphrase(useKeychain)
        assert(encryptedWalletPassphraseKey != nil)
        let walletPassphrase = TLWalletPassphrase.decryptWalletPassphrase(encryptedWalletPassphrase!, key: encryptedWalletPassphraseKey!)
        TLPreferences.setWalletPassphrase(walletPassphrase!, useKeychain: true)
        TLPreferences.setEncryptedWalletJSONPassphrase(walletPassphrase!, useKeychain: true)
        TLPreferences.clearEncryptedWalletPassphraseKey()
    }
    
    class func disableRecoverableFeature(_ useKeychain:Bool) {
        let encryptedWalletPassphraseKey = TLWalletPassphrase.generateWalletPassphraseKey()
        let walletPassphrase = TLPreferences.getWalletPassphrase(useKeychain)
        let encryptedWalletPassphrase = TLWalletPassphrase.encryptWalletPassphrase(walletPassphrase!, key: encryptedWalletPassphraseKey)
        assert(TLPreferences.getEncryptedWalletPassphraseKey() == nil)
        TLPreferences.setEncryptedWalletPassphraseKey(encryptedWalletPassphraseKey)
        TLPreferences.setWalletPassphrase(encryptedWalletPassphrase, useKeychain: false)
        TLPreferences.setEncryptedWalletJSONPassphrase(encryptedWalletPassphrase, useKeychain: false)
    }
    
    class func getDecryptedWalletPassphrase() -> String? {
        if TLUpdateAppData.instance().beforeUpdatedAppVersion != nil
            && TLUpdateAppData.instance().beforeUpdatedAppVersion!.hasPrefix("1.0") {
                if !TLPreferences.canRestoreDeletedApp() {
                    TLWalletPassphrase.disableRecoverableFeature(true)
                }
                TLUpdateAppData.instance().beforeUpdatedAppVersion = nil
                return TLPreferences.getWalletPassphrase(true)
        } else {
            let encryptedWalletPassphraseKey = TLPreferences.getEncryptedWalletPassphraseKey()
            if encryptedWalletPassphraseKey != nil {
                let encryptedWalletPassphrase = TLPreferences.getWalletPassphrase(TLPreferences.canRestoreDeletedApp())
                return TLWalletPassphrase.decryptWalletPassphrase(encryptedWalletPassphrase!,
                    key: encryptedWalletPassphraseKey!)
            } else {
                return TLPreferences.getWalletPassphrase(TLPreferences.canRestoreDeletedApp())
            }
        }
    }
    
    class func generateWalletPassphraseKey() -> String {
        return BTCKey().privateKeyAddress.base58String
    }
    
    class func decryptWalletPassphrase(_ encryptedWalletPassphrase: String, key: String)  -> String? {
        return TLCrypto.decrypt(encryptedWalletPassphrase, password: key)
    }
    
    class func encryptWalletPassphrase(_ walletPassphrase: String, key: String)  -> String {
        return TLCrypto.encrypt(walletPassphrase, password: key)
    }
    
    
    
}
