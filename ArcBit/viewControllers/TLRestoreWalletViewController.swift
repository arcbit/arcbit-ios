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
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet private var navigationBar:UINavigationBar?
    @IBOutlet private var inputMnemonicTextView:UITextView?
    @IBOutlet private var restoreWalletDescriptionLabel:UILabel?
    
    var encryptedWalletJSON:String?
    var isRestoringFromEncryptedWalletJSON:Bool = false
    
    override func preferredStatusBarStyle() -> (UIStatusBarStyle) {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarColors(self.navigationBar!)
        
        if (self.isRestoringFromEncryptedWalletJSON) {
            self.restoreWalletDescriptionLabel!.text = "Enter passphrase for your iCloud backup wallet.".localized
        }
        
        self.inputMnemonicTextView!.returnKeyType = .Done
        self.inputMnemonicTextView!.delegate = self
        self.inputMnemonicTextView!.backgroundColor = TLColors.mainAppColor()
        self.inputMnemonicTextView!.textColor = TLColors.mainAppOppositeColor()
        
        self.inputMnemonicTextView!.becomeFirstResponder()
    }
    
    private func showPromptToRestoreWallet(mnemonicPassphrase:String, walletPayload:NSDictionary?) -> () {
        let msg = String(format:"Your current wallet will be deleted. Your can restore your current wallet later with the wallet passphrase, but any imported accounts or addresses created in advance mode cannot be recovered. Do you wish to continue?".localized)
        
        UIAlertController.showAlertInViewController(self,
            withTitle:"Restoring Wallet".localized,
            message:msg,
            cancelButtonTitle:"Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles:["Continue".localized],
            tapBlock: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    self.inputMnemonicTextView!.resignFirstResponder()
                    TLHUDWrapper.showHUDAddedTo(self.view, labelText:"Restoring Wallet".localized, animated:true)
                    
                    if (self.isRestoringFromEncryptedWalletJSON) {
                        AppDelegate.instance().initializeWalletAppAndShowInitialScreen(false, walletPayload:walletPayload)
                        TLPreferences.setEnableBackupWithiCloud(true)
                        TLPreferences.setWalletPassphrase(mnemonicPassphrase)
                        TLPreferences.setEncryptedWalletJSONPassphrase(mnemonicPassphrase)
                        self.handleAfterRecoverWallet(mnemonicPassphrase)
                    } else {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                            AppDelegate.instance().saveWalletJSONEnabled = false
                            AppDelegate.instance().recoverHDWallet(mnemonicPassphrase, shouldRefreshApp:false)
                            AppDelegate.instance().refreshHDWalletAccounts(true)
                            AppDelegate.instance().refreshApp(mnemonicPassphrase, clearWalletInMemory:false)
                            AppDelegate.instance().saveWalletJSONEnabled = true
                            self.handleAfterRecoverWallet(mnemonicPassphrase)
                        }
                    }
                }
                else if (buttonIndex == alertView.cancelButtonIndex) {
                }
        })
    }
    
    private func handleAfterRecoverWallet(mnemonicPassphrase:String) -> () {
        AppDelegate.instance().updateGodSend(TLSendFromType.HDWallet, sendFromIndex:0)
        AppDelegate.instance().updateReceiveSelectedObject(TLSendFromType.HDWallet, sendFromIndex:0)
        AppDelegate.instance().updateHistorySelectedObject(TLSendFromType.HDWallet, sendFromIndex:0)
        
        AppDelegate.instance().saveWalletJsonCloud()
        
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_RESTORE_WALLET(),
            object:nil, userInfo:nil)
        
        dispatch_async(dispatch_get_main_queue()) {
            TLTransactionListener.instance().reconnect()
            TLStealthWebSocket.instance().reconnect()
            TLHUDWrapper.hideHUDForView(self.view, animated:true)
            self.dismissViewControllerAnimated(true, completion:nil)
            TLPrompts.promptSuccessMessage("Success".localized, message:"Your wallet is now restored!".localized)
        }
    }
    
    @IBAction private func cancel(sender:AnyObject!) {
        self.inputMnemonicTextView!.resignFirstResponder()
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_ENTER_MNEMONIC_VIEWCONTROLLER_DISMISSED(),
            object:nil, userInfo:nil)
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func textView(textView:UITextView, shouldChangeTextInRange range:NSRange, replacementText text:String) -> Bool {
        
        if(text == "\n") {
            var passphrase = textView.text
            passphrase = passphrase.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            if (TLHDWalletWrapper.phraseIsValid(passphrase)) {
                if (self.isRestoringFromEncryptedWalletJSON) {
                    //try passphrase on EncryptedWalletJSON
                    let encryptedWalletJSONPassphrase = passphrase
                    let walletPayload = TLWalletJson.getWalletJsonDict(self.encryptedWalletJSON, password:encryptedWalletJSONPassphrase)
                    if (walletPayload == nil) {
                        TLPrompts.promptErrorMessage("Error".localized, message:"Incorrect passphrase, could not decrypt iCloud wallet backup.".localized)
                    } else {
                        showPromptToRestoreWallet(passphrase, walletPayload:walletPayload!)
                    }
                } else {
                    showPromptToRestoreWallet(passphrase, walletPayload:nil)
                }
            } else {
                TLPrompts.promptErrorMessage("Error".localized, message:"Invalid backup passphrase".localized)
            }
            
            return false
        }
        
        return true
    }
    
    private func textViewShouldReturn(textView:UITextView) -> (Bool){
        textView.resignFirstResponder()
        return true
    }
    
    func textViewShouldBeginEditing(textView:UITextView) -> (Bool) {
        return true
    }
    
    func textViewShouldEndEditing(textView:UITextView) -> (Bool) {
        textView.resignFirstResponder()
        return true
    }
}
