//
//  TLInstructionsViewController.swift
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

@objc(TLInstructionsViewController) class TLInstructionsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet fileprivate var instructionsTableView: UITableView?
    var action:String?
    var actionInstructionsSteps:NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        self.instructionsTableView!.delegate = self
        self.instructionsTableView!.dataSource = self
        self.instructionsTableView!.tableFooterView = UIView(frame:CGRect.zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView:UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        return TLDisplayStrings.STEPS_STRING()
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return actionInstructionsSteps!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        let MyIdentifier = "InstructionStepCellIdentifier"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) 
        if (cell == nil) {
            cell = UITableViewCell(style:UITableViewCellStyle.default,
                reuseIdentifier:MyIdentifier)
        }
        cell!.textLabel!.numberOfLines = 0

        let text = String(format:"%ld. %@", (indexPath as NSIndexPath).row+1, actionInstructionsSteps!.object(at: (indexPath as NSIndexPath).row) as! String)
        cell!.textLabel!.text = text
        
        if ((indexPath as NSIndexPath).row % 2 == 0) {
            cell!.backgroundColor = TLColors.evenTableViewCellColor()
        } else {
            cell!.backgroundColor = TLColors.oddTableViewCellColor()
        }
        
        return cell!
    }
}
