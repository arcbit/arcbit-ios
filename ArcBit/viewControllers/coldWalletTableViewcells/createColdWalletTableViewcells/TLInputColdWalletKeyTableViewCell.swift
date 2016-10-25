//
//  TLInputColdWalletKeyTableViewCell.swift
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


protocol TLInputColdWalletKeyTableViewCellDelegate {
    func didClickInputColdWalletKeyInfoButton(_ cell: TLInputColdWalletKeyTableViewCell)
}

@objc(TLInputColdWalletKeyTableViewCell) class TLInputColdWalletKeyTableViewCell:UITableViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet var keyInputTextView:UITextView!
    @IBOutlet var statusLabel: UILabel!
    var accountPublicKey: String?

    var delegate: TLInputColdWalletKeyTableViewCellDelegate?
    
    override init(style:UITableViewCellStyle, reuseIdentifier:String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.keyInputTextView.layer.borderWidth = 1.0
        self.keyInputTextView.layer.borderColor = UIColor.black.cgColor
        self.keyInputTextView.autocorrectionType = UITextAutocorrectionType.no
        self.keyInputTextView.text = nil
        self.setstatusLabel(false)
    }
    
    class func cellHeight() -> CGFloat {
        return 151
    }
    
    @IBAction fileprivate func infoButtonClicked(_ sender:UIButton) {
        delegate?.didClickInputColdWalletKeyInfoButton(self)
    }
    
    func setstatusLabel(_ complete:Bool) {
        if complete {
            statusLabel.textColor = UIColor.green
            statusLabel.text = "Complete".localized
        } else {
            statusLabel.textColor = UIColor.red
            statusLabel.text = "Incomplete".localized
        }
    }
}
