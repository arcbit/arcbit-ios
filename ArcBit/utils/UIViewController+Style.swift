//
//  UIViewController+Style.swift
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

extension UIViewController
{
    public func setLogoImageView() -> () {
        let image = UIImage(named:"360X80logo.png")
        let imageView = UIImageView(frame:CGRect(x: 0, y: 0, width: 180, height: 40))
        
        imageView.contentMode = UIViewContentMode.scaleToFill
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.image = image
        imageView.backgroundColor = TLColors.mainAppColor()
        navigationItem.titleView = imageView
        
        // Add dummy rightBarButtonItem so that self.navigationItem.titleView does not extend to far to the right
        let dummyBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        
        navigationItem.rightBarButtonItem = dummyBarButtonItem
        // work around to hide rightBarButtonItem
        navigationItem.rightBarButtonItem!.tintColor = TLColors.mainAppColor()
    }

    public func setColors() -> () {
        if(navigationController != nil)
        {
            navigationController!.navigationBar.fixedHeightWhenStatusBarHidden = true
            
            navigationController!.navigationBar.barTintColor = TLColors.mainAppColor()
            navigationController!.navigationBar.tintColor = TLColors.mainAppOppositeColor()
            navigationController!.navigationBar.isTranslucent = false
            navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: TLColors.mainAppOppositeColor()]
            
            navigationController!.navigationItem.rightBarButtonItem = nil
        }
        if self.slidingViewController() != nil {
            slidingViewController().topViewController.view.layer.shadowOpacity = 0.75
            slidingViewController().topViewController.view.layer.shadowRadius = 10.0
            slidingViewController().topViewController.view.layer.shadowColor = UIColor.black.cgColor
        }
    }
    
    public func setNavigationBarColors(_ navigationBar:UINavigationBar) -> () {
        navigationBar.barTintColor = TLColors.mainAppColor()
        navigationBar.tintColor = TLColors.mainAppOppositeColor()
        navigationBar.isTranslucent = false
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: TLColors.mainAppOppositeColor()]
        navigationBar.barTintColor = TLColors.mainAppColor()
        view.backgroundColor = TLColors.mainAppColor()
    }
}
