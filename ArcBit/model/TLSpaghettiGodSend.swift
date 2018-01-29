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

    fileprivate var appWallet: TLWallet
    fileprivate var sendFromAccounts:NSMutableArray?
    fileprivate var sendFromAddresses:NSMutableArray?

    struct STATIC_MEMBERS {
        static var instance:TLSpaghettiGodSend?
    }
    
    init(appWallet: TLWallet) {
        self.appWallet = appWallet
        sendFromAccounts = NSMutableArray()
        sendFromAddresses = NSMutableArray()
        super.init()
    }
    
    fileprivate func clearFromAccountsAndAddresses() -> () {
        sendFromAccounts = NSMutableArray()
        sendFromAddresses = NSMutableArray()
    }
    
    func getSelectedObjectCoinType() -> TLCoinType {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.object(at: 0) as! TLAccountObject
            return accountObject.coinType
        } else {
            let importedAddress = sendFromAddresses!.object(at: 0) as! TLImportedAddress
            return importedAddress.coinType
        }
    }
    
    func getSelectedSendObject() -> AnyObject? {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            return sendFromAccounts!.object(at: 0) as AnyObject?
        } else if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            return sendFromAddresses!.object(at: 0) as AnyObject?
        }
        
        return nil
    }
    
    func getSelectedObjectType() -> (TLSelectObjectType) {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            return TLSelectObjectType.account
        } else if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            return TLSelectObjectType.address
        }
        
        return TLSelectObjectType.unknown
    }
    
    
    func isPaymentToOwnAccount(_ address: String) -> Bool {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.object(at: 0) as! TLAccountObject
            if accountObject.isAddressPartOfAccount(address) {
                return true
            }
            return false
        } else if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            let importedAddress = sendFromAddresses!.object(at: 0) as! TLImportedAddress
            if address == importedAddress.getAddress() {
                return true
            }
            return false
        }
        return false
    }
    
    func haveUpDatedUTXOs() -> Bool {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.object(at: 0) as! TLAccountObject
            return accountObject.haveUpDatedUTXOs
        } else if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            let importedAddress = sendFromAddresses!.object(at: 0) as! TLImportedAddress
            return importedAddress.haveUpDatedUTXOs
        }
        return false
    }
    
    fileprivate func getLabelForSelectedSendObject() -> String? {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.object(at: 0) as! TLAccountObject
            return accountObject.getAccountName()
        } else if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            let importedAddress = sendFromAddresses!.object(at: 0) as! TLImportedAddress
            return importedAddress.getLabel()
        }
        return nil
    }
    
    func getCurrentFromLabel() -> String? {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.object(at: 0) as! TLAccountObject
            return accountObject.getAccountName()
        } else if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            let importedAddress = sendFromAddresses!.object(at: 0) as! TLImportedAddress
            return importedAddress.getLabel()
        }
        
        return nil
    }
    
    func getExtendedPubKey() -> String? {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.object(at: 0) as! TLAccountObject
            return accountObject.getExtendedPubKey()
        }
        return nil
    }
    
    func setOnlyFromAccount(_ accountObject:TLAccountObject) -> () {
        sendFromAddresses = nil
        sendFromAccounts = NSMutableArray(objects:accountObject)
    }
    
    func setOnlyFromAddress(_ importedAddress:TLImportedAddress) -> () {
        sendFromAccounts = nil
        sendFromAddresses = NSMutableArray(objects:importedAddress)
    }
    
    fileprivate func  addSendAccount(_ accountObject: TLAccountObject) -> () {
        sendFromAccounts!.add(accountObject)
    }
    
    fileprivate func addImportedAddress(_ importedAddress:TLImportedAddress) -> () {
        sendFromAddresses!.add(importedAddress)
    }

    func isColdWalletAccount() -> (Bool) {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.object(at: 0) as! TLAccountObject
            return accountObject.isColdWalletAccount()
        }
        return false
    }
    
    func needWatchOnlyAccountPrivateKey() -> (Bool) {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.object(at: 0) as! TLAccountObject
            return accountObject.isWatchOnly() && !accountObject.hasSetExtendedPrivateKeyInMemory()
        }
        return false
    }
    
    func needWatchOnlyAddressPrivateKey() -> (Bool) {
        if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            let importedAddress = sendFromAddresses!.object(at: 0) as! TLImportedAddress
            return importedAddress.isWatchOnly() && !importedAddress.hasSetPrivateKeyInMemory()
        }
        return false
    }
    
    func needEncryptedPrivateKeyPassword() -> Bool {
        if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            let importedAddress = sendFromAddresses!.object(at: 0) as! TLImportedAddress
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
        let importedAddress = sendFromAddresses!.object(at: 0) as! TLImportedAddress
        assert(importedAddress.isPrivateKeyEncrypted() != false, "! importedAddress isPrivateKeyEncrypted]")
        return importedAddress.getEncryptedPrivateKey()!
    }
    
    func hasFetchedCurrentFromData() -> (Bool) {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.object(at: 0) as! TLAccountObject
            return accountObject.hasFetchedAccountData()
        } else if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            let importedAddress = sendFromAddresses!.object(at: 0) as! TLImportedAddress
            return importedAddress.hasFetchedAccountData()
        }
        return true
    }

    func setCurrentFromBalance(_ balance: TLCoin) {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.object(at: 0) as! TLAccountObject
            accountObject.accountBalance = balance
        } else if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            let importedAddress = sendFromAddresses!.object(at: 0) as! TLImportedAddress
            importedAddress.balance = balance
        }
    }
    
    func getCurrentFromBalance() -> (TLCoin) {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.object(at: 0) as! TLAccountObject
            return accountObject.getBalance()
        } else if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            let importedAddress = sendFromAddresses!.object(at: 0) as! TLImportedAddress
            return importedAddress.getBalance()!
        }
        return TLCoin.zero()
    }
    
    func getCurrentFromUnspentOutputsSum() -> (TLCoin) {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject = sendFromAccounts!.object(at: 0) as! TLAccountObject
            return accountObject.getTotalUnspentSum()
        } else if (sendFromAddresses != nil && sendFromAddresses!.count != 0) {
            let importedAddress = sendFromAddresses!.object(at: 0) as! TLImportedAddress
            return importedAddress.getUnspentSum()!
        }
        return TLCoin.zero()
    }
    
    func getAndSetUnspentOutputs(_ success:@escaping TLWalletUtils.Success, failure:@escaping TLWalletUtils.Error) -> () {
        if (sendFromAccounts != nil && sendFromAccounts!.count != 0) {
            let accountObject  = sendFromAccounts!.object(at: 0) as! TLAccountObject
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
            let importedAddress = sendFromAddresses!.object(at: 0) as! TLImportedAddress
            let amount = importedAddress.getBalance()
            if (amount!.greater(TLCoin.zero())) {
                addresses.append(importedAddress.getAddress())
            }
            
            if (addresses.count > 0) {
                importedAddress.haveUpDatedUTXOs = false
                TLBlockExplorerAPI.instance().getUnspentOutputs(self.getSelectedObjectCoinType(), addressArray: addresses, success:{(unspentOutputsObject) in
                    var address2UnspentOutputs = Dictionary<String, Array<TLUnspentOutputObject>>(minimumCapacity:addresses.count)
                    
                    for unspentOutput in unspentOutputsObject.unspentOutputs {
                        let outputScript = unspentOutput.script
                        
                        guard let address = TLCoreBitcoinWrapper.getAddressFromOutputScript(self.getSelectedObjectCoinType(), scriptHex: outputScript, isTestnet: self.appWallet.walletConfig.isTestnet) else {
                            DLog("address cannot be decoded. not normal pubkeyhash outputScript: \(outputScript)")
                            continue
                        }
                        
                        var cachedUnspentOutputs:Array<TLUnspentOutputObject>? = address2UnspentOutputs[address]
                        if (cachedUnspentOutputs == nil) {
                            cachedUnspentOutputs = Array<TLUnspentOutputObject>()
                            address2UnspentOutputs[address] = cachedUnspentOutputs
                        }
                        cachedUnspentOutputs!.append(unspentOutput)
                    }
                    
                    for _address in address2UnspentOutputs {
                        let address = _address.key as! String
                        let idx = addresses.index(of: address)
                        let importedAddress = self.sendFromAddresses!.object(at: idx!) as! TLImportedAddress
                        if let unspentOutputsArray = address2UnspentOutputs[address] {
                            importedAddress.unspentOutputsCount = unspentOutputsArray.count
                            importedAddress.setUnspentOutputs(unspentOutputsArray)
                            importedAddress.haveUpDatedUTXOs = true
                        }
                    }
                    
                    success()
                    }, failure:{(code, status) in
                        failure()
                    }
                )
            }
        }
    }
    
    class func getEstimatedTxSize(_ inputCount: Int, outputCount: Int) -> UInt64 {
        return UInt64(10 + 159*inputCount + 34*outputCount)
    }
        
    func createSignedSerializedTransactionHex(_ toAddressesAndAmounts:NSArray,
                                              feeAmount:TLCoin, signTx: Bool = true, nonce: UInt32? = nil, ephemeralPrivateKeyHex: String? = nil, error:TLWalletUtils.ErrorWithString) -> (NSDictionary?, Array<String>, NSArray?) {
            let inputsData = NSMutableArray()
            let outputsData = NSMutableArray()
            var outputValueSum = TLCoin.zero()

            for _toAddressAndAmount in toAddressesAndAmounts {
                let amount = (_toAddressAndAmount as! NSDictionary).object(forKey: "amount") as! TLCoin
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
                        changeAddress = importedAddress.getAddress() as NSString?
                    }
                    
                    let unspentOutputs = importedAddress.getUnspentArray()
                    for unspentOutput in unspentOutputs {
                        let amount = unspentOutput.value
                        if (amount < DUST_AMOUNT) {
                            dustAmount += amount
                            continue
                        }
                        
                        valueSelected = valueSelected.add(TLCoin(uint64:amount))
                        
                        let outputScript = unspentOutput.script
                        
                        let address = TLCoreBitcoinWrapper.getAddressFromOutputScript(self.getSelectedObjectCoinType(), scriptHex: outputScript, isTestnet: self.appWallet.walletConfig.isTestnet)
                        if (address == nil) {
                            DLog("address cannot be decoded. not normal pubkeyhash outputScript: \(outputScript)")
                            continue
                        }
                        assert(address == changeAddress as? String, "! address == changeAddress")
                        
                        if signTx {
                            inputsData.add([
                                "tx_hash": TLWalletUtils.hexStringToData(unspentOutput.txHash)!,
                                "txid": TLWalletUtils.hexStringToData(unspentOutput.txHashBigEndian)!,
                                "tx_output_n": unspentOutput.txOutputN,
                                "script": TLWalletUtils.hexStringToData(outputScript)!,
                                "private_key": importedAddress.getPrivateKey()!])
                        } else {
                            inputsData.add([
                                "tx_hash": TLWalletUtils.hexStringToData(unspentOutput.txHash)!,
                                "txid": TLWalletUtils.hexStringToData(unspentOutput.txHashBigEndian)!,
                                "tx_output_n": unspentOutput.txOutputN,
                                "script": TLWalletUtils.hexStringToData(outputScript)!])
                        }
                        
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
                            changeAddress = accountObject.getCurrentChangeAddress() as NSString?
                        }
    
                        let unspentOutputs = accountObject.getUnspentArray()
                        for unspentOutput in unspentOutputs {
                            if (unspentOutput.value < DUST_AMOUNT) {
                                // if commented out, app will try to spend dust inputs
                                dustAmount += unspentOutput.value
                                continue
                            }
                            
                            valueSelected = valueSelected.add(TLCoin(uint64:unspentOutput.value))
                            
                            let outputScript = unspentOutput.script
                            DLog("createSignedSerializedTransactionHex outputScript: \(outputScript)")
                            
                            let address = TLCoreBitcoinWrapper.getAddressFromOutputScript(self.getSelectedObjectCoinType(), scriptHex: outputScript, isTestnet: self.appWallet.walletConfig.isTestnet)
                            if (address == nil) {
                                DLog("address cannot be decoded. not normal pubkeyhash outputScript: \(outputScript)")
                                continue
                            }
                            
                            if signTx {
                                inputsData.add([
                                    "tx_hash": TLWalletUtils.hexStringToData(unspentOutput.txHash)!,
                                    "txid": TLWalletUtils.hexStringToData(unspentOutput.txHashBigEndian)!,
                                    "tx_output_n": unspentOutput.txOutputN,
                                    "script": TLWalletUtils.hexStringToData(outputScript)!,
                                    "private_key": accountObject.getAccountPrivateKey(address!)!
                                    ])
                            } else {
                                inputsData.add([
                                    "tx_hash": TLWalletUtils.hexStringToData(unspentOutput.txHash)!,
                                    "txid": TLWalletUtils.hexStringToData(unspentOutput.txHashBigEndian)!,
                                    "tx_output_n": unspentOutput.txOutputN,
                                    "script": TLWalletUtils.hexStringToData(outputScript)!,
                                    "hd_account_info": ["idx": accountObject.getAddressHDIndex(address!), "is_change": !accountObject.isMainAddress(address!)]
                                    ])
                            }
                            
                            if (valueSelected.greaterOrEqual(valueNeeded)) {
                                break
                            }
                        }
                    }
                }
            }
            
            DLog("createSignedSerializedTransactionHex valueSelected \(valueSelected.toString())")
            DLog("createSignedSerializedTransactionHex valueNeeded \(valueNeeded.toString())")
            var realToAddresses = [String]()
            if (valueSelected.less(valueNeeded)) {
                if (dustAmount > 0) {
                    let dustCoinAmount = TLCoin(uint64:dustAmount)
                    DLog("createSignedSerializedTransactionHex dustAmount \(Int(dustAmount))")
                    DLog("createSignedSerializedTransactionHex dustCoinAmount \(dustCoinAmount.toString())")
                    DLog("createSignedSerializedTransactionHex valueNeeded \(valueNeeded.toString())")
                    let amountCanSendString = TLCurrencyFormat.coinToProperBitcoinAmountString(valueNeeded.subtract(dustCoinAmount), coinType: self.getSelectedObjectCoinType())
                    error(String(format: TLDisplayStrings.INSUFFICIENT_FUNDS_ACCOUNT_CONTAINS_BITCOIN_DUST_STRING(), "\(amountCanSendString) \(TLCurrencyFormat.getBitcoinDisplay(self.getSelectedObjectCoinType()))"))
                    return (nil, realToAddresses, nil)
                }
                let valueSelectedString = TLCurrencyFormat.coinToProperBitcoinAmountString(valueSelected, coinType: self.getSelectedObjectCoinType())
                let valueNeededString = TLCurrencyFormat.coinToProperBitcoinAmountString(valueNeeded, coinType: self.getSelectedObjectCoinType())
                error(String(format: TLDisplayStrings.INSUFFICIENT_FUNDS_ACCOUNT_BALANCE_IS_STRING(), "\(valueSelectedString) \(TLCurrencyFormat.getBitcoinDisplay(self.getSelectedObjectCoinType()))", "\(valueNeededString) \(TLCurrencyFormat.getBitcoinDisplay(self.getSelectedObjectCoinType()))"))
                return (nil, realToAddresses, nil)
            }
            
            var stealthOutputScripts:NSMutableArray? = nil
            for i in stride(from: 0, to: toAddressesAndAmounts.count, by: 1) {
                let toAddress = (toAddressesAndAmounts.object(at: i) as AnyObject).object(forKey: "address") as! String
                let amount = (toAddressesAndAmounts.object(at: i) as AnyObject).object(forKey: "amount") as! TLCoin!
                
                if (!TLStealthAddress.isStealthAddress(toAddress, isTestnet:self.appWallet.walletConfig.isTestnet)) {
                    realToAddresses.append(toAddress)
                    
                    outputsData.add([
                        "to_address":toAddress,
                        "amount": NSNumber (value: amount!.toUInt64() as UInt64)])
                    
                } else {
                    if (stealthOutputScripts == nil) {
                        stealthOutputScripts = NSMutableArray(capacity:1)
                    }
                    
                    let ephemeralPrivateKey = ephemeralPrivateKeyHex != nil ? ephemeralPrivateKeyHex! : TLStealthAddress.generateEphemeralPrivkey()
                    let stealthDataScriptNonce = nonce != nil ? nonce! : TLStealthAddress.generateNonce()
                    let stealthDataScriptAndPaymentAddress = TLStealthAddress.createDataScriptAndPaymentAddress(toAddress,
                        ephemeralPrivateKey: ephemeralPrivateKey, nonce: stealthDataScriptNonce, isTestnet: self.appWallet.walletConfig.isTestnet)
                    
                    DLog("createSignedSerializedTransactionHex stealthDataScript: \(stealthDataScriptAndPaymentAddress.0)")
                    DLog("createSignedSerializedTransactionHex paymentAddress: \(stealthDataScriptAndPaymentAddress.1)")
                    stealthOutputScripts!.add(stealthDataScriptAndPaymentAddress.0)
                    let paymentAddress = stealthDataScriptAndPaymentAddress.1
                    realToAddresses.append(paymentAddress)
                    outputsData.add([
                        "to_address":paymentAddress,
                        "amount": NSNumber (value: amount!.toUInt64() as UInt64)])
                }
            }
            
            var changeAmount = TLCoin.zero()
            if (valueSelected.greater(valueNeeded)) {
                if (changeAddress != nil) {
                    changeAmount = valueSelected.subtract(valueNeeded)
                    outputsData.add([
                        "to_address":changeAddress!,
                        "amount": NSNumber(value: changeAmount.toUInt64() as UInt64)])
                }
            }
            
            DLog("createSignedSerializedTransactionHex changeAmount : \(changeAmount.toString())")
            DLog("createSignedSerializedTransactionHex feeAmount: \(feeAmount.toString())")
            DLog("createSignedSerializedTransactionHex valueSelected: \(valueSelected.toString())")
            DLog("createSignedSerializedTransactionHex valueNeeded: \(valueNeeded.toString())")
            
            if valueNeeded.greater(valueSelected) {
                NSException(name:NSExceptionName(rawValue: "Send Error"), reason:"not enough unspent outputs", userInfo:nil).raise()
            }
            
            for outputData in outputsData {
                let outputAmount = ((outputData as! NSDictionary).object(forKey: "amount") as! NSNumber).uint64Value
                if outputAmount <= DUST_AMOUNT {
                    let dustAmountBitcoins = TLCurrencyFormat.coinToProperBitcoinAmountString(TLCoin(uint64: DUST_AMOUNT), coinType: self.getSelectedObjectCoinType(), withCode: true)
                    error(String(format: TLDisplayStrings.CANNOT_CREATE_TRANSACTIONS_WITH_OUTPUTS_LESS_THEN_X_BITCOINS_STRING(), dustAmountBitcoins))
                    return (nil, realToAddresses, nil)
                }
            }
            
            let sortedInputs = inputsData.sortedArray (comparator: {
                (obj1, obj2) -> ComparisonResult in
                
                let firstTxid = (obj1 as! NSDictionary).object(forKey: "txid") as! Data
                let secondTxid = (obj2 as! NSDictionary).object(forKey: "txid") as! Data
                
                let firstTxBytes = (firstTxid as NSData).bytes.bindMemory(to: UInt8.self, capacity: firstTxid.count)
                let secondTxBytes = (secondTxid as NSData).bytes.bindMemory(to: UInt8.self, capacity: secondTxid.count)
                
                for i in stride(from: 0, to: firstTxid.count, by: 1) {
                    if firstTxBytes[i] < secondTxBytes[i] {
                        return ComparisonResult.orderedAscending
                    } else if firstTxBytes[i] > secondTxBytes[i] {
                        return ComparisonResult.orderedDescending
                    }
                }
                
                let firstTxOutputN = (obj1 as! NSDictionary).object(forKey: "tx_output_n") as! NSNumber
                let secondTxOutputN = (obj2 as! NSDictionary).object(forKey: "tx_output_n") as! NSNumber

                if firstTxOutputN.uint64Value < secondTxOutputN.uint64Value {
                    return ComparisonResult.orderedAscending
                } else if firstTxOutputN.uint64Value > secondTxOutputN.uint64Value {
                    return ComparisonResult.orderedDescending
                }

                return ComparisonResult.orderedSame
            })
            
            let hashes = NSMutableArray()
            let inputIndexes = NSMutableArray()
            let inputScripts = NSMutableArray()
            let privateKeys = NSMutableArray()
            let txInputsAccountHDIdxes = NSMutableArray()
            var isInputsAllFromHDAccountAddresses = true //only used for cold wallet accounts, and cant have addresses from other then hd account addresses
            for _sortedInput in sortedInputs {
                let sortedInput = _sortedInput as! NSDictionary
                hashes.add(sortedInput.object(forKey: "tx_hash")!)
                inputIndexes.add(sortedInput.object(forKey: "tx_output_n")!)
                if signTx {
                    privateKeys.add(sortedInput.object(forKey: "private_key")!)
                } else {
                    if let hdAccountInfo = sortedInput.object(forKey: "hd_account_info") {
                        txInputsAccountHDIdxes.add(hdAccountInfo)
                    } else {
                        isInputsAllFromHDAccountAddresses = false
                    }
                }
                inputScripts.add(sortedInput.object(forKey: "script")!)
            }
            let sortedOutputs = outputsData.sortedArray (comparator: {
                (obj1, obj2) -> ComparisonResult in
                
                let firstAmount = (obj1 as! NSDictionary).object(forKey: "amount") as! NSNumber
                let secondAmount = (obj2 as! NSDictionary).object(forKey: "amount") as! NSNumber
                
                if firstAmount.uint64Value < secondAmount.uint64Value {
                    return ComparisonResult.orderedAscending
                } else if firstAmount.uint64Value > secondAmount.uint64Value {
                    return ComparisonResult.orderedDescending
                } else {
                    let firstAddress = (obj1 as! NSDictionary).object(forKey: "to_address") as! String
                    let secondAddress = (obj2 as! NSDictionary).object(forKey: "to_address") as! String
                    
                    let firstScript = TLCoreBitcoinWrapper.getStandardPubKeyHashScriptFromAddress(self.getSelectedObjectCoinType(), address: firstAddress, isTestnet: self.appWallet.walletConfig.isTestnet)
                    let secondScript = TLCoreBitcoinWrapper.getStandardPubKeyHashScriptFromAddress(self.getSelectedObjectCoinType(), address: secondAddress, isTestnet: self.appWallet.walletConfig.isTestnet)
                    
                    let firstScriptData = TLWalletUtils.hexStringToData(firstScript)!
                    let secondScriptData = TLWalletUtils.hexStringToData(secondScript)!
                    
                    let firstScriptBytes = (firstScriptData as NSData).bytes.bindMemory(to: UInt8.self, capacity: firstScriptData.count)
                    let secondScriptBytes = (secondScriptData as NSData).bytes.bindMemory(to: UInt8.self, capacity: secondScriptData.count)

                    for i in stride(from: 0, to: firstScript.characters.count/2, by: 1) {
                        if firstScriptBytes[i] < secondScriptBytes[i] {
                            return ComparisonResult.orderedAscending
                        } else if firstScriptBytes[i] > secondScriptBytes[i] {
                            return ComparisonResult.orderedDescending
                        }
                    }
                    
                    return ComparisonResult.orderedSame
                }
            })
            
            let outputAmounts = NSMutableArray()
            let outputAddresses = NSMutableArray()
            for _sortedOutput in sortedOutputs {
                let sortedOutput = _sortedOutput as! NSDictionary
                outputAddresses.add(sortedOutput.object(forKey: "to_address")!)
                outputAmounts.add(sortedOutput.object(forKey: "amount")!)
            }
            
            
            DLog("createSignedSerializedTransactionHex hashes: \(hashes.debugDescription)")
            DLog("createSignedSerializedTransactionHex inputIndexes: \(inputIndexes.debugDescription)")
            DLog("createSignedSerializedTransactionHex inputScripts: \(inputScripts.debugDescription)")
            DLog("createSignedSerializedTransactionHex outputAddresses: \(outputAddresses.debugDescription)")
            DLog("createSignedSerializedTransactionHex outputAmounts: \(outputAmounts.debugDescription)")
            DLog("createSignedSerializedTransactionHex privateKeys: \(privateKeys.debugDescription)")
            for _ in 0...3 {
                let txHexAndTxHash = TLCoreBitcoinWrapper.createSignedSerializedTransactionHex(self.getSelectedObjectCoinType(), hashes:hashes, inputIndexes:inputIndexes, inputScripts:inputScripts,
                    outputAddresses:outputAddresses, outputAmounts:outputAmounts, privateKeys:privateKeys,
                    outputScripts:stealthOutputScripts, signTx: signTx, isTestnet: self.appWallet.walletConfig.isTestnet)
                DLog("createSignedSerializedTransactionHex txHexAndTxHash: \(txHexAndTxHash.debugDescription)")
                if txHexAndTxHash != nil {
                    return (txHexAndTxHash!, realToAddresses, isInputsAllFromHDAccountAddresses ? txInputsAccountHDIdxes : nil)
                }
            }
            
            error(TLDisplayStrings.ENCOUNTERED_ERROR_CREATING_TRANSACTION_TRY_AGAIN_STRING())
            return (nil, realToAddresses, nil)
    }
}


