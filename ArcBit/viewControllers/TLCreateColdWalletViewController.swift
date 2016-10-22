//
//  TLCreateColdWalletViewController.swift
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

@objc(TLCreateColdWalletViewController) class TLCreateColdWalletViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, TLNewWalletTableViewCellDelegate, CustomIOS7AlertViewDelegate {

    struct STATIC_MEMBERS {
        static let kInstuctionsSection = "kInstuctionsSection"
        static let kCreateNewWalletSection = "kCreateNewWalletSection"

        static let kSimpleNewWalletRow = "kSimpleNewWalletRow"
    }
    
    @IBOutlet private var tableView: UITableView?
    private var QRImageModal: TLQRImageModal?
    private var mnemonicPassphrase: String?
    private var masterHex: String?
    private var extendedKeyIdx: UInt?
    private var extendedPublicKey: String?
    private var extendedPrivateKey: String?
    private var sectionArray: Array<String>?
    private var instructionsRowArray: Array<String>?
    private var createNewWalletRowArray: Array<String>?
    private var newWalletTableViewCell: TLNewWalletTableViewCell?
    private var tapGesture: UITapGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()

        NSNotificationCenter.defaultCenter().addObserver(self ,selector:#selector(TLCreateColdWalletViewController.keyboardWillShow(_:)),
                                                         name:UIKeyboardWillShowNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self ,selector:#selector(TLCreateColdWalletViewController.keyboardWillHide(_:)),
                                                         name:UIKeyboardWillHideNotification, object:nil)

        self.tapGesture = UITapGestureRecognizer(target: self,
                                                 action: #selector(dismissKeyboard))
        
        self.view.addGestureRecognizer(self.tapGesture!)
        
        self.extendedKeyIdx = 0
        self.sectionArray = [STATIC_MEMBERS.kInstuctionsSection, STATIC_MEMBERS.kCreateNewWalletSection]
        self.instructionsRowArray = []

        self.createNewWalletRowArray = [STATIC_MEMBERS.kSimpleNewWalletRow]
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.tableFooterView = UIView(frame:CGRectZero)
    }
    
    func dismissKeyboard() {
        self.newWalletTableViewCell?.accountIDTextField.resignFirstResponder()
        self.newWalletTableViewCell?.mnemonicTextView.resignFirstResponder()
        self.newWalletTableViewCell?.accountPublicKeyTextView.resignFirstResponder()
    }
    
    func didClickShowQRCodeButton(cell: TLNewWalletTableViewCell, data: String) {
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
        
        if textField == self.newWalletTableViewCell?.accountIDTextField {
            if textField.text!.characters.count == 1 && string.isEmpty {
                self.newWalletTableViewCell?.updateAccountPublicKeyTextView(nil)
                return true
            }
            
            let nsString = textField.text! as NSString
            let newString = nsString.stringByReplacingCharactersInRange(range, withString: string)
            if let accountID = UInt(newString) {
                let mnemonicPassphrase = self.newWalletTableViewCell?.mnemonicTextView.text
                if mnemonicPassphrase != nil && TLHDWalletWrapper.phraseIsValid(mnemonicPassphrase!) {
                    let masterHex = TLHDWalletWrapper.getMasterHex(mnemonicPassphrase!)
                    let extendedPublicKey = TLHDWalletWrapper.getExtendPubKeyFromMasterHex(masterHex, accountIdx: accountID)
                    self.newWalletTableViewCell?.accountPublicKeyTextView.text = extendedPublicKey
                    self.newWalletTableViewCell?.updateAccountPublicKeyTextView(extendedPublicKey)
                } else {
                    self.newWalletTableViewCell?.updateAccountPublicKeyTextView(nil)
                }
            } else {
                self.newWalletTableViewCell?.updateAccountPublicKeyTextView(nil)
            }
        }

        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView == self.newWalletTableViewCell?.mnemonicTextView {
            let mnemonicPassphrase = textView.text!
            if TLHDWalletWrapper.phraseIsValid(mnemonicPassphrase) {
                self.newWalletTableViewCell?.didUpdateMnemonic(textView.text!)
            } else {
                self.newWalletTableViewCell?.updateAccountPublicKeyTextView(nil)
            }
        } else if textView == self.newWalletTableViewCell?.accountPublicKeyTextView {
            let accountPublicKey = self.newWalletTableViewCell?.accountPublicKeyTextView.text
            if accountPublicKey != nil && !accountPublicKey!.isEmpty && TLHDWalletWrapper.isValidExtendedPublicKey(accountPublicKey!) {
                self.newWalletTableViewCell?.showAccountPublicKeyQRButton.enabled = true
                self.newWalletTableViewCell?.showAccountPublicKeyQRButton.alpha = 1
            } else {
                self.newWalletTableViewCell?.showAccountPublicKeyQRButton.enabled = false
                self.newWalletTableViewCell?.showAccountPublicKeyQRButton.alpha = 0.5
            }
        }
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
            if row == STATIC_MEMBERS.kSimpleNewWalletRow {
                return TLNewWalletTableViewCell.cellHeight()
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
            if row == STATIC_MEMBERS.kSimpleNewWalletRow {
                let MyIdentifier = "NewWalletCellIdentifier"
                
                var cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier) as! TLNewWalletTableViewCell?
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Default,
                                           reuseIdentifier: MyIdentifier) as? TLNewWalletTableViewCell
                }
                
                cell?.delegate = self
                cell?.mnemonicTextView.delegate = self
                cell?.accountIDTextField.delegate = self
                cell?.accountPublicKeyTextView.delegate = self
                self.newWalletTableViewCell = cell
                return cell!
            }
        }
        return UITableViewCell(style:UITableViewCellStyle.Default,
                               reuseIdentifier:"DefaultCellIdentifier")
    }
//    
//    func tableView(tableView:UITableView, willSelectRowAtIndexPath indexPath:NSIndexPath) -> NSIndexPath? {
//        return nil
//    }
    
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
    
    func customIOS7dialogButtonTouchUpInside(alertView: AnyObject, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == 0) {
            iToast.makeText("Copied To clipboard".localized).setGravity(iToastGravityCenter).setDuration(1000).show()
            
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = self.QRImageModal!.QRcodeDisplayData
        }
        
        alertView.close()
    }
}
