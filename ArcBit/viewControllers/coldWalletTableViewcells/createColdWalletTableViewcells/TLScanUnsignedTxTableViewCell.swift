//
//  TLScanUnsignedTxTableViewCell.swift
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


protocol TLScanUnsignedTxTableViewCellDelegate {
    func didClickScanButton(cell: TLScanUnsignedTxTableViewCell)
    func didClickScanUnsignedTxInfoButton(cell: TLScanUnsignedTxTableViewCell)
}

@objc(TLScanUnsignedTxTableViewCell) class TLScanUnsignedTxTableViewCell:UITableViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet var scanButtonButton:UIButton!
    @IBOutlet var statusLabel: UILabel!

    var delegate: TLScanUnsignedTxTableViewCellDelegate?
    
    override init(style:UITableViewCellStyle, reuseIdentifier:String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.scanButtonButton.backgroundColor = TLColors.mainAppColor()
        self.scanButtonButton.setTitleColor(TLColors.mainAppOppositeColor(), forState:UIControlState.Normal)
        self.setstatusLabel(false)
    }
    
    class func cellHeight() -> CGFloat {
        return 88
    }
    
    @IBAction private func infoButtonClicked(sender:UIButton) {
        delegate?.didClickScanUnsignedTxInfoButton(self)
    }
    
    @IBAction private func scanButtonClicked(sender:UIButton) {
        delegate?.didClickScanButton(self)
    }
    
    func setstatusLabel(complete:Bool) {
        if complete {
            statusLabel.textColor = UIColor.greenColor()
            statusLabel.text = "Complete".localized
        } else {
            statusLabel.textColor = UIColor.redColor()
            statusLabel.text = "Incomplete".localized
        }
    }
}
