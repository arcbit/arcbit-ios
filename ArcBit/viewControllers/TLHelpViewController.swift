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
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet private var howToInstructionsTableView:UITableView?
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
        
        self.howToInstructionsTableView!.delegate = self
        self.howToInstructionsTableView!.dataSource = self
        self.howToInstructionsTableView!.tableFooterView = UIView(frame:CGRectZero)
    }
    
    override func viewDidAppear(animated:Bool) -> () {
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_HELP_SCREEN(),
            object:nil)
    }
    
    override func didReceiveMemoryWarning() -> () {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender:AnyObject!) -> () {
        if (segue.identifier == "SegueAchievements") {
            let vc = segue.destinationViewController as! UIViewController
            vc.navigationItem.title = "Achievements".localized
        } else if (segue.identifier == "SegueText") {
            let vc = segue.destinationViewController as! TLTextViewViewController
            vc.navigationItem.title = "Explanation".localized
            vc.text = FAQText as? String
        } else if (segue.identifier == "SegueInstructions") {
            let vc = segue.destinationViewController as! TLInstructionsViewController
            vc.navigationItem.title = "Instructions".localized
            vc.action = action as? String
            vc.actionInstructionsSteps = instructions
        }
    }
    
    @IBAction private func menuButtonClicked(sender:UIButton) -> () {
        self.slidingViewController().anchorTopViewToRightAnimated(true)
    }
    
    func numberOfSectionsInTableView(tableView:UITableView) -> Int {
        if (TLPreferences.enabledAdvanceMode()) {
            return 5
        } else {
            return 3
        }
    }
    
    func tableView(tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        if (TLPreferences.enabledAdvanceMode()) {
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        if (TLPreferences.enabledAdvanceMode()) {
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell{
        let MyIdentifier = "HowToCellIdentifier"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier) as! UITableViewCell?
        if (cell == nil) {
            cell = UITableViewCell(style:UITableViewCellStyle.Default,
                reuseIdentifier:MyIdentifier)
        }
        cell!.textLabel!.numberOfLines = 0
        
        if (TLPreferences.enabledAdvanceMode()) {
            if(indexPath.section == 0) {
                cell!.textLabel!.text = "View Achievements".localized
            }
            else if(indexPath.section == 1) {
                cell!.textLabel!.text = FAQArray!.objectAtIndex(indexPath.row) as? String
            }
            else if(indexPath.section == 2) {
                cell!.textLabel!.text = TLHelpDoc.getActionEventToHowToActionTitleDict().objectForKey(eventActionArray!.objectAtIndex(indexPath.row) as! String) as? String
            }
            else if(indexPath.section == 3) {
                cell!.textLabel!.text = advancedFAQArray!.objectAtIndex(indexPath.row) as? String
            }
            else
            {
                cell!.textLabel!.text = TLHelpDoc.getActionEventToHowToActionTitleDict().objectForKey(eventAdvanceActionArray!.objectAtIndex(indexPath.row) as! String) as? String
            }
        } else {
            if(indexPath.section == 0) {
                cell!.textLabel!.text = "View Achievements".localized
            }
            else if(indexPath.section == 1) {
                cell!.textLabel!.text = FAQArray!.objectAtIndex(indexPath.row) as? String
            }
            else {
                cell!.textLabel!.text = TLHelpDoc.getActionEventToHowToActionTitleDict().objectForKey(eventActionArray!.objectAtIndex(indexPath.row) as! String) as? String
            }
        }
        
        if (indexPath.row % 2 == 0) {
            cell!.backgroundColor = TLColors.evenTableViewCellColor()
        } else {
            cell!.backgroundColor = TLColors.oddTableViewCellColor()
        }
        
        return cell!
    }
    
    func tableView(tableView:UITableView, willSelectRowAtIndexPath indexPath:NSIndexPath) -> NSIndexPath? {
        if (TLPreferences.enabledAdvanceMode()) {
            if(indexPath.section == 0) {
                performSegueWithIdentifier("SegueAchievements", sender:self)
            } else if(indexPath.section == 1) {
                FAQText = TLHelpDoc.getExplanation(indexPath.row)
                performSegueWithIdentifier("SegueText", sender:self)
            } else if(indexPath.section == 2) {
                action = TLHelpDoc.getActionEventToHowToActionTitleDict().objectForKey(eventActionArray!.objectAtIndex(indexPath.row)) as! String
                instructions = TLHelpDoc.getBasicActionInstructionStepsArray(indexPath.row)
                performSegueWithIdentifier("SegueInstructions", sender:self)
            } else if(indexPath.section == 3) {
                FAQText = TLHelpDoc.getAdvanceExplanation(indexPath.row)
                performSegueWithIdentifier("SegueText", sender:self)
            } else {
                action = TLHelpDoc.getActionEventToHowToActionTitleDict().objectForKey(eventAdvanceActionArray!.objectAtIndex(indexPath.row)) as! String
                instructions = TLHelpDoc.getAdvanceActionInstructionStepsArray(indexPath.row)
                performSegueWithIdentifier("SegueInstructions", sender:self)
            }
        } else {
            if(indexPath.section == 0) {
                performSegueWithIdentifier("SegueAchievements", sender:self)
            } else if(indexPath.section == 1) {
                FAQText = TLHelpDoc.getExplanation(indexPath.row)
                performSegueWithIdentifier("SegueText", sender:self)
            } else {
                action = TLHelpDoc.getActionEventToHowToActionTitleDict().objectForKey(eventActionArray!.objectAtIndex(indexPath.row)) as! String
                instructions = TLHelpDoc.getBasicActionInstructionStepsArray(indexPath.row)
                performSegueWithIdentifier("SegueInstructions", sender:self)
            }
        }
        
        return nil
    }
}
