//
//  TLAddressTableViewCell.swift
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

@objc(TLAddressTableViewCell) class TLAddressTableViewCell:UITableViewCell {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet var addressLabel : UILabel?
    @IBOutlet var numberOfTransactionsCountLabel : UILabel?
    @IBOutlet var amountButton : UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.amountButton!.backgroundColor = TLColors.mainAppColor()
        self.amountButton!.setTitleColor(TLColors.mainAppOppositeColor(), forState:UIControlState.Normal)
        self.amountButton!.titleLabel!.adjustsFontSizeToFitWidth = true
    }
    
    override func setSelected(selected:Bool, animated:Bool) -> () {
        super.setSelected(selected, animated:animated)
    }
    
    @IBAction private func amountButtonClicked(sender:UIButton) {
        TLPreferences.setDisplayLocalCurrency(!TLPreferences.isDisplayLocalCurrency())
        TLPreferences.setInAppSettingsKitDisplayLocalCurrency(TLPreferences.isDisplayLocalCurrency())
    }
}