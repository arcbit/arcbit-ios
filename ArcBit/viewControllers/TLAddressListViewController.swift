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
    fileprivate var QRImageModal: TLQRImageModal?
    var showBalances: Bool = false
    let TL_STRING_NO_STEALTH_PAYMENT_ADDRESSES_INFO = "This account type can't see reusable address payments".localized
    let TL_STRING_NONE_CURRENTLY = "None currently".localized
    
    @IBOutlet fileprivate var addressListTableView: UITableView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(TLAddressListViewController.reloadAddressListTableView(_:)),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED()), object: nil)
        
        self.addressListTableView!.delegate = self
        self.addressListTableView!.dataSource = self
        self.addressListTableView!.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewDidAppear(_ animated: Bool) -> () {
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESSES()),
            object: nil, userInfo: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reloadAddressListTableView(_ notification: Notification) -> () {
        self.addressListTableView!.reloadData()
    }
    
    fileprivate func promptAddressActionSheet(_ address: String, addressType: TLAddressType,
        title: String,
        addressNtxs: Int) -> () {
            let otherButtonTitles:[String]
            if (TLPreferences.enabledAdvancedMode()) {
                otherButtonTitles = ["View in web".localized, "View address QR code".localized, "View private key QR code".localized]
            } else {
                otherButtonTitles = ["View in web".localized, "View address QR code".localized]
            }
            
            UIAlertController.showAlert(in: self,
                withTitle: title,
                message:"",
                preferredStyle: .actionSheet,
                cancelButtonTitle: "Cancel".localized,
                destructiveButtonTitle: nil,
                otherButtonTitles: otherButtonTitles as [AnyObject],
                
                tap: {(actionSheet, action, buttonIndex) in
                    
                    if (buttonIndex == actionSheet?.firstOtherButtonIndex) {
                        TLBlockExplorerAPI.instance().openWebViewForAddress(address)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESS_IN_WEB()),
                            object: nil, userInfo: nil)
                        
                    } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)! + 1) {
                        if (TLSuggestions.instance().enabledSuggestDontManageIndividualAccountAddress()) {
                            TLPrompts.promtForOK(self, title:"Warning".localized, message: "Do not use the QR code from here to receive bitcoins. Go to the Receive screen to get a QR code to receive bitcoins.".localized, success: {
                                () in
                                self.showAddressQRCode(address)
                                TLSuggestions.instance().setEnableSuggestDontManageIndividualAccountAddress(false)
                            })
                        } else {
                            self.showAddressQRCode(address)
                        }
                    } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)! + 2) {
                        if (TLSuggestions.instance().enabledSuggestDontManageIndividualAccountPrivateKeys()) {
                            TLPrompts.promtForOK(self,title:"Warning".localized, message: "It is not recommended that you manually manage an accounts' private key yourself. A leak of a private key can lead to the compromise of your accounts' bitcoins.".localized, success: {
                                () in
                                self.showPrivateKeyQRCode(address, addressType: addressType)
                                TLSuggestions.instance().setEnableSuggestDontManageIndividualAccountPrivateKeys(false)
                            })
                        } else {
                            self.showPrivateKeyQRCode(address, addressType: addressType)
                        }
                    } else if (buttonIndex == actionSheet?.cancelButtonIndex) {
                    }
            })
    }
    
    fileprivate func showAddressQRCode(_ address: String) -> () {
        self.QRImageModal = TLQRImageModal(data: address as NSString, buttonCopyText: "Copy To Clipboard".localized, vc: self)
        self.QRImageModal!.show()
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESS()),
            object: nil, userInfo: nil)
    }
    
    fileprivate func showPrivateKeyQRCode(_ address: String, addressType: TLAddressType) -> () {
        if (self.accountObject!.isWatchOnly() && !self.accountObject!.hasSetExtendedPrivateKeyInMemory() &&
            (addressType == .main || addressType == .change)) {
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
        } else if self.accountObject!.isColdWalletAccount() {
            TLPrompts.promptErrorMessage("".localized, message: "Cold wallet private keys are not stored here and cannot be viewed".localized)
        } else {
            self.showPrivateKeyQRCodeFinal(address, addressType: addressType)
        }
    }
    
    fileprivate func showPrivateKeyQRCodeFinal(_ address: String, addressType: TLAddressType) {
        let privateKey:String
        if (addressType == .stealth) {
            privateKey = self.accountObject!.stealthWallet!.getPaymentAddressPrivateKey(address)!
        } else if (addressType == .main) {
            privateKey = self.accountObject!.getMainPrivateKey(address)
        } else {
            privateKey = self.accountObject!.getChangePrivateKey(address)
        }
        
        self.QRImageModal = TLQRImageModal(data: privateKey as NSString, buttonCopyText: "Copy To Clipboard".localized, vc: self)
        self.QRImageModal!.show()
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_ACCOUNT_PRIVATE_KEY()), object: nil, userInfo: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count:Int
        if (section == 0) {
            if self.accountObject!.getAccountType() != .importedWatch && self.accountObject!.getAccountType() != .coldWallet {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let MyIdentifier = "AddressCellIdentifier"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) as! TLAddressTableViewCell?
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle,
                reuseIdentifier: MyIdentifier) as? TLAddressTableViewCell
        }
        
        
        if ((indexPath as NSIndexPath).section == 0 || (indexPath as NSIndexPath).section == 1 || (indexPath as NSIndexPath).section == 3) {
            cell!.textLabel!.isHidden = true
            cell!.amountButton!.isHidden = false
            cell!.addressLabel!.isHidden = false
            cell!.addressLabel!.adjustsFontSizeToFitWidth = true
            
            var address = ""
            var balance = ""
            if ((indexPath as NSIndexPath).section == 0) {
                if self.accountObject!.getAccountType() != .importedWatch {
                    if (self.accountObject!.stealthWallet!.getStealthAddressPaymentsCount() == 0) {
                        address = TL_STRING_NONE_CURRENTLY
                    } else {
                        let idx = self.accountObject!.stealthWallet!.getStealthAddressPaymentsCount() - 1 - (indexPath as NSIndexPath).row
                        address = self.accountObject!.stealthWallet!.getPaymentAddressForIndex(idx)
                    }
                } else {
                    cell!.textLabel!.isHidden = false
                    cell!.addressLabel!.isHidden = true
                    cell!.textLabel!.numberOfLines = 0
                    cell!.textLabel!.text = TL_STRING_NO_STEALTH_PAYMENT_ADDRESSES_INFO
                    address = TL_STRING_NO_STEALTH_PAYMENT_ADDRESSES_INFO
                }
            } else if ((indexPath as NSIndexPath).section == 1) {
                if (self.accountObject!.getMainActiveAddressesCount() == 0) {
                    address = TL_STRING_NONE_CURRENTLY
                } else {
                    let idx = self.accountObject!.getMainActiveAddressesCount() - 1 - (indexPath as NSIndexPath).row
                    address = self.accountObject!.getMainActiveAddress(idx)
                }
            } else if ((indexPath as NSIndexPath).section == 3) {
                if (self.accountObject!.getChangeActiveAddressesCount() == 0) {
                    address = TL_STRING_NONE_CURRENTLY
                } else {
                    let idx = self.accountObject!.getChangeActiveAddressesCount() - 1 - (indexPath as NSIndexPath).row
                    address = self.accountObject!.getChangeActiveAddress(idx)
                }
            }
            
            cell!.addressLabel!.text = address
            if (self.showBalances && address != TL_STRING_NONE_CURRENTLY && address != TL_STRING_NO_STEALTH_PAYMENT_ADDRESSES_INFO &&
                ((indexPath as NSIndexPath).section == 0 || (indexPath as NSIndexPath).section == 1 || (indexPath as NSIndexPath).section == 3)) {
                    // only show balances of active addresses
                    cell!.amountButton!.isHidden = false
                    balance = TLCurrencyFormat.getProperAmount(self.accountObject!.getAddressBalance(address)) as String
                    cell!.amountButton!.setTitle(balance, for: UIControlState())
            } else {
                cell!.amountButton!.isHidden = true
            }            
        } else {
            cell!.textLabel!.isHidden = false
            cell!.amountButton!.isHidden = true
            cell!.addressLabel!.isHidden = true
            cell!.textLabel!.adjustsFontSizeToFitWidth = true
            
            var address = ""
            if ((indexPath as NSIndexPath).section == 2) {
                if (self.accountObject!.getMainArchivedAddressesCount() == 0) {
                    address = TL_STRING_NONE_CURRENTLY
                } else {
                    let idx = self.accountObject!.getMainArchivedAddressesCount() - 1 - (indexPath as NSIndexPath).row
                    address = self.accountObject!.getMainArchivedAddress(idx)
                }
            } else if ((indexPath as NSIndexPath).section == 4) {
                if (self.accountObject!.getChangeArchivedAddressesCount() == 0) {
                    address = TL_STRING_NONE_CURRENTLY
                } else {
                    let idx = self.accountObject!.getChangeArchivedAddressesCount() - 1 - (indexPath as NSIndexPath).row
                    address = self.accountObject!.getChangeArchivedAddress(idx)
                }
            }
            
            cell!.textLabel!.text = address
        }
        
        if ((indexPath as NSIndexPath).row % 2 == 0) {
            cell!.backgroundColor = TLColors.evenTableViewCellColor()
        } else {
            cell!.backgroundColor = TLColors.oddTableViewCellColor()
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        var address = ""
        let cell = tableView.cellForRow(at: indexPath) as! TLAddressTableViewCell
        if ((indexPath as NSIndexPath).section == 0 || (indexPath as NSIndexPath).section == 1 || (indexPath as NSIndexPath).section == 3) {
            address = cell.addressLabel!.text!
        } else {
            address = cell.textLabel!.text!
        }
        
        if address == TL_STRING_NONE_CURRENTLY || address == TL_STRING_NO_STEALTH_PAYMENT_ADDRESSES_INFO {
            return nil
        }
        
        let addressType:TLAddressType
        let title:String
        if (indexPath as NSIndexPath).section == 0 {
            addressType = .stealth
            title = String(format: "Payment Index: %lu".localized, self.accountObject!.stealthWallet!.getStealthAddressPaymentsCount() - (indexPath as NSIndexPath).row)
        } else if ((indexPath as NSIndexPath).section == 1 || (indexPath as NSIndexPath).section == 3) {
            addressType = .main
            title = String(format: "Address ID: %lu".localized, self.accountObject!.getAddressHDIndex(address))
        } else {
            addressType = .change
            title = String(format: "Address ID: %lu".localized, self.accountObject!.getAddressHDIndex(address))
        }
        
        var nTxs = 0
        if ((indexPath as NSIndexPath).section == 1 || (indexPath as NSIndexPath).section == 3) {
            nTxs = self.accountObject!.getNumberOfTransactionsForAddress(address)
        }
        
        promptAddressActionSheet(address, addressType: addressType, title: title,
            addressNtxs: nTxs)
        
        return nil
    }
    
    func customIOS7dialogButtonTouchUp(inside alertView: CustomIOS7AlertView, clickedButtonAt buttonIndex: Int) {
        if (buttonIndex == 0) {
            iToast.makeText("Copied To clipboard".localized).setGravity(iToastGravityCenter).setDuration(1000).show()
            
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.QRImageModal!.QRcodeDisplayData
        }
        
        alertView.close()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
