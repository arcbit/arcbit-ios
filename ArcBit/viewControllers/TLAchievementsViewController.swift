//
//  TLAchievementsViewController.swift
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

@objc(TLAchievementsViewController) class  TLAchievementsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var eventActionArray:NSArray?
    var  advanceeventActionArray:NSArray?
    @IBOutlet private var howToInstructionsTableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        
        eventActionArray = TLHelpDoc.getEventsArray()
        advanceeventActionArray = TLHelpDoc.getAdvanceEventsArray()
        
        self.howToInstructionsTableView!.delegate = self
        self.howToInstructionsTableView!.dataSource = self
        self.howToInstructionsTableView!.tableFooterView = UIView(frame:CGRectZero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView:UITableView) -> Int {
        if (TLPreferences.enabledAdvanceMode()) {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        if(section == 0) {
            return "Achievement List".localized
        }
        else {
            return "Advance Achievement List".localized
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        if(section == 0) {
            return eventActionArray!.count
        }
        else {
            return advanceeventActionArray!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell{
        let MyIdentifier = "AchievementCellIdentifier"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier) 
        if (cell == nil) {
            cell = UITableViewCell(style:UITableViewCellStyle.Default,
                reuseIdentifier:MyIdentifier)
        }
        cell!.textLabel!.numberOfLines = 0

        if(indexPath.section == 0) {
            let event = eventActionArray!.objectAtIndex(indexPath.row) as! String
            if (TLAchievements.instance().hasDoneAction(event)) {
                cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell!.accessoryType = UITableViewCellAccessoryType.None
            }
            cell!.textLabel!.text = TLHelpDoc.getActionEventToHowToActionTitleDict().objectForKey(event) as? String
        } else {
            let event = advanceeventActionArray!.objectAtIndex(indexPath.row) as! String
            if (TLAchievements.instance().hasDoneAction(event)) {
                cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell!.accessoryType = UITableViewCellAccessoryType.None
            }
            cell!.textLabel!.text = TLHelpDoc.getActionEventToHowToActionTitleDict().objectForKey(event) as? String
        }
        
        if (indexPath.row % 2 == 0) {
            cell!.backgroundColor = TLColors.evenTableViewCellColor()
        } else {
            cell!.backgroundColor = TLColors.oddTableViewCellColor()
        }
        
        return cell!
    }
    
    func tableView(tableView:UITableView, willSelectRowAtIndexPath indexPath:NSIndexPath) -> NSIndexPath? {
        return nil
    }
}
