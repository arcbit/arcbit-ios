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
        button.setTitle(TLDisplayStrings.STATUS_STRING(), for: UIControlState())
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
                cancelButtonTitle: TLDisplayStrings.CANCEL_STRING(),
                otherButtonTitles: TLDisplayStrings.OK_STRING())
            av.show()
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }

    func showEmailSupportViewController() {
        let mc = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(String(format: "%@ iOS Support", TLWalletUtils.APP_NAME()))
        let message = "Dear ArcBit Support,\n\n\n\n--\nApp Version: \(TLPreferences .getAppVersion())\nSystem: \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)\n"
        DLog(message);
        mc.setMessageBody(message, isHTML: false)
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
                vc.navigationItem.title = TLDisplayStrings.ARCBIT_WEB_WALLET_STRING()
                vc.text = TLDisplayStrings.ARCBIT_WEB_WALLET_DESC_STRING()
            } else if (self.selectedSection == "brainwallet") {
                let vc = segue.destination as! TLTextViewViewController
                vc.navigationItem.title = TLDisplayStrings.ARCBIT_BRAIN_WALLET_STRING()
                vc.text = TLDisplayStrings.ARCBIT_BRAIN_WALLET_STRING_DESC_STRING()
            }
        }
    }
    
    @IBAction fileprivate func menuButtonClicked(_ sender:UIButton) -> () {
        self.slidingViewController().anchorTopViewToRight(animated: true)
    }
    
    func numberOfSections(in tableView:UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        if section == 0 {
            return TLDisplayStrings.ARCBIT_WEB_WALLET_STRING()
        } else if section == 1 {
            return TLDisplayStrings.ARCBIT_BRAIN_WALLET_STRING()
        } else if section == 2 {
            return TLDisplayStrings.ARCBIT_ANDROID_WALLET_STRING()
        } else if section == 3 {
            return TLDisplayStrings.OTHER_LINKS_STRING()
        } else {
            return TLDisplayStrings.EMAIL_SUPPORT_STRING()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        if section == 0 || section == 1 {
            return 2
        } else if section == 2 {
            return 1
        } else if section == 3 {
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
                cell!.textLabel?.text = TLDisplayStrings.CHECK_OUT_THE_ARCBIT_WEB_WALLET_STRING()
            } else {
                cell!.textLabel?.text = TLDisplayStrings.VIEW_ARCBIT_WEB_WALLET_DETAILS_STRING()
            }
        } else if (indexPath as NSIndexPath).section == 1 {
            if (indexPath as NSIndexPath).row == 0 {
                cell!.textLabel?.text = TLDisplayStrings.CHECK_OUT_THE_ARCBIT_BRAIN_WALLET_STRING()
            } else {
                cell!.textLabel?.text = TLDisplayStrings.VIEW_ARCBIT_BRAIN_WALLET_DETAILS_STRING()
            }
        } else if (indexPath as NSIndexPath).section == 2 {
            cell!.textLabel?.text = TLDisplayStrings.CHECK_OUT_THE_ARCBIT_ANDROID_WALLET_STRING()
        } else if (indexPath as NSIndexPath).section == 3 {
            if (indexPath as NSIndexPath).row == 0 {
                cell!.imageView?.image = UIImage(named: "home3")
                cell!.textLabel?.text = TLDisplayStrings.VISIT_OUR_HOME_PAGE_STRING()
            } else {
                cell!.imageView?.image = UIImage(named: "twitter")
                cell!.textLabel?.text = TLDisplayStrings.FOLLOW_US_ON_TWITTER_STRING()
            }
        } else {
            cell!.accessoryType = UITableViewCellAccessoryType.none
            cell!.imageView?.image = UIImage(named: "lifebuoy")
            cell!.textLabel?.text = TLDisplayStrings.EMAIL_SUPPORT_STRING()
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
            let url = URL(string: "https://play.google.com/store/apps/details?id=com.arcbit.arcbit&hl=en");
            if (UIApplication.shared.canOpenURL(url!)) {
                UIApplication.shared.openURL(url!);
            }
        } else if((indexPath as NSIndexPath).section == 3) {
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
