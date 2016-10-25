//
//  TLReviewPaymentViewController.swift
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

import Foundation
import UIKit
import AVFoundation

@objc(TLReviewPaymentViewController) class TLReviewPaymentViewController: UIViewController, CustomIOS7AlertViewDelegate {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var navigationBar:UINavigationBar?
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var fiatUnitLabel: UILabel!
    @IBOutlet weak var toAmountLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var toAmountFiatLabel: UILabel!
    @IBOutlet weak var feeAmountFiatLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var totalFiatAmountLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    private lazy var showedPromptedForSentPaymentTxHashSet:NSMutableSet = NSMutableSet()
    private var QRImageModal: TLQRImageModal?
    private var airGapDataBase64PartsArray: Array<String>?
    var sendTimer:NSTimer?
    var sendTxHash:String?
    var inputedToAddress: String? = nil
    var inputedToAmount: TLCoin? = nil
    var amountMovedFromAccount: TLCoin? = nil

    override func preferredStatusBarStyle() -> (UIStatusBarStyle) {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarColors(self.navigationBar!)
        self.sendButton.backgroundColor = TLColors.mainAppColor()
        self.sendButton.setTitleColor(TLColors.mainAppOppositeColor(), forState: .Normal)
        NSNotificationCenter.defaultCenter().addObserver(self
            ,selector:#selector(TLReviewPaymentViewController.finishSend(_:)),
             name:TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_UNCONFIRMED_TRANSACTION(), object:nil)
        updateView()
    }
    
    func updateView() {
        self.fromLabel.text = TLSendFormData.instance().fromLabel
        self.toLabel.text = TLSendFormData.instance().getAddress()
        self.unitLabel.text = TLCurrencyFormat.getBitcoinDisplay()
        self.fiatUnitLabel.text = TLCurrencyFormat.getFiatCurrency()
        self.toAmountLabel.text = TLCurrencyFormat.coinToProperBitcoinAmountString(TLSendFormData.instance().toAmount!, withCode: false)
        self.toAmountFiatLabel.text = TLCurrencyFormat.coinToProperFiatAmountString(TLSendFormData.instance().toAmount!, withCode: false)
        self.feeAmountLabel.text = TLCurrencyFormat.coinToProperBitcoinAmountString(TLSendFormData.instance().feeAmount!, withCode: false)
        self.feeAmountFiatLabel.text = TLCurrencyFormat.coinToProperFiatAmountString(TLSendFormData.instance().feeAmount!, withCode: false)
        let total = TLSendFormData.instance().toAmount!.add(TLSendFormData.instance().feeAmount!)
        self.totalAmountLabel.text = TLCurrencyFormat.coinToProperBitcoinAmountString(total, withCode: false)
        self.totalFiatAmountLabel.text = TLCurrencyFormat.coinToProperFiatAmountString(total, withCode: false)
    }
    
