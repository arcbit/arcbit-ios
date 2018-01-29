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
    
    @IBOutlet fileprivate var tableView: UITableView?
    fileprivate var QRImageModal: TLQRImageModal?
    fileprivate var mnemonicPassphrase: String?
    //    private var shouldShowMore: Bool = false
    fileprivate var masterHex: String?
    fileprivate var extendedKeyIdx: UInt?
    fileprivate var extendedPublicKey: String?
    fileprivate var extendedPrivateKey: String?
    fileprivate var sectionArray: Array<String>?
    fileprivate var instructionsRowArray: Array<String>?
    fileprivate var createNewWalletRowArray: Array<String>?
    fileprivate var advancedNewWalletTableViewCell: TLAdvancedNewWalletTableViewCell?
    fileprivate var tapGesture: UITapGestureRecognizer?
    fileprivate lazy var coldWalletKeyType: TLColdWalletKeyType = .mnemonic
    lazy var currentCoinType = TLWalletUtils.DEFAULT_COIN_TYPE()

    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        
        NotificationCenter.default.addObserver(self ,selector:#selector(TLBrainWalletViewController.keyboardWillShow(_:)),
                                                         name:NSNotification.Name.UIKeyboardWillShow, object:nil)
        NotificationCenter.default.addObserver(self ,selector:#selector(TLBrainWalletViewController.keyboardWillHide(_:)),
                                                         name:NSNotification.Name.UIKeyboardWillHide, object:nil)
        
        self.tapGesture = UITapGestureRecognizer(target: self,
                                                 action: #selector(dismissKeyboard))
        
        self.view.addGestureRecognizer(self.tapGesture!)
        
        self.extendedKeyIdx = 0
        self.sectionArray = [STATIC_MEMBERS.kInstuctionsSection, STATIC_MEMBERS.kCreateNewWalletSection]
        self.instructionsRowArray = []
        
        self.createNewWalletRowArray = [STATIC_MEMBERS.kSelectWhichKeyRow, STATIC_MEMBERS.kAdvancedNewWalletRow]

        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.tableFooterView = UIView(frame:CGRect.zero)
    }
    
    func dismissKeyboard() {
        self.advancedNewWalletTableViewCell?.mnemonicTextView.resignFirstResponder()
        self.advancedNewWalletTableViewCell?.accountIDTextField.resignFirstResponder()
        self.advancedNewWalletTableViewCell?.accountPublicKeyTextView.resignFirstResponder()
        self.advancedNewWalletTableViewCell?.accountPrivateKeyTextView.resignFirstResponder()
        self.advancedNewWalletTableViewCell?.startingAddressIDTextField.resignFirstResponder()
        self.advancedNewWalletTableViewCell?.startingChangeAddressIDTextField.resignFirstResponder()
    }
    
    func didSelectColdWalletKeyType(_ cell: TLColdWalletSelectKeyTypeTableViewCell, keyType: TLColdWalletKeyType) {
        self.coldWalletKeyType = keyType
        self.tableView?.reloadData()
    }

    
    func didAdvancedNewWalletClickShowQRCodeButton(_ cell: TLAdvancedNewWalletTableViewCell, data: String) {
        dismissKeyboard()
        self.QRImageModal = TLQRImageModal(data: data as NSString, buttonCopyText: TLDisplayStrings.COPY_TO_CLIPBOARD_STRING(), vc: self)
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
        
        if textField == self.advancedNewWalletTableViewCell?.accountIDTextField {
            
            let nsString = textField.text! as NSString
            let newString = nsString.replacingCharacters(in: range, with: string)
            
            var HDAccountID:Int = 0
            if let accountID = Int(newString) {
                HDAccountID = accountID
            }
            
            if self.coldWalletKeyType != .mnemonic {
                return true
            }
            self.advancedNewWalletTableViewCell?.didUpdateMnemonic(self.advancedNewWalletTableViewCell!.mnemonicTextView.text, accountID: HDAccountID)

        } else if textField == self.advancedNewWalletTableViewCell?.startingAddressIDTextField {
            let nsString = textField.text! as NSString
            let newString = nsString.replacingCharacters(in: range, with: string)
            
            var addressID:Int = 0
            if let addrID = Int(newString) {
                addressID = addrID
            }
            self.advancedNewWalletTableViewCell?.updateAddressFieldsWithStartingAddressID(addressID)
        } else if textField == self.advancedNewWalletTableViewCell?.startingChangeAddressIDTextField {
            let nsString = textField.text! as NSString
            let newString = nsString.replacingCharacters(in: range, with: string)
            
            var addressID:Int = 0
            if let addrID = Int(newString) {
                addressID = addrID
            }
            self.advancedNewWalletTableViewCell?.updateChangeAddressFieldsWithStartingAddressID(addressID)
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.advancedNewWalletTableViewCell?.mnemonicTextView {
            self.advancedNewWalletTableViewCell?.didUpdateMnemonic(textView.text!)
        } else if textView == self.advancedNewWalletTableViewCell?.accountPublicKeyTextView {
            self.advancedNewWalletTableViewCell?.didUpdateAccountPublicKey(textView.text!)
        } else if textView == self.advancedNewWalletTableViewCell?.accountPrivateKeyTextView {
            self.advancedNewWalletTableViewCell?.didUpdateAccountPrivateKey(textView.text!)
        }
    }
    
    
    
    
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
    
    func numberOfSections(in tableView:UITableView) -> Int {
        return self.sectionArray!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = self.sectionArray![(indexPath as NSIndexPath).section]
        if(section == STATIC_MEMBERS.kInstuctionsSection) {
            return 100
        } else if(section == STATIC_MEMBERS.kCreateNewWalletSection) {
            let row = self.createNewWalletRowArray![(indexPath as NSIndexPath).row]
            if row == STATIC_MEMBERS.kSelectWhichKeyRow {
                return TLColdWalletSelectKeyTypeTableViewCell.cellHeight()
            } else if row == STATIC_MEMBERS.kAdvancedNewWalletRow {
                return TLAdvancedNewWalletTableViewCell.cellHeight()
            }
        }
        return 0
    }
    
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        let section = self.sectionArray![section]
        if(section == STATIC_MEMBERS.kInstuctionsSection) {
            return ""
        } else if(section == STATIC_MEMBERS.kCreateNewWalletSection) {
            return ""
        }
        return ""
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
            if row == STATIC_MEMBERS.kSelectWhichKeyRow {
                let MyIdentifier = "ColdWalletSelectKeyTypeCellIdentifier"
                
                var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) as! TLColdWalletSelectKeyTypeTableViewCell?
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.default,
                                           reuseIdentifier: MyIdentifier) as? TLColdWalletSelectKeyTypeTableViewCell
                }
                cell?.delegate = self
                return cell!
            } else if row == STATIC_MEMBERS.kAdvancedNewWalletRow {
                let MyIdentifier = "AdvancedNewWalletCellIdentifier"
                
                var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) as! TLAdvancedNewWalletTableViewCell?
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.default,
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
                cell?.currentCoinType = self.currentCoinType
                self.advancedNewWalletTableViewCell = cell
                return cell!
            }
        }
        return UITableViewCell(style:UITableViewCellStyle.default,
                               reuseIdentifier:"DefaultCellIdentifier")
    }
    
    func tableView(_ tableView:UITableView, willSelectRowAt indexPath:IndexPath) -> IndexPath? {
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
}
