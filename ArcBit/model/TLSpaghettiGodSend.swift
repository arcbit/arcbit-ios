//
//  TLSpaghettiGodSend.swift
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


@objc class TLSpaghettiGodSend:NSObject {
    
    let DUST_AMOUNT:UInt64 = 546
    
    private var appWallet: TLWallet
    private var sendFromAccounts:NSMutableArray?
    private var sendFromAddresses:NSMutableArray?

    struct STATIC_MEMBERS {
        static var instance:TLSpaghettiGodSend?
    }
    
    init(appWallet: TLWallet) {
        self.appWallet = appWallet
        sendFromAccounts = NSMutableArray()
        sendFromAddresses = NSMutableArray()
        super.init()
    }
    
    private func clearFromAccountsAndAddresses() -> () {
        sendFromAccounts = NSMutableArray()
        sendFromAddresses = NSMutableArray()
    }
    
    func getSelectedSendObject() -> AnyObject? {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            return sendFromAccounts!.objectAtIndex(0)
        } else if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            return sendFromAddresses!.objectAtIndex(0)
        }
        
        return nil
    }
    
    func getSelectedObjectType() -> (TLSelectObjectType) {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            return TLSelectObjectType.Account
        } else if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            return TLSelectObjectType.Address
        }
        
        return TLSelectObjectType.Unknown
    }
    
    private func getLabelForSelectedSendObject() -> String? {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.objectAtIndex(0) as! TLAccountObject
            return accountObject.getAccountName()
        } else if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            let importedAddress = sendFromAddresses!.objectAtIndex(0) as! TLImportedAddress
            return importedAddress.getLabel()
        }
        return nil
    }
    
    func getCurrentFromLabel() -> String? {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.objectAtIndex(0) as! TLAccountObject
            return accountObject.getAccountName()
        } else if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            let importedAddress = sendFromAddresses!.objectAtIndex(0) as! TLImportedAddress
            return importedAddress.getLabel()
        }
        
        return nil
    }
    
    func getStealthAddress() -> String? {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.objectAtIndex(0) as! TLAccountObject
            return accountObject.stealthWallet?.getStealthAddress()
        }
        return nil
    }
    
    func setOnlyFromAccount(accountObject:TLAccountObject) -> () {
        sendFromAddresses = nil
        sendFromAccounts = NSMutableArray(objects:accountObject)
    }
    
    func setOnlyFromAddress(importedAddress:TLImportedAddress) -> () {
        sendFromAccounts = nil
        sendFromAddresses = NSMutableArray(objects:importedAddress)
    }
    
    private func  addSendAccount(accountObject: TLAccountObject) -> () {
        sendFromAccounts!.addObject(accountObject)
    }
    
    private func addImportedAddress(importedAddress:TLImportedAddress) -> () {
        sendFromAddresses!.addObject(importedAddress)
    }
    
    func needWatchOnlyAccountPrivateKey() -> (Bool) {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.objectAtIndex(0) as! TLAccountObject
            return accountObject.isWatchOnly() && !accountObject.hasSetExtendedPrivateKeyInMemory()
        }
        return false
    }
    
    func needWatchOnlyAddressPrivateKey() -> (Bool) {
        if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            let importedAddress = sendFromAddresses!.objectAtIndex(0) as! TLImportedAddress
            return importedAddress.isWatchOnly() && !importedAddress.hasSetPrivateKeyInMemory()
        }
        return false
    }
    
    func needEncryptedPrivateKeyPassword() -> Bool {
        if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            let importedAddress = sendFromAddresses!.objectAtIndex(0) as! TLImportedAddress
            if (importedAddress.isWatchOnly()) {
                return false
            } else {
                return importedAddress.isPrivateKeyEncrypted() && !importedAddress.hasSetPrivateKeyInMemory()
            }
        }
        return false
    }
    
    func getEncryptedPrivateKey () -> (String) {
        assert(sendFromAddresses!.count != 0, "sendFromAddresses!.count == 0")
        let importedAddress = sendFromAddresses!.objectAtIndex(0) as! TLImportedAddress
        assert(importedAddress.isPrivateKeyEncrypted() != false, "! importedAddress isPrivateKeyEncrypted]")
        return importedAddress.getEncryptedPrivateKey()!
    }
    
    func hasFetchedCurrentFromData() -> (Bool) {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.objectAtIndex(0) as! TLAccountObject
            return accountObject.hasFetchedAccountData()
        } else if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            let importedAddress = sendFromAddresses!.objectAtIndex(0) as! TLImportedAddress
            return importedAddress.hasFetchedAccountData()
        }
        return true
    }
    
    func getCurrentFromBalance() -> (TLCoin) {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.objectAtIndex(0) as! TLAccountObject
            return accountObject.getBalance()
        } else if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            let importedAddress = sendFromAddresses!.objectAtIndex(0) as! TLImportedAddress
            return importedAddress.getBalance()!
        }
        return TLCoin.zero()
    }
    
    func getCurrentFromUnspentOutputsSum() -> (TLCoin) {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.objectAtIndex(0) as! TLAccountObject
            return accountObject.getTotalUnspentSum()
        } else if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            let importedAddress = sendFromAddresses!.objectAtIndex(0) as! TLImportedAddress
            return importedAddress.getUnspentSum()!
        }
        return TLCoin.zero()
    }
    
    func getAndSetUnspentOutputs(success:TLWalletUtils.Success, failure:TLWalletUtils.Error) -> () {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject  = sendFromAccounts!.objectAtIndex(0) as! TLAccountObject
            let amount = accountObject.getBalance()
            if (amount.greater(TLCoin.zero())) {
                accountObject.getUnspentOutputs({() in
                    success()
                    }, failure:{() in
                        failure()
                    }
                )
            }
            
        } else {
            var addresses: [String] = []
            addresses.reserveCapacity(sendFromAddresses!.count)
            let importedAddress = sendFromAddresses!.objectAtIndex(0) as! TLImportedAddress
            let amount = importedAddress.getBalance()
            
            if (amount!.greater(TLCoin.zero())) {
                addresses.append(importedAddress.getAddress())
            }
            
            if (addresses.count > 0) {
                TLBlockExplorerAPI.instance().getUnspentOutputs(addresses, success:{(jsonData:AnyObject!) in
                    let unspentOutputs = (jsonData as! NSDictionary).objectForKey("unspent_outputs") as! NSArray
                    
                    let address2UnspentOutputs = NSMutableDictionary(capacity:addresses.count)
                    
                    for _unspentOutput in unspentOutputs {
                        let unspentOutput = _unspentOutput as! NSDictionary
                        let outputScript = unspentOutput.objectForKey("script") as! String
                        
                        let address = TLCoreBitcoinWrapper.getAddressFromOutputScript(outputScript, isTestnet: self.appWallet.walletConfig.isTestnet)
                        if (address == nil) {
                            DLog("address cannot be decoded. not normal pubkeyhash outputScript: %@", function: outputScript)
                            continue
                        }
                        
                        var cachedUnspentOutputs = address2UnspentOutputs.objectForKey(address!) as! NSMutableArray?
                        if (cachedUnspentOutputs == nil) {
                            cachedUnspentOutputs = NSMutableArray()
                            address2UnspentOutputs.setObject(cachedUnspentOutputs!, forKey:address!)
                        }
                        cachedUnspentOutputs!.addObject(unspentOutput)
                    }
                    
                    for _address in address2UnspentOutputs {
                        let address = _address.key as! String
                        let idx = addresses.indexOf(address)
                        let importedAddress = self.sendFromAddresses!.objectAtIndex(idx!) as! TLImportedAddress
                        importedAddress.setUnspentOutputs(address2UnspentOutputs.objectForKey(address) as! NSArray)
                    }
                    
                    success()
                    }, failure:{(code:NSInteger, status:String!) in
                        failure()
                    }
                )
            }
        }
    }
    
    func createSignedSerializedTransactionHex(toAddressesAndAmounts:NSArray,
        feeAmount:TLCoin, nonce: UInt32? = nil, ephemeralPrivateKeyHex: String? = nil, error:TLWalletUtils.ErrorWithString) -> (NSDictionary?, Array<String>) {
            let inputsData = NSMutableArray()
            let outputsData = NSMutableArray()
            var outputValueSum = TLCoin.zero()

            for _toAddressAndAmount in toAddressesAndAmounts {
                let amount = (_toAddressAndAmount as! NSDictionary).objectForKey("amount") as! TLCoin
                outputValueSum = outputValueSum.add(amount)
            }
            let valueNeeded = outputValueSum.add(feeAmount)
            
            var valueSelected = TLCoin.zero()
            
            var changeAddress:NSString? = nil
            var dustAmount:UInt64 = 0
            
            if sendFromAddresses != nil {
                for _importedAddress in sendFromAddresses! {
                    let importedAddress = _importedAddress as! TLImportedAddress
                    if (changeAddress == nil) {
                        changeAddress = importedAddress.getAddress()
                    }
                    
                    let unspentOutputs = importedAddress.getUnspentArray()
                    for _unspentOutput in unspentOutputs! {
                        let unspentOutput = _unspentOutput as! NSDictionary
                        let amount = (unspentOutput.objectForKey("value") as! NSNumber).unsignedLongLongValue
                        if (amount < DUST_AMOUNT) {
                            dustAmount += amount
                            continue
                        }
                        
                        valueSelected = valueSelected.add(TLCoin(uint64:amount))
                        
                        let outputScript = unspentOutput.objectForKey("script") as! String
                        
                        let address = TLCoreBitcoinWrapper.getAddressFromOutputScript(outputScript, isTestnet: self.appWallet.walletConfig.isTestnet)
                        if (address == nil) {
                            DLog("address cannot be decoded. not normal pubkeyhash outputScript: %@", function: outputScript)
                            continue
                        }
                        assert(address == changeAddress, "! address == changeAddress")
                        
                        inputsData.addObject([
                            "tx_hash": TLWalletUtils.hexStringToData(unspentOutput.objectForKey("tx_hash") as! String)!,
                            "txid": TLWalletUtils.hexStringToData(unspentOutput.objectForKey("tx_hash_big_endian") as! String)!,
                            "tx_output_n": unspentOutput.objectForKey("tx_output_n")!,
                            "script": TLWalletUtils.hexStringToData(outputScript)!,
                            "private_key": importedAddress.getPrivateKey()!])
                        
                        if (valueSelected.greaterOrEqual(valueNeeded)) {
                            break
                        }
                    }
                }
            }
            if (valueSelected.less(valueNeeded)) {
                changeAddress = nil
                if sendFromAccounts != nil {
                    
                    for _accountObject in sendFromAccounts! {
                        let accountObject = _accountObject as! TLAccountObject
                        if (changeAddress == nil) {
                            changeAddress = accountObject.getCurrentChangeAddress()
                        }
                        
                        // move some stealth payments to HD wallet as soon as possible
                        var stealthPaymentUnspentOutputs = NSArray()
                        if accountObject.stealthWallet != nil {
                            stealthPaymentUnspentOutputs = accountObject.getStealthPaymentUnspentOutputsArray()
                        }
                        
                        var unspentOutputsUsingCount = 0
                        for _unspentOutput in stealthPaymentUnspentOutputs {
                            let unspentOutput = _unspentOutput as! NSDictionary
                            let amount = (unspentOutput.objectForKey("value") as! NSNumber).unsignedLongLongValue
                            if (amount < DUST_AMOUNT) {
                                // if commented out, app will try to spend dust inputs
                                dustAmount += amount
                                continue
                            }
                            
                            valueSelected = valueSelected.add(TLCoin(uint64:amount))
                            let outputScript = unspentOutput.objectForKey("script") as! String
                            DLog("createSignedSerializedTransactionHex outputScript: %@", function: outputScript)
                            
                            let address = TLCoreBitcoinWrapper.getAddressFromOutputScript(outputScript, isTestnet: self.appWallet.walletConfig.isTestnet)
                            if (address == nil) {
                                DLog("address cannot be decoded. not normal pubkeyhash outputScript: %@", function: outputScript)
                                continue
                            }
                            
                            inputsData.addObject([
                                "tx_hash": TLWalletUtils.hexStringToData(unspentOutput.objectForKey("tx_hash") as! String)!,
                                "txid": TLWalletUtils.hexStringToData(unspentOutput.objectForKey("tx_hash_big_endian") as! String)!,
                                "tx_output_n": unspentOutput.objectForKey("tx_output_n")!,
                                "script": TLWalletUtils.hexStringToData(outputScript)!,
                                "private_key": accountObject.stealthWallet!.getPaymentAddressPrivateKey(address!)!])
                            
                            let txid = unspentOutput.objectForKey("tx_hash_big_endian") as! String

                            unspentOutputsUsingCount++
                            if (valueSelected.greaterOrEqual(valueNeeded) && unspentOutputsUsingCount > 12) {
                                // limit amount of stealth payment unspent outputs to use
                                break
                            }
                        }
                        
                        if (valueSelected.greaterOrEqual(valueNeeded)) {
                            break
                        }
                        
                        let unspentOutputs = accountObject.getUnspentArray()
                        for _unspentOutput in unspentOutputs {
                            let unspentOutput = _unspentOutput as! NSDictionary
                            let amount = (unspentOutput.objectForKey("value") as! NSNumber).unsignedLongLongValue
                            if (amount < DUST_AMOUNT) {
                                // if commented out, app will try to spend dust inputs
                                dustAmount += amount
                                continue
                            }
                            
                            valueSelected = valueSelected.add(TLCoin(uint64:amount))
                            
                            let outputScript = unspentOutput.objectForKey("script") as! String
                            DLog("createSignedSerializedTransactionHex outputScript: %@", function: outputScript)
                            
                            let address = TLCoreBitcoinWrapper.getAddressFromOutputScript(outputScript, isTestnet: self.appWallet.walletConfig.isTestnet)
                            if (address == nil) {
                                DLog("address cannot be decoded. not normal pubkeyhash outputScript: %@", function: outputScript)
                                continue
                            }
                            
                            inputsData.addObject([
                                "tx_hash": TLWalletUtils.hexStringToData(unspentOutput.objectForKey("tx_hash") as! String)!,
                                "txid": TLWalletUtils.hexStringToData(unspentOutput.objectForKey("tx_hash_big_endian") as! String)!,
                                "tx_output_n": unspentOutput.objectForKey("tx_output_n")!,
                                "script": TLWalletUtils.hexStringToData(outputScript)!,
                                "private_key": accountObject.getAccountPrivateKey(address!)!])
                            
                            if (valueSelected.greaterOrEqual(valueNeeded)) {
                                break
                            }
                        }
                    }
                }
            }
            
            DLog("createSignedSerializedTransactionHex valueSelected %@", function: valueSelected.toString())
            DLog("createSignedSerializedTransactionHex valueNeeded %@", function: valueNeeded.toString())
            var realToAddresses = [String]()
            if (valueSelected.less(valueNeeded)) {
                if (dustAmount > 0) {
                    let dustCoinAmount = TLCoin(uint64:dustAmount)
                    DLog("createSignedSerializedTransactionHex dustAmount %llu", function: Int(dustAmount))
                    DLog("createSignedSerializedTransactionHex dustCoinAmount %@", function: dustCoinAmount.toString())
                    DLog("createSignedSerializedTransactionHex valueNeeded %@", function: valueNeeded.toString())
                    let amountCanSendString = TLWalletUtils.coinToProperBitcoinAmountString(valueNeeded.subtract(dustCoinAmount))
                    error(String(format: "Insufficient Funds. Account contains bitcoin dust. You can only send up to %@ %@ for now.".localized, amountCanSendString, TLWalletUtils.getBitcoinDisplay()))
                    return (nil, realToAddresses)
                }
                let valueSelectedString = TLWalletUtils.coinToProperBitcoinAmountString(valueSelected)
                let valueNeededString = TLWalletUtils.coinToProperBitcoinAmountString(valueNeeded)
                error(String(format: "Insufficient Funds. Account balance is %@ %@ when %@ %@ is required.".localized, valueSelectedString, TLWalletUtils.getBitcoinDisplay(), valueNeededString, TLWalletUtils.getBitcoinDisplay()))
                return (nil, realToAddresses)
            }
            
            var stealthOutputScripts:NSMutableArray? = nil
            for (var i = 0; i < toAddressesAndAmounts.count; i++) {
                let toAddress = toAddressesAndAmounts.objectAtIndex(i).objectForKey("address") as! String
                let amount = toAddressesAndAmounts.objectAtIndex(i).objectForKey("amount") as! TLCoin!
                
                if (!TLStealthAddress.isStealthAddress(toAddress, isTestnet:self.appWallet.walletConfig.isTestnet)) {
                    realToAddresses.append(toAddress)
                    
                    outputsData.addObject([
                        "to_address":toAddress,
                        "amount": NSNumber (unsignedLongLong: amount!.toUInt64())])
                    
                } else {
                    if (stealthOutputScripts == nil) {
                        stealthOutputScripts = NSMutableArray(capacity:1)
                    }
                    
                    let ephemeralPrivateKey = ephemeralPrivateKeyHex != nil ? ephemeralPrivateKeyHex! : TLStealthAddress.generateEphemeralPrivkey()
                    let stealthDataScriptNonce = nonce != nil ? nonce! : TLStealthAddress.generateNonce()
                    let stealthDataScriptAndPaymentAddress = TLStealthAddress.createDataScriptAndPaymentAddress(toAddress,
                        ephemeralPrivateKey: ephemeralPrivateKey, nonce: stealthDataScriptNonce, isTestnet: self.appWallet.walletConfig.isTestnet)
                    
                    DLog("createSignedSerializedTransactionHex stealthDataScript: %@", function: stealthDataScriptAndPaymentAddress.0)
                    DLog("createSignedSerializedTransactionHex paymentAddress: %@", function: stealthDataScriptAndPaymentAddress.1)
                    stealthOutputScripts!.addObject(stealthDataScriptAndPaymentAddress.0)
                    let paymentAddress = stealthDataScriptAndPaymentAddress.1
                    realToAddresses.append(paymentAddress)
                    outputsData.addObject([
                        "to_address":paymentAddress,
                        "amount": NSNumber (unsignedLongLong: amount!.toUInt64())])
                }
            }
            
            var changeAmount = TLCoin.zero()
            if (valueSelected.greater(valueNeeded)) {
                if (changeAddress != nil) {
                    changeAmount = valueSelected.subtract(valueNeeded)
                    outputsData.addObject([
                        "to_address":changeAddress!,
                        "amount": NSNumber(unsignedLongLong: changeAmount.toUInt64())])
                }
            }
            
            DLog("createSignedSerializedTransactionHex changeAmount : %@", function: changeAmount.toString())
            DLog("createSignedSerializedTransactionHex feeAmount: %@", function: feeAmount.toString())
            DLog("createSignedSerializedTransactionHex valueSelected: %@", function: valueSelected.toString())
            DLog("createSignedSerializedTransactionHex valueNeeded: %@", function: valueNeeded.toString())
            
            if valueNeeded.greater(valueSelected) {
                NSException(name:"Send Error", reason:"not enough unspent outputs", userInfo:nil).raise()
            }
            
            for outputData in outputsData {
                let outputAmount = ((outputData as! NSDictionary).objectForKey("amount") as! NSNumber).unsignedLongLongValue
                if outputAmount <= DUST_AMOUNT {
                    let dustAmountBitcoins = TLCoin(uint64: DUST_AMOUNT).bigIntegerToBitcoinAmountString(TLBitcoinDenomination.Bitcoin)
                    error(String(format: "Cannot create transactions with outputs less then %@ bitcoins.".localized, dustAmountBitcoins))
                    return (nil, realToAddresses)
                }
            }
            
            let sortedInputs = inputsData.sortedArrayUsingComparator {
                (obj1, obj2) -> NSComparisonResult in
                
                let firstTxid = (obj1 as! NSDictionary).objectForKey("txid") as! NSData
                let secondTxid = (obj2 as! NSDictionary).objectForKey("txid") as! NSData
                
                let firstTxBytes = UnsafePointer<UInt8>(firstTxid.bytes)
                let secondTxBytes = UnsafePointer<UInt8>(secondTxid.bytes)
                
                for (var i = 0; i < firstTxid.length; i++) {
                    if firstTxBytes[i] < secondTxBytes[i] {
                        return NSComparisonResult.OrderedAscending
                    } else if firstTxBytes[i] > secondTxBytes[i] {
                        return NSComparisonResult.OrderedDescending
                    }
                }
                
                let firstTxOutputN = (obj1 as! NSDictionary).objectForKey("tx_output_n") as! NSNumber
                let secondTxOutputN = (obj2 as! NSDictionary).objectForKey("tx_output_n") as! NSNumber

                if firstTxOutputN.unsignedLongLongValue < secondTxOutputN.unsignedLongLongValue {
                    return NSComparisonResult.OrderedAscending
                } else if firstTxOutputN.unsignedLongLongValue > secondTxOutputN.unsignedLongLongValue {
                    return NSComparisonResult.OrderedDescending
                }

                return NSComparisonResult.OrderedSame
            }
            
            let hashes = NSMutableArray()
            let inputIndexes = NSMutableArray()
            let inputScripts = NSMutableArray()
            let privateKeys = NSMutableArray()
            for _sortedInput in sortedInputs {
                let sortedInput = _sortedInput as! NSDictionary
                hashes.addObject(sortedInput.objectForKey("tx_hash")!)
                inputIndexes.addObject(sortedInput.objectForKey("tx_output_n")!)
                privateKeys.addObject(sortedInput.objectForKey("private_key")!)
                inputScripts.addObject(sortedInput.objectForKey("script")!)
            }
            let sortedOutputs = outputsData.sortedArrayUsingComparator {
                (obj1, obj2) -> NSComparisonResult in
                
                let firstAmount = (obj1 as! NSDictionary).objectForKey("amount") as! NSNumber
                let secondAmount = (obj2 as! NSDictionary).objectForKey("amount") as! NSNumber
                
                if firstAmount.unsignedLongLongValue < secondAmount.unsignedLongLongValue {
                    return NSComparisonResult.OrderedAscending
                } else if firstAmount.unsignedLongLongValue > secondAmount.unsignedLongLongValue {
                    return NSComparisonResult.OrderedDescending
                } else {
                    let firstAddress = (obj1 as! NSDictionary).objectForKey("to_address") as! String
                    let secondAddress = (obj2 as! NSDictionary).objectForKey("to_address") as! String
                    
                    let firstScript = TLCoreBitcoinWrapper.getStandardPubKeyHashScriptFromAddress(firstAddress, isTestnet: self.appWallet.walletConfig.isTestnet)
                    let secondScript = TLCoreBitcoinWrapper.getStandardPubKeyHashScriptFromAddress(secondAddress, isTestnet: self.appWallet.walletConfig.isTestnet)
                    
                    let firstScriptData = TLWalletUtils.hexStringToData(firstScript)!
                    let secondScriptData = TLWalletUtils.hexStringToData(secondScript)!
                    
                    let firstScriptBytes = UnsafePointer<UInt8>(firstScriptData.bytes)
                    let secondScriptBytes = UnsafePointer<UInt8>(secondScriptData.bytes)

                    for (var i = 0; i < firstScript.characters.count/2; i++) {
                        if firstScriptBytes[i] < secondScriptBytes[i] {
                            return NSComparisonResult.OrderedAscending
                        } else if firstScriptBytes[i] > secondScriptBytes[i] {
                            return NSComparisonResult.OrderedDescending
                        }
                    }
                    
                    return NSComparisonResult.OrderedSame
                }
            }
            
            let outputAmounts = NSMutableArray()
            let outputAddresses = NSMutableArray()
            for _sortedOutput in sortedOutputs {
                let sortedOutput = _sortedOutput as! NSDictionary
                outputAddresses.addObject(sortedOutput.objectForKey("to_address")!)
                outputAmounts.addObject(sortedOutput.objectForKey("amount")!)
            }
            
            
            DLog("createSignedSerializedTransactionHex hashes: %@", function: hashes.debugDescription)
            DLog("createSignedSerializedTransactionHex inputIndexes: %@", function: inputIndexes.debugDescription)
            DLog("createSignedSerializedTransactionHex inputScripts: %@", function: inputScripts.debugDescription)
            DLog("createSignedSerializedTransactionHex outputAddresses: %@", function: outputAddresses.debugDescription)
            DLog("createSignedSerializedTransactionHex outputAmounts: %@", function: outputAmounts.debugDescription)
            DLog("createSignedSerializedTransactionHex privateKeys: %@", function: privateKeys.debugDescription)
            for _ in 0...3 {
                let txHexAndTxHash = TLCoreBitcoinWrapper.createSignedSerializedTransactionHex(hashes, inputIndexes:inputIndexes, inputScripts:inputScripts,
                    outputAddresses:outputAddresses, outputAmounts:outputAmounts, privateKeys:privateKeys,
                    outputScripts:stealthOutputScripts, isTestnet: self.appWallet.walletConfig.isTestnet)
                DLog("createSignedSerializedTransactionHex txHexAndTxHash: %@", function: txHexAndTxHash.debugDescription)
                if txHexAndTxHash != nil {
                    return (txHexAndTxHash!, realToAddresses)
                }
            }
            
            error("Encountered error creating transaction. Please try again.".localized)
            return (nil, realToAddresses)
    }
}


