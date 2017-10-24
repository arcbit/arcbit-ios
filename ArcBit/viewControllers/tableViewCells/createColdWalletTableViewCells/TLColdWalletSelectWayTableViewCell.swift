//
//  TLColdWalletSelectKeyTypeTableViewCell.swift
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

enum TLColdWalletKeyType:Int {
    case mnemonic = 0
    case accountPrivateKey = 1
    case accountPublicKey = 2
}

protocol TLColdWalletSelectKeyTypeTableViewCellDelegate {
    func didSelectColdWalletKeyType(_ cell: TLColdWalletSelectKeyTypeTableViewCell, keyType: TLColdWalletKeyType)
}

@objc(TLColdWalletSelectKeyTypeTableViewCell) class TLColdWalletSelectKeyTypeTableViewCell:UITableViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBOutlet var coldWalletSelectSegmentedControl:UISegmentedControl!
    var delegate: TLColdWalletSelectKeyTypeTableViewCellDelegate?
    
    override init(style:UITableViewCellStyle, reuseIdentifier:String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let attr:NSDictionary
        if UIScreen.main.bounds.size.width <= 320 {
            attr = NSDictionary(object: UIFont(name: "HelveticaNeue", size: 10.0)!, forKey: NSFontAttributeName as NSCopying)
        } else {
            attr = NSDictionary(object: UIFont(name: "HelveticaNeue", size: 12.0)!, forKey: NSFontAttributeName as NSCopying)
        }
        self.coldWalletSelectSegmentedControl.setTitleTextAttributes(attr as! [AnyHashable: Any] , for: UIControlState())
     
        self.coldWalletSelectSegmentedControl.setTitle(TLDisplayStrings.BACK_UP_PASSPHRASE_STRING(), forSegmentAt: 0)
        self.coldWalletSelectSegmentedControl.setTitle(TLDisplayStrings.ACCOUNT_PRIVATE_KEY_STRING(), forSegmentAt: 1)
        self.coldWalletSelectSegmentedControl.setTitle(TLDisplayStrings.ACCOUNT_PUBLIC_KEY_STRING(), forSegmentAt: 2)
    }
    
    class func cellHeight() -> CGFloat {
        return 61
    }
    
    @IBAction func coldWalletKeyTypeValueChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        delegate?.didSelectColdWalletKeyType(self, keyType: TLColdWalletKeyType(rawValue: selectedIndex)!)
    }
}
