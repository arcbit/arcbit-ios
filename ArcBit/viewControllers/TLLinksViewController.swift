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
    
    @IBOutlet fileprivate var linksTableView:UITableView?
    fileprivate var eventActionArray:NSArray?
    fileprivate var eventAdvanceActionArray:NSArray?
    fileprivate var FAQArray:NSArray?
    fileprivate var advancedFAQArray:NSArray?
    fileprivate var instructions:NSArray?
    fileprivate var action:NSString?
    fileprivate var FAQText:NSString?
    fileprivate var clickRightBarButtonCount:Int = 0
    fileprivate var selectedSection:String = ""

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
        self.linksTableView!.tableFooterView = UIView(frame:CGRect.zero)
        self.clickRightBarButtonCount = 0
        
        let button   = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        button.backgroundColor = TLColors.mainAppColor()
        button.setTitle("Status", for: UIControlState())
        button.setTitleColor(TLColors.mainAppColor(), for: UIControlState())
        button.addTarget(self, action: #selector(TLLinksViewController.rightBarButtonClicked), for: UIControlEvents.touchUpInside)
        let rightBarButtonItem = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func rightBarButtonClicked() {
        self.clickRightBarButtonCount += 1
        if (self.clickRightBarButtonCount >= 10) {
            TLStealthWebSocket.instance().isWebSocketOpen()
            let av = UIAlertView(title: "Web Socket Server status",
                message: "Up: \(TLStealthWebSocket.instance().isWebSocketOpen())",
                delegate: nil,
                cancelButtonTitle: "Cancel".localized,
                otherButtonTitles: "OK".localized)
            av.show()
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }

    func showEmailSupportViewController() {
        let mc = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(String(format: "%@ iOS Support".localized, TLWalletUtils.APP_NAME()))
        let message = "Dear ArcBit Support,\n\n\n\n--\nApp Version: \(TLPreferences .getAppVersion())\nSystem: \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)\n"
        DLog(message);
        mc.setMessageBody(message.localized, isHTML: false)
        mc.setToRecipients(["support@arcbit.zendesk.com"])
        self.present(mc, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated:Bool) -> () {
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_HELP_SCREEN()),
            object:nil)
    }
    
    override func didReceiveMemoryWarning() -> () {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any!) -> () {
        if (segue.identifier == "SegueText2") {
            if (self.selectedSection == "webwallet") {
                let vc = segue.destination as! TLTextViewViewController
                vc.navigationItem.title = "ArcBit Web Wallet".localized
                let detail1 = "\tArcBit Web Wallet is a Chrome extension. It has all the features of the mobile wallet plus more. Highlights include the ability to create multiple wallets instead of just one, and a new non-cumbersome way to generate wallets, store and spend bitcoins all from cold storage! ArcBit's new way to manage your cold storage bitcoins also offers a more compelling reason to use ArcBit's watch only account feature. Now you can safely watch the balance of your cold storage bitcoins by enabling advance mode in ArcBit and importing your cold storage account public keys.\n".localized
                let detail2 = "\tUse ArcBit Web Wallet in whatever way you wish. You can create a new wallet, or you can input your current 12 word backup passphrase to manage the same bitcoins across different devices. Check out the ArcBit Web Wallet in the Chrome Web Store for more details!\n".localized
                vc.text = detail1 + "\n" + detail2
            } else if (self.selectedSection == "brainwallet") {
                let vc = segue.destination as! TLTextViewViewController
                vc.navigationItem.title = "ArcBit Brain Wallet".localized
                let detail1 = "\tWith the Arcbit Brain Wallet you can safely spend your bitcoins without ever having your private keys be exposed to the internet. It can be use in conjuction with your Arcbit Wallet or as a stand alone wallet. Visit the link in the previous sceen and then checkout the overview section to see how easy it is to use the ArcBit Brain Wallet.\n".localized
                vc.text = detail1 + "\n"
            }
        }
    }
    
    @IBAction fileprivate func menuButtonClicked(_ sender:UIButton) -> () {
        self.slidingViewController().anchorTopViewToRight(animated: true)
    }
    
    func numberOfSections(in tableView:UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        if section == 0 {
            return "ArcBit Web Wallet".localized
        } else if section == 1 {
            return "ArcBit Brain Wallet".localized
        } else if section == 2 {
            return "Other Links".localized
        } else {
            return "Email Support".localized
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        if section == 0 || section == 1 {
            return 2
        } else if section == 2 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        let MyIdentifier = "LinksCellIdentifier"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(style:UITableViewCellStyle.default,
                reuseIdentifier:MyIdentifier)
        }
        cell!.textLabel!.numberOfLines = 0
        
        if (indexPath as NSIndexPath).section == 0 {
            if (indexPath as NSIndexPath).row == 0 {
                cell!.textLabel?.text = "Check out the ArcBit Web Wallet".localized
            } else {
                cell!.textLabel!.text = "View ArcBit Web Wallet Details".localized
            }
        } else if (indexPath as NSIndexPath).section == 1 {
            if (indexPath as NSIndexPath).row == 0 {
                cell!.textLabel?.text = "Check out the ArcBit Brain Wallet".localized
            } else {
                cell!.textLabel!.text = "View ArcBit Brain Wallet Details".localized
            }
        } else if (indexPath as NSIndexPath).section == 2 {
            if (indexPath as NSIndexPath).row == 0 {
                cell!.imageView?.image = UIImage(named: "home3")
                cell!.textLabel?.text = "Visit our home page".localized
            } else {
                cell!.imageView?.image = UIImage(named: "twitter")
                cell!.textLabel?.text = "Follow us on Twitter".localized
            }
        } else {
            cell!.accessoryType = UITableViewCellAccessoryType.none
            cell!.imageView?.image = UIImage(named: "lifebuoy")
            cell!.textLabel?.text = "Email Support".localized
        }

        return cell!
    }
    
    func tableView(_ tableView:UITableView, willSelectRowAt indexPath:IndexPath) -> IndexPath? {
        if((indexPath as NSIndexPath).section == 0) {
            if (indexPath as NSIndexPath).row == 0 {
                self.selectedSection = "webwallet"
                let url = URL(string: "https://chrome.google.com/webstore/detail/arcbit-bitcoin-wallet/dkceiphcnbfahjbomhpdgjmphnpgogfk");
                if (UIApplication.shared.canOpenURL(url!)) {
                    UIApplication.shared.openURL(url!);
                }
            } else {
                performSegue(withIdentifier: "SegueText2", sender:self)
            }
        } else if((indexPath as NSIndexPath).section == 1) {
            self.selectedSection = "brainwallet"
            if (indexPath as NSIndexPath).row == 0 {
                let url = URL(string: "https://www.arcbitbrainwallet.com");
                if (UIApplication.shared.canOpenURL(url!)) {
                    UIApplication.shared.openURL(url!);
                }
            } else {
                performSegue(withIdentifier: "SegueText2", sender:self)
            }
        } else if((indexPath as NSIndexPath).section == 2) {
            if (indexPath as NSIndexPath).row == 0 {
                let url = URL(string: "http://arcbit.io/");
                if (UIApplication.shared.canOpenURL(url!)) {
                    UIApplication.shared.openURL(url!);
                }
            } else {
                let url = URL(string: "https://twitter.com/arc_bit");
                if (UIApplication.shared.canOpenURL(url!)) {
                    UIApplication.shared.openURL(url!);
                }
            }
        } else {
            self.showEmailSupportViewController()
        }
        
        return nil
    }
}
