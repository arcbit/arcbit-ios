//
//  TLHUDWrapper.swift
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

@objc class TLHUDWrapper {
    struct STATIC_MEMBERS {
        static var LOADING_BACKGROUND_VIEW_TAG = 618033
        static var BACKGROUND_VIEW_ALPHA = 0.7
    }
    
    class func showHUDAddedTo(view:UIView, labelText:String, animated:Bool) -> () {
        var subView = UIView(frame: view.frame)
        subView.backgroundColor = UIColor.blackColor()
        subView.alpha = CGFloat(STATIC_MEMBERS.BACKGROUND_VIEW_ALPHA)
        subView.tag = STATIC_MEMBERS.LOADING_BACKGROUND_VIEW_TAG
        
        AppDelegate.instance().window!.addSubview(subView)
        
        var hud = MBProgressHUD.showHUDAddedTo(AppDelegate.instance().window, animated:animated)
        hud.labelText = labelText
    }
    
    class func hideHUDForView(view:UIView, animated:(Bool)) -> () {
        MBProgressHUD.hideHUDForView(AppDelegate.instance().window, animated:true)
        
        for subview in AppDelegate.instance().window!.subviews as! [UIView] {
            if (subview.tag == STATIC_MEMBERS.LOADING_BACKGROUND_VIEW_TAG) {
                subview.removeFromSuperview()
                break
            }
        }
    }
}