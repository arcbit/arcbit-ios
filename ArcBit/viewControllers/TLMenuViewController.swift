//
//  TLMenuViewController.swift
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
@objc(TLMenuViewController) class TLMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var menuItems:NSArray?
    @IBOutlet private var menuTopView:UIView?
    @IBOutlet private var tableView:UITableView?

    // This is used so that status bar text color is set to white
    override func preferredStatusBarStyle() -> (UIStatusBarStyle) {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        self.menuTopView!.backgroundColor = TLColors.mainAppColor()
        self.tableView!.backgroundColor = TLColors.mainAppColor()
        self.tableView!.separatorInset = UIEdgeInsetsZero
        menuItems = ["Send".localized, "Receive".localized, "History".localized, "Accounts".localized, "Help".localized, "Links".localized, "Settings".localized]
    }
    
    override func viewDidAppear(animated:Bool) -> () {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation:UIStatusBarAnimation.None)
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_HAMBURGER_MENU_OPENED(),
            object:nil)
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated:Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation:UIStatusBarAnimation.None)
        self.view.endEditing(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return menuItems!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell{
        let MyIdentifier = "MenuCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier) 
        if (cell == nil) {
            cell = UITableViewCell(style:UITableViewCellStyle.Default,
                reuseIdentifier:MyIdentifier)
        }
        
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        
        let menuItem = menuItems![indexPath.row] as! String
        
        cell!.textLabel!.text = menuItem
        cell!.backgroundColor = UIColor.clearColor()
        
        var imageName = ""
        var name = ""
        
        
        switch (indexPath.row) {
        case 0:
            imageName = TLWalletUtils.SEND_ICON_IMAGE_NAME()
            name = "Send".localized
            break
        case 1:
            imageName = TLWalletUtils.RECEIVE_ICON_IMAGE_NAME()
            name = "Receive".localized
            break
        case 2:
            imageName = TLWalletUtils.HISTORY_ICON_IMAGE_NAME()
            name = "History".localized
            break
        case 3:
            imageName = TLWalletUtils.ACCOUNT_ICON_IMAGE_NAME()
            name = "Accounts".localized
            break
        case 4:
            imageName = TLWalletUtils.HELP_ICON_IMAGE_NAME()
            name = "Help".localized
            break
        case 5:
            imageName = TLWalletUtils.LINK_ICON_IMAGE_NAME()
            name = "More".localized
            break
        default:
            imageName = TLWalletUtils.SETTINGS_ICON_IMAGE_NAME()
            name = "Settings".localized
            break
        }
        cell!.textLabel!.text = name
        cell!.textLabel!.textColor = TLColors.mainAppOppositeColor()
        
        cell!.imageView!.image = UIImage(named: imageName)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell!.imageView!.tintColor = TLColors.mainAppOppositeColor()
        
        return cell!
    }
    
    func tableView(tableView:UITableView, heightForHeaderInSection section:Int) -> CGFloat {
        return 30.0
    }

    func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) -> () {
        if (indexPath.row == 0) {
            self.slidingViewController().topViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SendNav") 
        } else if (indexPath.row == 1) {
            self.slidingViewController().topViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ReceiveNav")  
        } else if (indexPath.row == 2) {
            self.slidingViewController().topViewController = self.storyboard!.instantiateViewControllerWithIdentifier("HistoryNav")  
        } else if (indexPath.row == 3) {
            self.slidingViewController().topViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ManageAccountNav")  
        } else if (indexPath.row == 4) {
            self.slidingViewController().topViewController = self.storyboard!.instantiateViewControllerWithIdentifier("HelpNav")  
        } else if (indexPath.row == 5) {
            self.slidingViewController().topViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LinksNav")
        } else {
            self.slidingViewController().topViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SettingsNav")  
        }
        
        self.slidingViewController().resetTopViewAnimated(true)
    }
}
