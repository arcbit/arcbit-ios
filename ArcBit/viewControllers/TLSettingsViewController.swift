//
//  TLSettingsViewController.swift
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
import AVFoundation

@objc(TLSettingsViewController) class TLSettingsViewController:IASKAppSettingsViewController, IASKSettingsDelegate,LTHPasscodeViewControllerDelegate {
    
    override var preferredStatusBarStyle : (UIStatusBarStyle) {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        AppDelegate.instance().setSettingsPasscodeViewColors()

        AppDelegate.instance().giveExitAppNoticeForBlockExplorerAPIToTakeEffect = false
        
        LTHPasscodeViewController.sharedUser().delegate = self
        self.neverShowPrivacySettings = true
        self.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(TLSettingsViewController.settingDidChange(_:)), name: NSNotification.Name(rawValue: kIASKAppSettingChanged), object: nil)
        
        self.updateHiddenKeys()
    }
    
    override func viewDidAppear(_ animated: Bool) -> () {
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_SETTINGS_SCREEN()), object: nil)
        if (AppDelegate.instance().giveExitAppNoticeForBlockExplorerAPIToTakeEffect) {
            TLPrompts.promptSuccessMessage("", message: TLDisplayStrings.KILL_THIS_APP_DESC_STRING())
            AppDelegate.instance().giveExitAppNoticeForBlockExplorerAPIToTakeEffect = false
        }
    }
    
    @IBAction fileprivate func menuButtonClicked(_ sender: UIButton) {
        self.slidingViewController().anchorTopViewToRight(animated: true)
    }
    
    fileprivate func updateHiddenKeys() {
        let hiddenKeys = NSMutableSet()
        
        if (TLPreferences.enabledInAppSettingsKitDynamicFeeBitcoin()) {
            hiddenKeys.add("transactionfee")
            hiddenKeys.add("settransactionfee")
        } else {
            hiddenKeys.add("dynamicfeeoption")
        }
        
        if (TLPreferences.enabledInAppSettingsKitDynamicFeeBitcoinCash()) {
            hiddenKeys.add("transactionfeebitcoincash")
            hiddenKeys.add("settransactionfeebitcoincash")
        } else {
            hiddenKeys.add("dynamicfeeoptionbitcoincash")
        }
        
        if (!LTHPasscodeViewController.doesPasscodeExist()) {
            hiddenKeys.add("changepincode")
        }
        
        let blockExplorerAPI = TLPreferences.getBlockExplorerAPI()
        if (blockExplorerAPI == .blockchain) {
            hiddenKeys.add("blockexplorerurl")
            hiddenKeys.add("setblockexplorerurl")
        } else {
            if (blockExplorerAPI == .insight) {
                let blockExplorerURL = TLPreferences.getBlockExplorerURL(blockExplorerAPI)
                TLPreferences.setInAppSettingsKitBlockExplorerURL(blockExplorerURL!)
            }
        }
        
        if (!TLWalletUtils.ENABLE_STEALTH_ADDRESS()) {
            hiddenKeys.add("stealthaddressdefault")
            hiddenKeys.add("stealthaddressfooter")
        }
        
        self.setHiddenKeys(hiddenKeys as Set<NSObject>, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    fileprivate func showPromptForSetBlockExplorerURL() {
        UIAlertController.showAlert(in: self,
            withTitle: TLDisplayStrings.CHANGE_BLOCK_EXPLORER_URL_STRING(),
            message: "",
            preferredStyle: .alert,
            cancelButtonTitle: TLDisplayStrings.CANCEL_STRING(),
            destructiveButtonTitle: nil,
            otherButtonTitles: [TLDisplayStrings.OK_STRING()],
            
            preShow: {(controller) in
                
                func addPromptTextField(_ textField: UITextField!){
                    textField.placeholder = ""
                    textField.text = "http://"
                }
                
                controller!.addTextField(configurationHandler: addPromptTextField)
            }
            ,
            tap: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView!.firstOtherButtonIndex) {
                    let candidate = (alertView!.textFields![0] ).text
                    
                    let candidateURL = URL(string: candidate!)
                    
                    if (candidateURL != nil && candidateURL!.host != nil) {
                        TLPreferences.setInAppSettingsKitBlockExplorerURL(candidateURL!.absoluteString)
                        TLPreferences.setBlockExplorerURL(TLPreferences.getBlockExplorerAPI(), value: candidateURL!.absoluteString)
                        TLPrompts.promptSuccessMessage("", message: TLDisplayStrings.KILL_THIS_APP_DESC_STRING())
                    } else {
                        UIAlertController.showAlert(in: self,
                            withTitle:  TLDisplayStrings.INVALID_URL_STRING(),
                            message: "",
                            cancelButtonTitle: TLDisplayStrings.OK_STRING(),
                            destructiveButtonTitle: nil,
                            otherButtonTitles: nil,
                            tap: {(alertView, action, buttonIndex) in
                                self.showPromptForSetBlockExplorerURL()
                        })
                    }
                } else if (buttonIndex == alertView!.cancelButtonIndex) {
                }
        })
    }
    
    fileprivate func showPromptForSetTransactionFee(_ coinType: TLCoinType) {
        let msg = String(format: TLDisplayStrings.SET_TRANSACTION_FEE_IN_X_STRING(), TLCurrencyFormat.getBitcoinDisplay(coinType))
        
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
                    let feeAmount = (alertView!.textFields![0] ).text
                    let feeAmountCoin = TLCurrencyFormat.coinAmountStringToCoin(feeAmount!, coinType: coinType)

                    switch coinType {
                    case .BCH:
                        TLPreferences.setInAppSettingsKitTransactionFeeBitcoinCash(TLCurrencyFormat.bigIntegerToBitcoinAmountString(feeAmountCoin, coinType: coinType, coinDenomination: TLCoinDenomination.bitcoinCash))
                    case .BTC:
                        TLPreferences.setInAppSettingsKitTransactionFeeBitcoinCash(TLCurrencyFormat.bigIntegerToBitcoinAmountString(feeAmountCoin, coinType: coinType, coinDenomination: TLCoinDenomination.bitcoin))
                    }
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_CHANGE_AUTOMATIC_TX_FEE()), object: nil)
                } else if (buttonIndex == alertView!.cancelButtonIndex) {
                }
        })
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection: Int) -> CGFloat {
        return 30.0
    }
    
    func settingsViewControllerDidEnd(_ sender: IASKAppSettingsViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func settingsViewController(_ settingsViewController: IASKViewController?,
        tableView: UITableView,
        heightForHeaderForSection section: Int) -> CGFloat {
            
            let key = settingsViewController!.settingsReader.key(forSection: section)
            if (key == "IASKLogo") {
                return UIImage(named: "Icon.png")!.size.height + 25
            } else if (key == "IASKCustomHeaderStyle") {
                return 55
            }
            return 0
    }
    
    fileprivate func switchPasscodeType(_ sender: UISwitch) {
        LTHPasscodeViewController.sharedUser().setIsSimple(sender.isOn,
            in: self,
            asModal: true)
    }
    
    fileprivate func showLockViewForEnablingPasscode() {
        LTHPasscodeViewController.sharedUser().showForEnablingPasscode(in: self,
            asModal: true)
    }
    
    fileprivate func showLockViewForChangingPasscode() {
        LTHPasscodeViewController.sharedUser().showForChangingPasscode(in: self, asModal: true)
    }
    
    
    fileprivate func showLockViewForTurningPasscodeOff() {
        LTHPasscodeViewController.sharedUser().showForDisablingPasscode(in: self,
            asModal: true)
    }
    
    func settingDidChange(_ info: Notification) {
        let userInfo = (info as NSNotification).userInfo! as NSDictionary
        for key1 in userInfo.allKeys {
            guard let didChangeKey = key1 as? String else {
                return
            }
        if (didChangeKey == "enablecoldwallet") {
            let enabled = (userInfo.object(forKey: "enablecoldwallet")) as! Bool
            TLPreferences.setEnableColdWallet(enabled)
        } else if (didChangeKey == "enableadvancemode") {
            let enabled = (userInfo.object(forKey: "enableadvancemode")) as! Bool
            TLPreferences.setAdvancedMode(enabled)
        } else if (didChangeKey == "canrestoredeletedapp") {
            let enabled = (userInfo.object(forKey: "canrestoredeletedapp")) as! Bool
            
            TLPreferences.setInAppSettingsCanRestoreDeletedApp(!enabled) // make sure below code completes firstbefore enabling
            if enabled {
                // settingDidChange gets called twice on one change, so need to do this
                if (TLPreferences.getEncryptedWalletPassphraseKey() == nil) {
                    TLPreferences.setInAppSettingsCanRestoreDeletedApp(enabled)
                    return
                }
                TLWalletPassphrase.enableRecoverableFeature(TLPreferences.canRestoreDeletedApp())
            } else {
                // settingDidChange gets called twice on one change, so need to do this
                if (TLPreferences.getEncryptedWalletPassphraseKey() != nil) {
                    TLPreferences.setInAppSettingsCanRestoreDeletedApp(enabled)
                    return
                }
                TLWalletPassphrase.disableRecoverableFeature(TLPreferences.canRestoreDeletedApp())
            }
            TLPreferences.setInAppSettingsCanRestoreDeletedApp(enabled)
            TLPreferences.setCanRestoreDeletedApp(enabled)
        } else if (didChangeKey == "enablepincode") {
            let enabled = userInfo.object(forKey: "enablepincode") as! Bool
            TLPreferences.setEnablePINCode(enabled)
            if (!LTHPasscodeViewController.doesPasscodeExist()) {
                self.showLockViewForEnablingPasscode()
            } else {
                self.showLockViewForTurningPasscodeOff()
            }
        } else if (didChangeKey == "displaylocalcurrency") {
            let enabled = userInfo.object(forKey: "displaylocalcurrency") as! Bool
            TLPreferences.setDisplayLocalCurrency(enabled)
            
        } else if (didChangeKey == "dynamicfeeoption") {
        } else if (didChangeKey == "dynamicfeeoptionbitcoincash") {
        } else if (didChangeKey == "enabledynamicfee") {
            self.updateHiddenKeys()
        } else if (didChangeKey == "enabledynamicfeebitcoincash") {
            self.updateHiddenKeys()
            
        } else if (didChangeKey == "currency") {
            let currencyIdx = userInfo.object(forKey: "currency") as! String
            TLPreferences.setCurrency(currencyIdx)

        } else if (didChangeKey == "bitcoincashdisplay") {
            let displayIdx = userInfo.object(forKey: "bitcoincashdisplay") as! String
            TLPreferences.setBitcoinCashDisplay(displayIdx)
        } else if (didChangeKey == "bitcoindisplay") {
            let displayIdx = userInfo.object(forKey: "bitcoindisplay") as! String
            TLPreferences.setBitcoinDisplay(displayIdx)
            
        } else if (didChangeKey == "stealthaddressdefault") {
            let enabled = userInfo.object(forKey: "stealthaddressdefault") as! Bool
            TLPreferences.setEnabledStealthAddressDefault(enabled)
        } else if (didChangeKey == "blockexplorerapi") {
            let blockexplorerAPIIdx = userInfo.object(forKey: "blockexplorerapi") as! String
            TLPreferences.setBlockExplorerAPI(blockexplorerAPIIdx)
            TLPreferences.resetBlockExplorerAPIURL()
            self.updateHiddenKeys()
            
            AppDelegate.instance().giveExitAppNoticeForBlockExplorerAPIToTakeEffect = true
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_CHANGE_BLOCKEXPLORER_TYPE()), object: nil)
        }
        }
    }
    
    func settingsViewController(_ sender: IASKAppSettingsViewController, buttonTappedFor specifier: IASKSpecifier) {
        if (specifier.key() == "changepincode") {
            self.showLockViewForChangingPasscode()
        } else if (specifier.key() == "showpassphrase") {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "Passphrase") 
            self.slidingViewController().present(vc, animated: true, completion: nil)
        } else if (specifier.key() == "restorewallet") {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "EnterMnemonic") 
            self.slidingViewController().present(vc, animated: true, completion: nil)
            
        } else if (specifier.key() == "settransactionfee") {
            self.showPromptForSetTransactionFee(TLCoinType.BTC)
        } else if (specifier.key() == "settransactionfeebitcoincash") {
            self.showPromptForSetTransactionFee(TLCoinType.BCH)

        } else if (specifier.key() == "setblockexplorerurl") {
            self.showPromptForSetBlockExplorerURL()
        }
    }
    
    func passcodeViewControllerWillClose() {
        if (LTHPasscodeViewController.doesPasscodeExist()) {
            TLPreferences.setInAppSettingsKitEnablePinCode(true)
            TLPreferences.setEnablePINCode(true)
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_ENABLE_PIN_CODE()), object: nil)
        } else {
            TLPreferences.setInAppSettingsKitEnablePinCode(false)
            TLPreferences.setEnablePINCode(false)
        }
        self.updateHiddenKeys()
    }
    
    func maxNumberOfFailedAttemptsReached() {
    }
    
    func passcodeWasEnteredSuccessfully() {
    }
    
    func logoutButtonWasPressed() {
    }
 
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
