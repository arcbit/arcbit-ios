//
//  TLSpendColdWalletViewController.swift
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

@objc(TLSpendColdWalletViewController) class  TLSpendColdWalletViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, TLScanUnsignedTxTableViewCellDelegate, TLInputColdWalletKeyTableViewCellDelegate, TLPassSignedTxTableViewCellDelegate, CustomIOS7AlertViewDelegate {
    
    struct STATIC_MEMBERS {
        static let kInstuctionsSection = "kInstuctionsSection"
        static let kSpendColdWalletSection = "kSpendColdWalletSection"
        
        static let kScanUnsignedTxRow = "kScanUnsignedTxRow"
        static let kInputKeyRow = "kInputKeyRow"
        static let kPassSignedTxRow = "kPassSignedTxRow"
    }
    
    @IBOutlet fileprivate var tableView: UITableView?
    fileprivate var QRImageModal: TLQRImageModal?
    fileprivate var sectionArray: Array<String>?
    fileprivate var instructionsRowArray: Array<String>?
    fileprivate var spendColdWalletRowArray: Array<String>?
    fileprivate var tapGesture: UITapGestureRecognizer?
    fileprivate var scanUnsignedTxTableViewCell: TLScanUnsignedTxTableViewCell?
    fileprivate var inputColdWalletKeyTableViewCell: TLInputColdWalletKeyTableViewCell?
    fileprivate var passSignedTxTableViewCell: TLPassSignedTxTableViewCell?

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
        
        self.sectionArray = [STATIC_MEMBERS.kInstuctionsSection, STATIC_MEMBERS.kSpendColdWalletSection]
        self.instructionsRowArray = []
        
