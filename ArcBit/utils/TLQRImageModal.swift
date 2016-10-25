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
    
    fileprivate let alertView:CustomIOS7AlertView
    let QRcodeDisplayData:String
    
    init(data:NSString, buttonCopyText:(String), vc:(UIViewController)) {
        QRcodeDisplayData = data as String
        
        let QR_CODE_IMAGE_DIMENSION_IPHONE = CGFloat(300.0)
        let QR_CODE_IMAGE_DIMENSION_IPAD = CGFloat(450.0)
        
        let DATA_LABEL_HEIGHT_IPHONE = CGFloat(60.0)
        let DATA_LABEL_HEIGHT_IPAD = CGFloat(120.0)
        
        let QRCodeImageDimension:CGFloat
        let dataLabelHeight:CGFloat
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            QRCodeImageDimension = QR_CODE_IMAGE_DIMENSION_IPHONE
            dataLabelHeight = DATA_LABEL_HEIGHT_IPHONE
        } else {
            QRCodeImageDimension = QR_CODE_IMAGE_DIMENSION_IPAD
            dataLabelHeight = DATA_LABEL_HEIGHT_IPAD
        }
        
        let containerView = UIView(frame:CGRect(x: 0, y: 0,
            width: QRCodeImageDimension,
            height: QRCodeImageDimension+dataLabelHeight))
        
        
        let QRCodeImage = TLWalletUtils.getQRCodeImage(data as String, imageDimension:Int(QRCodeImageDimension))
        let qrCodeImageView = UIImageView(frame: CGRect(x: 0, y: 0,
            width: QRCodeImageDimension,
            height: QRCodeImageDimension))
        qrCodeImageView.image = QRCodeImage
        
        containerView.addSubview(qrCodeImageView)
        
        alertView = CustomIOS7AlertView()
        
        let titleLabel = UITextView(frame:CGRect(x: 0, y: QRCodeImageDimension, width: QRCodeImageDimension, height: dataLabelHeight))
        titleLabel.text = data as String
        titleLabel.textAlignment = .center
        
        titleLabel.isUserInteractionEnabled = false
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
        } else if (vc is TLCreateColdWalletViewController) {
            alertView.delegate = vc as! TLCreateColdWalletViewController
        } else if (vc is TLSpendColdWalletViewController) {
            alertView.delegate = vc as! TLSpendColdWalletViewController
        } else if (vc is TLBrainWalletViewController) {
            alertView.delegate = vc as! TLBrainWalletViewController
        } else if (vc is TLReviewPaymentViewController) {
            alertView.delegate = vc as! TLReviewPaymentViewController
        }
    }
    
    func show() -> () {
        alertView.show()
        NotificationCenter.default.addObserver(self, selector:#selector(TLQRImageModal.dismissDialog(_:)), name:NSNotification.Name.UIApplicationDidEnterBackground, object:nil)
    }
    
    func dismissDialog(_ notification: Notification) -> () {
        for subview in alertView.dialogView.subviews {
            if (subview is UIButton) {
                let button = subview as! UIButton
                if (button.titleLabel!.text == STATIC_MEMBERS.DISMISS_TEXT) {
                    button.sendActions(for: .touchUpInside)
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIApplicationDidEnterBackground, object:nil)
    }
}
