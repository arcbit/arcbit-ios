//
//  TLNewWalletTableViewCell.swift
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


protocol TLNewWalletTableViewCellDelegate {
    func didClickShowQRCodeButton(_ cell: TLNewWalletTableViewCell, data: String)
    func didClickMnemonicInfoButton(_ cell: TLNewWalletTableViewCell)
    func didClickAccountInfoButton(_ cell: TLNewWalletTableViewCell)
}

@objc(TLNewWalletTableViewCell) class TLNewWalletTableViewCell:UITableViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet var mnemonicLabel:UILabel!
    @IBOutlet var mnemonicTextView:UITextView!
    @IBOutlet var newWalletButton:UIButton!
    @IBOutlet weak var accountIDLabel: UILabel!
    @IBOutlet var accountIDTextField: UITextField!
    @IBOutlet weak var accountPublicKeyLabel: UILabel!
    @IBOutlet var accountPublicKeyTextView:UITextView!
    @IBOutlet var showAccountPublicKeyQRButton:UIButton!
    var delegate: TLNewWalletTableViewCellDelegate?
    lazy var currentCoinType = TLWalletUtils.DEFAULT_COIN_TYPE()

    override init(style:UITableViewCellStyle, reuseIdentifier:String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mnemonicLabel.text = TLDisplayStrings.BACK_UP_PASSPHRASE_STRING()+":"
        self.accountIDLabel.text = TLDisplayStrings.ACCOUNT_ID_STRING()+":"
        self.accountPublicKeyLabel.text = TLDisplayStrings.ACCOUNT_PUBLIC_KEY_STRING()+":"
        self.newWalletButton.setTitle(TLDisplayStrings.NEW_WALLET(), for: .normal)
        self.showAccountPublicKeyQRButton.setTitle(TLDisplayStrings.QR_CODE_STRING(), for: .normal)

        self.mnemonicTextView.layer.borderWidth = 1.0
        self.mnemonicTextView.layer.borderColor = UIColor.black.cgColor
        self.mnemonicTextView.text = nil
        self.mnemonicTextView.autocorrectionType = UITextAutocorrectionType.no
        self.mnemonicTextView.autocapitalizationType = .none
        self.newWalletButton.backgroundColor = TLColors.mainAppColor()
        self.newWalletButton.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.newWalletButton.titleLabel!.adjustsFontSizeToFitWidth = true
        self.accountIDTextField.keyboardType = UIKeyboardType.numberPad
        self.accountIDTextField.autocorrectionType = UITextAutocorrectionType.no
        self.accountPublicKeyTextView.layer.borderWidth = 1.0
        self.accountPublicKeyTextView.alpha = 0.5
        self.accountPublicKeyTextView.text = nil
        self.accountPublicKeyTextView.isUserInteractionEnabled = false
        self.showAccountPublicKeyQRButton.backgroundColor = TLColors.mainAppColor()
        self.showAccountPublicKeyQRButton.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.showAccountPublicKeyQRButton.alpha = 0.5
        self.showAccountPublicKeyQRButton.isEnabled = false
    }
    
    class func cellHeight() -> CGFloat {
        return 303
    }
    
    @IBAction func clickedMnemonicInfoButton(_ sender: AnyObject) {
        delegate?.didClickMnemonicInfoButton(self)
    }
    
    @IBAction func clickedAccountInfoButton(_ sender: AnyObject) {
        delegate?.didClickAccountInfoButton(self)
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
            delegate?.didClickShowQRCodeButton(self, data: accountPublicKey!)
        }
    }
    
    func didUpdateMnemonic(_ mnemonicPassphrase: String) {
        let masterHex = TLHDWalletWrapper.getMasterHex(mnemonicPassphrase)
        if let accountID = UInt(self.accountIDTextField.text!) {
            let extendedPublicKey = TLHDWalletWrapper.getExtendPubKeyFromMasterHex(self.currentCoinType, masterHex: masterHex, accountIdx: accountID)
            self.updateAccountPublicKeyTextView(extendedPublicKey)
        } else {
            self.accountIDTextField.text = "0"
            let extendedPublicKey = TLHDWalletWrapper.getExtendPubKeyFromMasterHex(self.currentCoinType, masterHex: masterHex, accountIdx: 0)
            self.updateAccountPublicKeyTextView(extendedPublicKey)
        }
    }

    func updateAccountPublicKeyTextView(_ extendedPublicKey: String?) {
        if extendedPublicKey == nil {
            self.showAccountPublicKeyQRButton.isEnabled = false
            self.showAccountPublicKeyQRButton.alpha = 0.5
            self.accountPublicKeyTextView.text = nil
            return
        }
        self.showAccountPublicKeyQRButton.isEnabled = true
        self.showAccountPublicKeyQRButton.alpha = 1
        self.accountPublicKeyTextView.text = extendedPublicKey!
        
        // shrink text to fit textview
        var fontSize:CGFloat = (self.accountPublicKeyTextView.font?.pointSize)!
        self.accountPublicKeyTextView.font = self.accountPublicKeyTextView.font?.withSize(fontSize)
        while (self.accountPublicKeyTextView.contentSize.height > self.accountPublicKeyTextView.frame.size.height && fontSize > 8.0) {
            fontSize -= 1.0
            self.accountPublicKeyTextView.font = self.accountPublicKeyTextView.font?.withSize(fontSize)
        }
    }
}
