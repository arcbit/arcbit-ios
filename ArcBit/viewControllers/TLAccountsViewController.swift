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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet fileprivate var accountsTableView: UITableView?
    fileprivate var numberOfSections = 0
    fileprivate var accountListSection = 0
    fileprivate var coldWalletAccountSection = 0
    fileprivate var importedAccountSection = 0
    fileprivate var importedWatchAccountSection = 0
    fileprivate var importedAddressSection = 0
    fileprivate var importedWatchAddressSection = 0
    fileprivate var accountRefreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        
        accountListSection = 0
        
        self.accountsTableView!.delegate = self
        self.accountsTableView!.dataSource = self
        self.accountsTableView!.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TLAccountsViewController.refreshWalletAccountsNotification(_:)),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED()), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TLAccountsViewController.refreshWalletAccountsNotification(_:)),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA()), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TLAccountsViewController.accountsTableViewReloadDataWrapper(_:)),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_ADVANCE_MODE_TOGGLED()), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TLAccountsViewController.accountsTableViewReloadDataWrapper(_:)), name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_UNCONFIRMED_TRANSACTION()), object: nil)
        
        accountRefreshControl = UIRefreshControl()
        accountRefreshControl!.addTarget(self, action: #selector(TLAccountsViewController.refresh(_:)), for: .valueChanged)
        self.accountsTableView!.addSubview(accountRefreshControl!)
        
        self.checkToRecoverAccounts()
        
        self.refreshWalletAccounts(false)
    }
    
    func refresh(_ refreshControl: UIRefreshControl) {
        self.refreshWalletAccounts(true)
        accountRefreshControl!.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshWalletAccounts(false)
    }
    
    override func viewDidAppear(_ animated: Bool) -> () {
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_ACCOUNTS_SCREEN()),
            object: nil, userInfo: nil)
    }
    
    fileprivate func checkToRecoverAccounts() {
        if (AppDelegate.instance().aAccountNeedsRecovering()) {
            TLHUDWrapper.showHUDAddedTo(self.slidingViewController().topViewController!.view,
                labelText: "Recovering Accounts".localized, animated: true)
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
                AppDelegate.instance().checkToRecoverAccounts()
                DispatchQueue.main.async {
                    self.refreshWalletAccounts(false)
                    TLHUDWrapper.hideHUDForView(self.view, animated: true)
                }
            }
        }
    }
    
    fileprivate func refreshColdWalletAccounts(_ fetchDataAgain: Bool) {
        for i in stride(from: 0, to: AppDelegate.instance().coldWalletAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = AppDelegate.instance().coldWalletAccounts!.getAccountObjectForIdx(i)
            let indexPath = IndexPath(row: i, section:coldWalletAccountSection)
            if (!accountObject.hasFetchedAccountData() || fetchDataAgain) {
                let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell
                if cell != nil {
                    (cell!.accessoryView as! UIActivityIndicatorView).isHidden = false
                    cell!.accountBalanceButton!.isHidden = true
                    (cell!.accessoryView as! UIActivityIndicatorView).startAnimating()
                }
                AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject,
                                                                                  fetchDataAgain: fetchDataAgain, success: {
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
    
    fileprivate func refreshImportedAccounts(_ fetchDataAgain: Bool) {
        for i in stride(from: 0, to: AppDelegate.instance().importedAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = AppDelegate.instance().importedAccounts!.getAccountObjectForIdx(i)
            let indexPath = IndexPath(row: i, section: importedAccountSection)
            if (!accountObject.hasFetchedAccountData() || fetchDataAgain) {
                let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell
                if cell != nil {
                    (cell!.accessoryView as! UIActivityIndicatorView).isHidden = false
                    cell!.accountBalanceButton!.isHidden = true
                    (cell!.accessoryView as! UIActivityIndicatorView).startAnimating()
                }
                AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject,
                    fetchDataAgain: fetchDataAgain, success: {
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
    
    fileprivate func refreshImportedWatchAccounts(_ fetchDataAgain: Bool) {
        for i in stride(from: 0, to: AppDelegate.instance().importedWatchAccounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = AppDelegate.instance().importedWatchAccounts!.getAccountObjectForIdx(i)
            let indexPath = IndexPath(row: i, section:importedWatchAccountSection)
            if (!accountObject.hasFetchedAccountData() || fetchDataAgain) {
                let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell
                if cell != nil {
                    (cell!.accessoryView as! UIActivityIndicatorView).isHidden = false
                    cell!.accountBalanceButton!.isHidden = true
                    (cell!.accessoryView as! UIActivityIndicatorView).startAnimating()
                }
                AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject,
                    fetchDataAgain: fetchDataAgain, success: {
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
                for i in stride(from: 0, to: AppDelegate.instance().importedAddresses!.getCount(), by: 1) {
                    let indexPath = IndexPath(row: i, section: importedAddressSection)
                    if let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell {
                        (cell.accessoryView as! UIActivityIndicatorView).isHidden = false
                        cell.accountBalanceButton!.isHidden = true
                        (cell.accessoryView as! UIActivityIndicatorView).startAnimating()
                    }
                }
                
                AppDelegate.instance().pendingOperations.addSetUpImportedAddressesOperation(AppDelegate.instance().importedAddresses!, fetchDataAgain: fetchDataAgain, success: {
                    for i in stride(from: 0, to: AppDelegate.instance().importedAddresses!.getCount(), by: 1) {
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
            for i in stride(from: 0, to: AppDelegate.instance().importedWatchAddresses!.getCount(), by: 1) {
                let indexPath = IndexPath(row: i, section: importedWatchAddressSection)
                if let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell {
                    (cell.accessoryView as! UIActivityIndicatorView).isHidden = false
                    cell.accountBalanceButton!.isHidden = true
                    (cell.accessoryView as! UIActivityIndicatorView).startAnimating()
                }
            }
            
            AppDelegate.instance().pendingOperations.addSetUpImportedAddressesOperation(AppDelegate.instance().importedWatchAddresses!, fetchDataAgain: fetchDataAgain, success: {
                for i in stride(from: 0, to: AppDelegate.instance().importedWatchAddresses!.getCount(), by: 1) {
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
    
    fileprivate func refreshAccountBalances(_ fetchDataAgain: Bool) {
        for i in stride(from: 0, to: AppDelegate.instance().accounts!.getNumberOfAccounts(), by: 1) {
            let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx(i)
            let indexPath = IndexPath(row: i, section: accountListSection)
            if (!accountObject.hasFetchedAccountData() || fetchDataAgain) {
                let cell = self.accountsTableView!.cellForRow(at: indexPath) as? TLAccountTableViewCell
                if cell != nil {
                    (cell!.accessoryView as! UIActivityIndicatorView).isHidden = false
                    cell!.accountBalanceButton!.isHidden = true
                    (cell!.accessoryView as! UIActivityIndicatorView).startAnimating()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refreshWalletAccountsNotification(_ notification: Notification) {
        self.refreshWalletAccounts(false)
    }
    
    fileprivate func refreshWalletAccounts(_ fetchDataAgain: Bool) {
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
    
    fileprivate func setUpCellAccounts(_ accountObject: TLAccountObject, cell: TLAccountTableViewCell, cellForRowAtIndexPath indexPath: IndexPath) {
        cell.accountNameLabel!.text = accountObject.getAccountName()
        if (accountObject.hasFetchedAccountData()) {
            (cell.accessoryView as! UIActivityIndicatorView).isHidden = true
            (cell.accessoryView as! UIActivityIndicatorView).stopAnimating()
            let balance = TLCurrencyFormat.getProperAmount(accountObject.getBalance())
            cell.accountBalanceButton!.setTitle(balance as String, for: UIControlState())
            cell.accountBalanceButton!.isHidden = false
        } else {
            (cell.accessoryView as! UIActivityIndicatorView).isHidden = false
            (cell.accessoryView as! UIActivityIndicatorView).startAnimating()
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
    
    fileprivate func setUpCellImportedAddresses(_ importedAddressObject: TLImportedAddress, cell: TLAccountTableViewCell, cellForRowAtIndexPath indexPath: IndexPath) {
        let label = importedAddressObject.getLabel()
        cell.accountNameLabel!.text = label
        
        if (importedAddressObject.hasFetchedAccountData()) {
            (cell.accessoryView as! UIActivityIndicatorView).isHidden = true
            (cell.accessoryView as! UIActivityIndicatorView).stopAnimating()
            let balance = TLCurrencyFormat.getProperAmount(importedAddressObject.getBalance()!)
            cell.accountBalanceButton!.setTitle(balance as String, for: UIControlState())
            cell.accountBalanceButton!.isHidden = false
        }
    }
    
    func _accountsTableViewReloadDataWrapper() {
        numberOfSections = 1
        
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
        }
        
        self.accountsTableView!.reloadData()}
    
    func accountsTableViewReloadDataWrapper(_ notification: Notification) {
        _accountsTableViewReloadDataWrapper()
    }
    
    fileprivate func doSelectFrom(_ sendFromType: TLSendFromType, sendFromIndex: NSInteger) {
        var viewControllersIdx = self.navigationController!.viewControllers.count - 2
        // make sure viewControllersIdx not negative
        if (self.navigationController!.viewControllers.count < 2) {
            viewControllersIdx = 0
        }
        
        self.navigationController!.popToViewController((self.navigationController!.viewControllers as NSArray).object(at: viewControllersIdx) as! UIViewController, animated: true)
        let selectedDict = ["sendFromType": sendFromType.rawValue, "sendFromIndex": sendFromIndex]
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_ACCOUNT_SELECTED()), object: selectedDict, userInfo: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
            } else {
            }
        } else {
            if (section == accountListSection) {
                return "Accounts".localized
            } else {
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (TLPreferences.enabledColdWallet() && section == coldWalletAccountSection) {
            return AppDelegate.instance().coldWalletAccounts!.getNumberOfAccounts()
        }
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let MyIdentifier = "AccountCellIdentifier"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) as! TLAccountTableViewCell?
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default,
                reuseIdentifier: MyIdentifier) as? TLAccountTableViewCell
        }
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        cell!.accessoryView = (activityView)
        
        cell!.accountBalanceButton!.titleLabel!.adjustsFontSizeToFitWidth = true
        if (TLPreferences.enabledColdWallet() && (indexPath as NSIndexPath).section == coldWalletAccountSection) {
            let accountObject = AppDelegate.instance().coldWalletAccounts!.getAccountObjectForIdx((indexPath as NSIndexPath).row)
            self.setUpCellAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
        }
        if (TLPreferences.enabledAdvancedMode()) {
            if ((indexPath as NSIndexPath).section == accountListSection) {
                let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx((indexPath as NSIndexPath).row)
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
            } else {
            }
        } else {
            if ((indexPath as NSIndexPath).section == accountListSection) {
                let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx((indexPath as NSIndexPath).row)
                self.setUpCellAccounts(accountObject, cell: cell!, cellForRowAtIndexPath: indexPath)
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
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (TLPreferences.enabledColdWallet() && (indexPath as NSIndexPath).section == coldWalletAccountSection) {
            self.doSelectFrom(.coldWalletAccount, sendFromIndex: (indexPath as NSIndexPath).row)
            return nil
        }
        if (TLPreferences.enabledAdvancedMode()) {
            if ((indexPath as NSIndexPath).section == accountListSection) {
                let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx((indexPath as NSIndexPath).row)
                if (accountObject.hasFetchedAccountData()) {
                    self.doSelectFrom(.hdWallet, sendFromIndex: (indexPath as NSIndexPath).row)
                }
                return nil
            } else if ((indexPath as NSIndexPath).section == importedAccountSection) {
                self.doSelectFrom(.importedAccount, sendFromIndex: (indexPath as NSIndexPath).row)
                return nil
            } else if ((indexPath as NSIndexPath).section == importedWatchAccountSection) {
                self.doSelectFrom(.importedWatchAccount, sendFromIndex: (indexPath as NSIndexPath).row)
                return nil
            } else if ((indexPath as NSIndexPath).section == importedAddressSection) {
                self.doSelectFrom(.importedAddress, sendFromIndex: (indexPath as NSIndexPath).row)
                return nil
            } else if ((indexPath as NSIndexPath).section == importedWatchAddressSection) {
                self.doSelectFrom(.importedWatchAddress, sendFromIndex: (indexPath as NSIndexPath).row)
                return nil
            } else {
            }
        } else {
            if ((indexPath as NSIndexPath).section == accountListSection) {
                let accountObject = AppDelegate.instance().accounts!.getAccountObjectForIdx((indexPath as NSIndexPath).row)
                
                if (accountObject.hasFetchedAccountData()) {
                    self.doSelectFrom(.hdWallet, sendFromIndex: (indexPath as NSIndexPath).row)
                }
            } else {
            }
        }
        
        return nil
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
