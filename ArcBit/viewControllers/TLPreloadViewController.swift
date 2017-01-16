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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet fileprivate var walletLoadingActivityIndicatorView: UIActivityIndicatorView?
    @IBOutlet fileprivate var backgroundView: UIView?
    @IBOutlet weak var backgroundImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.walletLoadingActivityIndicatorView!.isHidden = true
        self.walletLoadingActivityIndicatorView!.color = UIColor.gray
        
        self.navigationController!.navigationBar.isHidden = true
        UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.none)
        
        let passphrase = TLWalletPassphrase.getDecryptedWalletPassphrase()
        if (TLPreferences.canRestoreDeletedApp() && !TLPreferences.hasSetupHDWallet() && passphrase != nil) {
            // is fresh app but not first time installing
            UIAlertController.showAlert(in: self,
                withTitle: TLDisplayStrings.BACKUP_PASSPHRASE_FOUND_IN_KEYCHAIN_STRING(),
                message: TLDisplayStrings.BACKUP_PASSPHRASE_FOUND_IN_KEYCHAIN_DESC_STRING(),
                cancelButtonTitle: TLDisplayStrings.RESTORE_STRING(),
                destructiveButtonTitle: nil,
                otherButtonTitles: [TLDisplayStrings.START_FRESH_STRING()],
                tap: {(alertView, action, buttonIndex) in
                    if (buttonIndex == alertView?.firstOtherButtonIndex) {
                        self.initializeWalletAppAndShowInitialScreenAndGoToMainScreen(nil)
                    } else if (buttonIndex == alertView?.cancelButtonIndex) {
                        
                        TLHUDWrapper.showHUDAddedTo(self.view, labelText: TLDisplayStrings.RESTORING_WALLET_STRING(), animated: true)
                        AppDelegate.instance().saveWalletJSONEnabled = false

                        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
                            AppDelegate.instance().initializeWalletAppAndShowInitialScreen(true, walletPayload: nil)
                            AppDelegate.instance().refreshHDWalletAccounts(true)
                            DispatchQueue.main.async {
                                AppDelegate.instance().saveWalletJSONEnabled = true
                                AppDelegate.instance().saveWalletJsonCloud()
                                TLTransactionListener.instance().reconnect()
                                TLStealthWebSocket.instance().reconnect()
                                TLHUDWrapper.hideHUDForView(self.view, animated: true)
                                self.slidingViewController()!.topViewController = self.storyboard!.instantiateViewController(withIdentifier: "SendNav") 
                            }
                        }
                    }
            })
        } else {
            //self.checkToLoadFromiCloud()
            self.checkToLoadFromLocal()
        }
    }
    
    fileprivate func checkToLoadFromLocal() -> () {
        if (TLWalletJson.getDecryptedEncryptedWalletJSONPassphrase() != nil) {
            let localWalletPayload = AppDelegate.instance().getLocalWalletJsonDict()
            self.initializeWalletAppAndShowInitialScreenAndGoToMainScreen(localWalletPayload)
        } else {
            self.initializeWalletAppAndShowInitialScreenAndGoToMainScreen(nil)
        }
    }
    
    fileprivate func checkToLoadFromiCloud() -> () {
        if (TLPreferences.getEnableBackupWithiCloud()) {
            self.walletLoadingActivityIndicatorView!.startAnimating()
            
            TLCloudDocumentSyncWrapper.instance().getFileFromCloud(TLPreferences.getCloudBackupWalletFileName()!, completion: {
                (cloudDocument, documentData, error) in
                var walletPayload: NSDictionary? = nil
                
                if (documentData!.count == 0) {
                    self.walletLoadingActivityIndicatorView!.stopAnimating()
                    walletPayload = AppDelegate.instance().getLocalWalletJsonDict()
                    UIAlertController.showAlert(in: self,
                        withTitle: TLDisplayStrings.ICLOUD_BACKUP_NOT_FOUND_STRING(),
                        message: TLDisplayStrings.ICLOUD_BACKUP_NOT_FOUND_DESC_STRING(),
                        cancelButtonTitle: TLDisplayStrings.NO_STRING(),
                        destructiveButtonTitle: nil,
                        otherButtonTitles: [TLDisplayStrings.YES_STRING()],
                        tap: {(alertView, action, buttonIndex) in
                            if (buttonIndex == alertView!.firstOtherButtonIndex) {
                                self.initializeWalletAppAndShowInitialScreenAndGoToMainScreen(walletPayload!)
                                AppDelegate.instance().saveWalletJsonCloudBackground()
                            } else if (buttonIndex == alertView!.cancelButtonIndex) {
                            }
                    })
                } else {
                    if (error == nil) {
                        let cloudWalletJSONDocumentSavedDate = cloudDocument!.fileModificationDate
                        let localWalletJSONDocumentSavedDate = TLPreferences.getLastSavedEncryptedWalletJSONDate()
                        let comparisonResult = cloudWalletJSONDocumentSavedDate!.compare(localWalletJSONDocumentSavedDate)
                        
                        if (comparisonResult == ComparisonResult.orderedDescending || comparisonResult == ComparisonResult.orderedSame) {
                            let encryptedWalletJSON = NSString(data: documentData!, encoding: String.Encoding.utf8.rawValue)
                            let passphrase = TLWalletJson.getDecryptedEncryptedWalletJSONPassphrase()
                            walletPayload = TLWalletJson.getWalletJsonDict((encryptedWalletJSON as! String), password: passphrase)
                            if (walletPayload != nil) {
                                self.initializeWalletAppAndShowInitialScreenAndGoToMainScreen(walletPayload!)
                            } else {
                                // Should not happen, this means somehow I pulled an icloud backup wallet that is different then the local wallet,
                                // but the code that makes each icloud backup file name unique for each device should fix that issue.
                                TLPrompts.promptErrorMessage(TLDisplayStrings.ERROR_STRING(), message: TLDisplayStrings.CANNOT_DECRYPT_ICLOUD_BACKUP_WALLET_STRING())
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
                        
                        UIAlertController.showAlert(in: self,
                            withTitle: String(format: TLDisplayStrings.ICLOUD_ERROR_COLON_X_STRING(), error!.localizedDescription),
                            message: TLDisplayStrings.DO_YOU_WANT_TO_LOAD_LOCAL_WALLET_FILE_STRING(),
                            cancelButtonTitle: TLDisplayStrings.NO_STRING(),
                            destructiveButtonTitle: nil,
                            otherButtonTitles: [TLDisplayStrings.YES_STRING()],
                            
                            tap: {(alertView, action, buttonIndex) in
                                if (buttonIndex == alertView!.firstOtherButtonIndex) {
                                    self.initializeWalletAppAndShowInitialScreenAndGoToMainScreen(walletPayload!)
                                } else if (buttonIndex == alertView!.cancelButtonIndex) {
                                }
                        })
                        
                    }
                    
                }
            })
        } else {
            self.checkToLoadFromLocal()
        }
    }
    
    fileprivate func initializeWalletAppAndShowInitialScreenAndGoToMainScreen(_ walletPayload: NSDictionary?) -> () {
        AppDelegate.instance().initializeWalletAppAndShowInitialScreen(false, walletPayload: walletPayload)
        TLTransactionListener.instance().reconnect()
        TLStealthWebSocket.instance().reconnect()

        if self.slidingViewController() != nil {
            self.slidingViewController().topViewController = self.storyboard!.instantiateViewController(withIdentifier: "SendNav") 
        } else {
            //is running unit test
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) -> () {
        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.none)
    }
}
