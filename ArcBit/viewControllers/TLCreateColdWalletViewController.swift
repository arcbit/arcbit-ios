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
    
    @IBOutlet fileprivate var tableView: UITableView?
    fileprivate var QRImageModal: TLQRImageModal?
    fileprivate var mnemonicPassphrase: String?
    fileprivate var masterHex: String?
    fileprivate var extendedKeyIdx: UInt?
    fileprivate var extendedPublicKey: String?
    fileprivate var extendedPrivateKey: String?
    fileprivate var sectionArray: Array<String>?
    fileprivate var instructionsRowArray: Array<String>?
    fileprivate var createNewWalletRowArray: Array<String>?
    fileprivate var newWalletTableViewCell: TLNewWalletTableViewCell?
    fileprivate var tapGesture: UITapGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()

        NotificationCenter.default.addObserver(self ,selector:#selector(TLCreateColdWalletViewController.keyboardWillShow(_:)),
                                                         name:NSNotification.Name.UIKeyboardWillShow, object:nil)
        NotificationCenter.default.addObserver(self ,selector:#selector(TLCreateColdWalletViewController.keyboardWillHide(_:)),
                                                         name:NSNotification.Name.UIKeyboardWillHide, object:nil)

        self.tapGesture = UITapGestureRecognizer(target: self,
                                                 action: #selector(dismissKeyboard))
        
        self.view.addGestureRecognizer(self.tapGesture!)
        
        self.extendedKeyIdx = 0
        self.sectionArray = [STATIC_MEMBERS.kInstuctionsSection, STATIC_MEMBERS.kCreateNewWalletSection]
        self.instructionsRowArray = []

        self.createNewWalletRowArray = [STATIC_MEMBERS.kSimpleNewWalletRow]
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.tableFooterView = UIView(frame:CGRect.zero)
    }
    
    func dismissKeyboard() {
        self.newWalletTableViewCell?.accountIDTextField.resignFirstResponder()
        self.newWalletTableViewCell?.mnemonicTextView.resignFirstResponder()
        self.newWalletTableViewCell?.accountPublicKeyTextView.resignFirstResponder()
    }
    
    func didClickShowQRCodeButton(_ cell: TLNewWalletTableViewCell, data: String) {
        dismissKeyboard()
        self.QRImageModal = TLQRImageModal(data: data as NSString, buttonCopyText: "Copy To Clipboard".localized, vc: self)
        self.QRImageModal!.show()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        var frame:CGRect = CGRectMake(textField.frame.origin.x, textField.frame.origin.y, textField.frame.size.width, textField.frame.size.height)
//        if textField == self.newWalletTableViewCell?.accountIDTextField {
//            frame.origin.y += 100
//        } else {
//            frame.origin.y += 50
//        }
//        self.tableView!.scrollRectToVisible(self.tableView!.convertRect(frame, fromView:textField.superview), animated:true)
        self.tableView!.scrollRectToVisible(self.tableView!.convert(textField.frame, from:textField.superview), animated:true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let frame = CGRect(x: textView.frame.origin.x, y: textView.frame.origin.y+50, width: textView.frame.size.width, height: textView.frame.size.height)
        self.tableView!.scrollRectToVisible(self.tableView!.convert(frame, from:textView.superview), animated:true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.newWalletTableViewCell?.accountIDTextField {
            if textField.text!.characters.count == 1 && string.isEmpty {
                self.newWalletTableViewCell?.updateAccountPublicKeyTextView(nil)
                return true
            }
            
            let nsString = textField.text! as NSString
            let newString = nsString.replacingCharacters(in: range, with: string)
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
    
    func textViewDidChange(_ textView: UITextView) {
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
                self.newWalletTableViewCell?.showAccountPublicKeyQRButton.isEnabled = true
                self.newWalletTableViewCell?.showAccountPublicKeyQRButton.alpha = 1
            } else {
                self.newWalletTableViewCell?.showAccountPublicKeyQRButton.isEnabled = false
                self.newWalletTableViewCell?.showAccountPublicKeyQRButton.alpha = 0.5
            }
        }
    }
    
    func numberOfSections(in tableView:UITableView) -> Int {
        return self.sectionArray!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = self.sectionArray![(indexPath as NSIndexPath).section]
        if(section == STATIC_MEMBERS.kInstuctionsSection) {
            return 100
        } else if(section == STATIC_MEMBERS.kCreateNewWalletSection) {
            let row = self.createNewWalletRowArray![(indexPath as NSIndexPath).row]
            if row == STATIC_MEMBERS.kSimpleNewWalletRow {
                return TLNewWalletTableViewCell.cellHeight()
            }
        }
        return 0
    }
    
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        let section = self.sectionArray![section]
        if(section == STATIC_MEMBERS.kInstuctionsSection) {
            return "".localized
        } else if(section == STATIC_MEMBERS.kCreateNewWalletSection) {
            return "".localized
        }
        return "".localized
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        let section = self.sectionArray![section]
        if (section == STATIC_MEMBERS.kInstuctionsSection) {
            return self.instructionsRowArray!.count
        } else if(section == STATIC_MEMBERS.kCreateNewWalletSection) {
            return self.createNewWalletRowArray!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        let section = self.sectionArray![(indexPath as NSIndexPath).section];
        if (section == STATIC_MEMBERS.kInstuctionsSection) {
            let MyIdentifier = "InstructionsCellIdentifier"
            
            var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier)
            if (cell == nil) {
                cell = UITableViewCell(style:UITableViewCellStyle.default,
                                       reuseIdentifier:MyIdentifier)
            }
            return cell!
        } else if(section == STATIC_MEMBERS.kCreateNewWalletSection) {
            let row = self.createNewWalletRowArray![(indexPath as NSIndexPath).row];
            if row == STATIC_MEMBERS.kSimpleNewWalletRow {
                let MyIdentifier = "NewWalletCellIdentifier"
                
                var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) as! TLNewWalletTableViewCell?
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.default,
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
        return UITableViewCell(style:UITableViewCellStyle.default,
                               reuseIdentifier:"DefaultCellIdentifier")
    }
//    
//    func tableView(tableView:UITableView, willSelectRowAtIndexPath indexPath:NSIndexPath) -> NSIndexPath? {
//        return nil
//    }
    
    func keyboardWillShow(_ sender: Notification) {
        let kbSize = ((sender as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue!.size
        
        let duration = ((sender as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue!
        
        let height = UIDeviceOrientationIsPortrait(UIDevice.current.orientation) ? kbSize.height : kbSize.width;
        UIView.animate(withDuration: duration, delay: 1.0, options: UIViewAnimationOptions(), animations: {
            var edgeInsets = self.tableView!.contentInset;
            edgeInsets.bottom = height;
            self.tableView!.contentInset = edgeInsets;
            edgeInsets = self.tableView!.scrollIndicatorInsets;
            edgeInsets.bottom = height;
            self.tableView!.scrollIndicatorInsets = edgeInsets;
            }, completion: { finished in
        })
    }
    
    func keyboardWillHide(_ sender: Notification) {
        let duration = ((sender as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue!
        UIView.animate(withDuration: duration, delay: 1.0, options: UIViewAnimationOptions(), animations: {
            var edgeInsets = self.tableView!.contentInset;
            edgeInsets.bottom = 0;
            self.tableView!.contentInset = edgeInsets;
            edgeInsets = self.tableView!.scrollIndicatorInsets;
            edgeInsets.bottom = 0;
            self.tableView!.scrollIndicatorInsets = edgeInsets;
            }, completion: { finished in
        })
    }
    
    func customIOS7dialogButtonTouchUp(inside alertView: AnyObject, clickedButtonAt buttonIndex: Int) {
        if (buttonIndex == 0) {
            iToast.makeText("Copied To clipboard".localized).setGravity(iToastGravityCenter).setDuration(1000).show()
            
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.QRImageModal!.QRcodeDisplayData
        }
        
        alertView.close()
    }
}
