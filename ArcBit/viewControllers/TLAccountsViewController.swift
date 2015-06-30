//
//  TLAccountsViewController.swift
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


@objc(TLAccountsViewController) class TLAccountsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet private var accountsTableView: UITableView?
    private var numberOfSections = 0
    private var accountListSection = 0
    private var importedAccountSection = 0
    private var importedWatchAccountSection = 0
    private var importedAddressSection = 0
    private var importedWatchAddressSection = 0
    private var accountRefreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        
        accountListSection = 0
        
        self.accountsTableView!.delegate = self
        self.accountsTableView!.dataSource = self
        self.accountsTableView!.tableFooterView = UIView(frame: CGRectZero)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshWalletAccountsNotification:",
            name: TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED(), object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshWalletAccountsNotification:",
            name: TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA(), object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "accountsTableViewReloadDataWrapper:",
            name: TLNotificationEvents.EVENT_ADVANCE_MODE_TOGGLED(), object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "accountsTableViewReloadDataWrapper:", name: TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_UNCONFIRMED_TRANSACTION(), object: nil)
        
        accountRefreshControl = UIRefreshControl()
        accountRefreshControl!.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        self.accountsTableView!.addSubview(accountRefreshControl!)
        
        self.checkToRecoverAccounts()
        
        self.refreshWalletAccounts(false)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        self.refreshWalletAccounts(true)
        accountRefreshControl!.endRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.refreshWalletAccounts(false)
    }
    
    override func viewDidAppear(animated: Bool) -> () {
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_ACCOUNTS_SCREEN(),
            object: nil, userInfo: nil)
    }
    
    private func checkToRecoverAccounts() {
        if (AppDelegate.instance().aAccountNeedsRecovering()) {
            TLHUDWrapper.showHUDAddedTo(self.slidingViewController().topViewController!.view,
                labelText: "Recovering Accounts", animated: true)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                AppDelegate.instance().checkToRecoverAccounts()
                dispatch_async(dispatch_get_main_queue()) {
                    self.refreshWalletAccounts(false)
                    TLHUDWrapper.hideHUDForView(self.view, animated: true)
                }
            }
        }
    }
    
    private func refreshImportedAccounts(fetchDataAgain: Bool) {
        for (var i = 0; i < AppDelegate.instance().importedAccounts!.getNumberOfAccounts(); i++) {
            let accountObject = AppDelegate.instance().importedAccounts!.getAccountObjectForIdx(i)
            let indexPath = NSIndexPath(forRow: i, inSection: importedAccountSection)
            if (!accountObject.hasFetchedAccountData() || fetchDataAgain) {
                let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell
                if cell != nil {
                    (cell!.accessoryView as! UIActivityIndicatorView).hidden = false
                    cell!.accountBalanceButton!.hidden = true
                    (cell!.accessoryView as! UIActivityIndicatorView).startAnimating()
                }
                AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject,
                    fetchDataAgain: fetchDataAgain, success: {
                        if cell != nil {
                            (cell!.accessoryView as! UIActivityIndicatorView).stopAnimating()
                            (cell!.accessoryView as! UIActivityIndicatorView).hidden = true
                            cell!.accountBalanceButton!.hidden = false
                            if accountObject.downloadState == .Downloaded {
                                let balance = TLWalletUtils.getProperAmount(accountObject.getBalance())
                                cell!.accountBalanceButton!.setTitle(balance as String, forState: .Normal)
                            }
                            cell!.accountBalanceButton!.hidden = false
                        }
                })
            } else {
                if let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell {
                    cell.accountNameLabel!.text = accountObject.getAccountName()
                    let balance = TLWalletUtils.getProperAmount(accountObject.getBalance())
                    cell.accountBalanceButton!.setTitle(balance as String, forState: .Normal)
                }
            }
        }
    }
    
    private func refreshImportedWatchAccounts(fetchDataAgain: Bool) {
        for (var i = 0; i < AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts(); i++) {
            let accountObject = AppDelegate.instance().importedWatchAccounts!.getAccountObjectForIdx(i)
            let indexPath = NSIndexPath(forRow: i, inSection:importedWatchAccountSection)
            if (!accountObject.hasFetchedAccountData() || fetchDataAgain) {
                let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell
                if cell != nil {
                    (cell!.accessoryView as! UIActivityIndicatorView).hidden = false
                    cell!.accountBalanceButton!.hidden = true
                    (cell!.accessoryView as! UIActivityIndicatorView).startAnimating()
                }
                AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject,
                    fetchDataAgain: fetchDataAgain, success: {
                        if cell != nil {
                            (cell!.accessoryView as! UIActivityIndicatorView).stopAnimating()
                            (cell!.accessoryView as! UIActivityIndicatorView).hidden = true
                            cell!.accountBalanceButton!.hidden = false
                            if accountObject.downloadState == .Downloaded {
                                let balance = TLWalletUtils.getProperAmount(accountObject.getBalance())
                                cell!.accountBalanceButton!.setTitle(balance as String, forState: .Normal)
                            }
                            cell!.accountBalanceButton!.hidden = false
                        }
                })
            } else {
                if let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell {
                    cell.accountNameLabel!.text = accountObject.getAccountName()
                    let balance = TLWalletUtils.getProperAmount(accountObject.getBalance())
                    cell.accountBalanceButton!.setTitle(balance as String, forState: .Normal)
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
                                let balance = TLWalletUtils.getProperAmount(importAddressObject.getBalance()!)
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
                            let balance = TLWalletUtils.getProperAmount(importAddressObject.getBalance()!)
                            cell.accountBalanceButton!.setTitle(balance as String, forState: .Normal)
                        }
                        cell.accountBalanceButton!.hidden = false
                    }
                }
            })
        }
    }
    
    private func refreshAccountBalances(fetchDataAgain: Bool) {
        for (var i = 0; i < AppDelegate.instance().accounts!.getNumberOfAccounts(); i++) {
            let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx(i)
            let indexPath = NSIndexPath(forRow: i, inSection: accountListSection)
            if (!accountObject.hasFetchedAccountData() || fetchDataAgain) {
                let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell
                if cell != nil {
                    (cell!.accessoryView as! UIActivityIndicatorView).hidden = false
                    cell!.accountBalanceButton!.hidden = true
                    (cell!.accessoryView as! UIActivityIndicatorView).startAnimating()
                }
                
                AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: fetchDataAgain, success: {
                    if cell != nil {
                        (cell!.accessoryView as! UIActivityIndicatorView).stopAnimating()
                        (cell!.accessoryView as! UIActivityIndicatorView).hidden = true
                        cell!.accountBalanceButton!.hidden = false
                        if accountObject.downloadState == .Downloaded {
                            let balance = TLWalletUtils.getProperAmount(accountObject.getBalance())
                            cell!.accountBalanceButton!.setTitle(balance as String, forState: .Normal)
                        }
                        cell!.accountBalanceButton!.hidden = false
                    }
                })
            } else {
                if let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell {
                    cell.accountNameLabel!.text = accountObject.getAccountName()
                    let balance = TLWalletUtils.getProperAmount(accountObject.getBalance())
                    cell.accountBalanceButton!.setTitle(balance as String, forState: .Normal)
                }
            }
        }
    }
    
    private func updateAccountCellWithAccountID(accountIdxNumber: Int) {
        let accountObject = AppDelegate.instance().accounts!.getAccountObjectForAccountIdxNumber(accountIdxNumber)
        let accountIdx = AppDelegate.instance().accounts!.getIdxForAccountObject(accountObject)
        let indexPath = NSIndexPath(forRow: accountIdx, inSection: accountListSection)
        
        if let cell = self.accountsTableView!.cellForRowAtIndexPath(indexPath) as? TLAccountTableViewCell {
            let balance = TLWalletUtils.getProperAmount(accountObject.getBalance())
            cell.accountBalanceButton!.setTitle(balance as String, forState: .Normal)
            cell.accountNameLabel!.text = (accountObject.getAccountName())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refreshWalletAccountsNotification(notification: NSNotification) {
        self.refreshWalletAccounts(false)
    }
    
    private func refreshWalletAccounts(fetchDataAgain: Bool) {
        self._accountsTableViewReloadDataWrapper()
        self.refreshAccountBalances(fetchDataAgain)
        if (TLPreferences.enabledAdvanceMode()) {
            self.refreshImportedAccounts(fetchDataAgain)
            self.refreshImportedWatchAccounts(fetchDataAgain)
            self.refreshImportedAddressBalances(fetchDataAgain)
            self.refreshImportedWatchAddressBalances(fetchDataAgain)
        }
    }
    
    private func setUpCellAccounts(accountObject: TLAccountObject, cell: TLAccountTableViewCell, cellForRowAtIndexPath indexPath: NSIndexPath) {
        cell.accountNameLabel!.text = accountObject.getAccountName()
        if (accountObject.hasFetchedAccountData()) {
            (cell.accessoryView as! UIActivityIndicatorView).hidden = true
            (cell.accessoryView as! UIActivityIndicatorView).stopAnimating()
            let balance = TLWalletUtils.getProperAmount(accountObject.getBalance())
            cell.accountBalanceButton!.setTitle(balance as String, forState: .Normal)
            cell.accountBalanceButton!.hidden = false
        } else {
            (cell.accessoryView as! UIActivityIndicatorView).hidden = false
            (cell.accessoryView as! UIActivityIndicatorView).startAnimating()
            AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: false, success: {
                (cell.accessoryView as! UIActivityIndicatorView).stopAnimating()
                (cell.accessoryView as! UIActivityIndicatorView).hidden = true
                if accountObject.downloadState == .Downloaded {
                    let balance = TLWalletUtils.getProperAmount(accountObject.getBalance())
                    cell.accountBalanceButton!.setTitle(balance as String, forState: .Normal)
                    cell.accountBalanceButton!.hidden = false
                }
            })
        }
    }
    
    private func setUpCellImportedAddresses(importedAddressObject: TLImportedAddress, cell: TLAccountTableViewCell, cellForRowAtIndexPath indexPath: NSIndexPath) {
        let label = importedAddressObject.getLabel()
        cell.accountNameLabel!.text = label
        
        if (importedAddressObject.hasFetchedAccountData()) {
            (cell.accessoryView as! UIActivityIndicatorView).hidden = true
            (cell.accessoryView as! UIActivityIndicatorView).stopAnimating()
            let balance = TLWalletUtils.getProperAmount(importedAddressObject.getBalance()!)
            cell.accountBalanceButton!.setTitle(balance as String, forState: .Normal)
            cell.accountBalanceButton!.hidden = false
        }
    }
    
    func _accountsTableViewReloadDataWrapper() {
        numberOfSections = 1
        
        var sectionCounter = 1
        
        if (TLPreferences.enabledAdvanceMode()) {
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
        }
        
        self.accountsTableView!.reloadData()}
    
    func accountsTableViewReloadDataWrapper(notification: NSNotification) {
        _accountsTableViewReloadDataWrapper()
    }
    
    private func doSelectFrom(sendFromType: TLSendFromType, sendFromIndex: NSInteger) {
        var viewControllersIdx = self.navigationController!.viewControllers.count - 2
        // make sure viewControllersIdx not negative
        if (self.navigationController!.viewControllers.count < 2) {
            viewControllersIdx = 0
        }
        
        self.navigationController!.popToViewController((self.navigationController!.viewControllers as NSArray).objectAtIndex(viewControllersIdx) as! UIViewController, animated: true)
        let selectedDict = ["sendFromType": sendFromType.rawValue, "sendFromIndex": sendFromIndex]
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_ACCOUNT_SELECTED(), object: selectedDict, userInfo: nil)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // hard code height here to prevent cell auto-resizing
        return 74
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (TLPreferences.enabledAdvanceMode()) {
            if (section == accountListSection) {
                return "Accounts"
            } else if (section == importedAccountSection) {
                return "Imported Accounts"
            } else if (section == importedWatchAccountSection) {
                return "Imported Watch Accounts"
            } else if (section == importedAddressSection) {
                return "Imported Addresses"
            } else if (section == importedWatchAddressSection) {
                return "Imported Watch Addresses"
            } else {
            }
        } else {
            if (section == accountListSection) {
                return "Accounts"
            } else {
            }
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (TLPreferences.enabledAdvanceMode()) {
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
            } else {
                
            }
        } else {
            if (section == accountListSection) {
                return AppDelegate.instance().accounts!.getNumberOfAccounts()
            } else {
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let MyIdentifier = "AccountCellIdentifier"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier) as! TLAccountTableViewCell?
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default,
                reuseIdentifier: MyIdentifier) as? TLAccountTableViewCell
        }
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        cell!.accessoryView = (activityView)
        
        cell!.accountBalanceButton!.titleLabel!.adjustsFontSizeToFitWidth = true
        
        if (TLPreferences.enabledAdvanceMode()) {
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
            } else {
            }
        } else {
            if (indexPath.section == accountListSection) {
                let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx(indexPath.row)
                self.setUpCellAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
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
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if (TLPreferences.enabledAdvanceMode()) {
            if (indexPath.section == accountListSection) {
                let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx(indexPath.row)
                if (accountObject.hasFetchedAccountData()) {
                    self.doSelectFrom(.HDWallet, sendFromIndex: indexPath.row)
                }
                return nil
            } else if (indexPath.section == importedAccountSection) {
                self.doSelectFrom(.ImportedAccount, sendFromIndex: indexPath.row)
                return nil
            } else if (indexPath.section == importedWatchAccountSection) {
                self.doSelectFrom(.ImportedWatchAccount, sendFromIndex: indexPath.row)
                return nil
            } else if (indexPath.section == importedAddressSection) {
                self.doSelectFrom(.ImportedAddress, sendFromIndex: indexPath.row)
                return nil
            } else if (indexPath.section == importedWatchAddressSection) {
                self.doSelectFrom(.ImportedWatchAddress, sendFromIndex: indexPath.row)
                return nil
            } else {
            }
        } else {
            if (indexPath.section == accountListSection) {
                let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx(indexPath.row)
                
                if (accountObject.hasFetchedAccountData()) {
                    self.doSelectFrom(.HDWallet, sendFromIndex: indexPath.row)
                }
            } else {
            }
        }
        
        return nil
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
