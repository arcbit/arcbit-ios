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
    
    struct STATIC_MEMBERS {
        static let kWebWalletSection = "kColdWalletSection"
        static let kBrainSection = "kBrainSection"
        static let kOthersSection = "kOthersSection"
        static let kEmailSupportSection = "kEmailSupportSection"
    }
    
    @IBOutlet fileprivate var linksTableView:UITableView?
    fileprivate var action:NSString?
    fileprivate var clickRightBarButtonCount:Int = 0
    fileprivate var selectedSection:String = ""
    fileprivate lazy var sectionArray = Array<String>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        setLogoImageView()
        
        //self.sectionArray = [STATIC_MEMBERS.kWebWalletSection, STATIC_MEMBERS.kBrainSection, STATIC_MEMBERS.kOthersSection, STATIC_MEMBERS.kEmailSupportSection]
        self.sectionArray = [STATIC_MEMBERS.kWebWalletSection, STATIC_MEMBERS.kOthersSection, STATIC_MEMBERS.kEmailSupportSection]

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
//            TLStealthWebSocket.instance().isWebSocketOpen()
//            let av = UIAlertView(title: "Web Socket Server status",
//                message: "Up: \(TLStealthWebSocket.instance().isWebSocketOpen())",
//                delegate: nil,
//                cancelButtonTitle: TLDisplayStrings.CANCEL_STRING(),
//                otherButtonTitles: TLDisplayStrings.OK_STRING())
//            av.show()
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
        return self.sectionArray.count
    }
    
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        let sectionType = self.sectionArray[section]
        if sectionType == STATIC_MEMBERS.kWebWalletSection {
            return TLDisplayStrings.ARCBIT_WEB_WALLET_STRING()
        } else if sectionType == STATIC_MEMBERS.kBrainSection {
            return TLDisplayStrings.ARCBIT_BRAIN_WALLET_STRING()
        } else if sectionType == STATIC_MEMBERS.kOthersSection {
            return TLDisplayStrings.OTHER_LINKS_STRING()
        } else {
            return TLDisplayStrings.EMAIL_SUPPORT_STRING()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        let sectionType = self.sectionArray[section]
        if sectionType == STATIC_MEMBERS.kWebWalletSection ||
            sectionType == STATIC_MEMBERS.kBrainSection ||
            sectionType == STATIC_MEMBERS.kOthersSection {
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
        
        let sectionType = self.sectionArray[indexPath.section]
        if sectionType == STATIC_MEMBERS.kWebWalletSection {
            if (indexPath as NSIndexPath).row == 0 {
                cell!.textLabel?.text = TLDisplayStrings.CHECK_OUT_THE_ARCBIT_WEB_WALLET_STRING()
            } else {
                cell!.textLabel?.text = TLDisplayStrings.VIEW_ARCBIT_WEB_WALLET_DETAILS_STRING()
            }
        } else if sectionType == STATIC_MEMBERS.kBrainSection {
            if (indexPath as NSIndexPath).row == 0 {
                cell!.textLabel?.text = TLDisplayStrings.CHECK_OUT_THE_ARCBIT_BRAIN_WALLET_STRING()
            } else {
                cell!.textLabel?.text = TLDisplayStrings.VIEW_ARCBIT_BRAIN_WALLET_DETAILS_STRING()
            }
        } else if sectionType == STATIC_MEMBERS.kOthersSection {
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
        let sectionType = self.sectionArray[indexPath.section]
        if sectionType == STATIC_MEMBERS.kWebWalletSection {
            self.selectedSection = "webwallet"
            if (indexPath as NSIndexPath).row == 0 {
                let url = URL(string: "https://chrome.google.com/webstore/detail/arcbit-bitcoin-wallet/dkceiphcnbfahjbomhpdgjmphnpgogfk");
                if (UIApplication.shared.canOpenURL(url!)) {
                    UIApplication.shared.openURL(url!);
                }
            } else {
                performSegue(withIdentifier: "SegueText2", sender:self)
            }
        } else if sectionType == STATIC_MEMBERS.kBrainSection {
            self.selectedSection = "brainwallet"
            if (indexPath as NSIndexPath).row == 0 {
                let url = URL(string: "https://www.arcbitbrainwallet.com");
                if (UIApplication.shared.canOpenURL(url!)) {
                    UIApplication.shared.openURL(url!);
                }
            } else {
                performSegue(withIdentifier: "SegueText2", sender:self)
            }
        } else if sectionType == STATIC_MEMBERS.kOthersSection {
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
