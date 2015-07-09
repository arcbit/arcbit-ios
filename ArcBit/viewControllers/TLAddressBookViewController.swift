//
//  TLAddressBookViewController.swift
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

@objc(TLAddressBookViewController) class TLAddressBookViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet private var navigationBar: UINavigationBar?
    @IBOutlet private var addressBookTableView: UITableView?
    private var addressBook: NSArray?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func preferredStatusBarStyle() -> (UIStatusBarStyle) {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarColors(self.navigationBar!)
        
        addressBook = TLWallet.instance().getAddressBook()
        
        self.addressBookTableView!.delegate = self
        self.addressBookTableView!.dataSource = self
        self.addressBookTableView!.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        // TODO: better way
        if AppDelegate.instance().scannedAddressBookAddress != nil {
            self.processAddressBookAddress(AppDelegate.instance().scannedAddressBookAddress!)
            AppDelegate.instance().scannedAddressBookAddress = nil
        }
    }
    
    private func promptAddToAddressBookActionSheet() -> () {
        UIAlertController.showAlertInViewController(self,
            withTitle: "Input address".localized,
            message:"",
            preferredStyle: .ActionSheet,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Add via QR Code".localized, "Add via Text Input".localized],
            
            tapBlock: {(actionSheet, action, buttonIndex) in
                if (buttonIndex == actionSheet.firstOtherButtonIndex) {
                    AppDelegate.instance().showAddressReaderControllerFromViewController(self, success: {
                        (data: String!) in
                        AppDelegate.instance().scannedAddressBookAddress = data
                        }, error: {
                            (data: String?) in
                    })
                } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
                    TLPrompts.promtForInputText(self, title: "Input address".localized, message: "", textFieldPlaceholder: "address".localized, success: {(inputText: String!) in
                        self.processAddressBookAddress(inputText)
                        }, failure: {
                            (isCanceled: Bool) in
                            
                    })
                } else if (buttonIndex == actionSheet.cancelButtonIndex) {
                }
                
        })
    }
    
    private func processAddressBookAddress(address: String) -> () {
        if (TLCoreBitcoinWrapper.isValidAddress(address, isTestnet: TLWalletUtils.STATIC_MEMBERS.IS_TESTNET)) {
            if (TLCoreBitcoinWrapper.isAddressVersion0(address)) {
                if (TLSuggestions.instance().enabledSuggestDontAddNormalAddressToAddressBook()) {
                    TLPrompts.promtForOKCancel(self, title: "Warning".localized, message: "It is not recommended that you use a regular bitcoin address for multiple payments, but instead you should import a forward address. Add address anyways?".localized, success: {
                        () in
                        self.promptForLabel(address)
                        TLSuggestions.instance().setEnableSuggestDontAddNormalAddressToAddressBook(false)
                        }, failure: {
                            (isCanceled: Bool) in
                    })
                } else {
                    self.promptForLabel(address)
                }
            } else {
                self.promptForLabel(address)
            }
        }
        else {
            TLPrompts.promptErrorMessage("Invalid Address".localized, message: "")
        }
    }
    
    private func promptForLabel(address: String) -> () {
        TLPrompts.promtForInputText(self, title: "Input label for address".localized, message: "", textFieldPlaceholder: "label".localized, success: {
            (inputText: String!) in
            TLWallet.instance().addAddressBookEntry(address, label: inputText)
            NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_ADD_TO_ADDRESS_BOOK(), object: nil, userInfo: nil)
            
            self.addressBookTableView!.reloadData()
            
            }, failure: {
                (isCanceled: Bool) in
                
        })
    }
    
    @IBAction private func addAddressBookEntryButtonClicked(sender: UIButton) -> () {
        self.promptAddToAddressBookActionSheet()
    }
    
    @IBAction private func cancelButtonClicked(sender: UIButton) -> () {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) -> () {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
        } else if (editingStyle == UITableViewCellEditingStyle.None) {
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> (Int) {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressBook!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let MyIdentifier = "AddressBookCellIdentifier"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier) as! UITableViewCell?
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
                reuseIdentifier: MyIdentifier)
        }
        
        cell!.textLabel!.text = (addressBook!.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey(TLWallet.WALLET_PAYLOAD_KEY_LABEL()) as? String
        cell!.detailTextLabel!.text = (addressBook!.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey(TLWallet.WALLET_PAYLOAD_KEY_ADDRESS()) as? String
        cell!.detailTextLabel!.numberOfLines = 0
        
        if (indexPath.row % 2 == 0) {
            cell!.backgroundColor = TLColors.evenTableViewCellColor()
        } else {
            cell!.backgroundColor = TLColors.oddTableViewCellColor()
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let cell = self.addressBookTableView!.cellForRowAtIndexPath(indexPath)
        self.dismissViewControllerAnimated(true, completion: nil)
        let address = cell!.detailTextLabel!.text
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_ADDRESS_SELECTED(), object: address, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_SEND_TO_ADDRESS_IN_ADDRESS_BOOK(), object: nil, userInfo: nil)
        
        return nil
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let moreAction = UITableViewRowAction(style:UITableViewRowActionStyle.Default, title: "Edit", handler: {
            (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
            tableView.editing = false
            
            TLPrompts.promtForInputText(self, title: "Edit address label".localized, message: "Input label for address".localized, textFieldPlaceholder: "address".localized, success: {
                (inputText: String!) in
                TLWallet.instance().editAddressBookEntry(indexPath.row, label: inputText)
                NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_EDIT_ENTRY_ADDRESS_BOOK(), object: nil, userInfo: nil)
                tableView.reloadData()
                }, failure: {
                    (isCancelled: Bool) in
            })
        })
        moreAction.backgroundColor = UIColor.lightGrayColor()
        
        let deleteAction = UITableViewRowAction(style:UITableViewRowActionStyle.Default, title: "Delete".localized, handler: {
            (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
            tableView.editing = false
            
            TLPrompts.promtForOKCancel(self, title: "Delete address".localized, message: "Are you sure you want to delete this address?".localized, success: {
                () in
                TLWallet.instance().deleteAddressBookEntry(indexPath.row)
                NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_DELETE_ENTRY_ADDRESS_BOOK(), object: nil, userInfo: nil)
                tableView.reloadData()
                }, failure: {
                    (isCancelled: Bool) in
                    
            })
        })
        
        return [deleteAction, moreAction]
    }
}

