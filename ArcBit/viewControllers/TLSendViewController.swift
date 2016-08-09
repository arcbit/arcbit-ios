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
    private var beforeSendBalance: TLCoin? = nil
    private var isShowingSendHUD = false

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
        let allBarButtonItem = UIBarButtonItem(title: "Use all funds".localized, style: UIBarButtonItemStyle.Plain, target: self, action: "fillAmountFieldWithWholeBalance")
        navigationItem.rightBarButtonItem = allBarButtonItem
    }
    
    private func clearRightBarButton() {
        let allBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = allBarButtonItem
    }
    
    func fillAmountFieldWithWholeBalance() {
        let accountBalance = AppDelegate.instance().godSend!.getCurrentFromBalance()
        let fee:TLCoin
        if (!TLPreferences.isAutomaticFee()) {
            fee = TLCurrencyFormat.bitcoinAmountStringToCoin(TLWalletUtils.DEFAULT_FEE_AMOUNT_IN_BITCOINS())
        } else {
            let feeAmount = TLPreferences.getInAppSettingsKitTransactionFee()
            fee = TLCurrencyFormat.bitcoinAmountStringToCoin(feeAmount!)
        }

        let sendAmount = accountBalance.subtract(fee)

        if sendAmount.greater(TLCoin.zero()) {
            TLSendFormData.instance().setAmount(TLCurrencyFormat.coinToProperBitcoinAmountString(sendAmount))
        } else {
            TLSendFormData.instance().setAmount("0")
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
            ,selector:"hideHUDAndUpdateBalanceView",
            name:TLNotificationEvents.EVENT_TO_ADDRESS_WEBSOCKET_NOTIFICATION(), object:nil)
        
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

    func hiddenPresentAndDimissTransparentViewController() -> () {
        if AppDelegate.instance().doHiddenPresentAndDimissTransparentViewController {
            AppDelegate.instance().doHiddenPresentAndDimissTransparentViewController = false
            let transitionController = TransitionDelegate()
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("TransparentViewController") 
            vc.view.backgroundColor = UIColor.clearColor()
            vc.transitioningDelegate = transitionController
            vc.modalPresentationStyle = .Custom
            
            (AppDelegate.instance().window!.rootViewController! as! ECSlidingViewController).topViewController = self.storyboard!.instantiateViewControllerWithIdentifier("TransparentViewController") 
        }
    }
    
    func refreshAccountDataAndSetBalanceView(fetchDataAgain: Bool = false) -> () {
        let checkToRefreshAgain = { () -> () in
            let afterSendBalance = AppDelegate.instance().godSend!.getCurrentFromBalance()
            
            if self.beforeSendBalance != nil && afterSendBalance.equalTo(self.beforeSendBalance!) {
                self.beforeSendBalance = nil
                self.refreshAccountDataAndSetBalanceView()
            } else {
                self.setSendingHUDHidden(true)
                
                self.balanceActivityIndicatorView!.stopAnimating()
                self.balanceActivityIndicatorView!.hidden = true
                self._updateAccountBalanceView()
                self.viewDidLoad()
                self.hiddenPresentAndDimissTransparentViewController()
            }
        }
        
        self.accountBalanceLabel!.hidden = true
        self.balanceActivityIndicatorView!.hidden = false
        self.balanceActivityIndicatorView!.startAnimating()

        if (AppDelegate.instance().godSend!.getSelectedObjectType() == .Account) {
            let accountObject = AppDelegate.instance().godSend!.getSelectedSendObject() as! TLAccountObject

            AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: fetchDataAgain, success: {
                if accountObject.downloadState == .Downloaded {
                    self.accountBalanceLabel!.hidden = false
                    self.balanceActivityIndicatorView!.stopAnimating()
                    self.balanceActivityIndicatorView!.hidden = true
                    self._updateAccountBalanceView()
                    checkToRefreshAgain()
                }
            })
            
        } else if (AppDelegate.instance().godSend!.getSelectedObjectType() == .Address) {
            let importedAddress = AppDelegate.instance().godSend!.getSelectedSendObject() as! TLImportedAddress
            AppDelegate.instance().pendingOperations.addSetUpImportedAddressOperation(importedAddress, fetchDataAgain: fetchDataAgain, success: {
                if importedAddress.downloadState == .Downloaded {
                    self.accountBalanceLabel!.hidden = false
                    self.balanceActivityIndicatorView!.stopAnimating()
                    self.balanceActivityIndicatorView!.hidden = true
                    self._updateAccountBalanceView()
                    checkToRefreshAgain()
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
        TLSendFormData.instance().setAmount("0")
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

    func hideHudAndRefreshSendAccount() {
        if self.isShowingSendHUD == true {
            TLHUDWrapper.hideHUDForView(self.view, animated: true)
            self.isShowingSendHUD = false
            self.refreshAccountDataAndSetBalanceView(true)
            AppDelegate.instance().listeningToToAddress = nil
            AppDelegate.instance().inputedToAmount = nil
        }
    }
    
    func setSendingHUDHidden(hidden: Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            if hidden {
                TLHUDWrapper.hideHUDForView(self.view, animated: true)
                self.isShowingSendHUD = false
                NSObject.cancelPreviousPerformRequestsWithTarget(self, selector:"hideHudAndRefreshSendAccount", object:nil)
            } else {
                TLHUDWrapper.showHUDAddedTo(self.slidingViewController().topViewController.view, labelText: "Sending".localized, animated: true)
                self.isShowingSendHUD = true
                
                // relying on websocket to know when a payment has been sent can be unreliable, so cancel after a certain time
                let TIME_TO_WAIT_TO_HIDE_HUD_AND_REFRESH_ACCOUNT = 13.0
                NSTimer.scheduledTimerWithTimeInterval(TIME_TO_WAIT_TO_HIDE_HUD_AND_REFRESH_ACCOUNT, target: self,
                    selector: Selector("hideHudAndRefreshSendAccount"), userInfo: nil, repeats: false)
            }
        }
    }
    
    func hideHUDAndUpdateBalanceView() {
        self.accountBalanceLabel!.hidden = false
        self.balanceActivityIndicatorView!.stopAnimating()
        self.balanceActivityIndicatorView!.hidden = true
        self.setSendingHUDHidden(true)
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
    
    private func showPromptForTxFee() {
        func addTextField(textField: UITextField!){
            textField.text = "0"
            textField.keyboardType = .DecimalPad
        }
        
        UIAlertController.showAlertInViewController(self,
            withTitle: "Transaction Fee".localized,
            message: String(format: "Input desired transaction fee in %@ %@".localized, TLCurrencyFormat.getBitcoinDisplayWord(), TLCurrencyFormat.getBitcoinDisplay()),
            preferredStyle: .Alert,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Next".localized],
            preShowBlock: {(controller:UIAlertController!) in
                controller.addTextFieldWithConfigurationHandler(addTextField)
            },
            tapBlock: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    let feeAmount = (alertView.textFields![0] ).text
                    let feeAmountCoin = TLCurrencyFormat.properBitcoinAmountStringToCoin(feeAmount!)
                    self.showPromptReviewTx(feeAmountCoin)
                } else if (buttonIndex == alertView.cancelButtonIndex) {
                }
        })
    }
    
    private func showFinalPromptReviewTx(feeAmount: TLCoin) {
        let bitcoinAmount = self.amountTextField!.text
        let fiatAmount = self.fiatAmountTextField!.text
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
        
        let amountNeeded = inputtedAmount.add(feeAmount)
        let sendFromBalance = AppDelegate.instance().godSend!.getCurrentFromBalance()
        if (amountNeeded.greater(sendFromBalance)) {
            let msg = String(format: "You have %@ %@, but %@ is needed. (This includes the transactions fee)".localized, TLCurrencyFormat.coinToProperBitcoinAmountString(sendFromBalance), TLCurrencyFormat.getBitcoinDisplay(), TLCurrencyFormat.coinToProperBitcoinAmountString(amountNeeded))
            TLPrompts.promptErrorMessage("Insufficient Balance".localized, message: msg)
            return
        }
        
        let bitcoinDisplay = TLCurrencyFormat.getBitcoinDisplay()
        let currency = TLCurrencyFormat.getFiatCurrency()
        
        let feeAmountDisplay = TLCurrencyFormat.coinToProperBitcoinAmountString(feeAmount)
        
        let txSummary = String(format: "To: %@\nAmount:\n%@ %@\n%@ %@\nfee: %@ %@".localized, toAddress!, bitcoinAmount!, bitcoinDisplay, fiatAmount!, currency, feeAmountDisplay, bitcoinDisplay)
        
        UIAlertController.showAlertInViewController(self,
            withTitle: "Transaction Summary".localized,
            message:txSummary,
            preferredStyle: .Alert,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Send".localized],
            
            preShowBlock: {(controller:UIAlertController!) in
                if(controller.textFields != nil)
                {
                    for v in controller.textFields! {
                        if (v is UILabel) {
                            let label = v as! UILabel
                            label.textAlignment = .Left
                        }
                    }
                    
                }
            },
            tapBlock: {(alertView, action, buttonIndex) in
            
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    self.setSendingHUDHidden(false)

                    AppDelegate.instance().godSend!.getAndSetUnspentOutputs({
                        () in
                        
                        
                        let unspentOutputsSum = AppDelegate.instance().godSend!.getCurrentFromUnspentOutputsSum()
                        if (unspentOutputsSum.less(inputtedAmount)) {
                            // can only happen if unspentOutputsSum is for some reason less then the balance computed from the transactions, which it shouldn't
                            self.setSendingHUDHidden(true)
                            let unspentOutputsSumString = TLCurrencyFormat.coinToProperBitcoinAmountString(unspentOutputsSum)
                            TLPrompts.promptErrorMessage("Error: Insufficient Funds".localized, message: String(format: "Account only has a balance of %@ %@".localized, unspentOutputsSumString, TLCurrencyFormat.getBitcoinDisplay()))
                            return
                        }
                        
                        let toAddressesAndAmount = NSMutableDictionary()
                        toAddressesAndAmount.setObject(toAddress!, forKey: "address")
                        toAddressesAndAmount.setObject(inputtedAmount, forKey: "amount")
                        let toAddressesAndAmounts = NSArray(objects: toAddressesAndAmount)
                        let ret = AppDelegate.instance().godSend!.createSignedSerializedTransactionHex(toAddressesAndAmounts,
                            feeAmount: feeAmount,
                            error: {
                                (data: String?) in
                                self.setSendingHUDHidden(true)
                                TLPrompts.promptErrorMessage("Error".localized, message: data! ?? "")
                        })

                        let txHexAndTxHash = ret.0
                        let realToAddress = ret.1

                        if txHexAndTxHash == nil {
                            return
                        }
                        let txHex = txHexAndTxHash!.objectForKey("txHex") as? String
                        
                        if (txHex == nil) {
                            //should not reach here, because I check sum of unspent outputs already,
                            // unless unspent outputs contains dust and are require to filled the amount I want to send
                            self.setSendingHUDHidden(true)
                            return
                        }
                        
                        let txHash = txHexAndTxHash!.objectForKey("txHash") as? String
                        
                        if(txHex != nil) {
                            DLog("showPromptReviewTx txHex: %@", function: txHex!)
                        }
                        if(txHash != nil) {
                            DLog("showPromptReviewTx txHash: %@", function: txHash!)
                        }
                        
                        if (toAddress == AppDelegate.instance().godSend!.getStealthAddress()) {
                            AppDelegate.instance().pendingSelfStealthPaymentTxid = txHash
                        }
                        
                        for address in realToAddress {
                            TLTransactionListener.instance().listenToIncomingTransactionForAddress(address)
                            AppDelegate.instance().listeningToToAddress = address
                        }
                        
                        self.beforeSendBalance = AppDelegate.instance().godSend!.getCurrentFromBalance()
                        AppDelegate.instance().inputedToAddress = toAddress
                        AppDelegate.instance().inputedToAmount = inputtedAmount
                        
                        let handlePushTxSuccess = { () -> () in
                            AppDelegate.instance().doHiddenPresentAndDimissTransparentViewController = true
                            
                            self._clearSendForm()
                            
                            NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_SEND_PAYMENT(),
                                object: nil, userInfo: nil)
                        }

                        TLPushTxAPI.instance().sendTx(txHex!, txHash: txHash!, toAddress: toAddress!, success: {
                            (jsonData: AnyObject!) in
                            DLog("showPromptReviewTx pushTx: success %@", function: jsonData)

                            if TLStealthAddress.isStealthAddress(toAddress!, isTestnet:false) == true {
                                // doing stealth payment with push tx insight get wrong hash back??
                                let txid = (jsonData as! NSDictionary).objectForKey("txid") as! String
                                DLog("showPromptReviewTx pushTx: success txid %@", function: txid)
                                DLog("showPromptReviewTx pushTx: success txHash %@", function: txHash!)
                                if txid != txHash! {
                                    NSException(name: "API Error", reason:"txid return does not match txid in app", userInfo:nil).raise()
                                }
                            }
                            
                            if let label = AppDelegate.instance().appWallet.getLabelForAddress(toAddress!) {
                                AppDelegate.instance().appWallet.setTransactionTag(txHash!, tag: label)
                            }
                            handlePushTxSuccess()
                            
                        }, failure: {
                            (code: Int, status: String!) in
                            DLog("showPromptReviewTx pushTx: failure \(code) \(status)")
                            if (code == 200) {
                                handlePushTxSuccess()
                            } else {
                                TLPrompts.promptErrorMessage("Error".localized, message: status)
                            }
                            self.setSendingHUDHidden(true)
                        })
                    }, failure: {
                            () in
                        self._clearSendForm()
                        self.setSendingHUDHidden(true)
                        self.refreshAccountDataAndSetBalanceView(true)
                        TLPrompts.promptErrorMessage("Error".localized, message: "Bitcoins has already been spent.")
                    })
                } else if (buttonIndex == alertView.cancelButtonIndex) {
                }
        })
    }
    
    private func handleTempararyImportPrivateKey(privateKey: String, feeAmount: TLCoin) {
        if (!TLCoreBitcoinWrapper.isValidPrivateKey(privateKey, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)) {
            TLPrompts.promptErrorMessage("Error".localized, message: "Invalid private key".localized)
        } else {
            let importedAddress = AppDelegate.instance().godSend!.getSelectedSendObject() as! TLImportedAddress?
            let success = importedAddress!.setPrivateKeyInMemory(privateKey)
            if (!success) {
                TLPrompts.promptSuccessMessage("Error".localized, message: "Private key does not match imported address".localized)
            } else {
                self.showFinalPromptReviewTx(feeAmount)
            }
        }
    }
    
    private func showPromptReviewTx(feeAmount: TLCoin) {
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
                        self.showFinalPromptReviewTx(feeAmount)
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
                        self.handleTempararyImportPrivateKey(privKey, feeAmount: feeAmount)
                        }, failure: {
                            (isCanceled: Bool) in
                    })
                } else {
                    if AppDelegate.instance().scannedEncryptedPrivateKey == nil {
                        self.handleTempararyImportPrivateKey(data, feeAmount: feeAmount)
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
                    self.showFinalPromptReviewTx(feeAmount)
                }
                }, failure: {
                    (isCanceled: Bool) in
            })
        } else {
            self.showFinalPromptReviewTx(feeAmount)
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
        if (!TLPreferences.isAutomaticFee()) {
            self.showPromptForTxFee()
        } else {
            let feeAmount = TLPreferences.getInAppSettingsKitTransactionFee()
            self.showPromptReviewTx(TLCurrencyFormat.bitcoinAmountStringToCoin(feeAmount!))
        }
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
    
    @IBAction private func updateFiatAmountTextFieldExchangeRate(sender: AnyObject?) {
        let currency = TLCurrencyFormat.getFiatCurrency()
        let amount = TLCurrencyFormat.properBitcoinAmountStringToCoin(self.amountTextField!.text!)

        if (amount.greater(TLCoin.zero())) {
            self.fiatAmountTextField!.text = TLExchangeRate.instance().fiatAmountStringFromBitcoin(currency,
                bitcoinAmount: amount)
        } else {
            self.fiatAmountTextField!.text = "0"
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
        } else {
            self.amountTextField!.text = "0"
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
        } else if (textField == self.fiatAmountTextField) {
            TLSendFormData.instance().setFiatAmount(newString)
            TLSendFormData.instance().setAmount(nil)
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if (self.tapGesture == nil) {
            self.tapGesture = UITapGestureRecognizer(target: self,
                action: "dismissKeyboard")
            
            self.view.addGestureRecognizer(self.tapGesture!)
        }
        
        if textField != self.toAddressTextField && TLPreferences.isAutomaticFee() {
            self.setAllCoinsBarButton()
        }
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


