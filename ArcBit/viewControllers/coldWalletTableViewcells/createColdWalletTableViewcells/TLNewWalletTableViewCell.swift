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
    func didClickShowQRCodeButton(cell: TLNewWalletTableViewCell, data: String)
}

@objc(TLNewWalletTableViewCell) class TLNewWalletTableViewCell:UITableViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet var mnemonicLabel:UILabel!
    @IBOutlet var mnemonicTextView:UITextView!
    @IBOutlet var newWalletButton:UIButton!
    @IBOutlet var accountIDTextField: UITextField!
    @IBOutlet var accountPublicKeyTextView:UITextView!
    @IBOutlet var showAccountPublicKeyQRButton:UIButton!
    var delegate: TLNewWalletTableViewCellDelegate?
    
    override init(style:UITableViewCellStyle, reuseIdentifier:String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mnemonicTextView.layer.borderWidth = 1.0
        self.mnemonicTextView.layer.borderColor = UIColor.blackColor().CGColor
        self.mnemonicTextView.text = nil
        self.mnemonicTextView.autocorrectionType = UITextAutocorrectionType.No
        self.newWalletButton.backgroundColor = TLColors.mainAppColor()
        self.newWalletButton.setTitleColor(TLColors.mainAppOppositeColor(), forState:UIControlState.Normal)
        self.newWalletButton.titleLabel!.adjustsFontSizeToFitWidth = true
        self.accountIDTextField.keyboardType = UIKeyboardType.NumberPad
        self.accountIDTextField.autocorrectionType = UITextAutocorrectionType.No
        self.accountPublicKeyTextView.layer.borderWidth = 1.0
        self.accountPublicKeyTextView.alpha = 0.5
        self.accountPublicKeyTextView.text = nil
        self.accountPublicKeyTextView.userInteractionEnabled = false
        self.showAccountPublicKeyQRButton.backgroundColor = TLColors.mainAppColor()
        self.showAccountPublicKeyQRButton.setTitleColor(TLColors.mainAppOppositeColor(), forState:UIControlState.Normal)
    }
    
    class func cellHeight() -> CGFloat {
        return 287
    }
    
    @IBAction private func newWalletButtonClicked(sender:UIButton) {
        if let mnemonicPassphrase = TLHDWalletWrapper.generateMnemonicPassphrase() {
            self.mnemonicTextView.text = mnemonicPassphrase
            self.didUpdateMnemonic(mnemonicPassphrase)
        }
    }
    
    @IBAction private func showAccountPublicKeyQRButtonClicked(sender:UIButton) {
        let accountPublicKey = self.accountPublicKeyTextView.text
        if accountPublicKey != nil && !accountPublicKey.isEmpty && TLHDWalletWrapper.isValidExtendedPublicKey(accountPublicKey) {
            delegate?.didClickShowQRCodeButton(self, data: accountPublicKey!)
        }
    }
    
    func didUpdateMnemonic(mnemonicPassphrase: String) {
        let masterHex = TLHDWalletWrapper.getMasterHex(mnemonicPassphrase)
        if let accountID = UInt(self.accountIDTextField.text!) {
            let extendedPublicKey = TLHDWalletWrapper.getExtendPubKeyFromMasterHex(masterHex, accountIdx: accountID)
            self.updateAccountPublicKeyTextView(extendedPublicKey)
        } else {
            self.accountIDTextField.text = "0"
            let extendedPublicKey = TLHDWalletWrapper.getExtendPubKeyFromMasterHex(masterHex, accountIdx: 0)
            self.updateAccountPublicKeyTextView(extendedPublicKey)
        }
    }

    func updateAccountPublicKeyTextView(extendedPublicKey: String?) {
        if extendedPublicKey == nil {
            self.showAccountPublicKeyQRButton.enabled = false
            self.showAccountPublicKeyQRButton.alpha = 0.5
            self.accountPublicKeyTextView.text = nil
            return
        }
        self.showAccountPublicKeyQRButton.enabled = true
        self.showAccountPublicKeyQRButton.alpha = 1
        self.accountPublicKeyTextView.text = extendedPublicKey!
        
        // shrink text to fit textview
        var fontSize:CGFloat = (self.accountPublicKeyTextView.font?.pointSize)!
        self.accountPublicKeyTextView.font = self.accountPublicKeyTextView.font?.fontWithSize(fontSize)
        while (self.accountPublicKeyTextView.contentSize.height > self.accountPublicKeyTextView.frame.size.height && fontSize > 8.0) {
            fontSize -= 1.0
            self.accountPublicKeyTextView.font = self.accountPublicKeyTextView.font?.fontWithSize(fontSize)
        }
    }
}
