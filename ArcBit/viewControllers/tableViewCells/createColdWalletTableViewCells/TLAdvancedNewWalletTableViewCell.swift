//
//  TLAdvancedNewWalletTableViewCell.swift
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

protocol TLAdvancedNewWalletTableViewCellDelegate {
    func didAdvancedNewWalletClickShowQRCodeButton(_ cell: TLAdvancedNewWalletTableViewCell, data: String)
}

@objc(TLAdvancedNewWalletTableViewCell) class TLAdvancedNewWalletTableViewCell:UITableViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet var mnemonicTextView:UITextView!
    @IBOutlet var newWalletButton:UIButton!
    @IBOutlet var accountIDTextField: UITextField!
    @IBOutlet var accountPublicKeyTextView:UITextView!
    @IBOutlet var showAccountPublicKeyQRButton:UIButton!
    @IBOutlet var accountPrivateKeyTextView:UITextView!
    @IBOutlet var showAccountPrivateKeyQRButton:UIButton!
    
    @IBOutlet weak var startingAddressIDTextField: UITextField!
    @IBOutlet weak var addressLabel1: UILabel!
    @IBOutlet weak var addressTextField1: UITextField!
    @IBOutlet weak var privateKeyTextField1: UITextField!
    @IBOutlet weak var showAddressQRCodeButton1: UIButton!
    @IBOutlet weak var showPrivateKeyQRCodeButton1: UIButton!
    @IBOutlet weak var addressLabel2: UILabel!
    @IBOutlet weak var addressTextField2: UITextField!
    @IBOutlet weak var privateKeyTextField2: UITextField!
    @IBOutlet weak var showAddressQRCodeButton2: UIButton!
    @IBOutlet weak var showPrivateKeyQRCodeButton2: UIButton!
    @IBOutlet weak var addressLabel3: UILabel!
    @IBOutlet weak var addressTextField3: UITextField!
    @IBOutlet weak var privateKeyTextField3: UITextField!
    @IBOutlet weak var showAddressQRCodeButton3: UIButton!
    @IBOutlet weak var showPrivateKeyQRCodeButton3: UIButton!
    @IBOutlet weak var addressLabel4: UILabel!
    @IBOutlet weak var addressTextField4: UITextField!
    @IBOutlet weak var privateKeyTextField4: UITextField!
    @IBOutlet weak var showAddressQRCodeButton4: UIButton!
    @IBOutlet weak var showPrivateKeyQRCodeButton4: UIButton!
    @IBOutlet weak var addressLabel5: UILabel!
    @IBOutlet weak var addressTextField5: UITextField!
    @IBOutlet weak var privateKeyTextField5: UITextField!
    @IBOutlet weak var showAddressQRCodeButton5: UIButton!
    @IBOutlet weak var showPrivateKeyQRCodeButton5: UIButton!

    @IBOutlet weak var startingChangeAddressIDTextField: UITextField!
    @IBOutlet weak var changeAddressLabel1: UILabel!
    @IBOutlet weak var changeAddressTextField1: UITextField!
    @IBOutlet weak var changePrivateKeyTextField1: UITextField!
    @IBOutlet weak var showChangeAddressQRCodeButton1: UIButton!
    @IBOutlet weak var showChangePrivateKeyQRCodeButton1: UIButton!
    @IBOutlet weak var changeAddressLabel2: UILabel!
    @IBOutlet weak var changeAddressTextField2: UITextField!
    @IBOutlet weak var changePrivateKeyTextField2: UITextField!
    @IBOutlet weak var showChangeAddressQRCodeButton2: UIButton!
    @IBOutlet weak var showChangePrivateKeyQRCodeButton2: UIButton!
    @IBOutlet weak var changeAddressLabel3: UILabel!
    @IBOutlet weak var changeAddressTextField3: UITextField!
    @IBOutlet weak var changePrivateKeyTextField3: UITextField!
    @IBOutlet weak var showChangeAddressQRCodeButton3: UIButton!
    @IBOutlet weak var showChangePrivateKeyQRCodeButton3: UIButton!
    @IBOutlet weak var changeAddressLabel4: UILabel!
    @IBOutlet weak var changeAddressTextField4: UITextField!
    @IBOutlet weak var changePrivateKeyTextField4: UITextField!
    @IBOutlet weak var showChangeAddressQRCodeButton4: UIButton!
    @IBOutlet weak var showChangePrivateKeyQRCodeButton4: UIButton!
    @IBOutlet weak var changeAddressLabel5: UILabel!
    @IBOutlet weak var changeAddressTextField5: UITextField!
    @IBOutlet weak var changePrivateKeyTextField5: UITextField!
    @IBOutlet weak var showChangeAddressQRCodeButton5: UIButton!
    @IBOutlet weak var showChangePrivateKeyQRCodeButton5: UIButton!
    
    var delegate: TLAdvancedNewWalletTableViewCellDelegate?
    fileprivate lazy var coldWalletKeyType: TLColdWalletKeyType = .mnemonic
    fileprivate var isTestnet = AppDelegate.instance().appWallet.walletConfig.isTestnet
    fileprivate var extendedPrivateKey: String?
    fileprivate var extendedPublicKey: String?

    override init(style:UITableViewCellStyle, reuseIdentifier:String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.mnemonicTextView.layer.borderWidth = 1.0
        self.mnemonicTextView.layer.borderColor = UIColor.black.cgColor
        self.mnemonicTextView.autocorrectionType = UITextAutocorrectionType.no
        self.mnemonicTextView.autocapitalizationType = .none
        self.newWalletButton.backgroundColor = TLColors.mainAppColor()
        self.newWalletButton.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.newWalletButton.titleLabel!.adjustsFontSizeToFitWidth = true
        self.accountIDTextField.keyboardType = UIKeyboardType.numberPad
        self.accountPublicKeyTextView.layer.borderWidth = 1.0
        self.showAccountPublicKeyQRButton.backgroundColor = TLColors.mainAppColor()
        self.showAccountPublicKeyQRButton.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.accountPrivateKeyTextView.layer.borderWidth = 1.0
        self.showAccountPrivateKeyQRButton.backgroundColor = TLColors.mainAppColor()
        self.showAccountPrivateKeyQRButton.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.updateWalletKeys()
        
        self.startingAddressIDTextField.keyboardType = UIKeyboardType.numberPad
        
        self.showAddressQRCodeButton1.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showAddressQRCodeButton1.backgroundColor = TLColors.mainAppColor()
        self.showPrivateKeyQRCodeButton1.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showPrivateKeyQRCodeButton1.backgroundColor = TLColors.mainAppColor()
        
        self.showAddressQRCodeButton2.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showAddressQRCodeButton2.backgroundColor = TLColors.mainAppColor()
        self.showPrivateKeyQRCodeButton2.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showPrivateKeyQRCodeButton2.backgroundColor = TLColors.mainAppColor()
        
        self.showAddressQRCodeButton3.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showAddressQRCodeButton3.backgroundColor = TLColors.mainAppColor()
        self.showPrivateKeyQRCodeButton3.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showPrivateKeyQRCodeButton3.backgroundColor = TLColors.mainAppColor()
        
        self.showAddressQRCodeButton4.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showAddressQRCodeButton4.backgroundColor = TLColors.mainAppColor()
        self.showPrivateKeyQRCodeButton4.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showPrivateKeyQRCodeButton4.backgroundColor = TLColors.mainAppColor()
        
        self.showAddressQRCodeButton5.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showAddressQRCodeButton5.backgroundColor = TLColors.mainAppColor()
        self.showPrivateKeyQRCodeButton5.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showPrivateKeyQRCodeButton5.backgroundColor = TLColors.mainAppColor()
      
        self.startingChangeAddressIDTextField.keyboardType = UIKeyboardType.numberPad
        
        self.showChangeAddressQRCodeButton1.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showChangeAddressQRCodeButton1.backgroundColor = TLColors.mainAppColor()
        self.showChangePrivateKeyQRCodeButton1.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showChangePrivateKeyQRCodeButton1.backgroundColor = TLColors.mainAppColor()
        
        self.showChangeAddressQRCodeButton2.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showChangeAddressQRCodeButton2.backgroundColor = TLColors.mainAppColor()
        self.showChangePrivateKeyQRCodeButton2.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showChangePrivateKeyQRCodeButton2.backgroundColor = TLColors.mainAppColor()
        
        self.showChangeAddressQRCodeButton3.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showChangeAddressQRCodeButton3.backgroundColor = TLColors.mainAppColor()
        self.showChangePrivateKeyQRCodeButton3.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showChangePrivateKeyQRCodeButton3.backgroundColor = TLColors.mainAppColor()
        
        self.showChangeAddressQRCodeButton4.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showChangeAddressQRCodeButton4.backgroundColor = TLColors.mainAppColor()
        self.showChangePrivateKeyQRCodeButton4.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showChangePrivateKeyQRCodeButton4.backgroundColor = TLColors.mainAppColor()
        
        self.showChangeAddressQRCodeButton5.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showChangeAddressQRCodeButton5.backgroundColor = TLColors.mainAppColor()
        self.showChangePrivateKeyQRCodeButton5.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showChangePrivateKeyQRCodeButton5.backgroundColor = TLColors.mainAppColor()
        
        self.mnemonicTextView.text = nil
        self.accountPublicKeyTextView.text = nil
        self.accountPrivateKeyTextView.text = nil

        
        self.updateAccountIDTextField(false)
        self.updateAccountPublicKeyTextView(nil)
        self.updateAccountPrivateKeyTextView(nil)
        self.clearAddressFields()
    }
    
    class func cellHeight() -> CGFloat {
        return 1359
    }
    
    fileprivate func enableTextView(_ textView:UITextView, enable:Bool) {
        if enable {
            textView.isUserInteractionEnabled = true
            textView.alpha = 1
        } else {
            textView.isUserInteractionEnabled = false
            textView.alpha = 0.5
        }
    }

    fileprivate func enableTextField(_ textField:UITextField, enable:Bool) {
        if enable {
            textField.isEnabled = true
            textField.alpha = 1.0
        } else {
            textField.isEnabled = false
            textField.alpha = 0.5
        }
    }
    
    fileprivate func enableButton(_ button:UIButton, enable:Bool) {
        if enable {
            button.isEnabled = true
            button.alpha = 1.0
        } else {
            button.isEnabled = false
            button.alpha = 0.5
        }
    }
    
    
    func updateWalletKeys() {
        if self.coldWalletKeyType == .mnemonic {
            self.enableTextView(self.mnemonicTextView, enable: true)
            self.enableButton(self.newWalletButton, enable: true)
            self.updateAccountIDTextField(false)
            self.enableTextView(self.accountPrivateKeyTextView, enable: false)
            self.enableTextView(self.accountPublicKeyTextView, enable: false)
            
            self.didUpdateMnemonic(self.mnemonicTextView.text!)

        } else if self.coldWalletKeyType == .accountPublicKey {
            self.mnemonicTextView.text = nil
            self.enableTextView(self.mnemonicTextView, enable: false)
            self.enableButton(self.newWalletButton, enable: false)
            self.updateAccountIDTextField(false)
            self.accountPrivateKeyTextView.text = nil
            self.enableTextView(self.accountPrivateKeyTextView, enable: false)
            self.enableTextView(self.accountPublicKeyTextView, enable: true)

            self.enableButton(self.showAccountPrivateKeyQRButton, enable: false)

            self.didUpdateAccountPublicKey(self.accountPublicKeyTextView.text!)

        } else if self.coldWalletKeyType == .accountPrivateKey {
            self.mnemonicTextView.text = nil
            self.enableTextView(self.mnemonicTextView, enable: false)
            self.enableButton(self.newWalletButton, enable: false)
            self.updateAccountIDTextField(false)
            self.enableTextView(self.accountPrivateKeyTextView, enable: true)
            self.enableTextView(self.accountPublicKeyTextView, enable: false)

            self.didUpdateAccountPrivateKey(self.accountPrivateKeyTextView.text!)
        }
    }

    func updateCellWithColdWalletKeyType(_ coldWalletKeyType: TLColdWalletKeyType) {
        self.coldWalletKeyType = coldWalletKeyType
        self.updateWalletKeys()
    }

    func didUpdateMnemonic(_ mnemonicPassphrase: String, accountID: Int? = nil) {
        if TLHDWalletWrapper.phraseIsValid(mnemonicPassphrase) {
            let masterHex = TLHDWalletWrapper.getMasterHex(mnemonicPassphrase)
            var HDAccountID:Int? = 0
            if accountID == nil {
                HDAccountID = Int(self.accountIDTextField.text!)
                if HDAccountID == nil {
                    HDAccountID = 0
                }
            } else {
                HDAccountID = accountID
            }

            self.updateAccountIDTextField(true)
            let extendedPublicKey = TLHDWalletWrapper.getExtendPubKeyFromMasterHex(masterHex, accountIdx: UInt(HDAccountID!))
            self.accountPublicKeyTextView.text = extendedPublicKey
            self.updateAccountPublicKeyTextView(extendedPublicKey)
            let extendedPrivateKey = TLHDWalletWrapper.getExtendPrivKey(masterHex, accountIdx: UInt(HDAccountID!))
            self.accountPrivateKeyTextView.text = extendedPrivateKey
            self.updateAccountPrivateKeyTextView(extendedPrivateKey)
  
            self.updateAddressFieldsWithStartingAddressID()
            self.updateChangeAddressFieldsWithStartingAddressID()
        } else {
            self.updateAccountIDTextField(false)
            self.accountPublicKeyTextView.text = nil
            self.accountPrivateKeyTextView.text = nil
            self.updateAccountPublicKeyTextView(nil)
            self.updateAccountPrivateKeyTextView(nil)
            self.clearAddressFields()
        }
    }
    
    func didUpdateAccountPublicKey(_ accountPublicKey: String?) {
        if !accountPublicKey!.isEmpty && TLHDWalletWrapper.isValidExtendedPublicKey(accountPublicKey!) {
            let accoundIdx = TLHDWalletWrapper.getAccountIdxForExtendedKey(accountPublicKey!)
            self.accountIDTextField.text = String(accoundIdx)
            self.enableButton(self.showAccountPublicKeyQRButton, enable: true)
            self.updateAddressFieldsWithStartingAddressID()
            self.updateChangeAddressFieldsWithStartingAddressID()
        } else {
            self.accountIDTextField.text = nil
            self.enableButton(self.showAccountPublicKeyQRButton, enable: false)
            self.clearAddressFields()
        }
    }

    func didUpdateAccountPrivateKey(_ accountPrivateKey: String?) {
        if !accountPrivateKey!.isEmpty && TLHDWalletWrapper.isValidExtendedPrivateKey(accountPrivateKey!) {
            let accoundIdx = TLHDWalletWrapper.getAccountIdxForExtendedKey(accountPrivateKey!)
            self.accountIDTextField.text = String(accoundIdx)
            let accountPublicKey = TLHDWalletWrapper.getExtendPubKey(accountPrivateKey!)
            self.accountPublicKeyTextView.text = accountPublicKey
            self.enableButton(self.showAccountPrivateKeyQRButton, enable: true)
            self.enableButton(self.showAccountPublicKeyQRButton, enable: true)
            self.updateAccountPrivateKeyTextView(accountPrivateKey)
            self.updateAddressFieldsWithStartingAddressID()
        } else {
            self.accountIDTextField.text = nil
            self.accountPublicKeyTextView.text = nil
            self.updateAccountPublicKeyTextView(nil)
            self.enableButton(self.showAccountPrivateKeyQRButton, enable: false)
            self.enableButton(self.showAccountPublicKeyQRButton, enable: false)
            self.clearAddressFields()
        }
    }

    func updateAccountIDTextField(_ enable: Bool) {
        if enable {
            self.enableTextField(self.accountIDTextField, enable: true)
        } else {
            self.enableTextField(self.accountIDTextField, enable: false)
            self.accountIDTextField.text = nil
        }
    }
    
    func updateAccountPublicKeyTextView(_ extendedPublicKey: String?) {
        if extendedPublicKey == nil {
            self.enableButton(self.showAccountPublicKeyQRButton, enable: false)
            return
        }
        self.enableButton(self.showAccountPublicKeyQRButton, enable: true)
        
        // shrink text to fit textview
        var fontSize:CGFloat = (self.accountPublicKeyTextView.font?.pointSize)!
        self.accountPublicKeyTextView.font = self.accountPublicKeyTextView.font?.withSize(fontSize)
        while (self.accountPublicKeyTextView.contentSize.height > self.accountPublicKeyTextView.frame.size.height && fontSize > 8.0) {
            fontSize -= 1.0
            self.accountPublicKeyTextView.font = self.accountPublicKeyTextView.font?.withSize(fontSize)
        }
    }
    
    func updateAccountPrivateKeyTextView(_ extendedPrivateKey: String?) {
        if extendedPrivateKey == nil {
            self.enableButton(self.showAccountPrivateKeyQRButton, enable: false)
            return
        }
        self.enableButton(self.showAccountPrivateKeyQRButton, enable: true)
        
        // shrink text to fit textview
        var fontSize:CGFloat = (self.accountPrivateKeyTextView.font?.pointSize)!
        self.accountPrivateKeyTextView.font = self.accountPrivateKeyTextView.font?.withSize(fontSize)
        while (self.accountPrivateKeyTextView.contentSize.height > self.accountPrivateKeyTextView.frame.size.height && fontSize > 8.0) {
            fontSize -= 1.0
            self.accountPrivateKeyTextView.font = self.accountPrivateKeyTextView.font?.withSize(fontSize)
        }
    }

    func clearAddressFields() {
        self.clearReceivingAddressFields()
        self.clearChangeAddressFields()
    }

    func clearReceivingAddressFields() {
        self.enableTextField(self.startingAddressIDTextField, enable: false)
        
        self.enableButton(self.showAddressQRCodeButton1, enable: false)
        self.enableButton(self.showAddressQRCodeButton2, enable: false)
        self.enableButton(self.showAddressQRCodeButton3, enable: false)
        self.enableButton(self.showAddressQRCodeButton4, enable: false)
        self.enableButton(self.showAddressQRCodeButton5, enable: false)
        
        self.enableButton(self.showPrivateKeyQRCodeButton1, enable: false)
        self.enableButton(self.showPrivateKeyQRCodeButton2, enable: false)
        self.enableButton(self.showPrivateKeyQRCodeButton3, enable: false)
        self.enableButton(self.showPrivateKeyQRCodeButton4, enable: false)
        self.enableButton(self.showPrivateKeyQRCodeButton5, enable: false)
        
        self.enableTextField(self.addressTextField1, enable: false)
        self.enableTextField(self.addressTextField2, enable: false)
        self.enableTextField(self.addressTextField3, enable: false)
        self.enableTextField(self.addressTextField4, enable: false)
        self.enableTextField(self.addressTextField5, enable: false)
        
        self.enableTextField(self.privateKeyTextField1, enable: false)
        self.enableTextField(self.privateKeyTextField2, enable: false)
        self.enableTextField(self.privateKeyTextField3, enable: false)
        self.enableTextField(self.privateKeyTextField4, enable: false)
        self.enableTextField(self.privateKeyTextField5, enable: false)
        
        self.startingAddressIDTextField.text = nil
        
        self.privateKeyTextField1.text = nil
        self.addressTextField1.text = nil
        self.privateKeyTextField2.text = nil
        self.addressTextField2.text = nil
        self.privateKeyTextField3.text = nil
        self.addressTextField3.text = nil
        self.privateKeyTextField4.text = nil
        self.addressTextField4.text = nil
        self.privateKeyTextField5.text = nil
        self.addressTextField5.text = nil
    }

    func clearChangeAddressFields() {
        self.enableTextField(self.startingChangeAddressIDTextField, enable: false)
        
        self.enableButton(self.showChangeAddressQRCodeButton1, enable: false)
        self.enableButton(self.showChangeAddressQRCodeButton2, enable: false)
        self.enableButton(self.showChangeAddressQRCodeButton3, enable: false)
        self.enableButton(self.showChangeAddressQRCodeButton4, enable: false)
        self.enableButton(self.showChangeAddressQRCodeButton5, enable: false)
        
        self.enableButton(self.showChangePrivateKeyQRCodeButton1, enable: false)
        self.enableButton(self.showChangePrivateKeyQRCodeButton2, enable: false)
        self.enableButton(self.showChangePrivateKeyQRCodeButton3, enable: false)
        self.enableButton(self.showChangePrivateKeyQRCodeButton4, enable: false)
        self.enableButton(self.showChangePrivateKeyQRCodeButton5, enable: false)
        
        self.enableTextField(self.changeAddressTextField1, enable: false)
        self.enableTextField(self.changeAddressTextField2, enable: false)
        self.enableTextField(self.changeAddressTextField3, enable: false)
        self.enableTextField(self.changeAddressTextField4, enable: false)
        self.enableTextField(self.changeAddressTextField5, enable: false)
        
        self.enableTextField(self.changePrivateKeyTextField1, enable: false)
        self.enableTextField(self.changePrivateKeyTextField2, enable: false)
        self.enableTextField(self.changePrivateKeyTextField3, enable: false)
        self.enableTextField(self.changePrivateKeyTextField4, enable: false)
        self.enableTextField(self.changePrivateKeyTextField5, enable: false)
        
        self.startingAddressIDTextField.text = nil
        
        self.changePrivateKeyTextField1.text = nil
        self.changeAddressTextField1.text = nil
        self.changePrivateKeyTextField2.text = nil
        self.changeAddressTextField2.text = nil
        self.changePrivateKeyTextField3.text = nil
        self.changeAddressTextField3.text = nil
        self.changePrivateKeyTextField4.text = nil
        self.changeAddressTextField4.text = nil
        self.changePrivateKeyTextField5.text = nil
        self.changeAddressTextField5.text = nil
    }
    
    func updateAddressFieldsWithStartingAddressID(_ startingAddressID: Int? = nil) {
        var addressID:Int? = 0
        if startingAddressID == nil {
            addressID = Int(self.startingAddressIDTextField.text!)
            if addressID == nil {
                addressID = 0
            }
        } else {
            addressID = startingAddressID
        }
        updateAddressFields(addressID!)
    }

    func updateChangeAddressFieldsWithStartingAddressID(_ startingAddressID: Int? = nil) {
        var addressID:Int? = 0
        if startingAddressID == nil {
            addressID = Int(self.startingChangeAddressIDTextField.text!)
            if addressID == nil {
                addressID = 0
            }
        } else {
            addressID = startingAddressID
        }
        updateChangeAddressFields(addressID!)
    }
    
    func updateAddressFields(_ startingAddressID: Int) {
        var extendedPrivateKey:String? = nil
        var extendedPublicKey:String? = nil
        if self.coldWalletKeyType == .mnemonic {
            extendedPublicKey = self.accountPublicKeyTextView.text
            extendedPrivateKey = self.accountPrivateKeyTextView.text
        } else if self.coldWalletKeyType == .accountPublicKey {
            extendedPublicKey = self.accountPublicKeyTextView.text
        } else if self.coldWalletKeyType == .accountPrivateKey {
            extendedPublicKey = self.accountPublicKeyTextView.text
            extendedPrivateKey = self.accountPrivateKeyTextView.text
        }
        if extendedPublicKey != nil && TLHDWalletWrapper.isValidExtendedPublicKey(extendedPublicKey!)
            && (extendedPrivateKey == nil || extendedPrivateKey != nil && TLHDWalletWrapper.isValidExtendedPrivateKey(extendedPrivateKey!)) {
            self.enableTextField(self.startingAddressIDTextField, enable: true)

            var HDAddressIdx = startingAddressID
            let addressSequence1 = [Int(TLAddressType.main.rawValue), HDAddressIdx] as [Any]
            self.addressLabel1.text = "Address ID ".localized + String(HDAddressIdx) + ":"
            self.addressTextField1.text = TLHDWalletWrapper.getAddress(extendedPublicKey!, sequence: addressSequence1 as NSArray, isTestnet: isTestnet)
            HDAddressIdx += 1
            let addressSequence2 = [Int(TLAddressType.main.rawValue), HDAddressIdx]
            self.addressLabel2.text = "Address ID ".localized + String(HDAddressIdx) + ":"
            self.addressTextField2.text = TLHDWalletWrapper.getAddress(extendedPublicKey!, sequence: addressSequence2 as NSArray, isTestnet: isTestnet)
            HDAddressIdx += 1
            let addressSequence3 = [Int(TLAddressType.main.rawValue), HDAddressIdx]
            self.addressLabel3.text = "Address ID ".localized + String(HDAddressIdx) + ":"
            self.addressTextField3.text = TLHDWalletWrapper.getAddress(extendedPublicKey!, sequence: addressSequence3 as NSArray, isTestnet: isTestnet)
            HDAddressIdx += 1
            let addressSequence4 = [Int(TLAddressType.main.rawValue), HDAddressIdx]
            self.addressLabel4.text = "Address ID ".localized + String(HDAddressIdx) + ":"
            self.addressTextField4.text = TLHDWalletWrapper.getAddress(extendedPublicKey!, sequence: addressSequence4 as NSArray, isTestnet: isTestnet)
            HDAddressIdx += 1
            let addressSequence5 = [Int(TLAddressType.main.rawValue), HDAddressIdx]
            self.addressLabel5.text = "Address ID ".localized + String(HDAddressIdx) + ":"
            self.addressTextField5.text = TLHDWalletWrapper.getAddress(extendedPublicKey!, sequence: addressSequence5 as NSArray, isTestnet: isTestnet)

            self.enableButton(self.showAddressQRCodeButton1, enable: true)
            self.enableButton(self.showAddressQRCodeButton2, enable: true)
            self.enableButton(self.showAddressQRCodeButton3, enable: true)
            self.enableButton(self.showAddressQRCodeButton4, enable: true)
            self.enableButton(self.showAddressQRCodeButton5, enable: true)
            
            if extendedPrivateKey != nil {
                self.privateKeyTextField1.text = TLHDWalletWrapper.getPrivateKey(extendedPrivateKey! as NSString, sequence: addressSequence1 as NSArray, isTestnet: isTestnet)
                self.privateKeyTextField2.text = TLHDWalletWrapper.getPrivateKey(extendedPrivateKey! as NSString, sequence: addressSequence2 as NSArray, isTestnet: isTestnet)
                self.privateKeyTextField3.text = TLHDWalletWrapper.getPrivateKey(extendedPrivateKey! as NSString, sequence: addressSequence3 as NSArray, isTestnet: isTestnet)
                self.privateKeyTextField4.text = TLHDWalletWrapper.getPrivateKey(extendedPrivateKey! as NSString, sequence: addressSequence4 as NSArray, isTestnet: isTestnet)
                self.privateKeyTextField5.text = TLHDWalletWrapper.getPrivateKey(extendedPrivateKey! as NSString, sequence: addressSequence5 as NSArray, isTestnet: isTestnet)
                self.enableButton(self.showPrivateKeyQRCodeButton1, enable: true)
                self.enableButton(self.showPrivateKeyQRCodeButton2, enable: true)
                self.enableButton(self.showPrivateKeyQRCodeButton3, enable: true)
                self.enableButton(self.showPrivateKeyQRCodeButton4, enable: true)
                self.enableButton(self.showPrivateKeyQRCodeButton5, enable: true)
            } else {
                self.privateKeyTextField1.text = nil
                self.privateKeyTextField2.text = nil
                self.privateKeyTextField3.text = nil
                self.privateKeyTextField4.text = nil
                self.privateKeyTextField5.text = nil
                self.enableButton(self.showPrivateKeyQRCodeButton1, enable: false)
                self.enableButton(self.showPrivateKeyQRCodeButton2, enable: false)
                self.enableButton(self.showPrivateKeyQRCodeButton3, enable: false)
                self.enableButton(self.showPrivateKeyQRCodeButton4, enable: false)
                self.enableButton(self.showPrivateKeyQRCodeButton5, enable: false)
            }
        }
    }
    
    func updateChangeAddressFields(_ startingAddressID: Int) {
        var extendedPrivateKey:String? = nil
        var extendedPublicKey:String? = nil
        if self.coldWalletKeyType == .mnemonic {
            extendedPublicKey = self.accountPublicKeyTextView.text
            extendedPrivateKey = self.accountPrivateKeyTextView.text
        } else if self.coldWalletKeyType == .accountPublicKey {
            extendedPublicKey = self.accountPublicKeyTextView.text
        } else if self.coldWalletKeyType == .accountPrivateKey {
            extendedPublicKey = self.accountPublicKeyTextView.text
            extendedPrivateKey = self.accountPrivateKeyTextView.text
        }
        if extendedPublicKey != nil && TLHDWalletWrapper.isValidExtendedPublicKey(extendedPublicKey!)
            && (extendedPrivateKey == nil || extendedPrivateKey != nil && TLHDWalletWrapper.isValidExtendedPrivateKey(extendedPrivateKey!)) {
            self.enableTextField(self.startingChangeAddressIDTextField, enable: true)
            
            var HDAddressIdx = startingAddressID
            let addressSequence1 = [Int(TLAddressType.change.rawValue), HDAddressIdx] as [Any]
            self.changeAddressLabel1.text = "Change Address ID ".localized + String(HDAddressIdx) + ":"
            self.changeAddressTextField1.text = TLHDWalletWrapper.getAddress(extendedPublicKey!, sequence: addressSequence1 as NSArray, isTestnet: isTestnet)
            HDAddressIdx += 1
            let addressSequence2 = [Int(TLAddressType.change.rawValue), HDAddressIdx]
            self.changeAddressLabel2.text = "Change Address ID ".localized + String(HDAddressIdx) + ":"
            self.changeAddressTextField2.text = TLHDWalletWrapper.getAddress(extendedPublicKey!, sequence: addressSequence2 as NSArray, isTestnet: isTestnet)
            HDAddressIdx += 1
            let addressSequence3 = [Int(TLAddressType.change.rawValue), HDAddressIdx]
            self.changeAddressLabel3.text = "Change Address ID ".localized + String(HDAddressIdx) + ":"
            self.changeAddressTextField3.text = TLHDWalletWrapper.getAddress(extendedPublicKey!, sequence: addressSequence3 as NSArray, isTestnet: isTestnet)
            HDAddressIdx += 1
            let addressSequence4 = [Int(TLAddressType.change.rawValue), HDAddressIdx]
            self.changeAddressLabel4.text = "Change Address ID ".localized + String(HDAddressIdx) + ":"
            self.changeAddressTextField4.text = TLHDWalletWrapper.getAddress(extendedPublicKey!, sequence: addressSequence4 as NSArray, isTestnet: isTestnet)
            HDAddressIdx += 1
            let addressSequence5 = [Int(TLAddressType.change.rawValue), HDAddressIdx]
            self.changeAddressLabel5.text = "Change Address ID ".localized + String(HDAddressIdx) + ":"
            self.changeAddressTextField5.text = TLHDWalletWrapper.getAddress(extendedPublicKey!, sequence: addressSequence5 as NSArray, isTestnet: isTestnet)
            
            self.enableButton(self.showChangeAddressQRCodeButton1, enable: true)
            self.enableButton(self.showChangeAddressQRCodeButton2, enable: true)
            self.enableButton(self.showChangeAddressQRCodeButton3, enable: true)
            self.enableButton(self.showChangeAddressQRCodeButton4, enable: true)
            self.enableButton(self.showChangeAddressQRCodeButton5, enable: true)
            
            if extendedPrivateKey != nil {
                self.changePrivateKeyTextField1.text = TLHDWalletWrapper.getPrivateKey(extendedPrivateKey! as NSString, sequence: addressSequence1 as NSArray, isTestnet: isTestnet)
                self.changePrivateKeyTextField2.text = TLHDWalletWrapper.getPrivateKey(extendedPrivateKey! as NSString, sequence: addressSequence2 as NSArray, isTestnet: isTestnet)
                self.changePrivateKeyTextField3.text = TLHDWalletWrapper.getPrivateKey(extendedPrivateKey! as NSString, sequence: addressSequence3 as NSArray, isTestnet: isTestnet)
                self.changePrivateKeyTextField4.text = TLHDWalletWrapper.getPrivateKey(extendedPrivateKey! as NSString, sequence: addressSequence4 as NSArray, isTestnet: isTestnet)
                self.changePrivateKeyTextField5.text = TLHDWalletWrapper.getPrivateKey(extendedPrivateKey! as NSString, sequence: addressSequence5 as NSArray, isTestnet: isTestnet)
                self.enableButton(self.showChangePrivateKeyQRCodeButton1, enable: true)
                self.enableButton(self.showChangePrivateKeyQRCodeButton2, enable: true)
                self.enableButton(self.showChangePrivateKeyQRCodeButton3, enable: true)
                self.enableButton(self.showChangePrivateKeyQRCodeButton4, enable: true)
                self.enableButton(self.showChangePrivateKeyQRCodeButton5, enable: true)
            } else {
                self.changePrivateKeyTextField1.text = nil
                self.changePrivateKeyTextField2.text = nil
                self.changePrivateKeyTextField3.text = nil
                self.changePrivateKeyTextField4.text = nil
                self.changePrivateKeyTextField5.text = nil
                self.enableButton(self.showChangePrivateKeyQRCodeButton1, enable: false)
                self.enableButton(self.showChangePrivateKeyQRCodeButton2, enable: false)
                self.enableButton(self.showChangePrivateKeyQRCodeButton3, enable: false)
                self.enableButton(self.showChangePrivateKeyQRCodeButton4, enable: false)
                self.enableButton(self.showChangePrivateKeyQRCodeButton5, enable: false)
            }
        }
    }
    
    @IBAction fileprivate func newWalletButtonClicked(_ sender:UIButton) {
        if let mnemonicPassphrase = TLHDWalletWrapper.generateMnemonicPassphrase() {
            self.mnemonicTextView.text = mnemonicPassphrase
            self.didUpdateMnemonic(mnemonicPassphrase)
        }
    }
    
    @IBAction fileprivate func showAccountPublicKeyQRButtonClicked(_ sender:UIButton) {
        let accountPublicKey = self.accountPublicKeyTextView.text
        if accountPublicKey != nil && !accountPublicKey!.isEmpty && TLHDWalletWrapper.isValidExtendedPublicKey(accountPublicKey!) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: accountPublicKey!)
        }
    }
    
    @IBAction fileprivate func showAccountPrivateKeyQRButtonClicked(_ sender:UIButton) {
        let accountPrivateKey = self.accountPrivateKeyTextView.text
        if accountPrivateKey != nil && !accountPrivateKey!.isEmpty && TLHDWalletWrapper.isValidExtendedPrivateKey(accountPrivateKey!) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: accountPrivateKey!)
        }
    }
    
    
    @IBAction fileprivate func showAddressQRButtonClicked1(_ sender:UIButton) {
        let address = self.addressTextField1.text
        if address != nil && !address!.isEmpty && TLCoreBitcoinWrapper.isValidAddress(address!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: address!)
        }
    }
    
    @IBAction fileprivate func showPrivateKeyQRButtonClicked1(_ sender:UIButton) {
        let privateKey = self.privateKeyTextField1.text
        if privateKey != nil && !privateKey!.isEmpty && TLCoreBitcoinWrapper.isValidPrivateKey(privateKey!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: privateKey!)
        }
    }
    
    @IBAction fileprivate func showAddressQRButtonClicked2(_ sender:UIButton) {
        let address = self.addressTextField2.text
        if address != nil && !address!.isEmpty && TLCoreBitcoinWrapper.isValidAddress(address!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: address!)
        }
    }
    
    @IBAction fileprivate func showPrivateKeyQRButtonClicked2(_ sender:UIButton) {
        let privateKey = self.privateKeyTextField2.text
        if privateKey != nil && !privateKey!.isEmpty && TLCoreBitcoinWrapper.isValidPrivateKey(privateKey!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: privateKey!)
        }
    }
    
    @IBAction fileprivate func showAddressQRButtonClicked3(_ sender:UIButton) {
        let address = self.addressTextField3.text
        if address != nil && !address!.isEmpty && TLCoreBitcoinWrapper.isValidAddress(address!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: address!)
        }
    }
    
    @IBAction fileprivate func showPrivateKeyQRButtonClicked3(_ sender:UIButton) {
        let privateKey = self.privateKeyTextField3.text
        if privateKey != nil && !privateKey!.isEmpty && TLCoreBitcoinWrapper.isValidPrivateKey(privateKey!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: privateKey!)
        }
    }
    
    @IBAction fileprivate func showAddressQRButtonClicked4(_ sender:UIButton) {
        let address = self.addressTextField4.text
        if address != nil && !address!.isEmpty && TLCoreBitcoinWrapper.isValidAddress(address!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: address!)
        }
    }
    
    @IBAction fileprivate func showPrivateKeyQRButtonClicked4(_ sender:UIButton) {
        let privateKey = self.privateKeyTextField4.text
        if privateKey != nil && !privateKey!.isEmpty && TLCoreBitcoinWrapper.isValidPrivateKey(privateKey!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: privateKey!)
        }
    }
    
    @IBAction fileprivate func showAddressQRButtonClicked5(_ sender:UIButton) {
        let address = self.addressTextField5.text
        if address != nil && !address!.isEmpty && TLCoreBitcoinWrapper.isValidAddress(address!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: address!)
        }
    }
    
    @IBAction fileprivate func showPrivateKeyQRButtonClicked5(_ sender:UIButton) {
        let privateKey = self.privateKeyTextField5.text
        if privateKey != nil && !privateKey!.isEmpty && TLCoreBitcoinWrapper.isValidPrivateKey(privateKey!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: privateKey!)
        }
    }
    
    
    
    @IBAction fileprivate func showChangeAddressQRButtonClicked1(_ sender:UIButton) {
        let address = self.changeAddressTextField1.text
        if address != nil && !address!.isEmpty && TLCoreBitcoinWrapper.isValidAddress(address!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: address!)
        }
    }
    
    @IBAction fileprivate func showChangePrivateKeyQRButtonClicked1(_ sender:UIButton) {
        let privateKey = self.changePrivateKeyTextField1.text
        if privateKey != nil && !privateKey!.isEmpty && TLCoreBitcoinWrapper.isValidPrivateKey(privateKey!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: privateKey!)
        }
    }
    
    @IBAction fileprivate func showChangeAddressQRButtonClicked2(_ sender:UIButton) {
        let address = self.changeAddressTextField2.text
        if address != nil && !address!.isEmpty && TLCoreBitcoinWrapper.isValidAddress(address!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: address!)
        }
    }
    
    @IBAction fileprivate func showChangePrivateKeyQRButtonClicked2(_ sender:UIButton) {
        let privateKey = self.changePrivateKeyTextField2.text
        if privateKey != nil && !privateKey!.isEmpty && TLCoreBitcoinWrapper.isValidPrivateKey(privateKey!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: privateKey!)
        }
    }
    
    @IBAction fileprivate func showChangeAddressQRButtonClicked3(_ sender:UIButton) {
        let address = self.changeAddressTextField3.text
        if address != nil && !address!.isEmpty && TLCoreBitcoinWrapper.isValidAddress(address!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: address!)
        }
    }
    
    @IBAction fileprivate func showChangePrivateKeyQRButtonClicked3(_ sender:UIButton) {
        let privateKey = self.changePrivateKeyTextField3.text
        if privateKey != nil && !privateKey!.isEmpty && TLCoreBitcoinWrapper.isValidPrivateKey(privateKey!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: privateKey!)
        }
    }
    
    @IBAction fileprivate func showChangeAddressQRButtonClicked4(_ sender:UIButton) {
        let address = self.changeAddressTextField4.text
        if address != nil && !address!.isEmpty && TLCoreBitcoinWrapper.isValidAddress(address!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: address!)
        }
    }
    
    @IBAction fileprivate func showChangePrivateKeyQRButtonClicked4(_ sender:UIButton) {
        let privateKey = self.changePrivateKeyTextField4.text
        if privateKey != nil && !privateKey!.isEmpty && TLCoreBitcoinWrapper.isValidPrivateKey(privateKey!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: privateKey!)
        }
    }
    
    @IBAction fileprivate func showChangeAddressQRButtonClicked5(_ sender:UIButton) {
        let address = self.changeAddressTextField5.text
        if address != nil && !address!.isEmpty && TLCoreBitcoinWrapper.isValidAddress(address!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: address!)
        }
    }
    
    @IBAction fileprivate func showChangePrivateKeyQRButtonClicked5(_ sender:UIButton) {
        let privateKey = self.changePrivateKeyTextField5.text
        if privateKey != nil && !privateKey!.isEmpty && TLCoreBitcoinWrapper.isValidPrivateKey(privateKey!, isTestnet: isTestnet) {
            delegate?.didAdvancedNewWalletClickShowQRCodeButton(self, data: privateKey!)
        }
    }
}
