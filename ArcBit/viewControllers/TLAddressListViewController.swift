//
//  TLAddressListViewController.swift
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

@objc(TLAddressListViewController) class TLAddressListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomIOS7AlertViewDelegate {
    
    var accountObject: TLAccountObject?
    private var QRImageModal: TLQRImageModal?
    var showBalances: Bool = false
    let TL_STRING_NO_STEALTH_PAYMENT_ADDRESSES_INFO = "Imported Watch Only Accounts can't see reusable address payments".localized
    let TL_STRING_NONE_CURRENTLY = "None currently".localized
    
    @IBOutlet private var addressListTableView: UITableView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "reloadAddressListTableView:",
            name: TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED(), object: nil)
        
        self.addressListTableView!.delegate = self
        self.addressListTableView!.dataSource = self
        self.addressListTableView!.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewDidAppear(animated: Bool) -> () {
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESSES(),
            object: nil, userInfo: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reloadAddressListTableView(notification: NSNotification) -> () {
        self.addressListTableView!.reloadData()
    }
    
    private func promptAddressActionSheet(address: String, addressType: TLAddressType,
        title: String,
        addressNtxs: Int) -> () {
            let otherButtonTitles:[String]
            if (TLPreferences.enabledAdvancedMode()) {
                otherButtonTitles = ["View in web".localized, "View address QR code".localized, "View private key QR code".localized]
            } else {
                otherButtonTitles = ["View in web".localized, "View address QR code".localized]
            }
            
            UIAlertController.showAlertInViewController(self,
                withTitle: title,
                message:"",
                preferredStyle: .ActionSheet,
                cancelButtonTitle: "Cancel".localized,
                destructiveButtonTitle: nil,
                otherButtonTitles: otherButtonTitles as [AnyObject],
                
                tapBlock: {(actionSheet, action, buttonIndex) in
                    
                    if (buttonIndex == actionSheet.firstOtherButtonIndex) {
                        TLBlockExplorerAPI.instance().openWebViewForAddress(address)
                        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESS_IN_WEB(),
                            object: nil, userInfo: nil)
                        
                    } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
                        if (TLSuggestions.instance().enabledSuggestDontManageIndividualAccountAddress()) {
                            TLPrompts.promtForOK(self, title:"Warning".localized, message: "Do not use the QR code from here to receive bitcoins. Go to the Receive screen to get a QR code to receive bitcoins.".localized, success: {
                                () in
                                self.showAddressQRCode(address)
                                TLSuggestions.instance().setEnableSuggestDontManageIndividualAccountAddress(false)
                            })
                        } else {
                            self.showAddressQRCode(address)
                        }
                    } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) {
                        if (TLSuggestions.instance().enabledSuggestDontManageIndividualAccountPrivateKeys()) {
                            TLPrompts.promtForOK(self,title:"Warning".localized, message: "It is not recommended that you manually manage an accounts' private key yourself. A leak of a private key can lead to the compromise of your accounts' bitcoins.".localized, success: {
                                () in
                                self.showPrivateKeyQRCode(address, addressType: addressType)
                                TLSuggestions.instance().setEnableSuggestDontManageIndividualAccountPrivateKeys(false)
                            })
                        } else {
                            self.showPrivateKeyQRCode(address, addressType: addressType)
                        }
                    } else if (buttonIndex == actionSheet.cancelButtonIndex) {
                    }
            })
    }
    
    private func showAddressQRCode(address: String) -> () {
        self.QRImageModal = TLQRImageModal(data: address, buttonCopyText: "Copy To Clipboard".localized, vc: self)
        self.QRImageModal!.show()
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESS(),
            object: nil, userInfo: nil)
    }
    
    private func showPrivateKeyQRCode(address: String, addressType: TLAddressType) -> () {
        if (self.accountObject!.isWatchOnly() && !self.accountObject!.hasSetExtendedPrivateKeyInMemory() &&
            (addressType == .Main || addressType == .Change)) {
                TLPrompts.promptForTempararyImportExtendedPrivateKey(self, success: {
                    (data: String!) -> () in
                    if (!TLHDWalletWrapper.isValidExtendedPrivateKey(data)) {
                        TLPrompts.promptErrorMessage("Error".localized, message: "Invalid account private key".localized)
                    } else {
                        let success = self.accountObject!.setExtendedPrivateKeyInMemory(data)
                        if (!success) {
                            TLPrompts.promptErrorMessage("Error".localized, message: "Account private key does not match imported account public key".localized)
                        } else {
                            self.showPrivateKeyQRCodeFinal(address, addressType: addressType)
                        }
                    }
                    }, error: {
                        (data: String?) in
                })
        } else {
            self.showPrivateKeyQRCodeFinal(address, addressType: addressType)
        }
    }
    
    private func showPrivateKeyQRCodeFinal(address: String, addressType: TLAddressType) {
        let privateKey:String
        if (addressType == .Stealth) {
            privateKey = self.accountObject!.stealthWallet!.getPaymentAddressPrivateKey(address)!
        } else if (addressType == .Main) {
            privateKey = self.accountObject!.getMainPrivateKey(address)
        } else {
            privateKey = self.accountObject!.getChangePrivateKey(address)
        }
        
        self.QRImageModal = TLQRImageModal(data: privateKey, buttonCopyText: "Copy To Clipboard".localized, vc: self)
        self.QRImageModal!.show()
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_ACCOUNT_PRIVATE_KEY(), object: nil, userInfo: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            //there are no archived stealth payment addresses, because old payment addresses are deleted
            return "Reusable Address Payment Addresses".localized
        } else if (section == 1) {
            return "Active Main Addresses".localized
        } else if (section == 2) {
            return "Archived Main Addresses".localized
        } else if (section == 3) {
            return "Active Change Addresses".localized
        } else {
            return "Archived Change Addresses".localized
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count:Int
        if (section == 0) {
            if self.accountObject!.getAccountType() != .ImportedWatch {
                count = self.accountObject!.stealthWallet!.getStealthAddressPaymentsCount()
            } else {
                count = 0
            }
        } else if (section == 1) {
            count = self.accountObject!.getMainActiveAddressesCount()
        } else if (section == 2) {
            count = self.accountObject!.getMainArchivedAddressesCount()
        } else if (section == 3) {
            count = self.accountObject!.getChangeActiveAddressesCount()
        } else {
            count = self.accountObject!.getChangeArchivedAddressesCount()
        }
        return count == 0 ? 1 : count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let MyIdentifier = "AddressCellIdentifier"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier) as! TLAddressTableViewCell?
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
                reuseIdentifier: MyIdentifier) as? TLAddressTableViewCell
        }
        
        
        if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 3) {
            cell!.textLabel!.hidden = true
            cell!.amountButton!.hidden = false
            cell!.addressLabel!.hidden = false
            cell!.addressLabel!.adjustsFontSizeToFitWidth = true
            
            var address = ""
            var balance = ""
            if (indexPath.section == 0) {
                if self.accountObject!.getAccountType() != .ImportedWatch {
                    if (self.accountObject!.stealthWallet!.getStealthAddressPaymentsCount() == 0) {
                        address = TL_STRING_NONE_CURRENTLY
                    } else {
                        let idx = self.accountObject!.stealthWallet!.getStealthAddressPaymentsCount() - 1 - indexPath.row
                        address = self.accountObject!.stealthWallet!.getPaymentAddressForIndex(idx)
                    }
                } else {
                    cell!.textLabel!.hidden = false
                    cell!.addressLabel!.hidden = true
                    cell!.textLabel!.numberOfLines = 0
                    cell!.textLabel!.text = TL_STRING_NO_STEALTH_PAYMENT_ADDRESSES_INFO
                    address = TL_STRING_NO_STEALTH_PAYMENT_ADDRESSES_INFO
                }
            } else if (indexPath.section == 1) {
                if (self.accountObject!.getMainActiveAddressesCount() == 0) {
                    address = TL_STRING_NONE_CURRENTLY
                } else {
                    let idx = self.accountObject!.getMainActiveAddressesCount() - 1 - indexPath.row
                    address = self.accountObject!.getMainActiveAddress(idx)
                }
            } else if (indexPath.section == 3) {
                if (self.accountObject!.getChangeActiveAddressesCount() == 0) {
                    address = TL_STRING_NONE_CURRENTLY
                } else {
                    let idx = self.accountObject!.getChangeActiveAddressesCount() - 1 - indexPath.row
                    address = self.accountObject!.getChangeActiveAddress(idx)
                }
            }
            
            cell!.addressLabel!.text = address
            if (self.showBalances && address != TL_STRING_NONE_CURRENTLY && address != TL_STRING_NO_STEALTH_PAYMENT_ADDRESSES_INFO &&
                (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 3)) {
                    // only show balances of active addresses
                    cell!.amountButton!.hidden = false
                    balance = TLCurrencyFormat.getProperAmount(self.accountObject!.getAddressBalance(address)) as String
                    cell!.amountButton!.setTitle(balance, forState: UIControlState.Normal)
            } else {
                cell!.amountButton!.hidden = true
            }            
        } else {
            cell!.textLabel!.hidden = false
            cell!.amountButton!.hidden = true
            cell!.addressLabel!.hidden = true
            cell!.textLabel!.adjustsFontSizeToFitWidth = true
            
            var address = ""
            if (indexPath.section == 2) {
                if (self.accountObject!.getMainArchivedAddressesCount() == 0) {
                    address = TL_STRING_NONE_CURRENTLY
                } else {
                    let idx = self.accountObject!.getMainArchivedAddressesCount() - 1 - indexPath.row
                    address = self.accountObject!.getMainArchivedAddress(idx)
                }
            } else if (indexPath.section == 4) {
                if (self.accountObject!.getChangeArchivedAddressesCount() == 0) {
                    address = TL_STRING_NONE_CURRENTLY
                } else {
                    let idx = self.accountObject!.getChangeArchivedAddressesCount() - 1 - indexPath.row
                    address = self.accountObject!.getChangeArchivedAddress(idx)
                }
            }
            
            cell!.textLabel!.text = address
        }
        
        if (indexPath.row % 2 == 0) {
            cell!.backgroundColor = TLColors.evenTableViewCellColor()
        } else {
            cell!.backgroundColor = TLColors.oddTableViewCellColor()
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        var address = ""
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TLAddressTableViewCell
        if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 3) {
            address = cell.addressLabel!.text!
        } else {
            address = cell.textLabel!.text!
        }
        
        if address == TL_STRING_NONE_CURRENTLY || address == TL_STRING_NO_STEALTH_PAYMENT_ADDRESSES_INFO {
            return nil
        }
        
        let addressType:TLAddressType
        let title:String
        if indexPath.section == 0 {
            addressType = .Stealth
            title = String(format: "Payment Index: %lu".localized, self.accountObject!.stealthWallet!.getStealthAddressPaymentsCount() - indexPath.row)
        } else if (indexPath.section == 1 || indexPath.section == 3) {
            addressType = .Main
            title = String(format: "Address ID: %lu".localized, self.accountObject!.getAddressHDIndex(address))
        } else {
            addressType = .Change
            title = String(format: "Address ID: %lu".localized, self.accountObject!.getAddressHDIndex(address))
        }
        
        var nTxs = 0
        if (indexPath.section == 1 || indexPath.section == 3) {
            nTxs = self.accountObject!.getNumberOfTransactionsForAddress(address)
        }
        
        promptAddressActionSheet(address, addressType: addressType, title: title,
            addressNtxs: nTxs)
        
        return nil
    }
    
    func customIOS7dialogButtonTouchUpInside(alertView: AnyObject, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == 0) {
            iToast.makeText("Copied To clipboard".localized).setGravity(iToastGravityCenter).setDuration(1000).show()
            
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = self.QRImageModal!.QRcodeDisplayData
        }
        
        alertView.close()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}