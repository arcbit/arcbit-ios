//
//  TLSendViewController.swift
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

import UIKit

@objc(TLSendViewController) class TLSendViewController: UIViewController, UITextFieldDelegate, UITabBarDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet private var currencySymbolButton: UIButton?
    @IBOutlet private var toAddressTextField: UITextField?
    @IBOutlet private var amountTextField: UITextField?
    @IBOutlet private var qrCodeImageView: UIImageView?
    @IBOutlet private var selectAccountImageView: UIImageView?
    @IBOutlet private var bitcoinDisplayLabel: UILabel?
    @IBOutlet private var fiatCurrencyDisplayLabel: UILabel?
    @IBOutlet private var scanQRButton: UIButton?
    @IBOutlet private var reviewPaymentButton: UIButton?
    @IBOutlet private var addressBookButton: UIButton?
    @IBOutlet private var fiatAmountTextField: UITextField?
    @IBOutlet private var topView: UIView?
    @IBOutlet private var bottomView: UIView?
    @IBOutlet private var accountNameLabel: UILabel?
    @IBOutlet private var accountBalanceLabel: UILabel?
    @IBOutlet private var balanceActivityIndicatorView: UIActivityIndicatorView?
    @IBOutlet private var fromViewContainer: UIView?
    @IBOutlet private var fromLabel: UILabel?
    @IBOutlet private var tabBar: UITabBar?
    private var tapGesture: UITapGestureRecognizer?

    private func setAmountFromUrlHandler() -> () {
        let dict = AppDelegate.instance().bitcoinURIOptionsDict
        if (dict != nil) {
            let addr = dict!.objectForKey("address") as! String
            let amount = dict!.objectForKey("amount") as! String
            
            self.setAmountFromUrlHandler(TLCurrencyFormat.bitcoinAmountStringToCoin(amount), address: addr)
            AppDelegate.instance().bitcoinURIOptionsDict = nil
        }
    }
    
    private func setAmountFromUrlHandler(amount: TLCoin, address: String) {
        self.toAddressTextField!.text = address
        let amountString = TLCurrencyFormat.coinToProperBitcoinAmountString(amount)
        self.amountTextField!.text = amountString
        
        TLSendFormData.instance().setAddress(address)
        TLSendFormData.instance().setAmount(amountString)
        
        self.updateFiatAmountTextFieldExchangeRate(nil)
    }
    
    private func setAllCoinsBarButton() {
        let allBarButtonItem = UIBarButtonItem(title: "Use all funds".localized, style: UIBarButtonItemStyle.Plain, target: self, action: "checkToFetchUTXOsAndDynamicFeesAndFillAmountFieldWithWholeBalance")
        navigationItem.rightBarButtonItem = allBarButtonItem
    }
    
    private func clearRightBarButton() {
        let allBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = allBarButtonItem
    }
    
    func checkToFetchUTXOsAndDynamicFeesAndFillAmountFieldWithWholeBalance() {
        if TLPreferences.enabledInAppSettingsKitDynamicFee() {
            if !AppDelegate.instance().godSend!.haveUpDatedUTXOs() {
                AppDelegate.instance().godSend!.getAndSetUnspentOutputs({
                    self.checkToFetchDynamicFeesAndFillAmountFieldWithWholeBalance()
                    }, failure: {
                        TLPrompts.promptErrorMessage("Error".localized, message: "Error fetching unspent outputs. Try again later.".localized)
                })
            } else {
                self.checkToFetchDynamicFeesAndFillAmountFieldWithWholeBalance()
            }
        } else {
            self.fillAmountFieldWithWholeBalance(false)
        }
    }

    func checkToFetchDynamicFeesAndFillAmountFieldWithWholeBalance() {
        if !AppDelegate.instance().txFeeAPI.haveUpdatedCachedDynamicFees() {
            AppDelegate.instance().txFeeAPI.getDynamicTxFee({
                (_jsonData: AnyObject!) in
                self.fillAmountFieldWithWholeBalance(true)
                }, failure: {
                    (code: Int, status: String!) in
                    TLPrompts.promptErrorMessage("Error".localized, message: "Unable to query dynamic fees. Falling back on fixed transaction fee. (fee can be configured on review payment)".localized)
                    self.fillAmountFieldWithWholeBalance(false)
            })
        } else {
            self.fillAmountFieldWithWholeBalance(true)
        }
    }

    
    func fillAmountFieldWithWholeBalance(useDynamicFees: Bool) {
        let fee:TLCoin
        let txSizeBytes:UInt64
        if useDynamicFees {
            if (AppDelegate.instance().godSend!.getSelectedObjectType() == .Account) {
                let accountObject = AppDelegate.instance().godSend!.getSelectedSendObject() as! TLAccountObject
                let inputCount = accountObject.stealthPaymentUnspentOutputsCount + accountObject.unspentOutputsCount
                txSizeBytes = TLSpaghettiGodSend.getEstimatedTxSize(inputCount, outputCount: 1)
                DLog("fillAmountFieldWithWholeBalance TLAccountObject useDynamicFees inputCount txSizeBytes: \(inputCount) \(txSizeBytes)")
            } else {
                let importedAddress = AppDelegate.instance().godSend!.getSelectedSendObject() as! TLImportedAddress
                txSizeBytes = TLSpaghettiGodSend.getEstimatedTxSize(importedAddress.unspentOutputsCount, outputCount: 1)
                DLog("fillAmountFieldWithWholeBalance importedAddress useDynamicFees inputCount txSizeBytes: \(importedAddress.unspentOutputsCount) \(txSizeBytes)")
            }
            
            if let dynamicFeeSatoshis:NSNumber? = AppDelegate.instance().txFeeAPI.getCachedDynamicFee() {
                fee = TLCoin(uint64: txSizeBytes*dynamicFeeSatoshis!.unsignedLongLongValue)
                DLog("fillAmountFieldWithWholeBalance coinFeeAmount dynamicFeeSatoshis: \(txSizeBytes*dynamicFeeSatoshis!.unsignedLongLongValue)")
            } else {
                fee = TLCurrencyFormat.bitcoinAmountStringToCoin(TLPreferences.getInAppSettingsKitTransactionFee()!)
            }
            
        } else {
            let feeAmount = TLPreferences.getInAppSettingsKitTransactionFee()
            fee = TLCurrencyFormat.bitcoinAmountStringToCoin(feeAmount!)
        }

        let accountBalance = AppDelegate.instance().godSend!.getCurrentFromBalance()
        let sendAmount = accountBalance.subtract(fee)
        DLog("fillAmountFieldWithWholeBalance accountBalance: \(accountBalance.toUInt64())")
        DLog("fillAmountFieldWithWholeBalance sendAmount: \(sendAmount.toUInt64())")
        DLog("fillAmountFieldWithWholeBalance fee: \(fee.toUInt64())")
        TLSendFormData.instance().feeAmount = fee
        TLSendFormData.instance().useAllFunds = true
        if accountBalance.greater(fee) && sendAmount.greater(TLCoin.zero()) {
            TLSendFormData.instance().setAmount(TLCurrencyFormat.coinToProperBitcoinAmountString(sendAmount))
        } else {
            TLSendFormData.instance().setAmount(nil)
        }
        TLSendFormData.instance().setFiatAmount(nil)
        self.updateSendForm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        
        self.setLogoImageView()
        
        self.bottomView!.backgroundColor = TLColors.mainAppColor()
        
        self.fromViewContainer!.backgroundColor = TLColors.mainAppColor()
        self.accountNameLabel!.textColor = TLColors.mainAppOppositeColor()
        self.accountBalanceLabel!.textColor = TLColors.mainAppOppositeColor()
        self.balanceActivityIndicatorView!.color = TLColors.mainAppOppositeColor()
        
        self.scanQRButton!.backgroundColor = TLColors.mainAppColor()
        self.reviewPaymentButton!.backgroundColor = TLColors.mainAppColor()
        self.addressBookButton!.backgroundColor = TLColors.mainAppColor()
        self.scanQRButton!.setTitleColor(TLColors.mainAppOppositeColor(), forState: .Normal)
        self.reviewPaymentButton!.setTitleColor(TLColors.mainAppOppositeColor(), forState: .Normal)
        self.addressBookButton!.setTitleColor(TLColors.mainAppOppositeColor(), forState: .Normal)
        
        if TLUtils.isIPhone5() || TLUtils.isIPhone4() {
            let keyboardDoneButtonView = UIToolbar()
            keyboardDoneButtonView.sizeToFit()
            let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("dismissKeyboard") )
            let toolbarButtons = [item]
            keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
            self.amountTextField!.inputAccessoryView = keyboardDoneButtonView
            self.fiatAmountTextField!.inputAccessoryView = keyboardDoneButtonView
        }

        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_SEND_SCREEN_LOADING(),
            object: nil)
        

        self.tabBar!.selectedItem = ((self.tabBar!.items as NSArray!).objectAtIndex(0)) as? UITabBarItem
        if UIScreen.mainScreen().bounds.size.height <= 480.0 { // is 3.5 inch screen
            self.tabBar!.hidden = true
        }
        
        
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"dismissTextFieldsAndScrollDown:",
            name:TLNotificationEvents.EVENT_HAMBURGER_MENU_OPENED(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"clearSendForm:",
            name:TLNotificationEvents.EVENT_PREFERENCES_FIAT_DISPLAY_CHANGED(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"clearSendForm:",
            name:TLNotificationEvents.EVENT_PREFERENCES_BITCOIN_DISPLAY_CHANGED(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateCurrencyView:",
            name:TLNotificationEvents.EVENT_PREFERENCES_FIAT_DISPLAY_CHANGED(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateBitcoinDisplayView:",
            name:TLNotificationEvents.EVENT_PREFERENCES_BITCOIN_DISPLAY_CHANGED(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateAccountBalanceView:",
            name:TLNotificationEvents.EVENT_PREFERENCES_FIAT_DISPLAY_CHANGED(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateAccountBalanceView:",
            name:TLNotificationEvents.EVENT_PREFERENCES_BITCOIN_DISPLAY_CHANGED(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateAccountBalanceView:",
            name:TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"updateAccountBalanceView:",
            name:TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"hideHUDAndUpdateBalanceView",
            name:TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_UNCONFIRMED_TRANSACTION(), object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:"clearSendForm:",
             name:TLNotificationEvents.EVENT_SEND_PAYMENT(), object:nil)
        
        self.updateSendForm()
        
        self.amountTextField!.keyboardType = .DecimalPad
        self.amountTextField!.delegate = self
        self.fiatAmountTextField!.keyboardType = .DecimalPad
        self.fiatAmountTextField!.delegate = self
        
        self.toAddressTextField!.delegate = self
        self.toAddressTextField!.clearButtonMode = UITextFieldViewMode.WhileEditing
        
        self.currencySymbolButton?.setBackgroundImage(UIImage(named: "balance_bg_pressed.9.png"), forState: .Highlighted)
        self.currencySymbolButton?.setBackgroundImage(UIImage(named: "balance_bg_normal.9.png"), forState: .Normal)
        
        self.sendViewSetup()
        
        if self.slidingViewController() != nil {
            self.slidingViewController().topViewAnchoredGesture = [.Tapping, .Panning]
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.topView!.scrollToY(0)
    }
    
    private func sendViewSetup() -> () {
        self._updateCurrencyView()
        self._updateBitcoinDisplayView()
        
        self.updateViewToNewSelectedObject()
        
        if (AppDelegate.instance().godSend!.hasFetchedCurrentFromData()) {
            let balance = AppDelegate.instance().godSend!.getCurrentFromBalance()
            let balanceString = TLCurrencyFormat.getProperAmount(balance)
            self.accountBalanceLabel!.text = balanceString as String
            self.accountBalanceLabel!.hidden = false
            self.balanceActivityIndicatorView!.stopAnimating()
            self.balanceActivityIndicatorView!.hidden = true
        } else {
            self.refreshAccountDataAndSetBalanceView()
        }
        if (AppDelegate.instance().justSetupHDWallet) {
            self.showReceiveView()
        }
    }
    
    func refreshAccountDataAndSetBalanceView(fetchDataAgain: Bool = false) -> () {
        if (AppDelegate.instance().godSend!.getSelectedObjectType() == .Account) {
            let accountObject = AppDelegate.instance().godSend!.getSelectedSendObject() as! TLAccountObject
            self.balanceActivityIndicatorView!.hidden = false
            self.accountBalanceLabel!.hidden = true
            self.balanceActivityIndicatorView!.startAnimating()
            AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: fetchDataAgain, success: {
                if accountObject.downloadState == .Downloaded {
                    self.accountBalanceLabel!.hidden = false
                    self.balanceActivityIndicatorView!.stopAnimating()
                    self.balanceActivityIndicatorView!.hidden = true
                    self._updateAccountBalanceView()
                }
            })
            
        } else if (AppDelegate.instance().godSend!.getSelectedObjectType() == .Address) {
            let importedAddress = AppDelegate.instance().godSend!.getSelectedSendObject() as! TLImportedAddress
            self.balanceActivityIndicatorView!.hidden = false
            self.accountBalanceLabel!.hidden = true
            self.balanceActivityIndicatorView!.startAnimating()
            AppDelegate.instance().pendingOperations.addSetUpImportedAddressOperation(importedAddress, fetchDataAgain: fetchDataAgain, success: {
                if importedAddress.downloadState == .Downloaded {
                    self.accountBalanceLabel!.hidden = false
                    self.balanceActivityIndicatorView!.stopAnimating()
                    self.balanceActivityIndicatorView!.hidden = true
                    self._updateAccountBalanceView()
                }
            })
        }
    }
    
    private func showReceiveView() -> () {
        self.slidingViewController().topViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ReceiveNav") 
    }
    
    private func updateViewToNewSelectedObject() -> () {
        let label = AppDelegate.instance().godSend!.getCurrentFromLabel()
        self.accountNameLabel!.text = label
        self._updateAccountBalanceView()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.updateViewToNewSelectedObject()
    
        // TODO: better way
        if AppDelegate.instance().scannedEncryptedPrivateKey != nil {
            TLPrompts.promptForEncryptedPrivKeyPassword(self, view:self.slidingViewController().topViewController.view,
                encryptedPrivKey:AppDelegate.instance().scannedEncryptedPrivateKey!,
                success:{(privKey: String!) in
                    if AppDelegate.instance().scannedEncryptedPrivateKey == nil {
                        return
                    }

                    if (!TLCoreBitcoinWrapper.isValidPrivateKey(privKey, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)) {
                        TLPrompts.promptErrorMessage("Error".localized, message: "Invalid private key".localized)
                    } else {
                        let importedAddress = AppDelegate.instance().godSend!.getSelectedSendObject() as! TLImportedAddress?
                        let success = importedAddress!.setPrivateKeyInMemory(privKey)
                        if (!success) {
                            TLPrompts.promptSuccessMessage("Error".localized, message: "Private key does not match imported address".localized)
                        } else {
                            self._reviewPaymentClicked()
                        }
                        AppDelegate.instance().scannedEncryptedPrivateKey = nil
                    }
                }, failure:{(isCanceled: Bool) in
                    AppDelegate.instance().scannedEncryptedPrivateKey = nil
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_SEND_SCREEN(),
            object: nil, userInfo: nil)
        
        self.setAmountFromUrlHandler()
        
        if (!TLPreferences.getInAppSettingsKitEnablePinCode() && TLSuggestions.instance().conditionToPromptToSuggestEnablePinSatisfied()) {
            TLSuggestions.instance().promptToSuggestEnablePin(self)
        } else if TLSuggestions.instance().conditionToPromptRateAppSatisfied() {
            TLPrompts.promptAlertController(self, title: "Like using ArcBit?".localized,
                message: "Rate us in the App Store!".localized, okText: "Rate Now".localized, cancelTx: "Not now".localized,
                success: { () -> () in
                    let url = NSURL(string: "https://itunes.apple.com/app/id999487888");
                    if (UIApplication.sharedApplication().canOpenURL(url!)) {
                        UIApplication.sharedApplication().openURL(url!);
                    }
                    TLPreferences.setDisabledPromptRateApp(true)
                    if !TLPreferences.hasRatedOnce() {
                        TLPreferences.setHasRatedOnce()
                    }
                }, failure: { (Bool) -> () in
            })
        } else if TLSuggestions.instance().conditionToPromptShowWebWallet() {
            TLPrompts.promptAlertController(self, title: "Check out the ArcBit Web Wallet!".localized,
                message: "Use ArcBit on your browser to complement the mobile app. The web wallet has all the features that the mobile wallet has plus more! Including a new easy way to store and spend Bitcoins from cold storage!".localized, okText: "Go".localized, cancelTx: "Not now".localized,
                success: { () -> () in
                    let url = NSURL(string: "https://chrome.google.com/webstore/detail/arcbit-bitcoin-wallet/dkceiphcnbfahjbomhpdgjmphnpgogfk");
                    if (UIApplication.sharedApplication().canOpenURL(url!)) {
                        UIApplication.sharedApplication().openURL(url!);
                    }
                    TLPreferences.setDisabledPromptShowWebWallet(true)
                }, failure: { (Bool) -> () in
            })
        }
        self.navigationController!.view.addGestureRecognizer(self.slidingViewController().panGesture)
    }
    
    func _clearSendForm() {
        TLSendFormData.instance().setAddress(nil)
        TLSendFormData.instance().setAmount(nil)
        self.updateSendForm()
    }
    
    func clearSendForm(notification: NSNotification) {
        _clearSendForm()
    }
    
    private func updateSendForm() {
        self.toAddressTextField!.text = TLSendFormData.instance().getAddress()
        
        if (TLSendFormData.instance().getAmount() != nil) {
            self.amountTextField!.text = TLSendFormData.instance().getAmount()!
            self.updateFiatAmountTextFieldExchangeRate(nil)
        } else if (TLSendFormData.instance().getFiatAmount() != nil) {
            self.fiatAmountTextField!.text = TLSendFormData.instance().getFiatAmount()!
            self.updateAmountTextFieldExchangeRate(nil)
        } else {
            self.amountTextField!.text = nil
            self.fiatAmountTextField!.text = nil
        }
    }
    
    func _updateCurrencyView() {
        let currency = TLCurrencyFormat.getFiatCurrency()
        self.fiatCurrencyDisplayLabel!.text = currency
        
        self.updateSendForm()
        
        self.updateAmountTextFieldExchangeRate(nil)
    }
    
    func updateCurrencyView(notification: NSNotification) {
        _updateCurrencyView()
    }
    
    func _updateBitcoinDisplayView() {
        let bitcoinDisplay = TLCurrencyFormat.getBitcoinDisplay()
        self.bitcoinDisplayLabel!.text = bitcoinDisplay
        
        self.updateSendForm()
        
        self.updateFiatAmountTextFieldExchangeRate(nil)
    }
    
    func updateBitcoinDisplayView(notification: NSNotification) {
        _updateBitcoinDisplayView()
    }
    
    func dismissKeyboard() {
        self.amountTextField!.resignFirstResponder()
        self.fiatAmountTextField!.resignFirstResponder()
        self.toAddressTextField!.resignFirstResponder()
        if self.tapGesture != nil {
            self.view.removeGestureRecognizer(self.tapGesture!)
            self.tapGesture = nil
        }
        self.topView!.scrollToY(0)
    }
    
    func hideHUDAndUpdateBalanceView() {
        self.accountBalanceLabel!.hidden = false
        self.balanceActivityIndicatorView!.stopAnimating()
        self.balanceActivityIndicatorView!.hidden = true
        self._updateAccountBalanceView()
    }
    
    func _updateAccountBalanceView() {
        let balance = AppDelegate.instance().godSend!.getCurrentFromBalance()
        let balanceString = TLCurrencyFormat.getProperAmount(balance)
        self.accountBalanceLabel!.text = balanceString as String
    }
    
    func updateAccountBalanceView(notification: NSNotification) {
        self._updateAccountBalanceView()
    }
    
    func onAccountSelected(note: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: TLNotificationEvents.EVENT_ACCOUNT_SELECTED(),
            object: nil)
        
        let selectedDict = note.object as! NSDictionary
        let sendFromType = TLSendFromType(rawValue: selectedDict.objectForKey("sendFromType") as! Int)
        let sendFromIndex = selectedDict.objectForKey("sendFromIndex") as! Int
        AppDelegate.instance().updateGodSend(sendFromType!, sendFromIndex: sendFromIndex)
        
        self.updateViewToNewSelectedObject()
    }
    
    private func fillToAddressTextField(address: String) -> Bool {
        if (TLCoreBitcoinWrapper.isValidAddress(address, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)) {
            self.toAddressTextField!.text = address
            TLSendFormData.instance().setAddress(address)
            return true
        } else {
            let av = UIAlertView(title: "Invalid Bitcoin Address".localized,
                message: "",
                delegate: nil,
                cancelButtonTitle: "OK".localized
            )
            
            av.show()
            return false
        }
    }
    
    private func checkTofetchFeeThenFinalPromptReviewTx() {
        if TLPreferences.enabledInAppSettingsKitDynamicFee() && !AppDelegate.instance().txFeeAPI.haveUpdatedCachedDynamicFees() {
            AppDelegate.instance().txFeeAPI.getDynamicTxFee({
                (_jsonData: AnyObject!) in
                self.showFinalPromptReviewTx()
                }, failure: {
                    (code: Int, status: String!) in
                    self.showFinalPromptReviewTx()
            })
        } else {
            self.showFinalPromptReviewTx()
        }
    }

    private func showFinalPromptReviewTx() {
        let bitcoinAmount = self.amountTextField!.text
        let toAddress = self.toAddressTextField!.text
    
        if (!TLCoreBitcoinWrapper.isValidAddress(toAddress!, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)) {
            TLPrompts.promptErrorMessage("Error".localized, message: "You must provide a valid bitcoin address.".localized)
            return
        }

        DLog("showFinalPromptReviewTx bitcoinAmount %@", function: bitcoinAmount!)
        let inputtedAmount = TLCurrencyFormat.properBitcoinAmountStringToCoin(bitcoinAmount!)
        
        if (inputtedAmount.equalTo(TLCoin.zero())) {
            TLPrompts.promptErrorMessage("Error".localized, message: "Amount entered must be greater then zero.".localized)
            return
        }
        

        func showReviewPaymentViewController(useDynamicFees: Bool) {
            let fee:TLCoin
            let txSizeBytes:UInt64
            if useDynamicFees {
                if TLSendFormData.instance().useAllFunds {
                    fee = TLSendFormData.instance().feeAmount!
                } else {
                    if (AppDelegate.instance().godSend!.getSelectedObjectType() == .Account) {
                        let accountObject = AppDelegate.instance().godSend!.getSelectedSendObject() as! TLAccountObject
                        let inputCount = accountObject.getInputsNeededToConsume(inputtedAmount)
                        //TODO account for change output, output count likely 2 (3 if have stealth payment) cause if user dont do click use all funds because will likely have change
                        // but for now dont need to be fully accurate with tx fee, for now we will underestimate tx fee, wont underestimate much because outputs contributes little to tx size
                        txSizeBytes = TLSpaghettiGodSend.getEstimatedTxSize(inputCount, outputCount: 1)
                        DLog("showPromptReviewTx TLAccountObject useDynamicFees inputCount txSizeBytes: \(inputCount) \(txSizeBytes)")
                    } else {
                        let importedAddress = AppDelegate.instance().godSend!.getSelectedSendObject() as! TLImportedAddress
                        // TODO same as above
                        let inputCount = importedAddress.getInputsNeededToConsume(inputtedAmount)
                        txSizeBytes = TLSpaghettiGodSend.getEstimatedTxSize(inputCount, outputCount: 1)
                        DLog("showPromptReviewTx importedAddress useDynamicFees inputCount txSizeBytes: \(importedAddress.unspentOutputsCount) \(txSizeBytes)")
                    }
                    
                    if let dynamicFeeSatoshis:NSNumber? = AppDelegate.instance().txFeeAPI.getCachedDynamicFee() {
                        fee = TLCoin(uint64: txSizeBytes*dynamicFeeSatoshis!.unsignedLongLongValue)
                        DLog("showPromptReviewTx coinFeeAmount dynamicFeeSatoshis: \(txSizeBytes*dynamicFeeSatoshis!.unsignedLongLongValue)")
                        
                    } else {
                        fee = TLCurrencyFormat.bitcoinAmountStringToCoin(TLPreferences.getInAppSettingsKitTransactionFee()!)
                    }
                    TLSendFormData.instance().feeAmount = fee
                }
            } else {
                let feeAmount = TLPreferences.getInAppSettingsKitTransactionFee()
                fee = TLCurrencyFormat.bitcoinAmountStringToCoin(feeAmount!)
            }
            
            let amountNeeded = inputtedAmount.add(fee)
            let accountBalance = AppDelegate.instance().godSend!.getCurrentFromBalance()
            if (amountNeeded.greater(accountBalance)) {
                let msg = String(format: "You have %@ %@, but %@ is needed. (This includes the transactions fee)".localized, TLCurrencyFormat.coinToProperBitcoinAmountString(accountBalance), TLCurrencyFormat.getBitcoinDisplay(), TLCurrencyFormat.coinToProperBitcoinAmountString(amountNeeded))
                TLPrompts.promptErrorMessage("Insufficient Balance".localized, message: msg)
                return
            }
            
            DLog("showPromptReviewTx accountBalance: \(accountBalance.toUInt64())")
            DLog("showPromptReviewTx inputtedAmount: \(inputtedAmount.toUInt64())")
            DLog("showPromptReviewTx fee: \(fee.toUInt64())")
            TLSendFormData.instance().fromLabel = AppDelegate.instance().godSend!.getCurrentFromLabel()!
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("ReviewPayment") as! TLReviewPaymentViewController
            self.slidingViewController().presentViewController(vc, animated: true, completion: nil)
        }
        
        func checkToFetchDynamicFees() {
            if !AppDelegate.instance().txFeeAPI.haveUpdatedCachedDynamicFees() {
                AppDelegate.instance().txFeeAPI.getDynamicTxFee({
                    (_jsonData: AnyObject!) in
                    showReviewPaymentViewController(true)
                    }, failure: {
                        (code: Int, status: String!) in
                        TLPrompts.promptErrorMessage("Error".localized, message: "Unable to query dynamic fees. Falling back on fixed transaction fee. (fee can be configured on review payment)".localized)
                        showReviewPaymentViewController(false)
                })
            } else {
                showReviewPaymentViewController(true)
            }
        }
        
        if TLPreferences.enabledInAppSettingsKitDynamicFee() {
            if !AppDelegate.instance().godSend!.haveUpDatedUTXOs() {
                AppDelegate.instance().godSend!.getAndSetUnspentOutputs({
                    checkToFetchDynamicFees()
                    }, failure: {
                        TLPrompts.promptErrorMessage("Error".localized, message: "Error fetching unspent outputs. Try again later.".localized)
                })
            } else {
                checkToFetchDynamicFees()
            }
        } else {
            showReviewPaymentViewController(false)
        }
    }
    
    private func handleTempararyImportPrivateKey(privateKey: String) {
        if (!TLCoreBitcoinWrapper.isValidPrivateKey(privateKey, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)) {
            TLPrompts.promptErrorMessage("Error".localized, message: "Invalid private key".localized)
        } else {
            let importedAddress = AppDelegate.instance().godSend!.getSelectedSendObject() as! TLImportedAddress?
            let success = importedAddress!.setPrivateKeyInMemory(privateKey)
            if (!success) {
                TLPrompts.promptSuccessMessage("Error".localized, message: "Private key does not match imported address".localized)
            } else {
                self.checkTofetchFeeThenFinalPromptReviewTx()
            }
        }
    }
    
    private func showPromptReviewTx() {
        if (AppDelegate.instance().godSend!.needWatchOnlyAccountPrivateKey()) {
            let accountObject = AppDelegate.instance().godSend!.getSelectedSendObject() as! TLAccountObject
            TLPrompts.promptForTempararyImportExtendedPrivateKey(self, success: {
                (data: String!) in
                if (!TLHDWalletWrapper.isValidExtendedPrivateKey(data)) {
                    TLPrompts.promptErrorMessage("Error".localized, message: "Invalid account private key".localized)
                } else {
                    let success = accountObject.setExtendedPrivateKeyInMemory(data)
                    if (!success) {
                        TLPrompts.promptErrorMessage("Error".localized, message: "Account private key does not match imported account public key".localized)
                    } else {
                        self.checkTofetchFeeThenFinalPromptReviewTx()
                    }
                }
                

                }, error: {
                    (data: String?) in
            })
        } else if (AppDelegate.instance().godSend!.needWatchOnlyAddressPrivateKey()) {
            TLPrompts.promptForTempararyImportPrivateKey(self, success: {
                (data: String!) in
                if (TLCoreBitcoinWrapper.isBIP38EncryptedKey(data, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)) {
                    TLPrompts.promptForEncryptedPrivKeyPassword(self, view:self.slidingViewController().topViewController.view, encryptedPrivKey: data, success: {
                        (privKey: String!) in
                        self.handleTempararyImportPrivateKey(privKey)
                        }, failure: {
                            (isCanceled: Bool) in
                    })
                } else {
                    if AppDelegate.instance().scannedEncryptedPrivateKey == nil {
                        self.handleTempararyImportPrivateKey(data)
                    }
                }
                }, error: {
                    (data: String?) in
            })
            
        } else if (AppDelegate.instance().godSend!.needEncryptedPrivateKeyPassword()) {
            let encryptedPrivateKey = AppDelegate.instance().godSend!.getEncryptedPrivateKey()
            TLPrompts.promptForEncryptedPrivKeyPassword(self, view:self.slidingViewController().topViewController.view, encryptedPrivKey: encryptedPrivateKey, success: {
                (privKey: String!) in
                let importedAddress = AppDelegate.instance().godSend!.getSelectedSendObject() as! TLImportedAddress?
                let success = importedAddress!.setPrivateKeyInMemory(privKey)
                if (!success) {
                    TLPrompts.promptSuccessMessage("Error".localized, message: "Private key does not match imported address".localized)
                } else {
                    self.checkTofetchFeeThenFinalPromptReviewTx()
                }
                }, failure: {
                    (isCanceled: Bool) in
            })
        } else {
            self.checkTofetchFeeThenFinalPromptReviewTx()
        }
    }
    
    func dismissTextFieldsAndScrollDown(notification: NSNotification) {
        self.fiatAmountTextField!.resignFirstResponder()
        self.amountTextField!.resignFirstResponder()
        self.toAddressTextField!.resignFirstResponder()
        
        self.topView!.scrollToY(0)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification,
            object: nil)
    }
    
    func onAddressSelected(note: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: TLNotificationEvents.EVENT_ADDRESS_SELECTED(),
            object: nil)
        
        let address = note.object as! String
        self.toAddressTextField!.text = address
        TLSendFormData.instance().setAddress(address)
    }
    
    func _reviewPaymentClicked() {
        self.showPromptReviewTx()
    }
    
    private func handleScannedAddress(data: String) {
        if (data.hasPrefix("bitcoin:")) {
            let parsedBitcoinURI = TLWalletUtils.parseBitcoinURI(data)
            if parsedBitcoinURI == nil {
                TLPrompts.promptErrorMessage("Error".localized, message: "URL does not contain an address.".localized)
                return
            }
            let address = parsedBitcoinURI!.objectForKey("address") as! String?
            if (address == nil) {
                TLPrompts.promptErrorMessage("Error".localized, message: "URL does not contain an address.".localized)
                return
            }
            
            let success = self.fillToAddressTextField(address!)
            if (success) {
                let parsedBitcoinURIAmount = parsedBitcoinURI!.objectForKey("amount") as! String?
                if (parsedBitcoinURIAmount != nil) {
                    let coinAmount = TLCoin(bitcoinAmount: parsedBitcoinURIAmount!, bitcoinDenomination: TLBitcoinDenomination.Bitcoin)
                    let amountString = TLCurrencyFormat.coinToProperBitcoinAmountString(coinAmount)
                    self.amountTextField!.text = amountString
                    self.updateFiatAmountTextFieldExchangeRate(nil)
                    TLSendFormData.instance().setAmount(amountString)
                    TLSendFormData.instance().setFiatAmount(nil)
                }
            }
        } else {
            self.fillToAddressTextField(data)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> () {
        if (segue.identifier == "selectAccount") {
            let vc = segue.destinationViewController 
            vc.navigationItem.title = "Select Account".localized
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "onAccountSelected:",
                name: TLNotificationEvents.EVENT_ACCOUNT_SELECTED(), object: nil)
        }
    }
    
    func preFetchUTXOsAndDynamicFees() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            DLog("preFetchUTXOsAndDynamicFees")
            if TLPreferences.enabledInAppSettingsKitDynamicFee() {
                DLog("preFetchUTXOsAndDynamicFees enabledInAppSettingsKitDynamicFee")
                
                if !AppDelegate.instance().txFeeAPI.haveUpdatedCachedDynamicFees() {
                    AppDelegate.instance().txFeeAPI.getDynamicTxFee({
                        (_jsonData: AnyObject!) in
                        DLog("preFetchUTXOsAndDynamicFees getDynamicTxFee success")
                        }, failure: {
                            (code: Int, status: String!) in
                            DLog("preFetchUTXOsAndDynamicFees getDynamicTxFee failure")
                    })
                }
                
                if !AppDelegate.instance().godSend!.haveUpDatedUTXOs() {
                    AppDelegate.instance().godSend!.getAndSetUnspentOutputs({
                        DLog("preFetchUTXOsAndDynamicFees getAndSetUnspentOutputs success")
                        }, failure: {
                            DLog("preFetchUTXOsAndDynamicFees getAndSetUnspentOutputs failure")
                    })
                }
            }
        }
    }
    
    @IBAction private func updateFiatAmountTextFieldExchangeRate(sender: AnyObject?) {
        let currency = TLCurrencyFormat.getFiatCurrency()
        let amount = TLCurrencyFormat.properBitcoinAmountStringToCoin(self.amountTextField!.text!)

        if (amount.greater(TLCoin.zero())) {
            self.fiatAmountTextField!.text = TLExchangeRate.instance().fiatAmountStringFromBitcoin(currency,
                bitcoinAmount: amount)
            TLSendFormData.instance().toAmount = amount
        } else {
            self.fiatAmountTextField!.text = nil
            TLSendFormData.instance().toAmount = nil
        }
    }
    
    @IBAction private func updateAmountTextFieldExchangeRate(sender: AnyObject?) {
        let currency = TLCurrencyFormat.getFiatCurrency()
        let fiatFormatter = NSNumberFormatter()
        fiatFormatter.numberStyle = .DecimalStyle
        fiatFormatter.maximumFractionDigits = 2
        let fiatAmount = fiatFormatter.numberFromString(self.fiatAmountTextField!.text!)
        if fiatAmount != nil && fiatAmount! != 0 {
            let bitcoinAmount = TLExchangeRate.instance().bitcoinAmountFromFiat(currency, fiatAmount: fiatAmount!.doubleValue)
            self.amountTextField!.text = TLCurrencyFormat.coinToProperBitcoinAmountString(bitcoinAmount)
            TLSendFormData.instance().toAmount = bitcoinAmount
        } else {
            self.amountTextField!.text = nil
            TLSendFormData.instance().toAmount = nil
        }
    }
    
    @IBAction private func reviewPaymentClicked(sender: AnyObject) {
        self.dismissKeyboard()
        
        let toAddress = self.toAddressTextField!.text
        if toAddress != nil && TLStealthAddress.isStealthAddress(toAddress!, isTestnet: false) {
            func checkToShowStealthPaymentDelayInfo() {
                if TLSuggestions.instance().enabledShowStealthPaymentDelayInfo() && TLBlockExplorerAPI.STATIC_MEMBERS.blockExplorerAPI == .Blockchain {
                    let msg = "Sending payment to a reusable address might take longer to show up then a normal transaction with the blockchain.info API. You might have to wait until at least 1 confirmation for the transaction to show up. This is due to the limitations of the blockchain.info API. For reusable address payments to show up faster, configure your app to use the Insight API in advance settings.".localized
                    TLPrompts.promtForOK(self, title:"Warning".localized, message:msg, success: {
                        () in
                        TLSuggestions.instance().setEnableShowStealthPaymentDelayInfo(false)
                    })
                } else {
                    self._reviewPaymentClicked()
                }
            }
            
            if TLSuggestions.instance().enabledShowStealthPaymentNote() {
                let msg = "You are making a payment to a reusable address. Make sure that the receiver can see the payment made to them. (All ArcBit reusable addresses are compatible with other ArcBit wallets)".localized
                TLPrompts.promtForOK(self, title:"Note".localized, message:msg, success: {
                    () in
                    self._reviewPaymentClicked()
                    TLSuggestions.instance().setEnableShowStealthPaymentNote(false)
                    checkToShowStealthPaymentDelayInfo()
                })
            } else {
                checkToShowStealthPaymentDelayInfo();
            }
            
        } else {
            self._reviewPaymentClicked()
        }
    }
    
    @IBAction private func scanQRCodeClicked(sender: AnyObject) {
        AppDelegate.instance().showAddressReaderControllerFromViewController(self, success: {
            (data: String!) in
            self.handleScannedAddress(data)
            }, error: {
                (data: String?) in
        })
    }
    
    @IBAction private func addressBookClicked(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onAddressSelected:", name: TLNotificationEvents.EVENT_ADDRESS_SELECTED(), object: nil)
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("AddressBook") 
        self.slidingViewController().presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction private func menuButtonClicked(sender: AnyObject) {
        self.slidingViewController().anchorTopViewToRightAnimated(true)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: (NSRange), replacementString string: String) -> Bool {
        let newString = (textField.text as! NSString).stringByReplacingCharactersInRange(range, withString: string)
        if (textField == self.toAddressTextField) {
            TLSendFormData.instance().setAddress(newString)
        } else if (textField == self.amountTextField) {
            TLSendFormData.instance().setAmount(newString)
            TLSendFormData.instance().setFiatAmount(nil)
            TLSendFormData.instance().useAllFunds = false
        } else if (textField == self.fiatAmountTextField) {
            TLSendFormData.instance().setFiatAmount(newString)
            TLSendFormData.instance().setAmount(nil)
            TLSendFormData.instance().useAllFunds = false
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if (self.tapGesture == nil) {
            self.tapGesture = UITapGestureRecognizer(target: self,
                action: "dismissKeyboard")
            
            self.view.addGestureRecognizer(self.tapGesture!)
        }
        
        self.setAllCoinsBarButton()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissTextFieldsAndScrollDown:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        if TLUtils.isIPhone5() {
            if textField == self.amountTextField || textField == self.fiatAmountTextField {
                self.topView!.scrollToY(-140)
            } else {
                self.topView!.scrollToView(self.fiatAmountTextField!)
            }
        } else if TLUtils.isIPhone4() {
            if textField == self.amountTextField || textField == self.fiatAmountTextField {
                self.topView!.scrollToY(-230)
            } else {
                self.topView!.scrollToView(self.fiatAmountTextField!)
            }
        }
        if textField == self.amountTextField || textField == self.fiatAmountTextField {
            self.preFetchUTXOsAndDynamicFees()
        }
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if textField != self.toAddressTextField {
            self.clearRightBarButton()
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        if (textField == self.toAddressTextField) {
            TLSendFormData.instance().setAddress(nil)
        }
        
        return true
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if (item.tag == 1) {
            self.showReceiveView()
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}


