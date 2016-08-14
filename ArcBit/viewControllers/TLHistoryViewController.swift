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
    
    private let MAX_CONFIRMATIONS_TO_DISPLAY = 6
    private var accountRefreshControl: UIRefreshControl?
    private var managedObjectContext: NSManagedObjectContext?
    private var paymentInfos: NSMutableArray?
    private var transactions: NSMutableArray?
    @IBOutlet private var transactionsTableView: UITableView?
    @IBOutlet private var accountNameLabel: UILabel?
    @IBOutlet private var accountBalanceLabel: UILabel?
    @IBOutlet private var balanceActivityIndicatorView: UIActivityIndicatorView?
    @IBOutlet private var selectAccountImageView: UIImageView?
    @IBOutlet private var fromViewContainer: UIButton?
    @IBOutlet private var tableviewBackgroundView: UIView?
    @IBOutlet private var fromBackgroundView: UIView?
    @IBOutlet private var revealButtonItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        
        setLogoImageView()
        
        self.fromViewContainer!.backgroundColor = TLColors.mainAppColor()
        self.accountNameLabel!.textColor = TLColors.mainAppOppositeColor()
        self.accountBalanceLabel!.textColor = TLColors.mainAppOppositeColor()
        self.balanceActivityIndicatorView!.color = TLColors.mainAppOppositeColor()
        
        self.navigationController!.view.addGestureRecognizer(self.slidingViewController().panGesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self
            , selector: "updateViewToNewSelectedObject",
            name: TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED(), object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self
            , selector: "updateViewToNewSelectedObject",
            name: TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA(), object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            , selector: "updateViewToNewSelectedObject",
            name: TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_UNCONFIRMED_TRANSACTION(), object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self
            , selector: "updateViewToNewSelectedObject",
            name: TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED(), object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self
            , selector: "updateTransactionsTableView:",
            name: TLNotificationEvents.EVENT_PREFERENCES_BITCOIN_DISPLAY_CHANGED(), object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            , selector: "updateTransactionsTableView:",
            name: TLNotificationEvents.EVENT_PREFERENCES_FIAT_DISPLAY_CHANGED(), object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self
            , selector: "updateTransactionsTableView:",
            name: TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED(), object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self
            , selector: "updateTransactionsTableView:",
            name: TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_BLOCK(), object: nil)
        
        self.transactionsTableView!.delegate = self
        self.transactionsTableView!.dataSource = self
        self.transactionsTableView!.tableFooterView = UIView(frame: CGRectZero)
        self.transactionsTableView!.backgroundColor = self.fromBackgroundView!.backgroundColor
        
        self.tableviewBackgroundView!.layer.masksToBounds = false
        self.tableviewBackgroundView!.layer.shadowOpacity = 0.75
        self.tableviewBackgroundView!.layer.shadowRadius = 10.0
        self.tableviewBackgroundView!.layer.shadowColor = UIColor.blackColor().CGColor
        self.tableviewBackgroundView!.hidden = true // If I want the shadow, comment out this line
        
        accountRefreshControl = UIRefreshControl()
        accountRefreshControl!.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        self.transactionsTableView!.addSubview(accountRefreshControl!)
        
        self.updateViewToNewSelectedObject()
        
        self.refreshSelectedAccount(false)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        self.refreshSelectedAccount(true)
        accountRefreshControl!.endRefreshing()
    }
    
    private func refreshSelectedAccount(fetchDataAgain: Bool) {
        if (!AppDelegate.instance().historySelectedObject!.hasFetchedCurrentFromData() || fetchDataAgain) {
            if (AppDelegate.instance().historySelectedObject!.getSelectedObjectType() == .Account) {
                let accountObject = AppDelegate.instance().historySelectedObject!.getSelectedObject() as! TLAccountObject
                self.balanceActivityIndicatorView!.hidden = false
                self.accountBalanceLabel!.hidden = true
                self.balanceActivityIndicatorView!.startAnimating()
                AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: fetchDataAgain, success: {
                    self.accountBalanceLabel!.hidden = false
                    self.balanceActivityIndicatorView!.stopAnimating()
                    self.balanceActivityIndicatorView!.hidden = true
                    if accountObject.downloadState == .Downloaded {
                        self.updateAccountBalance()
                    }
                })
                
            } else if (AppDelegate.instance().historySelectedObject!.getSelectedObjectType() == .Address) {
                let importedAddress = AppDelegate.instance().historySelectedObject!.getSelectedObject() as! TLImportedAddress
                self.balanceActivityIndicatorView!.hidden = false
                self.accountBalanceLabel!.hidden = true
                AppDelegate.instance().pendingOperations.addSetUpImportedAddressOperation(importedAddress, fetchDataAgain: fetchDataAgain, success: {
                    self.accountBalanceLabel!.hidden = false
                    self.balanceActivityIndicatorView!.stopAnimating()
                    self.balanceActivityIndicatorView!.hidden = true
                    if importedAddress.downloadState != .Downloaded {
                        self.updateAccountBalance()
                    }
                })
            }
        } else {
            let balance = TLCurrencyFormat.getProperAmount(AppDelegate.instance().historySelectedObject!.getBalanceForSelectedObject()!)
            accountBalanceLabel!.text = balance as String
            self.balanceActivityIndicatorView!.hidden = true
        }
    }
    
    func updateViewToNewSelectedObject() {
        let label = AppDelegate.instance().historySelectedObject!.getLabelForSelectedObject()
        self.accountNameLabel!.text = label
        self.updateAccountBalance()
        self._updateTransactionsTableView()
    }
    
    func _updateTransactionsTableView() {
        self.transactionsTableView!.reloadData()
    }
    
    func updateTransactionsTableView(notification: NSNotification) {
        _updateTransactionsTableView()
    }
    
    override func viewWillAppear(animated: Bool) -> () {
        self.updateViewToNewSelectedObject()
    }
    
    override func viewDidAppear(animated: Bool) -> () {
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_HISTORY(),
            object: nil, userInfo: nil)
    }
    
    private func updateAccountBalance() {
        let balance = AppDelegate.instance().historySelectedObject!.getBalanceForSelectedObject()
        let balanceString = TLCurrencyFormat.getProperAmount(balance!)
    
        self.balanceActivityIndicatorView!.stopAnimating()
        self.balanceActivityIndicatorView!.hidden = true

        self.accountBalanceLabel!.text = balanceString as String
        self.accountBalanceLabel!.hidden = false
    }
    
    func onAccountSelected(note: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: TLNotificationEvents.EVENT_ACCOUNT_SELECTED(),
            object: nil)
        
        let selectedDict = note.object as! NSDictionary
        let sendFromType = TLSendFromType(rawValue: selectedDict.objectForKey("sendFromType") as! Int)
        let sendFromIndex = selectedDict.objectForKey("sendFromIndex") as! Int
        AppDelegate.instance().updateHistorySelectedObject(sendFromType!, sendFromIndex: sendFromIndex)
        self.updateViewToNewSelectedObject()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> () {
        if (segue.identifier == "selectAccount") {
            let vc = segue.destinationViewController 
            vc.navigationItem.title = "Select Account".localized
            
            NSNotificationCenter.defaultCenter().addObserver(self
                , selector: "onAccountSelected:",
                name: TLNotificationEvents.EVENT_ACCOUNT_SELECTED(), object: nil)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(AppDelegate.instance().historySelectedObject!.getTxObjectCount())
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let MyIdentifier = "TransactionCellIdentifier"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier) as! TLTransactionTableViewCell?
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default,
                reuseIdentifier: MyIdentifier) as? TLTransactionTableViewCell
        }
        
        cell!.amountButton!.titleEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)
        let txObject = AppDelegate.instance().historySelectedObject!.getTxObject(indexPath.row)
        DLog("txObject hash: %@", function: txObject!.getHash()!)
        cell!.dateLabel!.text = txObject!.getTime()
        
        let amount = TLCurrencyFormat.getProperAmount(AppDelegate.instance().historySelectedObject!.getAccountAmountChangeForTx(txObject!.getHash()! as String)!)
        let amountType = AppDelegate.instance().historySelectedObject!.getAccountAmountChangeTypeForTx(txObject!.getHash()! as String)
        var amountTypeString = ""
        let txTag = AppDelegate.instance().appWallet.getTransactionTag(txObject!.getHash()! as String)

        cell!.descriptionLabel!.adjustsFontSizeToFitWidth = true
        if (amountType == .Send) {
            amountTypeString = "-"
            cell!.amountButton!.backgroundColor = UIColor.redColor()
            if txTag == nil || txTag == "" {
                let outputAddressToValueArray = txObject!.getOutputAddressToValueArray()
                for _dict in outputAddressToValueArray! {
                    let dict = _dict as! NSDictionary
                    if let address = dict.objectForKey("addr") as? String {
                        if AppDelegate.instance().historySelectedObject!.isAddressPartOfAccount(address) {
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
        } else if (amountType == .Receive) {
            amountTypeString = "+"
            cell!.amountButton!.backgroundColor = UIColor.greenColor()
            if txTag == nil || txTag == "" {
                cell!.descriptionLabel!.text = ""
            } else {
                cell!.descriptionLabel!.text = txTag
            }

        } else {
            cell!.amountButton!.backgroundColor = UIColor.grayColor()
            if (txTag == nil) {
                cell!.descriptionLabel!.text = String(format: "Intra account transfer".localized)
            } else {
                cell!.descriptionLabel!.text = txTag
            }
        }
        cell!.amountButton!.setTitle(String(format: "%@%@", amountTypeString, amount), forState: .Normal)
        
        let confirmations = txObject!.getConfirmations()
        DLog("confirmations %ld", function: Int(confirmations))
        
        if (Int(confirmations) > MAX_CONFIRMATIONS_TO_DISPLAY) {
            cell!.confirmationsLabel!.text = String(format: "%llu confirmations".localized, txObject!.getConfirmations()) // label is hidden
            cell!.confirmationsLabel!.backgroundColor = UIColor.greenColor()
            cell!.confirmationsLabel!.hidden = true
        } else {
            if (confirmations == 0) {
                cell!.confirmationsLabel!.backgroundColor = UIColor.redColor()
            } else if (confirmations == 1) {
                cell!.confirmationsLabel!.backgroundColor = UIColor.orangeColor()
            } else if (confirmations <= 2 && confirmations <= 5) {
                //cell!.confirmationsLabel.backgroundColor = UIColor.yellowColor) //yellow color too light
                cell!.confirmationsLabel!.backgroundColor = UIColor.greenColor()
            } else {
                cell!.confirmationsLabel!.backgroundColor = UIColor.greenColor()
            }
            
            if (confirmations == 0) {
                cell!.confirmationsLabel!.text = String(format: "unconfirmed".localized)
            } else if (confirmations == 1) {
                cell!.confirmationsLabel!.text = String(format: "%llu confirmation".localized, txObject!.getConfirmations())
            } else {
                cell!.confirmationsLabel!.text = String(format: "%llu confirmations".localized, txObject!.getConfirmations())
            }
            cell!.confirmationsLabel!.hidden = false
        }
        
        if (indexPath.row % 2 == 0) {
            cell!.backgroundColor = TLColors.evenTableViewCellColor()
        } else {
            cell!.backgroundColor = TLColors.oddTableViewCellColor()
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let txObject = AppDelegate.instance().historySelectedObject!.getTxObject(indexPath.row)
        self.promptTransactionActionSheet(txObject!.getHash()!)
        return nil
    }
    
    private func promptTransactionActionSheet(txHash: NSString) {
        let otherButtonTitles = ["View in web".localized, "Label Transaction".localized, "Copy Transaction ID to Clipboard".localized]
        
        UIAlertController.showAlertInViewController(self,
            withTitle: String(format: "Transaction ID: %@".localized, txHash),
            message:"",
            preferredStyle: .ActionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: otherButtonTitles as [AnyObject],
            tapBlock: {(actionSheet, action, buttonIndex) in
                if (buttonIndex == actionSheet.firstOtherButtonIndex) {
                    TLBlockExplorerAPI.instance().openWebViewForTransaction(txHash as String)
                    NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_TRANSACTION_IN_WEB(),
                        object: nil, userInfo: nil)
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
                    TLPrompts.promtForInputText(self, title:"Edit Transaction tag".localized, message: "", textFieldPlaceholder: "tag".localized, success: {
                        (inputText: String!) in
                        if (inputText == "") {
                            AppDelegate.instance().appWallet.deleteTransactionTag(txHash as String)
                        } else {
                            AppDelegate.instance().appWallet.setTransactionTag(txHash as String, tag: inputText)
                            NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_TAG_TRANSACTION(),
                                object: nil, userInfo: nil)
                        }
                        self._updateTransactionsTableView()
                        }, failure: {
                            (isCancelled: Bool) in
                    })
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) {
                    let pasteboard = UIPasteboard.generalPasteboard()
                    pasteboard.string = txHash as String
                    iToast.makeText("Copied To clipboard".localized).setGravity(iToastGravityCenter).setDuration(1000).show()
                } else if (buttonIndex == actionSheet.cancelButtonIndex) {
                }
        })
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let moreAction = UITableViewRowAction(style: .Default, title: "More".localized, handler: {
            (action: UITableViewRowAction, indexPath: NSIndexPath) in
            tableView.editing = false
            let txObject = AppDelegate.instance().historySelectedObject!.getTxObject(indexPath.row)
            
            self.promptTransactionActionSheet(txObject!.getHash()!)
        })
        moreAction.backgroundColor = UIColor.lightGrayColor()
        
        return [moreAction]
    }
    
    @IBAction private func menuButtonClicked(sender: AnyObject) {
        self.slidingViewController().anchorTopViewToRightAnimated(true)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
