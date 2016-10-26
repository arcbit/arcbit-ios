//
//  TLRestoreWalletViewController.swift
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

@objc(TLRestoreWalletViewController) class TLRestoreWalletViewController: UIViewController, UITextViewDelegate {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet fileprivate var navigationBar:UINavigationBar?
    @IBOutlet fileprivate var inputMnemonicTextView:UITextView?
    @IBOutlet fileprivate var restoreWalletDescriptionLabel:UILabel?
    
    var encryptedWalletJSON:String?
    var isRestoringFromEncryptedWalletJSON:Bool = false
    
    override var preferredStatusBarStyle : (UIStatusBarStyle) {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarColors(self.navigationBar!)
        
        if (self.isRestoringFromEncryptedWalletJSON) {
            self.restoreWalletDescriptionLabel!.text = "Enter passphrase for your iCloud backup wallet.".localized
        }
        
        self.inputMnemonicTextView!.returnKeyType = .done
        self.inputMnemonicTextView!.delegate = self
        self.inputMnemonicTextView!.backgroundColor = TLColors.mainAppColor()
        self.inputMnemonicTextView!.textColor = TLColors.mainAppOppositeColor()
        self.inputMnemonicTextView!.isSecureTextEntry = true
        
        self.inputMnemonicTextView!.becomeFirstResponder()
    }
    
    fileprivate func showPromptToRestoreWallet(_ mnemonicPassphrase:String, walletPayload:NSDictionary?) -> () {
        let msg = String(format:"Your current wallet will be deleted. Your can restore your current wallet later with the wallet passphrase, but any imported accounts or addresses created in advanced mode cannot be recovered. Do you wish to continue?".localized)
        
        UIAlertController.showAlert(in: self,
            withTitle:"Restoring Wallet".localized,
            message:msg,
            cancelButtonTitle:"Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles:["Continue".localized],
            tap: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView?.firstOtherButtonIndex) {
                    self.inputMnemonicTextView!.resignFirstResponder()
                    TLHUDWrapper.showHUDAddedTo(self.view, labelText:"Restoring Wallet".localized, animated:true)
                    
                    if (self.isRestoringFromEncryptedWalletJSON) {
                        AppDelegate.instance().initializeWalletAppAndShowInitialScreen(false, walletPayload:walletPayload)
                        TLPreferences.setEnableBackupWithiCloud(true)
                        TLPreferences.setWalletPassphrase(mnemonicPassphrase, useKeychain: true)
                        TLPreferences.setEncryptedWalletJSONPassphrase(mnemonicPassphrase, useKeychain: true)
                        self.handleAfterRecoverWallet(mnemonicPassphrase)
                    } else {
                        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
                            AppDelegate.instance().saveWalletJSONEnabled = false
                            AppDelegate.instance().recoverHDWallet(mnemonicPassphrase, shouldRefreshApp:false)
                            AppDelegate.instance().refreshHDWalletAccounts(true)
                            AppDelegate.instance().refreshApp(mnemonicPassphrase, clearWalletInMemory:false)
                            AppDelegate.instance().saveWalletJSONEnabled = true
                            self.handleAfterRecoverWallet(mnemonicPassphrase)
                        }
                    }
                }
                else if (buttonIndex == alertView?.cancelButtonIndex) {
                }
        })
    }
    
    fileprivate func handleAfterRecoverWallet(_ mnemonicPassphrase:String) -> () {
        AppDelegate.instance().updateGodSend(TLSendFromType.hdWallet, sendFromIndex:0)
        AppDelegate.instance().updateReceiveSelectedObject(TLSendFromType.hdWallet, sendFromIndex:0)
        AppDelegate.instance().updateHistorySelectedObject(TLSendFromType.hdWallet, sendFromIndex:0)
        
        AppDelegate.instance().saveWalletJsonCloud()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_RESTORE_WALLET()),
            object:nil, userInfo:nil)
        
        DispatchQueue.main.async {
            TLTransactionListener.instance().reconnect()
            TLStealthWebSocket.instance().reconnect()
            TLHUDWrapper.hideHUDForView(self.view, animated:true)
            self.dismiss(animated: true, completion:nil)
            TLPrompts.promptSuccessMessage("Success".localized, message:"Your wallet is now restored!".localized)
        }
    }
    
    @IBAction fileprivate func cancel(_ sender:AnyObject!) {
        self.inputMnemonicTextView!.resignFirstResponder()
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_ENTER_MNEMONIC_VIEWCONTROLLER_DISMISSED()),
            object:nil, userInfo:nil)
        self.dismiss(animated: true, completion:nil)
    }
    
    func textView(_ textView:UITextView, shouldChangeTextIn range:NSRange, replacementText text:String) -> Bool {
        
        if(text == "\n") {
            var passphrase = textView.text
            passphrase = passphrase?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            if (TLHDWalletWrapper.phraseIsValid(passphrase!)) {
                if (self.isRestoringFromEncryptedWalletJSON) {
                    //try passphrase on EncryptedWalletJSON
                    let encryptedWalletJSONPassphrase = passphrase
                    let walletPayload = TLWalletJson.getWalletJsonDict(self.encryptedWalletJSON, password:encryptedWalletJSONPassphrase)
                    if (walletPayload == nil) {
                        TLPrompts.promptErrorMessage("Error".localized, message:"Incorrect passphrase, could not decrypt iCloud wallet backup.".localized)
                    } else {
                        showPromptToRestoreWallet(passphrase!, walletPayload:walletPayload!)
                    }
                } else {
                    showPromptToRestoreWallet(passphrase!, walletPayload:nil)
                }
            } else {
                TLPrompts.promptErrorMessage("Error".localized, message:"Invalid backup passphrase".localized)
            }
            
            return false
        }
        
        return true
    }
    
    fileprivate func textViewShouldReturn(_ textView:UITextView) -> (Bool){
        textView.resignFirstResponder()
        return true
    }
    
    func textViewShouldBeginEditing(_ textView:UITextView) -> (Bool) {
        return true
    }
    
    func textViewShouldEndEditing(_ textView:UITextView) -> (Bool) {
        textView.resignFirstResponder()
        return true
    }
}
