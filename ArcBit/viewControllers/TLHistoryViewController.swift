//
//  TLHistoryViewController.swift
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
import CoreData

@objc(TLHistoryViewController) class TLHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate let MAX_CONFIRMATIONS_TO_DISPLAY = 6
    fileprivate var accountRefreshControl: UIRefreshControl?
    fileprivate var managedObjectContext: NSManagedObjectContext?
    fileprivate var paymentInfos: NSMutableArray?
    fileprivate var transactions: NSMutableArray?
    @IBOutlet fileprivate var transactionsTableView: UITableView?
    @IBOutlet fileprivate var accountNameLabel: UILabel?
    @IBOutlet fileprivate var accountBalanceLabel: UILabel?
    @IBOutlet fileprivate var balanceActivityIndicatorView: UIActivityIndicatorView?
    @IBOutlet fileprivate var selectAccountImageView: UIImageView?
    @IBOutlet fileprivate var fromViewContainer: UIButton?
    @IBOutlet fileprivate var tableviewBackgroundView: UIView?
    @IBOutlet fileprivate var fromBackgroundView: UIView?
    @IBOutlet fileprivate var revealButtonItem: UIBarButtonItem?
    @IBOutlet weak var fromLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        
        setLogoImageView()
       self.fromLabel.text = TLDisplayStrings.FROM_COLON_STRING()
        self.fromViewContainer!.backgroundColor = TLColors.mainAppColor()
        self.accountNameLabel!.textColor = TLColors.mainAppOppositeColor()
        self.accountBalanceLabel!.textColor = TLColors.mainAppOppositeColor()
        self.balanceActivityIndicatorView!.color = TLColors.mainAppOppositeColor()
        self.updateViewForEnabledCryptoCoinsIfChanged()

        self.navigationController!.view.addGestureRecognizer(self.slidingViewController().panGesture)
        
        NotificationCenter.default.addObserver(self
            , selector: #selector(TLHistoryViewController.updateViewToNewSelectedObject),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED()), object: nil)
        
        NotificationCenter.default.addObserver(self
            , selector: #selector(TLHistoryViewController.updateViewToNewSelectedObject),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA()), object: nil)
        NotificationCenter.default.addObserver(self
            , selector: #selector(TLHistoryViewController.updateViewToNewSelectedObject),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_UNCONFIRMED_TRANSACTION()), object: nil)
        
        NotificationCenter.default.addObserver(self
            , selector: #selector(TLHistoryViewController.updateViewToNewSelectedObject),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED()), object: nil)
        
        NotificationCenter.default.addObserver(self
            , selector: #selector(TLHistoryViewController.updateTransactionsTableView(_:)),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_PREFERENCES_COIN_UNIT_DISPLAY_CHANGED()), object: nil)
        NotificationCenter.default.addObserver(self
            , selector: #selector(TLHistoryViewController.updateTransactionsTableView(_:)),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_PREFERENCES_FIAT_DISPLAY_CHANGED()), object: nil)
        NotificationCenter.default.addObserver(self
            , selector: #selector(TLHistoryViewController.updateTransactionsTableView(_:)),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED()), object: nil)
        
        NotificationCenter.default.addObserver(self
            , selector: #selector(TLHistoryViewController.updateTransactionsTableView(_:)),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_BLOCK()), object: nil)
        
        NotificationCenter.default.addObserver(self
            , selector: #selector(TLHistoryViewController.updateTransactionsTableView(_:)),
              name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_EXCHANGE_RATE_UPDATED()), object: nil)

        self.transactionsTableView!.delegate = self
        self.transactionsTableView!.dataSource = self
        self.transactionsTableView!.tableFooterView = UIView(frame: CGRect.zero)
        self.transactionsTableView!.backgroundColor = self.fromBackgroundView!.backgroundColor
        
        self.tableviewBackgroundView!.layer.masksToBounds = false
        self.tableviewBackgroundView!.layer.shadowOpacity = 0.75
        self.tableviewBackgroundView!.layer.shadowRadius = 10.0
        self.tableviewBackgroundView!.layer.shadowColor = UIColor.black.cgColor
        self.tableviewBackgroundView!.isHidden = true // If I want the shadow, comment out this line
        
        accountRefreshControl = UIRefreshControl()
        accountRefreshControl!.addTarget(self, action: #selector(TLHistoryViewController.refresh(_:)), for: .valueChanged)
        self.transactionsTableView!.addSubview(accountRefreshControl!)
        
        self.updateViewToNewSelectedObject()
        
        self.refreshSelectedAccount(false)
    }
    
    func updateViewToNoneSelectedObject() {
        self.accountNameLabel!.text = ""
        self.accountBalanceLabel!.text = ""
        self.balanceActivityIndicatorView!.isHidden = true
        self._updateTransactionsTableView()
    }
    
    func refresh(_ refreshControl: UIRefreshControl) {
        self.refreshSelectedAccount(true)
        accountRefreshControl!.endRefreshing()
    }
    
    fileprivate func refreshSelectedAccount(_ fetchDataAgain: Bool) {
        guard let historySelectedObject = AppDelegate.instance().coinWalletsManager!.historySelectedObject else {
            self.updateViewToNoneSelectedObject()
            return
        }
        if !historySelectedObject.hasFetchedCurrentFromData() || fetchDataAgain {
            if historySelectedObject.getSelectedObjectType() == .account {
                let accountObject = historySelectedObject.getSelectedObject() as! TLAccountObject
                self.balanceActivityIndicatorView!.isHidden = false
                self.accountBalanceLabel!.isHidden = true
                self.balanceActivityIndicatorView!.startAnimating()
                AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: fetchDataAgain, success: {
                    self.accountBalanceLabel!.isHidden = false
                    self.balanceActivityIndicatorView!.stopAnimating()
                    self.balanceActivityIndicatorView!.isHidden = true
                    if accountObject.downloadState == .downloaded {
                        self.updateAccountBalance()
                    }
                })
                
            } else if historySelectedObject.getSelectedObjectType() == .address {
                let importedAddress = historySelectedObject.getSelectedObject() as! TLImportedAddress
                self.balanceActivityIndicatorView!.isHidden = false
                self.accountBalanceLabel!.isHidden = true
                AppDelegate.instance().pendingOperations.addSetUpImportedAddressOperation(importedAddress, fetchDataAgain: fetchDataAgain, success: {
                    self.accountBalanceLabel!.isHidden = false
                    self.balanceActivityIndicatorView!.stopAnimating()
                    self.balanceActivityIndicatorView!.isHidden = true
                    if importedAddress.downloadState != .downloaded {
                        self.updateAccountBalance()
                    }
                })
            }
        } else {
            let balance = TLCurrencyFormat.getProperAmount(historySelectedObject.getBalanceForSelectedObject()!, coinType: historySelectedObject.getSelectedObjectCoinType())
            accountBalanceLabel!.text = balance as String
            self.balanceActivityIndicatorView!.isHidden = true
        }
    }
    
    func updateViewToNewSelectedObject() {
        guard let historySelectedObject = AppDelegate.instance().coinWalletsManager!.historySelectedObject else {
            self.updateViewToNoneSelectedObject()
            return
        }
        let label = historySelectedObject.getLabelForSelectedObject()
        self.accountNameLabel!.text = label
        self.updateAccountBalance()
        self._updateTransactionsTableView()
    }
    
    func _updateTransactionsTableView() {
        self.transactionsTableView!.reloadData()
    }
    
    func updateTransactionsTableView(_ notification: Notification) {
        _updateTransactionsTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) -> () {
        self.updateViewToNewSelectedObject()
    }
    
    override func viewDidAppear(_ animated: Bool) -> () {
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_HISTORY()),
            object: nil, userInfo: nil)
    }
    
    fileprivate func updateAccountBalance() {
        guard let historySelectedObject = AppDelegate.instance().coinWalletsManager!.historySelectedObject else {
            self.updateViewToNoneSelectedObject()
            return
        }
        let balance = historySelectedObject.getBalanceForSelectedObject()
        let balanceString = TLCurrencyFormat.getProperAmount(balance!, coinType: historySelectedObject.getSelectedObjectCoinType())
    
        self.balanceActivityIndicatorView!.stopAnimating()
        self.balanceActivityIndicatorView!.isHidden = true

        self.accountBalanceLabel!.text = balanceString as String
        self.accountBalanceLabel!.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) -> () {
        if (segue.identifier == "selectAccount") {
            if let vc = segue.destination as? TLAccountsViewController {
                vc.navigationItem.title = TLDisplayStrings.SELECT_ACCOUNT_STRING()
                vc.currentCoinType = AppDelegate.instance().coinWalletsManager!.getHistorySelectedCoinType()
                vc.delegate = self
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let historySelectedObject = AppDelegate.instance().coinWalletsManager!.historySelectedObject else {
            return 0
        }
        return historySelectedObject.getTxObjectCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let MyIdentifier = "TransactionCellIdentifier"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) as! TLTransactionTableViewCell?
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default,
                reuseIdentifier: MyIdentifier) as? TLTransactionTableViewCell
        }
        
        cell!.amountButton!.titleEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)
        guard let historySelectedObject = AppDelegate.instance().coinWalletsManager!.historySelectedObject else {
            return cell!
        }
        let txObject = historySelectedObject.getTxObject((indexPath as NSIndexPath).row)
        DLog("txObject hash: \(txObject!.getHash())")
        cell!.dateLabel!.text = txObject!.getTime()
        
        let historyObjectCurrentCoinType = historySelectedObject.getSelectedObjectCoinType()
        let amount = TLCurrencyFormat.getProperAmount(historySelectedObject.getAccountAmountChangeForTx(txObject!.getHash() as String)!, coinType: historyObjectCurrentCoinType)
        let amountType = historySelectedObject.getAccountAmountChangeTypeForTx(txObject!.getHash())
        var amountTypeString = ""
        let txTag = AppDelegate.instance().coinWalletsManager!.getTransactionTag(historyObjectCurrentCoinType, txObject: txObject!)

        cell!.descriptionLabel!.adjustsFontSizeToFitWidth = true
        if (amountType == .send) {
            amountTypeString = "-"
            cell!.amountButton!.backgroundColor = UIColor.red
            if txTag == nil || txTag == "" {
                let outputAddressToValueArray = txObject!.getOutputAddressToValueArray()
                for txOutputObject in outputAddressToValueArray {
                    if let address = txOutputObject.addr {
                        if historySelectedObject.isAddressPartOfAccount(address) {
                            cell!.descriptionLabel!.text = address
                        } else {
                            cell!.descriptionLabel!.text = address
                            break
                        }
                    } else {
                        cell!.descriptionLabel!.text = ""
                    }
                }
            } else {
                cell!.descriptionLabel!.text = txTag
            }
        } else if (amountType == .receive) {
            amountTypeString = "+"
            cell!.amountButton!.backgroundColor = UIColor.green
            if txTag == nil || txTag == "" {
                cell!.descriptionLabel!.text = ""
            } else {
                cell!.descriptionLabel!.text = txTag
            }

        } else {
            cell!.amountButton!.backgroundColor = UIColor.gray
            if (txTag == nil) {
                cell!.descriptionLabel!.text = String(format: TLDisplayStrings.INTERNAL_ACCOUNT_TRANSFER_STRING())
            } else {
                cell!.descriptionLabel!.text = txTag
            }
        }
        cell!.amountButton!.setTitle(String(format: "%@%@", amountTypeString, amount), for: UIControlState())
        
        let confirmations = txObject!.getConfirmations()
        DLog("confirmations \(Int(confirmations))")
        
        if (Int(confirmations) > MAX_CONFIRMATIONS_TO_DISPLAY) {
            cell!.confirmationsLabel!.text = String(format: TLDisplayStrings.X_CONFIRMATIONS_STRING(), txObject!.getConfirmations()) // label is hidden
            cell!.confirmationsLabel!.backgroundColor = UIColor.green
            cell!.confirmationsLabel!.isHidden = true
        } else {
            if (confirmations == 0) {
                cell!.confirmationsLabel!.backgroundColor = UIColor.red
            } else if (confirmations == 1) {
                cell!.confirmationsLabel!.backgroundColor = UIColor.orange
            } else if (confirmations <= 2 && confirmations <= 5) {
                //cell!.confirmationsLabel.backgroundColor = UIColor.yellowColor) //yellow color too light
                cell!.confirmationsLabel!.backgroundColor = UIColor.green
            } else {
                cell!.confirmationsLabel!.backgroundColor = UIColor.green
            }
            
            if (confirmations == 0) {
                cell!.confirmationsLabel!.text = String(format: TLDisplayStrings.UNCONFIRMED_STRING())
            } else if (confirmations == 1) {
                cell!.confirmationsLabel!.text = String(format: TLDisplayStrings.ONE_CONFIRMATION_STRING())
            } else {
                cell!.confirmationsLabel!.text = String(format: TLDisplayStrings.X_CONFIRMATIONS_STRING(), txObject!.getConfirmations())
            }
            cell!.confirmationsLabel!.isHidden = false
        }
        
        if ((indexPath as NSIndexPath).row % 2 == 0) {
            cell!.backgroundColor = TLColors.evenTableViewCellColor()
        } else {
            cell!.backgroundColor = TLColors.oddTableViewCellColor()
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let historySelectedObject = AppDelegate.instance().coinWalletsManager!.historySelectedObject else {
            return nil
        }
        let txObject = historySelectedObject.getTxObject((indexPath as NSIndexPath).row)
        self.promptTransactionActionSheet(txObject!)
        return nil
    }
    
    fileprivate func promptTransactionActionSheet(_ txObject: TLTxObject) {
        let otherButtonTitles = [TLDisplayStrings.VIEW_IN_WEB_STRING(), TLDisplayStrings.LABEL_TRANSACTION_STRING(), TLDisplayStrings.COPY_TRANSACTION_ID_TO_CLIPBOARD_STRING()]
        
        UIAlertController.showAlert(in: self,
            withTitle: String(format: TLDisplayStrings.TRANSACTION_ID_COLON_X_STRING(), txObject.getHash()),
            message:"",
            preferredStyle: .actionSheet,
            cancelButtonTitle: TLDisplayStrings.CANCEL_STRING(),
            destructiveButtonTitle: nil,
            otherButtonTitles: otherButtonTitles as [AnyObject],
            tap: {(actionSheet, action, buttonIndex) in
                guard let historySelectedObject = AppDelegate.instance().coinWalletsManager!.historySelectedObject else {
                    return
                }
                let historyObjectCurrentCoinType = historySelectedObject.getSelectedObjectCoinType()
                if (buttonIndex == actionSheet?.firstOtherButtonIndex) {
                    TLBlockExplorerAPI.instance().openWebViewForTransaction(historyObjectCurrentCoinType, txid: txObject.getHash())
                    NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_TRANSACTION_IN_WEB()),
                        object: nil, userInfo: nil)
                } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)! + 1) {
                    TLPrompts.promtForInputText(self, title:TLDisplayStrings.EDIT_TRANSACTION_LABEL_STRING(), message: "", textFieldPlaceholder: TLDisplayStrings.LABEL_STRING(), success: {
                        (inputText: String!) in
                        if (inputText == "") {
                            AppDelegate.instance().coinWalletsManager!.deleteTransactionTag(historyObjectCurrentCoinType, txObject: txObject)
                        } else {
                            AppDelegate.instance().coinWalletsManager!.setTransactionTag(historyObjectCurrentCoinType, txid: txObject.getHash(), tag: inputText)
                            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_TAG_TRANSACTION()),
                                object: nil, userInfo: nil)
                        }
                        self._updateTransactionsTableView()
                        }, failure: {
                            (isCancelled: Bool) in
                    })
                } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)! + 2) {
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = txObject.getHash()
                    iToast.makeText(TLDisplayStrings.COPIED_TO_CLIPBOARD_STRING()).setGravity(iToastGravityCenter).setDuration(1000).show()
                } else if (buttonIndex == actionSheet?.cancelButtonIndex) {
                }
        })
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let moreAction = UITableViewRowAction(style: .default, title: TLDisplayStrings.MORE_STRING(), handler: {
            (action: UITableViewRowAction, indexPath: IndexPath) in
            tableView.isEditing = false
            guard let historySelectedObject = AppDelegate.instance().coinWalletsManager!.historySelectedObject else {
                return
            }
            let txObject = historySelectedObject.getTxObject((indexPath as NSIndexPath).row)
            
            self.promptTransactionActionSheet(txObject!)
        })
        moreAction.backgroundColor = UIColor.lightGray
        
        return [moreAction]
    }
    
    @IBAction fileprivate func menuButtonClicked(_ sender: AnyObject) {
        self.slidingViewController().anchorTopViewToRight(animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TLHistoryViewController {
    func updateViewForEnabledCryptoCoinsIfChanged() {
        guard let historySelectedObject = AppDelegate.instance().coinWalletsManager!.historySelectedObject else {
            self.updateViewToNoneSelectedObject()
            return
        }
        let historyObjectCurrentCoinType = historySelectedObject.getSelectedObjectCoinType()
        if !TLPreferences.isCryptoCoinEnabled(historyObjectCurrentCoinType) {
            AppDelegate.instance().coinWalletsManager!.updateSelectedObjectsToEnabledCoin(TLSelectAccountObjectType.history)
            self.updateViewToNewSelectedObject()
        }
    }
}

extension TLHistoryViewController : TLAccountsViewControllerDelegate {
    func didSelectAccount(_ coinType: TLCoinType, sendFromType: TLSendFromType, sendFromIndex: NSInteger) {
        AppDelegate.instance().coinWalletsManager!.updateHistorySelectedObject(coinType, sendFromType: sendFromType, sendFromIndex: Int(sendFromIndex))
        self.updateViewToNewSelectedObject()
    }
}
