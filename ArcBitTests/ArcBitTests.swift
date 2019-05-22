//
//  ArcBitTests.swift
//  ArcBitTests
//
//  Created by Tim Lee on 3/22/15.
//  Copyright (c) 2015 ArcBit. All rights reserved.
//

import UIKit
import XCTest

class ArcBitTests: XCTestCase {
    
    var coinType = TLCoinType.BTC
    
    var mockWalletPayload = NSMutableDictionary()
    var wallets = NSMutableArray()
    var wallet = NSMutableDictionary()
    var backupPassphrase:String = ""
    var masterHex:String = ""
    var walletConfig:TLWalletConfig = TLWalletConfig(isTestnet: false)
    var extendPrivKey:String = ""
    
    var extendPubKey:String = ""
    let mainAddressIndex0 = [0,0]
    var mainAddress0:String = ""
    //    XCTAssertTrue("1K7fXZeeQydcUvbsfvkMSQmiacV5sKRYQz" == mainAddress0)
    let changeAddressIndex0 = [1,0]
    var changeAddress0:String = ""
    //    XCTAssertTrue("1CvpGn9VxVY1nsWWL3MSWRYaBHdNkCDbmv" == changeAddress0)

    
    
    var accountObject:TLAccountObject? = nil
    var sendFromAccounts: Array<TLAccountObject>? = nil
    let sendFromAddresses: Array<TLImportedAddress>? = nil
    let isTestnet = false

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        mockWalletPayload.setObject("1", forKey: "version" as NSCopying)
        backupPassphrase = "slogan lottery zone helmet fatigue rebuild solve best hint frown conduct ill"
        masterHex = TLHDWalletWrapper.getMasterHex(backupPassphrase)
        extendPrivKey = TLHDWalletWrapper.getExtendPrivKey(self.coinType, masterHex: masterHex, accountIdx:0)
        
        extendPubKey = TLHDWalletWrapper.getExtendPubKey(extendPrivKey)
//        mainAddressIndex0 = [0,0]
        mainAddress0 = TLHDWalletWrapper.getAddress(self.coinType, extendPubKey:extendPubKey, sequence:mainAddressIndex0 as NSArray, isTestnet:walletConfig.isTestnet)
        //    XCTAssertTrue("1K7fXZeeQydcUvbsfvkMSQmiacV5sKRYQz" == mainAddress0)
//        changeAddressIndex0 = [1,0]
        changeAddress0 = TLHDWalletWrapper.getAddress(self.coinType, extendPubKey:extendPubKey, sequence:changeAddressIndex0 as NSArray, isTestnet:walletConfig.isTestnet)
        //    XCTAssertTrue("1CvpGn9VxVY1nsWWL3MSWRYaBHdNkCDbmv" == changeAddress0)
        
        func getMockCoinWallet(_ coinType: TLCoinType) -> NSMutableDictionary {
            var imports = NSMutableDictionary()
            imports.setObject(NSMutableArray(), forKey: "imported_accounts" as NSCopying)
            imports.setObject(NSMutableArray(), forKey: "imported_private_keys" as NSCopying)
            imports.setObject(NSMutableArray(), forKey: "watch_only_accounts" as NSCopying)
            imports.setObject(NSMutableArray(), forKey: "watch_only_addresses" as NSCopying)
            imports.setObject(NSMutableArray(), forKey: "cold_wallet_accounts" as NSCopying)
            
            var hdWallets = NSMutableArray()
            
            var hdWallet = NSMutableDictionary()
            hdWallet.setObject(0, forKey: "current_account_id" as NSCopying)
            hdWallet.setObject(0, forKey: "master_hex" as NSCopying)
            hdWallet.setObject(1, forKey: "max_account_id_created" as NSCopying)
            hdWallet.setObject("default", forKey: "name" as NSCopying)
            hdWallet.setObject(backupPassphrase, forKey: "passphrase" as NSCopying)
            
            var accounts = NSMutableArray()
            var accountDict = NSMutableDictionary()
            accountDict.setObject(0, forKey: "account_idx" as NSCopying)
            accountDict.setObject(extendPubKey, forKey: "xpub" as NSCopying)
            accountDict.setObject(extendPrivKey, forKey: "xpriv" as NSCopying)
            
            var changeAdresses = NSMutableArray()
            var changeAdress = NSMutableDictionary()
            changeAdress.setObject(changeAddress0, forKey: "address" as NSCopying)
            changeAdress.setObject(0, forKey: "index" as NSCopying)
            changeAdress.setObject(1, forKey: "status" as NSCopying)
            changeAdresses.add(changeAdress)
            accountDict.setObject(changeAdresses, forKey: "change_addresses" as NSCopying)
            
            var mainAddresses = NSMutableArray()
            var mainAddress = NSMutableDictionary()
            mainAddress.setObject(mainAddress0, forKey: "address" as NSCopying)
            mainAddress.setObject(0, forKey: "index" as NSCopying)
            mainAddress.setObject(1, forKey: "status" as NSCopying)
            mainAddresses.add(mainAddress)
            accountDict.setObject(mainAddresses, forKey: "main_addresses" as NSCopying)
            
            accountDict.setObject(0, forKey: "min_change_address_vidx" as NSCopying)
            accountDict.setObject(0, forKey: "min_main_address_idx" as NSCopying)
            accountDict.setObject("Account 1", forKey: "name" as NSCopying)
            accountDict.setObject(0, forKey: "needs_recovering" as NSCopying)
            accountDict.setObject(1, forKey: "status" as NSCopying)
            
            
            var stealthAddresses = NSMutableArray()
            var stealthAddress = NSMutableDictionary()
            stealthAddress.setObject(0, forKey: "last_tx_time" as NSCopying)
            stealthAddress.setObject(NSMutableArray(), forKey: "payments" as NSCopying)
            stealthAddress.setObject("NOTUSED", forKey: "scan_key" as NSCopying)
            var servers = NSMutableDictionary()
            var watching = NSMutableDictionary()
            watching.setObject(1, forKey: "watching" as NSCopying)
            servers.setObject(watching, forKey: "www.arcbit.net" as NSCopying)
            stealthAddress.setObject(servers, forKey: "servers" as NSCopying)
            stealthAddress.setObject("NOTUSED", forKey: "spend_key" as NSCopying)
            stealthAddress.setObject("NOTUSED", forKey: "stealth_address" as NSCopying)
            stealthAddresses.add(stealthAddress)
            
            accountDict.setObject(stealthAddresses, forKey: "stealth_addresses" as NSCopying)
            accounts.add(accountDict)
            
            accountDict.setObject(extendPrivKey, forKey: "xprv" as NSCopying)
            accountDict.setObject(extendPubKey, forKey: "xpub" as NSCopying)
            
            hdWallet.setObject(accounts, forKey: "accounts" as NSCopying)
            hdWallets.add(hdWallet)
            
            let coinWallet = NSMutableDictionary()
            coinWallet.setObject(hdWallets, forKey: "hd_wallets" as NSCopying)
            coinWallet.setObject(NSMutableArray(), forKey: "address_book" as NSCopying)
            coinWallet.setObject(imports, forKey: "imports" as NSCopying)
            coinWallet.setObject(NSMutableArray(), forKey: "tx_tags" as NSCopying)
            return coinWallet
        }
        
        wallet.setObject(getMockCoinWallet(TLCoinType.BTC), forKey: "BTC" as NSCopying)
        wallet.setObject(getMockCoinWallet(TLCoinType.BCH), forKey: "BCH" as NSCopying)
        
        wallets.add(wallet)
        var payload = NSMutableDictionary()
        payload.setObject(wallets, forKey: "wallets" as NSCopying)
        mockWalletPayload.setObject(payload, forKey: "payload" as NSCopying)
        
