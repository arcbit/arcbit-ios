//
//  TLPreloadViewController.swift
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


@objc(TLPreloadViewController) class TLPreloadViewController: UIViewController, UIAlertViewDelegate {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet private var walletLoadingActivityIndicatorView: UIActivityIndicatorView?
    @IBOutlet private var backgroundView: UIView?
    @IBOutlet weak var backgroundImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.walletLoadingActivityIndicatorView!.hidden = true
        self.walletLoadingActivityIndicatorView!.color = UIColor.grayColor()
        
        self.navigationController!.navigationBar.hidden = true
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        
        var passphrase = TLWalletPassphrase.getDecryptedWalletPassphrase()
        if (TLPreferences.canRestoreDeletedApp() && !TLPreferences.hasSetupHDWallet() && passphrase != nil) {
            // is fresh app but not first time installing
            UIAlertController.showAlertInViewController(self,
                withTitle: "Backup passphrase found in keychain".localized,
                message: "Do you want to restore from your backup passphrase or start a fresh app?".localized,
                cancelButtonTitle: "Restore".localized,
                destructiveButtonTitle: nil,
                otherButtonTitles: ["Start fresh".localized],
                tapBlock: {(alertView, action, buttonIndex) in
                    if (buttonIndex == alertView.firstOtherButtonIndex) {
                        self.initializeWalletAppAndShowInitialScreenAndGoToMainScreen(nil)
                    } else if (buttonIndex == alertView.cancelButtonIndex) {
                        
                        TLHUDWrapper.showHUDAddedTo(self.view, labelText: "Restoring Wallet".localized, animated: true)
                        AppDelegate.instance().saveWalletJSONEnabled = false

                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                            AppDelegate.instance().initializeWalletAppAndShowInitialScreen(true, walletPayload: nil)
                            AppDelegate.instance().refreshHDWalletAccounts(true)
                            dispatch_async(dispatch_get_main_queue()) {
                                AppDelegate.instance().saveWalletJSONEnabled = true
                                AppDelegate.instance().saveWalletJsonCloud()
                                TLTransactionListener.instance().reconnect()
                                TLStealthWebSocket.instance().reconnect()
                                TLHUDWrapper.hideHUDForView(self.view, animated: true)
                                self.slidingViewController()!.topViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SendNav") as! UIViewController
                            }
                        }
                    }
            })
        } else {
            //self.checkToLoadFromiCloud()
            self.checkToLoadFromLocal()
        }
    }
    
    private func checkToLoadFromLocal() -> () {
        if (TLWalletJson.getDecryptedEncryptedWalletJSONPassphrase() != nil) {
            var localWalletPayload = AppDelegate.instance().getLocalWalletJsonDict()
            self.initializeWalletAppAndShowInitialScreenAndGoToMainScreen(localWalletPayload)
        } else {
            self.initializeWalletAppAndShowInitialScreenAndGoToMainScreen(nil)
        }
    }
    
    private func checkToLoadFromiCloud() -> () {
        if (TLPreferences.getEnableBackupWithiCloud()) {
            self.walletLoadingActivityIndicatorView!.startAnimating()
            
            TLCloudDocumentSyncWrapper.instance().getFileFromCloud(TLPreferences.getCloudBackupWalletFileName()!, completion: {
                (cloudDocument: UIDocument!, documentData: NSData!, error: NSError?) in
                var walletPayload: NSDictionary? = nil
                
                if (documentData.length == 0) {
                    self.walletLoadingActivityIndicatorView!.stopAnimating()
                    walletPayload = AppDelegate.instance().getLocalWalletJsonDict()
                    UIAlertController.showAlertInViewController(self,
                        withTitle: "iCloud backup not found".localized,
                        message: "Do you want to load and backup your current local wallet file?".localized,
                        cancelButtonTitle: "No".localized,
                        destructiveButtonTitle: nil,
                        otherButtonTitles: ["Yes".localized],
                        tapBlock: {(alertView, action, buttonIndex) in
                            if (buttonIndex == alertView.firstOtherButtonIndex) {
                                self.initializeWalletAppAndShowInitialScreenAndGoToMainScreen(walletPayload!)
                                AppDelegate.instance().saveWalletJsonCloudBackground()
                            } else if (buttonIndex == alertView.cancelButtonIndex) {
                            }
                    })
                } else {
                    if (error == nil) {
                        var cloudWalletJSONDocumentSavedDate = cloudDocument.fileModificationDate
                        var localWalletJSONDocumentSavedDate = TLPreferences.getLastSavedEncryptedWalletJSONDate()
                        var comparisonResult = cloudWalletJSONDocumentSavedDate!.compare(localWalletJSONDocumentSavedDate)
                        
                        if (comparisonResult == NSComparisonResult.OrderedDescending || comparisonResult == NSComparisonResult.OrderedSame) {
                            var encryptedWalletJSON = NSString(data: documentData, encoding: NSUTF8StringEncoding)
                            var passphrase = TLWalletJson.getDecryptedEncryptedWalletJSONPassphrase()
                            walletPayload = TLWalletJson.getWalletJsonDict((encryptedWalletJSON as! String), password: passphrase)
                            if (walletPayload != nil) {
                                self.initializeWalletAppAndShowInitialScreenAndGoToMainScreen(walletPayload!)
                            } else {
                                // Should not happen, this means somehow I pulled an icloud backup wallet that is different then the local wallet,
                                // but the code that makes each icloud backup file name unique for each device should fix that issue.
                                TLPrompts.promptErrorMessage("Error".localized, message: "Cannot decrypt iCloud backup wallet.".localized)
                            }
                        } else {
                            // Should not happen, this is because I always do local backup after icloud backup.
                            // Even if I do backup when cloud is disabled, and I turn cloud back on, a backup will be made, thus syncing backup and backup time.
                            // Even I do turn off wifi, and edit wallet also.
                            walletPayload = AppDelegate.instance().getLocalWalletJsonDict()
                            self.initializeWalletAppAndShowInitialScreenAndGoToMainScreen(walletPayload!)
                        }
                        self.walletLoadingActivityIndicatorView!.stopAnimating()
                    } else {
                        self.walletLoadingActivityIndicatorView!.stopAnimating()
                        
                        walletPayload = AppDelegate.instance().getLocalWalletJsonDict()
                        
                        UIAlertController.showAlertInViewController(self,
                            withTitle: String(format: "iCloud Error: %@".localized, error!.description),
                            message: "Do you want to load local wallet file?".localized,
                            cancelButtonTitle: "No".localized,
                            destructiveButtonTitle: nil,
                            otherButtonTitles: ["Yes".localized],
                            
                            tapBlock: {(alertView, action, buttonIndex) in
                                if (buttonIndex == alertView.firstOtherButtonIndex) {
                                    self.initializeWalletAppAndShowInitialScreenAndGoToMainScreen(walletPayload!)
                                } else if (buttonIndex == alertView.cancelButtonIndex) {
                                }
                        })
                        
                    }
                    
                }
            })
        } else {
            self.checkToLoadFromLocal()
        }
    }
    
    private func initializeWalletAppAndShowInitialScreenAndGoToMainScreen(walletPayload: NSDictionary?) -> () {
        AppDelegate.instance().initializeWalletAppAndShowInitialScreen(false, walletPayload: walletPayload)
        TLTransactionListener.instance().reconnect()
        TLStealthWebSocket.instance().reconnect()

        if self.slidingViewController() != nil {
            self.slidingViewController().topViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SendNav") as! UIViewController
        } else {
            //is running unit test
        }
    }
    
    override func viewWillDisappear(animated: Bool) -> () {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
    }
}
