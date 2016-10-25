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
    let MAX_IMPORTED_ACCOUNTS = 12
    let MAX_IMPORTED_ADDRESSES = 32
    @IBOutlet fileprivate var accountsTableView: UITableView?
    fileprivate var QRImageModal: TLQRImageModal?
    fileprivate var accountActionsArray: NSArray?
    fileprivate var numberOfSections: Int = 0
    fileprivate var accountListSection: Int = 0
    fileprivate var coldWalletAccountSection: Int = 0
    fileprivate var importedAccountSection: Int = 0
    fileprivate var importedWatchAccountSection: Int = 0
    fileprivate var importedAddressSection: Int = 0
    fileprivate var importedWatchAddressSection: Int = 0
    fileprivate var archivedAccountSection: Int = 0
    fileprivate var archivedColdWalletAccountSection: Int = 0
    fileprivate var archivedImportedAccountSection: Int = 0
    fileprivate var archivedImportedWatchAccountSection: Int = 0
    fileprivate var archivedImportedAddressSection: Int = 0
    fileprivate var archivedImportedWatchAddressSection: Int = 0
    fileprivate var accountActionSection: Int = 0
    fileprivate var accountRefreshControl: UIRefreshControl?
    fileprivate var showAddressListAccountObject: TLAccountObject?
    fileprivate var showAddressListShowBalances: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()

        self.setLogoImageView()

        self.navigationController!.view.addGestureRecognizer(self.slidingViewController().panGesture)

        accountListSection = 0

        self.accountsTableView!.delegate = self
        self.accountsTableView!.dataSource = self
        self.accountsTableView!.tableFooterView = UIView(frame: CGRect.zero)

        NotificationCenter.default.addObserver(self,
                selector: #selector(TLManageAccountsViewController.refreshWalletAccountsNotification(_:)),
                name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED()), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(TLManageAccountsViewController.refreshWalletAccountsNotification(_:)),
                name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA()), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(TLManageAccountsViewController.accountsTableViewReloadDataWrapper(_:)),
                name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_ADVANCE_MODE_TOGGLED()), object: nil)

        NotificationCenter.default.addObserver(self,
                selector: #selector(TLManageAccountsViewController.accountsTableViewReloadDataWrapper(_:)), name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_UNCONFIRMED_TRANSACTION()), object: nil)

        accountRefreshControl = UIRefreshControl()
        accountRefreshControl!.addTarget(self, action: #selector(TLManageAccountsViewController.refresh(_:)), for: .valueChanged)
        self.accountsTableView!.addSubview(accountRefreshControl!)

        checkToRecoverAccounts()
        refreshWalletAccounts(false)
    }

    func refresh(_ refresh:UIRefreshControl) -> () {
        self.refreshWalletAccounts(true)
        accountRefreshControl!.endRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) -> () {
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
    
    override func viewDidAppear(_ animated: Bool) -> () {
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_MANAGE_ACCOUNTS_SCREEN()),
                object: nil)
    }

    func checkToRecoverAccounts() {
        if (AppDelegate.instance().aAccountNeedsRecovering()) {
            TLHUDWrapper.showHUDAddedTo(self.slidingViewController().topViewController.view, labelText: "Recovering Accounts".localized, animated: true)
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
                AppDelegate.instance().checkToRecoverAccounts()
                DispatchQueue.main.async {
                    self.refreshWalletAccounts(false)
                    TLHUDWrapper.hideHUDForView(self.view, animated: true)
                }
            }
        }
    }

    fileprivate func refreshColdWalletAccounts(_ fetchDataAgain: Bool) -> () {
        for i in stride(from: 0, through: AppDelegate.instance().coldWalletAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = AppDelegate.instance().coldWalletAccounts!.getAccountObjectForIdx(i)
            let indexPath = IndexPath(row: i, section: coldWalletAccountSection)
            if self.accountsTableView!.cellForRow(at: indexPath) == nil {
                return
            }
            if (!accountObject.hasFetchedAccountData() || fetchDataAgain) {
                let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell
                if cell != nil {
                    (cell!.accessoryView! as! UIActivityIndicatorView).isHidden = false
                    (cell!.accessoryView! as! UIActivityIndicatorView).startAnimating()
                    cell!.accountBalanceButton!.isHidden = true
                }
                AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: fetchDataAgain, success: {
                    if cell != nil {
                        (cell!.accessoryView as! UIActivityIndicatorView).stopAnimating()
                        (cell!.accessoryView as! UIActivityIndicatorView).isHidden = true
                        cell!.accountBalanceButton!.isHidden = false
                        if accountObject.downloadState == .downloaded {
                            let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
                            cell!.accountBalanceButton!.setTitle(balance as String, for: UIControlState())
                        }
                        cell!.accountBalanceButton!.isHidden = false
                    }
                })
            } else {
                if let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell {
                    cell.accountNameLabel!.text = accountObject.getAccountName()
                    let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
                    cell.accountBalanceButton!.setTitle(balance as String, for: UIControlState())
                }
            }
        }
    }
    
    fileprivate func refreshImportedAccounts(_ fetchDataAgain: Bool) -> () {
        for i in stride(from: 0, through: AppDelegate.instance().importedAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = AppDelegate.instance().importedAccounts!.getAccountObjectForIdx(i)
            let indexPath = IndexPath(row: i, section: importedAccountSection)
            if self.accountsTableView!.cellForRow(at: indexPath) == nil {
                return
            }
            if (!accountObject.hasFetchedAccountData() || fetchDataAgain) {
                let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell
                if cell != nil {
                    (cell!.accessoryView! as! UIActivityIndicatorView).isHidden = false
                    cell!.accountBalanceButton!.isHidden = true
                    (cell!.accessoryView! as! UIActivityIndicatorView).startAnimating()
                }
                AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: fetchDataAgain, success: {
                    if cell != nil {
                        (cell!.accessoryView as! UIActivityIndicatorView).stopAnimating()
                        (cell!.accessoryView as! UIActivityIndicatorView).isHidden = true
                        cell!.accountBalanceButton!.isHidden = false
                        if accountObject.downloadState == .downloaded {
                            let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
                            cell!.accountBalanceButton!.setTitle(balance as String, for: UIControlState())
                        }
                        cell!.accountBalanceButton!.isHidden = false
                    }
                })
            } else {
                if let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell {
                    cell.accountNameLabel!.text = accountObject.getAccountName()
                    let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
                    cell.accountBalanceButton!.setTitle(balance as String, for: UIControlState())
                }
            }
        }
    }

    fileprivate func refreshImportedWatchAccounts(_ fetchDataAgain: Bool) -> () {
        for i in stride(from: 0, through: AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = AppDelegate.instance().importedWatchAccounts!.getAccountObjectForIdx(i)
            let indexPath = IndexPath(row: i, section: importedWatchAccountSection)
            if self.accountsTableView!.cellForRow(at: indexPath) == nil {
                return
            }
            if (!accountObject.hasFetchedAccountData() || fetchDataAgain) {
                let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell
                if cell != nil {
                    (cell!.accessoryView! as! UIActivityIndicatorView).isHidden = false
                    (cell!.accessoryView! as! UIActivityIndicatorView).startAnimating()
                    cell!.accountBalanceButton!.isHidden = true
                }
                AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: fetchDataAgain, success: {
                    if cell != nil {
                        (cell!.accessoryView as! UIActivityIndicatorView).stopAnimating()
                        (cell!.accessoryView as! UIActivityIndicatorView).isHidden = true
                        cell!.accountBalanceButton!.isHidden = false
                        if accountObject.downloadState == .downloaded {
                            let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
                            cell!.accountBalanceButton!.setTitle(balance as String, for: UIControlState())
                        }
                        cell!.accountBalanceButton!.isHidden = false
                    }
                })
            } else {
                if let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell {
                    cell.accountNameLabel!.text = accountObject.getAccountName()
                    let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
                    cell.accountBalanceButton!.setTitle(balance as String, for: UIControlState())
                }
            }
        }
    }

    fileprivate func refreshImportedAddressBalances(_ fetchDataAgain: Bool) {
        if (AppDelegate.instance().importedAddresses!.getCount() > 0 &&
            (!AppDelegate.instance().importedAddresses!.hasFetchedAddressesData() || fetchDataAgain)) {
            for i in stride(from: 0, through: AppDelegate.instance().importedAddresses!.getCount(), by: 1) {
                    let indexPath = IndexPath(row: i, section: importedAddressSection)
                    if let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell {
                        (cell.accessoryView as! UIActivityIndicatorView).isHidden = false
                        cell.accountBalanceButton!.isHidden = true
                        (cell.accessoryView as! UIActivityIndicatorView).startAnimating()
                    }
                }
                
                AppDelegate.instance().pendingOperations.addSetUpImportedAddressesOperation(AppDelegate.instance().importedAddresses!, fetchDataAgain: fetchDataAgain, success: {
                    for (var i = 0; i < AppDelegate.instance().importedAddresses!.getCount(); i++) {
                        let indexPath = IndexPath(row: i, section: self.importedAddressSection)
                        if let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell {
                            (cell.accessoryView as! UIActivityIndicatorView).stopAnimating()
                            (cell.accessoryView as! UIActivityIndicatorView).isHidden = true
                            if AppDelegate.instance().importedAddresses!.downloadState == .downloaded {
                                let importAddressObject = AppDelegate.instance().importedAddresses!.getAddressObjectAtIdx(i)
                                let balance = TLCurrencyFormat.getProperAmount(importAddressObject.getBalance()!)
                                cell.accountBalanceButton!.setTitle(balance as String, for: UIControlState())
                            }
                            cell.accountBalanceButton!.isHidden = false
                        }
                    }
                })
        }
    }

    fileprivate func refreshImportedWatchAddressBalances(_ fetchDataAgain: Bool) {
        if (AppDelegate.instance().importedWatchAddresses!.getCount() > 0 && (!AppDelegate.instance().importedWatchAddresses!.hasFetchedAddressesData() || fetchDataAgain)) {
            for i in stride(from: 0, through: AppDelegate.instance().importedWatchAddresses!.getCount(), by: 1) {
                let indexPath = IndexPath(row: i, section: importedWatchAddressSection)
                if let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell {
                    (cell.accessoryView as! UIActivityIndicatorView).isHidden = false
                    cell.accountBalanceButton!.isHidden = true
                    (cell.accessoryView as! UIActivityIndicatorView).startAnimating()
                }
            }
            
            AppDelegate.instance().pendingOperations.addSetUpImportedAddressesOperation(AppDelegate.instance().importedWatchAddresses!, fetchDataAgain: fetchDataAgain, success: {
                for (var i = 0; i < AppDelegate.instance().importedWatchAddresses!.getCount(); i++) {
                    let indexPath = IndexPath(row: i, section: self.importedWatchAddressSection)
                    if let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell {
                        (cell.accessoryView as! UIActivityIndicatorView).stopAnimating()
                        (cell.accessoryView as! UIActivityIndicatorView).isHidden = true
                        
                        if AppDelegate.instance().importedWatchAddresses!.downloadState == .downloaded {
                            let importAddressObject = AppDelegate.instance().importedWatchAddresses!.getAddressObjectAtIdx(i)
                            let balance = TLCurrencyFormat.getProperAmount(importAddressObject.getBalance()!)
                            cell.accountBalanceButton!.setTitle(balance as String, for: UIControlState())
                        }
                        cell.accountBalanceButton!.isHidden = false
                    }
                }
            })
        }
    }

    fileprivate func refreshAccountBalances(_ fetchDataAgain: Bool) -> () {
        for i in stride(from: 0, through: AppDelegate.instance().accounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx(i)
            let indexPath = IndexPath(row: i, section: accountListSection)
            if self.accountsTableView?.cellForRow(at: indexPath) == nil {
                return
            }
            if (!accountObject.hasFetchedAccountData() || fetchDataAgain) {
                let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell
                if cell != nil {
                    (cell!.accessoryView! as! UIActivityIndicatorView).isHidden = false
                    cell!.accountBalanceButton!.isHidden = true
                    (cell!.accessoryView! as! UIActivityIndicatorView).startAnimating()
                }
                AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: fetchDataAgain, success: {
                    if cell != nil {
                        (cell!.accessoryView as! UIActivityIndicatorView).stopAnimating()
                        (cell!.accessoryView as! UIActivityIndicatorView).isHidden = true
                        cell!.accountBalanceButton!.isHidden = false
                        if accountObject.downloadState != .failed {
                            let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
                            cell!.accountBalanceButton!.setTitle(balance as String, for: UIControlState())
                            cell!.accountBalanceButton!.isHidden = false
                        }
                    }
                })
            } else {
                if let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell {
                    cell.accountNameLabel!.text = (accountObject.getAccountName())
                    let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
                    cell.accountBalanceButton!.setTitle(balance as String, for: UIControlState())
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) -> () {
        if (segue.identifier == "SegueAddressList") {
            let vc = segue.destination as! TLAddressListViewController
            vc.navigationItem.title = "Addresses".localized
            vc.accountObject = showAddressListAccountObject
            vc.showBalances = showAddressListShowBalances
        }
    }

    func refreshWalletAccountsNotification(_ notification: Notification) -> () {
        self.refreshWalletAccounts(false)
    }

    fileprivate func refreshWalletAccounts(_ fetchDataAgain: Bool) -> () {
        self._accountsTableViewReloadDataWrapper()
        self.refreshAccountBalances(fetchDataAgain)
        if TLPreferences.enabledColdWallet() {
            self.refreshColdWalletAccounts(fetchDataAgain)
        }
        if (TLPreferences.enabledAdvancedMode()) {
            self.refreshImportedAccounts(fetchDataAgain)
            self.refreshImportedWatchAccounts(fetchDataAgain)
            self.refreshImportedAddressBalances(fetchDataAgain)
            self.refreshImportedWatchAddressBalances(fetchDataAgain)
        }
    }

    fileprivate func setUpCellAccounts(_ accountObject: TLAccountObject, cell: TLAccountTableViewCell, cellForRowAtIndexPath indexPath: IndexPath) -> () {
        cell.accountNameLabel!.isHidden = false
        cell.accountBalanceButton!.isHidden = false
        cell.textLabel!.isHidden = true

        cell.accountNameLabel!.text = accountObject.getAccountName()

        if (accountObject.hasFetchedAccountData()) {
            (cell.accessoryView! as! UIActivityIndicatorView).isHidden = true
            (cell.accessoryView! as! UIActivityIndicatorView).stopAnimating()
            let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
            cell.accountBalanceButton!.setTitle(balance as String, for: UIControlState())
            cell.accountBalanceButton!.isHidden = false
        } else {
            (cell.accessoryView! as! UIActivityIndicatorView).isHidden = false
            (cell.accessoryView! as! UIActivityIndicatorView).startAnimating()
            AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: false, success: {
                (cell.accessoryView as! UIActivityIndicatorView).stopAnimating()
                (cell.accessoryView as! UIActivityIndicatorView).isHidden = true
                if accountObject.downloadState == .downloaded {
                    let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
                    cell.accountBalanceButton!.setTitle(balance as String, for: UIControlState())
                    cell.accountBalanceButton!.isHidden = false
                }
            })
        }
    }

    fileprivate func setUpCellImportedAddresses(_ importedAddressObject: TLImportedAddress, cell: TLAccountTableViewCell, cellForRowAtIndexPath indexPath: IndexPath) -> () {
        cell.accountNameLabel!.isHidden = false
        cell.accountBalanceButton!.isHidden = false
        cell.textLabel!.isHidden = true

        let label = importedAddressObject.getLabel()
        cell.accountNameLabel!.text = label


        if (importedAddressObject.hasFetchedAccountData()) {
            (cell.accessoryView! as! UIActivityIndicatorView).isHidden = true
            (cell.accessoryView! as! UIActivityIndicatorView).stopAnimating()
            let balance = TLCurrencyFormat.getProperAmount(importedAddressObject.getBalance()!)
            cell.accountBalanceButton!.setTitle(balance as String, for: UIControlState())
        }
    }

    fileprivate func setUpCellArchivedImportedAddresses(_ importedAddressObject: TLImportedAddress, cell: TLAccountTableViewCell, cellForRowAtIndexPath indexPath: IndexPath) -> () {
        cell.accountNameLabel!.isHidden = true
        cell.accountBalanceButton!.isHidden = true
        cell.textLabel!.isHidden = false

        let label = importedAddressObject.getLabel()
        cell.textLabel!.text = label
    }

    fileprivate func setUpCellArchivedAccounts(_ accountObject: TLAccountObject, cell: TLAccountTableViewCell, cellForRowAtIndexPath indexPath: IndexPath) -> () {

        cell.accountNameLabel!.isHidden = true
        cell.accountBalanceButton!.isHidden = true
        cell.textLabel!.isHidden = false

        cell.textLabel!.text = accountObject.getAccountName()
        (cell.accessoryView! as! UIActivityIndicatorView).isHidden = true
    }

    fileprivate func promtForLabel(_ success: @escaping TLPrompts.UserInputCallback, failure: @escaping TLPrompts.Failure) -> () {
        func addTextField(_ textField: UITextField!){
            textField.placeholder = "label".localized
        }
        
        UIAlertController.showAlert(in: self,
            withTitle: "Enter Label".localized,
            message: "",
            preferredStyle: .alert,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Save".localized],
            preShow: {(controller:UIAlertController!) in
                controller.addTextField(configurationHandler: addTextField)
            },
            tap: {(alertView, action, buttonIndex) in
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

    fileprivate func promtForNameAccount(_ success: @escaping TLPrompts.UserInputCallback, failure: @escaping TLPrompts.Failure) -> () {
        func addTextField(_ textField: UITextField!){
            textField.placeholder = "account name".localized
        }
        
        UIAlertController.showAlert(in: self,
            withTitle: "Enter Label".localized,
            message: "",
            preferredStyle: .alert,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Save".localized],
            preShow: {(controller:UIAlertController!) in
                controller.addTextField(configurationHandler: addTextField)
            },
            tap: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    let accountName = (alertView.textFields![0] ).text//alertView.textFieldAtIndex(0)!.text
                    
                    if (AppDelegate.instance().accounts!.accountNameExist(accountName!) == true) {
                        UIAlertController.showAlert(in: self,
                            withTitle: "Account name is taken".localized,
                            message: "",
                            cancelButtonTitle: "Cancel".localized,
                            destructiveButtonTitle: nil,
                            otherButtonTitles: ["Rename".localized],
                            tap: {(alertView, action, buttonIndex) in
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
        
        if TLPreferences.enabledColdWallet() {
            if (AppDelegate.instance().coldWalletAccounts!.getNumberOfAccounts() > 0) {
                coldWalletAccountSection = sectionCounter
                sectionCounter += 1
                numberOfSections += 1
            } else {
                coldWalletAccountSection = NSIntegerMax
            }
        }
        
        if (TLPreferences.enabledAdvancedMode()) {
            if (AppDelegate.instance().importedAccounts!.getNumberOfAccounts() > 0) {
                importedAccountSection = sectionCounter
                sectionCounter += 1
                numberOfSections += 1
            } else {
                importedAccountSection = NSIntegerMax
            }
            
            if (AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts() > 0) {
                importedWatchAccountSection = sectionCounter
                sectionCounter += 1
                numberOfSections += 1
            } else {
                importedWatchAccountSection = NSIntegerMax
            }
            
            if (AppDelegate.instance().importedAddresses!.getCount() > 0) {
                importedAddressSection = sectionCounter
                sectionCounter += 1
                numberOfSections += 1
            } else {
                importedAddressSection = NSIntegerMax
            }
            
            if (AppDelegate.instance().importedWatchAddresses!.getCount() > 0) {
                importedWatchAddressSection = sectionCounter
                sectionCounter += 1
                numberOfSections += 1
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
            sectionCounter += 1
            numberOfSections += 1
        } else {
            archivedAccountSection = NSIntegerMax
        }
        
        if TLPreferences.enabledColdWallet() {
            if (AppDelegate.instance().coldWalletAccounts!.getNumberOfArchivedAccounts() > 0) {
                archivedColdWalletAccountSection = sectionCounter
                sectionCounter += 1
                numberOfSections += 1
            } else {
                archivedColdWalletAccountSection = NSIntegerMax
            }
        }
        
        if (TLPreferences.enabledAdvancedMode()) {
            if (AppDelegate.instance().importedAccounts!.getNumberOfArchivedAccounts() > 0) {
                archivedImportedAccountSection = sectionCounter
                sectionCounter += 1
                numberOfSections += 1
            } else {
                archivedImportedAccountSection = NSIntegerMax
            }
            
            if (AppDelegate.instance().importedWatchAccounts!.getNumberOfArchivedAccounts() > 0) {
                archivedImportedWatchAccountSection = sectionCounter
                sectionCounter += 1
                numberOfSections += 1
            } else {
                archivedImportedWatchAccountSection = NSIntegerMax
            }
            
            if (AppDelegate.instance().importedAddresses!.getArchivedCount() > 0) {
                archivedImportedAddressSection = sectionCounter
                sectionCounter += 1
                numberOfSections += 1
            } else {
                archivedImportedAddressSection = NSIntegerMax
            }
            
            if (AppDelegate.instance().importedWatchAddresses!.getArchivedCount() > 0) {
                archivedImportedWatchAddressSection = sectionCounter
                sectionCounter += 1
                numberOfSections += 1
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
    
    func accountsTableViewReloadDataWrapper(_ notification: Notification) -> () {
        _accountsTableViewReloadDataWrapper()
    }

    fileprivate func promptAccountsActionSheet(_ idx: Int) -> () {
        let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx(idx)
        let accountHDIndex = accountObject.getAccountHDIndex()
        let title = String(format: "Account ID: %u".localized, accountHDIndex)
        
        let otherButtonTitles:[String]
        if (TLPreferences.enabledAdvancedMode()) {
            otherButtonTitles = ["View account public key QR code".localized, "View account private key QR code".localized, "View Addresses".localized, "Scan For Reusable Address Payment".localized, "Edit Account Name".localized, "Archive Account".localized]
        } else {
            otherButtonTitles = ["View Addresses".localized, "Edit Account Name".localized, "Archive Account".localized]
        }
        
        UIAlertController.showAlert(in: self,
            withTitle: title,
            message: "",
            preferredStyle: .actionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: otherButtonTitles as [AnyObject],
            tap: {(actionSheet, action, buttonIndex) in
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
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY()), object: accountObject, userInfo: nil)
                    
                    
                } else if (buttonIndex == VIEW_EXTENDED_PRIVATE_KEY_BUTTON_IDX) {
                    self.QRImageModal = TLQRImageModal(data: accountObject.getExtendedPrivKey()!, buttonCopyText: "Copy To Clipboard".localized, vc: self)
                    self.QRImageModal!.show()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_EXTENDED_PRIVATE_KEY()),
                        object: accountObject, userInfo: nil)
                    
                } else if (buttonIndex == MANUALLY_SCAN_TX_FOR_STEALTH_TRANSACTION_BUTTON_IDX) {
                    self.promptInfoAndToManuallyScanForStealthTransactionAccount(accountObject)
                } else if (buttonIndex == VIEW_ADDRESSES_BUTTON_IDX) {
                    self.showAddressListAccountObject = accountObject
                    self.showAddressListShowBalances = true
                    self.performSegue(withIdentifier: "SegueAddressList", sender: self)
                } else if (buttonIndex == RENAME_ACCOUNT_BUTTON_IDX) {
                    self.promtForNameAccount({
                        (accountName: String!) in
                        AppDelegate.instance().accounts!.renameAccount(accountObject.getAccountIdxNumber(), accountName: accountName)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_EDIT_ACCOUNT_NAME()),
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

    fileprivate func promptColdWalletAccountsActionSheet(_ indexPath: IndexPath) -> () {
        let accountObject = AppDelegate.instance().coldWalletAccounts!.getAccountObjectForIdx((indexPath as NSIndexPath).row)
        let accountHDIndex = accountObject.getAccountHDIndex()
        let title = String(format: "Account ID: %u".localized, accountHDIndex)
        let otherButtons:[String]
        otherButtons = ["View account public key QR code".localized, "View Addresses".localized, "Edit Account Name".localized, "Archive Account".localized]
        
        UIAlertController.showAlert(in: self,
                                                    withTitle: title,
                                                    message:"",
                                                    preferredStyle: .actionSheet,
                                                    cancelButtonTitle: "Cancel".localized,
                                                    destructiveButtonTitle: nil,
                                                    otherButtonTitles: otherButtons as [AnyObject],
                                                    tap: {(actionSheet, action, buttonIndex) in
                                                        var VIEW_EXTENDED_PUBLIC_KEY_BUTTON_IDX = actionSheet.firstOtherButtonIndex
                                                        var VIEW_ADDRESSES_BUTTON_IDX = actionSheet.firstOtherButtonIndex+1
                                                        var RENAME_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex+2
                                                        var ARCHIVE_ACCOUNT_BUTTON_IDX = actionSheet.firstOtherButtonIndex+3
                                        
                                                        if (buttonIndex == VIEW_EXTENDED_PUBLIC_KEY_BUTTON_IDX) {
                                                            self.QRImageModal = TLQRImageModal(data: accountObject.getExtendedPubKey(),
                                                                buttonCopyText: "Copy To Clipboard".localized, vc: self)
                                                            self.QRImageModal!.show()
                                                            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY()), object: accountObject, userInfo: nil)
                                                        } else if (buttonIndex == VIEW_ADDRESSES_BUTTON_IDX) {
                                                            self.showAddressListAccountObject = accountObject
                                                            self.showAddressListShowBalances = true
                                                            self.performSegue(withIdentifier: "SegueAddressList", sender: self)
                                                            
                                                        } else if (buttonIndex == RENAME_ACCOUNT_BUTTON_IDX) {
                                                            self.promtForNameAccount({
                                                                (accountName: String!) in
                                                                AppDelegate.instance().coldWalletAccounts!.renameAccount(accountObject.getAccountIdxNumber(), accountName: accountName)
                                                                self._accountsTableViewReloadDataWrapper()
                                                                }, failure: {
                                                                    (isCancelled: Bool) in
                                                            })
                                                        } else if (buttonIndex == ARCHIVE_ACCOUNT_BUTTON_IDX) {
                                                            self.promptToArchiveAccount(accountObject)
                                                        } else if (buttonIndex == actionSheet.cancelButtonIndex) {
                                                            
                                                        }
        })
    }


    fileprivate func promptImportedAccountsActionSheet(_ indexPath: IndexPath) -> () {
        let accountObject = AppDelegate.instance().importedAccounts!.getAccountObjectForIdx((indexPath as NSIndexPath).row)
        let accountHDIndex = accountObject.getAccountHDIndex()
        let title = String(format: "Account ID: %u".localized, accountHDIndex)
        
        UIAlertController.showAlert(in: self,
            withTitle: title,
            message: "",
            preferredStyle: .actionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["View account public key QR code".localized, "View account private key QR code".localized, "View Addresses".localized, "Manually Scan For Forward Transaction".localized, "Edit Account Name".localized, "Archive Account".localized],
            tap: {(actionSheet, action, buttonIndex) in
                if (buttonIndex == actionSheet.firstOtherButtonIndex) {
                    self.QRImageModal = TLQRImageModal(data: accountObject.getExtendedPubKey(),
                        buttonCopyText: "Copy To Clipboard".localized, vc: self)
                    self.QRImageModal!.show()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY()), object: accountObject, userInfo: nil)
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex+1) {
                    self.QRImageModal = TLQRImageModal(data: accountObject.getExtendedPrivKey()!,
                        buttonCopyText: "Copy To Clipboard".localized, vc: self)
                    self.QRImageModal!.show()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_EXTENDED_PRIVATE_KEY()), object: accountObject, userInfo: nil)
                    
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex+2) {
                    self.showAddressListAccountObject = accountObject
                    self.showAddressListShowBalances = true
                    self.performSegue(withIdentifier: "SegueAddressList", sender: self)
                    
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex+3) {
                    self.promptInfoAndToManuallyScanForStealthTransactionAccount(accountObject)
                    
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex+4) {
                    
                    self.promtForNameAccount({
                        (accountName: String!) in
                        AppDelegate.instance().importedAccounts!.renameAccount(accountObject.getAccountIdxNumber(), accountName: accountName)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_EDIT_ACCOUNT_NAME()), object: nil, userInfo: nil)
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

    fileprivate func promptImportedWatchAccountsActionSheet(_ indexPath: IndexPath) -> () {
        let accountObject = AppDelegate.instance().importedWatchAccounts!.getAccountObjectForIdx((indexPath as NSIndexPath).row)
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
        
        UIAlertController.showAlert(in: self,
            withTitle: title,
            message:"",
            preferredStyle: .actionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: otherButtons as [AnyObject],
            tap: {(actionSheet, action, buttonIndex) in
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
                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY()), object: accountObject, userInfo: nil)
            } else if (buttonIndex == VIEW_ADDRESSES_BUTTON_IDX) {
                self.showAddressListAccountObject = accountObject
                self.showAddressListShowBalances = true
                self.performSegue(withIdentifier: "SegueAddressList", sender: self)

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
        })
    }

    fileprivate func promptImportedAddressActionSheet(_ importedAddressIdx: Int) -> () {
        let importAddressObject = AppDelegate.instance().importedAddresses!.getAddressObjectAtIdx(importedAddressIdx)
        
        UIAlertController.showAlert(in: self,
            withTitle: nil,
            message:"",
            preferredStyle: .actionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["View address QR code".localized, "View private key QR code".localized, "View address in web".localized, "Edit Label".localized, "Archive address".localized],
            
            tap: {(actionSheet, action, buttonIndex) in
     
        
            if (buttonIndex == actionSheet?.firstOtherButtonIndex) {
                self.QRImageModal = TLQRImageModal(data: importAddressObject.getAddress(), buttonCopyText: "Copy To Clipboard".localized, vc: self)
                self.QRImageModal!.show()
            } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)!+1) {
                self.QRImageModal = TLQRImageModal(data: importAddressObject.getEitherPrivateKeyOrEncryptedPrivateKey()!, buttonCopyText: "Copy To Clipboard".localized, vc: self)

                self.QRImageModal!.show()

            } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)!+2) {
                TLBlockExplorerAPI.instance().openWebViewForAddress(importAddressObject.getAddress())

            } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)!+3) {

                self.promtForLabel({
                    (inputText: String!) in

                    AppDelegate.instance().importedAddresses!.setLabel(inputText, positionInWalletArray: Int(importAddressObject.getPositionInWalletArrayNumber()))

                    self._accountsTableViewReloadDataWrapper()
                }, failure: {
                    (isCancelled: Bool) in
                })
            } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)!+4) {
                self.promptToArchiveAddress(importAddressObject)
            } else if (buttonIndex == actionSheet?.cancelButtonIndex) {
            }
        })
    }

    fileprivate func promptImportedWatchAddressActionSheet(_ importedAddressIdx: Int) -> () {
        let importAddressObject = AppDelegate.instance().importedWatchAddresses!.getAddressObjectAtIdx(importedAddressIdx)
        var addClearPrivateKeyButton = false

        let otherButtonTitles:[String]
        if (importAddressObject.hasSetPrivateKeyInMemory()) {
            addClearPrivateKeyButton = true

            otherButtonTitles = ["Clear private key from memory".localized, "View address QR code".localized, "View address in web".localized, "Edit Label".localized, "Archive address".localized]
        } else {
            otherButtonTitles = ["View address QR code".localized, "View address in web".localized, "Edit Label".localized, "Archive address".localized]
        }

        UIAlertController.showAlert(in: self,
            withTitle: nil,
            message:"",
            preferredStyle: .actionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: otherButtonTitles as [AnyObject],
            
            tap: {(actionSheet, action, buttonIndex) in

                var CLEAR_PRIVATE_KEY_BUTTON_IDX = -1
                var VIEW_ADDRESS_BUTTON_IDX = actionSheet?.firstOtherButtonIndex
                var VIEW_ADDRESS_IN_WEB_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)!+1
                var RENAME_ADDRESS_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)!+2
                var ARCHIVE_ADDRESS_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)!+3
                if (importAddressObject.hasSetPrivateKeyInMemory()) {
                    CLEAR_PRIVATE_KEY_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)!
                    VIEW_ADDRESS_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 1
                    VIEW_ADDRESS_IN_WEB_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 2
                    RENAME_ADDRESS_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 3
                    ARCHIVE_ADDRESS_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 4
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
            } else if (buttonIndex == actionSheet?.cancelButtonIndex) {

            }
        })
    }

    fileprivate func promptArchivedImportedAddressActionSheet(_ importedAddressIdx: Int) -> () {
        let importAddressObject = AppDelegate.instance().importedAddresses!.getArchivedAddressObjectAtIdx(importedAddressIdx)
        UIAlertController.showAlert(in: self,
                                                    withTitle: nil,
                                                    message:"",
                                                    preferredStyle: .actionSheet,
                                                    cancelButtonTitle: "Cancel".localized,
                                                    destructiveButtonTitle: nil,
                                                    otherButtonTitles: ["View address QR code".localized, "View private key QR code".localized, "View address in web".localized, "Edit Label".localized, "Unarchived address".localized, "Delete address".localized],
                                                    
                                                    tap: {(actionSheet, action, buttonIndex) in
                                                        
                                                        if (buttonIndex == actionSheet?.firstOtherButtonIndex) {
                                                            self.QRImageModal = TLQRImageModal(data: importAddressObject.getAddress(), buttonCopyText: "Copy To Clipboard".localized, vc: self)
                                                            
                                                            self.QRImageModal!.show()
                                                            
                                                        } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)!+1) {
                                                            self.QRImageModal = TLQRImageModal(data: importAddressObject.getEitherPrivateKeyOrEncryptedPrivateKey()!, buttonCopyText: "Copy To Clipboard".localized, vc: self)
                                                            
                                                            self.QRImageModal!.show()
                                                            
                                                        } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)!+2) {
                                                            TLBlockExplorerAPI.instance().openWebViewForAddress(importAddressObject.getAddress())
                                                            
                                                        } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)!+3) {
                                                            
                                                            self.promtForLabel({
                                                                (inputText: String!) in
                                                                
                                                                
                                                                AppDelegate.instance().importedAddresses!.setLabel(inputText, positionInWalletArray: Int(importAddressObject.getPositionInWalletArrayNumber()))
                                                                self._accountsTableViewReloadDataWrapper()
                                                                }, failure: ({
                                                                    (isCanceled: Bool) in
                                                                }))
                                                        } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)!+4) {
                                                            self.promptToUnarchiveAddress(importAddressObject)
                                                        } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)!+5) {
                                                            self.promptToDeleteImportedAddress(importedAddressIdx)
                                                        } else if (buttonIndex == actionSheet?.cancelButtonIndex) {
                                                        }
        })
    }

    fileprivate func promptArchivedImportedWatchAddressActionSheet(_ importedAddressIdx: Int) -> () {
        let importAddressObject = AppDelegate.instance().importedWatchAddresses!.getArchivedAddressObjectAtIdx(importedAddressIdx)
        var addClearPrivateKeyButton = false
        let otherButtonTitles:[String]
        if (importAddressObject.hasSetPrivateKeyInMemory()) {
            addClearPrivateKeyButton = true
            otherButtonTitles = ["Clear private key from memory".localized, "View address QR code".localized, "View address in web".localized, "Edit Label".localized, "Unarchived address".localized, "Delete address".localized]
        } else {
            otherButtonTitles = ["View address QR code".localized, "View address in web".localized, "Edit Label".localized, "Unarchived address".localized, "Delete address".localized]
        }

        UIAlertController.showAlert(in: self,
            withTitle: nil,
            message:"",
            preferredStyle: .actionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: otherButtonTitles as [AnyObject],
            
            tap: {(actionSheet, action, buttonIndex) in

                var CLEAR_PRIVATE_KEY_BUTTON_IDX = -1
                var VIEW_ADDRESS_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 0
                var VIEW_ADDRESS_IN_WEB_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 1
                var RENAME_ADDRESS_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 2
                var UNARCHIVE_ADDRESS_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 3
                var DELETE_ADDRESS_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 4
                if (importAddressObject.hasSetPrivateKeyInMemory()) {
                    CLEAR_PRIVATE_KEY_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)!
                    VIEW_ADDRESS_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 1
                    VIEW_ADDRESS_IN_WEB_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 2
                    RENAME_ADDRESS_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 3
                    UNARCHIVE_ADDRESS_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 4
                    DELETE_ADDRESS_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 5
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
            } else if (buttonIndex == actionSheet?.cancelButtonIndex) {

            }
        })
    }

    fileprivate func promptArchivedImportedAccountsActionSheet(_ indexPath: IndexPath, accountType: TLAccountType) -> () {
        assert(accountType == .imported || accountType == .importedWatch || accountType == .coldWallet, "not TLAccountTypeImported or TLAccountTypeImportedWatch or not TLAccountTypeIColdWallet")
        var accountObject: TLAccountObject?
        if (accountType == .coldWallet) {
            accountObject = AppDelegate.instance().coldWalletAccounts!.getArchivedAccountObjectForIdx((indexPath as NSIndexPath).row)
        } else if (accountType == .imported) {
            accountObject = AppDelegate.instance().importedAccounts!.getArchivedAccountObjectForIdx((indexPath as NSIndexPath).row)
        } else if (accountType == .importedWatch) {
            accountObject = AppDelegate.instance().importedWatchAccounts!.getArchivedAccountObjectForIdx((indexPath as NSIndexPath).row)
        }
        
        let accountHDIndex = accountObject!.getAccountHDIndex()
        let title = String(format: "Account ID: %u".localized, accountHDIndex)
        let otherButtonTitles:[String]
        if (accountObject!.getAccountType() == .imported) {
            otherButtonTitles = ["View account public key QR code".localized, "View account private key QR code".localized, "View Addresses".localized, "Edit Account Name".localized, "Unarchive Account".localized, "Delete Account".localized]
        } else {
            otherButtonTitles = ["View account public key QR code".localized, "View Addresses".localized, "Edit Account Name".localized, "Unarchive Account".localized, "Delete Account".localized]
        }
        
        UIAlertController.showAlert(in: self,
            withTitle: title,
            message:"",
            preferredStyle: .actionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: otherButtonTitles as [AnyObject],
            
            tap: {(actionSheet, action, buttonIndex) in
                let VIEW_EXTENDED_PUBLIC_KEY_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 0
                var VIEW_EXTENDED_PRIVATE_KEY_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 1
                var VIEW_ADDRESSES_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 2
                var RENAME_ACCOUNT_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 3
                var UNARCHIVE_ACCOUNT_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 4
                var DELETE_ACCOUNT_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 5
                if (accountObject!.getAccountType() == .imported) {
                } else {
                    VIEW_EXTENDED_PRIVATE_KEY_BUTTON_IDX = -1
                    VIEW_ADDRESSES_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 1
                    RENAME_ACCOUNT_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 2
                    UNARCHIVE_ACCOUNT_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 3
                    DELETE_ACCOUNT_BUTTON_IDX = (actionSheet?.firstOtherButtonIndex)! + 4
                }
                if (buttonIndex == VIEW_EXTENDED_PUBLIC_KEY_BUTTON_IDX) {
                    self.QRImageModal = TLQRImageModal(data: accountObject!.getExtendedPubKey() as NSString,
                        buttonCopyText: "Copy To Clipboard".localized, vc: self)
                    self.QRImageModal!.show()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY()),
                        object: accountObject, userInfo: nil)
                    
                } else if (buttonIndex == VIEW_EXTENDED_PRIVATE_KEY_BUTTON_IDX) {
                    self.QRImageModal = TLQRImageModal(data: accountObject!.getExtendedPrivKey()! as NSString,
                        buttonCopyText: "Copy To Clipboard".localized, vc: self)
                    self.QRImageModal!.show()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_EXTENDED_PRIVATE_KEY()),
                        object: accountObject, userInfo: nil)
                    
                } else if (buttonIndex == VIEW_ADDRESSES_BUTTON_IDX) {
                    self.showAddressListAccountObject = accountObject
                    self.showAddressListShowBalances = false
                    self.performSegue(withIdentifier: "SegueAddressList", sender: self)
                } else if (buttonIndex == RENAME_ACCOUNT_BUTTON_IDX) {
                    self.promtForNameAccount({
                        (accountName: String!) in
                        if (accountType == .coldWallet) {
                            AppDelegate.instance().coldWalletAccounts!.renameAccount(accountObject!.getAccountIdxNumber(), accountName: accountName)
                        } else if (accountType == .imported) {
                            AppDelegate.instance().importedAccounts!.renameAccount(accountObject!.getAccountIdxNumber(), accountName: accountName)
                        } else if (accountType == .importedWatch) {
                            AppDelegate.instance().importedWatchAccounts!.renameAccount(accountObject!.getAccountIdxNumber(), accountName: accountName)
                        }
                        self._accountsTableViewReloadDataWrapper()
                        }, failure: ({
                            (isCanceled: Bool) in
                        }))
                } else if (buttonIndex == UNARCHIVE_ACCOUNT_BUTTON_IDX) {
                    if (AppDelegate.instance().coldWalletAccounts!.getNumberOfAccounts() + AppDelegate.instance().importedAccounts!.getNumberOfAccounts() + AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts() >= self.MAX_IMPORTED_ACCOUNTS) {
                        TLPrompts.promptErrorMessage("Maximum accounts reached".localized, message: "You need to archived an account in order to unarchive a different one.".localized)
                        return
                    }
                    
                    self.promptToUnarchiveAccount(accountObject!)
                } else if (buttonIndex == DELETE_ACCOUNT_BUTTON_IDX) {
                    if (accountType == .coldWallet) {
                        self.promptToDeleteColdWalletAccount(indexPath)
                    } else if (accountType == .imported) {
                        self.promptToDeleteImportedAccount(indexPath)
                    } else if (accountType == .importedWatch) {
                        self.promptToDeleteImportedWatchAccount(indexPath)
                    }
                } else if (buttonIndex == actionSheet?.cancelButtonIndex) {
                    
                }
        })
    }

    fileprivate func promptArchivedAccountsActionSheet(_ idx: Int) -> () {
        let accountObject = AppDelegate.instance().accounts!.getArchivedAccountObjectForIdx(idx)
        let accountHDIndex = accountObject.getAccountHDIndex()
        let title = String(format: "Account ID: %u".localized, accountHDIndex)
        let otherButtonTitles:[String]
        if (TLPreferences.enabledAdvancedMode()) {
            otherButtonTitles = ["View account public key QR code".localized, "View account private key QR code".localized, "View Addresses".localized, "Edit Account Name".localized, "Unarchive Account".localized]
        } else {
            otherButtonTitles = ["View Addresses".localized, "Edit Account Name".localized, "Unarchive Account".localized]
        }

        UIAlertController.showAlert(in: self,
            withTitle: title,
            message:"",
            preferredStyle: .actionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: otherButtonTitles as [AnyObject],
            tap: {(actionSheet, action, buttonIndex) in
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
                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_EXTENDED_PUBLIC_KEY()), object: accountObject, userInfo: nil)

            } else if (buttonIndex == VIEW_EXTENDED_PRIVATE_KEY_BUTTON_IDX) {
                self.QRImageModal = TLQRImageModal(data: accountObject.getExtendedPrivKey()!,
                        buttonCopyText: "Copy To Clipboard".localized, vc: self)
                self.QRImageModal!.show()
                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_EXTENDED_PRIVATE_KEY()), object: accountObject, userInfo: nil)

            } else if (buttonIndex == VIEW_ADDRESSES_BUTTON_IDX) {
                self.showAddressListAccountObject = accountObject
                self.showAddressListShowBalances = false
                self.performSegue(withIdentifier: "SegueAddressList", sender: self)
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

    fileprivate func promptToManuallyScanForStealthTransactionAccount(_ accountObject: TLAccountObject) -> () {
        func addTextField(_ textField: UITextField!){
            textField.placeholder = "Transaction ID".localized
        }
        
        UIAlertController.showAlert(in: self,
            withTitle: "Scan for reusable address transaction".localized,
            message: "",
            preferredStyle: .alert,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],
            
            preShow: {(controller:UIAlertController!) in
                controller.addTextField(configurationHandler: addTextField)
            }
            ,
            tap: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    let txid = (alertView.textFields![0] ).text
                    self.manuallyScanForStealthTransactionAccount(accountObject, txid: txid!)
                } else if (buttonIndex == alertView.cancelButtonIndex) {
                    
                }
            }
        )
    }

    fileprivate func manuallyScanForStealthTransactionAccount(_ accountObject: TLAccountObject, txid: String) -> () {
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
                TLPrompts.promptSuccessMessage("", message: "Txid is not a reusable address transaction.".localized)
                return
            }
            
            let scanPriv = accountObject.stealthWallet!.getStealthAddressScanKey()
            let spendPriv = accountObject.stealthWallet!.getStealthAddressSpendKey()
            let stealthDataScript = stealthDataScriptAndOutputAddresses!.stealthDataScript!
            if let secret = TLStealthAddress.getPaymentAddressPrivateKeySecretFromScript(stealthDataScript, scanPrivateKey: scanPriv, spendPrivateKey: spendPriv) {
                let paymentAddress = TLCoreBitcoinWrapper.getAddressFromSecret(secret, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)
                if (stealthDataScriptAndOutputAddresses!.outputAddresses).index(of: (paymentAddress!)) != nil {
                    
                    TLBlockExplorerAPI.instance().getUnspentOutputs([paymentAddress!], success: {
                        (jsonData2: AnyObject!) in
                        let unspentOutputs = (jsonData2 as! NSDictionary).object(forKey: "unspent_outputs") as! NSArray!
                        if (unspentOutputs.count > 0) {
                            let privateKey = TLCoreBitcoinWrapper.privateKeyFromSecret(secret, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)
                            let txObject = TLTxObject(dict:jsonData as! NSDictionary)
                            let txTime = txObject.getTxUnixTime()
                            accountObject.stealthWallet!.addStealthAddressPaymentKey(privateKey, paymentAddress: paymentAddress!,
                                txid: txid, txTime: txTime, stealthPaymentStatus: TLStealthPaymentStatus.unspent)
                            
                            TLHUDWrapper.hideHUDForView(self.view, animated: true)
                            TLPrompts.promptSuccessMessage("Success".localized, message: String(format: "Transaction %@ belongs to this account. Funds imported".localized, txid))
                            
                            AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: true, success: {
                                self.refreshWalletAccounts(false)
                                
                                TLStealthExplorerAPI.instance().lookupTx(accountObject.stealthWallet!.getStealthAddress(), txid: txid, success: { (jsonData: AnyObject!) -> () in
                                    DLog("lookupTx success %@", function: jsonData.description)
                                }) { (code: Int, status: String!) -> () in
                                    DLog("lookupTx failure code: \(code) \(status)")
                                }
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
    
    fileprivate func promptInfoAndToManuallyScanForStealthTransactionAccount(_ accountObject: TLAccountObject) -> () {
        if (TLSuggestions.instance().enabledShowManuallyScanTransactionForStealthTxInfo()) {
            TLPrompts.promtForOK(self, title:"", message: "This feature allows you to manually input a transaction id and see if the corresponding transaction contains a forwarding payment to your reusable address. If so, then the funds will be added to your wallet. Normally the app will discover forwarding payments automatically for you, but if you believe a payment is missing you can use this feature.".localized, success: {
                () in
                self.promptToManuallyScanForStealthTransactionAccount(accountObject)
                TLSuggestions.instance().setEnabledShowManuallyScanTransactionForStealthTxInfo(false)
            })
        } else {
            self.promptToManuallyScanForStealthTransactionAccount(accountObject)
        }
    }

    fileprivate func promptToUnarchiveAccount(_ accountObject: TLAccountObject) -> () {
        UIAlertController.showAlert(in: self,
            withTitle: "Unarchive account".localized,
            message: String(format: "Are you sure you want to unarchive account %@".localized, accountObject.getAccountName()),
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],
            tap: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView?.firstOtherButtonIndex) {
                    if (accountObject.getAccountType() == .hdWallet) {
                        AppDelegate.instance().accounts!.unarchiveAccount(accountObject.getAccountIdxNumber())
                    } else if (accountObject.getAccountType() == .coldWallet) {
                        AppDelegate.instance().coldWalletAccounts!.unarchiveAccount(accountObject.getPositionInWalletArray())
                    } else if (accountObject.getAccountType() == .imported) {
                        AppDelegate.instance().importedAccounts!.unarchiveAccount(accountObject.getPositionInWalletArray())
                    } else if (accountObject.getAccountType() == .importedWatch) {
                        AppDelegate.instance().importedWatchAccounts!.unarchiveAccount(accountObject.getPositionInWalletArray())
                    }
                    
                    if !accountObject.isWatchOnly() && !accountObject.isColdWalletAccount() && !accountObject.stealthWallet!.hasUpdateStealthPaymentStatuses {
                        accountObject.stealthWallet!.updateStealthPaymentStatusesAsync()
                    }
                    self._accountsTableViewReloadDataWrapper()
                    AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: true, success: {
                        self._accountsTableViewReloadDataWrapper()
                    })
                } else if (buttonIndex == alertView?.cancelButtonIndex) {
                }
            }
        )
    }

    fileprivate func promptToArchiveAccount(_ accountObject: TLAccountObject) -> () {
        UIAlertController.showAlert(in: self,
            withTitle:  "Archive account".localized,
            message: String(format: "Are you sure you want to archive account %@?".localized, accountObject.getAccountName()),
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],

            tap: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView?.firstOtherButtonIndex) {
                    if (accountObject.getAccountType() == .hdWallet) {
                        AppDelegate.instance().accounts!.archiveAccount(accountObject.getAccountIdxNumber())
                    } else if (accountObject.getAccountType() == .coldWallet) {
                        AppDelegate.instance().coldWalletAccounts!.archiveAccount(accountObject.getPositionInWalletArray())
                    } else if (accountObject.getAccountType() == .imported) {
                        AppDelegate.instance().importedAccounts!.archiveAccount(accountObject.getPositionInWalletArray())
                    } else if (accountObject.getAccountType() == .importedWatch) {
                        AppDelegate.instance().importedWatchAccounts!.archiveAccount(accountObject.getPositionInWalletArray())
                    }
                    self._accountsTableViewReloadDataWrapper()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_ARCHIVE_ACCOUNT()), object: nil, userInfo: nil)
                } else if (buttonIndex == alertView?.cancelButtonIndex) {
                }
            }
        )
    }

    fileprivate func promptToArchiveAccountHDWalletAccount(_ accountObject: TLAccountObject) -> () {
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

    fileprivate func promptToArchiveAddress(_ importedAddressObject: TLImportedAddress) -> () {
        UIAlertController.showAlert(in: self,
            withTitle: "Archive address".localized,
            message: String(format: "Are you sure you want to archive address %@".localized, importedAddressObject.getLabel()),
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],
            tap: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView?.firstOtherButtonIndex) {
                    if (importedAddressObject.isWatchOnly()) {
                        AppDelegate.instance().importedWatchAddresses!.archiveAddress(Int(importedAddressObject.getPositionInWalletArrayNumber()))
                    } else {
                        AppDelegate.instance().importedAddresses!.archiveAddress(Int(importedAddressObject.getPositionInWalletArrayNumber()))
                    }
                    self._accountsTableViewReloadDataWrapper()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_ARCHIVE_ACCOUNT()), object: nil, userInfo: nil)
                } else if (buttonIndex == alertView?.cancelButtonIndex) {
                    
                }
            }
        )
    }

    fileprivate func promptToUnarchiveAddress(_ importedAddressObject: TLImportedAddress) -> () {
        UIAlertController.showAlert(in: self,
            withTitle: "Unarchive address".localized,
            message:  String(format: "Are you sure you want to unarchive address %@?".localized, importedAddressObject.getLabel()),
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],
            tap: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView?.firstOtherButtonIndex) {
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
                } else if (buttonIndex == alertView?.cancelButtonIndex) {
                    
                }
            }
        )
    }

    fileprivate func promptToDeleteColdWalletAccount(_ indexPath: IndexPath) -> () {
        let accountObject = AppDelegate.instance().coldWalletAccounts!.getArchivedAccountObjectForIdx((indexPath as NSIndexPath).row)
        
        UIAlertController.showAlert(in: self,
                                                    withTitle: String(format: "Delete %@".localized, accountObject.getAccountName()),
                                                    message: "Are you sure you want to delete this account?".localized,
                                                    cancelButtonTitle: "No".localized,
                                                    destructiveButtonTitle: nil,
                                                    otherButtonTitles: ["Yes".localized],
                                                    tap: {(alertView, action, buttonIndex) in
                                                        
                                                        if (buttonIndex == alertView.firstOtherButtonIndex) {
                                                            AppDelegate.instance().coldWalletAccounts!.deleteAccount((indexPath as NSIndexPath).row)
                                                            //*
                                                            self.accountsTableView!.beginUpdates()
                                                            let index = NSIndexPath(indexes:[self.archivedColdWalletAccountSection, (indexPath as NSIndexPath).row], length:2) as IndexPath
                                                            let deleteIndexPaths = [index]
                                                            self.accountsTableView!.deleteRows(at: deleteIndexPaths, with: .fade)
                                                            self.accountsTableView!.endUpdates()
                                                            //*/
                                                            self._accountsTableViewReloadDataWrapper()
                                                        } else if (buttonIndex == alertView.cancelButtonIndex) {
                                                            self.accountsTableView!.isEditing = false
                                                        }
        })
    }
    
    fileprivate func promptToDeleteImportedAccount(_ indexPath: IndexPath) -> () {
        let accountObject = AppDelegate.instance().importedAccounts!.getArchivedAccountObjectForIdx((indexPath as NSIndexPath).row)

        UIAlertController.showAlert(in: self,
            withTitle: String(format: "Delete %@".localized, accountObject.getAccountName()),
            message: "Are you sure you want to delete this account?".localized,
            cancelButtonTitle: "No".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],
            tap: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    AppDelegate.instance().importedAccounts!.deleteAccount((indexPath as NSIndexPath).row)
                    
                    self.accountsTableView!.beginUpdates()
                    let index = NSIndexPath(indexes: [self.archivedImportedAccountSection, (indexPath as NSIndexPath).row], length:2) as IndexPath
                    let deleteIndexPaths = [index]
                    self.accountsTableView!.deleteRows(at: deleteIndexPaths, with: .fade)
                    self.accountsTableView!.endUpdates()
                    self._accountsTableViewReloadDataWrapper()
                } else if (buttonIndex == alertView.cancelButtonIndex) {
                    self.accountsTableView!.isEditing = false
                }
            }
        )
    }

    fileprivate func promptToDeleteImportedWatchAccount(_ indexPath: IndexPath) -> () {
        let accountObject = AppDelegate.instance().importedWatchAccounts!.getArchivedAccountObjectForIdx((indexPath as NSIndexPath).row)
        
        UIAlertController.showAlert(in: self,
            withTitle: String(format: "Delete %@".localized, accountObject.getAccountName()),
            message: "Are you sure you want to delete this account?".localized,
            cancelButtonTitle: "No".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],
            tap: {(alertView, action, buttonIndex) in
                
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    AppDelegate.instance().importedWatchAccounts!.deleteAccount((indexPath as NSIndexPath).row)
                    //*
                    self.accountsTableView!.beginUpdates()
                    let index = NSIndexPath(indexes:[self.archivedImportedWatchAccountSection, (indexPath as NSIndexPath).row], length:2) as IndexPath
                    let deleteIndexPaths = [index]
                    self.accountsTableView!.deleteRows(at: deleteIndexPaths, with: .fade)
                    self.accountsTableView!.endUpdates()
                    //*/
                    self._accountsTableViewReloadDataWrapper()
                } else if (buttonIndex == alertView.cancelButtonIndex) {
                    self.accountsTableView!.isEditing = false
                }
        })
    }

    fileprivate func promptToDeleteImportedAddress(_ importedAddressIdx: Int) -> () {
        let importedAddressObject = AppDelegate.instance().importedAddresses!.getArchivedAddressObjectAtIdx(importedAddressIdx)

        UIAlertController.showAlert(in: self,
            withTitle: String(format: "Delete %@".localized, importedAddressObject.getLabel()),
            message: "Are you sure you want to delete this account?".localized,
            cancelButtonTitle: "No".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes".localized],
            tap: {(alertView, action, buttonIndex) in
        
            if (buttonIndex == alertView.firstOtherButtonIndex) {
                self.accountsTableView!.setEditing(true, animated: true)
                AppDelegate.instance().importedAddresses!.deleteAddress(importedAddressIdx)
                self._accountsTableViewReloadDataWrapper()
                self.accountsTableView!.setEditing(false, animated: true)
            } else if (buttonIndex == alertView.cancelButtonIndex) {
                self.accountsTableView!.isEditing = false
            }
        })
    }

    fileprivate func promptToDeleteImportedWatchAddress(_ importedAddressIdx: Int) -> () {
        let importedAddressObject = AppDelegate.instance().importedWatchAddresses!.getArchivedAddressObjectAtIdx(importedAddressIdx)

        UIAlertController.showAlert(in: self,
            withTitle:  String(format: "Delete %@", importedAddressObject.getLabel()),
            message: "Are you sure you want to delete this watch only address?",
            cancelButtonTitle: "No",
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Yes"],

            tap: {(alertView, action, buttonIndex) in

            if (buttonIndex == alertView.firstOtherButtonIndex) {
                self.accountsTableView!.setEditing(true, animated: true)
                AppDelegate.instance().importedWatchAddresses!.deleteAddress(importedAddressIdx)
                self._accountsTableViewReloadDataWrapper()
                self.accountsTableView!.setEditing(false, animated: true)
            } else if (buttonIndex == alertView.cancelButtonIndex) {
                self.accountsTableView!.isEditing = false
            }
        })
    }

    fileprivate func setEditingAndRefreshAccounts() -> () {
        self.accountsTableView!.setEditing(true, animated: true)
        self.refreshWalletAccounts(false)
        self._accountsTableViewReloadDataWrapper()
        self.accountsTableView!.setEditing(false, animated: true)
    }
    
    fileprivate func importColdWalletAccount(_ extendedPublicKey: String) -> (Bool) {
        if (TLHDWalletWrapper.isValidExtendedPublicKey(extendedPublicKey)) {
            AppDelegate.instance().saveWalletJsonCloudBackground()
            AppDelegate.instance().saveWalletJSONEnabled = false
            let accountObject = AppDelegate.instance().coldWalletAccounts!.addAccountWithExtendedKey(extendedPublicKey)
            
            TLHUDWrapper.showHUDAddedTo(self.slidingViewController().topViewController.view, labelText: "Importing Cold Wallet Account".localized, animated: true)
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
                SwiftTryCatch.`try`({
                    () -> () in
                    accountObject.recoverAccount(false, recoverStealthPayments: true)
                    AppDelegate.instance().saveWalletJSONEnabled = true
                    AppDelegate.instance().saveWalletJsonCloudBackground()
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_IMPORT_COLD_WALLET_ACCOUNT()),
                        object: nil)
                    // don't need to call do accountObject.getAccountData like in importAccount() cause watch only account does not see stealth payments. yet
                    DispatchQueue.main.async {
                        TLHUDWrapper.hideHUDForView(self.view, animated: true)
                        self.promtForNameAccount({
                            (_accountName: String?) in
                            var accountName = _accountName
                            if (accountName == nil || accountName == "") {
                                accountName = accountObject.getDefaultNameAccount()
                            }
                            AppDelegate.instance().coldWalletAccounts!.renameAccount(accountObject.getAccountIdxNumber(), accountName: accountName!)
                            
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
                    }, catch: {
                        (exception: NSException!) -> Void in
                        DispatchQueue.main.async {
                            AppDelegate.instance().coldWalletAccounts!.deleteAccount(AppDelegate.instance().coldWalletAccounts!.getNumberOfAccounts() - 1)
                            TLHUDWrapper.hideHUDForView(self.view, animated: true)
                            TLPrompts.promptErrorMessage("Error importing cold wallet account".localized, message: "Try Again".localized)
                            self.setEditingAndRefreshAccounts()
                        }
                    }, finally: { () in })
            }
            
            return true
        } else {
            let av = UIAlertView(title: "Invalid account public Key".localized,
                                 message: "",
                                 delegate: nil,
                                 cancelButtonTitle: "Cancel".localized,
                                 otherButtonTitles: "OK".localized)
            
            av.show()
            return false
        }
    }
    
    fileprivate func importAccount(_ extendedPrivateKey: String) -> (Bool) {
        let handleImportAccountFail = {
            DispatchQueue.main.async {
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
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
                SwiftTryCatch.`try`({
                    () -> () in
                    accountObject.recoverAccount(false, recoverStealthPayments: true)
                    AppDelegate.instance().saveWalletJSONEnabled = true
                    AppDelegate.instance().saveWalletJsonCloudBackground()
                    
                    let handleImportAccountSuccess = {
                        DispatchQueue.main.async {
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
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_IMPORT_ACCOUNT()),
                        object: nil, userInfo: nil)
                    TLStealthWebSocket.instance().sendMessageGetChallenge()
                    AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: true, success: {
                        self.refreshWalletAccounts(false)
                        handleImportAccountSuccess()
                    })
                }, catch: {
                        (e: NSException!) -> Void in
                    handleImportAccountFail()
                    
                }, finally: { () in })
            }
            return true

        } else {
            let av = UIAlertView(title: "Invalid account private key".localized,
                message: "",
                delegate: nil,
                cancelButtonTitle: "Cancel".localized,
                otherButtonTitles: "OK".localized)
            
            av.show()
            return false
        }
    }

    fileprivate func importWatchOnlyAccount(_ extendedPublicKey: String) -> (Bool) {
        if (TLHDWalletWrapper.isValidExtendedPublicKey(extendedPublicKey)) {
            AppDelegate.instance().saveWalletJsonCloudBackground()
            AppDelegate.instance().saveWalletJSONEnabled = false
            let accountObject = AppDelegate.instance().importedWatchAccounts!.addAccountWithExtendedKey(extendedPublicKey)
            
            TLHUDWrapper.showHUDAddedTo(self.slidingViewController().topViewController.view, labelText: "Importing Watch Account".localized, animated: true)
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
                SwiftTryCatch.`try`({
                    () -> () in
                    accountObject.recoverAccount(false, recoverStealthPayments: true)
                    AppDelegate.instance().saveWalletJSONEnabled = true
                    AppDelegate.instance().saveWalletJsonCloudBackground()

                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_IMPORT_WATCH_ONLY_ACCOUNT()),
                        object: nil)
                    // don't need to call do accountObject.getAccountData like in importAccount() cause watch only account does not see stealth payments. yet
                    DispatchQueue.main.async {
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
                }, catch: {
                    (exception: NSException!) -> Void in
                    DispatchQueue.main.async {
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
                cancelButtonTitle: "Cancel".localized,
                otherButtonTitles: "OK".localized)
            
            av.show()
            return false
        }
    }

    fileprivate func checkAndImportAddress(_ privateKey: String, encryptedPrivateKey: String?) -> (Bool) {        
        if (TLCoreBitcoinWrapper.isValidPrivateKey(privateKey, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)) {
            if (encryptedPrivateKey != nil) {
                UIAlertController.showAlert(in: self,
                    withTitle: "Import private key encrypted or unencrypted?".localized,
                    message: "Importing key encrypted will require you to input the password everytime you want to send bitcoins from it.".localized,
                    cancelButtonTitle: "encrypted".localized,
                    destructiveButtonTitle: nil,
                    otherButtonTitles: ["unencrypted".localized],

                    tap: {(alertView, action, buttonIndex) in
                    if (buttonIndex == alertView?.firstOtherButtonIndex) {
                        let importedAddressObject = AppDelegate.instance().importedAddresses!.addImportedPrivateKey(privateKey,
                                encryptedPrivateKey: nil)
                        self.refreshAfterImportAddress(importedAddressObject)
                    } else if (buttonIndex == alertView?.cancelButtonIndex) {
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

    fileprivate func refreshAfterImportAddress(_ importedAddressObject: TLImportedAddress) -> () {
        let lastIdx = AppDelegate.instance().importedAddresses!.getCount()
        let indexPath = IndexPath(row: lastIdx, section: importedAddressSection)
        let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell
        if cell != nil {
            (cell!.accessoryView! as! UIActivityIndicatorView).isHidden = false
            (cell!.accessoryView! as! UIActivityIndicatorView).startAnimating()
        }

        importedAddressObject.getSingleAddressData({
            () in
            if cell != nil {
                (cell!.accessoryView! as! UIActivityIndicatorView).stopAnimating()
                (cell!.accessoryView! as! UIActivityIndicatorView).isHidden = true
                
                let balance = TLCurrencyFormat.getProperAmount(importedAddressObject.getBalance()!)
                cell!.accountBalanceButton!.setTitle(balance as String, for: UIControlState())
                self.setEditingAndRefreshAccounts()
            }
        }, failure: {
            () in
            if cell != nil {
                (cell!.accessoryView! as! UIActivityIndicatorView).stopAnimating()
                (cell!.accessoryView! as! UIActivityIndicatorView).isHidden = true
            }
        })

        let address = importedAddressObject.getAddress()
        let msg = String(format: "Address %@ imported".localized, address)
        let av = UIAlertView(title: msg,
                message: "",
                delegate: nil,
                cancelButtonTitle: "OK".localized)

        av.show()

        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_IMPORT_PRIVATE_KEY()), object: nil, userInfo: nil)
    }

    fileprivate func checkAndImportWatchAddress(_ address: String) -> (Bool) {
        if (TLCoreBitcoinWrapper.isValidAddress(address, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)) {
            if (TLStealthAddress.isStealthAddress(address, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)) {
                TLPrompts.promptErrorMessage("Error".localized, message: "Cannot import reusable address".localized)
                return false
            }
            
            let importedAddressObject = AppDelegate.instance().importedWatchAddresses!.addImportedWatchAddress(address)
            let lastIdx = AppDelegate.instance().importedWatchAddresses!.getCount()
            let indexPath = IndexPath(row: lastIdx, section: importedWatchAddressSection)
            let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell
            if cell != nil {
                (cell!.accessoryView! as! UIActivityIndicatorView).isHidden = false
                (cell!.accessoryView! as! UIActivityIndicatorView).startAnimating()
            }
            importedAddressObject.getSingleAddressData(
                {
                    () in
                    if cell != nil {
                        (cell!.accessoryView! as! UIActivityIndicatorView).stopAnimating()
                        (cell!.accessoryView! as! UIActivityIndicatorView).isHidden = true
                        
                        let balance = TLCurrencyFormat.getProperAmount(importedAddressObject.getBalance()!)
                        cell!.accountBalanceButton!.setTitle(balance as String, for: UIControlState())
                        self.setEditingAndRefreshAccounts()
                    }
                }, failure: {
                    () in
                    if cell != nil {
                        (cell!.accessoryView! as! UIActivityIndicatorView).stopAnimating()
                        (cell!.accessoryView! as! UIActivityIndicatorView).isHidden = true
                    }
            })
            
            let av = UIAlertView(title: String(format: "Address %@ imported".localized, address),
                message: "",
                delegate: nil,
                cancelButtonTitle: "OK".localized)
            
            av.show()
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_IMPORT_WATCH_ONLY_ADDRESS()), object: nil, userInfo: nil)
            return true
        } else {
            TLPrompts.promptErrorMessage("Invalid address".localized, message: "")
            return false
        }
    }

    
    fileprivate func promptColdWalletAccountActionSheet() -> () {
        UIAlertController.showAlert(in: self,
                                                    withTitle: "Cold Wallet Account".localized,
                                                    message:"",
                                                    preferredStyle: .actionSheet,
                                                    cancelButtonTitle: "Cancel".localized,
                                                    destructiveButtonTitle: nil,
                                                    otherButtonTitles: ["Import via QR code".localized, "Import via text input".localized],
                                                    tap: {(actionSheet, action, buttonIndex) in
                                                        if (buttonIndex == (actionSheet?.firstOtherButtonIndex)! + 0) {
                                                            AppDelegate.instance().showExtendedPublicKeyReaderController(self, success: {
                                                                (data: String!) in
                                                                self.importColdWalletAccount(data)
                                                                }, error: {
                                                                    (data: String?) in
                                                            })
                                                        } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)! + 1) {
                                                            TLPrompts.promtForInputText(self, title: "Cold Wallet Account", message: "Input account public key", textFieldPlaceholder: nil, success: {
                                                                (inputText: String!) in
                                                                self.importColdWalletAccount(inputText)
                                                                }, failure: {
                                                                    (isCanceled: Bool) in
                                                            })
                                                        } else if (buttonIndex == actionSheet?.cancelButtonIndex) {
                                                        }
        })
    }
    
    fileprivate func promptImportAccountActionSheet() -> () {
        UIAlertController.showAlert(in: self,
            withTitle: "Import Account".localized,
            message:"",
            preferredStyle: .actionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Import via QR code".localized, "Import via text input".localized],
            tap: {(actionSheet, action, buttonIndex) in
            if (buttonIndex == (actionSheet?.firstOtherButtonIndex)! + 0) {
                AppDelegate.instance().showExtendedPrivateKeyReaderController(self, success: {
                    (data: String!) in
                    self.importAccount(data)
                }, error: {
                    (data: String?) in
                })

            } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)! + 1) {
                TLPrompts.promtForInputText(self, title: "Import Account".localized, message: "Input account private key".localized, textFieldPlaceholder: nil, success: {
                    (inputText: String!) in
                    self.importAccount(inputText)
                }, failure: {
                    (isCanceled: Bool) in
                })
            } else if (buttonIndex == actionSheet?.cancelButtonIndex) {
            }
        })
    }

    fileprivate func promptImportWatchAccountActionSheet() -> () {
        UIAlertController.showAlert(in: self,
            withTitle: "Import Watch Account".localized,
            message:"",
            preferredStyle: .actionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Import via QR code".localized, "Import via text input".localized],
            tap: {(actionSheet, action, buttonIndex) in
                if (buttonIndex == (actionSheet?.firstOtherButtonIndex)! + 0) {
                    AppDelegate.instance().showExtendedPublicKeyReaderController(self, success: {
                        (data: String!) in
                        self.importWatchOnlyAccount(data)
                        }, error: {
                            (data: String?) in
                    })
                } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)! + 1) {
                    TLPrompts.promtForInputText(self, title: "Import Watch Account", message: "Input account public key", textFieldPlaceholder: nil, success: {
                        (inputText: String!) in
                        self.importWatchOnlyAccount(inputText)
                        }, failure: {
                            (isCanceled: Bool) in
                    })
                } else if (buttonIndex == actionSheet?.cancelButtonIndex) {
                }
        })
    }

    fileprivate func promptImportPrivateKeyActionSheet() -> () {
        UIAlertController.showAlert(in: self,
            withTitle: "Import Private Key".localized,
            message:"",
            preferredStyle: .actionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Import via QR code".localized, "Import via text input".localized],
            tap: {(actionSheet, action, buttonIndex) in
                if (buttonIndex == (actionSheet?.firstOtherButtonIndex)! + 0) {
                    AppDelegate.instance().showPrivateKeyReaderController(self, success: {
                        (data: NSDictionary) in
                        let privateKey = data.object(forKey: "privateKey") as? String
                        let encryptedPrivateKey = data.object(forKey: "encryptedPrivateKey") as? String
                        if encryptedPrivateKey == nil {
                            self.checkAndImportAddress(privateKey!, encryptedPrivateKey: encryptedPrivateKey)
                        }
                        }, error: {
                            (data: String?) in
                    })
                } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)! + 1) {
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
                } else if (buttonIndex == actionSheet?.cancelButtonIndex) {
                }
        })
    }

    fileprivate func promptImportWatchAddressActionSheet() -> () {
        UIAlertController.showAlert(in: self,
            withTitle: "Import Watch Address".localized,
            message:"",
            preferredStyle: .actionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Import via QR code".localized, "Import via text input".localized],
            tap: {(actionSheet, action, buttonIndex) in
                if (buttonIndex == (actionSheet?.firstOtherButtonIndex)! + 0) {
                    AppDelegate.instance().showAddressReaderControllerFromViewController(self, success: {
                        (data: String!) in
                        self.checkAndImportWatchAddress(data)
                        }, error: {
                            (data: String?) in
                    })
                } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)! + 1) {
                    TLPrompts.promtForInputText(self, title: "Import Watch Address".localized, message: "Input watch address".localized, textFieldPlaceholder: nil, success: {
                        (inputText: String!) in
                        self.checkAndImportWatchAddress(inputText)
                        }, failure: {
                            (isCanceled: Bool) in
                    })
                } else if (buttonIndex == actionSheet?.cancelButtonIndex) {
                }
        })
    }

    fileprivate func doAccountAction(_ accountSelectIdx: Int) -> () {
        var count = 0
        let CREATE_NEW_ACCOUNT_BUTTON_IDX = count
        count +=  1
        var IMPORT_COLD_WALLET_ACCOUNT_BUTTON_IDX = -1
        if TLPreferences.enabledColdWallet() {
            IMPORT_COLD_WALLET_ACCOUNT_BUTTON_IDX = count
        }
        count +=  1
        let IMPORT_ACCOUNT_BUTTON_IDX = count
        count +=  1
        let IMPORT_WATCH_ACCOUNT_BUTTON_IDX = count
        count +=  1
        let IMPORT_PRIVATE_KEY_BUTTON_IDX = count
        count +=  1
        let IMPORT_WATCH_ADDRESS_BUTTON_IDX = count
        
        if (accountSelectIdx == CREATE_NEW_ACCOUNT_BUTTON_IDX) {
            if (AppDelegate.instance().accounts!.getNumberOfAccounts() >= MAX_ACTIVE_CREATED_ACCOUNTS) {
                TLPrompts.promptErrorMessage("Maximum accounts reached".localized, message: "You need to archive an account in order to create a new one.".localized)
                return
            }
            self.promtForNameAccount({
                (accountName: String!) in
                AppDelegate.instance().accounts!.createNewAccount(accountName, accountType: .normal)

                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_CREATE_NEW_ACCOUNT()), object: nil, userInfo: nil)

                self.refreshWalletAccounts(false)
                TLStealthWebSocket.instance().sendMessageGetChallenge()
            }, failure: {
                (isCanceled: Bool) in
            })
        } else if (accountSelectIdx == IMPORT_COLD_WALLET_ACCOUNT_BUTTON_IDX) {
            if (AppDelegate.instance().coldWalletAccounts!.getNumberOfAccounts() + AppDelegate.instance().importedAccounts!.getNumberOfAccounts() + AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts() >= MAX_IMPORTED_ACCOUNTS) {
                TLPrompts.promptErrorMessage("Maximum imported accounts reached.".localized, message: "You need to archive an imported account in order to import a new one.".localized)
                return
            }
            self.promptColdWalletAccountActionSheet()
        } else if (accountSelectIdx == IMPORT_ACCOUNT_BUTTON_IDX) {
            if (AppDelegate.instance().coldWalletAccounts!.getNumberOfAccounts() + AppDelegate.instance().importedAccounts!.getNumberOfAccounts() + AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts() >= MAX_IMPORTED_ACCOUNTS) {
                TLPrompts.promptErrorMessage("Maximum imported accounts reached.".localized, message: "You need to archive an imported account in order to import a new one.".localized)
                return
            }
            self.promptImportAccountActionSheet()
        } else if (accountSelectIdx == IMPORT_WATCH_ACCOUNT_BUTTON_IDX) {
            if (AppDelegate.instance().coldWalletAccounts!.getNumberOfAccounts() + AppDelegate.instance().importedAccounts!.getNumberOfAccounts() + AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts() >= MAX_IMPORTED_ACCOUNTS) {
                TLPrompts.promptErrorMessage("Maximum imported accounts reached.".localized, message: "You need to archive an imported account in order to import a new one.".localized)
                return
            }
            self.promptImportWatchAccountActionSheet()
        } else if (accountSelectIdx == IMPORT_PRIVATE_KEY_BUTTON_IDX) {
            if (AppDelegate.instance().importedAddresses!.getCount() + AppDelegate.instance().importedWatchAddresses!.getCount() >= MAX_IMPORTED_ADDRESSES) {
                TLPrompts.promptErrorMessage("Maximum imported addresses and private keys reached.".localized, message: "You need to archive an imported private key or address in order to import a new one.".localized)
                return
            }
            self.promptImportPrivateKeyActionSheet()
        } else if (accountSelectIdx == IMPORT_WATCH_ADDRESS_BUTTON_IDX) {
            if (AppDelegate.instance().importedAddresses!.getCount() + AppDelegate.instance().importedWatchAddresses!.getCount() >= MAX_IMPORTED_ADDRESSES) {
                TLPrompts.promptErrorMessage("Maximum imported addresses and private keys reached.".localized, message: "You need to archive an imported private key or address in order to import a new one.".localized)
                return
            }
            self.promptImportWatchAddressActionSheet()
        }
    }

    @IBAction fileprivate func menuButtonClicked(_ sender: UIButton) {
        self.slidingViewController().anchorTopViewToRight(animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt heightForRowAtIndexPath: IndexPath) -> CGFloat {
        // hard code height here to prevent cell auto-resizing
        return 74
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (TLPreferences.enabledAdvancedMode()) {
            if (section == accountListSection) {
                return "Accounts".localized
            } else if (section == coldWalletAccountSection) {
                return "Cold Wallet Accounts".localized
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
            } else if (section == archivedColdWalletAccountSection) {
                return "Archived Cold Wallet Accounts".localized
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
            } else if (section == coldWalletAccountSection) {
                return "Cold Wallet Accounts".localized
            } else if (section == archivedAccountSection) {
                return "Archived Accounts".localized
            } else if (section == archivedColdWalletAccountSection) {
                return "Archived Cold Wallet Accounts".localized
            } else {
                return "Account Actions".localized
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (TLPreferences.enabledAdvancedMode()) {
            if (section == accountListSection) {
                return AppDelegate.instance().accounts!.getNumberOfAccounts()
            } else if (section == coldWalletAccountSection) {
                return AppDelegate.instance().coldWalletAccounts!.getNumberOfAccounts()
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
            } else if (section == archivedColdWalletAccountSection) {
                return AppDelegate.instance().coldWalletAccounts!.getNumberOfArchivedAccounts()
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
        } else if (section == coldWalletAccountSection) {
            return AppDelegate.instance().coldWalletAccounts!.getNumberOfAccounts()
        } else if (section == archivedAccountSection) {
            return AppDelegate.instance().accounts!.getNumberOfArchivedAccounts()
        } else if (section == archivedColdWalletAccountSection) {
            return AppDelegate.instance().coldWalletAccounts!.getNumberOfArchivedAccounts()
        } else {
            return accountActionsArray!.count
        }
    }


    fileprivate func setUpCellAccountActions(_ cell: UITableViewCell, cellForRowAtIndexPath indexPath: IndexPath) -> () {
        cell.accessoryType = UITableViewCellAccessoryType.none
        cell.textLabel!.text = accountActionsArray!.object(at: (indexPath as NSIndexPath).row) as? String
        if(cell.accessoryView != nil) {
            (cell.accessoryView as! UIActivityIndicatorView).isHidden = true
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if ((indexPath as NSIndexPath).section == accountActionSection) {
            let MyIdentifier = "AccountActionCellIdentifier"

            var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) 
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.default,
                        reuseIdentifier: MyIdentifier)
            }

            cell!.textLabel!.textAlignment = .center
            cell!.textLabel!.font = UIFont.boldSystemFont(ofSize: cell!.textLabel!.font.pointSize)
            self.setUpCellAccountActions(cell!, cellForRowAtIndexPath: indexPath)

            if ((indexPath as NSIndexPath).row % 2 == 0) {
                cell!.backgroundColor = TLColors.evenTableViewCellColor()
            } else {
                cell!.backgroundColor = TLColors.oddTableViewCellColor()
            }

            return cell!
        } else {
            let MyIdentifier = "AccountCellIdentifier"

            var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) as? TLAccountTableViewCell
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.default,
                        reuseIdentifier: MyIdentifier) as? TLAccountTableViewCell
            }

            cell!.accountNameLabel!.textAlignment = .natural
            let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            cell!.accessoryView = activityView

            if (TLPreferences.enabledAdvancedMode()) {
                if ((indexPath as NSIndexPath).section == accountListSection) {
                    let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx((indexPath as NSIndexPath).row)
                    self.setUpCellAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if ((indexPath as NSIndexPath).section == coldWalletAccountSection) {
                    let accountObject = AppDelegate.instance().coldWalletAccounts!.getAccountObjectForIdx((indexPath as NSIndexPath).row)
                    self.setUpCellAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if ((indexPath as NSIndexPath).section == importedAccountSection) {
                    let accountObject = AppDelegate.instance().importedAccounts!.getAccountObjectForIdx((indexPath as NSIndexPath).row)
                    self.setUpCellAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if ((indexPath as NSIndexPath).section == importedWatchAccountSection) {
                    let accountObject = AppDelegate.instance().importedWatchAccounts!.getAccountObjectForIdx((indexPath as NSIndexPath).row)
                    self.setUpCellAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if ((indexPath as NSIndexPath).section == importedAddressSection) {
                    let importedAddressObject = AppDelegate.instance().importedAddresses!.getAddressObjectAtIdx((indexPath as NSIndexPath).row)
                    self.setUpCellImportedAddresses(importedAddressObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if ((indexPath as NSIndexPath).section == importedWatchAddressSection) {
                    let importedAddressObject = AppDelegate.instance().importedWatchAddresses!.getAddressObjectAtIdx((indexPath as NSIndexPath).row)
                    self.setUpCellImportedAddresses(importedAddressObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if ((indexPath as NSIndexPath).section == archivedAccountSection) {
                    let accountObject = AppDelegate.instance().accounts!.getArchivedAccountObjectForIdx((indexPath as NSIndexPath).row)
                    self.setUpCellArchivedAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if ((indexPath as NSIndexPath).section == archivedColdWalletAccountSection) {
                    let accountObject = AppDelegate.instance().coldWalletAccounts!.getArchivedAccountObjectForIdx((indexPath as NSIndexPath).row)
                    self.setUpCellArchivedAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if ((indexPath as NSIndexPath).section == archivedImportedAccountSection) {
                    let accountObject = AppDelegate.instance().importedAccounts!.getArchivedAccountObjectForIdx((indexPath as NSIndexPath).row)
                    self.setUpCellArchivedAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if ((indexPath as NSIndexPath).section == archivedImportedWatchAccountSection) {
                    let accountObject = AppDelegate.instance().importedWatchAccounts!.getArchivedAccountObjectForIdx((indexPath as NSIndexPath).row)
                    self.setUpCellArchivedAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if ((indexPath as NSIndexPath).section == archivedImportedAddressSection) {
                    let importedAddressObject = AppDelegate.instance().importedAddresses!.getArchivedAddressObjectAtIdx((indexPath as NSIndexPath).row)
                    self.setUpCellArchivedImportedAddresses(importedAddressObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if ((indexPath as NSIndexPath).section == archivedImportedWatchAddressSection) {
                    let importedAddressObject = AppDelegate.instance().importedWatchAddresses!.getArchivedAddressObjectAtIdx((indexPath as NSIndexPath).row)
                    self.setUpCellArchivedImportedAddresses(importedAddressObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else {
                }
            } else {
                if ((indexPath as NSIndexPath).section == accountListSection) {
                    let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx((indexPath as NSIndexPath).row)
                    self.setUpCellAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if ((indexPath as NSIndexPath).section == coldWalletAccountSection) {
                    let accountObject = AppDelegate.instance().coldWalletAccounts!.getAccountObjectForIdx((indexPath as NSIndexPath).row)
                    self.setUpCellAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if ((indexPath as NSIndexPath).section == archivedAccountSection) {
                    let accountObject = AppDelegate.instance().accounts!.getArchivedAccountObjectForIdx((indexPath as NSIndexPath).row)
                    self.setUpCellArchivedAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else if ((indexPath as NSIndexPath).section == archivedColdWalletAccountSection) {
                    let accountObject = AppDelegate.instance().coldWalletAccounts!.getArchivedAccountObjectForIdx((indexPath as NSIndexPath).row)
                    self.setUpCellArchivedAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
                } else {
                }
            }

            if ((indexPath as NSIndexPath).row % 2 == 0) {
                cell!.backgroundColor = TLColors.evenTableViewCellColor()
            } else {
                cell!.backgroundColor = TLColors.oddTableViewCellColor()
            }

            return cell!
        }
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (TLPreferences.enabledAdvancedMode()) {
            if ((indexPath as NSIndexPath).section == accountListSection) {
                self.promptAccountsActionSheet((indexPath as NSIndexPath).row)
                return nil
            } else if ((indexPath as NSIndexPath).section == coldWalletAccountSection) {
                self.promptColdWalletAccountsActionSheet(indexPath)
                return nil
            } else if ((indexPath as NSIndexPath).section == importedAccountSection) {
                self.promptImportedAccountsActionSheet(indexPath)
                return nil
            } else if ((indexPath as NSIndexPath).section == importedWatchAccountSection) {
                self.promptImportedWatchAccountsActionSheet(indexPath)
                return nil
            } else if ((indexPath as NSIndexPath).section == importedAddressSection) {
                self.promptImportedAddressActionSheet((indexPath as NSIndexPath).row)
                return nil
            } else if ((indexPath as NSIndexPath).section == importedWatchAddressSection) {
                self.promptImportedWatchAddressActionSheet((indexPath as NSIndexPath).row)
                return nil
            } else if ((indexPath as NSIndexPath).section == archivedAccountSection) {
                self.promptArchivedAccountsActionSheet((indexPath as NSIndexPath).row)
                return nil
            } else if ((indexPath as NSIndexPath).section == archivedColdWalletAccountSection) {
                self.promptArchivedImportedAccountsActionSheet(indexPath, accountType: .coldWallet)
                return nil
            } else if ((indexPath as NSIndexPath).section == archivedImportedAccountSection) {
                self.promptArchivedImportedAccountsActionSheet(indexPath, accountType: .imported)
                return nil
            } else if ((indexPath as NSIndexPath).section == archivedImportedWatchAccountSection) {
                self.promptArchivedImportedAccountsActionSheet(indexPath, accountType: .importedWatch)
                return nil
            } else if ((indexPath as NSIndexPath).section == archivedImportedAddressSection) {
                self.promptArchivedImportedAddressActionSheet((indexPath as NSIndexPath).row)
                return nil
            } else if ((indexPath as NSIndexPath).section == archivedImportedWatchAddressSection) {
                self.promptArchivedImportedWatchAddressActionSheet((indexPath as NSIndexPath).row)
                return nil
            } else {
                self.doAccountAction((indexPath as NSIndexPath).row)
                return nil
            }
        } else {
            if ((indexPath as NSIndexPath).section == accountListSection) {
                self.promptAccountsActionSheet((indexPath as NSIndexPath).row)
                return nil
            } else if ((indexPath as NSIndexPath).section == coldWalletAccountSection) {
                self.promptColdWalletAccountsActionSheet(indexPath)
                return nil
            } else if ((indexPath as NSIndexPath).section == archivedAccountSection) {
                self.promptArchivedAccountsActionSheet((indexPath as NSIndexPath).row)
                return nil
            } else if ((indexPath as NSIndexPath).section == archivedColdWalletAccountSection) {
                self.promptArchivedImportedAccountsActionSheet(indexPath, accountType: .imported)
                return nil
            } else {
                self.doAccountAction((indexPath as NSIndexPath).row)
                return nil
            }
        }
    }

    func customIOS7dialogButtonTouchUp(inside alertView: AnyObject!, clickedButtonAt buttonIndex: Int) -> () {
        if (buttonIndex == 0) {
            iToast.makeText("Copied To clipboard".localized).setGravity(iToastGravityCenter).setDuration(1000).show()
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.QRImageModal!.QRcodeDisplayData
        } else {

        }

        alertView.close()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
