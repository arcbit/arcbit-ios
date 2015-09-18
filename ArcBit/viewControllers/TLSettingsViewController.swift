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
    
    override func preferredStatusBarStyle() -> (UIStatusBarStyle) {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        
        AppDelegate.instance().setSettingsPasscodeViewColors()

        AppDelegate.instance().giveExitAppNoticeForBlockExplorerAPIToTakeEffect = false
        
        LTHPasscodeViewController.sharedUser().delegate = self
        self.delegate = self
        
        TLPreferences.setInAppSettingsKitEnableBackupWithiCloud(TLPreferences.getEnableBackupWithiCloud())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "settingDidChange:", name: kIASKAppSettingChanged, object: nil)
        
        self.updateHiddenKeys()
    }
    
    override func viewDidAppear(animated: Bool) -> () {
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_SETTINGS_SCREEN(), object: nil)
        if (AppDelegate.instance().giveExitAppNoticeForBlockExplorerAPIToTakeEffect) {
            TLPrompts.promptSuccessMessage("Notice".localized, message: "You must close the app in order for the API change to take effect.".localized)
            AppDelegate.instance().giveExitAppNoticeForBlockExplorerAPIToTakeEffect = false
        }
    }
    
    @IBAction private func menuButtonClicked(sender: UIButton) {
        self.slidingViewController().anchorTopViewToRightAnimated(true)
    }
    
    private func updateHiddenKeys() {
        let hiddenKeys = NSMutableSet()
        
        if (!TLPreferences.isAutomaticFee()) {
            hiddenKeys.addObject("feeamounttitle")
            hiddenKeys.addObject("transactionfee")
            hiddenKeys.addObject("settransactionfee")
        }
        
        if (!LTHPasscodeViewController.doesPasscodeExist()) {
            hiddenKeys.addObject("changepincode")
        }
        
        let blockExplorerAPI = TLPreferences.getBlockExplorerAPI()
        if (blockExplorerAPI == .Blockchain) {
            hiddenKeys.addObject("blockexplorerurl")
            hiddenKeys.addObject("setblockexplorerurl")
        } else {
            if (blockExplorerAPI == .Insight) {
                let blockExplorerURL = TLPreferences.getBlockExplorerURL(blockExplorerAPI)
                TLPreferences.setInAppSettingsKitBlockExplorerURL(blockExplorerURL!)
            }
        }
        
        if (!TLWalletUtils.ENABLE_STEALTH_ADDRESS()) {
            hiddenKeys.addObject("stealthaddressdefault")
            hiddenKeys.addObject("stealthaddressfooter")
        }
        
        self.setHiddenKeys(hiddenKeys as Set<NSObject>, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func showEmailSupportViewController() {
        let mc = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(String(format: "%@ Support".localized, TLWalletUtils.APP_NAME()))
        mc.setMessageBody("Hi, \n\nI need help with... ".localized, isHTML: false)
        mc.setToRecipients(["support@arcbit.zendesk.com"])
        self.presentViewController(mc, animated: true, completion: nil)
    }
    
    private func showPromptForSetBlockExplorerURL() {
        UIAlertController.showAlertInViewController(self,
            withTitle: "Set Block Explorer URL".localized,
            message: "",
            preferredStyle: .Alert,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["OK".localized],
            
            preShowBlock: {(controller:UIAlertController!) in
                
                func addPromptTextField(textField: UITextField!){
                    textField.placeholder = ""
                    textField.text = "http://"
                }
                
                controller.addTextFieldWithConfigurationHandler(addPromptTextField)
            }
            ,
            tapBlock: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    let candidate = (alertView.textFields![0] ).text
                    
                    let candidateURL = NSURL(string: candidate!)
                    
                    if (candidateURL != nil && candidateURL!.host != nil) {
                        TLPreferences.setInAppSettingsKitBlockExplorerURL(candidateURL!.absoluteString)
                        TLPreferences.setBlockExplorerURL(TLPreferences.getBlockExplorerAPI(), value: candidateURL!.absoluteString)
                        TLPrompts.promptSuccessMessage("Notice".localized, message: "You must exit and kill this app in order for this to take effect.".localized)
                    } else {
                        UIAlertController.showAlertInViewController(self,
                            withTitle:  "Invalid URL".localized,
                            message: "Enter something like https://example.com".localized,
                            cancelButtonTitle: "OK".localized,
                            destructiveButtonTitle: nil,
                            otherButtonTitles: nil,
                            tapBlock: {(alertView, action, buttonIndex) in
                                self.showPromptForSetBlockExplorerURL()
                        })
                    }
                } else if (buttonIndex == alertView.cancelButtonIndex) {
                }
        })
    }
    
    private func showPromptForSetTransactionFee() {
        let msg = String(format: "Input a recommended amount. Somewhere between %@ and %@ BTC".localized, TLWalletUtils.MIN_FEE_AMOUNT_IN_BITCOINS(), TLWalletUtils.MAX_FEE_AMOUNT_IN_BITCOINS())
        
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
                    let feeAmount = (alertView.textFields![0] ).text
                    
                    let feeAmountCoin = TLWalletUtils.bitcoinAmountStringToCoin(feeAmount!)
                    if (TLWalletUtils.isValidInputTransactionFee(feeAmountCoin)) {
                        TLPreferences.setInAppSettingsKitTransactionFee(feeAmountCoin.bigIntegerToBitcoinAmountString(.Bitcoin))
                        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_CHANGE_AUTOMATIC_TX_FEE(), object: nil)
                        
                    } else {
                        let msg = String(format: "Too low a transaction fee can cause transactions to take a long time to confirm. Continue anyways?".localized)
                        
                        TLPrompts.promtForOKCancel(self, title: "Non-recommended Amount Transaction Fee".localized, message: msg, success: {
                            () in
                            let amount = TLWalletUtils.bitcoinAmountStringToCoin(feeAmount!)
                            TLPreferences.setInAppSettingsKitTransactionFee(amount.bigIntegerToBitcoinAmountString(.Bitcoin))
                            NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_CHANGE_AUTOMATIC_TX_FEE(), object: nil)
                            
                            }, failure: {
                                (isCancelled: Bool) in
                                self.showPromptForSetTransactionFee()
                        })
                    }
                } else if (buttonIndex == alertView.cancelButtonIndex) {
                }
        })
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection: Int) -> CGFloat {
        return 30.0
    }
    
    func settingsViewControllerDidEnd(sender: IASKAppSettingsViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func settingsViewController(settingsViewController: IASKViewController?,
        tableView: UITableView,
        heightForHeaderForSection section: Int) -> CGFloat {
            
            let key = settingsViewController!.settingsReader.keyForSection(section)
            if (key == "IASKLogo") {
                return UIImage(named: "Icon.png")!.size.height + 25
            } else if (key == "IASKCustomHeaderStyle") {
                return 55
            }
            return 0
    }
    
    private func switchPasscodeType(sender: UISwitch) {
        LTHPasscodeViewController.sharedUser().setIsSimple(sender.on,
            inViewController: self,
            asModal: true)
    }
    
    private func showLockViewForEnablingPasscode() {
        LTHPasscodeViewController.sharedUser().showForEnablingPasscodeInViewController(self,
            asModal: true)
    }
    
    private func showLockViewForChangingPasscode() {
        LTHPasscodeViewController.sharedUser().showForChangingPasscodeInViewController(self, asModal: true)
    }
    
    
    private func showLockViewForTurningPasscodeOff() {
        LTHPasscodeViewController.sharedUser().showForDisablingPasscodeInViewController(self,
            asModal: true)
    }
    
    
    private func promptToConfirmOverwriteCloudWalletJSONFileWithLocalWalletJSONFile() {
        UIAlertController.showAlertInViewController(self,
            withTitle: "iCloud backup will be lost. Are you sure you want to backup your local wallet to iCloud?".localized,
            message: "",
            cancelButtonTitle: "No".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],
            
            tapBlock: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    AppDelegate.instance().saveWalletJsonCloudBackground()
                    TLPreferences.setEnableBackupWithiCloud(true)
                } else if (buttonIndex == alertView.cancelButtonIndex) {
                    TLPreferences.setEnableBackupWithiCloud(false)
                    TLPreferences.setInAppSettingsKitEnableBackupWithiCloud(false)
                }
        })
        
    }
    
    private func promptToConfirmOverwriteLocalWalletJSONFileWithCloudWalletJSONFile(encryptedWalletJSON: String) {
        UIAlertController.showAlertInViewController(self,
            withTitle: "Local wallet will be lost. Are you sure you want to restore wallet from iCloud?".localized,
            message: "",
            cancelButtonTitle: "No".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],
            
            tapBlock: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    NSNotificationCenter.defaultCenter().addObserver(self,
                        selector: "didDismissEnterMnemonicViewController:",
                        name: TLNotificationEvents.EVENT_ENTER_MNEMONIC_VIEWCONTROLLER_DISMISSED(),
                        object: nil)
                    
                    let vc = self.storyboard!.instantiateViewControllerWithIdentifier("EnterMnemonic") as! TLRestoreWalletViewController
                    vc.isRestoringFromEncryptedWalletJSON = true
                    vc.encryptedWalletJSON = encryptedWalletJSON
                    self.slidingViewController().presentViewController(vc, animated: true, completion: nil)
                } else if (buttonIndex == alertView.cancelButtonIndex) {
                    TLPreferences.setEnableBackupWithiCloud(false)
                    TLPreferences.setInAppSettingsKitEnableBackupWithiCloud(false)
                }
        })
    }
    
    func didDismissEnterMnemonicViewController(notification: NSNotification) {
        TLPreferences.setEnableBackupWithiCloud(false)
        TLPreferences.setInAppSettingsKitEnableBackupWithiCloud(false)
    }
    
    func settingDidChange(info: NSNotification) {
        let userInfo = info.userInfo! as NSDictionary
        if ((info.object as! String) == "enableadvancemode") {
            let enabled = (userInfo.objectForKey("enableadvancemode")) as! Int == 1
            TLPreferences.setAdvanceMode(enabled)
        } else if ((info.object as! String) == "canrestoredeletedapp") {
            let enabled = (userInfo.objectForKey("canrestoredeletedapp")) as! Int == 1
            
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
        } else if ((info.object as! String) == "enablesoundnotification") {
            let enabled = (userInfo.objectForKey("enablesoundnotification") as! Int) == 1
            if (enabled) {
                AudioServicesPlaySystemSound(1016)
            }
            
        } else if ((info.object as! String) == "enablebackupwithicloud") {
            let enabled = (userInfo.objectForKey("enablebackupwithicloud") as! Int) == 1
            if (enabled) {
                if !TLCloudDocumentSyncWrapper.instance().checkCloudAvailability() {
                    // don't need own alert message, OS will give warning for you
                    TLPreferences.setInAppSettingsKitEnableBackupWithiCloud(false)
                    self.updateHiddenKeys()
                    return
                }

                // Why give option to back from cloud or local? A user may want to restore from cloud backup if he get a new phone.
                TLCloudDocumentSyncWrapper.instance().getFileFromCloud(TLPreferences.getCloudBackupWalletFileName()!, completion: {
                    (cloudDocument: UIDocument!, documentData: NSData!, error: NSError!) in
                    TLHUDWrapper.hideHUDForView(self.view, animated: true)
                    if (documentData.length != 0) {
                        let cloudWalletJSONDocumentSavedDate = cloudDocument.fileModificationDate
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateStyle = .MediumStyle
                        dateFormatter.timeStyle = .MediumStyle
                        
                        let msg = String(format: "Your iCloud backup was last saved on %@. Do you want to restore your wallet from iCloud or backup your local wallet to iCloud?".localized, dateFormatter.stringFromDate(cloudWalletJSONDocumentSavedDate!))

                        UIAlertController.showAlertInViewController(self,
                            withTitle: "iCloud backup found".localized,
                            message: msg,
                            cancelButtonTitle: "Restore from iCloud".localized,
                            destructiveButtonTitle: nil,
                            otherButtonTitles: ["Backup local wallet".localized],
                            tapBlock: {(alertView, action, buttonIndex) in
                                if (buttonIndex == alertView.firstOtherButtonIndex) {
                                    self.promptToConfirmOverwriteCloudWalletJSONFileWithLocalWalletJSONFile()
                                } else if (buttonIndex == alertView.cancelButtonIndex) {
                                    let encryptedWalletJSON = NSString(data: documentData, encoding: NSUTF8StringEncoding)
                                    self.promptToConfirmOverwriteLocalWalletJSONFileWithCloudWalletJSONFile(encryptedWalletJSON! as String)
                                }
                        })
                        
                    } else {
                        TLPreferences.setEnableBackupWithiCloud(true)
                        AppDelegate.instance().saveWalletJsonCloudBackground()
                    }
                })
            } else {
                TLPreferences.setEnableBackupWithiCloud(false)
            }
        } else if ((info.object as! String) == "enablepincode") {
            let enabled = (userInfo.objectForKey("enablepincode") as! Int) == 1
            TLPreferences.setEnablePINCode(enabled)
            if (!LTHPasscodeViewController.doesPasscodeExist()) {
                self.showLockViewForEnablingPasscode()
            } else {
                self.showLockViewForTurningPasscodeOff()
            }
        } else if ((info.object as! String) == "displaylocalcurrency") {
            let enabled = (userInfo.objectForKey("displaylocalcurrency") as! Int) == 1
            TLPreferences.setDisplayLocalCurrency(enabled)
        } else if ((info.object as! String) == "enableAutomacticFee") {
            let enabled = (userInfo.objectForKey("enableAutomacticFee") as! Int) == 1
            TLPreferences.setIsAutomaticFee(enabled)
            NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_TOGGLE_AUTOMATIC_TX_FEE(), object: nil)
            self.updateHiddenKeys()
        } else if ((info.object as! String) == "currency") {
            let currencyIdx = userInfo.objectForKey("currency") as! String
            TLPreferences.setCurrency(currencyIdx)
        } else if ((info.object as! String) == "bitcoindisplay") {
            let bitcoindisplayIdx = userInfo.objectForKey("bitcoindisplay") as! String
            TLPreferences.setBitcoinDisplay(bitcoindisplayIdx)
        } else if ((info.object as! String) == "stealthaddressdefault") {
            let enabled = (userInfo.objectForKey("stealthaddressdefault") as! Int) == 1
            TLPreferences.setEnabledStealthAddressDefault(enabled)
        } else if ((info.object as! String) == "blockexplorerapi") {
            let blockexplorerAPIIdx = userInfo.objectForKey("blockexplorerapi") as! String
            TLPreferences.setBlockExplorerAPI(blockexplorerAPIIdx)
            TLPreferences.resetBlockExplorerAPIURL()
            self.updateHiddenKeys()
            
            AppDelegate.instance().giveExitAppNoticeForBlockExplorerAPIToTakeEffect = true
            
            NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_CHANGE_BLOCKEXPLORER_TYPE(), object: nil)
        }
    }
    
    func settingsViewController(sender: IASKAppSettingsViewController, buttonTappedForSpecifier specifier: IASKSpecifier) {
        if (specifier.key() == "changepincode") {
            self.showLockViewForChangingPasscode()
        } else if (specifier.key() == "emailsupport") {
            self.showEmailSupportViewController()
        } else if (specifier.key() == "showpassphrase") {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Passphrase") 
            self.slidingViewController().presentViewController(vc, animated: true, completion: nil)
        } else if (specifier.key() == "restorewallet") {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("EnterMnemonic") 
            self.slidingViewController().presentViewController(vc, animated: true, completion: nil)
            
        } else if (specifier.key() == "settransactionfee") {
            self.showPromptForSetTransactionFee()
        } else if (specifier.key() == "setblockexplorerurl") {
            self.showPromptForSetBlockExplorerURL()
        }
    }
    
    func passcodeViewControllerWillClose() {
        if (LTHPasscodeViewController.doesPasscodeExist()) {
            TLPreferences.setInAppSettingsKitEnablePinCode(true)
            TLPreferences.setEnablePINCode(true)
            NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_ENABLE_PIN_CODE(), object: nil)
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
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}