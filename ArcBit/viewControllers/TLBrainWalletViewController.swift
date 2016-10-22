//
//  TLBrainWalletViewController.swift
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

@objc(TLBrainWalletViewController) class TLBrainWalletViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, TLAdvancedNewWalletTableViewCellDelegate, TLColdWalletSelectKeyTypeTableViewCellDelegate, CustomIOS7AlertViewDelegate {
    
    struct STATIC_MEMBERS {
        static let kInstuctionsSection = "kInstuctionsSection"
        static let kCreateNewWalletSection = "kCreateNewWalletSection"
        static let kSelectWhichKeyRow = "kSelectWhichKeyRow"
        static let kAdvancedNewWalletRow = "kAdvancedNewWalletRow"
    }
    
    @IBOutlet private var tableView: UITableView?
    private var QRImageModal: TLQRImageModal?
    private var mnemonicPassphrase: String?
    //    private var shouldShowMore: Bool = false
    private var masterHex: String?
    private var extendedKeyIdx: UInt?
    private var extendedPublicKey: String?
    private var extendedPrivateKey: String?
    private var sectionArray: Array<String>?
    private var instructionsRowArray: Array<String>?
    private var createNewWalletRowArray: Array<String>?
    private var advancedNewWalletTableViewCell: TLAdvancedNewWalletTableViewCell?
    private var tapGesture: UITapGestureRecognizer?
    private lazy var coldWalletKeyType: TLColdWalletKeyType = .Mnemonic

    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        
        NSNotificationCenter.defaultCenter().addObserver(self ,selector:#selector(TLBrainWalletViewController.keyboardWillShow(_:)),
                                                         name:UIKeyboardWillShowNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self ,selector:#selector(TLBrainWalletViewController.keyboardWillHide(_:)),
                                                         name:UIKeyboardWillHideNotification, object:nil)
        
        self.tapGesture = UITapGestureRecognizer(target: self,
                                                 action: #selector(dismissKeyboard))
        
        self.view.addGestureRecognizer(self.tapGesture!)
        
        self.extendedKeyIdx = 0
        self.sectionArray = [STATIC_MEMBERS.kInstuctionsSection, STATIC_MEMBERS.kCreateNewWalletSection]
        self.instructionsRowArray = []
        
        self.createNewWalletRowArray = [STATIC_MEMBERS.kSelectWhichKeyRow, STATIC_MEMBERS.kAdvancedNewWalletRow]

        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.tableFooterView = UIView(frame:CGRectZero)
    }
    
    func dismissKeyboard() {
        self.advancedNewWalletTableViewCell?.mnemonicTextView.resignFirstResponder()
        self.advancedNewWalletTableViewCell?.accountIDTextField.resignFirstResponder()
        self.advancedNewWalletTableViewCell?.accountPublicKeyTextView.resignFirstResponder()
        self.advancedNewWalletTableViewCell?.accountPrivateKeyTextView.resignFirstResponder()
        self.advancedNewWalletTableViewCell?.startingAddressIDTextField.resignFirstResponder()
        self.advancedNewWalletTableViewCell?.startingChangeAddressIDTextField.resignFirstResponder()
    }
    
