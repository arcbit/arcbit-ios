//
//  TLColdWalletViewController.m
//  ArcBit
//
//  Created by Tim Lee on 3/18/15.
//  Copyright (c) 2015 ArcBit. All rights reserved.
//


//
//  TLColdWalletViewController.swift
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

@objc(TLColdWalletViewController) class TLColdWalletViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    struct STATIC_MEMBERS {
        static let kColdWalletSection = "kColdWalletSection"
        static let kColdWalletCreateRow = "kColdWalletCreateRow"
        static let kColdWalletSpendtRow = "kColdWalletSpendtRow"

        static let kSeeHDWalletDataSection = "kSeeHDWalletDataSection"
        static let kSeeHDWalletDataRow = "kSeeHDWalletDataRow"
    }
    
    private var sectionArray: Array<String>?
    private var coldWalletRowArray: Array<String>?
    private var seeHDWalletDataRowArray: Array<String>?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet private var coldWalletTableView:UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        setLogoImageView()
        
        self.navigationController!.view.addGestureRecognizer(self.slidingViewController().panGesture)
        
        if (TLPreferences.enabledAdvancedMode()) {
            self.sectionArray = [STATIC_MEMBERS.kColdWalletSection, STATIC_MEMBERS.kSeeHDWalletDataSection]
        } else {
            self.sectionArray = [STATIC_MEMBERS.kColdWalletSection]
        }
        self.coldWalletRowArray = [STATIC_MEMBERS.kColdWalletCreateRow, STATIC_MEMBERS.kColdWalletSpendtRow]
        self.seeHDWalletDataRowArray = [STATIC_MEMBERS.kSeeHDWalletDataRow]

        
        self.coldWalletTableView!.delegate = self
        self.coldWalletTableView!.dataSource = self
        self.coldWalletTableView!.tableFooterView = UIView(frame:CGRectZero)
    }
    
    override func viewDidAppear(animated:Bool) -> () {
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_COLD_WALLET_SCREEN(),
            object:nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender:AnyObject!) -> () {
        if (segue.identifier == "SegueCreateColdWallet") {
            let vc = segue.destinationViewController
            vc.navigationItem.title = "Create".localized
        } else if (segue.identifier == "SegueSpendColdWallet") {
            let vc = segue.destinationViewController
            vc.navigationItem.title = "Spend".localized
        } else if (segue.identifier == "SegueSpendColdWallet") {
            let vc = segue.destinationViewController
            vc.navigationItem.title = "".localized
        }
    }
    
    @IBAction private func menuButtonClicked(sender:UIButton) -> () {
        self.slidingViewController().anchorTopViewToRightAnimated(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        let sectionType = self.sectionArray![section]
        if(sectionType == STATIC_MEMBERS.kColdWalletSection) {
            return self.coldWalletRowArray!.count
        } else if(sectionType == STATIC_MEMBERS.kSeeHDWalletDataSection) {
            return self.seeHDWalletDataRowArray!.count
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView:UITableView) -> Int {
        return self.sectionArray!.count
    }
    
    func tableView(tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        let sectionType = self.sectionArray![section]
        if(sectionType == STATIC_MEMBERS.kColdWalletSection) {
            return "Cold Wallet".localized
        } else if(sectionType == STATIC_MEMBERS.kSeeHDWalletDataSection) {
            return "See Internal Wallet Data (Advanced)".localized
        }
        return "".localized
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell{
        let MyIdentifier = "ColdWalletCellIdentifier"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(style:UITableViewCellStyle.Default,
                reuseIdentifier:MyIdentifier)
        }
        let sectionType = self.sectionArray![indexPath.section]
        if(sectionType == STATIC_MEMBERS.kColdWalletSection) {
            let row = self.coldWalletRowArray![indexPath.row]
            if row == STATIC_MEMBERS.kColdWalletCreateRow {
                cell!.textLabel!.text = "Create Cold Wallet".localized
            } else if row == STATIC_MEMBERS.kColdWalletSpendtRow {
                cell!.textLabel!.text = "Spend From Cold Wallet Account".localized
            }
        } else if(sectionType == STATIC_MEMBERS.kSeeHDWalletDataSection) {
            let row = self.seeHDWalletDataRowArray![indexPath.row]
            if row == STATIC_MEMBERS.kSeeHDWalletDataRow {
                cell!.textLabel!.text = "See Internal Wallet Data".localized
            }
        }

        return cell!
    }
    
    func tableView(tableView:UITableView, willSelectRowAtIndexPath indexPath:NSIndexPath) -> NSIndexPath? {
        let sectionType = self.sectionArray![indexPath.section]
        if(sectionType == STATIC_MEMBERS.kColdWalletSection) {
            let row = self.coldWalletRowArray![indexPath.row]
            if row == STATIC_MEMBERS.kColdWalletCreateRow {
                performSegueWithIdentifier("SegueCreateColdWallet", sender:self)
            } else if row == STATIC_MEMBERS.kColdWalletSpendtRow {
                performSegueWithIdentifier("SegueSpendColdWallet", sender:self)
            }
        } else if(sectionType == STATIC_MEMBERS.kSeeHDWalletDataSection){
            let row = self.seeHDWalletDataRowArray![indexPath.row]
            if row == STATIC_MEMBERS.kSeeHDWalletDataRow {
                performSegueWithIdentifier("SegueSeeWalletData", sender:self)
            }
        }

        return nil
    }
}