    private func showPromptForSetTransactionFee() {
        let msg = String(format: "Input your custom fee in %@", TLCurrencyFormat.getBitcoinDisplay())
        
        func addTextField(textField: UITextField!){
            textField.placeholder = "fee amount".localized
            textField.keyboardType = .DecimalPad
        }
        
        UIAlertController.showAlertInViewController(self,
                                                    withTitle: "Transaction Fee".localized,
                                                    
                                                    message: msg,
                                                    preferredStyle: .Alert,
                                                    cancelButtonTitle: "Cancel".localized,
                                                    destructiveButtonTitle: nil,
                                                    otherButtonTitles: ["OK".localized],
                                                    
                                                    preShowBlock: {(controller:UIAlertController!) in
                                                        controller.addTextFieldWithConfigurationHandler(addTextField)
            }
            ,
                                                    tapBlock: {(alertView, action, buttonIndex) in
                                                        if (buttonIndex == alertView.firstOtherButtonIndex) {
                                                            let feeAmountString = (alertView.textFields![0]).text
                                                            
                                                            let feeAmount = TLCurrencyFormat.properBitcoinAmountStringToCoin(feeAmountString!)
                                                            
                                                            let amountNeeded = TLSendFormData.instance().toAmount!.add(feeAmount)
                                                            let sendFromBalance = AppDelegate.instance().godSend!.getCurrentFromBalance()
                                                            if (amountNeeded.greater(sendFromBalance)) {
                                                                TLPrompts.promptErrorMessage("Insufficient Balance".localized, message: "Your new transaction fee is too high")
                                                                return
                                                            }
                                                            
                                                            if (TLWalletUtils.isTransactionFeeTooLow(feeAmount)) {
                                                                let msg = String(format: "Too low a transaction fee can cause transactions to take a long time to confirm. Continue anyways?".localized)
                                                                
                                                                TLPrompts.promtForOKCancel(self, title: "Non-recommended Amount Transaction Fee".localized, message: msg, success: {
                                                                    () in
                                                                    TLSendFormData.instance().feeAmount = feeAmount
                                                                    self.updateView()
                                                                    }, failure: {
                                                                        (isCancelled: Bool) in
                                                                        self.showPromptForSetTransactionFee()
                                                                })
                                                            } else if (TLWalletUtils.isTransactionFeeTooHigh(feeAmount)) {
                                                                let msg = String(format: "Your transaction fee is very high. Continue anyways?".localized)
                                                                
                                                                TLPrompts.promtForOKCancel(self, title: "Non-recommended Amount Transaction Fee".localized, message: msg, success: {
                                                                    () in
                                                                    TLSendFormData.instance().feeAmount = feeAmount
                                                                    self.updateView()
                                                                    }, failure: {
                                                                        (isCancelled: Bool) in
                                                                        self.showPromptForSetTransactionFee()
                                                                })
                                                            } else {
                                                                TLSendFormData.instance().feeAmount = feeAmount
                                                                self.updateView()
                                                            }
                                                        } else if (buttonIndex == alertView.cancelButtonIndex) {
                                                        }
        })
    }

