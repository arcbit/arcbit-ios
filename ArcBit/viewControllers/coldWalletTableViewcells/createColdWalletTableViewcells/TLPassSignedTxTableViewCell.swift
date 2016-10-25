//
//  TLPassSignedTxTableViewCell.swift
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


protocol TLPassSignedTxTableViewCellDelegate {
    func didClickPassButton(_ cell: TLPassSignedTxTableViewCell)
    func didClickPassSignedTxInfoButton(_ cell: TLPassSignedTxTableViewCell)
}

@objc(TLPassSignedTxTableViewCell) class TLPassSignedTxTableViewCell:UITableViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet var passButtonButton:UIButton!
    
    var delegate: TLPassSignedTxTableViewCellDelegate?
    
    override init(style:UITableViewCellStyle, reuseIdentifier:String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.passButtonButton.backgroundColor = TLColors.mainAppColor()
        self.passButtonButton.setTitleColor(TLColors.mainAppOppositeColor(), for:UIControlState())
    }
    
    class func cellHeight() -> CGFloat {
        return 88
    }
    
    @IBAction fileprivate func infoButtonClicked(_ sender:UIButton) {
        delegate?.didClickPassSignedTxInfoButton(self)
    }
    
    @IBAction fileprivate func passButtonClicked(_ sender:UIButton) {
        delegate?.didClickPassButton(self)
    }
}
