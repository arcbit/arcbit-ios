//
//  TLColors.swift
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

class TLColors {
    struct Static {
        static var color:UIColor? = nil
    }
    
    class func mainAppColor() -> UIColor {
        if Static.color == nil {
            let r = 36.0/255.0
            let g = 171/255.0
            let b = 220/255.0
            
            Static.color = UIColor(red: CGFloat(r), green:CGFloat(g), blue:CGFloat(b), alpha:1)
        }
        return Static.color!
    }
    
    class func mainAppOppositeColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    class func evenTableViewCellColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    class func oddTableViewCellColor() -> UIColor {
        return UIColor.whiteColor()
    }
}