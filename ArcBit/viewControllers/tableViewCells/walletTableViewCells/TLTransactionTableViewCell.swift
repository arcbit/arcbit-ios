//
//  TLTransactionTableViewCell.swift
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


@objc(TLTransactionTableViewCell) class TLTransactionTableViewCell:UITableViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet var dateLabel:UILabel?
    @IBOutlet var currencyLabel:UILabel?
    @IBOutlet var amountLabel:UILabel?
    @IBOutlet var descriptionLabel:UILabel?
    @IBOutlet var confirmationsLabel:UILabel?
    @IBOutlet var amountButton:UIButton?
    @IBOutlet var confirmedStatusImageView:UIImageView?
    
    @IBAction fileprivate func amountButtonClicked(_ sender:UIButton) {
        TLPreferences.setDisplayLocalCurrency(!TLPreferences.isDisplayLocalCurrency())
        TLPreferences.setInAppSettingsKitDisplayLocalCurrency(TLPreferences.isDisplayLocalCurrency())
    }
    
    override init(style:UITableViewCellStyle, reuseIdentifier:String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.amountButton!.backgroundColor = TLColors.mainAppColor()
        self.amountButton!.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
        self.amountButton!.titleLabel!.adjustsFontSizeToFitWidth = true
    }
        
    override func setSelected(_ selected:Bool, animated:Bool) -> () {
        super.setSelected(selected, animated:animated)
    }
}
