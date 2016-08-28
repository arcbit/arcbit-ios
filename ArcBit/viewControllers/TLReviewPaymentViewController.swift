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

@objc(TLReviewPaymentViewController) class TLReviewPaymentViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var navigationBar:UINavigationBar?
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var toAmountLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var toAmountFiatLabel: UILabel!
    @IBOutlet weak var feeAmountFiatLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var totalFiatAmountLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    override func preferredStatusBarStyle() -> (UIStatusBarStyle) {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarColors(self.navigationBar!)
        self.sendButton.backgroundColor = TLColors.mainAppColor()
        self.sendButton.setTitleColor(TLColors.mainAppOppositeColor(), forState: .Normal)
        updateView()
    }

    func updateView() {
        self.fromLabel.text = TLSendFormData.instance().fromLabel
        self.toLabel.text = TLSendFormData.instance().getAddress()
        self.toAmountLabel.text = TLCurrencyFormat.coinToProperBitcoinAmountString(TLSendFormData.instance().toAmount!, withCode: true)
        self.toAmountFiatLabel.text = TLCurrencyFormat.coinToProperFiatAmountString(TLSendFormData.instance().toAmount!, withCode: true)
        self.feeAmountLabel.text = TLCurrencyFormat.coinToProperBitcoinAmountString(TLSendFormData.instance().feeAmount!, withCode: true)
        self.feeAmountFiatLabel.text = TLCurrencyFormat.coinToProperFiatAmountString(TLSendFormData.instance().feeAmount!, withCode: true)
        let total = TLSendFormData.instance().toAmount?.add(TLSendFormData.instance().feeAmount!)
        self.totalAmountLabel.text = TLCurrencyFormat.coinToProperBitcoinAmountString(total!, withCode: true)
        self.totalFiatAmountLabel.text = TLCurrencyFormat.coinToProperFiatAmountString(total!, withCode: true)
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
                                                            let feeAmountString = (alertView.textFields![0] ).text
                                                            
                                                            let feeAmount = TLCurrencyFormat.properBitcoinAmountStringToCoin(feeAmountString!)
                                                            
                                                            let amountNeeded = TLSendFormData.instance().toAmount!.add(feeAmount)
                                                            let sendFromBalance = AppDelegate.instance().godSend!.getCurrentFromBalance()
                                                            if (amountNeeded.greater(sendFromBalance)) {
                                                                TLPrompts.promptErrorMessage("Insufficient Balance".localized, message: "Your new transaction fee is too high")
                                                                return
                                                            }
                                                            
                                                            if (!TLWalletUtils.isTransactionFeeToLow(feeAmount)) {
                                                                let msg = String(format: "Too low a transaction fee can cause transactions to take a long time to confirm. Continue anyways?".localized)
                                                                
                                                                TLPrompts.promtForOKCancel(self, title: "Non-recommended Amount Transaction Fee".localized, message: msg, success: {
                                                                    () in
                                                                    TLSendFormData.instance().feeAmount = feeAmount
                                                                    self.updateView()
                                                                    }, failure: {
                                                                        (isCancelled: Bool) in
                                                                        self.showPromptForSetTransactionFee()
                                                                })
                                                            } else if (!TLWalletUtils.isTransactionFeeToHigh(feeAmount)) {
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
    
    @IBAction func customizeFeeButtonClicked(sender: AnyObject) {
        showPromptForSetTransactionFee()
    }
    
    @IBAction func feeInfoButtonClicked(sender: AnyObject) {
        TLPrompts.promptSuccessMessage("Transaction Fees", message: "Transaction fees impact how quickly the Bitcoin mining network will confirm your transactions, and depend on the current network conditions.")
    }
    
    @IBAction func sendButtonClicked(sender: AnyObject) {
        
    }

    @IBAction private func cancel(sender:AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
}
