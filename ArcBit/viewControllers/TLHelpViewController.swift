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
    
    @IBOutlet fileprivate var howToInstructionsTableView:UITableView?
    fileprivate var eventActionArray:NSArray?
    fileprivate var eventAdvanceActionArray:NSArray?
    fileprivate var FAQArray:NSArray?
    fileprivate var advancedFAQArray:NSArray?
    fileprivate var instructions:NSArray?
    fileprivate var action:NSString?
    fileprivate var FAQText:NSString?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        setLogoImageView()
        
        eventActionArray = TLHelpDoc.getEventsArray()
        eventAdvanceActionArray = TLHelpDoc.getAdvanceEventsArray()
        FAQArray = TLHelpDoc.getFAQArray()
        advancedFAQArray = TLHelpDoc.getAdvanceFAQArray()
        
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
        if (TLPreferences.enabledAdvancedMode()) {
            return 5
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        if (TLPreferences.enabledAdvancedMode()) {
            if(section == 0) {
                return "Achievements".localized
            }
            else if(section == 1) {
                return "FAQ".localized
            }
            else if(section == 2) {
                return "How To:".localized
            }
            else if(section == 3) {
                return "Advance FAQ".localized
            }
            else {
                return "Advance how To:".localized
            }
        } else {
            if(section == 0) {
                return "Achievements".localized
            }
            else if(section == 1) {
                return "Features".localized
            }
            else {
                return "How To:".localized
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        if (TLPreferences.enabledAdvancedMode()) {
            if(section == 0) {
                return 1
            }
            else if(section == 1) {
                return FAQArray!.count
            }
            else if(section == 2) {
                return eventActionArray!.count
            }
            else if(section == 3) {
                return advancedFAQArray!.count
            }
            else {
                return eventAdvanceActionArray!.count
            }
        } else {
            if(section == 0) {
                return 1
            }
            else if(section == 1) {
                return FAQArray!.count
            }
            else {
                return eventActionArray!.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        let MyIdentifier = "HowToCellIdentifier"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) 
        if (cell == nil) {
            cell = UITableViewCell(style:UITableViewCellStyle.default,
                reuseIdentifier:MyIdentifier)
        }
        cell!.textLabel!.numberOfLines = 0
        
        if (TLPreferences.enabledAdvancedMode()) {
            if((indexPath as NSIndexPath).section == 0) {
                cell!.textLabel!.text = "View Achievements".localized
            }
            else if((indexPath as NSIndexPath).section == 1) {
                cell!.textLabel!.text = FAQArray!.object(at: (indexPath as NSIndexPath).row) as? String
            }
            else if((indexPath as NSIndexPath).section == 2) {
                cell!.textLabel!.text = TLHelpDoc.getActionEventToHowToActionTitleDict().object(forKey: eventActionArray!.object(at: (indexPath as NSIndexPath).row) as! String) as? String
            }
            else if((indexPath as NSIndexPath).section == 3) {
                cell!.textLabel!.text = advancedFAQArray!.object(at: (indexPath as NSIndexPath).row) as? String
            }
            else
            {
                cell!.textLabel!.text = TLHelpDoc.getActionEventToHowToActionTitleDict().object(forKey: eventAdvanceActionArray!.object(at: (indexPath as NSIndexPath).row) as! String) as? String
            }
        } else {
            if((indexPath as NSIndexPath).section == 0) {
                cell!.textLabel!.text = "View Achievements".localized
            }
            else if((indexPath as NSIndexPath).section == 1) {
                cell!.textLabel!.text = FAQArray!.object(at: (indexPath as NSIndexPath).row) as? String
            }
            else {
                cell!.textLabel!.text = TLHelpDoc.getActionEventToHowToActionTitleDict().object(forKey: eventActionArray!.object(at: (indexPath as NSIndexPath).row) as! String) as? String
            }
        }
        
        if ((indexPath as NSIndexPath).row % 2 == 0) {
            cell!.backgroundColor = TLColors.evenTableViewCellColor()
        } else {
            cell!.backgroundColor = TLColors.oddTableViewCellColor()
        }
        
        return cell!
    }
    
    func tableView(_ tableView:UITableView, willSelectRowAt indexPath:IndexPath) -> IndexPath? {
        if (TLPreferences.enabledAdvancedMode()) {
            if((indexPath as NSIndexPath).section == 0) {
                performSegue(withIdentifier: "SegueAchievements", sender:self)
            } else if((indexPath as NSIndexPath).section == 1) {
                FAQText = TLHelpDoc.getExplanation((indexPath as NSIndexPath).row)
                performSegue(withIdentifier: "SegueText", sender:self)
            } else if((indexPath as NSIndexPath).section == 2) {
                action = TLHelpDoc.getActionEventToHowToActionTitleDict().object(forKey: eventActionArray!.object(at: (indexPath as NSIndexPath).row)) as! String as NSString?
                instructions = TLHelpDoc.getBasicActionInstructionStepsArray((indexPath as NSIndexPath).row)
                performSegue(withIdentifier: "SegueInstructions", sender:self)
            } else if((indexPath as NSIndexPath).section == 3) {
                FAQText = TLHelpDoc.getAdvanceExplanation((indexPath as NSIndexPath).row)
                performSegue(withIdentifier: "SegueText", sender:self)
            } else {
                action = TLHelpDoc.getActionEventToHowToActionTitleDict().object(forKey: eventAdvanceActionArray!.object(at: (indexPath as NSIndexPath).row)) as! String as NSString?
                instructions = TLHelpDoc.getAdvanceActionInstructionStepsArray((indexPath as NSIndexPath).row)
                performSegue(withIdentifier: "SegueInstructions", sender:self)
            }
        } else {
            if((indexPath as NSIndexPath).section == 0) {
                performSegue(withIdentifier: "SegueAchievements", sender:self)
            } else if((indexPath as NSIndexPath).section == 1) {
                FAQText = TLHelpDoc.getExplanation((indexPath as NSIndexPath).row)
                performSegue(withIdentifier: "SegueText", sender:self)
            } else {
                action = TLHelpDoc.getActionEventToHowToActionTitleDict().object(forKey: eventActionArray!.object(at: (indexPath as NSIndexPath).row)) as! String as NSString?
                instructions = TLHelpDoc.getBasicActionInstructionStepsArray((indexPath as NSIndexPath).row)
                performSegue(withIdentifier: "SegueInstructions", sender:self)
            }
        }
        
        return nil
    }
}
