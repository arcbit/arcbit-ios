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

    @IBOutlet fileprivate var navigationBar: UINavigationBar?
    @IBOutlet fileprivate var addressBookTableView: UITableView?
    fileprivate var addressBook: NSArray?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var preferredStatusBarStyle : (UIStatusBarStyle) {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarColors(self.navigationBar!)
        self.navigationBar?.topItem?.title = TLDisplayStrings.CONTACTS_STRING()
        
        addressBook = AppDelegate.instance().getAddressBook(TLPreferences.getSendFromCoinType())
        
        self.addressBookTableView!.delegate = self
        self.addressBookTableView!.dataSource = self
        self.addressBookTableView!.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // TODO: better way
        if AppDelegate.instance().scannedAddressBookAddress != nil {
            self.processAddressBookAddress(AppDelegate.instance().scannedAddressBookAddress!)
            AppDelegate.instance().scannedAddressBookAddress = nil
        }
    }
    
    fileprivate func promptAddToAddressBookActionSheet() -> () {
        UIAlertController.showAlert(in: self,
            withTitle: TLDisplayStrings.CREATE_NEW_CONTACT_STRING(),
            message:"",
            preferredStyle: .actionSheet,
            cancelButtonTitle: TLDisplayStrings.CANCEL_STRING(),
            destructiveButtonTitle: nil,
            otherButtonTitles: [TLDisplayStrings.IMPORT_WITH_QR_CODE_STRING(), TLDisplayStrings.IMPORT_WITH_TEXT_INPUT_STRING()],
            
            tap: {(actionSheet, action, buttonIndex) in
                if (buttonIndex == actionSheet?.firstOtherButtonIndex) {
                    AppDelegate.instance().showAddressReaderControllerFromViewController(self, success: {
                        (data: String!) in
                        AppDelegate.instance().scannedAddressBookAddress = data
                        }, error: {
                            (data: String?) in
                    })
                } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)! + 1) {
                    TLPrompts.promtForInputText(self, title: TLDisplayStrings.INPUT_ADDRESS_STRING(), message: "", textFieldPlaceholder: TLDisplayStrings.ADDRESS_STRING(), success: {(inputText: String!) in
                        self.processAddressBookAddress(inputText)
                        }, failure: {
                            (isCanceled: Bool) in
                            
                    })
                } else if (buttonIndex == actionSheet?.cancelButtonIndex) {
                }
                
        })
    }
    
    fileprivate func processAddressBookAddress(_ address: String) -> () {
        if (TLCoreBitcoinWrapper.isValidAddress(address, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)) {
            if (TLCoreBitcoinWrapper.isAddressVersion0(address, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)) {
                if (TLWalletUtils.ENABLE_STEALTH_ADDRESS() && TLSuggestions.instance().enabledSuggestDontAddNormalAddressToAddressBook()) {
                    TLPrompts.promtForOKCancel(self, title: TLDisplayStrings.WARNING_STRING(), message: TLDisplayStrings.ADD_ADDRESS_TO_CONTACT_WARNING_DESC_STRING(), success: {
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
            TLPrompts.promptErrorMessage(TLDisplayStrings.INVALID_ADDRESS_STRING(), message: "")
        }
    }
    
    fileprivate func promptForLabel(_ address: String) -> () {
        TLPrompts.promtForInputText(self, title: TLDisplayStrings.EDIT_CONTACTS_ENTRY_STRING(), message: "", textFieldPlaceholder: TLDisplayStrings.LABEL_STRING(), success: {
            (inputText: String!) in
            AppDelegate.instance().addAddressBookEntry(TLPreferences.getSendFromCoinType(), address: address, label: inputText)
            NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_ADD_TO_ADDRESS_BOOK()), object: nil, userInfo: nil)
            
            self.addressBookTableView!.reloadData()
            
            }, failure: {
                (isCanceled: Bool) in
                
        })
    }
    
    @IBAction fileprivate func addAddressBookEntryButtonClicked(_ sender: UIButton) -> () {
        self.promptAddToAddressBookActionSheet()
    }
    
    @IBAction fileprivate func cancelButtonClicked(_ sender: UIButton) -> () {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) -> () {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
        } else if (editingStyle == UITableViewCellEditingStyle.none) {
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> (Int) {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressBook!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let MyIdentifier = "AddressBookCellIdentifier"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) 
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle,
                reuseIdentifier: MyIdentifier)
        }
        
        cell!.textLabel!.text = (addressBook!.object(at: (indexPath as NSIndexPath).row) as! NSDictionary).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_LABEL) as? String
        cell!.detailTextLabel!.text = (addressBook!.object(at: (indexPath as NSIndexPath).row) as! NSDictionary).object(forKey: TLWalletJSONKeys.STATIC_MEMBERS.WALLET_PAYLOAD_KEY_ADDRESS) as? String
        cell!.detailTextLabel!.numberOfLines = 0
        
        if ((indexPath as NSIndexPath).row % 2 == 0) {
            cell!.backgroundColor = TLColors.evenTableViewCellColor()
        } else {
            cell!.backgroundColor = TLColors.oddTableViewCellColor()
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = self.addressBookTableView!.cellForRow(at: indexPath)
        self.dismiss(animated: true, completion: nil)
        let address = cell!.detailTextLabel!.text
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_ADDRESS_SELECTED()), object: address, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_SEND_TO_ADDRESS_IN_ADDRESS_BOOK()), object: nil, userInfo: nil)
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let moreAction = UITableViewRowAction(style:UITableViewRowActionStyle.default, title: TLDisplayStrings.EDIT_STRING(), handler: {
            (action: UITableViewRowAction, indexPath: IndexPath) in
            tableView.isEditing = false
            
            TLPrompts.promtForInputText(self, title: TLDisplayStrings.EDIT_CONTACTS_ENTRY_STRING(), message: "", textFieldPlaceholder: TLDisplayStrings.ADDRESS_STRING(), success: {
                (inputText: String!) in
                AppDelegate.instance().editAddressBookEntry(TLPreferences.getSendFromCoinType(), idx: (indexPath as NSIndexPath).row, label: inputText)
                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_EDIT_ENTRY_ADDRESS_BOOK()), object: nil, userInfo: nil)
                tableView.reloadData()
                }, failure: {
                    (isCancelled: Bool) in
            })
        })
        moreAction.backgroundColor = UIColor.lightGray
        
        let deleteAction = UITableViewRowAction(style:UITableViewRowActionStyle.default, title: TLDisplayStrings.DELETE_STRING(), handler: {
            (action: UITableViewRowAction, indexPath: IndexPath) in
            tableView.isEditing = false
            
            TLPrompts.promtForOKCancel(self, title: TLDisplayStrings.DELETE_ADDRESS_STRING(), message: TLDisplayStrings.ARE_YOU_SURE_YOU_WANT_TO_DELETE_THIS_ACCOUNT_STRING(), success: {
                () in
                AppDelegate.instance().deleteAddressBookEntry(TLPreferences.getSendFromCoinType(), idx: (indexPath as NSIndexPath).row)
                NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_DELETE_ENTRY_ADDRESS_BOOK()), object: nil, userInfo: nil)
                tableView.reloadData()
                }, failure: {
                    (isCancelled: Bool) in
                    
            })
        })
        
        return [deleteAction, moreAction]
    }
}

