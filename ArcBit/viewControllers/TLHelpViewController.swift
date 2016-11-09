//
//  TLHelpViewController.m
//  ArcBit
//
//  Created by Tim Lee on 3/18/15.
//  Copyright (c) 2015 ArcBit. All rights reserved.
//


//
//  TLHelpViewController.swift
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

@objc(TLHelpViewController) class TLHelpViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    struct STATIC_MEMBERS {
        static let kAchievementsSection = "kAchievementsSection"
        static let kFAQSection = "kFAQSection"
        static let kHowToSection = "kHowToSection"
        static let kAdvancedFAQSection = "kAdvancedFAQSection"
        static let kAdvancedHowToFAQSection = "kAdvancedHowToFAQSection"
    }
    
    @IBOutlet fileprivate var howToInstructionsTableView:UITableView?
    fileprivate var eventActionArray:NSArray?
    fileprivate var eventAdvanceActionArray:NSArray?
    fileprivate var FAQArray:NSArray?
    fileprivate var advancedFAQArray:NSArray?
    fileprivate var instructions:NSArray?
    fileprivate var action:NSString?
    fileprivate var FAQText:NSString?
    fileprivate var sectionArray: Array<String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        setLogoImageView()
        
        eventActionArray = TLHelpDoc.getEventsArray()
        eventAdvanceActionArray = TLHelpDoc.getAdvanceEventsArray()
        FAQArray = TLHelpDoc.getFAQArray()
        advancedFAQArray = TLHelpDoc.getAdvanceFAQArray()
        if (TLPreferences.enabledAdvancedMode()) {
            //self.sectionArray = [STATIC_MEMBERS.kAchievementsSection, STATIC_MEMBERS.kFAQSection, STATIC_MEMBERS.kHowToSection, STATIC_MEMBERS.kAdvancedFAQSection, STATIC_MEMBERS.kAdvancedHowToFAQSection]
            self.sectionArray = [STATIC_MEMBERS.kFAQSection, STATIC_MEMBERS.kHowToSection, STATIC_MEMBERS.kAdvancedFAQSection, STATIC_MEMBERS.kAdvancedHowToFAQSection]
        } else {
            //self.sectionArray = [STATIC_MEMBERS.kAchievementsSection, STATIC_MEMBERS.kFAQSection, STATIC_MEMBERS.kHowToSection]
            self.sectionArray = [STATIC_MEMBERS.kFAQSection, STATIC_MEMBERS.kHowToSection]
        }

        self.navigationController!.view.addGestureRecognizer(self.slidingViewController().panGesture)
        
        self.howToInstructionsTableView!.delegate = self
        self.howToInstructionsTableView!.dataSource = self
        self.howToInstructionsTableView!.tableFooterView = UIView(frame:CGRect.zero)
    }
    
    override func viewDidAppear(_ animated:Bool) -> () {
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_HELP_SCREEN()),
            object:nil)
    }
    
    override func didReceiveMemoryWarning() -> () {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any!) -> () {
        if (segue.identifier == "SegueAchievements") {
            let vc = segue.destination 
            vc.navigationItem.title = "Achievements".localized
        } else if (segue.identifier == "SegueText") {
            let vc = segue.destination as! TLTextViewViewController
            vc.navigationItem.title = "Explanation".localized
            vc.text = FAQText as? String
        } else if (segue.identifier == "SegueInstructions") {
            let vc = segue.destination as! TLInstructionsViewController
            vc.navigationItem.title = "Instructions".localized
            vc.action = action as? String
            vc.actionInstructionsSteps = instructions
        }
    }
    
    @IBAction fileprivate func menuButtonClicked(_ sender:UIButton) -> () {
        self.slidingViewController().anchorTopViewToRight(animated: true)
    }
    
    func numberOfSections(in tableView:UITableView) -> Int {
        return self.sectionArray!.count
    }
    
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        let sectionType = self.sectionArray![section]
        if(sectionType == STATIC_MEMBERS.kAchievementsSection) {
            return "Achievements".localized
        } else if(sectionType == STATIC_MEMBERS.kFAQSection) {
            return "FAQ".localized
        } else if(sectionType == STATIC_MEMBERS.kHowToSection) {
            return "How To:".localized
        } else if(sectionType == STATIC_MEMBERS.kAdvancedFAQSection) {
            return "Advance FAQ".localized
        } else if(sectionType == STATIC_MEMBERS.kAdvancedHowToFAQSection) {
            return "Advance how To:".localized
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        let sectionType = self.sectionArray![section]
        if(sectionType == STATIC_MEMBERS.kAchievementsSection) {
            return 1
        } else if(sectionType == STATIC_MEMBERS.kFAQSection) {
            return FAQArray!.count
        } else if(sectionType == STATIC_MEMBERS.kHowToSection) {
            return eventActionArray!.count
        } else if(sectionType == STATIC_MEMBERS.kAdvancedFAQSection) {
            return advancedFAQArray!.count
        } else if(sectionType == STATIC_MEMBERS.kAdvancedHowToFAQSection) {
            return eventAdvanceActionArray!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        let MyIdentifier = "HowToCellIdentifier"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) 
        if (cell == nil) {
            cell = UITableViewCell(style:UITableViewCellStyle.default,
                reuseIdentifier:MyIdentifier)
        }
        cell!.textLabel!.numberOfLines = 0
        let sectionType = self.sectionArray![(indexPath as NSIndexPath).section]
        if(sectionType == STATIC_MEMBERS.kAchievementsSection) {
            cell!.textLabel!.text = "View Achievements".localized
        } else if(sectionType == STATIC_MEMBERS.kFAQSection) {
            cell!.textLabel!.text = FAQArray!.object(at: (indexPath as NSIndexPath).row) as? String
        } else if(sectionType == STATIC_MEMBERS.kHowToSection) {
            cell!.textLabel!.text = TLHelpDoc.getActionEventToHowToActionTitleDict().object(forKey: eventActionArray!.object(at: (indexPath as NSIndexPath).row) as! String) as? String
        } else if(sectionType == STATIC_MEMBERS.kAdvancedFAQSection) {
            cell!.textLabel!.text = advancedFAQArray!.object(at: (indexPath as NSIndexPath).row) as? String
        } else if(sectionType == STATIC_MEMBERS.kAdvancedHowToFAQSection) {
            cell!.textLabel!.text = TLHelpDoc.getActionEventToHowToActionTitleDict().object(forKey: eventAdvanceActionArray!.object(at: (indexPath as NSIndexPath).row) as! String) as? String
        }
        
        if ((indexPath as NSIndexPath).row % 2 == 0) {
            cell!.backgroundColor = TLColors.evenTableViewCellColor()
        } else {
            cell!.backgroundColor = TLColors.oddTableViewCellColor()
        }
        
        return cell!
    }
    
    func tableView(_ tableView:UITableView, willSelectRowAt indexPath:IndexPath) -> IndexPath? {
        let sectionType = self.sectionArray![(indexPath as NSIndexPath).section]
        if(sectionType == STATIC_MEMBERS.kAchievementsSection) {
            performSegue(withIdentifier: "SegueAchievements", sender:self)
        } else if(sectionType == STATIC_MEMBERS.kFAQSection) {
            FAQText = TLHelpDoc.getExplanation((indexPath as NSIndexPath).row) as NSString?
            performSegue(withIdentifier: "SegueText", sender:self)
        } else if(sectionType == STATIC_MEMBERS.kHowToSection) {
            action = TLHelpDoc.getActionEventToHowToActionTitleDict().object(forKey: eventActionArray!.object(at: (indexPath as NSIndexPath).row)) as! String as NSString?
            instructions = TLHelpDoc.getBasicActionInstructionStepsArray((indexPath as NSIndexPath).row)
            performSegue(withIdentifier: "SegueInstructions", sender:self)
        } else if(sectionType == STATIC_MEMBERS.kAdvancedFAQSection) {
            FAQText = TLHelpDoc.getAdvanceExplanation((indexPath as NSIndexPath).row) as NSString?
            performSegue(withIdentifier: "SegueText", sender:self)
        } else if(sectionType == STATIC_MEMBERS.kAdvancedHowToFAQSection) {
            action = TLHelpDoc.getActionEventToHowToActionTitleDict().object(forKey: eventAdvanceActionArray!.object(at: (indexPath as NSIndexPath).row)) as! String as NSString?
            instructions = TLHelpDoc.getAdvanceActionInstructionStepsArray((indexPath as NSIndexPath).row)
            performSegue(withIdentifier: "SegueInstructions", sender:self)
        }
        return nil
    }
}