    func didSelectColdWalletKeyType(cell: TLColdWalletSelectKeyTypeTableViewCell, keyType: TLColdWalletKeyType) {
        self.coldWalletKeyType = keyType
        self.tableView?.reloadData()
    }

    
    func didAdvancedNewWalletClickShowQRCodeButton(cell: TLAdvancedNewWalletTableViewCell, data: String) {
        dismissKeyboard()
        self.QRImageModal = TLQRImageModal(data: data, buttonCopyText: "Copy To Clipboard".localized, vc: self)
        self.QRImageModal!.show()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //        var frame:CGRect = CGRectMake(textField.frame.origin.x, textField.frame.origin.y, textField.frame.size.width, textField.frame.size.height)
        //        if textField == self.newWalletTableViewCell?.accountIDTextField {
        //            frame.origin.y += 100
        //        } else {
        //            frame.origin.y += 50
        //        }
        //        self.tableView!.scrollRectToVisible(self.tableView!.convertRect(frame, fromView:textField.superview), animated:true)
        self.tableView!.scrollRectToVisible(self.tableView!.convertRect(textField.frame, fromView:textField.superview), animated:true)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        let frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y+50, textView.frame.size.width, textView.frame.size.height)
        self.tableView!.scrollRectToVisible(self.tableView!.convertRect(frame, fromView:textView.superview), animated:true)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.advancedNewWalletTableViewCell?.accountIDTextField {
            
            let nsString = textField.text! as NSString
            let newString = nsString.stringByReplacingCharactersInRange(range, withString: string)
            
            var HDAccountID:UInt = 0
            if let accountID = UInt(newString) {
                HDAccountID = accountID
            }
            
            if self.coldWalletKeyType != .Mnemonic {
                return true
            }
            self.advancedNewWalletTableViewCell?.didUpdateMnemonic(self.advancedNewWalletTableViewCell!.mnemonicTextView.text, accountID: HDAccountID)

        } else if textField == self.advancedNewWalletTableViewCell?.startingAddressIDTextField {
            let nsString = textField.text! as NSString
            let newString = nsString.stringByReplacingCharactersInRange(range, withString: string)
            
            var addressID:UInt = 0
            if let HDAccountID = UInt(newString) {
                addressID = HDAccountID
            }
            self.advancedNewWalletTableViewCell?.updateAddressFieldsWithStartingAddressID(addressID)
        } else if textField == self.advancedNewWalletTableViewCell?.startingChangeAddressIDTextField {
            let nsString = textField.text! as NSString
            let newString = nsString.stringByReplacingCharactersInRange(range, withString: string)
            
            var addressID:UInt = 0
            if let HDAccountID = UInt(newString) {
                addressID = HDAccountID
            }
            self.advancedNewWalletTableViewCell?.updateChangeAddressFieldsWithStartingAddressID(addressID)
        }
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView == self.advancedNewWalletTableViewCell?.mnemonicTextView {
            self.advancedNewWalletTableViewCell?.didUpdateMnemonic(textView.text!)
        } else if textView == self.advancedNewWalletTableViewCell?.accountPublicKeyTextView {
            self.advancedNewWalletTableViewCell?.didUpdateAccountPublicKey(textView.text!)
        } else if textView == self.advancedNewWalletTableViewCell?.accountPrivateKeyTextView {
            self.advancedNewWalletTableViewCell?.didUpdateAccountPrivateKey(textView.text!)
        }
    }
    
    
    
    
    func keyboardWillShow(sender: NSNotification) {
        let kbSize = sender.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue!.size
        
        let duration = sender.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!
        
        let height = UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) ? kbSize.height : kbSize.width;
        UIView.animateWithDuration(duration, delay: 1.0, options: .TransitionNone, animations: {
            var edgeInsets = self.tableView!.contentInset;
            edgeInsets.bottom = height;
            self.tableView!.contentInset = edgeInsets;
            edgeInsets = self.tableView!.scrollIndicatorInsets;
            edgeInsets.bottom = height;
            self.tableView!.scrollIndicatorInsets = edgeInsets;
            }, completion: { finished in
        })
    }
    
    func keyboardWillHide(sender: NSNotification) {
        let duration = sender.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!
        UIView.animateWithDuration(duration, delay: 1.0, options: .TransitionNone, animations: {
            var edgeInsets = self.tableView!.contentInset;
            edgeInsets.bottom = 0;
            self.tableView!.contentInset = edgeInsets;
            edgeInsets = self.tableView!.scrollIndicatorInsets;
            edgeInsets.bottom = 0;
            self.tableView!.scrollIndicatorInsets = edgeInsets;
            }, completion: { finished in
        })
    }
    
    func numberOfSectionsInTableView(tableView:UITableView) -> Int {
        return self.sectionArray!.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = self.sectionArray![indexPath.section]
        if(section == STATIC_MEMBERS.kInstuctionsSection) {
            return 100
        } else if(section == STATIC_MEMBERS.kCreateNewWalletSection) {
            let row = self.createNewWalletRowArray![indexPath.row]
            if row == STATIC_MEMBERS.kSelectWhichKeyRow {
                return TLColdWalletSelectKeyTypeTableViewCell.cellHeight()
            } else if row == STATIC_MEMBERS.kAdvancedNewWalletRow {
                return TLAdvancedNewWalletTableViewCell.cellHeight()
            }
        }
        return 0
    }
    
    func tableView(tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        let section = self.sectionArray![section]
        if(section == STATIC_MEMBERS.kInstuctionsSection) {
            return "".localized
        } else if(section == STATIC_MEMBERS.kCreateNewWalletSection) {
            return "".localized
        }
        return "".localized
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        let section = self.sectionArray![section]
        if (section == STATIC_MEMBERS.kInstuctionsSection) {
            return self.instructionsRowArray!.count
        } else if(section == STATIC_MEMBERS.kCreateNewWalletSection) {
            return self.createNewWalletRowArray!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let section = self.sectionArray![indexPath.section];
        if (section == STATIC_MEMBERS.kInstuctionsSection) {
            let MyIdentifier = "InstructionsCellIdentifier"
            
            var cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier)
            if (cell == nil) {
                cell = UITableViewCell(style:UITableViewCellStyle.Default,
                                       reuseIdentifier:MyIdentifier)
            }
            return cell!
        } else if(section == STATIC_MEMBERS.kCreateNewWalletSection) {
            let row = self.createNewWalletRowArray![indexPath.row];
            if row == STATIC_MEMBERS.kSelectWhichKeyRow {
                let MyIdentifier = "ColdWalletSelectKeyTypeCellIdentifier"
                
                var cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier) as! TLColdWalletSelectKeyTypeTableViewCell?
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Default,
                                           reuseIdentifier: MyIdentifier) as? TLColdWalletSelectKeyTypeTableViewCell
                }
                cell?.delegate = self
                return cell!
            } else if row == STATIC_MEMBERS.kAdvancedNewWalletRow {
                let MyIdentifier = "AdvancedNewWalletCellIdentifier"
                
                var cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier) as! TLAdvancedNewWalletTableViewCell?
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Default,
                                           reuseIdentifier: MyIdentifier) as? TLAdvancedNewWalletTableViewCell
                }
                
                cell?.updateCellWithColdWalletKeyType(self.coldWalletKeyType)
                cell?.delegate = self
                cell?.mnemonicTextView.delegate = self
                cell?.accountIDTextField.delegate = self
                cell?.accountPublicKeyTextView.delegate = self
                cell?.accountPrivateKeyTextView.delegate = self
                cell?.startingAddressIDTextField.delegate = self
                cell?.startingChangeAddressIDTextField.delegate = self
                self.advancedNewWalletTableViewCell = cell
                return cell!
            }
        }
        return UITableViewCell(style:UITableViewCellStyle.Default,
                               reuseIdentifier:"DefaultCellIdentifier")
    }
    
    func tableView(tableView:UITableView, willSelectRowAtIndexPath indexPath:NSIndexPath) -> NSIndexPath? {
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
}