        self.spendColdWalletRowArray = [STATIC_MEMBERS.kScanUnsignedTxRow, STATIC_MEMBERS.kInputKeyRow, STATIC_MEMBERS.kPassSignedTxRow]
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.tableFooterView = UIView(frame:CGRect.zero)
    }
    
    func dismissKeyboard() {
        self.inputColdWalletKeyTableViewCell?.keyInputTextView.resignFirstResponder()
    }
    
    func didClickScanUnsignedTxInfoButton(_ cell: TLScanUnsignedTxTableViewCell) {
        dismissKeyboard()
//        TLPrompts.promtForOK(self, title:"", message: "Info Text".localized, success: {
//            () in
//        })
        
        AppDelegate.instance().showColdWalletSpendReaderControllerFromViewController(self, success: {
            (data: String!) in
            
            DLog("didClickScanUnsignedTxInfoButton \(data)");
            }, error: {
                (data: String?) in
        })
    }

    func didClickScanButton(_ cell: TLScanUnsignedTxTableViewCell) {
        dismissKeyboard()
        
    }
    
    func didClickInputColdWalletKeyInfoButton(_ cell: TLInputColdWalletKeyTableViewCell) {
        dismissKeyboard()
        TLPrompts.promtForOK(self, title:"", message: "Info Text".localized, success: {
            () in
        })
    }
    
    func didClickPassButton(_ cell: TLPassSignedTxTableViewCell) {
        dismissKeyboard()

    }
    
    func didClickPassSignedTxInfoButton(_ cell: TLPassSignedTxTableViewCell) {
        dismissKeyboard()
        TLPrompts.promtForOK(self, title:"", message: "Info Text".localized, success: {
            () in
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.inputColdWalletKeyTableViewCell?.keyInputTextView {
            let value = textView.text!
            if value.contains(" ") && TLHDWalletWrapper.phraseIsValid(value) {
                
                if let accountPublicKey = self.inputColdWalletKeyTableViewCell?.accountPublicKey {
                    let masterHex = TLHDWalletWrapper.getMasterHex(value)

                    //                let accountIdx = TLHDWalletWrapper.getAccountIdxForExtendedKey(accountPublicKey!)
                    let accountIdx = UInt(TLHDWalletWrapper.getAccountIdxForExtendedKey(accountPublicKey))  //FIXME
                    
                    if TLHDWalletWrapper.getExtendPubKeyFromMasterHex(masterHex, accountIdx: accountIdx) == accountPublicKey {
                        //                    self.inputColdWalletKeyTableViewCell?.setstatusLabel(true) //DEBUG
                        self.inputColdWalletKeyTableViewCell?.setstatusLabel(false)
                    } else {
                        self.inputColdWalletKeyTableViewCell?.setstatusLabel(true)
                    }
   
                } else {
                    self.inputColdWalletKeyTableViewCell?.setstatusLabel(false)
                }
            } else if TLHDWalletWrapper.isValidExtendedPrivateKey(value) {
                // does nt match
                if (self.inputColdWalletKeyTableViewCell?.accountPublicKey != nil && TLHDWalletWrapper.getExtendPubKey(value) == self.inputColdWalletKeyTableViewCell?.accountPublicKey) {
                    self.inputColdWalletKeyTableViewCell?.setstatusLabel(true)
                } else {
                    self.inputColdWalletKeyTableViewCell?.setstatusLabel(false)
                }
            } else {
                self.inputColdWalletKeyTableViewCell?.setstatusLabel(false)
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
        } else if(section == STATIC_MEMBERS.kSpendColdWalletSection) {
            let row = self.spendColdWalletRowArray![(indexPath as NSIndexPath).row]
            if row == STATIC_MEMBERS.kScanUnsignedTxRow {
                return TLScanUnsignedTxTableViewCell.cellHeight()
            } else if row == STATIC_MEMBERS.kInputKeyRow {
                return TLInputColdWalletKeyTableViewCell.cellHeight()
            } else if row == STATIC_MEMBERS.kPassSignedTxRow {
                return TLPassSignedTxTableViewCell.cellHeight()
            }
        }
        return 0
    }
    
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        let section = self.sectionArray![section]
        if(section == STATIC_MEMBERS.kInstuctionsSection) {
            return "".localized
        } else if(section == STATIC_MEMBERS.kSpendColdWalletSection) {
            return "".localized
        }
        return "".localized
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        let section = self.sectionArray![section]
        if (section == STATIC_MEMBERS.kInstuctionsSection) {
            return self.instructionsRowArray!.count
        } else if(section == STATIC_MEMBERS.kSpendColdWalletSection) {
            return self.spendColdWalletRowArray!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        let section = self.sectionArray![(indexPath as NSIndexPath).section];
        if (section == STATIC_MEMBERS.kInstuctionsSection) {
            let MyIdentifier = "InstructionsCellIdentifier"
            
            var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier)
            if (cell == nil) {
                cell = UITableViewCell(style:UITableViewCellStyle.default,
                                       reuseIdentifier:MyIdentifier)
            }
            return cell!
        } else if(section == STATIC_MEMBERS.kSpendColdWalletSection) {
            let row = self.spendColdWalletRowArray![(indexPath as NSIndexPath).row];
            self.spendColdWalletRowArray = [STATIC_MEMBERS.kScanUnsignedTxRow, STATIC_MEMBERS.kInputKeyRow, STATIC_MEMBERS.kPassSignedTxRow]

            if row == STATIC_MEMBERS.kScanUnsignedTxRow {
                let MyIdentifier = "ScanUnsignedTxCellIdentifier"
                var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) as! TLScanUnsignedTxTableViewCell?
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.default,
                                           reuseIdentifier: MyIdentifier) as? TLScanUnsignedTxTableViewCell
                }
                
                cell?.delegate = self
                self.scanUnsignedTxTableViewCell = cell
                return cell!
            } else if row == STATIC_MEMBERS.kInputKeyRow {
                let MyIdentifier = "InputColdWalletKeyCellIdentifier"
                var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) as! TLInputColdWalletKeyTableViewCell?
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.default,
                                           reuseIdentifier: MyIdentifier) as? TLInputColdWalletKeyTableViewCell
                }
                
                cell?.delegate = self
                cell?.keyInputTextView.delegate = self
                self.inputColdWalletKeyTableViewCell = cell
                return cell!
            } else if row == STATIC_MEMBERS.kPassSignedTxRow {
                let MyIdentifier = "PassSignedTxCellIdentifier"
                var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) as! TLPassSignedTxTableViewCell?
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.default,
                                           reuseIdentifier: MyIdentifier) as? TLPassSignedTxTableViewCell
                }
                
                cell?.delegate = self
                self.passSignedTxTableViewCell = cell
                return cell!
            }
        }
        
        return UITableViewCell(style:UITableViewCellStyle.default,
                               reuseIdentifier:"DefaultCellIdentifier")
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
    
    func customIOS7dialogButtonTouchUp(inside alertView: CustomIOS7AlertView, clickedButtonAt buttonIndex: Int) {
        if (buttonIndex == 0) {
            iToast.makeText("Copied To clipboard".localized).setGravity(iToastGravityCenter).setDuration(1000).show()
            
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.QRImageModal!.QRcodeDisplayData
        }
        
        alertView.close()
    }
}
