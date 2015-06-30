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
    
    private var sendFromAccounts:NSMutableArray?
    private var sendFromAddresses:NSMutableArray?
    
    struct STATIC_MEMBERS {
        static var instance:TLSpaghettiGodSend?
    }
    
    class func instance() -> (TLSpaghettiGodSend) {
        
        if(STATIC_MEMBERS.instance == nil)
        {
            STATIC_MEMBERS.instance = TLSpaghettiGodSend()
        }
        return STATIC_MEMBERS.instance!
    }
    
    override init() {
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
                        
                        let address = TLCoreBitcoinWrapper.getAddressFromOutputScript(outputScript)
                        if (address == nil) {
                            DLog("address cannot be decoded. not normal pubkeyhash outputScript: %@", outputScript)
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
                        let idx = find(addresses, address)
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
        feeAmount:TLCoin, error:TLWalletUtils.ErrorWithString) -> (NSDictionary?, Array<String>, Array<String>) {
            let hashes = NSMutableArray()
            let inputIndexes = NSMutableArray()
            let inputScripts = NSMutableArray()
            let privateKeys = NSMutableArray()
            let outputAmounts = NSMutableArray()
            let outputAddresses = NSMutableArray()
            var stealthPaymentTxidsClaiming = [String]()
            var outputValueSum = TLCoin.zero()
            var realToAddresses = [String]()

            for _toAddressAndAmount in toAddressesAndAmounts {
                var amount = (_toAddressAndAmount as! NSDictionary).objectForKey("amount") as! TLCoin
                outputValueSum = outputValueSum.add(amount)
            }
            var valueNeeded = outputValueSum.add(feeAmount)
            
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
                        
                        hashes.addObject(TLWalletUtils.hexStringToData(unspentOutput.objectForKey("tx_hash") as! String)!)
                        inputIndexes.addObject(unspentOutput.objectForKey("tx_output_n")!)
                        let outputScript = unspentOutput.objectForKey("script") as! String
                        inputScripts.addObject(TLWalletUtils.hexStringToData(outputScript)!)
                        
                        let address = TLCoreBitcoinWrapper.getAddressFromOutputScript(outputScript)
                        if (address == nil) {
                            DLog("address cannot be decoded. not normal pubkeyhash outputScript: %@", outputScript)
                            continue
                        }
                        assert(address == changeAddress, "! address == changeAddress")
                        let privateKey = importedAddress.getPrivateKey()
                        
                        privateKeys.addObject(privateKey!)
                        
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
                            hashes.addObject(TLWalletUtils.hexStringToData(unspentOutput.objectForKey("tx_hash") as! String)!)
                            inputIndexes.addObject(unspentOutput.objectForKey("tx_output_n")!)
                            let outputScript = unspentOutput.objectForKey("script") as! String
                            inputScripts.addObject(TLWalletUtils.hexStringToData(outputScript)!)
                            DLog("createSignedSerializedTransactionHex outputScript: %@", outputScript)
                            
                            let address = TLCoreBitcoinWrapper.getAddressFromOutputScript(outputScript)
                            if (address == nil) {
                                DLog("address cannot be decoded. not normal pubkeyhash outputScript: %@", outputScript)
                                continue
                            }

                            privateKeys.addObject(accountObject.stealthWallet!.getPaymentAddressPrivateKey(address!)!)
                            
                            let txid = unspentOutput.objectForKey("tx_hash_big_endian") as! String
                            stealthPaymentTxidsClaiming.append(txid)

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
                            
                            hashes.addObject(TLWalletUtils.hexStringToData(unspentOutput.objectForKey("tx_hash") as! String)!)
                            inputIndexes.addObject(unspentOutput.objectForKey("tx_output_n")!)
                            let outputScript = unspentOutput.objectForKey("script") as! String
                            inputScripts.addObject(TLWalletUtils.hexStringToData(outputScript)!)
                            DLog("createSignedSerializedTransactionHex outputScript: %@", outputScript)
                            
                            let address = TLCoreBitcoinWrapper.getAddressFromOutputScript(outputScript)
                            if (address == nil) {
                                DLog("address cannot be decoded. not normal pubkeyhash outputScript: %@", outputScript)
                                continue
                            }
                            
                            privateKeys.addObject(accountObject.getAccountPrivateKey(address!)!)
                            
                            if (valueSelected.greaterOrEqual(valueNeeded)) {
                                break
                            }
                        }
                    }
                }
            }
            
            DLog("createSignedSerializedTransactionHex valueSelected %@", valueSelected.toString())
            DLog("createSignedSerializedTransactionHex valueNeeded %@", valueNeeded.toString())

            if (valueSelected.less(valueNeeded)) {
                if (dustAmount > 0) {
                    let dustCoinAmount = TLCoin(uint64:dustAmount)
                    DLog("createSignedSerializedTransactionHex dustAmount %llu", Int(dustAmount))
                    DLog("createSignedSerializedTransactionHex dustCoinAmount %@", dustCoinAmount.toString())
                    DLog("createSignedSerializedTransactionHex valueNeeded %@", valueNeeded.toString())
                    let amountCanSendString = TLWalletUtils.coinToProperBitcoinAmountString(valueNeeded.subtract(dustCoinAmount))
                    error(String(format: "Insufficient Funds. Account contains bitcoin dust. You can only send up to %@ %@ for now.", amountCanSendString, TLWalletUtils.getBitcoinDisplay()))
                    return (nil, stealthPaymentTxidsClaiming, realToAddresses)
                }
                let valueSelectedString = TLWalletUtils.coinToProperBitcoinAmountString(valueSelected)
                let valueNeededString = TLWalletUtils.coinToProperBitcoinAmountString(valueNeeded)
                error("Insufficient Funds. Account balance is \(valueSelectedString) \(TLWalletUtils.getBitcoinDisplay()) when \(valueNeededString) \(TLWalletUtils.getBitcoinDisplay()) is required.")
                return (nil, stealthPaymentTxidsClaiming, realToAddresses)
            }
            
            var stealthOutputScripts:NSMutableArray? = nil
            for (var i = 0; i < toAddressesAndAmounts.count; i++) {
                let toAddress = toAddressesAndAmounts.objectAtIndex(i).objectForKey("address") as! String
                let amount = toAddressesAndAmounts.objectAtIndex(i).objectForKey("amount") as! TLCoin!
                
                if (!TLStealthAddress.isStealthAddress(toAddress, isTestnet:TLWalletUtils.STATIC_MEMBERS.IS_TESTNET)) {
                    realToAddresses.append(toAddress)
                    outputAddresses.addObject(toAddress)
                    outputAmounts.addObject((NSNumber (unsignedLongLong: amount!.toUInt64())))
                } else {
                    if (stealthOutputScripts == nil) {
                        stealthOutputScripts = NSMutableArray(capacity:1)
                    }
                    
                    let ephemeralPrivateKey = TLStealthAddress.generateEphemeralPrivkey()
                    let nonce = TLStealthAddress.generateNonce()
                    let stealthDataScriptAndPaymentAddress = TLStealthAddress.createDataScriptAndPaymentAddress(toAddress, ephemeralPrivateKey: ephemeralPrivateKey, nonce: nonce, isTestnet: TLWalletUtils.STATIC_MEMBERS.IS_TESTNET)
                    
                    DLog("createSignedSerializedTransactionHex stealthDataScript: %@", stealthDataScriptAndPaymentAddress.0)
                    DLog("createSignedSerializedTransactionHex paymentAddress: %@", stealthDataScriptAndPaymentAddress.1)
                    stealthOutputScripts!.addObject(stealthDataScriptAndPaymentAddress.0)
                    let paymentAddress = stealthDataScriptAndPaymentAddress.1
                    realToAddresses.append(paymentAddress)
                    outputAddresses.addObject(paymentAddress)
                    outputAmounts.addObject((NSNumber (unsignedLongLong: amount!.toUInt64())))
                }
            }
            
            var changeAmount = TLCoin.zero()
            if (valueSelected.greater(valueNeeded)) {
                if (changeAddress != nil) {
                    changeAmount = valueSelected.subtract(valueNeeded)
                    let changeOutputIndex = Int(arc4random_uniform(UInt32(outputAmounts.count+1)))
                    DLog("randomized changeOutputIndex: \(changeOutputIndex)")
                    outputAmounts.insertObject((NSNumber(unsignedLongLong: changeAmount.toUInt64())), atIndex: changeOutputIndex)
                    outputAddresses.insertObject(changeAddress!, atIndex: changeOutputIndex)
                }
            }
            
            DLog("createSignedSerializedTransactionHex changeAmount : %@", changeAmount.toString())
            DLog("createSignedSerializedTransactionHex feeAmount: %@", feeAmount.toString())
            DLog("createSignedSerializedTransactionHex valueSelected: %@", valueSelected.toString())
            DLog("createSignedSerializedTransactionHex valueNeeded: %@", valueNeeded.toString())
            
            if valueNeeded.greater(valueSelected) {
                NSException(name:"Send Error", reason:"not enough unspent outputs", userInfo:nil).raise()
            }
            
            for _outputAmount in outputAmounts {
                let outputAmount = (_outputAmount as! NSNumber).unsignedLongLongValue
                if outputAmount <= DUST_AMOUNT {
                    let dustAmountBitcoins = TLCoin(uint64: DUST_AMOUNT).bigIntegerToBitcoinAmountString(TLBitcoinDenomination.Bitcoin)
                    error("Cannot create transactions with outputs less then \(dustAmountBitcoins) bitcoins.")
                    return (nil, stealthPaymentTxidsClaiming, realToAddresses)
                }
            }
            
            DLog("createSignedSerializedTransactionHex hashes: %@", hashes.debugDescription)
            DLog("createSignedSerializedTransactionHex inputIndexes: %@", inputIndexes.debugDescription)
            DLog("createSignedSerializedTransactionHex inputScripts: %@", inputScripts.debugDescription)
            DLog("createSignedSerializedTransactionHex outputAddresses: %@", outputAddresses.debugDescription)
            DLog("createSignedSerializedTransactionHex outputAmounts: %@", outputAmounts.debugDescription)
            DLog("createSignedSerializedTransactionHex privateKeys: %@", privateKeys.debugDescription)
            for i in 0...3 {
                let txHexAndTxHash = TLCoreBitcoinWrapper.createSignedSerializedTransactionHex(hashes, inputIndexes:inputIndexes, inputScripts:inputScripts,
                    outputAddresses:outputAddresses, outputAmounts:outputAmounts, privateKeys:privateKeys,
                    outputScripts:stealthOutputScripts)
                DLog("createSignedSerializedTransactionHex txHexAndTxHash: %@", txHexAndTxHash.debugDescription)
                if txHexAndTxHash != nil {
                    return (txHexAndTxHash!, stealthPaymentTxidsClaiming, realToAddresses)
                }
            }
            
            error("Encountered error creating transaction. Please try again.")
            return (nil, stealthPaymentTxidsClaiming, realToAddresses)
    }
}


