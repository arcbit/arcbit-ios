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
                            AppDelegate.instance().coinWalletsManager!.refreshHDWalletAccounts(true)
                            DispatchQueue.main.async {
                                AppDelegate.instance().saveWalletJSONEnabled = true
                                AppDelegate.instance().saveWalletJsonCloud()
                                TLWalletUtils.SUPPORT_COIN_TYPES().forEach({ (coinType) in
                                    TLTransactionListener.instance().reconnect(coinType)
                                })
                                TLHUDWrapper.hideHUDForView(self.view, animated: true)
                                self.slidingViewController()!.topViewController = self.storyboard!.instantiateViewController(withIdentifier: "SendNav") 
                            }
                        }
                    }
            })
        } else {
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
    
    fileprivate func initializeWalletAppAndShowInitialScreenAndGoToMainScreen(_ walletPayload: NSDictionary?) -> () {
        AppDelegate.instance().initializeWalletAppAndShowInitialScreen(false, walletPayload: walletPayload)
        TLWalletUtils.SUPPORT_COIN_TYPES().forEach({ (coinType) in
            TLTransactionListener.instance().reconnect(coinType)
        })
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
