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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

    func testSignature() {
        let privKey = "4e422fb1e5e1db6c1f6ab32a7706d368ceb385e7fab098e633c5c5949c3b97cd"
        let challenge = "0000000000000000104424c7eda87ebd4a690b9efa09abc0ec23f2ae4c64cc4e"
        let key = BTCKey(privateKey: BTCDataFromHex(privKey))
        let signature = key.signatureForMessage(challenge)
        NSLog("signature: %@", signature.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength))
        XCTAssertTrue(key.isValidSignature(signature, forMessage: challenge), "")
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
        
        let stealthAddress = TLStealthAddress.createStealthAddress(expectedScanPublicKey, spendPublicKey:expectedSpendPublicKey, isTestnet:isTestNet)
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
        let expectedStealthDataScript = String(format:"%02x%lu%02x%x%@",
            BTCOpcode.OP_RETURN.rawValue,
            TLStealthAddress.getStealthAddressMsgSize(),
            TLStealthAddress.getStealthAddressTransacionVersion(),
            nonce,
            ephemeralPublicKey)
        
        XCTAssertTrue(stealthDataScriptAndPaymentAddress.0 == expectedStealthDataScript)
        
        let key = BTCKey(publicKey:paymentAddressPublicKey.hexToData())
        let paymentAddress = key.address.base58String
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
        NSLog("address: %@", key.address.base58String)
        XCTAssertTrue(key.address.base58String == "1C6gQ79qKKG21AGCA9USKYWPvu6LzoPH5h")
        
        let secret = TLStealthAddress.getPaymentAddressPrivateKeySecretFromScript(stealthDataScript, scanPrivateKey:scanPrivateKey, spendPrivateKey:spendPrivateKey)
        NSLog("secret: %@", secret!)
        key = BTCKey(privateKey: BTCDataFromHex(secret))
        key.publicKeyCompressed = true
        
        NSLog("address: %@", key.address.base58String)
        
        XCTAssertTrue(secret == paymentAddressPrivateKey)
        XCTAssertTrue(key.address.base58String == "1C6gQ79qKKG21AGCA9USKYWPvu6LzoPH5h")
        
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
        var cipherText = TLWalletJson.encrypt(plainText, password:"pass", PBKDF2Iterations:pbk)
        var decryptedText = TLWalletJson.decrypt(cipherText, password:"pass", PBKDF2Iterations:pbk)
        
        NSLog("decryptedText: %@", decryptedText!)
        XCTAssert(plainText == decryptedText)
        
        
        plainText = "test"
        cipherText = TLWalletJson.encrypt("test", password:"pass")
        decryptedText = TLWalletJson.decrypt(cipherText, password:"pass")
        XCTAssert(plainText == decryptedText)
        
        
        plainText = "test"
        cipherText = TLWalletJson.encrypt("test", password:"pass1", PBKDF2Iterations:pbk)
        decryptedText = TLWalletJson.decrypt(cipherText, password:"pass2", PBKDF2Iterations:pbk)
        XCTAssert(decryptedText == nil)
        
        plainText = "test"
        cipherText = TLWalletJson.encrypt("test", password:"pass", PBKDF2Iterations:pbk)
        decryptedText = TLWalletJson.decrypt(cipherText, password:"pass", PBKDF2Iterations:UInt32(1000))
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

        var backupPassphrase = "slogan lottery zone helmet fatigue rebuild solve best hint frown conduct ill"
        let masterHex = TLHDWalletWrapper.getMasterHex(backupPassphrase)
        
        XCTAssertTrue(TLHDWalletWrapper.phraseIsValid(backupPassphrase))
        NSLog("masterHex: %@", masterHex)
        XCTAssertTrue(masterHex == "ae3ff5936bf70293eda11b5ea5ee9585fe9b22c9a80b610ee37251a22120e970c75a18bbd95219a0348c7dee40eeb44a4d2480900be8f931d0cf85203f9d94ce")
        
        
        let extendPrivKey = TLHDWalletWrapper.getExtendPrivKey(masterHex, accountIdx:0)
        NSLog("extendPrivKey: %@", extendPrivKey)
        XCTAssertTrue("xprv9z2LgaTwJsrjcHqwG9ZFManHWbiUQqwSMYdMvDN4Pr8i7sVf3x8Us9JSQ8FFCT8f7wBDzEVEhTFX3wJdNx2pchEZJ2HNTa4U7NKgM9uWoK6" == extendPrivKey)
        
        
        let extendPubKey = TLHDWalletWrapper.getExtendPubKey(extendPrivKey)
        NSLog("extendPubKey: %@", extendPubKey)
        XCTAssertTrue("xpub6D1h65zq9FR2pmvQNB6Fiij24dYxpJfHimYxibmfxBfgzfpobVSjQwcvFPr7pTATRisprc2YwYYWiysUEvJ1u9iuAQKMNsiLn2PPSrtVFt6" == extendPubKey)
        
        
        let mainAddressIndex0 = [0,0]
        let mainAddress0 = TLHDWalletWrapper.getAddress(extendPubKey, sequence:mainAddressIndex0)
        NSLog("mainAddress0: %@", mainAddress0)
        XCTAssertTrue("1K7fXZeeQydcUvbsfvkMSQmiacV5sKRYQz" == mainAddress0)
        TLHDWalletWrapper.getPrivateKey(extendPrivKey, sequence:mainAddressIndex0)
        let mainPrivKey0 = TLHDWalletWrapper.getPrivateKey(extendPrivKey, sequence:mainAddressIndex0)
        NSLog("mainPrivKey0: %@", mainPrivKey0)
        XCTAssertTrue("KwJhkmrjjg3AEX5gvccNAHCDcXnQLwzyZshnp5yK7vXz1mHKqDDq" == mainPrivKey0)
        
        let mainAddressIndex1 = [0,1]
        let mainAddress1 = TLHDWalletWrapper.getAddress(extendPubKey, sequence:mainAddressIndex1)
        NSLog("mainAddress1: %@", mainAddress1)
        XCTAssertTrue("12eQLjACXw6XwfGF9kqBwy9U7Se8qGoBuq" == mainAddress1)
        TLHDWalletWrapper.getPrivateKey(extendPrivKey, sequence:mainAddressIndex0)
        let mainPrivKey1 = TLHDWalletWrapper.getPrivateKey(extendPrivKey, sequence:mainAddressIndex1)
        NSLog("mainPrivKey1: %@", mainPrivKey1)
        XCTAssertTrue("KwpCsb3wBGk7E1M9EXcZWZhRoKBoZLNc63RsSP4YspUR53Ndefyr" == mainPrivKey1)
        
        
        let changeAddressIndex0 = [1,0]
        let changeAddress0 = TLHDWalletWrapper.getAddress(extendPubKey, sequence:changeAddressIndex0)
        NSLog("changeAddress0: %@", changeAddress0)
        XCTAssertTrue("1CvpGn9VxVY1nsWWL3MSWRYaBHdNkCDbmv" == changeAddress0)
        TLHDWalletWrapper.getPrivateKey(extendPrivKey, sequence:changeAddressIndex0)
        let changePrivKey0 = TLHDWalletWrapper.getPrivateKey(extendPrivKey, sequence:changeAddressIndex0)
        NSLog("changePrivKey0: %@", changePrivKey0)
        XCTAssertTrue("L33guNrQHMXdpFd9jpjo2mQzddwLUgUrNzK3KqAM83D9ZU1H5NDN" == changePrivKey0)
        
        let changeAddressIndex1 = [1,1]
        let changeAddress1 = TLHDWalletWrapper.getAddress(extendPubKey, sequence:changeAddressIndex1)
        NSLog("changeAddress1: %@", changeAddress1)
        XCTAssertTrue("17vnH8d1fBbjX7GZx727X2Y6dheaid2NUR" == changeAddress1)
        TLHDWalletWrapper.getPrivateKey(extendPrivKey, sequence:changeAddressIndex1)
        let changePrivKey1 = TLHDWalletWrapper.getPrivateKey(extendPrivKey, sequence:changeAddressIndex1)
        NSLog("changePrivKey1: %@", changePrivKey1)
        XCTAssertTrue("KwiMiFtWv1PXNN3zV67TC59tWJxPbeagMJU1SSr3uLssAC82UKhf" == changePrivKey1)
    }
    
    func testUtils() {
        NSLog("testUtils")

        let txid = "2c441ba4920f03f37866edb5647f2626b64f57ad98b0a8e011af07da0aefcec3"
        
        let txHash = TLWalletUtils.reverseTxidHexString(txid)
        NSLog("txHash: %@", txHash)
        XCTAssertTrue(txHash == "c3ceef0ada07af11e0a8b098ad574fb626267f64b5ed6678f3030f92a41b442c")
        
        let address = TLCoreBitcoinWrapper.getAddressFromOutputScript("76a9147ab89f9fae3f8043dcee5f7b5467a0f0a6e2f7e188ac")
        NSLog("address: %@", address!)
        XCTAssertTrue(address == "1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG")
    }
    
    func testCreateSignedSerializeTransactionHex() {
        NSLog("testCreateSignedSerializeTransactionHex")

        let hash = TLWalletUtils.reverseTxidHexString("935c6975aa65f95cb55616ace8c8bede83b010f7191c0a6d385be1c95992870d").hexToData()
        let script = "76a9149a1c78a507689f6f54b847ad1cef1e614ee23f1e88ac".hexToData()
        let address = "1F3sAm6ZtwLAUnj7d38pGFxtP3RVEvtsbV"
        let privateKey = "L4rK1yDtCWekvXuE6oXD9jCYfFNV2cWRpVuPLBcCU2z8TrisoyY1"
        let txHexAndTxHash = TLCoreBitcoinWrapper.createSignedSerializedTransactionHex([hash], inputIndexes:[0], inputScripts:[script],
            outputAddresses:[address], outputAmounts:[2500000], privateKeys:[privateKey], outputScripts:nil)!
        
        let txHex = txHexAndTxHash.objectForKey("txHex") as! String
        let txHash = txHexAndTxHash.objectForKey("txHash") as! String
        
        NSLog("txHash: %@", txHash)
        NSLog("txHex: %@", txHex)
        
        XCTAssertTrue("121d274734c83488e2bd6a2a3a136823d6099bf5a3517f78931c3ed0b9a2c619" == txHash)
        XCTAssertTrue("01000000010d879259c9e15b386d0a1c19f710b083debec8e8ac1656b55cf965aa75695c93000000006b4830450221009ceebee12f7a6321e39e83a0d0f8ba3db33271439e98addbc2c8518e9dd4d4ab022061965b500a9b1dd154545df086c3cc44661265841c82a4db20c44304711f1a0a012103a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bdffffffff01a0252600000000001976a9149a1c78a507689f6f54b847ad1cef1e614ee23f1e88ac00000000" == txHex)
    }
}
