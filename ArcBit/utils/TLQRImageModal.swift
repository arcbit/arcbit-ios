//
//  TLQRImageModal.swift
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

@objc class TLQRImageModal:NSObject {
    struct STATIC_MEMBERS {
        static var DISMISS_TEXT = "Dismiss".localized
    }
    
    private let alertView:CustomIOS7AlertView
    let QRcodeDisplayData:String
    
    init(data:NSString, buttonCopyText:(String), vc:(UIViewController)) {
        QRcodeDisplayData = data as String
        
        let QR_CODE_IMAGE_DIMENSION_IPHONE = CGFloat(300.0)
        let QR_CODE_IMAGE_DIMENSION_IPAD = CGFloat(450.0)
        
        let DATA_LABEL_HEIGHT_IPHONE = CGFloat(60.0)
        let DATA_LABEL_HEIGHT_IPAD = CGFloat(120.0)
        
        let QRCodeImageDimension:CGFloat
        let dataLabelHeight:CGFloat
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            QRCodeImageDimension = QR_CODE_IMAGE_DIMENSION_IPHONE
            dataLabelHeight = DATA_LABEL_HEIGHT_IPHONE
        } else {
            QRCodeImageDimension = QR_CODE_IMAGE_DIMENSION_IPAD
            dataLabelHeight = DATA_LABEL_HEIGHT_IPAD
        }
        
        let containerView = UIView(frame:CGRectMake(0, 0,
            QRCodeImageDimension,
            QRCodeImageDimension+dataLabelHeight))
        
        
        let QRCodeImage = TLWalletUtils.getQRCodeImage(data as String, imageDimension:Int(QRCodeImageDimension))
        let qrCodeImageView = UIImageView(frame: CGRectMake(0, 0,
            QRCodeImageDimension,
            QRCodeImageDimension))
        qrCodeImageView.image = QRCodeImage
        
        containerView.addSubview(qrCodeImageView)
        
        alertView = CustomIOS7AlertView()
        
        let titleLabel = UITextView(frame:CGRectMake(0, QRCodeImageDimension, QRCodeImageDimension, dataLabelHeight))
        titleLabel.text = data as String
        titleLabel.textAlignment = .Center
        
        titleLabel.userInteractionEnabled = false
        titleLabel.backgroundColor = TLColors.mainAppColor()
        titleLabel.textColor = TLColors.mainAppOppositeColor()
        titleLabel.layer.cornerRadius = 5.0
        
        containerView.addSubview(titleLabel)
        
        alertView.containerView = containerView
        alertView.buttonTitles = [buttonCopyText, STATIC_MEMBERS.DISMISS_TEXT]
        
        //TODO: refactor, find cleaner way to do this
        if (vc is TLManageAccountsViewController) {
            alertView.delegate = vc as! TLManageAccountsViewController
        } else if (vc is TLAddressListViewController) {
            alertView.delegate = vc as! TLAddressListViewController
        }
    }
    
    func show() -> () {
        alertView.show()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"dismissDialog:", name:UIApplicationDidEnterBackgroundNotification, object:nil)
    }
    
    func dismissDialog(notification: NSNotification) -> () {
        for subview in alertView.dialogView.subviews as! [UIView] {
            if (subview is UIButton) {
                let button = subview as! UIButton
                if (button.titleLabel!.text == STATIC_MEMBERS.DISMISS_TEXT) {
                    button.sendActionsForControlEvents(.TouchUpInside)
                }
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIApplicationDidEnterBackgroundNotification, object:nil)
    }
}
