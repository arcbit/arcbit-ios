//
//  TLManageAccountsViewController.swift
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

@objc(TLManageAccountsViewController) class TLManageAccountsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomIOS7AlertViewDelegate {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    let MAX_ACTIVE_CREATED_ACCOUNTS = 8
    let MAX_IMPORTED_ACCOUNTS = 8
    let MAX_IMPORTED_ADDRESSES = 32
    @IBOutlet private var accountsTableView: UITableView?
    private var QRImageModal: TLQRImageModal?
    private var accountActionsArray: NSArray?
    private var numberOfSections: Int = 0
    private var accountListSection: Int = 0
    private var importedAccountSection: Int = 0
    private var importedWatchAccountSection: Int = 0
    private var importedAddressSection: Int = 0
    private var importedWatchAddressSection: Int = 0
    private var archivedAccountSection: Int = 0
    private var archivedImportedAccountSection: Int = 0
    private var archivedImportedWatchAccountSection: Int = 0
    private var archivedImportedAddressSection: Int = 0
    private var archivedImportedWatchAddressSection: Int = 0
    private var accountActionSection: Int = 0
    private var accountRefreshControl: UIRefreshControl?
    private var showAddressListAccountObject: TLAccountObject?
    private var showAddressListShowBalances: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()

        self.setLogoImageView()

        self.navigationController!.view.addGestureRecognizer(self.slidingViewController().panGesture)

        accountListSection = 0

        self.accountsTableView!.delegate = self
        self.accountsTableView!.dataSource = self
        self.accountsTableView!.tableFooterView = UIView(frame: CGRectZero)

        NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "refreshWalletAccountsNotification:",
                name: TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED(), object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshWalletAccountsNotification:",
                name: TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA(), object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "accountsTableViewReloadDataWrapper:",
                name: TLNotificationEvents.EVENT_ADVANCE_MODE_TOGGLED(), object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "accountsTableViewReloadDataWrapper:", name: TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_UNCONFIRMED_TRANSACTION(), object: nil)

        accountRefreshControl = UIRefreshControl()
        accountRefreshControl!.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        self.accountsTableView!.addSubview(accountRefreshControl!)

        checkToRecoverAccounts()
        refreshWalletAccounts(false)
    }

    func refresh(refresh:UIRefreshControl) -> () {
        self.refreshWalletAccounts(true)
        accountRefreshControl!.endRefreshing()
    }

    override func viewWillAppear(animated: Bool) -> () {
        // TODO: better way
        if AppDelegate.instance().scannedEncryptedPrivateKey != nil {
            TLPrompts.promptForEncryptedPrivKeyPassword(self, view:self.slidingViewController().topViewController.view,
                encryptedPrivKey:AppDelegate.instance().scannedEncryptedPrivateKey!,
                success:{(privKey: String!) in
                    let privateKey = privKey
                    let encryptedPrivateKey = AppDelegate.instance().scannedEncryptedPrivateKey
                    self.checkAndImportAddress(privateKey!, encryptedPrivateKey: encryptedPrivateKey)
                    AppDelegate.instance().scannedEncryptedPrivateKey = nil
                }, failure:{(isCanceled: Bool) in
                    AppDelegate.instance().scannedEncryptedPrivateKey = nil
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) -> () {
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_MANAGE_ACCOUNTS_SCREEN(),
                object: nil)
    }

    func checkToRecoverAccounts() {
        if (AppDelegate.instance().aAccountNeedsRecovering()) {
            TLHUDWrapper.showHUDAddedTo(self.slidingViewController().topViewController.view, labelText: "Recovering Accounts".localized, animated: true)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                AppDelegate.instance().checkToRecoverAccounts()
                dispatch_async(dispatch_get_main_queue()) {
                    self.refreshWalletAccounts(false)
                    TLHUDWrapper.hideHUDForView(self.view, animated: true)
                }
            }
        }
    }

    private func refreshImportedAccounts(fetchDataAgain: Bool) -> () {
        for (var i = 0; i < AppDelegate.instance().importedAccounts!.getNumberOfAccounts(); i++) {
            let accountObject = AppDelegate.instance().importedAccounts!.getAccountObjectForIdx(i)
            let indexPath = NSIndexPath(forRow: i, inSection: importedAccountSection)
            if self.accountsTableView!.cellForRowAtIndexPath(indexPath) == nil {
                return
            }
            if (!accountObject.hasFetchedAccountData() || fetchDataAgain) {
                let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell
                if cell != nil {
                    (cell!.accessoryView! as! UIActivityIndicatorView).hidden = false
                    cell!.accountBalanceButton!.hidden = true
                    (cell!.accessoryView! as! UIActivityIndicatorView).startAnimating()
                }
                AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: fetchDataAgain, success: {
                    if cell != nil {
                        (cell!.accessoryView as! UIActivityIndicatorView).stopAnimating()
                        (cell!.accessoryView as! UIActivityIndicatorView).hidden = true
                        cell!.accountBalanceButton!.hidden = false
                        if accountObject.downloadState == .Downloaded {
                            let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
                            cell!.accountBalanceButton!.setTitle(balance as String, forState: .Normal)
                        }
                        cell!.accountBalanceButton!.hidden = false
                    }
                })
            } else {
                if let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell {
                    cell.accountNameLabel!.text = accountObject.getAccountName()
                    let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
                    cell.accountBalanceButton!.setTitle(balance as String, forState: UIControlState.Normal)
                }
            }
        }
    }

    private func refreshImportedWatchAccounts(fetchDataAgain: Bool) -> () {
        for (var i = 0; i < AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts(); i++) {
            let accountObject = AppDelegate.instance().importedWatchAccounts!.getAccountObjectForIdx(i)
            let indexPath = NSIndexPath(forRow: i, inSection: importedWatchAccountSection)
            if self.accountsTableView!.cellForRowAtIndexPath(indexPath) == nil {
                return
            }
            if (!accountObject.hasFetchedAccountData() || fetchDataAgain) {
                let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell
                if cell != nil {
                    (cell!.accessoryView! as! UIActivityIndicatorView).hidden = false
                    (cell!.accessoryView! as! UIActivityIndicatorView).startAnimating()
                    cell!.accountBalanceButton!.hidden = true
                }
                AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: fetchDataAgain, success: {
                    if cell != nil {
                        (cell!.accessoryView as! UIActivityIndicatorView).stopAnimating()
                        (cell!.accessoryView as! UIActivityIndicatorView).hidden = true
                        cell!.accountBalanceButton!.hidden = false
                        if accountObject.downloadState == .Downloaded {
                            let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
                            cell!.accountBalanceButton!.setTitle(balance as String, forState: .Normal)
                        }
                        cell!.accountBalanceButton!.hidden = false
                    }
                })
            } else {
                if let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell {
                    cell.accountNameLabel!.text = accountObject.getAccountName()
                    let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
                    cell.accountBalanceButton!.setTitle(balance as String, forState: UIControlState.Normal)
                }
            }
        }
    }

    private func refreshImportedAddressBalances(fetchDataAgain: Bool) {
        if (AppDelegate.instance().importedAddresses!.getCount() > 0 &&
            (!AppDelegate.instance().importedAddresses!.hasFetchedAddressesData() || fetchDataAgain)) {
                for (var i = 0; i < AppDelegate.instance().importedAddresses!.getCount(); i++) {
                    let indexPath = NSIndexPath(forRow: i, inSection: importedAddressSection)
                    if let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell {
                        (cell.accessoryView as! UIActivityIndicatorView).hidden = false
                        cell.accountBalanceButton!.hidden = true
                        (cell.accessoryView as! UIActivityIndicatorView).startAnimating()
                    }
                }
                
                AppDelegate.instance().pendingOperations.addSetUpImportedAddressesOperation(AppDelegate.instance().importedAddresses!, fetchDataAgain: fetchDataAgain, success: {
                    for (var i = 0; i < AppDelegate.instance().importedAddresses!.getCount(); i++) {
                        let indexPath = NSIndexPath(forRow: i, inSection: self.importedAddressSection)
                        if let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell {
                            (cell.accessoryView as! UIActivityIndicatorView).stopAnimating()
                            (cell.accessoryView as! UIActivityIndicatorView).hidden = true
                            if AppDelegate.instance().importedAddresses!.downloadState == .Downloaded {
                                let importAddressObject = AppDelegate.instance().importedAddresses!.getAddressObjectAtIdx(i)
                                let balance = TLCurrencyFormat.getProperAmount(importAddressObject.getBalance()!)
                                cell.accountBalanceButton!.setTitle(balance as String, forState: .Normal)
                            }
                            cell.accountBalanceButton!.hidden = false
                        }
                    }
                })
        }
    }

    private func refreshImportedWatchAddressBalances(fetchDataAgain: Bool) {
        if (AppDelegate.instance().importedWatchAddresses!.getCount() > 0 && (!AppDelegate.instance().importedWatchAddresses!.hasFetchedAddressesData() || fetchDataAgain)) {
            for (var i = 0; i < AppDelegate.instance().importedWatchAddresses!.getCount(); i++) {
                let indexPath = NSIndexPath(forRow: i, inSection: importedWatchAddressSection)
                if let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell {
                    (cell.accessoryView as! UIActivityIndicatorView).hidden = false
                    cell.accountBalanceButton!.hidden = true
                    (cell.accessoryView as! UIActivityIndicatorView).startAnimating()
                }
            }
            
            AppDelegate.instance().pendingOperations.addSetUpImportedAddressesOperation(AppDelegate.instance().importedWatchAddresses!, fetchDataAgain: fetchDataAgain, success: {
                for (var i = 0; i < AppDelegate.instance().importedWatchAddresses!.getCount(); i++) {
                    let indexPath = NSIndexPath(forRow: i, inSection: self.importedWatchAddressSection)
                    if let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell {
                        (cell.accessoryView as! UIActivityIndicatorView).stopAnimating()
                        (cell.accessoryView as! UIActivityIndicatorView).hidden = true
                        
                        if AppDelegate.instance().importedWatchAddresses!.downloadState == .Downloaded {
                            let importAddressObject = AppDelegate.instance().importedWatchAddresses!.getAddressObjectAtIdx(i)
                            let balance = TLCurrencyFormat.getProperAmount(importAddressObject.getBalance()!)
                            cell.accountBalanceButton!.setTitle(balance as String, forState: .Normal)
                        }
                        cell.accountBalanceButton!.hidden = false
                    }
                }
            })
        }
    }

    private func refreshAccountBalances(fetchDataAgain: Bool) -> () {
        for (var i = 0; i < AppDelegate.instance().accounts!.getNumberOfAccounts(); i++) {
            let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx(i)
            let indexPath = NSIndexPath(forRow: i, inSection: accountListSection)
            if self.accountsTableView?.cellForRowAtIndexPath(indexPath) == nil {
                return
            }
            if (!accountObject.hasFetchedAccountData() || fetchDataAgain) {
                let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell
                if cell != nil {
                    (cell!.accessoryView! as! UIActivityIndicatorView).hidden = false
                    cell!.accountBalanceButton!.hidden = true
                    (cell!.accessoryView! as! UIActivityIndicatorView).startAnimating()
                }
                AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: fetchDataAgain, success: {
                    if cell != nil {
                        (cell!.accessoryView as! UIActivityIndicatorView).stopAnimating()
                        (cell!.accessoryView as! UIActivityIndicatorView).hidden = true
                        cell!.accountBalanceButton!.hidden = false
                        if accountObject.downloadState != .Failed {
                            let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
                            cell!.accountBalanceButton!.setTitle(balance as String, forState: .Normal)
                            cell!.accountBalanceButton!.hidden = false
                        }
                    }
                })
            } else {
                if let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell {
                    cell.accountNameLabel!.text = (accountObject.getAccountName())
                    let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
                    cell.accountBalanceButton!.setTitle(balance as String, forState: UIControlState.Normal)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> () {
        if (segue.identifier == "SegueAddressList") {
            let vc = segue.destinationViewController as! TLAddressListViewController
            vc.navigationItem.title = "Addresses".localized
            vc.accountObject = showAddressListAccountObject
            vc.showBalances = showAddressListShowBalances
        }
    }

    func refreshWalletAccountsNotification(notification: NSNotification) -> () {
        self.refreshWalletAccounts(false)
    }

    private func refreshWalletAccounts(fetchDataAgain: Bool) -> () {
        self._accountsTableViewReloadDataWrapper()
        self.refreshAccountBalances(fetchDataAgain)
        if (TLPreferences.enabledAdvancedMode()) {
            self.refreshImportedAccounts(fetchDataAgain)
            self.refreshImportedWatchAccounts(fetchDataAgain)
            self.refreshImportedAddressBalances(fetchDataAgain)
            self.refreshImportedWatchAddressBalances(fetchDataAgain)
        }
    }

    private func setUpCellAccounts(accountObject: TLAccountObject, cell: TLAccountTableViewCell, cellForRowAtIndexPath indexPath: NSIndexPath) -> () {
        cell.accountNameLabel!.hidden = false
        cell.accountBalanceButton!.hidden = false
        cell.textLabel!.hidden = true

        cell.accountNameLabel!.text = accountObject.getAccountName()

        if (accountObject.hasFetchedAccountData()) {
            (cell.accessoryView! as! UIActivityIndicatorView).hidden = true
            (cell.accessoryView! as! UIActivityIndicatorView).stopAnimating()
            let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
            cell.accountBalanceButton!.setTitle(balance as String, forState: UIControlState.Normal)
            cell.accountBalanceButton!.hidden = false
        } else {
            (cell.accessoryView! as! UIActivityIndicatorView).hidden = false
            (cell.accessoryView! as! UIActivityIndicatorView).startAnimating()
            AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: false, success: {
                (cell.accessoryView as! UIActivityIndicatorView).stopAnimating()
                (cell.accessoryView as! UIActivityIndicatorView).hidden = true
                if accountObject.downloadState == .Downloaded {
                    let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
                    cell.accountBalanceButton!.setTitle(balance as String, forState: .Normal)
                    cell.accountBalanceButton!.hidden = false
                }
            })
        }
    }

    private func setUpCellImportedAddresses(importedAddressObject: TLImportedAddress, cell: TLAccountTableViewCell, cellForRowAtIndexPath indexPath: NSIndexPath) -> () {
        cell.accountNameLabel!.hidden = false
        cell.accountBalanceButton!.hidden = false
        cell.textLabel!.hidden = true

        let label = importedAddressObject.getLabel()
        cell.accountNameLabel!.text = label


        if (importedAddressObject.hasFetchedAccountData()) {
            (cell.accessoryView! as! UIActivityIndicatorView).hidden = true
            (cell.accessoryView! as! UIActivityIndicatorView).stopAnimating()
            let balance = TLCurrencyFormat.getProperAmount(importedAddressObject.getBalance()!)
            cell.accountBalanceButton!.setTitle(balance as String, forState: UIControlState.Normal)
        }
    }

    private func setUpCellArchivedImportedAddresses(importedAddressObject: TLImportedAddress, cell: TLAccountTableViewCell, cellForRowAtIndexPath indexPath: NSIndexPath) -> () {
        cell.accountNameLabel!.hidden = true
        cell.accountBalanceButton!.hidden = true
        cell.textLabel!.hidden = false

        let label = importedAddressObject.getLabel()
        cell.textLabel!.text = label
    }

    private func setUpCellArchivedAccounts(accountObject: TLAccountObject, cell: TLAccountTableViewCell, cellForRowAtIndexPath indexPath: NSIndexPath) -> () {

        cell.accountNameLabel!.hidden = true
        cell.accountBalanceButton!.hidden = true
        cell.textLabel!.hidden = false

        cell.textLabel!.text = accountObject.getAccountName()
        (cell.accessoryView! as! UIActivityIndicatorView).hidden = true
    }

    private func promptForTempararyImportExtendedPrivateKey(success: TLWalletUtils.SuccessWithString, error: TLWalletUtils.ErrorWithString) -> () {
        UIAlertController.showAlertInViewController(self,
            withTitle: "Account private key missing".localized,
                message: "Do you want to temporary import your account private key?".localized,
                cancelButtonTitle: "NO".localized,
            destructiveButtonTitle: nil,
                otherButtonTitles: ["YES".localized],

            tapBlock: {(alertView, action, buttonIndex) in
                
                if (buttonIndex == alertView.firstOtherButtonIndex) {

                AppDelegate.instance().showExtendedPrivateKeyReaderController(self, success: {
                    (data: String!) in
                    success(data)

                }, error: {
                    (data: String?) in
                    error(data)
                })

            } else if (buttonIndex == alertView.cancelButtonIndex) {
                error("")
            }
        })
    }

    private func promtForLabel(success: TLPrompts.UserInputCallback, failure: TLPrompts.Failure) -> () {
        func addTextField(textField: UITextField!){
            textField.placeholder = "label".localized
        }
        
        UIAlertController.showAlertInViewController(self,
            withTitle: "Enter Label".localized,
            message: "",
            preferredStyle: .Alert,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Save".localized],
            preShowBlock: {(controller:UIAlertController!) in
                controller.addTextFieldWithConfigurationHandler(addTextField)
            },
            tapBlock: {(alertView, action, buttonIndex) in
            if (buttonIndex == alertView.firstOtherButtonIndex) {
                if(alertView.textFields != nil) {
                    let label = (alertView.textFields![0] ).text
                    success(label)
                }
            } else if (buttonIndex == alertView.cancelButtonIndex) {
                failure(true)
            }
        })
    }

    private func promtForNameAccount(success: TLPrompts.UserInputCallback, failure: TLPrompts.Failure) -> () {
        func addTextField(textField: UITextField!){
            textField.placeholder = "account name".localized
        }
        
        UIAlertController.showAlertInViewController(self,
            withTitle: "Enter Label".localized,
            message: "",
            preferredStyle: .Alert,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Save".localized],
            preShowBlock: {(controller:UIAlertController!) in
                controller.addTextFieldWithConfigurationHandler(addTextField)
            },
            tapBlock: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    let accountName = (alertView.textFields![0] ).text//alertView.textFieldAtIndex(0)!.text
                    
                    if (AppDelegate.instance().accounts!.accountNameExist(accountName!) == true) {
                        UIAlertController.showAlertInViewController(self,
                            withTitle: "Account name is taken".localized,
                            message: "",
                            cancelButtonTitle: "Cancel".localized,
                            destructiveButtonTitle: nil,
                            otherButtonTitles: ["Rename".localized],
                            tapBlock: {(alertView, action, buttonIndex) in
                                if (buttonIndex == alertView.firstOtherButtonIndex) {
                                    self.promtForNameAccount(success, failure: failure)
                                } else if (buttonIndex == alertView.cancelButtonIndex) {
                                    failure(true)
                                }
                        })
                    } else {
                        success(accountName)
                    }
                } else if (buttonIndex == alertView.cancelButtonIndex) {
                    failure(true)
                }
        })
    }
    
    func _accountsTableViewReloadDataWrapper() -> () {
        accountActionsArray = TLHelpDoc.getAccountActionsArray()
        
        numberOfSections = 2
        
        var sectionCounter = 1
        if (TLPreferences.enabledAdvancedMode()) {
            if (AppDelegate.instance().importedAccounts!.getNumberOfAccounts() > 0) {
                importedAccountSection = sectionCounter
                sectionCounter++
                numberOfSections++
            } else {
                importedAccountSection = NSIntegerMax
            }
            
            if (AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts() > 0) {
                importedWatchAccountSection = sectionCounter
                sectionCounter++
                numberOfSections++
            } else {
                importedWatchAccountSection = NSIntegerMax
            }
            
            if (AppDelegate.instance().importedAddresses!.getCount() > 0) {
                importedAddressSection = sectionCounter
                sectionCounter++
                numberOfSections++
            } else {
                importedAddressSection = NSIntegerMax
            }
            
            if (AppDelegate.instance().importedWatchAddresses!.getCount() > 0) {
                importedWatchAddressSection = sectionCounter
                sectionCounter++
                numberOfSections++
            } else {
                importedWatchAddressSection = NSIntegerMax
            }
        } else {
            importedAccountSection = NSIntegerMax
            importedWatchAccountSection = NSIntegerMax
            importedAddressSection = NSIntegerMax
            importedWatchAddressSection = NSIntegerMax
        }
        
        if (AppDelegate.instance().accounts!.getNumberOfArchivedAccounts() > 0) {
            archivedAccountSection = sectionCounter
            sectionCounter++
            numberOfSections++
        } else {
            archivedAccountSection = NSIntegerMax
        }
        
        
        if (TLPreferences.enabledAdvancedMode()) {
            if (AppDelegate.instance().importedAccounts!.getNumberOfArchivedAccounts() > 0) {
                archivedImportedAccountSection = sectionCounter
                sectionCounter++
                numberOfSections++
            } else {
                archivedImportedAccountSection = NSIntegerMax
            }
            
            if (AppDelegate.instance().importedWatchAccounts!.getNumberOfArchivedAccounts() > 0) {
                archivedImportedWatchAccountSection = sectionCounter
                sectionCounter++
                numberOfSections++
            } else {
                archivedImportedWatchAccountSection = NSIntegerMax
            }
            
            if (AppDelegate.instance().importedAddresses!.getArchivedCount() > 0) {
                archivedImportedAddressSection = sectionCounter
                sectionCounter++
                numberOfSections++
            } else {
                archivedImportedAddressSection = NSIntegerMax
            }
            
            if (AppDelegate.instance().importedWatchAddresses!.getArchivedCount() > 0) {
                archivedImportedWatchAddressSection = sectionCounter
                sectionCounter++
                numberOfSections++
            } else {
                archivedImportedWatchAddressSection = NSIntegerMax
            }
        } else {
            archivedImportedAccountSection = NSIntegerMax
            archivedImportedWatchAccountSection = NSIntegerMax
        }
        
        accountActionSection = sectionCounter
        
        self.accountsTableView!.reloadData()
    }
    
    func accountsTableViewReloadDataWrapper(notification: NSNotification) -> () {
        _accountsTableViewReloadDataWrapper()
    }

    private func promptAccountsActionSheet(idx: Int) -> () {
        let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx(idx)
        let accountHDIndex = accountObject.getAccountHDIndex()
        let title = String(format: "Account ID: %u".localized, accountHDIndex)
        
        let otherButtonTitles:[String]
        if (TLPreferences.enabledAdvancedMode()) {
            otherButtonTitles = ["View account public key QR code".localized, "View account private key QR code".localized, "View Addresses".localized, "Scan For Forward Address Payment".localized, "Edit Account Name".localized, "Archive Account".localized]
        } else {
            otherButtonTitles = ["View Addresses".localized, "Edit Account Name".localized, "Archive Account".localized]
        }
        
        UIAlertController.showAlertInViewController(self,
            withTitle: title,
            message: "",
            preferredStyle: .ActionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: otherButtonTitles as [AnyObject],
            tapBlock: {(actionSheet, action, buttonIndex) in
                var VIEW_EXTENDED_PUBLIC_KEY_BUTTON_IDX = actionSheet.firstOtherButtonIndex
                var VIEW_EXTENDED_PRIVATE_KEY_BUTTON_IDX = actionSheet.firstOtherButtonIndex+1
                var VIEW_ADDRESSES_BUTTON_IDX = actionSheet.firstOtherButtonIndex+2
                var MANUALLY_SCAN_TX_FOR_STEALTH_TRANSACTION_BUTTON_IDX = actionSheet.firstOtherButtonIndex+3
                var RENAME_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex+4
                var ARCHIVE_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex+5
                if (!TLPreferences.enabledAdvancedMode()) {
                    VIEW_EXTENDED_PUBLIC_KEY_BUTTON_IDX = -1
                    VIEW_EXTENDED_PRIVATE_KEY_BUTTON_IDX = -1
                    MANUALLY_SCAN_TX_FOR_STEALTH_TRANSACTION_BUTTON_IDX = -1
                    VIEW_ADDRESSES_BUTTON_IDX = actionSheet.firstOtherButtonIndex
                    RENAME_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex+1
                    ARCHIVE_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex+2
                }
                
                if (buttonIndex == VIEW_EXTENDED_PUBLIC_KEY_BUTTON_IDX) {
                    self.QRImageModal = TLQRImageModal(data: accountObject.getExtendedPubKey(), buttonCopyText: "Copy To Clipboard".localized, vc: self)
                    self.QRImageModal!.show()
                    NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY(), object: accountObject, userInfo: nil)
                    
                    
                } else if (buttonIndex == VIEW_EXTENDED_PRIVATE_KEY_BUTTON_IDX) {
                    self.QRImageModal = TLQRImageModal(data: accountObject.getExtendedPrivKey()!, buttonCopyText: "Copy To Clipboard".localized, vc: self)
                    self.QRImageModal!.show()
                    NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_EXTENDED_PRIVATE_KEY(),
                        object: accountObject, userInfo: nil)
                    
                } else if (buttonIndex == MANUALLY_SCAN_TX_FOR_STEALTH_TRANSACTION_BUTTON_IDX) {
                    self.promptInfoAndToManuallyScanForStealthTransactionAccount(accountObject)
                } else if (buttonIndex == VIEW_ADDRESSES_BUTTON_IDX) {
                    self.showAddressListAccountObject = accountObject
                    self.showAddressListShowBalances = true
                    self.performSegueWithIdentifier("SegueAddressList", sender: self)
                } else if (buttonIndex == RENAME_ACCOUNT_BUTTON_IDX) {
                    self.promtForNameAccount({
                        (accountName: String!) in
                        AppDelegate.instance().accounts!.renameAccount(accountObject.getAccountIdxNumber(), accountName: accountName)
                        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_EDIT_ACCOUNT_NAME(),
                            object: accountObject, userInfo: nil)
                        
                        self._accountsTableViewReloadDataWrapper()
                        
                        }, failure: ({
                            (isCanceled: Bool) in
                        }))
                } else if (buttonIndex == ARCHIVE_ACCOUNT_BUTTON_IDX) {
                    self.promptToArchiveAccountHDWalletAccount(accountObject)
                    
                } else if (buttonIndex == actionSheet.cancelButtonIndex) {
                    
                }
        })
    }

    private func promptImportedAccountsActionSheet(indexPath: NSIndexPath) -> () {
        let accountObject = AppDelegate.instance().importedAccounts!.getAccountObjectForIdx(indexPath.row)
        let accountHDIndex = accountObject.getAccountHDIndex()
        let title = String(format: "Account ID: %u".localized, accountHDIndex)
        
        UIAlertController.showAlertInViewController(self,
            withTitle: title,
            message: "",
            preferredStyle: .ActionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["View account public key QR code".localized, "View account private key QR code".localized, "View Addresses".localized, "Manually Scan For Forward Transaction".localized, "Edit Account Name".localized, "Archive Account".localized],
            tapBlock: {(actionSheet, action, buttonIndex) in
                if (buttonIndex == actionSheet.firstOtherButtonIndex) {
                    self.QRImageModal = TLQRImageModal(data: accountObject.getExtendedPubKey(),
                        buttonCopyText: "Copy To Clipboard".localized, vc: self)
                    self.QRImageModal!.show()
                    NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY(), object: accountObject, userInfo: nil)
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex+1) {
                    self.QRImageModal = TLQRImageModal(data: accountObject.getExtendedPrivKey()!,
                        buttonCopyText: "Copy To Clipboard".localized, vc: self)
                    self.QRImageModal!.show()
                    NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_EXTENDED_PRIVATE_KEY(), object: accountObject, userInfo: nil)
                    
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex+2) {
                    self.showAddressListAccountObject = accountObject
                    self.showAddressListShowBalances = true
                    self.performSegueWithIdentifier("SegueAddressList", sender: self)
                    
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex+3) {
                    self.promptInfoAndToManuallyScanForStealthTransactionAccount(accountObject)
                    
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex+4) {
                    
                    self.promtForNameAccount({
                        (accountName: String!) in
                        AppDelegate.instance().importedAccounts!.renameAccount(accountObject.getAccountIdxNumber(), accountName: accountName)
                        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_EDIT_ACCOUNT_NAME(), object: nil, userInfo: nil)
                        self._accountsTableViewReloadDataWrapper()
                        }
                        , failure: ({
                            (isCanceled: Bool) in
                        }))}
                else if (buttonIndex == actionSheet.firstOtherButtonIndex+5) {
                    self.promptToArchiveAccount(accountObject)
                } else if (buttonIndex == actionSheet.cancelButtonIndex) {
                }
        })
    }

    private func promptImportedWatchAccountsActionSheet(indexPath: NSIndexPath) -> () {
        let accountObject = AppDelegate.instance().importedWatchAccounts!.getAccountObjectForIdx(indexPath.row)
        let accountHDIndex = accountObject.getAccountHDIndex()
        let title = String(format: "Account ID: %u".localized, accountHDIndex)
        var addClearPrivateKeyButton = false
        let otherButtons:[String]
        if (accountObject.hasSetExtendedPrivateKeyInMemory()) {
            addClearPrivateKeyButton = true
            otherButtons = ["Clear account private key from memory".localized, "View account public key QR code".localized, "View Addresses".localized,  "Edit Account Name".localized, "Archive Account".localized]
        } else {
            otherButtons = ["View account public key QR code".localized, "View Addresses".localized, "Edit Account Name".localized, "Archive Account".localized]
        }
        
        UIAlertController.showAlertInViewController(self,
            withTitle: title,
            message:"",
            preferredStyle: .ActionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: otherButtons as [AnyObject],
            tapBlock: {(actionSheet, action, buttonIndex) in
                var CLEAR_ACCOUNT_PRIVATE_KEY_BUTTON_IDX = -1
                var VIEW_EXTENDED_PUBLIC_KEY_BUTTON_IDX = actionSheet.firstOtherButtonIndex
                var VIEW_ADDRESSES_BUTTON_IDX = actionSheet.firstOtherButtonIndex+1
                var RENAME_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex+2
                var ARCHIVE_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex+3

                if (accountObject.hasSetExtendedPrivateKeyInMemory()) {
                    CLEAR_ACCOUNT_PRIVATE_KEY_BUTTON_IDX = actionSheet.firstOtherButtonIndex
                    VIEW_EXTENDED_PUBLIC_KEY_BUTTON_IDX = actionSheet.firstOtherButtonIndex+1
                    VIEW_ADDRESSES_BUTTON_IDX = actionSheet.firstOtherButtonIndex+2
                    RENAME_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex+3
                    ARCHIVE_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex+4
                }

                if (addClearPrivateKeyButton && buttonIndex == CLEAR_ACCOUNT_PRIVATE_KEY_BUTTON_IDX) {
                assert(accountObject.hasSetExtendedPrivateKeyInMemory(), "")
                accountObject.clearExtendedPrivateKeyFromMemory()
                TLPrompts.promptSuccessMessage(nil, message: "Account private key cleared from memory".localized)
            } else if (buttonIndex == VIEW_EXTENDED_PUBLIC_KEY_BUTTON_IDX) {
                self.QRImageModal = TLQRImageModal(data: accountObject.getExtendedPubKey(),
                        buttonCopyText: "Copy To Clipboard".localized, vc: self)
                self.QRImageModal!.show()
                NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY(), object: accountObject, userInfo: nil)
            } else if (buttonIndex == VIEW_ADDRESSES_BUTTON_IDX) {
                self.showAddressListAccountObject = accountObject
                self.showAddressListShowBalances = true
                self.performSegueWithIdentifier("SegueAddressList", sender: self)

            } else if (buttonIndex == RENAME_ACCOUNT_BUTTON_IDX) {
                self.promtForNameAccount({
                    (accountName: String!) in
                    AppDelegate.instance().importedWatchAccounts!.renameAccount(accountObject.getAccountIdxNumber(), accountName: accountName)
                    self._accountsTableViewReloadDataWrapper()
                }, failure: {
                    (isCancelled: Bool) in
                })
            } else if (buttonIndex == ARCHIVE_ACCOUNT_BUTTON_IDX) {
                self.promptToArchiveAccount(accountObject)
            } else if (buttonIndex == actionSheet.cancelButtonIndex) {

            }
        })    }

    private func promptImportedAddressActionSheet(importedAddressIdx: Int) -> () {
        let importAddressObject = AppDelegate.instance().importedAddresses!.getAddressObjectAtIdx(importedAddressIdx)
        
        UIAlertController.showAlertInViewController(self,
            withTitle: nil,
            message:"",
            preferredStyle: .ActionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["View address QR code".localized, "View private key QR code".localized, "View address in web".localized, "Edit Label".localized, "Archive address".localized],
            
            tapBlock: {(actionSheet, action, buttonIndex) in
     
        
            if (buttonIndex == actionSheet.firstOtherButtonIndex) {
                self.QRImageModal = TLQRImageModal(data: importAddressObject.getAddress(), buttonCopyText: "Copy To Clipboard".localized, vc: self)
                self.QRImageModal!.show()
            } else if (buttonIndex == actionSheet.firstOtherButtonIndex+1) {
                self.QRImageModal = TLQRImageModal(data: importAddressObject.getEitherPrivateKeyOrEncryptedPrivateKey()!, buttonCopyText: "Copy To Clipboard".localized, vc: self)

                self.QRImageModal!.show()

            } else if (buttonIndex == actionSheet.firstOtherButtonIndex+2) {
                TLBlockExplorerAPI.instance().openWebViewForAddress(importAddressObject.getAddress())

            } else if (buttonIndex == actionSheet.firstOtherButtonIndex+3) {

                self.promtForLabel({
                    (inputText: String!) in

                    AppDelegate.instance().importedAddresses!.setLabel(inputText, positionInWalletArray: Int(importAddressObject.getPositionInWalletArrayNumber()))

                    self._accountsTableViewReloadDataWrapper()
                }, failure: {
                    (isCancelled: Bool) in
                })
            } else if (buttonIndex == actionSheet.firstOtherButtonIndex+4) {
                self.promptToArchiveAddress(importAddressObject)
            } else if (buttonIndex == actionSheet.cancelButtonIndex) {
            }
        })
    }

    private func promptArchivedImportedAddressActionSheet(importedAddressIdx: Int) -> () {
        let importAddressObject = AppDelegate.instance().importedAddresses!.getArchivedAddressObjectAtIdx(importedAddressIdx)
        UIAlertController.showAlertInViewController(self,
            withTitle: nil,
            message:"",
            preferredStyle: .ActionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["View address QR code".localized, "View private key QR code".localized, "View address in web".localized, "Edit Label".localized, "Unarchived address".localized, "Delete address".localized],
            
            tapBlock: {(actionSheet, action, buttonIndex) in
                
                if (buttonIndex == actionSheet.firstOtherButtonIndex) {
                    self.QRImageModal = TLQRImageModal(data: importAddressObject.getAddress(), buttonCopyText: "Copy To Clipboard".localized, vc: self)
                    
                    self.QRImageModal!.show()
                    
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex+1) {
                    self.QRImageModal = TLQRImageModal(data: importAddressObject.getEitherPrivateKeyOrEncryptedPrivateKey()!, buttonCopyText: "Copy To Clipboard".localized, vc: self)
                    
                    self.QRImageModal!.show()
                    
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex+2) {
                    TLBlockExplorerAPI.instance().openWebViewForAddress(importAddressObject.getAddress())
                    
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex+3) {
                    
                    self.promtForLabel({
                        (inputText: String!) in
                        
                        
                        AppDelegate.instance().importedAddresses!.setLabel(inputText, positionInWalletArray: Int(importAddressObject.getPositionInWalletArrayNumber()))
                        self._accountsTableViewReloadDataWrapper()
                        }, failure: ({
                            (isCanceled: Bool) in
                        }))
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex+4) {
                    self.promptToUnarchiveAddress(importAddressObject)
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex+5) {
                    self.promptToDeleteImportedAddress(importedAddressIdx)
                } else if (buttonIndex == actionSheet.cancelButtonIndex) {
                }
        })
    }

    private func promptImportedWatchAddressActionSheet(importedAddressIdx: Int) -> () {
        let importAddressObject = AppDelegate.instance().importedWatchAddresses!.getAddressObjectAtIdx(importedAddressIdx)
        var addClearPrivateKeyButton = false

        let otherButtonTitles:[String]
        if (importAddressObject.hasSetPrivateKeyInMemory()) {
            addClearPrivateKeyButton = true

            otherButtonTitles = ["Clear private key from memory".localized, "View address QR code".localized, "View address in web".localized, "Edit Label".localized, "Archive address".localized]
        } else {
            otherButtonTitles = ["View address QR code".localized, "View address in web".localized, "Edit Label".localized, "Archive address".localized]
        }

        UIAlertController.showAlertInViewController(self,
            withTitle: nil,
            message:"",
            preferredStyle: .ActionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: otherButtonTitles as [AnyObject],
            
            tapBlock: {(actionSheet, action, buttonIndex) in

                var CLEAR_PRIVATE_KEY_BUTTON_IDX = -1
                var VIEW_ADDRESS_BUTTON_IDX = actionSheet.firstOtherButtonIndex
                var VIEW_ADDRESS_IN_WEB_BUTTON_IDX = actionSheet.firstOtherButtonIndex+1
                var RENAME_ADDRESS_BUTTON_IDX = actionSheet.firstOtherButtonIndex+2
                var ARCHIVE_ADDRESS_BUTTON_IDX = actionSheet.firstOtherButtonIndex+3
                if (importAddressObject.hasSetPrivateKeyInMemory()) {
                    CLEAR_PRIVATE_KEY_BUTTON_IDX = actionSheet.firstOtherButtonIndex
                    VIEW_ADDRESS_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 1
                    VIEW_ADDRESS_IN_WEB_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 2
                    RENAME_ADDRESS_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 3
                    ARCHIVE_ADDRESS_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 4
                }

                if (addClearPrivateKeyButton && buttonIndex == CLEAR_PRIVATE_KEY_BUTTON_IDX) {
                assert(importAddressObject.hasSetPrivateKeyInMemory(), "")
                importAddressObject.clearPrivateKeyFromMemory()
                TLPrompts.promptSuccessMessage(nil, message: "Private key cleared from memory".localized)
            }
            if (buttonIndex == VIEW_ADDRESS_BUTTON_IDX) {
                self.QRImageModal = TLQRImageModal(data: importAddressObject.getAddress(),
                        buttonCopyText: "Copy To Clipboard".localized, vc: self)
                self.QRImageModal!.show()

            } else if (buttonIndex == VIEW_ADDRESS_IN_WEB_BUTTON_IDX) {
                TLBlockExplorerAPI.instance().openWebViewForAddress(importAddressObject.getAddress())

            } else if (buttonIndex == RENAME_ADDRESS_BUTTON_IDX) {

                self.promtForLabel({
                    (inputText: String!) in

                    AppDelegate.instance().importedWatchAddresses!.setLabel(inputText, positionInWalletArray: Int(importAddressObject.getPositionInWalletArrayNumber()))
                    self._accountsTableViewReloadDataWrapper()
                }, failure: ({
                    (isCanceled: Bool) in
                }))
            } else if (buttonIndex == ARCHIVE_ADDRESS_BUTTON_IDX) {
                self.promptToArchiveAddress(importAddressObject)
            } else if (buttonIndex == actionSheet.cancelButtonIndex) {

            }
        })    }

    private func promptArchivedImportedWatchAddressActionSheet(importedAddressIdx: Int) -> () {
        let importAddressObject = AppDelegate.instance().importedWatchAddresses!.getArchivedAddressObjectAtIdx(importedAddressIdx)
        var addClearPrivateKeyButton = false
        let otherButtonTitles:[String]
        if (importAddressObject.hasSetPrivateKeyInMemory()) {
            addClearPrivateKeyButton = true
            otherButtonTitles = ["Clear private key from memory".localized, "View address QR code".localized, "View address in web".localized, "Edit Label".localized, "Unarchived address".localized, "Delete address".localized]
        } else {
            otherButtonTitles = ["View address QR code".localized, "View address in web".localized, "Edit Label".localized, "Unarchived address".localized, "Delete address".localized]
        }

        UIAlertController.showAlertInViewController(self,
            withTitle: nil,
            message:"",
            preferredStyle: .ActionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: otherButtonTitles as [AnyObject],
            
            tapBlock: {(actionSheet, action, buttonIndex) in

                var CLEAR_PRIVATE_KEY_BUTTON_IDX = -1
                var VIEW_ADDRESS_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 0
                var VIEW_ADDRESS_IN_WEB_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 1
                var RENAME_ADDRESS_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 2
                var UNARCHIVE_ADDRESS_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 3
                var DELETE_ADDRESS_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 4
                if (importAddressObject.hasSetPrivateKeyInMemory()) {
                    CLEAR_PRIVATE_KEY_BUTTON_IDX = actionSheet.firstOtherButtonIndex
                    VIEW_ADDRESS_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 1
                    VIEW_ADDRESS_IN_WEB_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 2
                    RENAME_ADDRESS_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 3
                    UNARCHIVE_ADDRESS_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 4
                    DELETE_ADDRESS_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 5
                } else {
                }

                if (addClearPrivateKeyButton && buttonIndex == CLEAR_PRIVATE_KEY_BUTTON_IDX) {
                assert(importAddressObject.hasSetPrivateKeyInMemory(), "")
                importAddressObject.clearPrivateKeyFromMemory()
                TLPrompts.promptSuccessMessage(nil, message: "Private key cleared from memory".localized)
            }
            if (buttonIndex == VIEW_ADDRESS_BUTTON_IDX) {
                self.QRImageModal = TLQRImageModal(data: importAddressObject.getAddress(),
                        buttonCopyText: "Copy To Clipboard".localized, vc: self)
                self.QRImageModal!.show()

            } else if (buttonIndex == VIEW_ADDRESS_IN_WEB_BUTTON_IDX) {
                TLBlockExplorerAPI.instance().openWebViewForAddress(importAddressObject.getAddress())

            } else if (buttonIndex == RENAME_ADDRESS_BUTTON_IDX) {

                self.promtForLabel({
                    (inputText: String!) in
                    
                    AppDelegate.instance().importedWatchAddresses!.setLabel(inputText, positionInWalletArray: Int(importAddressObject.getPositionInWalletArrayNumber()))
                    self._accountsTableViewReloadDataWrapper()
                    }, failure: ({
                        (isCanceled: Bool) in
                    }))
            } else if (buttonIndex == UNARCHIVE_ADDRESS_BUTTON_IDX) {
                self.promptToUnarchiveAddress(importAddressObject)
            } else if (buttonIndex == DELETE_ADDRESS_BUTTON_IDX) {
                self.promptToDeleteImportedWatchAddress(importedAddressIdx)
            } else if (buttonIndex == actionSheet.cancelButtonIndex) {

            }
        })
    }

    private func promptArchivedImportedAccountsActionSheet(indexPath: NSIndexPath, accountType: TLAccountType) -> () {
        assert(accountType == .Imported || accountType == .ImportedWatch, "not TLAccountTypeImported or TLAccountTypeImportedWatch")
        var accountObject: TLAccountObject?
        if (accountType == .Imported) {
            accountObject = AppDelegate.instance().importedAccounts!.getArchivedAccountObjectForIdx(indexPath.row)
        } else if (accountType == .ImportedWatch) {
            accountObject = AppDelegate.instance().importedWatchAccounts!.getArchivedAccountObjectForIdx(indexPath.row)
        }
        
        let accountHDIndex = accountObject!.getAccountHDIndex()
        let title = String(format: "Account ID: %u".localized, accountHDIndex)
        let otherButtonTitles:[String]
        if (accountObject!.getAccountType() == .Imported) {
            otherButtonTitles = ["View account public key QR code".localized, "View account private key QR code".localized, "View Addresses".localized, "Edit Account Name".localized, "Unarchive Account".localized, "Delete Account".localized]
        } else {
            otherButtonTitles = ["View account public key QR code".localized, "View Addresses".localized, "Edit Account Name".localized, "Unarchive Account".localized, "Delete Account".localized]
        }
        
        UIAlertController.showAlertInViewController(self,
            withTitle: title,
            message:"",
            preferredStyle: .ActionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: otherButtonTitles as [AnyObject],
            
            tapBlock: {(actionSheet, action, buttonIndex) in
                let VIEW_EXTENDED_PUBLIC_KEY_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 0
                var VIEW_EXTENDED_PRIVATE_KEY_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 1
                var VIEW_ADDRESSES_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 2
                var RENAME_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 3
                var UNARCHIVE_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 4
                var DELETE_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 5
                if (accountObject!.getAccountType() == .Imported) {
                } else {
                    VIEW_EXTENDED_PRIVATE_KEY_BUTTON_IDX = -1
                    VIEW_ADDRESSES_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 1
                    RENAME_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 2
                    UNARCHIVE_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 3
                    DELETE_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 4
                }
                if (buttonIndex == VIEW_EXTENDED_PUBLIC_KEY_BUTTON_IDX) {
                    self.QRImageModal = TLQRImageModal(data: accountObject!.getExtendedPubKey(),
                        buttonCopyText: "Copy To Clipboard".localized, vc: self)
                    self.QRImageModal!.show()
                    NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY(),
                        object: accountObject, userInfo: nil)
                    
                } else if (buttonIndex == VIEW_EXTENDED_PRIVATE_KEY_BUTTON_IDX) {
                    self.QRImageModal = TLQRImageModal(data: accountObject!.getExtendedPrivKey()!,
                        buttonCopyText: "Copy To Clipboard".localized, vc: self)
                    self.QRImageModal!.show()
                    NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY(),
                        object: accountObject, userInfo: nil)
                    
                } else if (buttonIndex == VIEW_ADDRESSES_BUTTON_IDX) {
                    self.showAddressListAccountObject = accountObject
                    self.showAddressListShowBalances = false
                    self.performSegueWithIdentifier("SegueAddressList", sender: self)
                } else if (buttonIndex == RENAME_ACCOUNT_BUTTON_IDX) {
                    self.promtForNameAccount({
                        (accountName: String!) in
                        if (accountType == .Imported) {
                            AppDelegate.instance().importedAccounts!.renameAccount(accountObject!.getAccountIdxNumber(), accountName: accountName)
                        } else if (accountType == .ImportedWatch) {
                            AppDelegate.instance().importedWatchAccounts!.renameAccount(accountObject!.getAccountIdxNumber(), accountName: accountName)
                        }
                        self._accountsTableViewReloadDataWrapper()
                        }, failure: ({
                            (isCanceled: Bool) in
                        }))
                } else if (buttonIndex == UNARCHIVE_ACCOUNT_BUTTON_IDX) {
                    if (AppDelegate.instance().importedAccounts!.getNumberOfAccounts() + AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts() >= self.MAX_IMPORTED_ACCOUNTS) {
                        TLPrompts.promptErrorMessage("Maximum accounts reached".localized, message: "You need to archived an account in order to unarchive a different one.".localized)
                        return
                    }
                    
                    self.promptToUnarchiveAccount(accountObject!)
                } else if (buttonIndex == DELETE_ACCOUNT_BUTTON_IDX) {
                    if (accountType == .Imported) {
                        self.promptToDeleteImportedAccount(indexPath)
                    } else if (accountType == .ImportedWatch) {
                        self.promptToDeleteImportedWatchAccount(indexPath)
                    }
                } else if (buttonIndex == actionSheet.cancelButtonIndex) {
                    
                }
        })
    }

    private func promptArchivedAccountsActionSheet(idx: Int) -> () {
        let accountObject = AppDelegate.instance().accounts!.getArchivedAccountObjectForIdx(idx)
        let accountHDIndex = accountObject.getAccountHDIndex()
        let title = String(format: "Account ID: %u".localized, accountHDIndex)
        let otherButtonTitles:[String]
        if (TLPreferences.enabledAdvancedMode()) {
            otherButtonTitles = ["View account public key QR code".localized, "View account private key QR code".localized, "View Addresses".localized, "Edit Account Name".localized, "Unarchive Account".localized]
        } else {
            otherButtonTitles = ["View Addresses".localized, "Edit Account Name".localized, "Unarchive Account".localized]
        }

        UIAlertController.showAlertInViewController(self,
            withTitle: title,
            message:"",
            preferredStyle: .ActionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: otherButtonTitles as [AnyObject],
            tapBlock: {(actionSheet, action, buttonIndex) in
                var VIEW_EXTENDED_PUBLIC_KEY_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 0
                var VIEW_EXTENDED_PRIVATE_KEY_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 1
                var VIEW_ADDRESSES_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 2
                var RENAME_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 3
                var UNARCHIVE_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 4
                if (!TLPreferences.enabledAdvancedMode()) {
                    VIEW_EXTENDED_PUBLIC_KEY_BUTTON_IDX = -1
                    VIEW_EXTENDED_PRIVATE_KEY_BUTTON_IDX = -1
                    VIEW_ADDRESSES_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 0
                    RENAME_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 1
                    UNARCHIVE_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex + 2
                }
            
            if (buttonIndex == VIEW_EXTENDED_PUBLIC_KEY_BUTTON_IDX) {
                self.QRImageModal = TLQRImageModal(data: accountObject.getExtendedPubKey(),
                        buttonCopyText: "Copy To Clipboard".localized, vc: self)
                self.QRImageModal!.show()
                NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY(), object: accountObject, userInfo: nil)

            } else if (buttonIndex == VIEW_EXTENDED_PRIVATE_KEY_BUTTON_IDX) {
                self.QRImageModal = TLQRImageModal(data: accountObject.getExtendedPrivKey()!,
                        buttonCopyText: "Copy To Clipboard".localized, vc: self)
                self.QRImageModal!.show()
                NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_EXTENDED_PRIVATE_KEY(), object: accountObject, userInfo: nil)

            } else if (buttonIndex == VIEW_ADDRESSES_BUTTON_IDX) {
                self.showAddressListAccountObject = accountObject
                self.showAddressListShowBalances = false
                self.performSegueWithIdentifier("SegueAddressList", sender: self)
            } else if (buttonIndex == RENAME_ACCOUNT_BUTTON_IDX) {
                self.promtForNameAccount({
                    (accountName: String!) in
                    AppDelegate.instance().accounts!.renameAccount(accountObject.getAccountIdxNumber(), accountName: accountName)
                    self._accountsTableViewReloadDataWrapper()
                }, failure: ({
                    (isCanceled: Bool) in
                }))
            } else if (buttonIndex == UNARCHIVE_ACCOUNT_BUTTON_IDX) {
                if (AppDelegate.instance().accounts!.getNumberOfAccounts() >= self.MAX_ACTIVE_CREATED_ACCOUNTS) {
                    TLPrompts.promptErrorMessage("Maximum accounts reached.".localized, message: "You need to archived an account in order to unarchive a different one.".localized)
                    return
                }

                self.promptToUnarchiveAccount(accountObject)

            } else if (buttonIndex == actionSheet!.cancelButtonIndex) {

            }
        })
    }

    private func promptToManuallyScanForStealthTransactionAccount(accountObject: TLAccountObject) -> () {
        func addTextField(textField: UITextField!){
            textField.placeholder = "Transaction ID".localized
        }
        
        UIAlertController.showAlertInViewController(self,
            withTitle: "Scan for forward address transaction".localized,
            message: "",
            preferredStyle: .Alert,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],
            
            preShowBlock: {(controller:UIAlertController!) in
                controller.addTextFieldWithConfigurationHandler(addTextField)
            }
            ,
            tapBlock: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    let txid = (alertView.textFields![0] ).text
                    self.manuallyScanForStealthTransactionAccount(accountObject, txid: txid!)
                } else if (buttonIndex == alertView.cancelButtonIndex) {
                    
                }
            }
        )
    }

    private func manuallyScanForStealthTransactionAccount(accountObject: TLAccountObject, txid: String) -> () {
        if accountObject.stealthWallet!.paymentTxidExist(txid) {
            TLPrompts.promptSuccessMessage("", message: String(format: "Transaction %@ already accounted for.".localized, txid))
            return
        }
        
        if txid.characters.count != 64 || TLWalletUtils.hexStringToData(txid) == nil {
            TLPrompts.promptErrorMessage("Inputed Txid is invalid".localized, message: "Txid must be a 64 character hex string.".localized)
            return
        }

        TLHUDWrapper.showHUDAddedTo(self.slidingViewController().topViewController.view, labelText: "Checking Transaction".localized, animated: true)

        TLBlockExplorerAPI.instance().getTx(txid, success: {
            (jsonData: AnyObject?) in
            let stealthDataScriptAndOutputAddresses = TLStealthWallet.getStealthDataScriptAndOutputAddresses(jsonData as! NSDictionary)
            if stealthDataScriptAndOutputAddresses == nil || stealthDataScriptAndOutputAddresses!.stealthDataScript == nil {
                TLHUDWrapper.hideHUDForView(self.view, animated: true)
                TLPrompts.promptSuccessMessage("", message: "Txid is not a forward address transaction.".localized)
                return
            }
            
            let scanPriv = accountObject.stealthWallet!.getStealthAddressScanKey()
            let spendPriv = accountObject.stealthWallet!.getStealthAddressSpendKey()
            let stealthDataScript = stealthDataScriptAndOutputAddresses!.stealthDataScript!
            if let secret = TLStealthAddress.getPaymentAddressPrivateKeySecretFromScript(stealthDataScript, scanPrivateKey: scanPriv, spendPrivateKey: spendPriv) {
                let paymentAddress = TLCoreBitcoinWrapper.getAddressFromSecret(secret, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)
                if (stealthDataScriptAndOutputAddresses!.outputAddresses).indexOf((paymentAddress!)) != nil {
                    
                    TLBlockExplorerAPI.instance().getUnspentOutputs([paymentAddress!], success: {
                        (jsonData2: AnyObject!) in
                        let unspentOutputs = (jsonData2 as! NSDictionary).objectForKey("unspent_outputs") as! NSArray!
                        if (unspentOutputs.count > 0) {
                            let privateKey = TLCoreBitcoinWrapper.privateKeyFromSecret(secret, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)
                            let txObject = TLTxObject(dict:jsonData as! NSDictionary)
                            let txTime = txObject.getTxUnixTime()
                            accountObject.stealthWallet!.addStealthAddressPaymentKey(privateKey, paymentAddress: paymentAddress!,
                                txid: txid, txTime: txTime, stealthPaymentStatus: TLStealthPaymentStatus.Unspent)
                            
                            TLHUDWrapper.hideHUDForView(self.view, animated: true)
                            TLPrompts.promptSuccessMessage("Success".localized, message: String(format: "Transaction %@ belongs to this account. Funds imported".localized, txid))
                            
                            AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: true, success: {
                                self.refreshWalletAccounts(false)
                            })
                        } else {
                            TLHUDWrapper.hideHUDForView(self.view, animated: true)
                            TLPrompts.promptSuccessMessage("", message: "Funds have been claimed already.".localized)
                        }
                        }, failure: {(code: Int, status: String!) in
                            TLHUDWrapper.hideHUDForView(self.view, animated: true)
                            TLPrompts.promptSuccessMessage("", message: "Funds have been claimed already.".localized)
                    })
                } else {
                    TLHUDWrapper.hideHUDForView(self.view, animated: true)
                    TLPrompts.promptSuccessMessage("", message: String(format: "Transaction %@ does not belong to this account.".localized, txid))
                }
            } else {
                TLHUDWrapper.hideHUDForView(self.view, animated: true)
                TLPrompts.promptSuccessMessage("", message: String(format: "Transaction %@ does not belong to this account.".localized, txid))
            }
            
            }, failure: {
                (code: Int, status: String!) in
                TLHUDWrapper.hideHUDForView(self.view, animated: true)
                TLPrompts.promptSuccessMessage("Error".localized, message: "Error fetching Transaction.".localized)
        })
    }
    
    private func promptInfoAndToManuallyScanForStealthTransactionAccount(accountObject: TLAccountObject) -> () {
        if (TLSuggestions.instance().enabledShowManuallyScanTransactionForStealthTxInfo()) {
            TLPrompts.promtForOK(self, title:"", message: "This feature allows you to manually input a transaction id and see if the corresponding transaction contains a forwarding payment to your forward address. If so, then the funds will be added to your wallet. Normally the app will discover forwarding payments automatically for you, but if you believe a payment is missing you can use this feature.".localized, success: {
                () in
                self.promptToManuallyScanForStealthTransactionAccount(accountObject)
                TLSuggestions.instance().setEnabledShowManuallyScanTransactionForStealthTxInfo(false)
            })
        } else {
            self.promptToManuallyScanForStealthTransactionAccount(accountObject)
        }
    }

    private func promptToUnarchiveAccount(accountObject: TLAccountObject) -> () {
        UIAlertController.showAlertInViewController(self,
            withTitle: "Unarchive account".localized,
            message: String(format: "Are you sure you want to unarchive account %@".localized, accountObject.getAccountName()),
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],
            tapBlock: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    if (accountObject.getAccountType() == .HDWallet) {
                        AppDelegate.instance().accounts!.unarchiveAccount(accountObject.getAccountIdxNumber())
                    } else if (accountObject.getAccountType() == .Imported) {
                        AppDelegate.instance().importedAccounts!.unarchiveAccount(accountObject.getPositionInWalletArray())
                    } else if (accountObject.getAccountType() == .ImportedWatch) {
                        AppDelegate.instance().importedWatchAccounts!.unarchiveAccount(accountObject.getPositionInWalletArray())
                    }
                    
                    if !accountObject.isWatchOnly() && !accountObject.stealthWallet!.hasUpdateStealthPaymentStatuses {
                        accountObject.stealthWallet!.updateStealthPaymentStatusesAsync()
                    }
                    self._accountsTableViewReloadDataWrapper()
                    AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: true, success: {
                        self._accountsTableViewReloadDataWrapper()
                    })
                } else if (buttonIndex == alertView.cancelButtonIndex) {
                }
            }
        )
    }

    private func promptToArchiveAccount(accountObject: TLAccountObject) -> () {
        UIAlertController.showAlertInViewController(self,
            withTitle:  "Archive account".localized,
            message: String(format: "Are you sure you want to archive account %@?".localized, accountObject.getAccountName()),
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],

            tapBlock: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    if (accountObject.getAccountType() == .HDWallet) {
                        AppDelegate.instance().accounts!.archiveAccount(accountObject.getAccountIdxNumber())
                    } else if (accountObject.getAccountType() == .Imported) {
                        AppDelegate.instance().importedAccounts!.archiveAccount(accountObject.getPositionInWalletArray())
                    } else if (accountObject.getAccountType() == .ImportedWatch) {
                        AppDelegate.instance().importedWatchAccounts!.archiveAccount(accountObject.getPositionInWalletArray())
                    }
                    self._accountsTableViewReloadDataWrapper()
                    NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_ARCHIVE_ACCOUNT(), object: nil, userInfo: nil)
                } else if (buttonIndex == alertView.cancelButtonIndex) {
                }
            }
        )
    }

    private func promptToArchiveAccountHDWalletAccount(accountObject: TLAccountObject) -> () {
        if (accountObject.getAccountIdxNumber() == 0) {
            let av = UIAlertView(title: "Cannot archive your default account".localized,
                    message: "",
                    delegate: nil,
                    cancelButtonTitle: nil,
                    otherButtonTitles: "OK".localized)

            av.show()
        } else if (AppDelegate.instance().accounts!.getNumberOfAccounts() <= 1) {
            let av = UIAlertView(title: "Cannot archive your one and only account".localized,
                    message: "",
                    delegate: nil,
                    cancelButtonTitle: nil,
                    otherButtonTitles: "OK".localized)

            av.show()
        } else {
            self.promptToArchiveAccount(accountObject)
        }
    }

    private func promptToArchiveAddress(importedAddressObject: TLImportedAddress) -> () {
        UIAlertController.showAlertInViewController(self,
            withTitle: "Archive address".localized,
            message: String(format: "Are you sure you want to archive address %@".localized, importedAddressObject.getLabel()),
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],
            tapBlock: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    if (importedAddressObject.isWatchOnly()) {
                        AppDelegate.instance().importedWatchAddresses!.archiveAddress(Int(importedAddressObject.getPositionInWalletArrayNumber()))
                    } else {
                        AppDelegate.instance().importedAddresses!.archiveAddress(Int(importedAddressObject.getPositionInWalletArrayNumber()))
                    }
                    self._accountsTableViewReloadDataWrapper()
                    NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_ARCHIVE_ACCOUNT(), object: nil, userInfo: nil)
                } else if (buttonIndex == alertView.cancelButtonIndex) {
                    
                }
            }
        )
    }

    private func promptToUnarchiveAddress(importedAddressObject: TLImportedAddress) -> () {
        UIAlertController.showAlertInViewController(self,
            withTitle: "Unarchive address".localized,
            message:  String(format: "Are you sure you want to unarchive address %@?".localized, importedAddressObject.getLabel()),
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],
            tapBlock: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    if (importedAddressObject.isWatchOnly()) {
                        AppDelegate.instance().importedWatchAddresses!.unarchiveAddress(Int(importedAddressObject.getPositionInWalletArrayNumber()))
                    } else {
                        AppDelegate.instance().importedAddresses!.unarchiveAddress(Int(importedAddressObject.getPositionInWalletArrayNumber()))
                    }
                    self._accountsTableViewReloadDataWrapper()
                    importedAddressObject.getSingleAddressData({
                        () in
                        self._accountsTableViewReloadDataWrapper()
                        }, failure: {
                            () in
                            
                    })
                } else if (buttonIndex == alertView.cancelButtonIndex) {
                    
                }
            }
        )
    }

    private func promptToDeleteImportedAccount(indexPath: NSIndexPath) -> () {
        let accountObject = AppDelegate.instance().importedAccounts!.getArchivedAccountObjectForIdx(indexPath.row)

        UIAlertController.showAlertInViewController(self,
            withTitle: String(format: "Delete %@".localized, accountObject.getAccountName()),
            message: "Are you sure you want to delete this account?".localized,
            cancelButtonTitle: "No".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],
            tapBlock: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    AppDelegate.instance().importedAccounts!.deleteAccount(indexPath.row)
                    
                    self.accountsTableView!.beginUpdates()
                    let index = NSIndexPath(indexes: [self.archivedImportedAccountSection, indexPath.row], length:2)
                    let deleteIndexPaths = [index]
                    self.accountsTableView!.deleteRowsAtIndexPaths(deleteIndexPaths, withRowAnimation: .Fade)
                    self.accountsTableView!.endUpdates()
                    self._accountsTableViewReloadDataWrapper()
                } else if (buttonIndex == alertView.cancelButtonIndex) {
                    self.accountsTableView!.editing = false
                }
            }
        )
    }

    private func promptToDeleteImportedWatchAccount(indexPath: NSIndexPath) -> () {
        let accountObject = AppDelegate.instance().importedWatchAccounts!.getArchivedAccountObjectForIdx(indexPath.row)
        
        UIAlertController.showAlertInViewController(self,
            withTitle: String(format: "Delete %@".localized, accountObject.getAccountName()),
            message: "Are you sure you want to delete this account?".localized,
            cancelButtonTitle: "No".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],
            tapBlock: {(alertView, action, buttonIndex) in
                
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    AppDelegate.instance().importedWatchAccounts!.deleteAccount(indexPath.row)
                    //*
                    self.accountsTableView!.beginUpdates()
                    let index = NSIndexPath(indexes:[self.archivedImportedWatchAccountSection, indexPath.row], length:2)
                    let deleteIndexPaths = [index]
                    self.accountsTableView!.deleteRowsAtIndexPaths(deleteIndexPaths, withRowAnimation: .Fade)
                    self.accountsTableView!.endUpdates()
                    //*/
                    self._accountsTableViewReloadDataWrapper()
                } else if (buttonIndex == alertView.cancelButtonIndex) {
                    self.accountsTableView!.editing = false
                }
        })
    }

    private func promptToDeleteImportedAddress(importedAddressIdx: Int) -> () {
        let importedAddressObject = AppDelegate.instance().importedAddresses!.getArchivedAddressObjectAtIdx(importedAddressIdx)

        UIAlertController.showAlertInViewController(self,
            withTitle: String(format: "Delete %@".localized, importedAddressObject.getLabel()),
            message: "Are you sure you want to delete this account?".localized,
            cancelButtonTitle: "No".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],
            tapBlock: {(alertView, action, buttonIndex) in
        
            if (buttonIndex == alertView.firstOtherButtonIndex) {
                self.accountsTableView!.setEditing(true, animated: true)
                AppDelegate.instance().importedAddresses!.deleteAddress(importedAddressIdx)
                self._accountsTableViewReloadDataWrapper()
                self.accountsTableView!.setEditing(false, animated: true)
            } else if (buttonIndex == alertView.cancelButtonIndex) {
                self.accountsTableView!.editing = false
            }
        })
    }

    private func promptToDeleteImportedWatchAddress(importedAddressIdx: Int) -> () {
        let importedAddressObject = AppDelegate.instance().importedWatchAddresses!.getArchivedAddressObjectAtIdx(importedAddressIdx)

        UIAlertController.showAlertInViewController(self,
            withTitle:  String(format: "Delete %@", importedAddressObject.getLabel()),
            message: "Are you sure you want to delete this watch only address?",
            cancelButtonTitle: "No",
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes"],

            tapBlock: {(alertView, action, buttonIndex) in

            if (buttonIndex == alertView.firstOtherButtonIndex) {
                self.accountsTableView!.setEditing(true, animated: true)
                AppDelegate.instance().importedWatchAddresses!.deleteAddress(importedAddressIdx)
                self._accountsTableViewReloadDataWrapper()
                self.accountsTableView!.setEditing(false, animated: true)
            } else if (buttonIndex == alertView.cancelButtonIndex) {
                self.accountsTableView!.editing = false
            }
        })
    }

    private func setEditingAndRefreshAccounts() -> () {
        self.accountsTableView!.setEditing(true, animated: true)
        self.refreshWalletAccounts(false)
        self._accountsTableViewReloadDataWrapper()
        self.accountsTableView!.setEditing(false, animated: true)
    }
    
    private func importAccount(extendedPrivateKey: String) -> (Bool) {
        let handleImportAccountFail = {
            dispatch_async(dispatch_get_main_queue()) {
                AppDelegate.instance().importedAccounts!.deleteAccount(AppDelegate.instance().importedAccounts!.getNumberOfAccounts() - 1)
                TLHUDWrapper.hideHUDForView(self.view, animated: true)
                TLPrompts.promptErrorMessage("Error importing account".localized, message: "")
                self.setEditingAndRefreshAccounts()
            }
        }
        
        if (TLHDWalletWrapper.isValidExtendedPrivateKey(extendedPrivateKey)) {
            AppDelegate.instance().saveWalletJsonCloudBackground()
            AppDelegate.instance().saveWalletJSONEnabled = false
            let accountObject = AppDelegate.instance().importedAccounts!.addAccountWithExtendedKey(extendedPrivateKey)
            TLHUDWrapper.showHUDAddedTo(self.slidingViewController().topViewController.view, labelText: "Importing Account".localized, animated: true)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                SwiftTryCatch.`try`({
                    () -> () in
                    accountObject.recoverAccount(false, recoverStealthPayments: true)
                    AppDelegate.instance().saveWalletJSONEnabled = true
                    AppDelegate.instance().saveWalletJsonCloudBackground()
                    
                    let handleImportAccountSuccess = {
                        dispatch_async(dispatch_get_main_queue()) {
                            TLHUDWrapper.hideHUDForView(self.view, animated: true)
                            self.promtForNameAccount({
                                (_accountName: String?) in
                                var accountName = _accountName
                                if (accountName == nil || accountName == "") {
                                    accountName = accountObject.getDefaultNameAccount()
                                }
                                AppDelegate.instance().importedAccounts!.renameAccount(accountObject.getAccountIdxNumber(), accountName: accountName!)
                                let av = UIAlertView(title: String(format: "Account %@ imported".localized, accountName!),
                                    message: nil,
                                    delegate: nil,
                                    cancelButtonTitle: "OK".localized)
                                
                                av.show()
                                self.setEditingAndRefreshAccounts()
                                }, failure: ({
                                    (isCanceled: Bool) in
                                    self.setEditingAndRefreshAccounts()
                                }))
                        }
                    }
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_IMPORT_ACCOUNT(),
                        object: nil, userInfo: nil)
                    TLStealthWebSocket.instance().sendMessageGetChallenge()
                    AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: true, success: {
                        self.refreshWalletAccounts(false)
                        handleImportAccountSuccess()
                    })
                }, `catch`: {
                        (e: NSException!) -> Void in
                    handleImportAccountFail()
                    
                }, finally: { () in })
            }
            return true

        } else {
            let av = UIAlertView(title: "Invalid account private key".localized,
                    message: "",
                    delegate: nil,
                    cancelButtonTitle: "OK".localized,
                    otherButtonTitles: "")

            av.show()
            return false
        }
    }

    private func importWatchOnlyAccount(extendedPublicKey: String) -> (Bool) {
        if (TLHDWalletWrapper.isValidExtendedPublicKey(extendedPublicKey)) {
            AppDelegate.instance().saveWalletJsonCloudBackground()
            AppDelegate.instance().saveWalletJSONEnabled = false
            let accountObject = AppDelegate.instance().importedWatchAccounts!.addAccountWithExtendedKey(extendedPublicKey)
            
            TLHUDWrapper.showHUDAddedTo(self.slidingViewController().topViewController.view, labelText: "Importing Watch Account".localized, animated: true)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                SwiftTryCatch.`try`({
                    () -> () in
                    accountObject.recoverAccount(false, recoverStealthPayments: true)
                    AppDelegate.instance().saveWalletJSONEnabled = true
                    AppDelegate.instance().saveWalletJsonCloudBackground()

                    NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_IMPORT_WATCH_ONLY_ACCOUNT(),
                        object: nil)
                    // don't need to call do accountObject.getAccountData like in importAccount() cause watch only account does not see stealth payments. yet
                    dispatch_async(dispatch_get_main_queue()) {
                        TLHUDWrapper.hideHUDForView(self.view, animated: true)
                        self.promtForNameAccount({
                            (_accountName: String?) in
                                var accountName = _accountName
                                if (accountName == nil || accountName == "") {
                                    accountName = accountObject.getDefaultNameAccount()
                                }
                                AppDelegate.instance().importedWatchAccounts!.renameAccount(accountObject.getAccountIdxNumber(), accountName: accountName!)
                            
                                let titleStr = String(format: "Account %@ imported".localized, accountName!)
                                let av = UIAlertView(title: titleStr,
                                    message: "",
                                    delegate: nil,
                                    cancelButtonTitle: "OK".localized)
                            
                                av.show()
                                self.setEditingAndRefreshAccounts()
                            }, failure: {
                                (isCanceled: Bool) in
                                
                                self.setEditingAndRefreshAccounts()
                        })
                    }
                }, `catch`: {
                    (exception: NSException!) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        AppDelegate.instance().importedWatchAccounts!.deleteAccount(AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts() - 1)
                        TLHUDWrapper.hideHUDForView(self.view, animated: true)
                        TLPrompts.promptErrorMessage("Error importing watch only account".localized, message: "Try Again".localized)
                        self.setEditingAndRefreshAccounts()
                    }
                }, finally: { () in })
            }
            
            return true
        } else {
            let av = UIAlertView(title: "Invalid account public Key".localized,
                message: "",
                delegate: nil,
                cancelButtonTitle: "OK".localized,
                otherButtonTitles: "")
            
            av.show()
            return false
        }
    }

    private func checkAndImportAddress(privateKey: String, encryptedPrivateKey: String?) -> (Bool) {        
        if (TLCoreBitcoinWrapper.isValidPrivateKey(privateKey, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)) {
            if (encryptedPrivateKey != nil) {
                UIAlertController.showAlertInViewController(self,
                    withTitle: "Import private key encrypted or unencrypted?".localized,
                    message: "Importing key encrypted will require you to input the password everytime you want to send bitcoins from it.".localized,
                    cancelButtonTitle: "encrypted".localized,
                    destructiveButtonTitle: nil,
                    otherButtonTitles: ["unencrypted".localized],

                    tapBlock: {(alertView, action, buttonIndex) in
                    if (buttonIndex == alertView.firstOtherButtonIndex) {
                        let importedAddressObject = AppDelegate.instance().importedAddresses!.addImportedPrivateKey(privateKey,
                                encryptedPrivateKey: nil)
                        self.refreshAfterImportAddress(importedAddressObject)
                    } else if (buttonIndex == alertView.cancelButtonIndex) {
                        let importedAddressObject = AppDelegate.instance().importedAddresses!.addImportedPrivateKey(privateKey,
                                encryptedPrivateKey: encryptedPrivateKey)
                        self.refreshAfterImportAddress(importedAddressObject)
                    }
                })
            } else {
                let importedAddressObject = AppDelegate.instance().importedAddresses!.addImportedPrivateKey(privateKey,
                    encryptedPrivateKey: nil)
                self.refreshAfterImportAddress(importedAddressObject)
            }

            return true
        } else {
            let av = UIAlertView(title: "Invalid private key".localized,
                    message: "",
                    delegate: nil,
                    cancelButtonTitle: "OK".localized)

            av.show()
            return false
        }
    }

    private func refreshAfterImportAddress(importedAddressObject: TLImportedAddress) -> () {
        let lastIdx = AppDelegate.instance().importedAddresses!.getCount()
        let indexPath = NSIndexPath(forRow: lastIdx, inSection: importedAddressSection)
        let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell
        if cell != nil {
            (cell!.accessoryView! as! UIActivityIndicatorView).hidden = false
            (cell!.accessoryView! as! UIActivityIndicatorView).startAnimating()
        }

        importedAddressObject.getSingleAddressData({
            () in
            if cell != nil {
                (cell!.accessoryView! as! UIActivityIndicatorView).stopAnimating()
                (cell!.accessoryView! as! UIActivityIndicatorView).hidden = true
                
                let balance = TLCurrencyFormat.getProperAmount(importedAddressObject.getBalance()!)
                cell!.accountBalanceButton!.setTitle(balance as String, forState: UIControlState.Normal)
                self.setEditingAndRefreshAccounts()
            }
        }, failure: {
            () in
            if cell != nil {
                (cell!.accessoryView! as! UIActivityIndicatorView).stopAnimating()
                (cell!.accessoryView! as! UIActivityIndicatorView).hidden = true
            }
        })

        let address = importedAddressObject.getAddress()
        let msg = String(format: "Address %@ imported".localized, address)
        let av = UIAlertView(title: msg,
                message: "",
                delegate: nil,
                cancelButtonTitle: "OK".localized)

        av.show()

        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_IMPORT_PRIVATE_KEY(), object: nil, userInfo: nil)
    }

    private func checkAndImportWatchAddress(address: String) -> (Bool) {
        if (TLCoreBitcoinWrapper.isValidAddress(address, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)) {
            if (TLStealthAddress.isStealthAddress(address, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)) {
                TLPrompts.promptErrorMessage("Error".localized, message: "Cannot import forward address".localized)
                return false
            }
            
            let importedAddressObject = AppDelegate.instance().importedWatchAddresses!.addImportedWatchAddress(address)
            let lastIdx = AppDelegate.instance().importedWatchAddresses!.getCount()
            let indexPath = NSIndexPath(forRow: lastIdx, inSection: importedWatchAddressSection)
            let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell
            if cell != nil {
                (cell!.accessoryView! as! UIActivityIndicatorView).hidden = false
                (cell!.accessoryView! as! UIActivityIndicatorView).startAnimating()
            }
            importedAddressObject.getSingleAddressData(
                {
                    () in
                    if cell != nil {
                        (cell!.accessoryView! as! UIActivityIndicatorView).stopAnimating()
                        (cell!.accessoryView! as! UIActivityIndicatorView).hidden = true
                        
                        let balance = TLCurrencyFormat.getProperAmount(importedAddressObject.getBalance()!)
                        cell!.accountBalanceButton!.setTitle(balance as String, forState: UIControlState.Normal)
                        self.setEditingAndRefreshAccounts()
                    }
                }, failure: {
                    () in
                    if cell != nil {
                        (cell!.accessoryView! as! UIActivityIndicatorView).stopAnimating()
                        (cell!.accessoryView! as! UIActivityIndicatorView).hidden = true
                    }
            })
            
            let av = UIAlertView(title: String(format: "Address %@ imported".localized, address),
                message: "",
                delegate: nil,
                cancelButtonTitle: "OK".localized)
            
            av.show()
            NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_IMPORT_WATCH_ONLY_ADDRESS(), object: nil, userInfo: nil)
            return true
        } else {
            TLPrompts.promptErrorMessage("Invalid address".localized, message: "")
            return false
        }
    }


    private func promptImportAccountActionSheet() -> () {
        UIAlertController.showAlertInViewController(self,
            withTitle: "Import Account".localized,
            message:"",
            preferredStyle: .ActionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Import via QR code".localized, "Import via text input".localized],
            tapBlock: {(actionSheet, action, buttonIndex) in
            if (buttonIndex == actionSheet.firstOtherButtonIndex + 0) {
                AppDelegate.instance().showExtendedPrivateKeyReaderController(self, success: {
                    (data: String!) in
                    self.importAccount(data)
                }, error: {
                    (data: String?) in
                })

            } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
                TLPrompts.promtForInputText(self, title: "Import Account".localized, message: "Input account private key".localized, textFieldPlaceholder: nil, success: {
                    (inputText: String!) in
                    self.importAccount(inputText)
                }, failure: {
                    (isCanceled: Bool) in
                })
            } else if (buttonIndex == actionSheet.cancelButtonIndex) {
            }
        })
    }

    private func promptImportWatchAccountActionSheet() -> () {
        UIAlertController.showAlertInViewController(self,
            withTitle: "Import Watch Account".localized,
            message:"",
            preferredStyle: .ActionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Import via QR code".localized, "Import via text input".localized],
            tapBlock: {(actionSheet, action, buttonIndex) in
                if (buttonIndex == actionSheet.firstOtherButtonIndex + 0) {
                    AppDelegate.instance().showExtendedPublicKeyReaderController(self, success: {
                        (data: String!) in
                        self.importWatchOnlyAccount(data)
                        }, error: {
                            (data: String?) in
                    })
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
                    TLPrompts.promtForInputText(self, title: "Import Watch Account", message: "Input account public key", textFieldPlaceholder: nil, success: {
                        (inputText: String!) in
                        self.importWatchOnlyAccount(inputText)
                        }, failure: {
                            (isCanceled: Bool) in
                    })
                } else if (buttonIndex == actionSheet.cancelButtonIndex) {
                }
        })
    }

    private func promptImportPrivateKeyActionSheet() -> () {
        UIAlertController.showAlertInViewController(self,
            withTitle: "Import Private Key".localized,
            message:"",
            preferredStyle: .ActionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Import via QR code".localized, "Import via text input".localized],
            tapBlock: {(actionSheet, action, buttonIndex) in
                if (buttonIndex == actionSheet.firstOtherButtonIndex + 0) {
                    AppDelegate.instance().showPrivateKeyReaderController(self, success: {
                        (data: NSDictionary) in
                        let privateKey = data.objectForKey("privateKey") as? String
                        let encryptedPrivateKey = data.objectForKey("encryptedPrivateKey") as? String
                        if encryptedPrivateKey == nil {
                            self.checkAndImportAddress(privateKey!, encryptedPrivateKey: encryptedPrivateKey)
                        }
                        }, error: {
                            (data: String?) in
                    })
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
                    TLPrompts.promtForInputText(self, title: "Import Private Key".localized, message: "Input private key".localized, textFieldPlaceholder: nil, success: {
                        (inputText: String!) in
                        if (TLCoreBitcoinWrapper.isBIP38EncryptedKey(inputText, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)) {
                            TLPrompts.promptForEncryptedPrivKeyPassword(self, view:self.slidingViewController().topViewController.view, encryptedPrivKey: inputText, success: {
                                (privKey: String!) in
                                self.checkAndImportAddress(privKey, encryptedPrivateKey: inputText)
                                }, failure: {
                                    (isCanceled: Bool) in
                            })
                        } else {
                            self.checkAndImportAddress(inputText, encryptedPrivateKey: nil)
                        }
                        }, failure: {
                            (isCanceled: Bool) in
                    })
                } else if (buttonIndex == actionSheet.cancelButtonIndex) {
                }
        })
    }

    private func promptImportWatchAddressActionSheet() -> () {
        UIAlertController.showAlertInViewController(self,
            withTitle: "Import Watch Address".localized,
            message:"",
            preferredStyle: .ActionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Import via QR code".localized, "Import via text input".localized],
            tapBlock: {(actionSheet, action, buttonIndex) in
                if (buttonIndex == actionSheet.firstOtherButtonIndex + 0) {
                    AppDelegate.instance().showAddressReaderControllerFromViewController(self, success: {
                        (data: String!) in
                        self.checkAndImportWatchAddress(data)
                        }, error: {
                            (data: String?) in
                    })
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
                    TLPrompts.promtForInputText(self, title: "Import Watch Address".localized, message: "Input watch address".localized, textFieldPlaceholder: nil, success: {
                        (inputText: String!) in
                        self.checkAndImportWatchAddress(inputText)
                        }, failure: {
                            (isCanceled: Bool) in
                    })
                } else if (buttonIndex == actionSheet.cancelButtonIndex) {
                }
        })
    }

    private func doAccountAction(accountSelectIdx: Int) -> () {
        if (accountSelectIdx == 0) {
            if (AppDelegate.instance().accounts!.getNumberOfAccounts() >= MAX_ACTIVE_CREATED_ACCOUNTS) {
                TLPrompts.promptErrorMessage("Maximum accounts reached".localized, message: "You need to archive an account in order to create a new one.".localized)
                return
            }

            self.promtForNameAccount({
                (accountName: String!) in
                AppDelegate.instance().accounts!.createNewAccount(accountName, accountType: .Normal)

                NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_CREATE_NEW_ACCOUNT(), object: nil, userInfo: nil)

                self.refreshWalletAccounts(false)
                TLStealthWebSocket.instance().sendMessageGetChallenge()
            }, failure: {
                (isCanceled: Bool) in
            })
        } else if (accountSelectIdx == 1) {
            if (AppDelegate.instance().importedAccounts!.getNumberOfAccounts() + AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts() >= MAX_IMPORTED_ACCOUNTS) {
                TLPrompts.promptErrorMessage("Maximum imported accounts and watch only accounts reached.".localized, message: "You need to archive an imported account or imported watch only account in order to import a new one.".localized)
                return
            }
            self.promptImportAccountActionSheet()
        } else if (accountSelectIdx == 2) {
            if (AppDelegate.instance().importedAccounts!.getNumberOfAccounts() + AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts() >= MAX_IMPORTED_ACCOUNTS) {
                TLPrompts.promptErrorMessage("Maximum imported accounts and watch only accounts reached.".localized, message: "You need to archive an imported account or imported watch only account in order to import a new one.".localized)
                return
            }
            self.promptImportWatchAccountActionSheet()
        } else if (accountSelectIdx == 3) {
            if (AppDelegate.instance().importedAddresses!.getCount() + AppDelegate.instance().importedWatchAddresses!.getCount() >= MAX_IMPORTED_ADDRESSES) {
                TLPrompts.promptErrorMessage("Maximum imported addresses and private keys reached.".localized, message: "You need to archive an imported private key or address in order to import a new one.".localized)
                return
            }
            self.promptImportPrivateKeyActionSheet()
        } else if (accountSelectIdx == 4) {
            if (AppDelegate.instance().importedAddresses!.getCount() + AppDelegate.instance().importedWatchAddresses!.getCount() >= MAX_IMPORTED_ADDRESSES) {
                TLPrompts.promptErrorMessage("Maximum imported addresses and private keys reached.".localized, message: "You need to archive an imported private key or address in order to import a new one.".localized)
                return
            }
            self.promptImportWatchAddressActionSheet()
        }
    }

    @IBAction private func menuButtonClicked(sender: UIButton) {
        self.slidingViewController().anchorTopViewToRightAnimated(true)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath: NSIndexPath) -> CGFloat {
        // hard code height here to prevent cell auto-resizing
        return 74
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numberOfSections
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (TLPreferences.enabledAdvancedMode()) {
            if (section == accountListSection) {
                return "Accounts".localized
            } else if (section == importedAccountSection) {
                return "Imported Accounts".localized
            } else if (section == importedWatchAccountSection) {
                return "Imported Watch Accounts".localized
            } else if (section == importedAddressSection) {
                return "Imported Addresses".localized
            } else if (section == importedWatchAddressSection) {
                return "Imported Watch Addresses".localized
            } else if (section == archivedAccountSection) {
                return "Archived Accounts".localized
            } else if (section == archivedImportedAccountSection) {
                return "Archived Imported Accounts".localized
            } else if (section == archivedImportedWatchAccountSection) {
                return "Archived Imported Watch Accounts".localized
            } else if (section == archivedImportedAddressSection) {
                return "Archived Imported Addresses".localized
            } else if (section == archivedImportedWatchAddressSection) {
                return "Archived Imported Watch Addresses".localized
            } else {
                return "Account Actions".localized
            }
        } else {
            if (section == accountListSection) {
                return "Accounts".localized
            } else if (section == archivedAccountSection) {
                return "Archived Accounts".localized } else {
                return "Account Actions".localized
            }
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (TLPreferences.enabledAdvancedMode()) {
            if (section == accountListSection) {
                return AppDelegate.instance().accounts!.getNumberOfAccounts()
            } else if (section == importedAccountSection) {
                return AppDelegate.instance().importedAccounts!.getNumberOfAccounts()
            } else if (section == importedWatchAccountSection) {
                return AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts()
            } else if (section == importedAddressSection) {
                return AppDelegate.instance().importedAddresses!.getCount()
            } else if (section == importedWatchAddressSection) {
                return AppDelegate.instance().importedWatchAddresses!.getCount()
            } else if (section == archivedAccountSection) {
                return AppDelegate.instance().accounts!.getNumberOfArchivedAccounts()
            } else if (section == archivedImportedAccountSection) {
                return AppDelegate.instance().importedAccounts!.getNumberOfArchivedAccounts()
            } else if (section == archivedImportedWatchAccountSection) {
                return AppDelegate.instance().importedWatchAccounts!.getNumberOfArchivedAccounts()
            } else if (section == archivedImportedAddressSection) {
                return AppDelegate.instance().importedAddresses!.getArchivedCount()
            } else if (section == archivedImportedWatchAddressSection) {
                return AppDelegate.instance().importedWatchAddresses!.getArchivedCount()
            } else {
                return accountActionsArray!.count
            }
        } else if (section == accountListSection) {
            return AppDelegate.instance().accounts!.getNumberOfAccounts()
        } else if (section == archivedAccountSection) {
            return AppDelegate.instance().accounts!.getNumberOfArchivedAccounts()
        } else {
            return accountActionsArray!.count
        }
    }


    private func setUpCellAccountActions(cell: UITableViewCell, cellForRowAtIndexPath indexPath: NSIndexPath) -> () {
        cell.accessoryType = UITableViewCellAccessoryType.None
        cell.textLabel!.text = accountActionsArray!.objectAtIndex(indexPath.row) as? String
        if(cell.accessoryView != nil) {
            (cell.accessoryView as! UIActivityIndicatorView).hidden = true
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == accountActionSection) {
            let MyIdentifier = "AccountActionCellIdentifier"

            var cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier) 
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.Default,
                        reuseIdentifier: MyIdentifier)
            }

            cell!.textLabel!.textAlignment = .Center
            cell!.textLabel!.font = UIFont.boldSystemFontOfSize(cell!.textLabel!.font.pointSize)
            self.setUpCellAccountActions(cell!, cellForRowAtIndexPath: indexPath)

            if (indexPath.row % 2 == 0) {
                cell!.backgroundColor = TLColors.evenTableViewCellColor()
            } else {
                cell!.backgroundColor = TLColors.oddTableViewCellColor()
            }

            return cell!
        } else {
            let MyIdentifier = "AccountCellIdentifier"

            var cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier) as? TLAccountTableViewCell
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.Default,
                        reuseIdentifier: MyIdentifier) as? TLAccountTableViewCell
            }

            cell!.accountNameLabel!.textAlignment = .Natural
            let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            cell!.accessoryView = activityView

            if (TLPreferences.enabledAdvancedMode()) {
                if (indexPath.section == accountListSection) {
                    let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx(indexPath.row)
                    self.setUpCellAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if (indexPath.section == importedAccountSection) {
                    let accountObject = AppDelegate.instance().importedAccounts!.getAccountObjectForIdx(indexPath.row)

                    self.setUpCellAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)

                } else if (indexPath.section == importedWatchAccountSection) {
                    let accountObject = AppDelegate.instance().importedWatchAccounts!.getAccountObjectForIdx(indexPath.row)
                    self.setUpCellAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if (indexPath.section == importedAddressSection) {
                    let importedAddressObject = AppDelegate.instance().importedAddresses!.getAddressObjectAtIdx(indexPath.row)
                    self.setUpCellImportedAddresses(importedAddressObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if (indexPath.section == importedWatchAddressSection) {
                    let importedAddressObject = AppDelegate.instance().importedWatchAddresses!.getAddressObjectAtIdx(indexPath.row)
                    self.setUpCellImportedAddresses(importedAddressObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if (indexPath.section == archivedAccountSection) {
                    let accountObject = AppDelegate.instance().accounts!.getArchivedAccountObjectForIdx(indexPath.row)
                    self.setUpCellArchivedAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if (indexPath.section == archivedImportedAccountSection) {
                    let accountObject = AppDelegate.instance().importedAccounts!.getArchivedAccountObjectForIdx(indexPath.row)
                    self.setUpCellArchivedAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if (indexPath.section == archivedImportedWatchAccountSection) {
                    let accountObject = AppDelegate.instance().importedWatchAccounts!.getArchivedAccountObjectForIdx(indexPath.row)
                    self.setUpCellArchivedAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if (indexPath.section == archivedImportedAddressSection) {
                    let importedAddressObject = AppDelegate.instance().importedAddresses!.getArchivedAddressObjectAtIdx(indexPath.row)
                    self.setUpCellArchivedImportedAddresses(importedAddressObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if (indexPath.section == archivedImportedWatchAddressSection) {
                    let importedAddressObject = AppDelegate.instance().importedWatchAddresses!.getArchivedAddressObjectAtIdx(indexPath.row)
                    self.setUpCellArchivedImportedAddresses(importedAddressObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else {
                }
            } else {
                if (indexPath.section == accountListSection) {
                    let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx(indexPath.row)
                    self.setUpCellAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if (indexPath.section == archivedAccountSection) {
                    let accountObject = AppDelegate.instance().accounts!.getArchivedAccountObjectForIdx(indexPath.row)
                    self.setUpCellArchivedAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else {
                }
            }

            if (indexPath.row % 2 == 0) {
                cell!.backgroundColor = TLColors.evenTableViewCellColor()
            } else {
                cell!.backgroundColor = TLColors.oddTableViewCellColor()
            }

            return cell!
        }
    }

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if (TLPreferences.enabledAdvancedMode()) {
            if (indexPath.section == accountListSection) {
                self.promptAccountsActionSheet(indexPath.row)
                return nil
            } else if (indexPath.section == importedAccountSection) {
                self.promptImportedAccountsActionSheet(indexPath)
                return nil
            } else if (indexPath.section == importedWatchAccountSection) {
                self.promptImportedWatchAccountsActionSheet(indexPath)
                return nil
            } else if (indexPath.section == importedAddressSection) {
                self.promptImportedAddressActionSheet(indexPath.row)
                return nil
            } else if (indexPath.section == importedWatchAddressSection) {
                self.promptImportedWatchAddressActionSheet(indexPath.row)
                return nil
            } else if (indexPath.section == archivedAccountSection) {
                self.promptArchivedAccountsActionSheet(indexPath.row)
                return nil
            } else if (indexPath.section == archivedImportedAccountSection) {
                self.promptArchivedImportedAccountsActionSheet(indexPath, accountType: .Imported)
                return nil
            } else if (indexPath.section == archivedImportedWatchAccountSection) {
                self.promptArchivedImportedAccountsActionSheet(indexPath, accountType: .ImportedWatch)
                return nil
            } else if (indexPath.section == archivedImportedAddressSection) {
                self.promptArchivedImportedAddressActionSheet(indexPath.row)
                return nil
            } else if (indexPath.section == archivedImportedWatchAddressSection) {
                self.promptArchivedImportedWatchAddressActionSheet(indexPath.row)
                return nil
            } else {
                self.doAccountAction(indexPath.row)
                return nil
            }
        } else {
            if (indexPath.section == accountListSection) {
                self.promptAccountsActionSheet(indexPath.row)
                return nil
            } else if (indexPath.section == archivedAccountSection) {
                self.promptArchivedAccountsActionSheet(indexPath.row)
                return nil
            } else {
                self.doAccountAction(indexPath.row)
                return nil
            }
        }
    }

    func customIOS7dialogButtonTouchUpInside(alertView: AnyObject!, clickedButtonAtIndex buttonIndex: Int) -> () {
        if (buttonIndex == 0) {
            iToast.makeText("Copied To clipboard".localized).setGravity(iToastGravityCenter).setDuration(1000).show()
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = self.QRImageModal!.QRcodeDisplayData
        } else {

        }

        alertView.close()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}