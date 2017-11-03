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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc(TLReviewPaymentViewController) class TLReviewPaymentViewController: UIViewController, CustomIOS7AlertViewDelegate {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var navigationBar:UINavigationBar?
    
    @IBOutlet weak var fromTitleLabel: UILabel!
    @IBOutlet weak var toTitleLabel: UILabel!
    @IBOutlet weak var toAmountTitleLabel: UILabel!
    @IBOutlet weak var feeAmountTitleLabel: UILabel!
    @IBOutlet weak var totalAmountTitleLabel: UILabel!

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
    @IBOutlet weak var customizeFeeButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    weak var reviewPaymentViewController: TLReviewPaymentViewController?
    fileprivate lazy var showedPromptedForSentPaymentTxHashSet:NSMutableSet = NSMutableSet()
    fileprivate var QRImageModal: TLQRImageModal?
    fileprivate var airGapDataBase64PartsArray: Array<String>?
    var sendTimer:Timer?
    var sendTxHash:String?
    var toAddress:String?
    var toAmount:TLCoin?
    var amountMovedFromAccount: TLCoin? = nil
    var realToAddresses: Array<String>? = nil
    

    
    private var scannedSignedTxAirGapDataPartsDict = [Int:String]()
    private var totalExpectedParts:Int = 0
    private var scannedSignedTxAirGapData:String? = nil
    
    private var shouldPromptToScanSignedTxAirGapData = false
    private var shouldPromptToBroadcastSignedTx = false
    private var signedAirGapTxHex:String? = nil
    private var signedAirGapTxHash:String? = nil
    
    
    
    override var preferredStatusBarStyle : (UIStatusBarStyle) {
        return UIStatusBarStyle.lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarColors(self.navigationBar!)
        
        self.navigationBar?.topItem?.title = TLDisplayStrings.CONFIRM_PAYMENT_STRING()
        self.fromTitleLabel.text = TLDisplayStrings.FROM_COLON_STRING()
        self.toTitleLabel.text = TLDisplayStrings.TO_COLON_STRING()
        self.toAmountTitleLabel.text = TLDisplayStrings.AMOUNT_COLON_STRING()
        self.feeAmountTitleLabel.text = TLDisplayStrings.FEE_COLON_STRING()
        self.totalAmountTitleLabel.text = TLDisplayStrings.TOTAL_COLON_STRING()

        self.customizeFeeButton.setTitle(TLDisplayStrings.CUSTOMIZE_FEE_STRING(), for: .normal)
        self.sendButton.setTitle(TLDisplayStrings.SEND_STRING(), for: .normal)
        
        self.sendButton.backgroundColor = TLColors.mainAppColor()
        self.sendButton.setTitleColor(TLColors.mainAppOppositeColor(), for: UIControlState())
        NotificationCenter.default.addObserver(self
            ,selector:#selector(TLReviewPaymentViewController.finishSend(_:)),
             name:NSNotification.Name(rawValue: TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_UNCONFIRMED_TRANSACTION()), object:nil)
        updateView()
        self.reviewPaymentViewController = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.shouldPromptToScanSignedTxAirGapData {
            self.promptToScanSignedTxAirGapData()
        } else if self.shouldPromptToBroadcastSignedTx {
            self.shouldPromptToBroadcastSignedTx = false
            self.promptToBroadcastColdWalletAccountSignedTx(self.signedAirGapTxHex!, txHash: self.signedAirGapTxHash!)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if (!TLPreferences.disabledShowFeeExplanationInfo()) {
            TLPrompts.promptSuccessMessage(TLDisplayStrings.TRANSACTION_FEE_STRING(), message: TLDisplayStrings.FEE_INFO_DESC_STRING())
            TLPreferences.setDisableShowFeeExplanationInfo(true);
        }
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
    
    fileprivate func showPromptForSetTransactionFee() {
        let msg = String(format: TLDisplayStrings.SET_TRANSACTION_FEE_IN_X_STRING(), TLCurrencyFormat.getBitcoinDisplay())

        func addTextField(_ textField: UITextField!){
            textField.placeholder = ""
            textField.keyboardType = .decimalPad
        }
        
        UIAlertController.showAlert(in: self,
                                                    withTitle: TLDisplayStrings.TRANSACTION_FEE_STRING(),
                                                    
                                                    message: msg,
                                                    preferredStyle: .alert,
                                                    cancelButtonTitle: TLDisplayStrings.CANCEL_STRING(),
                                                    destructiveButtonTitle: nil,
                                                    otherButtonTitles: [TLDisplayStrings.OK_STRING()],
                                                    
                                                    preShow: {(controller) in
                                                        controller!.addTextField(configurationHandler: addTextField)
            }
            ,
                                                    tap: {(alertView, action, buttonIndex) in
                                                        if (buttonIndex == alertView!.firstOtherButtonIndex) {
                                                            let feeAmountString = (alertView!.textFields![0]).text
                                                            
                                                            let feeAmount = TLCurrencyFormat.properBitcoinAmountStringToCoin(feeAmountString!)
                                                            
                                                            let amountNeeded = TLSendFormData.instance().toAmount!.add(feeAmount)
                                                            let sendFromBalance = AppDelegate.instance().godSend!.getCurrentFromBalance()
                                                            if (amountNeeded.greater(sendFromBalance)) {
                                                                TLPrompts.promptErrorMessage(TLDisplayStrings.INSUFFICIENT_FUNDS_STRING(), message: TLDisplayStrings.YOUR_NEW_TRANSACTION_FEE_IS_TOO_HIGH_STRING())
                                                                return
                                                            }
                                                            
                                                            TLSendFormData.instance().feeAmount = feeAmount
                                                            self.updateView()

                                                        } else if (buttonIndex == alertView!.cancelButtonIndex) {
                                                        }
        })
    }

    func showPromptPaymentSent(_ txHash: String, address: String, amount: TLCoin) {
        DLog("showPromptPaymentSent \(txHash)")
        let msg = String(format:TLDisplayStrings.SENT_X_TO_Y_STRING(), TLCurrencyFormat.getProperAmount(amount), address)
        TLHUDWrapper.hideHUDForView(self.view, animated: true)
        TLPrompts.promtForOK(self, title: "", message: msg, success: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func cancelSend() {
        sendTimer?.invalidate()
        TLHUDWrapper.hideHUDForView(self.view, animated: true)
    }

    func retryFinishSend() {
        DLog("retryFinishSend \(self.sendTxHash)")
        if !AppDelegate.instance().webSocketNotifiedTxHashSet.contains(self.sendTxHash!) {
            let nonUpdatedBalance = AppDelegate.instance().godSend!.getCurrentFromBalance()
            let accountNewBalance = nonUpdatedBalance.subtract(self.amountMovedFromAccount!)
            DLog("retryFinishSend 2 \(self.sendTxHash)")
            AppDelegate.instance().godSend!.setCurrentFromBalance(accountNewBalance)
        }

        if !self.showedPromptedForSentPaymentTxHashSet.contains(self.sendTxHash!) {
            self.showedPromptedForSentPaymentTxHashSet.add(self.sendTxHash!)
            self.showPromptPaymentSent(self.sendTxHash!, address: self.toAddress!, amount: self.toAmount!)
        }
    }
    
    func finishSend(_ note: Notification) {
        let webSocketNotifiedTxHash = note.object as? String
        DLog("finishSend \(webSocketNotifiedTxHash)")
        if webSocketNotifiedTxHash! == self.sendTxHash! && !self.showedPromptedForSentPaymentTxHashSet.contains(webSocketNotifiedTxHash!) {
            DLog("finishSend 2 \(webSocketNotifiedTxHash)")
            self.showedPromptedForSentPaymentTxHashSet.add(webSocketNotifiedTxHash!)
            sendTimer?.invalidate()
            self.showPromptPaymentSent(webSocketNotifiedTxHash!, address: self.toAddress!, amount: self.toAmount!)
        }
    }

    func initiateSend() {
        let unspentOutputsSum = AppDelegate.instance().godSend!.getCurrentFromUnspentOutputsSum()
        if (unspentOutputsSum.less(TLSendFormData.instance().toAmount!)) {
            // can only happen if unspentOutputsSum is for some reason less then the balance computed from the transactions, which it shouldn't
            cancelSend()
            let unspentOutputsSumString = TLCurrencyFormat.coinToProperBitcoinAmountString(unspentOutputsSum)
            TLPrompts.promptErrorMessage(TLDisplayStrings.INSUFFICIENT_FUNDS_STRING(), message: String(format: TLDisplayStrings.SOME_FUNDS_MAY_BE_PENDING_CONFIRMATION_DESC_STRING(), "\(unspentOutputsSumString) \(TLCurrencyFormat.getBitcoinDisplay())"))
            return
        }
        
        let toAddressesAndAmount = NSMutableDictionary()
        toAddressesAndAmount.setObject(TLSendFormData.instance().getAddress()!, forKey: "address" as NSCopying)
        toAddressesAndAmount.setObject(TLSendFormData.instance().toAmount!, forKey: "amount" as NSCopying)
        let toAddressesAndAmounts = NSArray(objects: toAddressesAndAmount)
        
        let signTx = !AppDelegate.instance().godSend!.isColdWalletAccount()
        let ret = AppDelegate.instance().godSend!.createSignedSerializedTransactionHex(toAddressesAndAmounts,
                                                                                       feeAmount: TLSendFormData.instance().feeAmount!,
                                                                                       signTx: signTx,
                                                                                       error: {
                                                                                        (data: String?) in
                                                                                        self.cancelSend()
                                                                                        TLPrompts.promptErrorMessage(TLDisplayStrings.ERROR_STRING(), message: data ?? "")
        })
        
        let txHexAndTxHash = ret.0
        self.realToAddresses = ret.1
        
        if txHexAndTxHash == nil {
            cancelSend()
            return
        }
        
        let txHex = txHexAndTxHash!.object(forKey: "txHex") as? String
        
        if (txHex == nil) {
            //should not reach here, because I check sum of unspent outputs already,
            // unless unspent outputs contains dust and are require to filled the amount I want to send
            cancelSend()
            return
        }
        
        if AppDelegate.instance().godSend!.isColdWalletAccount() {
            cancelSend()
            let txInputsAccountHDIdxes = ret.2
            let inputScripts = txHexAndTxHash!.object(forKey: "inputScripts") as! NSArray
            self.promptToSignTransaction(txHex!, inputScripts:inputScripts, txInputsAccountHDIdxes:txInputsAccountHDIdxes!)
            return;
        }
        let txHash = txHexAndTxHash!.object(forKey: "txHash") as? String
        prepAndBroadcastTx(txHex!, txHash: txHash!)
    }

    func prepAndBroadcastTx(_ txHex: String, txHash: String) {
        if (TLSendFormData.instance().getAddress() == AppDelegate.instance().godSend!.getStealthAddress()) {
            AppDelegate.instance().pendingSelfStealthPaymentTxid = txHash
        }
        
        if AppDelegate.instance().godSend!.isPaymentToOwnAccount(TLSendFormData.instance().getAddress()!) {
            self.amountMovedFromAccount = TLSendFormData.instance().feeAmount!
        } else {
            self.amountMovedFromAccount = TLSendFormData.instance().toAmount!.add(TLSendFormData.instance().feeAmount!)
        }
        
        for address in self.realToAddresses! {
            TLTransactionListener.instance().listenToIncomingTransactionForAddress(address)
        }
        
        TLSendFormData.instance().beforeSendBalance = AppDelegate.instance().godSend!.getCurrentFromBalance()
        self.sendTxHash = txHash
        self.toAddress = TLSendFormData.instance().getAddress()
        self.toAmount = TLSendFormData.instance().toAmount
        DLog("showPromptReviewTx txHex: \(txHex)")
        DLog("showPromptReviewTx txHash: \(txHash)")
        broadcastTx(txHex, txHash: txHash, toAddress: TLSendFormData.instance().getAddress()!)
    }
    
    func broadcastTx(_ txHex: String, txHash: String, toAddress: String) {
        let handlePushTxSuccess = { () -> () in
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_SEND_PAYMENT()),
                                                                      object: nil, userInfo: nil)
        }
        
        TLPushTxAPI.instance().sendTx(txHex, txHash: txHash, toAddress: toAddress, success: {
            (jsonData) in
            DLog("showPromptReviewTx pushTx: success \(jsonData)")
            
            if TLStealthAddress.isStealthAddress(toAddress, isTestnet:false) == true {
                // doing stealth payment with push tx insight get wrong hash back??
                let txid = (jsonData as! NSDictionary).object(forKey: "txid") as! String
                DLog("showPromptReviewTx pushTx: success txid \(txid)")
                DLog("showPromptReviewTx pushTx: success txHash \(txHash)")
                if txid != txHash {
                    NSException(name: NSExceptionName(rawValue: "API Error"), reason:"txid return does not match txid in app", userInfo:nil).raise()
                }
            }
            
            if let label = AppDelegate.instance().appWallet.getLabelForAddress(toAddress) {
                AppDelegate.instance().appWallet.setTransactionTag(txHash, tag: label)
            }
            handlePushTxSuccess()
            
            }, failure: {
                (code, status) in
                DLog("showPromptReviewTx pushTx: failure \(code) \(status)")
                if (code == 200) {
                    handlePushTxSuccess()
                } else {
                    TLPrompts.promptErrorMessage(TLDisplayStrings.ERROR_STRING(), message: status!)
                    self.cancelSend()
                }
        })
    }

    func showNextUnsignedTxPartQRCode() {
        if self.airGapDataBase64PartsArray == nil {
            return
        }
        let nextAipGapDataPart = self.airGapDataBase64PartsArray![0]
        self.airGapDataBase64PartsArray!.remove(at: 0)
        self.QRImageModal = TLQRImageModal(data: nextAipGapDataPart as NSString, buttonCopyText: TLDisplayStrings.NEXT_STRING(), vc: self)
        self.QRImageModal!.show()
    }
    
    func promptToSignTransaction(_ unSignedTx: String, inputScripts:NSArray, txInputsAccountHDIdxes:NSArray) {
        let extendedPublicKey = AppDelegate.instance().godSend!.getExtendedPubKey()
        if let airGapDataBase64 = TLColdWallet.createSerializedUnsignedTxAipGapData(unSignedTx, extendedPublicKey: extendedPublicKey!, inputScripts: inputScripts, txInputsAccountHDIdxes: txInputsAccountHDIdxes) {
            self.airGapDataBase64PartsArray = TLColdWallet.splitStringToArray(airGapDataBase64)
            DLog("airGapDataBase64PartsArray \(airGapDataBase64PartsArray)")
            TLPrompts.promtForOKCancel(self, title: TLDisplayStrings.SPENDING_FROM_A_COLD_WALLET_ACCOUNT_STRING(), message: TLDisplayStrings.SPENDING_FROM_A_COLD_WALLET_ACCOUNT_DESC_STRING(), success: {
                () in
                self.showNextUnsignedTxPartQRCode()
                }, failure: {
                    (isCancelled: Bool) in
            })
        }
    }
    
    @IBAction func customizeFeeButtonClicked(_ sender: AnyObject) {
        showPromptForSetTransactionFee()
    }
    
    @IBAction func feeInfoButtonClicked(_ sender: AnyObject) {
        TLPrompts.promptSuccessMessage(TLDisplayStrings.TRANSACTION_FEE_STRING(), message: TLDisplayStrings.FEE_INFO_DESC_STRING())
    }
    
    @IBAction func sendButtonClicked(_ sender: AnyObject) {
        self.startSendTimer()
        if !AppDelegate.instance().godSend!.haveUpDatedUTXOs() {
            AppDelegate.instance().godSend!.getAndSetUnspentOutputs({
                self.initiateSend()
                }, failure: {
                    self.cancelSend()
                    TLPrompts.promptErrorMessage(TLDisplayStrings.ERROR_STRING(), message: TLDisplayStrings.ERROR_FETCHING_UNSPENT_OUTPUTS_TRY_AGAIN_STRING())
            })
        } else {
            self.initiateSend()
        }
    }

    @IBAction fileprivate func cancel(_ sender:AnyObject) {
        self.dismiss(animated: true, completion:nil)
    }

    func startSendTimer() {
        TLHUDWrapper.showHUDAddedTo(self.view, labelText: TLDisplayStrings.SENDING_STRING(), animated: true)
        // relying on websocket to know when a payment has been sent can be unreliable, so cancel after a certain time
        let TIME_TO_WAIT_TO_HIDE_HUD_AND_REFRESH_ACCOUNT = 13.0
        sendTimer = Timer.scheduledTimer(timeInterval: TIME_TO_WAIT_TO_HIDE_HUD_AND_REFRESH_ACCOUNT, target: self,
                                         selector: #selector(retryFinishSend), userInfo: nil, repeats: false)
    }

    func promptToBroadcastColdWalletAccountSignedTx(_ txHex: String, txHash: String) {
        TLPrompts.promptAlertController(self, title: TLDisplayStrings.SEND_AUTHORIZED_PAYMENT_STRING(),
                                        message: "", okText: TLDisplayStrings.SEND_STRING(), cancelTx: TLDisplayStrings.CANCEL_STRING(), success: {
                                            () in
                                            self.startSendTimer()
                                            self.prepAndBroadcastTx(txHex, txHash: txHash)
            }, failure: {
                (isCancelled: Bool) in
        })
    }

    func didClickScanSignedTxButton() {
        scanSignedTx(success: { () in
            DLog("didClickScanSignedTxButton success");
            
            if self.totalExpectedParts != 0 && self.scannedSignedTxAirGapDataPartsDict.count == self.totalExpectedParts {
                self.shouldPromptToScanSignedTxAirGapData = false

                self.scannedSignedTxAirGapData = ""
                for i in stride(from: 1, through: self.totalExpectedParts, by: 1) {
                    let dataPart = self.scannedSignedTxAirGapDataPartsDict[i]
                    self.scannedSignedTxAirGapData = self.scannedSignedTxAirGapData! + dataPart!
                }
                self.scannedSignedTxAirGapDataPartsDict = [Int:String]()
                DLog("didClickScanSignedTxButton self.scannedSignedTxAirGapData \(self.scannedSignedTxAirGapData)");

                if let signedTxData = TLColdWallet.getSignedTxData(self.scannedSignedTxAirGapData!) {
                    DLog("didClickScanSignedTxButton signedTxData \(signedTxData)");
                    let txHex = signedTxData["txHex"] as! String
                    let txHash = signedTxData["txHash"] as! String
                    let txSize = signedTxData["txSize"] as! NSNumber
                    DLog("didClickScanSignedTxButton txHex \(txHex)");
                    DLog("didClickScanSignedTxButton txHash \(txHash)");
                    DLog("didClickScanSignedTxButton txSize \(txSize)");

                    self.signedAirGapTxHex = txHex
                    self.signedAirGapTxHash = txHash
                    self.shouldPromptToBroadcastSignedTx = true
                }
            } else {
                self.shouldPromptToScanSignedTxAirGapData = true
            }
            
            }, error: {
                () in
                DLog("didClickScanSignedTxButton error");
        })
    }
    
    func scanSignedTx(success: @escaping (TLWalletUtils.Success), error: @escaping (TLWalletUtils.Error)) {
        AppDelegate.instance().showColdWalletSpendReaderControllerFromViewController(self, success: {
            (data: String!) in
            let ret = TLColdWallet.parseScannedPart(data)
            let dataPart = ret.0
            let partNumber = ret.1
            let totalParts = ret.2

            self.totalExpectedParts = totalParts
            self.scannedSignedTxAirGapDataPartsDict[partNumber] = dataPart

            DLog("scanSignedTx \(dataPart) \(partNumber) \(totalParts)");
            success()
            }, error: {
                (data: String?) in
                error()
        })
    }

    func promptToScanSignedTxAirGapData() {
        let msg = String(format: TLDisplayStrings.X_SLASH_Y_PARTS_SCANNED_STRING(), self.scannedSignedTxAirGapDataPartsDict.count, self.totalExpectedParts)
        TLPrompts.promptAlertController(self, title: TLDisplayStrings.SCAN_NEXT_PART_STRING(), message: msg,
                                        okText: TLDisplayStrings.SCAN_STRING(), cancelTx: TLDisplayStrings.CANCEL_STRING(), success: { () in
                                            self.didClickScanSignedTxButton()
            }, failure: {
                (isCancelled: Bool) in
        })
    }

    func customIOS7dialogButtonTouchUp(inside alertView: CustomIOS7AlertView, clickedButtonAt buttonIndex: Int) {
        if (buttonIndex == 0) {
            if self.airGapDataBase64PartsArray?.count > 0 {
                self.showNextUnsignedTxPartQRCode()
            } else {
                TLPrompts.promptAlertController(self, title: TLDisplayStrings.FINISHED_PASSING_TRANSACTION_DATA_STRING(),
                                                message: TLDisplayStrings.FINISHED_PASSING_TRANSACTION_DATA_DESC_STRING(),
                                                okText: TLDisplayStrings.CONTINUE_STRING(), cancelTx: TLDisplayStrings.CANCEL_STRING(), success: {
                                                    () in
                                                    self.didClickScanSignedTxButton()
                    }, failure: {
                        (isCancelled: Bool) in
                })
            }
        }
        
        alertView.close()
    }
}
