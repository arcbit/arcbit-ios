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

    struct STATIC_MEMBERS {
        static let kStealthAddressSection = "kStealthAddressSection"
        static let kActiveMainSection = "kActiveMainSection"
        static let kArchivedMainSection = "kArchivedMainSection"
        static let kActiveChangeSection = "kActiveChangeSection"
        static let kArchivedChangeSection = "kArchivedChangeSection"
    }
    
    var accountObject: TLAccountObject?
    fileprivate var QRImageModal: TLQRImageModal?
    fileprivate lazy var sectionArray = Array<String>()
    var showBalances: Bool = false
    let TL_STRING_NO_STEALTH_PAYMENT_ADDRESSES_INFO = TLDisplayStrings.CANT_SEE_REUSABLE_ADDRESS_PAYMENTS_STRING()
    let TL_STRING_NONE_CURRENTLY = TLDisplayStrings.NONE_CURRENTLY_STRING()
    
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TLAddressListViewController.reloadAddressListTableView(_:)),
                                               name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_EXCHANGE_RATE_UPDATED()), object: nil)

        if TLWalletUtils.ENABLE_STEALTH_ADDRESS() {
            self.sectionArray = [STATIC_MEMBERS.kStealthAddressSection, STATIC_MEMBERS.kActiveMainSection, STATIC_MEMBERS.kArchivedMainSection, STATIC_MEMBERS.kActiveChangeSection, STATIC_MEMBERS.kArchivedChangeSection]
        } else {
            self.sectionArray = [STATIC_MEMBERS.kActiveMainSection, STATIC_MEMBERS.kArchivedMainSection, STATIC_MEMBERS.kActiveChangeSection, STATIC_MEMBERS.kArchivedChangeSection]
        }
        
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
                otherButtonTitles = [TLDisplayStrings.VIEW_IN_WEB_STRING(), TLDisplayStrings.VIEW_ADDRESS_QR_CODE_STRING(), TLDisplayStrings.VIEW_PRIVATE_KEY_QR_CODE_STRING()]
            } else {
                otherButtonTitles = [TLDisplayStrings.VIEW_IN_WEB_STRING(), TLDisplayStrings.VIEW_ADDRESS_QR_CODE_STRING()]
            }
            
            UIAlertController.showAlert(in: self,
                withTitle: title,
                message:"",
                preferredStyle: .actionSheet,
                cancelButtonTitle: TLDisplayStrings.CANCEL_STRING(),
                destructiveButtonTitle: nil,
                otherButtonTitles: otherButtonTitles as [AnyObject],
                
                tap: {(actionSheet, action, buttonIndex) in
                    
                    if (buttonIndex == actionSheet?.firstOtherButtonIndex) {
                        TLBlockExplorerAPI.instance().openWebViewForAddress(address)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_ACCOUNT_ADDRESS_IN_WEB()),
                            object: nil, userInfo: nil)
                        
                    } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)! + 1) {
                        if (TLSuggestions.instance().enabledSuggestDontManageIndividualAccountAddress()) {
                            TLPrompts.promtForOK(self, title:TLDisplayStrings.WARNING_STRING(), message: TLDisplayStrings.DONT_MANAGE_INDIVIDUAL_ACCOUNT_ADDRESS_WARNING_DESC_STRING(), success: {
                                () in
                                self.showAddressQRCode(address)
                                TLSuggestions.instance().setEnableSuggestDontManageIndividualAccountAddress(false)
                            })
                        } else {
                            self.showAddressQRCode(address)
                        }
                    } else if (buttonIndex == (actionSheet?.firstOtherButtonIndex)! + 2) {
                        if (TLSuggestions.instance().enabledSuggestDontManageIndividualAccountPrivateKeys()) {
                            TLPrompts.promtForOK(self,title:TLDisplayStrings.WARNING_STRING(), message: TLDisplayStrings.DONT_MANAGE_INDIVIDUAL_ACCOUNT_PRIVATE_KEY_WARNING_DESC_STRING(), success: {
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
        self.QRImageModal = TLQRImageModal(data: address as NSString, buttonCopyText: TLDisplayStrings.COPY_TO_CLIPBOARD_STRING(), vc: self)
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
                        TLPrompts.promptErrorMessage(TLDisplayStrings.ERROR_STRING(), message: TLDisplayStrings.INVALID_ACCOUNT_PRIVATE_KEY_STRING())
                    } else {
                        let success = self.accountObject!.setExtendedPrivateKeyInMemory(data)
                        if (!success) {
                            TLPrompts.promptErrorMessage(TLDisplayStrings.ERROR_STRING(), message: TLDisplayStrings.ACCOUNT_PRIVATE_KEY_DOES_NOT_MATCH_STRING())
                        } else {
                            self.showPrivateKeyQRCodeFinal(address, addressType: addressType)
                        }
                    }
                    }, error: {
                        (data: String?) in
                })
        } else if self.accountObject!.isColdWalletAccount() {
            TLPrompts.promptErrorMessage("", message: TLDisplayStrings.COLD_WALLET_PRIVATE_KEYS_ARE_NOT_STORED_HERE_STRING())
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
        
        self.QRImageModal = TLQRImageModal(data: privateKey as NSString, buttonCopyText: TLDisplayStrings.COPY_TO_CLIPBOARD_STRING(), vc: self)
        self.QRImageModal!.show()
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_ACCOUNT_PRIVATE_KEY()), object: nil, userInfo: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionType = self.sectionArray[section]
        if sectionType == STATIC_MEMBERS.kStealthAddressSection {
            //there are no archived stealth payment addresses, because old payment addresses are deleted
            return TLDisplayStrings.REUSABLE_ADDRESS_PAYMENT_ADDRESSES_STRING()
        } else if sectionType == STATIC_MEMBERS.kActiveMainSection {
            return TLDisplayStrings.ACTIVE_MAIN_ADDRESSES_STRING()
        } else if sectionType == STATIC_MEMBERS.kArchivedMainSection {
            return TLDisplayStrings.ARCHIVED_MAIN_ADDRESSES_STRING()
        } else if sectionType == STATIC_MEMBERS.kActiveChangeSection {
            return TLDisplayStrings.ACTIVE_CHANGE_ADDRESSES_STRING()
        } else if sectionType == STATIC_MEMBERS.kArchivedChangeSection {
            return TLDisplayStrings.ARCHIVED_CHANGE_ADDRESSES_STRING()
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count:Int
        let sectionType = self.sectionArray[section]
        if sectionType == STATIC_MEMBERS.kStealthAddressSection {
            if TLWalletUtils.ENABLE_STEALTH_ADDRESS() && self.accountObject!.getAccountType() != .importedWatch && self.accountObject!.getAccountType() != .coldWallet {
                count = self.accountObject!.stealthWallet!.getStealthAddressPaymentsCount()
            } else {
                count = 0
            }
        } else if sectionType == STATIC_MEMBERS.kActiveMainSection {
            count = self.accountObject!.getMainActiveAddressesCount()
        } else if sectionType == STATIC_MEMBERS.kArchivedMainSection {
            count = self.accountObject!.getMainArchivedAddressesCount()
        } else if sectionType == STATIC_MEMBERS.kActiveChangeSection {
            count = self.accountObject!.getChangeActiveAddressesCount()
        } else if sectionType == STATIC_MEMBERS.kArchivedChangeSection {
            count = self.accountObject!.getChangeArchivedAddressesCount()
        } else {
            count = 0
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
        let sectionType = self.sectionArray[(indexPath as NSIndexPath).section]
        if sectionType == STATIC_MEMBERS.kStealthAddressSection || sectionType == STATIC_MEMBERS.kActiveMainSection || sectionType == STATIC_MEMBERS.kActiveChangeSection {
            cell!.textLabel!.isHidden = true
            cell!.amountButton!.isHidden = false
            cell!.addressLabel!.isHidden = false
            cell!.addressLabel!.adjustsFontSizeToFitWidth = true
            
            var address = ""
            var balance = ""
            if sectionType == STATIC_MEMBERS.kStealthAddressSection {
                if TLWalletUtils.ENABLE_STEALTH_ADDRESS() && self.accountObject!.getAccountType() != .importedWatch && self.accountObject!.getAccountType() != .coldWallet {
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
            } else if sectionType == STATIC_MEMBERS.kActiveMainSection {
                if (self.accountObject!.getMainActiveAddressesCount() == 0) {
                    address = TL_STRING_NONE_CURRENTLY
                } else {
                    let idx = self.accountObject!.getMainActiveAddressesCount() - 1 - (indexPath as NSIndexPath).row
                    address = self.accountObject!.getMainActiveAddress(idx)
                }
            } else if sectionType == STATIC_MEMBERS.kActiveChangeSection {
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
            if sectionType == STATIC_MEMBERS.kArchivedMainSection {
                if (self.accountObject!.getMainArchivedAddressesCount() == 0) {
                    address = TL_STRING_NONE_CURRENTLY
                } else {
                    let idx = self.accountObject!.getMainArchivedAddressesCount() - 1 - (indexPath as NSIndexPath).row
                    address = self.accountObject!.getMainArchivedAddress(idx)
                }
            } else if sectionType == STATIC_MEMBERS.kArchivedChangeSection {
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
        
        let sectionType = self.sectionArray[(indexPath as NSIndexPath).section]
        if sectionType == STATIC_MEMBERS.kStealthAddressSection || sectionType == STATIC_MEMBERS.kActiveMainSection || sectionType == STATIC_MEMBERS.kActiveChangeSection {
            address = cell.addressLabel!.text!
        } else {
            address = cell.textLabel!.text!
        }
        
        if address == TL_STRING_NONE_CURRENTLY || address == TL_STRING_NO_STEALTH_PAYMENT_ADDRESSES_INFO {
            return nil
        }
        
        let addressType:TLAddressType
        let title:String
        if sectionType == STATIC_MEMBERS.kStealthAddressSection {
            addressType = .stealth
            title = String(format: TLDisplayStrings.PAYMENT_INDEX_X_STRING(), self.accountObject!.stealthWallet!.getStealthAddressPaymentsCount() - (indexPath as NSIndexPath).row)
        } else if sectionType == STATIC_MEMBERS.kActiveMainSection || sectionType == STATIC_MEMBERS.kActiveChangeSection {
            addressType = .main
            title = String(format: TLDisplayStrings.ADDRESS_ID_X_STRING_STRING(), self.accountObject!.getAddressHDIndex(address))
        } else {
            addressType = .change
            title = String(format: TLDisplayStrings.ADDRESS_ID_X_STRING_STRING(), self.accountObject!.getAddressHDIndex(address))
        }
        
        var nTxs = 0
        if (sectionType == STATIC_MEMBERS.kActiveMainSection || sectionType == STATIC_MEMBERS.kActiveChangeSection) {
            nTxs = self.accountObject!.getNumberOfTransactionsForAddress(address)
        }
        
        promptAddressActionSheet(address, addressType: addressType, title: title,
            addressNtxs: nTxs)
        
        return nil
    }
    
    func customIOS7dialogButtonTouchUp(inside alertView: CustomIOS7AlertView, clickedButtonAt buttonIndex: Int) {
        if (buttonIndex == 0) {
            iToast.makeText(TLDisplayStrings.COPY_TO_CLIPBOARD_STRING()).setGravity(iToastGravityCenter).setDuration(1000).show()
            
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.QRImageModal!.QRcodeDisplayData
        }
        
        alertView.close()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
