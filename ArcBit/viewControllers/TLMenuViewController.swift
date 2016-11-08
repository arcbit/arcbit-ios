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
    
    fileprivate var menuItems:NSArray?
    @IBOutlet fileprivate var menuTopView:UIView?
    @IBOutlet fileprivate var tableView:UITableView?

    // This is used so that status bar text color is set to white
    override var preferredStatusBarStyle : (UIStatusBarStyle) {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        self.menuTopView!.backgroundColor = TLColors.mainAppColor()
        self.tableView!.backgroundColor = TLColors.mainAppColor()
        self.tableView!.separatorInset = UIEdgeInsets.zero
    }
    
    override func viewDidAppear(_ animated:Bool) -> () {
        super.viewDidAppear(animated)
        UIApplication.shared.setStatusBarHidden(true, with:UIStatusBarAnimation.none)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_HAMBURGER_MENU_OPENED()),
            object:nil)
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        if TLPreferences.enabledColdWallet() {
            menuItems = ["Send".localized, "Receive".localized, "History".localized, "Accounts".localized, "Cold Wallet".localized, "Help".localized, "Links".localized, "Settings".localized]
        } else {
            menuItems = ["Send".localized, "Receive".localized, "History".localized, "Accounts".localized, "Help".localized, "Links".localized, "Settings".localized]
        }
        self.tableView!.reloadData()
    }
    
    override func viewWillDisappear(_ animated:Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarHidden(false, with:UIStatusBarAnimation.none)
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return menuItems!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        let MyIdentifier = "MenuCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) 
        if (cell == nil) {
            cell = UITableViewCell(style:UITableViewCellStyle.default,
                reuseIdentifier:MyIdentifier)
        }
        
        cell!.selectionStyle = UITableViewCellSelectionStyle.none
        
        let menuItem = menuItems![(indexPath as NSIndexPath).row] as! String
        
        cell!.textLabel!.text = menuItem
        cell!.backgroundColor = UIColor.clear
        
        var imageName = ""
        var name = ""
        
        
        if TLPreferences.enabledColdWallet() {
            switch ((indexPath as NSIndexPath).row) {
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
                imageName = TLWalletUtils.VAULT_ICON_IMAGE_NAME()
                name = "Cold Wallet".localized
                break
            case 5:
                imageName = TLWalletUtils.HELP_ICON_IMAGE_NAME()
                name = "Help".localized
                break
            case 6:
                imageName = TLWalletUtils.LINK_ICON_IMAGE_NAME()
                name = "More".localized
                break
            default:
                imageName = TLWalletUtils.SETTINGS_ICON_IMAGE_NAME()
                name = "Settings".localized
                break
            }
        } else {
            switch ((indexPath as NSIndexPath).row) {
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
        }

        cell!.textLabel!.text = name
        cell!.textLabel!.textColor = TLColors.mainAppOppositeColor()
        
        cell!.imageView!.image = UIImage(named: imageName)!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell!.imageView!.tintColor = TLColors.mainAppOppositeColor()
        
        return cell!
    }
    
    func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int) -> CGFloat {
        return 30.0
    }

    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath) -> () {
        if TLPreferences.enabledColdWallet() {
            if ((indexPath as NSIndexPath).row == 0) {
                self.slidingViewController().topViewController = self.storyboard!.instantiateViewController(withIdentifier: "SendNav")
            } else if ((indexPath as NSIndexPath).row == 1) {
                self.slidingViewController().topViewController = self.storyboard!.instantiateViewController(withIdentifier: "ReceiveNav")
            } else if ((indexPath as NSIndexPath).row == 2) {
                self.slidingViewController().topViewController = self.storyboard!.instantiateViewController(withIdentifier: "HistoryNav")
            } else if ((indexPath as NSIndexPath).row == 3) {
                self.slidingViewController().topViewController = self.storyboard!.instantiateViewController(withIdentifier: "ManageAccountNav")
            } else if ((indexPath as NSIndexPath).row == 4) {
                self.slidingViewController().topViewController = self.storyboard!.instantiateViewController(withIdentifier: "ColdWalletNav")
            } else if ((indexPath as NSIndexPath).row == 5) {
                self.slidingViewController().topViewController = self.storyboard!.instantiateViewController(withIdentifier: "HelpNav")
            } else if ((indexPath as NSIndexPath).row == 6) {
                self.slidingViewController().topViewController = self.storyboard!.instantiateViewController(withIdentifier: "LinksNav")
            } else {
                self.slidingViewController().topViewController = self.storyboard!.instantiateViewController(withIdentifier: "SettingsNav")
            }
        } else {
            if ((indexPath as NSIndexPath).row == 0) {
                self.slidingViewController().topViewController = self.storyboard!.instantiateViewController(withIdentifier: "SendNav")
            } else if ((indexPath as NSIndexPath).row == 1) {
                self.slidingViewController().topViewController = self.storyboard!.instantiateViewController(withIdentifier: "ReceiveNav")
            } else if ((indexPath as NSIndexPath).row == 2) {
                self.slidingViewController().topViewController = self.storyboard!.instantiateViewController(withIdentifier: "HistoryNav")
            } else if ((indexPath as NSIndexPath).row == 3) {
                self.slidingViewController().topViewController = self.storyboard!.instantiateViewController(withIdentifier: "ManageAccountNav")
            } else if ((indexPath as NSIndexPath).row == 4) {
                self.slidingViewController().topViewController = self.storyboard!.instantiateViewController(withIdentifier: "HelpNav")
            } else if ((indexPath as NSIndexPath).row == 5) {
                self.slidingViewController().topViewController = self.storyboard!.instantiateViewController(withIdentifier: "LinksNav")
            } else {
                self.slidingViewController().topViewController = self.storyboard!.instantiateViewController(withIdentifier: "SettingsNav")
            }
        }
        
        self.slidingViewController().resetTopView(animated: true)
    }
}