    func showPromptPaymentSent(txHash: String, address: String, amount: TLCoin) {
        self.inputedToAddress = nil
        self.inputedToAmount = nil
        DLog("showPromptPaymentSent \(txHash)")
        let msg = String(format:"Sent %@ to %@".localized, TLCurrencyFormat.getProperAmount(amount), address)
        TLHUDWrapper.hideHUDForView(self.view, animated: true)
        TLPrompts.promtForOK(self, title: "", message: msg, success: {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func cancelSend() {
        sendTimer?.invalidate()
        TLHUDWrapper.hideHUDForView(self.view, animated: true)
    }

    func retryFinishSend() {
        DLog("retryFinishSend \(self.sendTxHash)")
        if !AppDelegate.instance().webSocketNotifiedTxHashSet.containsObject(self.sendTxHash!) {
            let nonUpdatedBalance = AppDelegate.instance().godSend!.getCurrentFromBalance()
            let accountNewBalance = nonUpdatedBalance.subtract(self.amountMovedFromAccount!)
            DLog("retryFinishSend 2 \(self.sendTxHash)")
            AppDelegate.instance().godSend!.setCurrentFromBalance(accountNewBalance)
        }

        if !self.showedPromptedForSentPaymentTxHashSet.containsObject(self.sendTxHash!) {
            self.showedPromptedForSentPaymentTxHashSet.addObject(self.sendTxHash!)
            self.showPromptPaymentSent(self.sendTxHash!, address: inputedToAddress!, amount: inputedToAmount!)
        }
    }
    
    func finishSend(note: NSNotification) {
        let webSocketNotifiedTxHash = note.object as? String
        DLog("finishSend \(webSocketNotifiedTxHash)")
        if webSocketNotifiedTxHash! == self.sendTxHash! && !self.showedPromptedForSentPaymentTxHashSet.containsObject(webSocketNotifiedTxHash!) {
            DLog("finishSend 2 \(webSocketNotifiedTxHash)")
            self.showedPromptedForSentPaymentTxHashSet.addObject(webSocketNotifiedTxHash!)
            sendTimer?.invalidate()
            self.showPromptPaymentSent(webSocketNotifiedTxHash!, address: inputedToAddress!, amount: inputedToAmount!)
        }
    }

    func initiateSend() {
        let inputtedAmount = TLSendFormData.instance().toAmount!
        let feeAmount = TLSendFormData.instance().feeAmount!
        let toAddress = TLSendFormData.instance().getAddress()
        
        let unspentOutputsSum = AppDelegate.instance().godSend!.getCurrentFromUnspentOutputsSum()
        if (unspentOutputsSum.less(inputtedAmount)) {
            // can only happen if unspentOutputsSum is for some reason less then the balance computed from the transactions, which it shouldn't
            cancelSend()
            let unspentOutputsSumString = TLCurrencyFormat.coinToProperBitcoinAmountString(unspentOutputsSum)
            TLPrompts.promptErrorMessage("Error: Insufficient Funds".localized, message: String(format: "Some funds may be pending confirmation and cannot be spent yet. (Check your account history) Account only has a spendable balance of %@ %@".localized, unspentOutputsSumString, TLCurrencyFormat.getBitcoinDisplay()))
            return
        }
        
        let toAddressesAndAmount = NSMutableDictionary()
        toAddressesAndAmount.setObject(toAddress!, forKey: "address")
        toAddressesAndAmount.setObject(inputtedAmount, forKey: "amount")
        let toAddressesAndAmounts = NSArray(objects: toAddressesAndAmount)
        
        let signTx = !AppDelegate.instance().godSend!.isColdWalletAccount()
        let ret = AppDelegate.instance().godSend!.createSignedSerializedTransactionHex(toAddressesAndAmounts,
                                                                                       feeAmount: feeAmount,
                                                                                       signTx: signTx,
                                                                                       error: {
                                                                                        (data: String?) in
                                                                                        self.cancelSend()
                                                                                        TLPrompts.promptErrorMessage("Error".localized, message: data! ?? "")
        })
        
        let txHexAndTxHash = ret.0
        let realToAddress = ret.1
        
        if txHexAndTxHash == nil {
            cancelSend()
            return
        }
        
        let txHex = txHexAndTxHash!.objectForKey("txHex") as? String
        
        if (txHex == nil) {
            //should not reach here, because I check sum of unspent outputs already,
            // unless unspent outputs contains dust and are require to filled the amount I want to send
            cancelSend()
            return
        }
        
        if AppDelegate.instance().godSend!.isColdWalletAccount() {
            cancelSend()
            let txInputsAccountHDIdxes = ret.2
            self.promptToSignTransaction(txHex!, txInputsAccountHDIdxes:txInputsAccountHDIdxes!)
            return;
        }
        
        let txHash = txHexAndTxHash!.objectForKey("txHash") as? String
        
        
        if (toAddress == AppDelegate.instance().godSend!.getStealthAddress()) {
            AppDelegate.instance().pendingSelfStealthPaymentTxid = txHash
        }
        
        if AppDelegate.instance().godSend!.isPaymentToOwnAccount(toAddress!) {
            self.amountMovedFromAccount = feeAmount
        } else {
            self.amountMovedFromAccount = inputtedAmount.add(feeAmount)
        }
        
        for address in realToAddress {
            TLTransactionListener.instance().listenToIncomingTransactionForAddress(address)
        }
        
        TLSendFormData.instance().beforeSendBalance = AppDelegate.instance().godSend!.getCurrentFromBalance()
        self.inputedToAddress = toAddress
        self.inputedToAmount = inputtedAmount
        self.sendTxHash = txHash
        DLog("showPromptReviewTx txHex: \(txHex)")
        DLog("showPromptReviewTx txHash: \(txHash)")
        broadcastTx(txHex!, txHash: txHash!, toAddress: toAddress!)
    }

    func broadcastTx(txHex: String, txHash: String, toAddress: String) {
        let handlePushTxSuccess = { () -> () in
            NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_SEND_PAYMENT(),
                                                                      object: nil, userInfo: nil)
        }
        
        TLPushTxAPI.instance().sendTx(txHex, txHash: txHash, toAddress: toAddress, success: {
            (jsonData: AnyObject!) in
            DLog("showPromptReviewTx pushTx: success %@", function: jsonData)
            
            if TLStealthAddress.isStealthAddress(toAddress, isTestnet:false) == true {
                // doing stealth payment with push tx insight get wrong hash back??
                let txid = (jsonData as! NSDictionary).objectForKey("txid") as! String
                DLog("showPromptReviewTx pushTx: success txid %@", function: txid)
                DLog("showPromptReviewTx pushTx: success txHash %@", function: txHash)
                if txid != txHash {
                    NSException(name: "API Error", reason:"txid return does not match txid in app", userInfo:nil).raise()
                }
            }
            
            if let label = AppDelegate.instance().appWallet.getLabelForAddress(toAddress) {
                AppDelegate.instance().appWallet.setTransactionTag(txHash, tag: label)
            }
            handlePushTxSuccess()
            
            }, failure: {
                (code: Int, status: String!) in
                DLog("showPromptReviewTx pushTx: failure \(code) \(status)")
                if (code == 200) {
                    handlePushTxSuccess()
                } else {
                    TLPrompts.promptErrorMessage("Error".localized, message: status)
                    self.cancelSend()
                }
        })
    }

    func promptToSignTransaction(unSignedTx: String, txInputsAccountHDIdxes:NSArray) {
        let extendedPublicKey = AppDelegate.instance().godSend!.getExtendedPubKey()
        if let airGapDataBase64 = TLColdWallet.createSerializedAipGapData(unSignedTx, extendedPublicKey: extendedPublicKey!, txInputsAccountHDIdxes: txInputsAccountHDIdxes) {
            DLog("airGapDataBase64 0000 \(airGapDataBase64)")
            self.airGapDataBase64PartsArray = TLColdWallet.splitStringToAray(airGapDataBase64)
            DLog("airGapDataBase64PartsArray \(airGapDataBase64PartsArray)")

            
            let signedAirGapData = TLColdWallet.createSignedAipGapData(airGapDataBase64, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)
            
            TLPrompts.promtForOKCancel(self, title: "Spending from a cold wallet account".localized, message: "Transaction needs to be authorize by an offline and airgap device. Send transaction to an offline device for authorization?", success: {
                () in
                
                let firstAipGapDataPart = self.airGapDataBase64PartsArray![0]
                self.airGapDataBase64PartsArray!.removeAtIndex(0)
                self.QRImageModal = TLQRImageModal(data: firstAipGapDataPart, buttonCopyText: "Next".localized, vc: self)
                self.QRImageModal!.show()
                
                }, failure: {
                    (isCancelled: Bool) in
            })
        }
    }
    
    @IBAction func customizeFeeButtonClicked(sender: AnyObject) {
        showPromptForSetTransactionFee()
    }
    
    @IBAction func feeInfoButtonClicked(sender: AnyObject) {
        TLPrompts.promptSuccessMessage("Transaction Fees", message: "Transaction fees impact how quickly the Bitcoin mining network will confirm your transactions, and depend on the current network conditions.")
    }
    
    @IBAction func sendButtonClicked(sender: AnyObject) {
        TLHUDWrapper.showHUDAddedTo(self.view, labelText: "Sending".localized, animated: true)
        // relying on websocket to know when a payment has been sent can be unreliable, so cancel after a certain time
        let TIME_TO_WAIT_TO_HIDE_HUD_AND_REFRESH_ACCOUNT = 13.0
        sendTimer = NSTimer.scheduledTimerWithTimeInterval(TIME_TO_WAIT_TO_HIDE_HUD_AND_REFRESH_ACCOUNT, target: self,
                                               selector: #selector(retryFinishSend), userInfo: nil, repeats: false)

        if !AppDelegate.instance().godSend!.haveUpDatedUTXOs() {
            AppDelegate.instance().godSend!.getAndSetUnspentOutputs({
                self.initiateSend()
                }, failure: {
                    self.cancelSend()
                    TLPrompts.promptErrorMessage("Error".localized, message: "Error fetching unspent outputs. Try again.".localized)
            })
        } else {
            self.initiateSend()
        }
    }

    @IBAction private func cancel(sender:AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func customIOS7dialogButtonTouchUpInside(alertView: AnyObject, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == 0) {
            if self.airGapDataBase64PartsArray?.count > 0 {
                let nextAipGapDataPart = self.airGapDataBase64PartsArray![0]
                self.airGapDataBase64PartsArray!.removeAtIndex(0)
                self.QRImageModal = TLQRImageModal(data: nextAipGapDataPart, buttonCopyText: "Next".localized, vc: self)
                self.QRImageModal!.show()
            } else {
                TLPrompts.promptAlertController(self, title: "Finished Passing Transaction Data".localized,
                                                message: "Now authorize the transaction on your air gap device. When you have done so click continue on this device to scan the authorized transaction data and make your payment.".localized,
                                                okText: "Continue".localized, cancelTx: "Cancel".localized, success: {
                                                    () in

                    
                    }, failure: {
                        (isCancelled: Bool) in
                })
            }
        }
        
        alertView.close()
    }
}