        let appWallet = TLWallet(walletName: "Test Wallet", walletConfig: walletConfig)
        appWallet.loadWalletPayload(mockWalletPayload, masterHex:masterHex)
        
        
        let accountsArray = appWallet.getAccountObjectArray(TLCoinType.BTC)
        
        
        accountObject = accountsArray.object(at: 0) as! TLAccountObject
        sendFromAccounts = [accountObject!]

    }
    
    func mockUnspentOutput(_ txid: String, value: UInt64, txOutputN: Int) -> TLUnspentOutputObject {
        let fromAddress = BTCAddress(base58String: mainAddress0)
        var unspentOutput = NSMutableDictionary()
        unspentOutput.setObject(TLWalletUtils.reverseHexString(txid), forKey: "tx_hash" as NSCopying)
        unspentOutput.setObject(txid, forKey: "tx_hash_big_endian" as NSCopying)
        unspentOutput.setObject(txOutputN, forKey: "tx_output_n" as NSCopying)
        unspentOutput.setObject(BTCScript(address: fromAddress).hex, forKey: "script" as NSCopying)
        unspentOutput.setObject(NSNumber(value: value as UInt64), forKey: "value" as NSCopying)
        unspentOutput.setObject(6, forKey: "confirmations" as NSCopying)
        return TLUnspentOutputObject(unspentOutput)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSignature() {
        let privKey = "4e422fb1e5e1db6c1f6ab32a7706d368ceb385e7fab098e633c5c5949c3b97cd"
        let challenge = "0000000000000000104424c7eda87ebd4a690b9efa09abc0ec23f2ae4c64cc4e"
        let key = BTCKey(privateKey: BTCDataFromHex(privKey))
        let signature = key?.signature(forMessage: challenge)
        NSLog("signature: %@", signature!.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters))
        XCTAssertTrue((key?.isValidSignature(signature, forMessage: challenge))!, "")
    }
    func testStealthAddress() {
        let expectedStealthAddress = "vJmujDzf2PyDEcLQEQWyzVNthLpRAXqTi3ZencThu2WCzrRNi64eFYJP6ZyPWj53hSZBKTcUAk8J5Mb8rZC4wvGn77Sj4Z3yP7zE69"
        let expectedScanPublicKey = "02a13daf6cc5ad7a1adcae59ff348a005247aa9e84453770d0e0ee96b894f8bbb1"
        let scanPrivateKey = "d63e1ca7e79bafd8fdc7e568c6b3fcf8a287ad328e80376e6582af2e69943eca"
        let expectedSpendPublicKey = "02c55695f16cd320fef70ff6f46601cdeed655d9198d555a533382fb81a8f6eab5"
        let spendPrivateKey = "c4054001795dd20c740d5d1389e080b424a9ff2ec9503aa3182369f4b71f00ac"
        let ephemeralPublicKey = "02d53b53c3cb7d6e8f4925e404ce40ec9edd81b0b03d49da950deb3c2240ca519a"
        let ephemeralPrivateKey = "dc406d598685e3400a7eff2d952d47f999de9f69d5ff1295302ad7314a2cf979"
        let paymentAddressPublicKey = "02da20a21ac1332edd5352306104f7a751b45e52bf4a41d4c350ccb890301d80e6"
        let paymentAddressPrivateKey = "775c912899b27ee8a1f944c0e2ac90e095f63893d39c3d66d0dd0a854b799eb5"
        
        let isTestNet = false
        
        let stealthAddress = TLStealthAddress.createStealthAddress(expectedScanPublicKey as NSString, spendPublicKey:expectedSpendPublicKey as NSString, isTestnet:isTestNet)
        NSLog("stealthAddress: %@", stealthAddress)
        XCTAssertTrue(stealthAddress == expectedStealthAddress)
        
        
        let publicKeys = TLStealthAddress.getScanPublicKeyAndSpendPublicKey(stealthAddress, isTestnet:isTestNet)
        let scanPublicKey = publicKeys.0
        let spendPublicKey = publicKeys.1
        XCTAssertTrue(scanPublicKey == expectedScanPublicKey, "scanPublicKey != scanPublicKey")
        XCTAssertTrue(spendPublicKey == expectedSpendPublicKey, "spendPublicKey != spendPublicKey")
        
        let nonce:UInt32 = 0xdeadbeef
        
        let stealthDataScriptAndPaymentAddress = TLStealthAddress.createDataScriptAndPaymentAddress(stealthAddress,
            ephemeralPrivateKey:ephemeralPrivateKey, nonce:nonce, isTestnet:isTestNet)
        let expectedStealthDataScript = String(format:"%02x%02x%02x%x%@",
            BTCOpcode.OP_RETURN.rawValue,
            TLStealthAddress.getStealthAddressMsgSize(),
            TLStealthAddress.getStealthAddressTransacionVersion(),
            nonce,
            ephemeralPublicKey)
        
        XCTAssertTrue(stealthDataScriptAndPaymentAddress.0 == expectedStealthDataScript)
        
        let key = BTCKey(publicKey:paymentAddressPublicKey.hexToData())
        let paymentAddress = key?.address.base58String
        XCTAssertTrue(stealthDataScriptAndPaymentAddress.1 == paymentAddress)
        
        NSLog("stealthDataScript: %@", stealthDataScriptAndPaymentAddress.0)
        NSLog("paymentAddress: %@", stealthDataScriptAndPaymentAddress.1)
        
        let stealthDataScript = stealthDataScriptAndPaymentAddress.0
        let publicKey = TLStealthAddress.getPaymentAddressPublicKeyFromScript(stealthDataScript, scanPrivateKey:scanPrivateKey, spendPublicKey:spendPublicKey)
        
        XCTAssertTrue(publicKey == paymentAddressPublicKey)
        
        let secret = TLStealthAddress.getPaymentAddressPrivateKeySecretFromScript(stealthDataScript, scanPrivateKey:scanPrivateKey, spendPrivateKey:spendPrivateKey)
        XCTAssertTrue(secret == paymentAddressPrivateKey)
        
        XCTAssertTrue(TLStealthAddress.isStealthAddress(expectedStealthAddress, isTestnet:false))
        XCTAssertTrue(!TLStealthAddress.isStealthAddress(expectedStealthAddress, isTestnet:true))
    }
    
    func testStealthAddress2() {
        let addr = "vJmujDzf2PyDEcLQEQWyzVNthLpRAXqTi3ZencThu2WCzrRNi64eFYJP6ZyPWj53hSZBKTcUAk8J5Mb8rZC4wvGn77Sj4Z3yP7zE69"
        let scanPublicKey = "02a13daf6cc5ad7a1adcae59ff348a005247aa9e84453770d0e0ee96b894f8bbb1"
        let scanPrivateKey = "d63e1ca7e79bafd8fdc7e568c6b3fcf8a287ad328e80376e6582af2e69943eca"
        let spendPublicKey = "02c55695f16cd320fef70ff6f46601cdeed655d9198d555a533382fb81a8f6eab5"
        let spendPrivateKey = "c4054001795dd20c740d5d1389e080b424a9ff2ec9503aa3182369f4b71f00ac"
        let ephemeralPublicKey = "02d53b53c3cb7d6e8f4925e404ce40ec9edd81b0b03d49da950deb3c2240ca519a"
        let ephemeralPrivateKey = "dc406d598685e3400a7eff2d952d47f999de9f69d5ff1295302ad7314a2cf979"
        let paymentAddressPublicKey = "02da20a21ac1332edd5352306104f7a751b45e52bf4a41d4c350ccb890301d80e6"
        let paymentAddressPrivateKey = "775c912899b27ee8a1f944c0e2ac90e095f63893d39c3d66d0dd0a854b799eb5"
        
        let stealthDataScript = "6a2606deadbeef02d53b53c3cb7d6e8f4925e404ce40ec9edd81b0b03d49da950deb3c2240ca519a"
        let publicKey = TLStealthAddress.getPaymentAddressPublicKeyFromScript(stealthDataScript, scanPrivateKey: scanPrivateKey, spendPublicKey: spendPublicKey)
        XCTAssertTrue(publicKey == paymentAddressPublicKey)
        NSLog("publicKey: %@", publicKey!)
        var key = BTCKey(publicKey:publicKey!.hexToData())
        NSLog("address: %@", key!.address.base58String)
        XCTAssertTrue(key?.address.base58String == "1C6gQ79qKKG21AGCA9USKYWPvu6LzoPH5h")
        
        let secret = TLStealthAddress.getPaymentAddressPrivateKeySecretFromScript(stealthDataScript, scanPrivateKey:scanPrivateKey, spendPrivateKey:spendPrivateKey)
        NSLog("secret: %@", secret!)
        key = BTCKey(privateKey: BTCDataFromHex(secret))
        key?.isPublicKeyCompressed = true
        
        NSLog("address: %@", key!.address.base58String)
        
        XCTAssertTrue(secret == paymentAddressPrivateKey)
        XCTAssertTrue(key?.address.base58String == "1C6gQ79qKKG21AGCA9USKYWPvu6LzoPH5h")
        
        let nonce:UInt32 = 0xdeadbeef
        let stealthDataScriptAndPaymentAddress = TLStealthAddress.createDataScriptAndPaymentAddress(addr,
            ephemeralPrivateKey: ephemeralPrivateKey, nonce: nonce, isTestnet: false)
        NSLog("stealthDataScript: %@", stealthDataScriptAndPaymentAddress.0)
        NSLog("paymentAddress: %@", stealthDataScriptAndPaymentAddress.1)
    }
    
    func testEncryptionAndDecryption() {
        NSLog("testEncryptionAndDecryption")
        
        var plainText = "test"
        let pbk = UInt32(2000)
        var cipherText = TLCrypto.encrypt(plainText, password:"pass", PBKDF2Iterations:pbk)
        var decryptedText = TLCrypto.decrypt(cipherText, password:"pass", PBKDF2Iterations:pbk)
        
        NSLog("decryptedText: %@", decryptedText!)
        XCTAssert(plainText == decryptedText)
        
        
        plainText = "test"
        cipherText = TLCrypto.encrypt("test", password:"pass")
        decryptedText = TLCrypto.decrypt(cipherText, password:"pass")
        XCTAssert(plainText == decryptedText)
        
        
        plainText = "test"
        cipherText = TLCrypto.encrypt("test", password:"pass1", PBKDF2Iterations:pbk)
        decryptedText = TLCrypto.decrypt(cipherText, password:"pass2", PBKDF2Iterations:pbk)
        XCTAssert(decryptedText == nil)
        
        plainText = "test"
        cipherText = TLCrypto.encrypt("test", password:"pass", PBKDF2Iterations:pbk)
        decryptedText = TLCrypto.decrypt(cipherText, password:"pass", PBKDF2Iterations:UInt32(1000))
        XCTAssert(true)
    }
    
    func testHDWallet() {
        NSLog("testHDWallet")
        XCTAssertTrue(TLHDWalletWrapper.isValidExtendedPrivateKey("xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U"))
        XCTAssertTrue(!TLHDWalletWrapper.isValidExtendedPrivateKey("xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB"))
        XCTAssertTrue(TLHDWalletWrapper.isValidExtendedPublicKey("xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB"))
        XCTAssertTrue(!TLHDWalletWrapper.isValidExtendedPublicKey("xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U"))
        
        XCTAssertTrue(!TLHDWalletWrapper.isValidExtendedPrivateKey("I'm sorry, Dave. I'm afraid I can't do that"))
        XCTAssertTrue(!TLHDWalletWrapper.isValidExtendedPublicKey("I'm sorry, Dave. I'm afraid I can't do that"))
        
        XCTAssertTrue(!TLHDWalletWrapper.phraseIsValid("report age service frame aspect worry nature toward vendor jungle grit grit"))
        
        let backupPassphrase = "slogan lottery zone helmet fatigue rebuild solve best hint frown conduct ill"
        let masterHex = TLHDWalletWrapper.getMasterHex(backupPassphrase)
        
        XCTAssertTrue(TLHDWalletWrapper.phraseIsValid(backupPassphrase))
        NSLog("masterHex: %@", masterHex)
        XCTAssertTrue(masterHex == "ae3ff5936bf70293eda11b5ea5ee9585fe9b22c9a80b610ee37251a22120e970c75a18bbd95219a0348c7dee40eeb44a4d2480900be8f931d0cf85203f9d94ce")
        
        
        let extendPrivKey = TLHDWalletWrapper.getExtendPrivKey(self.coinType, masterHex: masterHex, accountIdx:0)
        NSLog("extendPrivKey: %@", extendPrivKey)
        XCTAssertTrue("xprv9z2LgaTwJsrjcHqwG9ZFManHWbiUQqwSMYdMvDN4Pr8i7sVf3x8Us9JSQ8FFCT8f7wBDzEVEhTFX3wJdNx2pchEZJ2HNTa4U7NKgM9uWoK6" == extendPrivKey)
        
        
        let extendPubKey = TLHDWalletWrapper.getExtendPubKey(extendPrivKey)
        NSLog("extendPubKey: %@", extendPubKey)
        XCTAssertTrue("xpub6D1h65zq9FR2pmvQNB6Fiij24dYxpJfHimYxibmfxBfgzfpobVSjQwcvFPr7pTATRisprc2YwYYWiysUEvJ1u9iuAQKMNsiLn2PPSrtVFt6" == extendPubKey)
        
        
        let walletConfig = TLWalletConfig(isTestnet: false)
        let mainAddressIndex0 = [0,0]
        let mainAddress0 = TLHDWalletWrapper.getAddress(self.coinType, extendPubKey:extendPubKey, sequence:mainAddressIndex0 as NSArray, isTestnet:walletConfig.isTestnet)
        NSLog("mainAddress0: %@", mainAddress0)
        XCTAssertTrue("1K7fXZeeQydcUvbsfvkMSQmiacV5sKRYQz" == mainAddress0)
        TLHDWalletWrapper.getPrivateKey(self.coinType, extendPrivKey: extendPrivKey as NSString, sequence:mainAddressIndex0 as NSArray, isTestnet:walletConfig.isTestnet)
        let mainPrivKey0 = TLHDWalletWrapper.getPrivateKey(self.coinType, extendPrivKey: extendPrivKey as NSString, sequence:mainAddressIndex0 as NSArray, isTestnet:walletConfig.isTestnet)
        NSLog("mainPrivKey0: %@", mainPrivKey0)
        XCTAssertTrue("KwJhkmrjjg3AEX5gvccNAHCDcXnQLwzyZshnp5yK7vXz1mHKqDDq" == mainPrivKey0)
        
        let mainAddressIndex1 = [0,1]
        let mainAddress1 = TLHDWalletWrapper.getAddress(self.coinType, extendPubKey:extendPubKey, sequence:mainAddressIndex1 as NSArray, isTestnet:walletConfig.isTestnet)
        NSLog("mainAddress1: %@", mainAddress1)
        XCTAssertTrue("12eQLjACXw6XwfGF9kqBwy9U7Se8qGoBuq" == mainAddress1)
        TLHDWalletWrapper.getPrivateKey(self.coinType, extendPrivKey: extendPrivKey as NSString, sequence:mainAddressIndex0 as NSArray, isTestnet:walletConfig.isTestnet)
        let mainPrivKey1 = TLHDWalletWrapper.getPrivateKey(self.coinType, extendPrivKey: extendPrivKey as NSString, sequence:mainAddressIndex1 as NSArray, isTestnet:walletConfig.isTestnet)
        NSLog("mainPrivKey1: %@", mainPrivKey1)
        XCTAssertTrue("KwpCsb3wBGk7E1M9EXcZWZhRoKBoZLNc63RsSP4YspUR53Ndefyr" == mainPrivKey1)
        
        
        let changeAddressIndex0 = [1,0]
        let changeAddress0 = TLHDWalletWrapper.getAddress(self.coinType, extendPubKey:extendPubKey, sequence:changeAddressIndex0 as NSArray, isTestnet:walletConfig.isTestnet)
        NSLog("changeAddress0: %@", changeAddress0)
        XCTAssertTrue("1CvpGn9VxVY1nsWWL3MSWRYaBHdNkCDbmv" == changeAddress0)
        TLHDWalletWrapper.getPrivateKey(self.coinType, extendPrivKey: extendPrivKey as NSString, sequence:changeAddressIndex0 as NSArray, isTestnet:walletConfig.isTestnet)
        let changePrivKey0 = TLHDWalletWrapper.getPrivateKey(self.coinType, extendPrivKey: extendPrivKey as NSString, sequence:changeAddressIndex0 as NSArray, isTestnet:walletConfig.isTestnet)
        NSLog("changePrivKey0: %@", changePrivKey0)
        XCTAssertTrue("L33guNrQHMXdpFd9jpjo2mQzddwLUgUrNzK3KqAM83D9ZU1H5NDN" == changePrivKey0)
        
        let changeAddressIndex1 = [1,1]
        let changeAddress1 = TLHDWalletWrapper.getAddress(self.coinType, extendPubKey:extendPubKey, sequence:changeAddressIndex1 as NSArray, isTestnet:walletConfig.isTestnet)
        NSLog("changeAddress1: %@", changeAddress1)
        XCTAssertTrue("17vnH8d1fBbjX7GZx727X2Y6dheaid2NUR" == changeAddress1)
        TLHDWalletWrapper.getPrivateKey(self.coinType, extendPrivKey: extendPrivKey as NSString, sequence:changeAddressIndex1 as NSArray, isTestnet:walletConfig.isTestnet)
        let changePrivKey1 = TLHDWalletWrapper.getPrivateKey(self.coinType, extendPrivKey: extendPrivKey as NSString, sequence:changeAddressIndex1 as NSArray, isTestnet:walletConfig.isTestnet)
        NSLog("changePrivKey1: %@", changePrivKey1)
        XCTAssertTrue("KwiMiFtWv1PXNN3zV67TC59tWJxPbeagMJU1SSr3uLssAC82UKhf" == changePrivKey1)
    }
    
    func testUtils() {
        NSLog("testUtils")
        
        let txid = "2c441ba4920f03f37866edb5647f2626b64f57ad98b0a8e011af07da0aefcec3"
        
        let txHash = TLWalletUtils.reverseHexString(txid)
        NSLog("txHash: %@", txHash)
        XCTAssertTrue(txHash == "c3ceef0ada07af11e0a8b098ad574fb626267f64b5ed6678f3030f92a41b442c")
        
        let address = TLCoreBitcoinWrapper.getAddressFromOutputScript(self.coinType, scriptHex: "76a9147ab89f9fae3f8043dcee5f7b5467a0f0a6e2f7e188ac", isTestnet: false)
        NSLog("address: %@", address!)
        XCTAssertTrue(address == "1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG")
    }
    
    func testCreateSignedSerializeTransactionHex() {
        NSLog("testCreateSignedSerializeTransactionHex")
        
        let hash = TLWalletUtils.hexStringToData(TLWalletUtils.reverseHexString("935c6975aa65f95cb55616ace8c8bede83b010f7191c0a6d385be1c95992870d"))!
        let script = TLWalletUtils.hexStringToData("76a9149a1c78a507689f6f54b847ad1cef1e614ee23f1e88ac")!
        let address = "1F3sAm6ZtwLAUnj7d38pGFxtP3RVEvtsbV"
        let privateKey = "L4rK1yDtCWekvXuE6oXD9jCYfFNV2cWRpVuPLBcCU2z8TrisoyY1"
        let txHexAndTxHash = TLCoreBitcoinWrapper.createSignedSerializedTransactionHex(self.coinType, hashes: [hash], inputIndexes:[0], inputScripts:[script],
            outputAddresses:[address], outputAmounts:[2500000], privateKeys:[privateKey], outputScripts:nil, isTestnet: false)!
        
        let txHex = txHexAndTxHash.object(forKey: "txHex") as! String
        let txHash = txHexAndTxHash.object(forKey: "txHash") as! String
        let txSize = txHexAndTxHash.object(forKey: "txSize") as! NSNumber

        NSLog("txHash: %@", txHash)
        NSLog("txHex: %@", txHex)
        NSLog("txSize: %@", txSize)

        XCTAssertTrue("121d274734c83488e2bd6a2a3a136823d6099bf5a3517f78931c3ed0b9a2c619" == txHash)
        XCTAssertTrue("01000000010d879259c9e15b386d0a1c19f710b083debec8e8ac1656b55cf965aa75695c93000000006b4830450221009ceebee12f7a6321e39e83a0d0f8ba3db33271439e98addbc2c8518e9dd4d4ab022061965b500a9b1dd154545df086c3cc44661265841c82a4db20c44304711f1a0a012103a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bdffffffff01a0252600000000001976a9149a1c78a507689f6f54b847ad1cef1e614ee23f1e88ac00000000" == txHex)
        XCTAssertTrue(txSize.uintValue == 193)
    }
    
    func testCreateSignedSerializedTransactionHexAndBIP69_1() -> () {
        guard let accountObject = accountObject else {
            return
        }
        let feeAmount = TLCurrencyFormat.amountStringToCoin("0.00000", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        let toAddress = "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv"
        let toAddress2 = "1DZTzaBHUDM7T3QvUKBz4qXMRpkg8jsfB5"
        let toAmount = TLCurrencyFormat.amountStringToCoin("1", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        let toAmount2 = TLCurrencyFormat.amountStringToCoin("24", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        
        let txid0 = "35288d269cee1941eaebb2ea85e32b42cdb2b04284a56d8b14dcc3f5c65d6055"
        let txid1 = "35288d269cee1941eaebb2ea85e32b42cdb2b04284a56d8b14dcc3f5c65d6055"
        
        let unspentOutput0 = mockUnspentOutput(txid0, value: 100000000, txOutputN: 0)
        let unspentOutput1 = mockUnspentOutput(txid1, value: 2400000000, txOutputN: 1)
        
        func testCreateSignedSerializedTransactionHexAndBIP69_1_1() -> () {
            let toAddressesAndAmounts = [["address": toAddress, "amount": toAmount], ["address": toAddress2, "amount": toAmount2]]
            
            accountObject.unspentOutputs = Array<TLUnspentOutputObject>()
            accountObject.unspentOutputs!.append(unspentOutput0)
            accountObject.unspentOutputs!.append(unspentOutput1)
            accountObject.stealthPaymentUnspentOutputs = Array<TLUnspentOutputObject>()

            let ret = TLSpaghettiGodSend.createSignedSerializedTransactionHex(isTestnet, coinType: accountObject.getSelectedObjectCoinType(),  sendFromAccounts: sendFromAccounts, sendFromAddresses: sendFromAddresses, toAddressesAndAmounts: toAddressesAndAmounts as NSArray, feeAmount: feeAmount, error: {
                (data: String?) in
            })
            
            let txHexAndTxHash = ret.0
            let realToAddresses = ret.1
            let txHex = txHexAndTxHash!.object(forKey: "txHex") as! String
            let txHash = txHexAndTxHash!.object(forKey: "txHash") as! String
            let txSize = txHexAndTxHash!.object(forKey: "txSize") as! NSNumber
            XCTAssertTrue(txHash == "fbacfede55dc6a779782ba8fa22813860b7ef07d82c3abebb8f290b3141bf965")
            XCTAssertTrue(txHex == "010000000255605dc6f5c3dc148b6da58442b0b2cd422be385eab2ebea4119ee9c268d2835000000006a4730440220449b1f95687bf469fb954bcdbbc0ae362fe9bd6ba88c5b4dd227d9a5c37eb82a02203440bf6b4178786913a197344d0999a7d98d246099dcddf4bf9b24473a4e7a9a0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff55605dc6f5c3dc148b6da58442b0b2cd422be385eab2ebea4119ee9c268d2835010000006a47304402201f6a4a87d0584157471210c1e126e64e52f565e950feb80045fc855829df3da4022059fd75fe51262aa7b7f214534357ed2786a9b3dcb12493112027711aebc8478a0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff0200e1f505000000001976a914c73015fa62d972ebb3b241fe8c936657b13fabd788ac00180d8f000000001976a91489c55a3ca6676c9f7f260a6439c83249b747380288ac00000000")
            XCTAssertTrue(txSize.uintValue == 376)
            
            let transaction = BTCTransaction(hex: txHex)
            
            XCTAssertTrue(transaction?.inputs.count == 2)
            let input0 = transaction?.inputs[0] as! BTCTransactionInput
            XCTAssertTrue(input0.previousTransactionID == txid0)
            XCTAssertTrue(input0.outpoint.index == 0)
            let input1 = transaction?.inputs[1] as! BTCTransactionInput
            XCTAssertTrue(input1.previousTransactionID == txid1)
            XCTAssertTrue(input1.outpoint.index == 1)
            
            XCTAssertTrue(transaction?.outputs.count == 2)
            let output0 = transaction?.outputs[0] as! BTCTransactionOutput
            XCTAssertTrue(output0.script.hex == "76a914c73015fa62d972ebb3b241fe8c936657b13fabd788ac")
            XCTAssertTrue(output0.value == 100000000)
            XCTAssertTrue(output0.script.standardAddress.base58String == "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv")
            let output1 = transaction?.outputs[1] as! BTCTransactionOutput
            XCTAssertTrue(output1.script.hex == "76a91489c55a3ca6676c9f7f260a6439c83249b747380288ac")
            XCTAssertTrue(output1.value == 2400000000)
            XCTAssertTrue(output1.script.standardAddress.base58String == "1DZTzaBHUDM7T3QvUKBz4qXMRpkg8jsfB5")
            
            XCTAssertTrue(realToAddresses.count == 2)
            XCTAssertTrue(realToAddresses[0] == "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv")
            XCTAssertTrue(realToAddresses[1] == "1DZTzaBHUDM7T3QvUKBz4qXMRpkg8jsfB5")
        }
        
        func testCreateSignedSerializedTransactionHexAndBIP69_1_2() -> () {
            let toAddressesAndAmounts = [["address": toAddress2, "amount": toAmount2], ["address": toAddress, "amount": toAmount]]
            
            accountObject.unspentOutputs = Array<TLUnspentOutputObject>()
            accountObject.unspentOutputs!.append(unspentOutput0)
            accountObject.unspentOutputs!.append(unspentOutput1)
            accountObject.stealthPaymentUnspentOutputs = Array<TLUnspentOutputObject>()
            
            let ret = TLSpaghettiGodSend.createSignedSerializedTransactionHex(isTestnet, coinType: accountObject.getSelectedObjectCoinType(),  sendFromAccounts: sendFromAccounts, sendFromAddresses: sendFromAddresses, toAddressesAndAmounts: toAddressesAndAmounts as NSArray, feeAmount: feeAmount, error: {
                (data: String?) in
            })
            
            let txHexAndTxHash = ret.0
            let realToAddresses = ret.1
            let txHex = txHexAndTxHash!.object(forKey: "txHex") as! String
            let txHash = txHexAndTxHash!.object(forKey: "txHash") as! String
            let txSize = txHexAndTxHash!.object(forKey: "txSize") as! NSNumber
            XCTAssertTrue(txHash == "fbacfede55dc6a779782ba8fa22813860b7ef07d82c3abebb8f290b3141bf965")
            XCTAssertTrue(txHex == "010000000255605dc6f5c3dc148b6da58442b0b2cd422be385eab2ebea4119ee9c268d2835000000006a4730440220449b1f95687bf469fb954bcdbbc0ae362fe9bd6ba88c5b4dd227d9a5c37eb82a02203440bf6b4178786913a197344d0999a7d98d246099dcddf4bf9b24473a4e7a9a0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff55605dc6f5c3dc148b6da58442b0b2cd422be385eab2ebea4119ee9c268d2835010000006a47304402201f6a4a87d0584157471210c1e126e64e52f565e950feb80045fc855829df3da4022059fd75fe51262aa7b7f214534357ed2786a9b3dcb12493112027711aebc8478a0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff0200e1f505000000001976a914c73015fa62d972ebb3b241fe8c936657b13fabd788ac00180d8f000000001976a91489c55a3ca6676c9f7f260a6439c83249b747380288ac00000000")
            XCTAssertTrue(txSize.uintValue == 376)
            
            let transaction = BTCTransaction(hex: txHex)
            
            XCTAssertTrue(transaction?.inputs.count == 2)
            let input0 = transaction?.inputs[0] as! BTCTransactionInput
            XCTAssertTrue(input0.previousTransactionID == txid0)
            XCTAssertTrue(input0.outpoint.index == 0)
            let input1 = transaction?.inputs[1] as! BTCTransactionInput
            XCTAssertTrue(input1.previousTransactionID == txid1)
            XCTAssertTrue(input1.outpoint.index == 1)
            
            XCTAssertTrue(transaction?.outputs.count == 2)
            let output0 = transaction?.outputs[0] as! BTCTransactionOutput
            XCTAssertTrue(output0.script.hex == "76a914c73015fa62d972ebb3b241fe8c936657b13fabd788ac")
            XCTAssertTrue(output0.value == 100000000)
            XCTAssertTrue(output0.script.standardAddress.base58String == "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv")
            let output1 = transaction?.outputs[1] as! BTCTransactionOutput
            XCTAssertTrue(output1.script.hex == "76a91489c55a3ca6676c9f7f260a6439c83249b747380288ac")
            XCTAssertTrue(output1.value == 2400000000)
            XCTAssertTrue(output1.script.standardAddress.base58String == "1DZTzaBHUDM7T3QvUKBz4qXMRpkg8jsfB5")
            
            XCTAssertTrue(realToAddresses.count == 2)
            XCTAssertTrue(realToAddresses[0] == "1DZTzaBHUDM7T3QvUKBz4qXMRpkg8jsfB5")
            XCTAssertTrue(realToAddresses[1] == "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv")
        }
        testCreateSignedSerializedTransactionHexAndBIP69_1_1()
        testCreateSignedSerializedTransactionHexAndBIP69_1_2()
    }
    
    func testCreateSignedSerializedTransactionHexAndBIP69_2() -> () {
        guard let accountObject = accountObject else {
            return
        }
        let feeAmount = TLCurrencyFormat.amountStringToCoin("0.00002735", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        let toAddress = "17nFgS1YaDPnXKMPQkZVdNQqZnVqRgBwnZ"
        let toAddress2 = "19Nrc2Xm226xmSbeGZ1BVtX7DUm4oCx8Pm"
        let toAmount = TLCurrencyFormat.amountStringToCoin("4.00057456", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        let toAmount2 = TLCurrencyFormat.amountStringToCoin("400", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        
        let txid0 = "0e53ec5dfb2cb8a71fec32dc9a634a35b7e24799295ddd5278217822e0b31f57"
        let txid1 = "26aa6e6d8b9e49bb0630aac301db6757c02e3619feb4ee0eea81eb1672947024"
        let txid2 = "28e0fdd185542f2c6ea19030b0796051e7772b6026dd5ddccd7a2f93b73e6fc2"
        let txid3 = "381de9b9ae1a94d9c17f6a08ef9d341a5ce29e2e60c36a52d333ff6203e58d5d"
        let txid4 = "3b8b2f8efceb60ba78ca8bba206a137f14cb5ea4035e761ee204302d46b98de2"
        let txid5 = "402b2c02411720bf409eff60d05adad684f135838962823f3614cc657dd7bc0a"
        let txid6 = "54ffff182965ed0957dba1239c27164ace5a73c9b62a660c74b7b7f15ff61e7a"
        let txid7 = "643e5f4e66373a57251fb173151e838ccd27d279aca882997e005016bb53d5aa"
        let txid8 = "6c1d56f31b2de4bfc6aaea28396b333102b1f600da9c6d6149e96ca43f1102b1"
        let txid9 = "7a1de137cbafb5c70405455c49c5104ca3057a1f1243e6563bb9245c9c88c191"
        let txid10 = "7d037ceb2ee0dc03e82f17be7935d238b35d1deabf953a892a4507bfbeeb3ba4"
        let txid11 = "a5e899dddb28776ea9ddac0a502316d53a4a3fca607c72f66c470e0412e34086"
        let txid12 = "b4112b8f900a7ca0c8b0e7c4dfad35c6be5f6be46b3458974988e1cdb2fa61b8"
        let txid13 = "bafd65e3c7f3f9fdfdc1ddb026131b278c3be1af90a4a6ffa78c4658f9ec0c85"
        let txid14 = "de0411a1e97484a2804ff1dbde260ac19de841bebad1880c782941aca883b4e9"
        let txid15 = "f0a130a84912d03c1d284974f563c5949ac13f8342b8112edff52971599e6a45"
        let txid16 = "f320832a9d2e2452af63154bc687493484a0e7745ebd3aaf9ca19eb80834ad60"
        
        let unspentOutput0 = mockUnspentOutput(txid0, value: 2529937904, txOutputN: 0)
        let unspentOutput1 = mockUnspentOutput(txid1, value: 2521656792, txOutputN: 1)
        let unspentOutput2 = mockUnspentOutput(txid2, value: 2509683086, txOutputN: 0)
        let unspentOutput3 = mockUnspentOutput(txid3, value: 2506060377, txOutputN: 1)
        let unspentOutput4 = mockUnspentOutput(txid4, value: 2510645247, txOutputN: 0)
        let unspentOutput5 = mockUnspentOutput(txid5, value: 2502325820, txOutputN: 1)
        let unspentOutput6 = mockUnspentOutput(txid6, value: 2525953727, txOutputN: 1)
        let unspentOutput7 = mockUnspentOutput(txid7, value: 2507302856, txOutputN: 0)
        let unspentOutput8 = mockUnspentOutput(txid8, value: 2534185804, txOutputN: 1)
        let unspentOutput9 = mockUnspentOutput(txid9, value: 136219905, txOutputN: 0)
        let unspentOutput10 = mockUnspentOutput(txid10, value: 2502901118, txOutputN: 1)
        let unspentOutput11 = mockUnspentOutput(txid11, value: 2527569363, txOutputN: 0)
        let unspentOutput12 = mockUnspentOutput(txid12, value: 2516268302, txOutputN: 0)
        let unspentOutput13 = mockUnspentOutput(txid13, value: 2521794404, txOutputN: 0)
        let unspentOutput14 = mockUnspentOutput(txid14, value: 2520533680, txOutputN: 1)
        let unspentOutput15 = mockUnspentOutput(txid15, value: 2513840095, txOutputN: 0)
        let unspentOutput16 = mockUnspentOutput(txid16, value: 2513181711, txOutputN: 0)
        
        func testCreateSignedSerializedTransactionHexAndBIP69_2_1() -> () {
            let toAddressesAndAmounts = [["address": toAddress, "amount": toAmount], ["address": toAddress2, "amount": toAmount2]]
            
            accountObject.unspentOutputs = Array<TLUnspentOutputObject>()
            accountObject.unspentOutputs!.append(unspentOutput0)
            accountObject.unspentOutputs!.append(unspentOutput1)
            accountObject.unspentOutputs!.append(unspentOutput2)
            accountObject.unspentOutputs!.append(unspentOutput3)
            accountObject.unspentOutputs!.append(unspentOutput4)
            accountObject.unspentOutputs!.append(unspentOutput5)
            accountObject.unspentOutputs!.append(unspentOutput6)
            accountObject.unspentOutputs!.append(unspentOutput7)
            accountObject.unspentOutputs!.append(unspentOutput8)
            accountObject.unspentOutputs!.append(unspentOutput9)
            accountObject.unspentOutputs!.append(unspentOutput10)
            accountObject.unspentOutputs!.append(unspentOutput11)
            accountObject.unspentOutputs!.append(unspentOutput12)
            accountObject.unspentOutputs!.append(unspentOutput13)
            accountObject.unspentOutputs!.append(unspentOutput14)
            accountObject.unspentOutputs!.append(unspentOutput15)
            accountObject.unspentOutputs!.append(unspentOutput16)
            accountObject.stealthPaymentUnspentOutputs = Array<TLUnspentOutputObject>()
            
            let ret = TLSpaghettiGodSend.createSignedSerializedTransactionHex(isTestnet, coinType: accountObject.getSelectedObjectCoinType(),  sendFromAccounts: sendFromAccounts, sendFromAddresses: sendFromAddresses, toAddressesAndAmounts: toAddressesAndAmounts as NSArray, feeAmount: feeAmount, error: {
                (data: String?) in
            })
            
            let txHexAndTxHash = ret.0
            let realToAddresses = ret.1
            let txHex = txHexAndTxHash!.object(forKey: "txHex") as! String
            let txHash = txHexAndTxHash!.object(forKey: "txHash") as! String
            let txSize = txHexAndTxHash!.object(forKey: "txSize") as! NSNumber
            XCTAssertTrue(txHash == "0656add012962ef3bdd11eaf88347b78a2c4adb08fe8b95f79a8b8a4fe862132")
            XCTAssertTrue(txHex == "0100000011571fb3e02278217852dd5d299947e2b7354a639adc32ec1fa7b82cfb5dec530e000000006b483045022100b28348624779833117dc8ae73bcb649528ad6edf9d5b48018c4488dbc9b9fa3702201f8b0e1707bdfa3438d6c1353b62e3a01cb0b7b4ee5e7ef93e7b2f563ead66a30121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff2470947216eb81ea0eeeb4fe19362ec05767db01c3aa3006bb499e8b6d6eaa26010000006a4730440220679db98b1e5b17a57acc78e7271c357130fd8b6d8d2072880429d05630c5cc2802205fb88f764053185d610ae8041907bdb85f711a51f5602bb663b744e786fd78700121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffc26f3eb7932f7acddc5ddd26602b77e7516079b03090a16e2c2f5485d1fde028000000006a47304402205031699fc96af02637f1ed7120c0e380f65370824f6af5cd37baf391f8188f73022026f5ba7a7f31fc3590f1e4dce50f12cc2122ce3fe30d187f11c3922ce3b22d0a0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff5d8de50362ff33d3526ac3602e9ee25c1a349def086a7fc1d9941aaeb9e91d38010000006b483045022100fefda0743cc428b17e688c65d226e899af8b0d5a6f05d0944f9c67257fa5a15a02207baa0a95d88b98b0b669cab8342cc43bc992daf3be41c4ba40de77453ed3fb220121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffe28db9462d3004e21e765e03a45ecb147f136a20ba8bca78ba60ebfc8e2f8b3b000000006b483045022100a54a4e0a3b476c855273a0aa6d97f5995e78a83cad59c28cda786b49a14f370602202cce0aadf128986b6448ad7f3288f95c9c5467ba01d16e94d807db587e481fe30121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff0abcd77d65cc14363f8262898335f184d6da5ad060ff9e40bf201741022c2b40010000006a4730440220636b2a05ef164457c9b8ee0f364c308a7ef8a0f5f7b01d6633ace40803a6fd7902205f052f39e940d2b8d797a5259ee35d0596a0dbfd199799722d95a895308bd1f10121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff7a1ef65ff1b7b7740c662ab6c9735ace4a16279c23a1db5709ed652918ffff54010000006b4830450221008e3f42e8e5d45712efe14c17ba199724e1d2bcaa2a459ede155b2df89d1b8c7902205260062b1eb6595a43180f0b40307467f4fe2f67138c2aed47d21dac739f4a770121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffaad553bb1650007e9982a8ac79d227cd8c831e1573b11f25573a37664e5f3e64000000006a47304402204b3a8b40ea4bd092ce05ae5a55704d98ceee485b87e9d9bbc1dcc0956a2230bb022043b2660c1513b029038a3f2492c2d0d39b45c04a14b1143ede43abb6832d6f910121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffb102113fa46ce949616d9cda00f6b10231336b3928eaaac6bfe42d1bf3561d6c010000006a4730440220651a1d62ba88ac05790bab2ead82483e99a748965cd8f1887c943c62c67786de022002bc57e36c7668c8e5d4c02e1baed3491b30d91e53633b807ca950b8bfad6fe90121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff91c1889c5c24b93b56e643121f7a05a34c10c5495c450504c7b5afcb37e11d7a000000006b483045022100ea05603d2944228bd2231354b1a6e6d106a803d7d52e8a290232b9769629c9a502204125264bb9d2cfd2db5455044d58a7b8ea8e0c7c88870def8c0fac2c559c5cfc0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffa43bebbebf07452a893a95bfea1d5db338d23579be172fe803dce02eeb7c037d010000006b483045022100fe8ce378ed72b0829805dde89cb16d2f6722f8b4128ee07f6ef064eaa4b607f702206400a9816e120e3e7427f4e83518b2822f010c219bcb758560ff280aae1cbe420121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff8640e312040e476cf6727c60ca3f4a3ad51623500aacdda96e7728dbdd99e8a5000000006a47304402203cce0a54d3314decb5adf1d9dbe5f887eb779daf6d4d2ce463435181da6cc72302206104213df446b9fc78d598c8425c82ca9b0952fab48a9edecb382ee5e68c11fe0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffb861fab2cde188499758346be46b5fbec635addfc4e7b0c8a07c0a908f2b11b4000000006a4730440220120d5d6672695c9ad3e72049da00be123bab74971386953b38409ff52989ce2502202b8702ba2d7fe90fc35aef52585c664865ae746d9e4242955b7ece22d89ad1ca0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff850cecf958468ca7ffa6a490afe13b8c271b1326b0ddc1fdfdf9f3c7e365fdba000000006a4730440220282a14909d8ed766441c4766a574af0fc20e1b587e545e1943429670457b959602207e4c7503ae3c9de83865d0972fbb18cd7c9630023347d6eba45963f0670ef7e70121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffe9b483a8ac4129780c88d1babe41e89dc10a26dedbf14f80a28474e9a11104de010000006b483045022100ec3744090e0603690319768ef234071410224230cc32e4731e50f9e8a05a6a5802203a1a8f7380e83fd1b61f4fd775aa6410d2e87d018b820aab4e98e1a8de0715f10121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff456a9e597129f5df2e11b842833fc19a94c563f57449281d3cd01249a830a1f0000000006a473044022060b06dcb2550beb9dd4181a45566ccf0ba41040d9003aa83c02fb63c4f9cbd8a02203c577c070c69382cfb05c74275590e3de6dcb77ce929b0d771f314ffa889f47c0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff60ad3408b89ea19caf3abd5e74e7a084344987c64b1563af52242e9d2a8320f3000000006b483045022100d7b08a358ce19469d369765c38d1f17ffe66151f7c9cd85757d89d4f218a9d390220418f13a4b8eb41ca471901f1ba2b1677166f90127b65b7417ad5a62d76f0b8c80121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff027064d817000000001976a9144a5fba237213a062f6f57978f796390bdcf8d01588ac00902f50090000001976a9145be32612930b8323add2212a4ec03c1562084f8488ac00000000")
            XCTAssertTrue(txSize.uintValue == 2611)
            
            let transaction = BTCTransaction(hex: txHex)
            
            XCTAssertTrue(transaction?.inputs.count == 17)
            let input0 = transaction?.inputs[0] as! BTCTransactionInput
            XCTAssertTrue(input0.previousTransactionID == txid0)
            XCTAssertTrue(input0.outpoint.index == 0)
            let input1 = transaction?.inputs[1] as! BTCTransactionInput
            XCTAssertTrue(input1.previousTransactionID == txid1)
            XCTAssertTrue(input1.outpoint.index == 1)
            let input2 = transaction?.inputs[2] as! BTCTransactionInput
            XCTAssertTrue(input2.previousTransactionID == txid2)
            XCTAssertTrue(input2.outpoint.index == 0)
            let input3 = transaction?.inputs[3] as! BTCTransactionInput
            XCTAssertTrue(input3.previousTransactionID == txid3)
            XCTAssertTrue(input3.outpoint.index == 1)
            let input4 = transaction?.inputs[4] as! BTCTransactionInput
            XCTAssertTrue(input4.previousTransactionID == txid4)
            XCTAssertTrue(input4.outpoint.index == 0)
            let input5 = transaction?.inputs[5] as! BTCTransactionInput
            XCTAssertTrue(input5.previousTransactionID == txid5)
            XCTAssertTrue(input5.outpoint.index == 1)
            let input6 = transaction?.inputs[6] as! BTCTransactionInput
            XCTAssertTrue(input6.previousTransactionID == txid6)
            XCTAssertTrue(input6.outpoint.index == 1)
            let input7 = transaction?.inputs[7] as! BTCTransactionInput
            XCTAssertTrue(input7.previousTransactionID == txid7)
            XCTAssertTrue(input7.outpoint.index == 0)
            let input8 = transaction?.inputs[8] as! BTCTransactionInput
            XCTAssertTrue(input8.previousTransactionID == txid8)
            XCTAssertTrue(input8.outpoint.index == 1)
            let input9 = transaction?.inputs[9] as! BTCTransactionInput
            XCTAssertTrue(input9.previousTransactionID == txid9)
            XCTAssertTrue(input9.outpoint.index == 0)
            let input10 = transaction?.inputs[10] as! BTCTransactionInput
            XCTAssertTrue(input10.previousTransactionID == txid10)
            XCTAssertTrue(input10.outpoint.index == 1)
            let input11 = transaction?.inputs[11] as! BTCTransactionInput
            XCTAssertTrue(input11.previousTransactionID == txid11)
            XCTAssertTrue(input11.outpoint.index == 0)
            let input12 = transaction?.inputs[12] as! BTCTransactionInput
            XCTAssertTrue(input12.previousTransactionID == txid12)
            XCTAssertTrue(input12.outpoint.index == 0)
            let input13 = transaction?.inputs[13] as! BTCTransactionInput
            XCTAssertTrue(input13.previousTransactionID == txid13)
            XCTAssertTrue(input13.outpoint.index == 0)
            let input14 = transaction?.inputs[14] as! BTCTransactionInput
            XCTAssertTrue(input14.previousTransactionID == txid14)
            XCTAssertTrue(input14.outpoint.index == 1)
            let input15 = transaction?.inputs[15] as! BTCTransactionInput
            XCTAssertTrue(input15.previousTransactionID == txid15)
            XCTAssertTrue(input15.outpoint.index == 0)
            let input16 = transaction?.inputs[16] as! BTCTransactionInput
            XCTAssertTrue(input16.previousTransactionID == txid16)
            XCTAssertTrue(input16.outpoint.index == 0)
            
            XCTAssertTrue(transaction?.outputs.count == 2)
            let output0 = transaction?.outputs[0] as! BTCTransactionOutput
            XCTAssertTrue(output0.script.hex == "76a9144a5fba237213a062f6f57978f796390bdcf8d01588ac")
            XCTAssertTrue(output0.value == 400057456)
            XCTAssertTrue(output0.script.standardAddress.base58String == "17nFgS1YaDPnXKMPQkZVdNQqZnVqRgBwnZ")
            let output1 = transaction?.outputs[1] as! BTCTransactionOutput
            XCTAssertTrue(output1.script.hex == "76a9145be32612930b8323add2212a4ec03c1562084f8488ac")
            XCTAssertTrue(output1.value == 40000000000)
            XCTAssertTrue(output1.script.standardAddress.base58String == "19Nrc2Xm226xmSbeGZ1BVtX7DUm4oCx8Pm")
            
            XCTAssertTrue(realToAddresses.count == 2)
            XCTAssertTrue(realToAddresses[0] == "17nFgS1YaDPnXKMPQkZVdNQqZnVqRgBwnZ")
            XCTAssertTrue(realToAddresses[1] == "19Nrc2Xm226xmSbeGZ1BVtX7DUm4oCx8Pm")
        }
        
        func testCreateSignedSerializedTransactionHexAndBIP69_2_2() -> () {
            let toAddressesAndAmounts = [["address": toAddress2, "amount": toAmount2], ["address": toAddress, "amount": toAmount]]
            
            accountObject.unspentOutputs = Array<TLUnspentOutputObject>()
            accountObject.unspentOutputs!.append(unspentOutput15)
            accountObject.unspentOutputs!.append(unspentOutput2)
            accountObject.unspentOutputs!.append(unspentOutput0)
            accountObject.unspentOutputs!.append(unspentOutput1)
            accountObject.unspentOutputs!.append(unspentOutput5)
            accountObject.unspentOutputs!.append(unspentOutput3)
            accountObject.unspentOutputs!.append(unspentOutput4)
            accountObject.unspentOutputs!.append(unspentOutput6)
            accountObject.unspentOutputs!.append(unspentOutput7)
            accountObject.unspentOutputs!.append(unspentOutput9)
            accountObject.unspentOutputs!.append(unspentOutput10)
            accountObject.unspentOutputs!.append(unspentOutput8)
            accountObject.unspentOutputs!.append(unspentOutput12)
            accountObject.unspentOutputs!.append(unspentOutput11)
            accountObject.unspentOutputs!.append(unspentOutput14)
            accountObject.unspentOutputs!.append(unspentOutput16)
            accountObject.unspentOutputs!.append(unspentOutput13)
            accountObject.stealthPaymentUnspentOutputs = Array<TLUnspentOutputObject>()
            
            let ret = TLSpaghettiGodSend.createSignedSerializedTransactionHex(isTestnet, coinType: accountObject.getSelectedObjectCoinType(),  sendFromAccounts: sendFromAccounts, sendFromAddresses: sendFromAddresses, toAddressesAndAmounts: toAddressesAndAmounts as NSArray, feeAmount: feeAmount, error: {
                (data: String?) in
            })
            
            let txHexAndTxHash = ret.0
            let realToAddresses = ret.1
            let txHex = txHexAndTxHash!.object(forKey: "txHex") as! String
            let txHash = txHexAndTxHash!.object(forKey: "txHash") as! String
            let txSize = txHexAndTxHash!.object(forKey: "txSize") as! NSNumber
            XCTAssertTrue(txHash == "0656add012962ef3bdd11eaf88347b78a2c4adb08fe8b95f79a8b8a4fe862132")
            XCTAssertTrue(txHex == "0100000011571fb3e02278217852dd5d299947e2b7354a639adc32ec1fa7b82cfb5dec530e000000006b483045022100b28348624779833117dc8ae73bcb649528ad6edf9d5b48018c4488dbc9b9fa3702201f8b0e1707bdfa3438d6c1353b62e3a01cb0b7b4ee5e7ef93e7b2f563ead66a30121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff2470947216eb81ea0eeeb4fe19362ec05767db01c3aa3006bb499e8b6d6eaa26010000006a4730440220679db98b1e5b17a57acc78e7271c357130fd8b6d8d2072880429d05630c5cc2802205fb88f764053185d610ae8041907bdb85f711a51f5602bb663b744e786fd78700121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffc26f3eb7932f7acddc5ddd26602b77e7516079b03090a16e2c2f5485d1fde028000000006a47304402205031699fc96af02637f1ed7120c0e380f65370824f6af5cd37baf391f8188f73022026f5ba7a7f31fc3590f1e4dce50f12cc2122ce3fe30d187f11c3922ce3b22d0a0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff5d8de50362ff33d3526ac3602e9ee25c1a349def086a7fc1d9941aaeb9e91d38010000006b483045022100fefda0743cc428b17e688c65d226e899af8b0d5a6f05d0944f9c67257fa5a15a02207baa0a95d88b98b0b669cab8342cc43bc992daf3be41c4ba40de77453ed3fb220121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffe28db9462d3004e21e765e03a45ecb147f136a20ba8bca78ba60ebfc8e2f8b3b000000006b483045022100a54a4e0a3b476c855273a0aa6d97f5995e78a83cad59c28cda786b49a14f370602202cce0aadf128986b6448ad7f3288f95c9c5467ba01d16e94d807db587e481fe30121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff0abcd77d65cc14363f8262898335f184d6da5ad060ff9e40bf201741022c2b40010000006a4730440220636b2a05ef164457c9b8ee0f364c308a7ef8a0f5f7b01d6633ace40803a6fd7902205f052f39e940d2b8d797a5259ee35d0596a0dbfd199799722d95a895308bd1f10121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff7a1ef65ff1b7b7740c662ab6c9735ace4a16279c23a1db5709ed652918ffff54010000006b4830450221008e3f42e8e5d45712efe14c17ba199724e1d2bcaa2a459ede155b2df89d1b8c7902205260062b1eb6595a43180f0b40307467f4fe2f67138c2aed47d21dac739f4a770121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffaad553bb1650007e9982a8ac79d227cd8c831e1573b11f25573a37664e5f3e64000000006a47304402204b3a8b40ea4bd092ce05ae5a55704d98ceee485b87e9d9bbc1dcc0956a2230bb022043b2660c1513b029038a3f2492c2d0d39b45c04a14b1143ede43abb6832d6f910121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffb102113fa46ce949616d9cda00f6b10231336b3928eaaac6bfe42d1bf3561d6c010000006a4730440220651a1d62ba88ac05790bab2ead82483e99a748965cd8f1887c943c62c67786de022002bc57e36c7668c8e5d4c02e1baed3491b30d91e53633b807ca950b8bfad6fe90121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff91c1889c5c24b93b56e643121f7a05a34c10c5495c450504c7b5afcb37e11d7a000000006b483045022100ea05603d2944228bd2231354b1a6e6d106a803d7d52e8a290232b9769629c9a502204125264bb9d2cfd2db5455044d58a7b8ea8e0c7c88870def8c0fac2c559c5cfc0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffa43bebbebf07452a893a95bfea1d5db338d23579be172fe803dce02eeb7c037d010000006b483045022100fe8ce378ed72b0829805dde89cb16d2f6722f8b4128ee07f6ef064eaa4b607f702206400a9816e120e3e7427f4e83518b2822f010c219bcb758560ff280aae1cbe420121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff8640e312040e476cf6727c60ca3f4a3ad51623500aacdda96e7728dbdd99e8a5000000006a47304402203cce0a54d3314decb5adf1d9dbe5f887eb779daf6d4d2ce463435181da6cc72302206104213df446b9fc78d598c8425c82ca9b0952fab48a9edecb382ee5e68c11fe0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffb861fab2cde188499758346be46b5fbec635addfc4e7b0c8a07c0a908f2b11b4000000006a4730440220120d5d6672695c9ad3e72049da00be123bab74971386953b38409ff52989ce2502202b8702ba2d7fe90fc35aef52585c664865ae746d9e4242955b7ece22d89ad1ca0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff850cecf958468ca7ffa6a490afe13b8c271b1326b0ddc1fdfdf9f3c7e365fdba000000006a4730440220282a14909d8ed766441c4766a574af0fc20e1b587e545e1943429670457b959602207e4c7503ae3c9de83865d0972fbb18cd7c9630023347d6eba45963f0670ef7e70121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffe9b483a8ac4129780c88d1babe41e89dc10a26dedbf14f80a28474e9a11104de010000006b483045022100ec3744090e0603690319768ef234071410224230cc32e4731e50f9e8a05a6a5802203a1a8f7380e83fd1b61f4fd775aa6410d2e87d018b820aab4e98e1a8de0715f10121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff456a9e597129f5df2e11b842833fc19a94c563f57449281d3cd01249a830a1f0000000006a473044022060b06dcb2550beb9dd4181a45566ccf0ba41040d9003aa83c02fb63c4f9cbd8a02203c577c070c69382cfb05c74275590e3de6dcb77ce929b0d771f314ffa889f47c0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff60ad3408b89ea19caf3abd5e74e7a084344987c64b1563af52242e9d2a8320f3000000006b483045022100d7b08a358ce19469d369765c38d1f17ffe66151f7c9cd85757d89d4f218a9d390220418f13a4b8eb41ca471901f1ba2b1677166f90127b65b7417ad5a62d76f0b8c80121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff027064d817000000001976a9144a5fba237213a062f6f57978f796390bdcf8d01588ac00902f50090000001976a9145be32612930b8323add2212a4ec03c1562084f8488ac00000000")
            XCTAssertTrue(txSize.uintValue == 2611)
            
            let transaction = BTCTransaction(hex: txHex)
            
            XCTAssertTrue(transaction?.inputs.count == 17)
            let input0 = transaction?.inputs[0] as! BTCTransactionInput
            XCTAssertTrue(input0.previousTransactionID == txid0)
            XCTAssertTrue(input0.outpoint.index == 0)
            let input1 = transaction?.inputs[1] as! BTCTransactionInput
            XCTAssertTrue(input1.previousTransactionID == txid1)
            XCTAssertTrue(input1.outpoint.index == 1)
            let input2 = transaction?.inputs[2] as! BTCTransactionInput
            XCTAssertTrue(input2.previousTransactionID == txid2)
            XCTAssertTrue(input2.outpoint.index == 0)
            let input3 = transaction?.inputs[3] as! BTCTransactionInput
            XCTAssertTrue(input3.previousTransactionID == txid3)
            XCTAssertTrue(input3.outpoint.index == 1)
            let input4 = transaction?.inputs[4] as! BTCTransactionInput
            XCTAssertTrue(input4.previousTransactionID == txid4)
            XCTAssertTrue(input4.outpoint.index == 0)
            let input5 = transaction?.inputs[5] as! BTCTransactionInput
            XCTAssertTrue(input5.previousTransactionID == txid5)
            XCTAssertTrue(input5.outpoint.index == 1)
            let input6 = transaction?.inputs[6] as! BTCTransactionInput
            XCTAssertTrue(input6.previousTransactionID == txid6)
            XCTAssertTrue(input6.outpoint.index == 1)
            let input7 = transaction?.inputs[7] as! BTCTransactionInput
            XCTAssertTrue(input7.previousTransactionID == txid7)
            XCTAssertTrue(input7.outpoint.index == 0)
            let input8 = transaction?.inputs[8] as! BTCTransactionInput
            XCTAssertTrue(input8.previousTransactionID == txid8)
            XCTAssertTrue(input8.outpoint.index == 1)
            let input9 = transaction?.inputs[9] as! BTCTransactionInput
            XCTAssertTrue(input9.previousTransactionID == txid9)
            XCTAssertTrue(input9.outpoint.index == 0)
            let input10 = transaction?.inputs[10] as! BTCTransactionInput
            XCTAssertTrue(input10.previousTransactionID == txid10)
            XCTAssertTrue(input10.outpoint.index == 1)
            let input11 = transaction?.inputs[11] as! BTCTransactionInput
            XCTAssertTrue(input11.previousTransactionID == txid11)
            XCTAssertTrue(input11.outpoint.index == 0)
            let input12 = transaction?.inputs[12] as! BTCTransactionInput
            XCTAssertTrue(input12.previousTransactionID == txid12)
            XCTAssertTrue(input12.outpoint.index == 0)
            let input13 = transaction?.inputs[13] as! BTCTransactionInput
            XCTAssertTrue(input13.previousTransactionID == txid13)
            XCTAssertTrue(input13.outpoint.index == 0)
            let input14 = transaction?.inputs[14] as! BTCTransactionInput
            XCTAssertTrue(input14.previousTransactionID == txid14)
            XCTAssertTrue(input14.outpoint.index == 1)
            let input15 = transaction?.inputs[15] as! BTCTransactionInput
            XCTAssertTrue(input15.previousTransactionID == txid15)
            XCTAssertTrue(input15.outpoint.index == 0)
            let input16 = transaction?.inputs[16] as! BTCTransactionInput
            XCTAssertTrue(input16.previousTransactionID == txid16)
            XCTAssertTrue(input16.outpoint.index == 0)
            
            
            XCTAssertTrue(transaction?.outputs.count == 2)
            let output0 = transaction?.outputs[0] as! BTCTransactionOutput
            XCTAssertTrue(output0.script.hex == "76a9144a5fba237213a062f6f57978f796390bdcf8d01588ac")
            XCTAssertTrue(output0.value == 400057456)
            XCTAssertTrue(output0.script.standardAddress.base58String == "17nFgS1YaDPnXKMPQkZVdNQqZnVqRgBwnZ")
            let output1 = transaction?.outputs[1] as! BTCTransactionOutput
            XCTAssertTrue(output1.script.hex == "76a9145be32612930b8323add2212a4ec03c1562084f8488ac")
            XCTAssertTrue(output1.value == 40000000000)
            XCTAssertTrue(output1.script.standardAddress.base58String == "19Nrc2Xm226xmSbeGZ1BVtX7DUm4oCx8Pm")
            
            XCTAssertTrue(realToAddresses.count == 2)
            XCTAssertTrue(realToAddresses[0] == "19Nrc2Xm226xmSbeGZ1BVtX7DUm4oCx8Pm")
            XCTAssertTrue(realToAddresses[1] == "17nFgS1YaDPnXKMPQkZVdNQqZnVqRgBwnZ")
        }
        
        testCreateSignedSerializedTransactionHexAndBIP69_2_1()
        testCreateSignedSerializedTransactionHexAndBIP69_2_2()
    }
    
    func testCreateSignedSerializedTransactionHexAndBIP69_3() -> () {
        guard let accountObject = accountObject else {
            return
        }
        let feeAmount = TLCurrencyFormat.amountStringToCoin("0.00000", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        let toAddress = "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv"
        let toAddress2 = "vJmwhHhMNevDQh188gSeHd2xxxYGBQmnVuMY2yG2MmVTC31UWN5s3vaM3xsM2Q1bUremdK1W7eNVgPg1BnvbTyQuDtMKAYJanahvse"
        let toAmount = TLCurrencyFormat.amountStringToCoin("1", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        let toAmount2 = TLCurrencyFormat.amountStringToCoin("24", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        
        let txid0 = "35288d269cee1941eaebb2ea85e32b42cdb2b04284a56d8b14dcc3f5c65d6055"
        let txid1 = "35288d269cee1941eaebb2ea85e32b42cdb2b04284a56d8b14dcc3f5c65d6055"
        
        let unspentOutput0 = mockUnspentOutput(txid0, value: 100000000, txOutputN: 0)
        let unspentOutput1 = mockUnspentOutput(txid1, value: 2400000000, txOutputN: 1)
        let nonce:UInt32 = 123
        let ephemeralPrivateKeyHex = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        
        func testCreateSignedSerializedTransactionHexAndBIP69_3_1() -> () {
            let toAddressesAndAmounts = [["address": toAddress, "amount": toAmount], ["address": toAddress2, "amount": toAmount2]]
            
            accountObject.unspentOutputs = Array<TLUnspentOutputObject>()
            accountObject.unspentOutputs!.append(unspentOutput0)
            accountObject.unspentOutputs!.append(unspentOutput1)
            accountObject.stealthPaymentUnspentOutputs = Array<TLUnspentOutputObject>()
            
            let ret = TLSpaghettiGodSend.createSignedSerializedTransactionHex(isTestnet, coinType: accountObject.getSelectedObjectCoinType(),  sendFromAccounts: sendFromAccounts, sendFromAddresses: sendFromAddresses, toAddressesAndAmounts: toAddressesAndAmounts as NSArray,
                                                                              feeAmount: feeAmount, nonce: nonce, ephemeralPrivateKeyHex: ephemeralPrivateKeyHex, error: {
                                                                                (data: String?) in
            })
            
            let txHexAndTxHash = ret.0
            let realToAddresses = ret.1
            let txHex = txHexAndTxHash!.object(forKey: "txHex") as! String
            let txHash = txHexAndTxHash!.object(forKey: "txHash") as! String
            let txSize = txHexAndTxHash!.object(forKey: "txSize") as! NSNumber
            XCTAssertTrue(txHash == "9debd8fa98772ef4110fc3eb07a0a172e7704a148708ada788b2b5560efd445f")
            XCTAssertTrue(txHex == "010000000255605dc6f5c3dc148b6da58442b0b2cd422be385eab2ebea4119ee9c268d2835000000006b483045022100bb8786c01153753ab524a4a40c4d0635489e6bd68ded28e63b06f661977fa9fc022055bcba9bd538a5bb2c375c9b76f64c8a5e65f8d609fe50413d65c71afa6d31c40121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff55605dc6f5c3dc148b6da58442b0b2cd422be385eab2ebea4119ee9c268d2835010000006a47304402202c4c09455e0fc246617575d335194253a98bfb516943b3c0f14bb40f2676717402200af78f6591c26fc34910f4e43bde46c24538e500c71a781e2fb359b425fbca8e0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff030000000000000000286a26060000007b03a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd00e1f505000000001976a914c73015fa62d972ebb3b241fe8c936657b13fabd788ac00180d8f000000001976a914d9bbccb1b996061b735b35841d90844c263fbc7388ac00000000")
            XCTAssertTrue(txSize.uintValue == 410)
            
            let transaction = BTCTransaction(hex: txHex)
            
            XCTAssertTrue(transaction?.inputs.count == 2)
            let input0 = transaction?.inputs[0] as! BTCTransactionInput
            XCTAssertTrue(input0.previousTransactionID == txid0)
            XCTAssertTrue(input0.outpoint.index == 0)
            let input1 = transaction?.inputs[1] as! BTCTransactionInput
            XCTAssertTrue(input1.previousTransactionID == txid1)
            XCTAssertTrue(input1.outpoint.index == 1)
            
            XCTAssertTrue(transaction?.outputs.count == 3)
            let output0 = transaction?.outputs[0] as! BTCTransactionOutput
            XCTAssertTrue(output0.script.hex == "6a26060000007b03a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd")
            XCTAssertTrue(output0.value == 0)
            XCTAssertTrue(output0.script.standardAddress == nil)
            let output1 = transaction?.outputs[1] as! BTCTransactionOutput
            XCTAssertTrue(output1.script.hex == "76a914c73015fa62d972ebb3b241fe8c936657b13fabd788ac")
            XCTAssertTrue(output1.value == 100000000)
            XCTAssertTrue(output1.script.standardAddress.base58String == "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv")
            let output2 = transaction?.outputs[2] as! BTCTransactionOutput
            XCTAssertTrue(output2.script.hex == "76a914d9bbccb1b996061b735b35841d90844c263fbc7388ac")
            XCTAssertTrue(output2.value == 2400000000)
            XCTAssertTrue(output2.script.standardAddress.base58String == "1LrGcAw6WPFK4re5mt4MQfXj9xLeBYojRm")
            
            XCTAssertTrue(realToAddresses.count == 2)
            XCTAssertTrue(realToAddresses[0] == "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv")
            XCTAssertTrue(realToAddresses[1] == "1LrGcAw6WPFK4re5mt4MQfXj9xLeBYojRm")
        }
        
        func testCreateSignedSerializedTransactionHexAndBIP69_3_2() -> () {
            let toAddressesAndAmounts = [["address": toAddress2, "amount": toAmount2], ["address": toAddress, "amount": toAmount]]
            
            accountObject.unspentOutputs = Array<TLUnspentOutputObject>()
            accountObject.unspentOutputs!.append(unspentOutput1)
            accountObject.unspentOutputs!.append(unspentOutput0)
            accountObject.stealthPaymentUnspentOutputs = Array<TLUnspentOutputObject>()
            
            let ret = TLSpaghettiGodSend.createSignedSerializedTransactionHex(isTestnet, coinType: accountObject.getSelectedObjectCoinType(),  sendFromAccounts: sendFromAccounts, sendFromAddresses: sendFromAddresses, toAddressesAndAmounts: toAddressesAndAmounts as NSArray,
                                                                              feeAmount: feeAmount, nonce: nonce, ephemeralPrivateKeyHex: ephemeralPrivateKeyHex, error: {
                                                                                (data: String?) in
            })
            
            let txHexAndTxHash = ret.0
            let realToAddresses = ret.1
            let txHex = txHexAndTxHash!.object(forKey: "txHex") as! String
            let txHash = txHexAndTxHash!.object(forKey: "txHash") as! String
            let txSize = txHexAndTxHash!.object(forKey: "txSize") as! NSNumber
            XCTAssertTrue(txHash == "9debd8fa98772ef4110fc3eb07a0a172e7704a148708ada788b2b5560efd445f")
            XCTAssertTrue(txHex == "010000000255605dc6f5c3dc148b6da58442b0b2cd422be385eab2ebea4119ee9c268d2835000000006b483045022100bb8786c01153753ab524a4a40c4d0635489e6bd68ded28e63b06f661977fa9fc022055bcba9bd538a5bb2c375c9b76f64c8a5e65f8d609fe50413d65c71afa6d31c40121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff55605dc6f5c3dc148b6da58442b0b2cd422be385eab2ebea4119ee9c268d2835010000006a47304402202c4c09455e0fc246617575d335194253a98bfb516943b3c0f14bb40f2676717402200af78f6591c26fc34910f4e43bde46c24538e500c71a781e2fb359b425fbca8e0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff030000000000000000286a26060000007b03a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd00e1f505000000001976a914c73015fa62d972ebb3b241fe8c936657b13fabd788ac00180d8f000000001976a914d9bbccb1b996061b735b35841d90844c263fbc7388ac00000000")
            XCTAssertTrue(txSize.uintValue == 410)
            
            let transaction = BTCTransaction(hex: txHex)
            
            XCTAssertTrue(transaction?.inputs.count == 2)
            let input0 = transaction?.inputs[0] as! BTCTransactionInput
            XCTAssertTrue(input0.previousTransactionID == txid0)
            XCTAssertTrue(input0.outpoint.index == 0)
            let input1 = transaction?.inputs[1] as! BTCTransactionInput
            XCTAssertTrue(input1.previousTransactionID == txid1)
            XCTAssertTrue(input1.outpoint.index == 1)
            
            XCTAssertTrue(transaction?.outputs.count == 3)
            let output0 = transaction?.outputs[0] as! BTCTransactionOutput
            XCTAssertTrue(output0.script.hex == "6a26060000007b03a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd")
            XCTAssertTrue(output0.value == 0)
            XCTAssertTrue(output0.script.standardAddress == nil)
            let output1 = transaction?.outputs[1] as! BTCTransactionOutput
            XCTAssertTrue(output1.script.hex == "76a914c73015fa62d972ebb3b241fe8c936657b13fabd788ac")
            XCTAssertTrue(output1.value == 100000000)
            XCTAssertTrue(output1.script.standardAddress.base58String == "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv")
            let output2 = transaction?.outputs[2] as! BTCTransactionOutput
            XCTAssertTrue(output2.script.hex == "76a914d9bbccb1b996061b735b35841d90844c263fbc7388ac")
            XCTAssertTrue(output2.value == 2400000000)
            XCTAssertTrue(output2.script.standardAddress.base58String == "1LrGcAw6WPFK4re5mt4MQfXj9xLeBYojRm")
            
            XCTAssertTrue(realToAddresses.count == 2)
            XCTAssertTrue(realToAddresses[0] == "1LrGcAw6WPFK4re5mt4MQfXj9xLeBYojRm")
            XCTAssertTrue(realToAddresses[1] == "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv")
        }
        
        testCreateSignedSerializedTransactionHexAndBIP69_3_1()
        testCreateSignedSerializedTransactionHexAndBIP69_3_2()
    }
    
    func testCreateSignedSerializedTransactionHexAndBIP69_4() -> () {
        guard let accountObject = accountObject else {
            return
        }
        let feeAmount = TLCurrencyFormat.amountStringToCoin("0.00002735", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        let toAddress = "vJmwhHhMNevDQh188gSeHd2xxxYGBQmnVuMY2yG2MmVTC31UWN5s3vaM3xsM2Q1bUremdK1W7eNVgPg1BnvbTyQuDtMKAYJanahvse"
        let toAddress2 = "19Nrc2Xm226xmSbeGZ1BVtX7DUm4oCx8Pm"
        let toAmount = TLCurrencyFormat.amountStringToCoin("4.00057456", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        let toAmount2 = TLCurrencyFormat.amountStringToCoin("400", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        
        let txid0 = "0e53ec5dfb2cb8a71fec32dc9a634a35b7e24799295ddd5278217822e0b31f57"
        let txid1 = "26aa6e6d8b9e49bb0630aac301db6757c02e3619feb4ee0eea81eb1672947024"
        let txid2 = "28e0fdd185542f2c6ea19030b0796051e7772b6026dd5ddccd7a2f93b73e6fc2"
        let txid3 = "381de9b9ae1a94d9c17f6a08ef9d341a5ce29e2e60c36a52d333ff6203e58d5d"
        let txid4 = "3b8b2f8efceb60ba78ca8bba206a137f14cb5ea4035e761ee204302d46b98de2"
        let txid5 = "402b2c02411720bf409eff60d05adad684f135838962823f3614cc657dd7bc0a"
        let txid6 = "54ffff182965ed0957dba1239c27164ace5a73c9b62a660c74b7b7f15ff61e7a"
        let txid7 = "643e5f4e66373a57251fb173151e838ccd27d279aca882997e005016bb53d5aa"
        let txid8 = "6c1d56f31b2de4bfc6aaea28396b333102b1f600da9c6d6149e96ca43f1102b1"
        let txid9 = "7a1de137cbafb5c70405455c49c5104ca3057a1f1243e6563bb9245c9c88c191"
        let txid10 = "7d037ceb2ee0dc03e82f17be7935d238b35d1deabf953a892a4507bfbeeb3ba4"
        let txid11 = "a5e899dddb28776ea9ddac0a502316d53a4a3fca607c72f66c470e0412e34086"
        let txid12 = "b4112b8f900a7ca0c8b0e7c4dfad35c6be5f6be46b3458974988e1cdb2fa61b8"
        let txid13 = "bafd65e3c7f3f9fdfdc1ddb026131b278c3be1af90a4a6ffa78c4658f9ec0c85"
        let txid14 = "de0411a1e97484a2804ff1dbde260ac19de841bebad1880c782941aca883b4e9"
        let txid15 = "f0a130a84912d03c1d284974f563c5949ac13f8342b8112edff52971599e6a45"
        let txid16 = "f320832a9d2e2452af63154bc687493484a0e7745ebd3aaf9ca19eb80834ad60"
        
        let unspentOutput0 = mockUnspentOutput(txid0, value: 2529937904, txOutputN: 0)
        let unspentOutput1 = mockUnspentOutput(txid1, value: 2521656792, txOutputN: 1)
        let unspentOutput2 = mockUnspentOutput(txid2, value: 2509683086, txOutputN: 0)
        let unspentOutput3 = mockUnspentOutput(txid3, value: 2506060377, txOutputN: 1)
        let unspentOutput4 = mockUnspentOutput(txid4, value: 2510645247, txOutputN: 0)
        let unspentOutput5 = mockUnspentOutput(txid5, value: 2502325820, txOutputN: 1)
        let unspentOutput6 = mockUnspentOutput(txid6, value: 2525953727, txOutputN: 1)
        let unspentOutput7 = mockUnspentOutput(txid7, value: 2507302856, txOutputN: 0)
        let unspentOutput8 = mockUnspentOutput(txid8, value: 2534185804, txOutputN: 1)
        let unspentOutput9 = mockUnspentOutput(txid9, value: 136219905, txOutputN: 0)
        let unspentOutput10 = mockUnspentOutput(txid10, value: 2502901118, txOutputN: 1)
        let unspentOutput11 = mockUnspentOutput(txid11, value: 2527569363, txOutputN: 0)
        let unspentOutput12 = mockUnspentOutput(txid12, value: 2516268302, txOutputN: 0)
        let unspentOutput13 = mockUnspentOutput(txid13, value: 2521794404, txOutputN: 0)
        let unspentOutput14 = mockUnspentOutput(txid14, value: 2520533680, txOutputN: 1)
        let unspentOutput15 = mockUnspentOutput(txid15, value: 2513840095, txOutputN: 0)
        let unspentOutput16 = mockUnspentOutput(txid16, value: 2513181711, txOutputN: 0)
        
        let nonce:UInt32 = 123
        let ephemeralPrivateKeyHex = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        
        func testCreateSignedSerializedTransactionHexAndBIP69_4_1() -> () {
            let toAddressesAndAmounts = [["address": toAddress, "amount": toAmount], ["address": toAddress2, "amount": toAmount2]]
            
            accountObject.unspentOutputs = Array<TLUnspentOutputObject>()
            accountObject.unspentOutputs!.append(unspentOutput0)
            accountObject.unspentOutputs!.append(unspentOutput1)
            accountObject.unspentOutputs!.append(unspentOutput2)
            accountObject.unspentOutputs!.append(unspentOutput3)
            accountObject.unspentOutputs!.append(unspentOutput4)
            accountObject.unspentOutputs!.append(unspentOutput5)
            accountObject.unspentOutputs!.append(unspentOutput6)
            accountObject.unspentOutputs!.append(unspentOutput7)
            accountObject.unspentOutputs!.append(unspentOutput8)
            accountObject.unspentOutputs!.append(unspentOutput9)
            accountObject.unspentOutputs!.append(unspentOutput10)
            accountObject.unspentOutputs!.append(unspentOutput11)
            accountObject.unspentOutputs!.append(unspentOutput12)
            accountObject.unspentOutputs!.append(unspentOutput13)
            accountObject.unspentOutputs!.append(unspentOutput14)
            accountObject.unspentOutputs!.append(unspentOutput15)
            accountObject.unspentOutputs!.append(unspentOutput16)
            
            accountObject.stealthPaymentUnspentOutputs = Array<TLUnspentOutputObject>()
            
            let ret = TLSpaghettiGodSend.createSignedSerializedTransactionHex(isTestnet, coinType: accountObject.getSelectedObjectCoinType(),  sendFromAccounts: sendFromAccounts, sendFromAddresses: sendFromAddresses, toAddressesAndAmounts: toAddressesAndAmounts as NSArray,
                                                                              feeAmount: feeAmount, nonce: nonce, ephemeralPrivateKeyHex: ephemeralPrivateKeyHex, error: {
                                                                                (data: String?) in
            })
            
            let txHexAndTxHash = ret.0
            let realToAddresses = ret.1
            let txHex = txHexAndTxHash!.object(forKey: "txHex") as! String
            let txHash = txHexAndTxHash!.object(forKey: "txHash") as! String
            let txSize = txHexAndTxHash!.object(forKey: "txSize") as! NSNumber
            XCTAssertTrue(txHash == "b982687699c5bbd6ee36b157c3b34b3d3370945e68b63c987cdf880dbe475706")
            XCTAssertTrue(txHex == "0100000011571fb3e02278217852dd5d299947e2b7354a639adc32ec1fa7b82cfb5dec530e000000006b483045022100d9e6a6677e63574fd5216957f0652334acf64343192064c4f19c5c8daad1f796022041cbcc403865f92b2804e2d04cfa165dd42bd75c247055c626901507479f923c0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff2470947216eb81ea0eeeb4fe19362ec05767db01c3aa3006bb499e8b6d6eaa26010000006a47304402204a6451764251502cfdcac44deab397e538e5c33fdf354116bcf3dd8088b47c450220345f69761d82e03e88dce29f37e6bccdffce78e3b640d089a377079950006fba0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffc26f3eb7932f7acddc5ddd26602b77e7516079b03090a16e2c2f5485d1fde028000000006b48304502210080577b722d775c9ab9acba7f90b6ee0187395c65824c52ee96a83d9582b27761022063aafc98452e62ee85d99082c96d9dae4071ed0b5f822a4ab211428336e937440121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff5d8de50362ff33d3526ac3602e9ee25c1a349def086a7fc1d9941aaeb9e91d38010000006b483045022100a2279a85d58b05822dbc1ba9cb4c22a9efaf4e3e2d0aaf4c140f6232b90339cf02202e88942afcc0defc3839e764e7358e5065e9bcc6a437f3a1f9e60a912e5cd0180121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffe28db9462d3004e21e765e03a45ecb147f136a20ba8bca78ba60ebfc8e2f8b3b000000006b483045022100d431504d890b2acdc45f618ddc53c2a7accb01d9273afbaa31d5beb71c9bb4de02200797a199a0783d16397152db1159fc8594946ca876ef3586f06be36afc0915230121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff0abcd77d65cc14363f8262898335f184d6da5ad060ff9e40bf201741022c2b40010000006b4830450221008424d7c4bc369a735b92c0f367f5bead679bc82b77ac3ea527002a795299e5cd02200bd017178c46caf204cd3283daed2539a525051e3a73f10f23175d4a90a6d21e0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff7a1ef65ff1b7b7740c662ab6c9735ace4a16279c23a1db5709ed652918ffff54010000006b483045022100bec61f4a8aa3ed122f02663d162ea8d06b65730a1400bb58586783c4155c4ecc022037ba1f6434685252902ca095317299e9facb634216e94677e444182c15d4b8dc0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffaad553bb1650007e9982a8ac79d227cd8c831e1573b11f25573a37664e5f3e64000000006b483045022100b090ff8248aa3f6ea9026861ecbf91e60859801d04fbc4ad54eb3f7497a482c90220128a6dcb1d2d17033aa3e002fcec7fa54b0f817f56abf14d5d37574f2dcf2d1d0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffb102113fa46ce949616d9cda00f6b10231336b3928eaaac6bfe42d1bf3561d6c010000006b483045022100cb8f6d41cb664bee9fe86417e6b6b61452fdcc7c652fe66c46cddae49a678fcb02201f8c040f0a034602015ad2cbf4e6c058077366633c7d3fd5df626de03a091e7b0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff91c1889c5c24b93b56e643121f7a05a34c10c5495c450504c7b5afcb37e11d7a000000006a47304402200cd323984290d2ef6d7ad01942102ea0cceee9b897103ef385719c6f2b57963702201d9dd8c3ea68ea02b6a3ee4a19c18f899d8b02da549f914dd917489c067e7e8e0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffa43bebbebf07452a893a95bfea1d5db338d23579be172fe803dce02eeb7c037d010000006b483045022100be493ef5d839eea19d68e8a3a037fc2f7eb41655d511169a4a8b653ab9d86ca30220416cb1f8dfc83a322de2617e007521dbd408d5ef776193400351c046cbde3d780121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff8640e312040e476cf6727c60ca3f4a3ad51623500aacdda96e7728dbdd99e8a5000000006a47304402200b746b555bf44674ca15ba71ca751719311244f3ba0a5a492fe685fdf7a95dcf0220357f17f4af7a322ca18fc65ddd87580e75bb9988023a11ab00b2f4243c7b6b150121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffb861fab2cde188499758346be46b5fbec635addfc4e7b0c8a07c0a908f2b11b4000000006b4830450221008c0b600801fed1af9c9400daf9c345f27837670a7acd0f1dcdbbbeb7925bad1f022017ef87eabf09308b2f11e63dcb15c4007a907b78afcad4931f9129355ed57b390121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff850cecf958468ca7ffa6a490afe13b8c271b1326b0ddc1fdfdf9f3c7e365fdba000000006b483045022100bcfe32a695abde4c66996b9d38b6be73a70abfcbe09fcc564f4aa1e0c51fd93b0220579cb2061627efbf9ce1748284f9ecedbe72ccdbc9010cb673e64f2aa58c51d90121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffe9b483a8ac4129780c88d1babe41e89dc10a26dedbf14f80a28474e9a11104de010000006a47304402204eeedb2a870d7c1f9aa74a9edc166eda1d80a63c39c5d964c9c4b92db14c1bdd02207e70e0d5740835419f82c23580fdeed491ab872c2fe8a51b4f03fdb817ebfe850121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff456a9e597129f5df2e11b842833fc19a94c563f57449281d3cd01249a830a1f0000000006b483045022100c3c3a47e694c6e9c1d43ae89bfe97a387c45e17d99f79707a6a4df006f5561240220573c40748cc42c45038ac718963eb6385c75216b70249dfb9f8f9d67ae569b9a0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff60ad3408b89ea19caf3abd5e74e7a084344987c64b1563af52242e9d2a8320f3000000006a47304402202744a81ba331f89bc0f39c2eb241460a279347e070df57c60148dd7c6ae1778102200616c24bf72cd82a49e0419634388bed2516e4b95dc68dd846851742e15f3cec0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff030000000000000000286a26060000007b03a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd7064d817000000001976a914d9bbccb1b996061b735b35841d90844c263fbc7388ac00902f50090000001976a9145be32612930b8323add2212a4ec03c1562084f8488ac00000000")
            XCTAssertTrue(txSize.uintValue == 2645)
            
            let transaction = BTCTransaction(hex: txHex)
            
            XCTAssertTrue(transaction?.inputs.count == 17)
            let input0 = transaction?.inputs[0] as! BTCTransactionInput
            XCTAssertTrue(input0.previousTransactionID == txid0)
            XCTAssertTrue(input0.outpoint.index == 0)
            let input1 = transaction?.inputs[1] as! BTCTransactionInput
            XCTAssertTrue(input1.previousTransactionID == txid1)
            XCTAssertTrue(input1.outpoint.index == 1)
            let input2 = transaction?.inputs[2] as! BTCTransactionInput
            XCTAssertTrue(input2.previousTransactionID == txid2)
            XCTAssertTrue(input2.outpoint.index == 0)
            let input3 = transaction?.inputs[3] as! BTCTransactionInput
            XCTAssertTrue(input3.previousTransactionID == txid3)
            XCTAssertTrue(input3.outpoint.index == 1)
            let input4 = transaction?.inputs[4] as! BTCTransactionInput
            XCTAssertTrue(input4.previousTransactionID == txid4)
            XCTAssertTrue(input4.outpoint.index == 0)
            let input5 = transaction?.inputs[5] as! BTCTransactionInput
            XCTAssertTrue(input5.previousTransactionID == txid5)
            XCTAssertTrue(input5.outpoint.index == 1)
            let input6 = transaction?.inputs[6] as! BTCTransactionInput
            XCTAssertTrue(input6.previousTransactionID == txid6)
            XCTAssertTrue(input6.outpoint.index == 1)
            let input7 = transaction?.inputs[7] as! BTCTransactionInput
            XCTAssertTrue(input7.previousTransactionID == txid7)
            XCTAssertTrue(input7.outpoint.index == 0)
            let input8 = transaction?.inputs[8] as! BTCTransactionInput
            XCTAssertTrue(input8.previousTransactionID == txid8)
            XCTAssertTrue(input8.outpoint.index == 1)
            let input9 = transaction?.inputs[9] as! BTCTransactionInput
            XCTAssertTrue(input9.previousTransactionID == txid9)
            XCTAssertTrue(input9.outpoint.index == 0)
            let input10 = transaction?.inputs[10] as! BTCTransactionInput
            XCTAssertTrue(input10.previousTransactionID == txid10)
            XCTAssertTrue(input10.outpoint.index == 1)
            let input11 = transaction?.inputs[11] as! BTCTransactionInput
            XCTAssertTrue(input11.previousTransactionID == txid11)
            XCTAssertTrue(input11.outpoint.index == 0)
            let input12 = transaction?.inputs[12] as! BTCTransactionInput
            XCTAssertTrue(input12.previousTransactionID == txid12)
            XCTAssertTrue(input12.outpoint.index == 0)
            let input13 = transaction?.inputs[13] as! BTCTransactionInput
            XCTAssertTrue(input13.previousTransactionID == txid13)
            XCTAssertTrue(input13.outpoint.index == 0)
            let input14 = transaction?.inputs[14] as! BTCTransactionInput
            XCTAssertTrue(input14.previousTransactionID == txid14)
            XCTAssertTrue(input14.outpoint.index == 1)
            let input15 = transaction?.inputs[15] as! BTCTransactionInput
            XCTAssertTrue(input15.previousTransactionID == txid15)
            XCTAssertTrue(input15.outpoint.index == 0)
            let input16 = transaction?.inputs[16] as! BTCTransactionInput
            XCTAssertTrue(input16.previousTransactionID == txid16)
            XCTAssertTrue(input16.outpoint.index == 0)
            
            XCTAssertTrue(transaction?.outputs.count == 3)
            let output0 = transaction?.outputs[0] as! BTCTransactionOutput
            XCTAssertTrue(output0.script.hex == "6a26060000007b03a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd")
            XCTAssertTrue(output0.value == 0)
            XCTAssertTrue(output0.script.standardAddress == nil)
            let output1 = transaction?.outputs[1] as! BTCTransactionOutput
            XCTAssertTrue(output1.script.hex == "76a914d9bbccb1b996061b735b35841d90844c263fbc7388ac")
            XCTAssertTrue(output1.value == 400057456)
            XCTAssertTrue(output1.script.standardAddress.base58String == "1LrGcAw6WPFK4re5mt4MQfXj9xLeBYojRm")
            let output2 = transaction?.outputs[2] as! BTCTransactionOutput
            XCTAssertTrue(output2.script.hex == "76a9145be32612930b8323add2212a4ec03c1562084f8488ac")
            XCTAssertTrue(output2.value == 40000000000)
            XCTAssertTrue(output2.script.standardAddress.base58String == "19Nrc2Xm226xmSbeGZ1BVtX7DUm4oCx8Pm")
            
            XCTAssertTrue(realToAddresses.count == 2)
            XCTAssertTrue(realToAddresses[0] == "1LrGcAw6WPFK4re5mt4MQfXj9xLeBYojRm")
            XCTAssertTrue(realToAddresses[1] == "19Nrc2Xm226xmSbeGZ1BVtX7DUm4oCx8Pm")
        }
        
        func testCreateSignedSerializedTransactionHexAndBIP69_4_2() -> () {
            let toAddressesAndAmounts = [["address": toAddress2, "amount": toAmount2], ["address": toAddress, "amount": toAmount]]
            
            accountObject.unspentOutputs = Array<TLUnspentOutputObject>()
            accountObject.unspentOutputs!.append(unspentOutput5)
            accountObject.unspentOutputs!.append(unspentOutput2)
            accountObject.unspentOutputs!.append(unspentOutput15)
            accountObject.unspentOutputs!.append(unspentOutput0)
            accountObject.unspentOutputs!.append(unspentOutput1)
            accountObject.unspentOutputs!.append(unspentOutput6)
            accountObject.unspentOutputs!.append(unspentOutput4)
            accountObject.unspentOutputs!.append(unspentOutput7)
            accountObject.unspentOutputs!.append(unspentOutput3)
            accountObject.unspentOutputs!.append(unspentOutput13)
            accountObject.unspentOutputs!.append(unspentOutput9)
            accountObject.unspentOutputs!.append(unspentOutput10)
            accountObject.unspentOutputs!.append(unspentOutput8)
            accountObject.unspentOutputs!.append(unspentOutput11)
            accountObject.unspentOutputs!.append(unspentOutput14)
            accountObject.unspentOutputs!.append(unspentOutput12)
            accountObject.unspentOutputs!.append(unspentOutput16)
            
            accountObject.stealthPaymentUnspentOutputs = Array<TLUnspentOutputObject>()
            
            let ret = TLSpaghettiGodSend.createSignedSerializedTransactionHex(isTestnet, coinType: accountObject.getSelectedObjectCoinType(),  sendFromAccounts: sendFromAccounts, sendFromAddresses: sendFromAddresses, toAddressesAndAmounts: toAddressesAndAmounts as NSArray,
                                                                              feeAmount: feeAmount, nonce: nonce, ephemeralPrivateKeyHex: ephemeralPrivateKeyHex, error: {
                                                                                (data: String?) in
            })
            
            let txHexAndTxHash = ret.0
            let realToAddresses = ret.1
            let txHex = txHexAndTxHash!.object(forKey: "txHex") as! String
            let txHash = txHexAndTxHash!.object(forKey: "txHash") as! String
            let txSize = txHexAndTxHash!.object(forKey: "txSize") as! NSNumber
            XCTAssertTrue(txHash == "b982687699c5bbd6ee36b157c3b34b3d3370945e68b63c987cdf880dbe475706")
            XCTAssertTrue(txHex == "0100000011571fb3e02278217852dd5d299947e2b7354a639adc32ec1fa7b82cfb5dec530e000000006b483045022100d9e6a6677e63574fd5216957f0652334acf64343192064c4f19c5c8daad1f796022041cbcc403865f92b2804e2d04cfa165dd42bd75c247055c626901507479f923c0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff2470947216eb81ea0eeeb4fe19362ec05767db01c3aa3006bb499e8b6d6eaa26010000006a47304402204a6451764251502cfdcac44deab397e538e5c33fdf354116bcf3dd8088b47c450220345f69761d82e03e88dce29f37e6bccdffce78e3b640d089a377079950006fba0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffc26f3eb7932f7acddc5ddd26602b77e7516079b03090a16e2c2f5485d1fde028000000006b48304502210080577b722d775c9ab9acba7f90b6ee0187395c65824c52ee96a83d9582b27761022063aafc98452e62ee85d99082c96d9dae4071ed0b5f822a4ab211428336e937440121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff5d8de50362ff33d3526ac3602e9ee25c1a349def086a7fc1d9941aaeb9e91d38010000006b483045022100a2279a85d58b05822dbc1ba9cb4c22a9efaf4e3e2d0aaf4c140f6232b90339cf02202e88942afcc0defc3839e764e7358e5065e9bcc6a437f3a1f9e60a912e5cd0180121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffe28db9462d3004e21e765e03a45ecb147f136a20ba8bca78ba60ebfc8e2f8b3b000000006b483045022100d431504d890b2acdc45f618ddc53c2a7accb01d9273afbaa31d5beb71c9bb4de02200797a199a0783d16397152db1159fc8594946ca876ef3586f06be36afc0915230121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff0abcd77d65cc14363f8262898335f184d6da5ad060ff9e40bf201741022c2b40010000006b4830450221008424d7c4bc369a735b92c0f367f5bead679bc82b77ac3ea527002a795299e5cd02200bd017178c46caf204cd3283daed2539a525051e3a73f10f23175d4a90a6d21e0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff7a1ef65ff1b7b7740c662ab6c9735ace4a16279c23a1db5709ed652918ffff54010000006b483045022100bec61f4a8aa3ed122f02663d162ea8d06b65730a1400bb58586783c4155c4ecc022037ba1f6434685252902ca095317299e9facb634216e94677e444182c15d4b8dc0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffaad553bb1650007e9982a8ac79d227cd8c831e1573b11f25573a37664e5f3e64000000006b483045022100b090ff8248aa3f6ea9026861ecbf91e60859801d04fbc4ad54eb3f7497a482c90220128a6dcb1d2d17033aa3e002fcec7fa54b0f817f56abf14d5d37574f2dcf2d1d0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffb102113fa46ce949616d9cda00f6b10231336b3928eaaac6bfe42d1bf3561d6c010000006b483045022100cb8f6d41cb664bee9fe86417e6b6b61452fdcc7c652fe66c46cddae49a678fcb02201f8c040f0a034602015ad2cbf4e6c058077366633c7d3fd5df626de03a091e7b0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff91c1889c5c24b93b56e643121f7a05a34c10c5495c450504c7b5afcb37e11d7a000000006a47304402200cd323984290d2ef6d7ad01942102ea0cceee9b897103ef385719c6f2b57963702201d9dd8c3ea68ea02b6a3ee4a19c18f899d8b02da549f914dd917489c067e7e8e0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffa43bebbebf07452a893a95bfea1d5db338d23579be172fe803dce02eeb7c037d010000006b483045022100be493ef5d839eea19d68e8a3a037fc2f7eb41655d511169a4a8b653ab9d86ca30220416cb1f8dfc83a322de2617e007521dbd408d5ef776193400351c046cbde3d780121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff8640e312040e476cf6727c60ca3f4a3ad51623500aacdda96e7728dbdd99e8a5000000006a47304402200b746b555bf44674ca15ba71ca751719311244f3ba0a5a492fe685fdf7a95dcf0220357f17f4af7a322ca18fc65ddd87580e75bb9988023a11ab00b2f4243c7b6b150121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffb861fab2cde188499758346be46b5fbec635addfc4e7b0c8a07c0a908f2b11b4000000006b4830450221008c0b600801fed1af9c9400daf9c345f27837670a7acd0f1dcdbbbeb7925bad1f022017ef87eabf09308b2f11e63dcb15c4007a907b78afcad4931f9129355ed57b390121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff850cecf958468ca7ffa6a490afe13b8c271b1326b0ddc1fdfdf9f3c7e365fdba000000006b483045022100bcfe32a695abde4c66996b9d38b6be73a70abfcbe09fcc564f4aa1e0c51fd93b0220579cb2061627efbf9ce1748284f9ecedbe72ccdbc9010cb673e64f2aa58c51d90121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffffe9b483a8ac4129780c88d1babe41e89dc10a26dedbf14f80a28474e9a11104de010000006a47304402204eeedb2a870d7c1f9aa74a9edc166eda1d80a63c39c5d964c9c4b92db14c1bdd02207e70e0d5740835419f82c23580fdeed491ab872c2fe8a51b4f03fdb817ebfe850121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff456a9e597129f5df2e11b842833fc19a94c563f57449281d3cd01249a830a1f0000000006b483045022100c3c3a47e694c6e9c1d43ae89bfe97a387c45e17d99f79707a6a4df006f5561240220573c40748cc42c45038ac718963eb6385c75216b70249dfb9f8f9d67ae569b9a0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff60ad3408b89ea19caf3abd5e74e7a084344987c64b1563af52242e9d2a8320f3000000006a47304402202744a81ba331f89bc0f39c2eb241460a279347e070df57c60148dd7c6ae1778102200616c24bf72cd82a49e0419634388bed2516e4b95dc68dd846851742e15f3cec0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff030000000000000000286a26060000007b03a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd7064d817000000001976a914d9bbccb1b996061b735b35841d90844c263fbc7388ac00902f50090000001976a9145be32612930b8323add2212a4ec03c1562084f8488ac00000000")
            XCTAssertTrue(txSize.uintValue == 2645)
            
            let transaction = BTCTransaction(hex: txHex)
            
            XCTAssertTrue(transaction?.inputs.count == 17)
            let input0 = transaction?.inputs[0] as! BTCTransactionInput
            XCTAssertTrue(input0.previousTransactionID == txid0)
            XCTAssertTrue(input0.outpoint.index == 0)
            let input1 = transaction?.inputs[1] as! BTCTransactionInput
            XCTAssertTrue(input1.previousTransactionID == txid1)
            XCTAssertTrue(input1.outpoint.index == 1)
            let input2 = transaction?.inputs[2] as! BTCTransactionInput
            XCTAssertTrue(input2.previousTransactionID == txid2)
            XCTAssertTrue(input2.outpoint.index == 0)
            let input3 = transaction?.inputs[3] as! BTCTransactionInput
            XCTAssertTrue(input3.previousTransactionID == txid3)
            XCTAssertTrue(input3.outpoint.index == 1)
            let input4 = transaction?.inputs[4] as! BTCTransactionInput
            XCTAssertTrue(input4.previousTransactionID == txid4)
            XCTAssertTrue(input4.outpoint.index == 0)
            let input5 = transaction?.inputs[5] as! BTCTransactionInput
            XCTAssertTrue(input5.previousTransactionID == txid5)
            XCTAssertTrue(input5.outpoint.index == 1)
            let input6 = transaction?.inputs[6] as! BTCTransactionInput
            XCTAssertTrue(input6.previousTransactionID == txid6)
            XCTAssertTrue(input6.outpoint.index == 1)
            let input7 = transaction?.inputs[7] as! BTCTransactionInput
            XCTAssertTrue(input7.previousTransactionID == txid7)
            XCTAssertTrue(input7.outpoint.index == 0)
            let input8 = transaction?.inputs[8] as! BTCTransactionInput
            XCTAssertTrue(input8.previousTransactionID == txid8)
            XCTAssertTrue(input8.outpoint.index == 1)
            let input9 = transaction?.inputs[9] as! BTCTransactionInput
            XCTAssertTrue(input9.previousTransactionID == txid9)
            XCTAssertTrue(input9.outpoint.index == 0)
            let input10 = transaction?.inputs[10] as! BTCTransactionInput
            XCTAssertTrue(input10.previousTransactionID == txid10)
            XCTAssertTrue(input10.outpoint.index == 1)
            let input11 = transaction?.inputs[11] as! BTCTransactionInput
            XCTAssertTrue(input11.previousTransactionID == txid11)
            XCTAssertTrue(input11.outpoint.index == 0)
            let input12 = transaction?.inputs[12] as! BTCTransactionInput
            XCTAssertTrue(input12.previousTransactionID == txid12)
            XCTAssertTrue(input12.outpoint.index == 0)
            let input13 = transaction?.inputs[13] as! BTCTransactionInput
            XCTAssertTrue(input13.previousTransactionID == txid13)
            XCTAssertTrue(input13.outpoint.index == 0)
            let input14 = transaction?.inputs[14] as! BTCTransactionInput
            XCTAssertTrue(input14.previousTransactionID == txid14)
            XCTAssertTrue(input14.outpoint.index == 1)
            let input15 = transaction?.inputs[15] as! BTCTransactionInput
            XCTAssertTrue(input15.previousTransactionID == txid15)
            XCTAssertTrue(input15.outpoint.index == 0)
            let input16 = transaction?.inputs[16] as! BTCTransactionInput
            XCTAssertTrue(input16.previousTransactionID == txid16)
            XCTAssertTrue(input16.outpoint.index == 0)
            
            
            XCTAssertTrue(transaction?.outputs.count == 3)
            let output0 = transaction?.outputs[0] as! BTCTransactionOutput
            XCTAssertTrue(output0.script.hex == "6a26060000007b03a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd")
            XCTAssertTrue(output0.value == 0)
            XCTAssertTrue(output0.script.standardAddress == nil)
            let output1 = transaction?.outputs[1] as! BTCTransactionOutput
            XCTAssertTrue(output1.script.hex == "76a914d9bbccb1b996061b735b35841d90844c263fbc7388ac")
            XCTAssertTrue(output1.value == 400057456)
            XCTAssertTrue(output1.script.standardAddress.base58String == "1LrGcAw6WPFK4re5mt4MQfXj9xLeBYojRm")
            let output2 = transaction?.outputs[2] as! BTCTransactionOutput
            XCTAssertTrue(output2.script.hex == "76a9145be32612930b8323add2212a4ec03c1562084f8488ac")
            XCTAssertTrue(output2.value == 40000000000)
            XCTAssertTrue(output2.script.standardAddress.base58String == "19Nrc2Xm226xmSbeGZ1BVtX7DUm4oCx8Pm")
            
            
            XCTAssertTrue(realToAddresses.count == 2)
            XCTAssertTrue(realToAddresses[0] == "19Nrc2Xm226xmSbeGZ1BVtX7DUm4oCx8Pm")
            XCTAssertTrue(realToAddresses[1] == "1LrGcAw6WPFK4re5mt4MQfXj9xLeBYojRm")
        }
        
        testCreateSignedSerializedTransactionHexAndBIP69_4_1()
        testCreateSignedSerializedTransactionHexAndBIP69_4_2()
    }

    func testCreateSignedSerializedTransactionHexAndBIP69_5() -> () {
        guard let accountObject = accountObject else {
            return
        }
        let feeAmount = TLCurrencyFormat.amountStringToCoin("0.00000", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        let toAddress = "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv"
        let toAmount = TLCurrencyFormat.amountStringToCoin("8", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        
        let txid0 = "35288d269cee1941eaebb2ea85e32b42cdb2b04284a56d8b14dcc3f5c65d6055"
        let txid1 = "35288d269cee1941eaebb2ea85e32b42cdb2b04284a56d8b14dcc3f5c65d6055"
        
        let unspentOutput0 = mockUnspentOutput(txid0, value: 700000000, txOutputN: 0)
        let unspentOutput1 = mockUnspentOutput(txid1, value: 1000000000, txOutputN: 1)
        
        func testCreateSignedSerializedTransactionHexAndBIP69_5_1() -> () {
            let toAddressesAndAmounts = [["address": toAddress, "amount": toAmount]]
            
            accountObject.unspentOutputs = Array<TLUnspentOutputObject>()
            accountObject.unspentOutputs!.append(unspentOutput0)
            accountObject.unspentOutputs!.append(unspentOutput1)
            accountObject.stealthPaymentUnspentOutputs = Array<TLUnspentOutputObject>()
            
            let ret = TLSpaghettiGodSend.createSignedSerializedTransactionHex(isTestnet, coinType: accountObject.getSelectedObjectCoinType(),  sendFromAccounts: sendFromAccounts, sendFromAddresses: sendFromAddresses, toAddressesAndAmounts: toAddressesAndAmounts as NSArray, feeAmount: feeAmount, error: {
                (data: String?) in
            })
            
            let txHexAndTxHash = ret.0
            let realToAddresses = ret.1
            let txHex = txHexAndTxHash!.object(forKey: "txHex") as! String
            let txHash = txHexAndTxHash!.object(forKey: "txHash") as! String
            let txSize = txHexAndTxHash!.object(forKey: "txSize") as! NSNumber
            XCTAssertTrue(txHash == "7993558323324a61028e592f8e1421ec131d48ecba09627645d7c2aec49b838e")
            XCTAssertTrue(txHex == "010000000255605dc6f5c3dc148b6da58442b0b2cd422be385eab2ebea4119ee9c268d2835000000006a473044022044fb6ce5ce9ae0ef3d381f749612a993d98bf6c293e1e6bbc73979c0c7d7f88a0220749e495896ca230272d0d6e93a53019e2479b4829f09d574c26e21b5ef614da80121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff55605dc6f5c3dc148b6da58442b0b2cd422be385eab2ebea4119ee9c268d2835010000006a473044022020573f136e62c66ba6130b1fbe7fb87ba8cfbfd9af89227fe10a878a189c3569022043f1fcf6b88cd6befee91899ae92905074fe48ef3f82206638752db6bd90201a0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff020008af2f000000001976a914c73015fa62d972ebb3b241fe8c936657b13fabd788ac00e9a435000000001976a91482d6e3eb4cb25dfd325b4af06948d3a2e064a5f788ac00000000")
            XCTAssertTrue(txSize.uintValue == 376)
            
            let transaction = BTCTransaction(hex: txHex)
            
            XCTAssertTrue(transaction?.inputs.count == 2)
            let input0 = transaction?.inputs[0] as! BTCTransactionInput
            XCTAssertTrue(input0.previousTransactionID == txid0)
            XCTAssertTrue(input0.outpoint.index == 0)
            let input1 = transaction?.inputs[1] as! BTCTransactionInput
            XCTAssertTrue(input1.previousTransactionID == txid1)
            XCTAssertTrue(input1.outpoint.index == 1)
            
            XCTAssertTrue(transaction?.outputs.count == 2)
            let output0 = transaction?.outputs[0] as! BTCTransactionOutput
            XCTAssertTrue(output0.script.hex == "76a914c73015fa62d972ebb3b241fe8c936657b13fabd788ac")
            XCTAssertTrue(output0.value == 800000000)
            XCTAssertTrue(output0.script.standardAddress.base58String == "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv")
            let output1 = transaction?.outputs[1] as! BTCTransactionOutput
            XCTAssertTrue(output1.script.hex == "76a91482d6e3eb4cb25dfd325b4af06948d3a2e064a5f788ac")
            XCTAssertTrue(output1.value == 900000000)
            XCTAssertTrue(output1.script.standardAddress.base58String == changeAddress0)
            
            XCTAssertTrue(realToAddresses.count == 1)
            XCTAssertTrue(realToAddresses[0] == "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv")
        }
        
        func testCreateSignedSerializedTransactionHexAndBIP69_5_2() -> () {
            let toAddressesAndAmounts = [["address": toAddress, "amount": toAmount]]
            
            accountObject.unspentOutputs = Array<TLUnspentOutputObject>()
            accountObject.unspentOutputs!.append(unspentOutput1)
            accountObject.unspentOutputs!.append(unspentOutput0)
            accountObject.stealthPaymentUnspentOutputs = Array<TLUnspentOutputObject>()
            
            let ret = TLSpaghettiGodSend.createSignedSerializedTransactionHex(isTestnet, coinType: accountObject.getSelectedObjectCoinType(),  sendFromAccounts: sendFromAccounts, sendFromAddresses: sendFromAddresses, toAddressesAndAmounts: toAddressesAndAmounts as NSArray, feeAmount: feeAmount, error: {
                (data: String?) in
            })
            
            let txHexAndTxHash = ret.0
            let realToAddresses = ret.1
            let txHex = txHexAndTxHash!.object(forKey: "txHex") as! String
            let txHash = txHexAndTxHash!.object(forKey: "txHash") as! String
            let txSize = txHexAndTxHash!.object(forKey: "txSize") as! NSNumber
            XCTAssertTrue(txHash == "9d332311d0a172ef2f875fc76ac261ddac4debbd86cbf0711d9c86a5024423dd")
            XCTAssertTrue(txHex == "010000000155605dc6f5c3dc148b6da58442b0b2cd422be385eab2ebea4119ee9c268d2835010000006b483045022100b5a727e693ddc88a13e50513252a3d508757a6bfbd2f4b9b369f37fac41c28c00220392dbb2f4d99c4efd1d346513e695163b1e1564399d4cc1a9f5779b04a5f03aa0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff0200c2eb0b000000001976a91482d6e3eb4cb25dfd325b4af06948d3a2e064a5f788ac0008af2f000000001976a914c73015fa62d972ebb3b241fe8c936657b13fabd788ac00000000")
            XCTAssertTrue(txSize.uintValue == 227)
            
            let transaction = BTCTransaction(hex: txHex)
            
            XCTAssertTrue(transaction?.inputs.count == 1)
            let input0 = transaction?.inputs[0] as! BTCTransactionInput
            XCTAssertTrue(input0.previousTransactionID == txid1)
            XCTAssertTrue(input0.outpoint.index == 1)
            
            XCTAssertTrue(transaction?.outputs.count == 2)
            let output0 = transaction?.outputs[0] as! BTCTransactionOutput
            XCTAssertTrue(output0.script.hex == "76a91482d6e3eb4cb25dfd325b4af06948d3a2e064a5f788ac")
            XCTAssertTrue(output0.value == 200000000)
            XCTAssertTrue(output0.script.standardAddress.base58String == changeAddress0)
            let output1 = transaction?.outputs[1] as! BTCTransactionOutput
            XCTAssertTrue(output1.script.hex == "76a914c73015fa62d972ebb3b241fe8c936657b13fabd788ac")
            XCTAssertTrue(output1.value == 800000000)
            XCTAssertTrue(output1.script.standardAddress.base58String == "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv")
            
            XCTAssertTrue(realToAddresses.count == 1)
            XCTAssertTrue(realToAddresses[0] == "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv")
        }
        
        testCreateSignedSerializedTransactionHexAndBIP69_5_1()
        testCreateSignedSerializedTransactionHexAndBIP69_5_2()
    }

    func testCreateSignedSerializedTransactionHexAndBIP69_6() -> () {
        guard let accountObject = accountObject else {
            return
        }
        let feeAmount = TLCurrencyFormat.amountStringToCoin("0.00000", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        let toAddress = "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv"
        let toAddress2 = "1DZTzaBHUDM7T3QvUKBz4qXMRpkg8jsfB5"
        let toAmount = TLCurrencyFormat.amountStringToCoin("1", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        let toAmount2 = TLCurrencyFormat.amountStringToCoin("1", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        
        let txid0 = "35288d269cee1941eaebb2ea85e32b42cdb2b04284a56d8b14dcc3f5c65d6055"
        let txid1 = "35288d269cee1941eaebb2ea85e32b42cdb2b04284a56d8b14dcc3f5c65d6055"
        
        let unspentOutput0 = mockUnspentOutput(txid0, value: 100000000, txOutputN: 0)
        let unspentOutput1 = mockUnspentOutput(txid1, value: 100000000, txOutputN: 1)
        
        func testCreateSignedSerializedTransactionHexAndBIP69_6_1() -> () {
            let toAddressesAndAmounts = [["address": toAddress, "amount": toAmount], ["address": toAddress2, "amount": toAmount2]]
            
            accountObject.unspentOutputs = Array<TLUnspentOutputObject>()
            accountObject.unspentOutputs!.append(unspentOutput0)
            accountObject.unspentOutputs!.append(unspentOutput1)
            accountObject.stealthPaymentUnspentOutputs = Array<TLUnspentOutputObject>()
            
            let ret = TLSpaghettiGodSend.createSignedSerializedTransactionHex(isTestnet, coinType: accountObject.getSelectedObjectCoinType(),  sendFromAccounts: sendFromAccounts, sendFromAddresses: sendFromAddresses, toAddressesAndAmounts: toAddressesAndAmounts as NSArray, feeAmount: feeAmount, error: {
                (data: String?) in
            })
            
            let txHexAndTxHash = ret.0
            let realToAddresses = ret.1
            let txHex = txHexAndTxHash!.object(forKey: "txHex") as! String
            let txHash = txHexAndTxHash!.object(forKey: "txHash") as! String
            let txSize = txHexAndTxHash!.object(forKey: "txSize") as! NSNumber
            XCTAssertTrue(txHash == "1b27e859e51c272c6fa539e8579649cf0ba3d6ac560c38e3d93d83edd85adedc")
            XCTAssertTrue(txHex == "010000000255605dc6f5c3dc148b6da58442b0b2cd422be385eab2ebea4119ee9c268d2835000000006b483045022100a24aec6b79e3907be855490f4e9e4a7c28c67181b707df50599e1b7381f578810220275c84a766f8088e92de8e01de291ce7edc50a7dc8e8afa28741fe80c0ab91860121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff55605dc6f5c3dc148b6da58442b0b2cd422be385eab2ebea4119ee9c268d2835010000006a473044022014ed6ef24ff1048d29ec8b2ed8602299e85b4a39a98df7cc3f0ea02db11a345c022008d955f96e52fc85d2fe0d42c6f3c4b04fc6b43ef87978c4a01c10afb59041a40121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff0200e1f505000000001976a91489c55a3ca6676c9f7f260a6439c83249b747380288ac00e1f505000000001976a914c73015fa62d972ebb3b241fe8c936657b13fabd788ac00000000")
            XCTAssertTrue(txSize.uintValue == 376)
            
            let transaction = BTCTransaction(hex: txHex)
            
            XCTAssertTrue(transaction?.inputs.count == 2)
            let input0 = transaction?.inputs[0] as! BTCTransactionInput
            XCTAssertTrue(input0.previousTransactionID == txid0)
            XCTAssertTrue(input0.outpoint.index == 0)
            let input1 = transaction?.inputs[1] as! BTCTransactionInput
            XCTAssertTrue(input1.previousTransactionID == txid1)
            XCTAssertTrue(input1.outpoint.index == 1)
            
            XCTAssertTrue(transaction?.outputs.count == 2)
            let output0 = transaction?.outputs[0] as! BTCTransactionOutput
            XCTAssertTrue(output0.script.hex == "76a91489c55a3ca6676c9f7f260a6439c83249b747380288ac")
            XCTAssertTrue(output0.value == 100000000)
            XCTAssertTrue(output0.script.standardAddress.base58String == "1DZTzaBHUDM7T3QvUKBz4qXMRpkg8jsfB5")
            let output1 = transaction?.outputs[1] as! BTCTransactionOutput
            XCTAssertTrue(output1.script.hex == "76a914c73015fa62d972ebb3b241fe8c936657b13fabd788ac")
            XCTAssertTrue(output1.value == 100000000)
            XCTAssertTrue(output1.script.standardAddress.base58String == "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv")
            
            XCTAssertTrue(realToAddresses.count == 2)
            XCTAssertTrue(realToAddresses[0] == "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv")
            XCTAssertTrue(realToAddresses[1] == "1DZTzaBHUDM7T3QvUKBz4qXMRpkg8jsfB5")
        }
        
        testCreateSignedSerializedTransactionHexAndBIP69_6_1()
    }
    
    func testColdWallet_1() -> () {
        guard let accountObject = accountObject else {
            return
        }
        let feeAmount = TLCurrencyFormat.amountStringToCoin("0.00000", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        let toAddress = "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv"
        let toAddress2 = "1DZTzaBHUDM7T3QvUKBz4qXMRpkg8jsfB5"
        let toAmount = TLCurrencyFormat.amountStringToCoin("1", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        let toAmount2 = TLCurrencyFormat.amountStringToCoin("24", coinType: TLCoinType.BTC, coinDenomination: TLCoinDenomination.bitcoin)
        
        let txid0 = "35288d269cee1941eaebb2ea85e32b42cdb2b04284a56d8b14dcc3f5c65d6055"
        let txid1 = "35288d269cee1941eaebb2ea85e32b42cdb2b04284a56d8b14dcc3f5c65d6055"
        
        let unspentOutput0 = mockUnspentOutput(txid0, value: 100000000, txOutputN: 0)
        let unspentOutput1 = mockUnspentOutput(txid1, value: 2400000000, txOutputN: 1)
        
        func testColdWallet_1_1() -> () {
            let toAddressesAndAmounts = [["address": toAddress, "amount": toAmount], ["address": toAddress2, "amount": toAmount2]]
            
            accountObject.unspentOutputs = Array<TLUnspentOutputObject>()
            accountObject.unspentOutputs!.append(unspentOutput0)
            accountObject.unspentOutputs!.append(unspentOutput1)
            accountObject.stealthPaymentUnspentOutputs = Array<TLUnspentOutputObject>()
            
            let ret = TLSpaghettiGodSend.createSignedSerializedTransactionHex(isTestnet, coinType: accountObject.getSelectedObjectCoinType(),  sendFromAccounts: sendFromAccounts, sendFromAddresses: sendFromAddresses, toAddressesAndAmounts: toAddressesAndAmounts as NSArray, feeAmount: feeAmount, signTx: false, error: {
                (data: String?) in
            })
            
            let txHexAndTxHash = ret.0
            let realToAddresses = ret.1
            let txInputsAccountHDIdxes = ret.2
            let unSignedTx = txHexAndTxHash!.object(forKey: "txHex") as! String
            let inputScripts = txHexAndTxHash!.object(forKey: "inputScripts") as! NSArray

            let unsignedTxAirGapDataBase64 = TLColdWallet.createSerializedUnsignedTxAipGapData(unSignedTx, extendedPublicKey: extendPubKey, inputScripts: inputScripts, txInputsAccountHDIdxes: txInputsAccountHDIdxes!)
            NSLog("testColdWallet_1_1 unsignedTxAirGapDataBase64 \(unsignedTxAirGapDataBase64)");
            //XCTAssertTrue will fail because json serialization in Foundation from a dictionary object does not always return the same json serialized string. ie order of keys and values can be different in the serialize version. This probably change with a Swift version update.
//            XCTAssertTrue(unsignedTxAirGapDataBase64 == "eyJ0eF9pbnB1dHNfYWNjb3VudF9oZF9pZHhlcyI6W3siaWR4IjowLCJpc19jaGFuZ2UiOmZhbHNlfSx7ImlkeCI6MCwiaXNfY2hhbmdlIjpmYWxzZX1dLCJhY2NvdW50X3B1YmxpY19rZXkiOiJ4cHViNkQxaDY1enE5RlIycG12UU5CNkZpaWoyNGRZeHBKZkhpbVl4aWJtZnhCZmd6ZnBvYlZTalF3Y3ZGUHI3cFRBVFJpc3ByYzJZd1lZV2l5c1VFdkoxdTlpdUFRS01Oc2lMbjJQUFNydFZGdDYiLCJ1bnNpZ25lZF90eF9iYXNlNjQiOiJBUUFBQUFKVllGM0c5Y1BjRkl0dHBZUkNzTExOUWl2amhlcXk2K3BCR2U2Y0pvMG9OUUFBQUFBQVwvXC9cL1wvXC8xVmdYY2Ixdzl3VWkyMmxoRUt3c3MxQ0srT0Y2ckxyNmtFWjdwd21qU2cxQVFBQUFBRFwvXC9cL1wvXC9BZ0RoOVFVQUFBQUFHWGFwRk1jd0ZmcGkyWExyczdKQlwvb3lUWmxleFA2dlhpS3dBR0EyUEFBQUFBQmwycVJTSnhWbzhwbWRzbjM4bUNtUTV5REpKdDBjNEFvaXNBQUFBQUE9PSIsInYiOiIxIiwiaW5wdXRfc2NyaXB0cyI6WyI3NmE5MTRjNmI0ZWJhOTcyYzIyN2FjMDQ1OGRiYTk1MWI0ODEyMzFlNGQ1ZmQ3ODhhYyIsIjc2YTkxNGM2YjRlYmE5NzJjMjI3YWMwNDU4ZGJhOTUxYjQ4MTIzMWU0ZDVmZDc4OGFjIl19")
            
            
            let unsignedTxAirGapDataBase64PartsArray = TLColdWallet.splitStringToArray(unsignedTxAirGapDataBase64!)
            //Pass unsigned tx here ----------------------------------------------------------------------------------------
            var passedUnsignedTxairGapDataBase64 = ""
            for unsignedTxAirGapDataBase64Part in unsignedTxAirGapDataBase64PartsArray {
                let ret = TLColdWallet.parseScannedPart(unsignedTxAirGapDataBase64Part)
                let dataPart = ret.0
                //let partNumber = ret.1 // unused in test
                //let totalParts = ret.2 // unused in test
                passedUnsignedTxairGapDataBase64 += dataPart
            }
            XCTAssertTrue(passedUnsignedTxairGapDataBase64 == unsignedTxAirGapDataBase64)
            
            do {
                let serializedSignedAipGapData = try TLColdWallet.createSerializedSignedTxAipGapData(self.coinType, aipGapDataBase64: passedUnsignedTxairGapDataBase64,
                                                                                                     mnemonicOrExtendedPrivateKey: backupPassphrase,
                                                                                                     isTestnet: false)
                NSLog("testColdWallet_1_1 serializedSignedAipGapData \(serializedSignedAipGapData)");
                XCTAssertTrue(serializedSignedAipGapData == "eyJ0eEhleCI6IjAxMDAwMDAwMDI1NTYwNWRjNmY1YzNkYzE0OGI2ZGE1ODQ0MmIwYjJjZDQyMmJlMzg1ZWFiMmViZWE0MTE5ZWU5YzI2OGQyODM1MDAwMDAwMDA2YTQ3MzA0NDAyMjA0NDliMWY5NTY4N2JmNDY5ZmI5NTRiY2RiYmMwYWUzNjJmZTliZDZiYTg4YzViNGRkMjI3ZDlhNWMzN2ViODJhMDIyMDM0NDBiZjZiNDE3ODc4NjkxM2ExOTczNDRkMDk5OWE3ZDk4ZDI0NjA5OWRjZGRmNGJmOWIyNDQ3M2E0ZTdhOWEwMTIxMDI3ZWNiYTllYmM0Njk5ZGY3ZjU1N2M0ZTE4MTkyZWZiNWM5N2IxZmY0ZWNkY2ViYjRlMjFiYjdkMWZlZDIyMDNhZmZmZmZmZmY1NTYwNWRjNmY1YzNkYzE0OGI2ZGE1ODQ0MmIwYjJjZDQyMmJlMzg1ZWFiMmViZWE0MTE5ZWU5YzI2OGQyODM1MDEwMDAwMDA2YTQ3MzA0NDAyMjAxZjZhNGE4N2QwNTg0MTU3NDcxMjEwYzFlMTI2ZTY0ZTUyZjU2NWU5NTBmZWI4MDA0NWZjODU1ODI5ZGYzZGE0MDIyMDU5ZmQ3NWZlNTEyNjJhYTdiN2YyMTQ1MzQzNTdlZDI3ODZhOWIzZGNiMTI0OTMxMTIwMjc3MTFhZWJjODQ3OGEwMTIxMDI3ZWNiYTllYmM0Njk5ZGY3ZjU1N2M0ZTE4MTkyZWZiNWM5N2IxZmY0ZWNkY2ViYjRlMjFiYjdkMWZlZDIyMDNhZmZmZmZmZmYwMjAwZTFmNTA1MDAwMDAwMDAxOTc2YTkxNGM3MzAxNWZhNjJkOTcyZWJiM2IyNDFmZThjOTM2NjU3YjEzZmFiZDc4OGFjMDAxODBkOGYwMDAwMDAwMDE5NzZhOTE0ODljNTVhM2NhNjY3NmM5ZjdmMjYwYTY0MzljODMyNDliNzQ3MzgwMjg4YWMwMDAwMDAwMCIsInR4SGFzaCI6ImZiYWNmZWRlNTVkYzZhNzc5NzgyYmE4ZmEyMjgxMzg2MGI3ZWYwN2Q4MmMzYWJlYmI4ZjI5MGIzMTQxYmY5NjUiLCJ0eFNpemUiOjM3Nn0=")
                
                
                
                let signedTxAirGapDataBase64PartsArray = TLColdWallet.splitStringToArray(serializedSignedAipGapData!)
                //Pass signed tx here ----------------------------------------------------------------------------------------
                var passedSignedTxairGapDataBase64 = ""
                for signedTxAirGapDataBase64Part in signedTxAirGapDataBase64PartsArray {
                    let ret = TLColdWallet.parseScannedPart(signedTxAirGapDataBase64Part)
                    let dataPart = ret.0
                    //let partNumber = ret.1 // unused in test
                    //let totalParts = ret.2 // unused in test
                    passedSignedTxairGapDataBase64 += dataPart
                }
                XCTAssertTrue(passedSignedTxairGapDataBase64 == serializedSignedAipGapData)
                
                
                let signedTxData = TLColdWallet.getSignedTxData(passedSignedTxairGapDataBase64)
                let txHex = signedTxData!["txHex"] as! String
                let txHash = signedTxData!["txHash"] as! String
                let txSize = signedTxData!["txSize"] as! NSNumber
                
                XCTAssertTrue(txHash == "fbacfede55dc6a779782ba8fa22813860b7ef07d82c3abebb8f290b3141bf965")
                XCTAssertTrue(txHex == "010000000255605dc6f5c3dc148b6da58442b0b2cd422be385eab2ebea4119ee9c268d2835000000006a4730440220449b1f95687bf469fb954bcdbbc0ae362fe9bd6ba88c5b4dd227d9a5c37eb82a02203440bf6b4178786913a197344d0999a7d98d246099dcddf4bf9b24473a4e7a9a0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff55605dc6f5c3dc148b6da58442b0b2cd422be385eab2ebea4119ee9c268d2835010000006a47304402201f6a4a87d0584157471210c1e126e64e52f565e950feb80045fc855829df3da4022059fd75fe51262aa7b7f214534357ed2786a9b3dcb12493112027711aebc8478a0121027ecba9ebc4699df7f557c4e18192efb5c97b1ff4ecdcebb4e21bb7d1fed2203affffffff0200e1f505000000001976a914c73015fa62d972ebb3b241fe8c936657b13fabd788ac00180d8f000000001976a91489c55a3ca6676c9f7f260a6439c83249b747380288ac00000000")
                XCTAssertTrue(txSize.uintValue == 376)
                
                let transaction = BTCTransaction(hex: txHex)
                
                XCTAssertTrue(transaction?.inputs.count == 2)
                let input0 = transaction?.inputs[0] as! BTCTransactionInput
                XCTAssertTrue(input0.previousTransactionID == txid0)
                XCTAssertTrue(input0.outpoint.index == 0)
                let input1 = transaction?.inputs[1] as! BTCTransactionInput
                XCTAssertTrue(input1.previousTransactionID == txid1)
                XCTAssertTrue(input1.outpoint.index == 1)
                
                XCTAssertTrue(transaction?.outputs.count == 2)
                let output0 = transaction?.outputs[0] as! BTCTransactionOutput
                XCTAssertTrue(output0.script.hex == "76a914c73015fa62d972ebb3b241fe8c936657b13fabd788ac")
                XCTAssertTrue(output0.value == 100000000)
                XCTAssertTrue(output0.script.standardAddress.base58String == "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv")
                let output1 = transaction?.outputs[1] as! BTCTransactionOutput
                XCTAssertTrue(output1.script.hex == "76a91489c55a3ca6676c9f7f260a6439c83249b747380288ac")
                XCTAssertTrue(output1.value == 2400000000)
                XCTAssertTrue(output1.script.standardAddress.base58String == "1DZTzaBHUDM7T3QvUKBz4qXMRpkg8jsfB5")
                
                XCTAssertTrue(realToAddresses.count == 2)
                XCTAssertTrue(realToAddresses[0] == "1KAD5EnzzLtrSo2Da2G4zzD7uZrjk8zRAv")
                XCTAssertTrue(realToAddresses[1] == "1DZTzaBHUDM7T3QvUKBz4qXMRpkg8jsfB5")
                
                
                
            } catch TLColdWallet.TLColdWalletError.InvalidKey(let error) {
            } catch TLColdWallet.TLColdWalletError.MisMatchExtendedPublicKey(let error) {
            } catch {
            }
        }
        
        testColdWallet_1_1()
    }
    
    func testCoin() {
        
        var coin:TLCoin
        let coinType = TLCoinType.BTC
        coin = TLCurrencyFormat.coinAmountStringToCoin("0.0", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 0)
        coin = TLCurrencyFormat.coinAmountStringToCoin("0", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 0)

        coin = TLCurrencyFormat.coinAmountStringToCoin("0.00000001", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 1)
        //coin = TLCurrencyFormat.coinAmountStringToCoin("0.000000011", coinType: coinType)
        //XCTAssertTrue(coin.toUInt64() == 1)
        //coin = TLCurrencyFormat.coinAmountStringToCoin("0.000000015", coinType: coinType)
        //XCTAssertTrue(coin.toUInt64() == 2)
        //coin = TLCurrencyFormat.coinAmountStringToCoin("0.000000019", coinType: coinType)
        //XCTAssertTrue(coin.toUInt64() == 2)

        coin = TLCurrencyFormat.coinAmountStringToCoin("0.1", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 10000000)

        coin = TLCurrencyFormat.coinAmountStringToCoin(".99999998", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 99999998)
        //coin = TLCurrencyFormat.coinAmountStringToCoin(".999999985", coinType: coinType)
        //XCTAssertTrue(coin.toUInt64() == 99999998)
        //coin = TLCurrencyFormat.coinAmountStringToCoin(".999999986", coinType: coinType)
        //XCTAssertTrue(coin.toUInt64() == 99999999)
        //coin = TLCurrencyFormat.coinAmountStringToCoin(".999999989", coinType: coinType)
        //XCTAssertTrue(coin.toUInt64() == 99999999)

        coin = TLCurrencyFormat.coinAmountStringToCoin("0.99999999", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 99999999)
        coin = TLCurrencyFormat.coinAmountStringToCoin(".99999999", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 99999999)

        coin = TLCurrencyFormat.coinAmountStringToCoin("1.00000000", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 100000000)
        coin = TLCurrencyFormat.coinAmountStringToCoin("1", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 100000000)

        coin = TLCurrencyFormat.coinAmountStringToCoin("1.00000001", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 100000001)

        coin = TLCurrencyFormat.coinAmountStringToCoin("1.99999998", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 199999998)
        
        coin = TLCurrencyFormat.coinAmountStringToCoin("1.99999999", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 199999999)

        coin = TLCurrencyFormat.coinAmountStringToCoin("2.0", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 200000000)

        coin = TLCurrencyFormat.coinAmountStringToCoin("2.00000001", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 200000001)

        coin = TLCurrencyFormat.coinAmountStringToCoin("31,821.95320551", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 3182195320551)
        coin = TLCurrencyFormat.coinAmountStringToCoin("31821.95320551", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 3182195320551)

        coin = TLCurrencyFormat.coinAmountStringToCoin("21,000,000", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 2100000000000000)
        coin = TLCurrencyFormat.coinAmountStringToCoin("21000000", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 2100000000000000)
        
        
        let spainLocale = Locale(identifier: "es_ES")
        coin = TLCurrencyFormat.coinAmountStringToCoin("0,0", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 0)
        coin = TLCurrencyFormat.coinAmountStringToCoin("0", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 0)
        
        coin = TLCurrencyFormat.coinAmountStringToCoin("0,00000001", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 1)
        
        coin = TLCurrencyFormat.coinAmountStringToCoin("0,1", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 10000000)
        
        coin = TLCurrencyFormat.coinAmountStringToCoin(",99999998", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 99999998)
        
        coin = TLCurrencyFormat.coinAmountStringToCoin("0,99999999", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 99999999)
        coin = TLCurrencyFormat.coinAmountStringToCoin(",99999999", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 99999999)
        
        coin = TLCurrencyFormat.coinAmountStringToCoin("1,00000000", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 100000000)
        coin = TLCurrencyFormat.coinAmountStringToCoin("1", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 100000000)
        
        coin = TLCurrencyFormat.coinAmountStringToCoin("1,00000001", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 100000001)
        
        coin = TLCurrencyFormat.coinAmountStringToCoin("1,99999998", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 199999998)
        
        coin = TLCurrencyFormat.coinAmountStringToCoin("1,99999999", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 199999999)
        
        coin = TLCurrencyFormat.coinAmountStringToCoin("2,0", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 200000000)
        
        coin = TLCurrencyFormat.coinAmountStringToCoin("2,00000001", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 200000001)
        
        coin = TLCurrencyFormat.coinAmountStringToCoin("31.821,95320551", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 3182195320551)
        coin = TLCurrencyFormat.coinAmountStringToCoin("31821,95320551", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 3182195320551)
        
        coin = TLCurrencyFormat.coinAmountStringToCoin("21.000.000", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 2100000000000000)
        coin = TLCurrencyFormat.coinAmountStringToCoin("21000000", coinType: coinType, locale: spainLocale)
        XCTAssertTrue(coin.toUInt64() == 2100000000000000)
        
        
                
        TLPreferences.setBitcoinDisplayUnit("1")
        coin = TLCurrencyFormat.properBitcoinAmountStringToCoin("1000", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 100000000)

        TLPreferences.setBitcoinDisplayUnit("2")
        coin = TLCurrencyFormat.properBitcoinAmountStringToCoin("1000000", coinType: coinType)
        XCTAssertTrue(coin.toUInt64() == 100000000)

        TLPreferences.setBitcoinDisplayUnit("0")
    }

    func testCoreBitcoinWrapper() {
        let outputScript = "76a9149a1c78a507689f6f54b847ad1cef1e614ee23f1e88ac"
        var address = TLCoreBitcoinWrapper.getAddressFromOutputScript(self.coinType, scriptHex: outputScript, isTestnet: false)
        NSLog("address: %@", address!)
        XCTAssertTrue(address == "1F3sAm6ZtwLAUnj7d38pGFxtP3RVEvtsbV")
        address = TLCoreBitcoinWrapper.getAddressFromOutputScript(self.coinType, scriptHex: outputScript, isTestnet: true)
        NSLog("address: %@", address!)
        XCTAssertTrue(address == "muZpTpBYhxmRFuCjLc7C6BBDF32C8XVJUi")
        
        
        let secret = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        address = TLCoreBitcoinWrapper.getAddressFromSecret(self.coinType, secret: secret, isTestnet: false)
        NSLog("address: %@", address!)
        XCTAssertTrue(address == "1F3sAm6ZtwLAUnj7d38pGFxtP3RVEvtsbV")
        address = TLCoreBitcoinWrapper.getAddressFromSecret(self.coinType, secret: secret, isTestnet: true)
        NSLog("address: %@", address!)
        XCTAssertTrue(address == "muZpTpBYhxmRFuCjLc7C6BBDF32C8XVJUi")

        var privateKey:String
        privateKey = TLCoreBitcoinWrapper.privateKeyFromSecret(self.coinType, secret: secret, isTestnet: false)
        NSLog("privateKey: %@", privateKey)
        XCTAssertTrue(privateKey == "L4rK1yDtCWekvXuE6oXD9jCYfFNV2cWRpVuPLBcCU2z8TrisoyY1")
        privateKey = TLCoreBitcoinWrapper.privateKeyFromSecret(self.coinType, secret: secret, isTestnet: true)
        NSLog("privateKey: %@", privateKey)
        XCTAssertTrue(privateKey == "cVDJUtDjdaM25yNVVDLLX3hcHUfth4c7tY3rSc4hy9e8ibtCuj6G")

        var pubKeyHash:String
        pubKeyHash = TLCoreBitcoinWrapper.getStandardPubKeyHashScriptFromAddress(self.coinType, address: "1F3sAm6ZtwLAUnj7d38pGFxtP3RVEvtsbV", isTestnet: false)
        NSLog("pubKeyHash: %@", pubKeyHash)
        XCTAssertTrue(pubKeyHash == "76a9149a1c78a507689f6f54b847ad1cef1e614ee23f1e88ac")
        pubKeyHash = TLCoreBitcoinWrapper.getStandardPubKeyHashScriptFromAddress(self.coinType, address: "muZpTpBYhxmRFuCjLc7C6BBDF32C8XVJUi", isTestnet: true)
        NSLog("pubKeyHash: %@", pubKeyHash)
        XCTAssertTrue(pubKeyHash == "76a9149a1c78a507689f6f54b847ad1cef1e614ee23f1e88ac")

        address = TLCoreBitcoinWrapper.getAddress(self.coinType, privateKey: "L4rK1yDtCWekvXuE6oXD9jCYfFNV2cWRpVuPLBcCU2z8TrisoyY1", isTestnet: false)
        NSLog("address: %@", address!)
        XCTAssertTrue(address! == "1F3sAm6ZtwLAUnj7d38pGFxtP3RVEvtsbV")
        address = TLCoreBitcoinWrapper.getAddress(self.coinType, privateKey: "5KYZdUEo39z3FPrtuX2QbbwGnNP5zTd7yyr2SC1j299sBCnWjss", isTestnet: false)
        NSLog("address: %@", address!)
        XCTAssertTrue(address! == "1HZwkjkeaoZfTSaJxDw6aKkxp45agDiEzN")
        address = TLCoreBitcoinWrapper.getAddress(self.coinType, privateKey: "cVDJUtDjdaM25yNVVDLLX3hcHUfth4c7tY3rSc4hy9e8ibtCuj6G", isTestnet: true)
        NSLog("address: %@", address!)
        XCTAssertTrue(address! == "muZpTpBYhxmRFuCjLc7C6BBDF32C8XVJUi")
        address = TLCoreBitcoinWrapper.getAddress(self.coinType, privateKey: "93KCDD4LdP4BDTNBXrvKUCVES2jo9dAKKvhyWpNEMstuxDauHty", isTestnet: true)
        NSLog("address: %@", address!)
        XCTAssertTrue(address! == "mx5u3nqdPpzvEZ3vfnuUQEyHg3gHd8zrrH")

        
        let compressedPubKey = "03a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd"
        address = TLCoreBitcoinWrapper.getAddressFromPublicKey(self.coinType, publicKey: compressedPubKey, isTestnet: false)
        NSLog("address: %@", address!)
        XCTAssertTrue(address == "1F3sAm6ZtwLAUnj7d38pGFxtP3RVEvtsbV")
        address = TLCoreBitcoinWrapper.getAddressFromPublicKey(self.coinType, publicKey: compressedPubKey, isTestnet: true)
        NSLog("address: %@", address!)
        XCTAssertTrue(address == "muZpTpBYhxmRFuCjLc7C6BBDF32C8XVJUi")
        let uncompressedPubKey = "04a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd5b8dec5235a0fa8722476c7709c02559e3aa73aa03918ba2d492eea75abea235"
        address = TLCoreBitcoinWrapper.getAddressFromPublicKey(self.coinType, publicKey: uncompressedPubKey, isTestnet: false)
        NSLog("address: %@", address!)
        XCTAssertTrue(address == "1HZwkjkeaoZfTSaJxDw6aKkxp45agDiEzN")
        address = TLCoreBitcoinWrapper.getAddressFromPublicKey(self.coinType, publicKey: uncompressedPubKey, isTestnet: true)
        NSLog("address: %@", address!)
        XCTAssertTrue(address == "mx5u3nqdPpzvEZ3vfnuUQEyHg3gHd8zrrH")

        XCTAssertTrue(TLCoreBitcoinWrapper.isAddressVersion0(self.coinType, address: "1F3sAm6ZtwLAUnj7d38pGFxtP3RVEvtsbV", isTestnet: false))
        XCTAssertTrue(TLCoreBitcoinWrapper.isAddressVersion0(self.coinType, address: "muZpTpBYhxmRFuCjLc7C6BBDF32C8XVJUi", isTestnet: true))
        XCTAssertTrue(TLCoreBitcoinWrapper.isAddressVersion0(self.coinType, address: "n2MLT38EuTYgK8GcDrL2JQqbVvkSCGGf6S", isTestnet: true))
        XCTAssertTrue(!TLCoreBitcoinWrapper.isAddressVersion0(self.coinType, address: "3EktnHQD7RiAE6uzMj2ZifT9YgRrkSgzQX", isTestnet: false))
        XCTAssertTrue(!TLCoreBitcoinWrapper.isAddressVersion0(self.coinType, address: "2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc", isTestnet: true))
        
        // address = 13adjLZo3iUEZuQEeEAkyRvw2nKKrGLuKJ password = "murray rothbard"
        XCTAssertTrue(TLCoreBitcoinWrapper.isBIP38EncryptedKey(self.coinType, privateKey: "6PfRr3RtH3GKh7qcRUfEe5rAcFBBcKxJAvQWZPwpksfL6dxTpC9kqMctoE", isTestnet: false))
        // address = n1nKsF2UvyPgG3QLYupR4mwv1fQwLEJf9b password = "murray rothbard"
        XCTAssertTrue(TLCoreBitcoinWrapper.isBIP38EncryptedKey(self.coinType, privateKey: "6PfSacWmYziVFFjHqiAHM9nvxsZDMBpDnPtWVQSNgSH9qpo1s1VCCWYEno", isTestnet: true))
        
        XCTAssertTrue(TLCoreBitcoinWrapper.isValidAddress(self.coinType, address: "1F3sAm6ZtwLAUnj7d38pGFxtP3RVEvtsbV", isTestnet: false))
        XCTAssertTrue(TLCoreBitcoinWrapper.isValidAddress(self.coinType, address: "muZpTpBYhxmRFuCjLc7C6BBDF32C8XVJUi", isTestnet: true))
        XCTAssertTrue(TLCoreBitcoinWrapper.isValidAddress(self.coinType, address: "3EktnHQD7RiAE6uzMj2ZifT9YgRrkSgzQX", isTestnet: false))
        XCTAssertTrue(TLCoreBitcoinWrapper.isValidAddress(self.coinType, address: "2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc", isTestnet: true))
        XCTAssertTrue(TLCoreBitcoinWrapper.isValidAddress(self.coinType, address: "vJmujDzf2PyDEcLQEQWyzVNthLpRAXqTi3ZencThu2WCzrRNi64eFYJP6ZyPWj53hSZBKTcUAk8J5Mb8rZC4wvGn77Sj4Z3yP7zE69", isTestnet: false))
        XCTAssertTrue(TLCoreBitcoinWrapper.isValidAddress(self.coinType, address: "waPUEHTatbqyM6RKtsbdCy63fqyjwW6ksSCi5KhD1NTGdYrvAgvSAneAqDooHxVzpMAx8nZLzZTnhAGM1WxpRFvvp9zF6wFuAA7dNW", isTestnet: true))

        XCTAssertTrue(TLCoreBitcoinWrapper.isValidPrivateKey(self.coinType, privateKey: "L4rK1yDtCWekvXuE6oXD9jCYfFNV2cWRpVuPLBcCU2z8TrisoyY1", isTestnet: false))
        XCTAssertTrue(TLCoreBitcoinWrapper.isValidPrivateKey(self.coinType, privateKey: "cVDJUtDjdaM25yNVVDLLX3hcHUfth4c7tY3rSc4hy9e8ibtCuj6G", isTestnet: true))
    }

    func testHDWalletWrapper() {
        let extendPrivKey = "xprv9z2LgaTwJsrjcHqwG9ZFManHWbiUQqwSMYdMvDN4Pr8i7sVf3x8Us9JSQ8FFCT8f7wBDzEVEhTFX3wJdNx2pchEZJ2HNTa4U7NKgM9uWoK6"
        let extendPubKey = "xpub6D1h65zq9FR2pmvQNB6Fiij24dYxpJfHimYxibmfxBfgzfpobVSjQwcvFPr7pTATRisprc2YwYYWiysUEvJ1u9iuAQKMNsiLn2PPSrtVFt6"

        let mainAddressIndex0 = [0,0]
        var mainAddress0:String
        var walletConfig = TLWalletConfig(isTestnet: false)
        mainAddress0 = TLHDWalletWrapper.getAddress(self.coinType, extendPubKey:extendPubKey, sequence:mainAddressIndex0 as NSArray, isTestnet:walletConfig.isTestnet)
        NSLog("mainAddress0: %@", mainAddress0)
        XCTAssertTrue("1K7fXZeeQydcUvbsfvkMSQmiacV5sKRYQz" == mainAddress0)
        var mainPrivKey0:String
        mainPrivKey0 = TLHDWalletWrapper.getPrivateKey(self.coinType, extendPrivKey: extendPrivKey as NSString, sequence:mainAddressIndex0 as NSArray, isTestnet:walletConfig.isTestnet)
        NSLog("mainPrivKey0: %@", mainPrivKey0)
        XCTAssertTrue("KwJhkmrjjg3AEX5gvccNAHCDcXnQLwzyZshnp5yK7vXz1mHKqDDq" == mainPrivKey0)

        walletConfig = TLWalletConfig(isTestnet: true)
        mainAddress0 = TLHDWalletWrapper.getAddress(self.coinType, extendPubKey:extendPubKey, sequence:mainAddressIndex0 as NSArray, isTestnet:walletConfig.isTestnet)
        NSLog("mainAddress0: %@", mainAddress0)
        XCTAssertTrue("mydcpcjdE14sG35VPVijGKz3Sc5nsbbeo7" == mainAddress0)
        mainPrivKey0 = TLHDWalletWrapper.getPrivateKey(self.coinType, extendPrivKey: extendPrivKey as NSString, sequence:mainAddressIndex0 as NSArray, isTestnet:walletConfig.isTestnet)
        NSLog("mainPrivKey0: %@", mainPrivKey0)
        XCTAssertTrue("cMfhDgrbAjjRPxYxK2RVXbhHEm5p1Q6fdurFvWRpd3BzGWQYiFw6" == mainPrivKey0)
    }
}

