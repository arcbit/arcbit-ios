//
//  TLLinksViewController.m
//  ArcBit
//
//  Created by Tim Lee on 3/18/15.
//  Copyright (c) 2015 ArcBit. All rights reserved.
//


//
//  TLLinksViewController.swift
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

@objc(TLLinksViewController) class TLLinksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet private var linksTableView:UITableView?
    private var eventActionArray:NSArray?
    private var eventAdvanceActionArray:NSArray?
    private var FAQArray:NSArray?
    private var advancedFAQArray:NSArray?
    private var instructions:NSArray?
    private var action:NSString?
    private var FAQText:NSString?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        setLogoImageView()
        
        eventActionArray = TLHelpDoc.getEventsArray()
        eventAdvanceActionArray = TLHelpDoc.getAdvanceEventsArray()
        FAQArray = TLHelpDoc.getFAQArray()
        advancedFAQArray = TLHelpDoc.getAdvanceFAQArray()
        
        self.navigationController!.view.addGestureRecognizer(self.slidingViewController().panGesture)
        
        self.linksTableView!.delegate = self
        self.linksTableView!.dataSource = self
        self.linksTableView!.tableFooterView = UIView(frame:CGRectZero)
    }
    
    func showEmailSupportViewController() {
        let mc = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(String(format: "%@ iOS Support".localized, TLWalletUtils.APP_NAME()))
        let message = "Dear ArcBit Support,\n\n\n\n--\nApp Version: \(TLPreferences .getAppVersion())\nSystem: \(UIDevice.currentDevice().systemName) \(UIDevice.currentDevice().systemVersion)\n"
        DLog(message);
        mc.setMessageBody(message.localized, isHTML: false)
        mc.setToRecipients(["support@arcbit.zendesk.com"])
        self.presentViewController(mc, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated:Bool) -> () {
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_HELP_SCREEN(),
            object:nil)
    }
    
    override func didReceiveMemoryWarning() -> () {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender:AnyObject!) -> () {
        if (segue.identifier == "SegueText2") {
            let vc = segue.destinationViewController as! TLTextViewViewController
            vc.navigationItem.title = "ArcBit Web Wallet".localized
            let detail1 = "\tArcBit Web Wallet is a Chrome extension. It has all the features of the mobile wallet plus more. Highlights include the ability to create multiple wallets instead of just one, and a new non-cumbersome way to generate wallets, store and spend bitcoins all from cold storage! ArcBit's new way to manage your cold storage bitcoins also offers a more compelling reason to use ArcBit's watch only account feature. Now you can safely watch the balance of your cold storage bitcoins by enabling advance mode in ArcBit and importing your cold storage account public keys.\n".localized
            let detail2 = "\tUse ArcBit Web Wallet in whatever way you wish. You can create a new wallet, or you can input your current 12 word backup passphrase to manage the same bitcoins across different devices. Check out the ArcBit Web Wallet in the Chrome Web Store for more details!\n".localized
            vc.text = detail1 + "\n" + detail2
        }
    }
    
    @IBAction private func menuButtonClicked(sender:UIButton) -> () {
        self.slidingViewController().anchorTopViewToRightAnimated(true)
    }
    
    func numberOfSectionsInTableView(tableView:UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        if section == 0 {
            return "ArcBit Web Wallet".localized
        } else if section == 1 {
            return "Other Links".localized
        } else {
            return "Email Support".localized
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell{
        let MyIdentifier = "LinksCellIdentifier"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(style:UITableViewCellStyle.Default,
                reuseIdentifier:MyIdentifier)
        }
        cell!.textLabel!.numberOfLines = 0
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell!.textLabel?.text = "Check out the ArcBit Web Wallet".localized
            } else {
                cell!.textLabel!.text = "View ArcBit Web Wallet Details".localized
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell!.imageView?.image = UIImage(named: "home3")
                cell!.textLabel?.text = "Visit our home page".localized
            } else {
                cell!.imageView?.image = UIImage(named: "twitter")
                cell!.textLabel?.text = "Follow us on Twitter".localized
            }
        } else {
            cell!.accessoryType = UITableViewCellAccessoryType.None
            cell!.imageView?.image = UIImage(named: "lifebuoy")
            cell!.textLabel?.text = "Email Support".localized
        }

        return cell!
    }
    
    func tableView(tableView:UITableView, willSelectRowAtIndexPath indexPath:NSIndexPath) -> NSIndexPath? {
        if(indexPath.section == 0) {
            if indexPath.row == 0 {
                let url = NSURL(string: "https://chrome.google.com/webstore/detail/walmart/bmelcnhnemihidpaehodijpamdaeeglh"); //TODO
                if (UIApplication.sharedApplication().canOpenURL(url!)) {
                    UIApplication.sharedApplication().openURL(url!);
                }
            } else {
                performSegueWithIdentifier("SegueText2", sender:self)
            }
        } else if(indexPath.section == 1) {
            if indexPath.row == 0 {
                let url = NSURL(string: "http://arcbit.io/");
                if (UIApplication.sharedApplication().canOpenURL(url!)) {
                    UIApplication.sharedApplication().openURL(url!);
                }
            } else {
                let url = NSURL(string: "https://twitter.com/arc_bit");
                if (UIApplication.sharedApplication().canOpenURL(url!)) {
                    UIApplication.sharedApplication().openURL(url!);
                }
            }
        } else {
            self.showEmailSupportViewController()
        }
        
        return nil
    }
}
