//
//  UIView+FormScroll.swift
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


extension UIView{
    public func scrollToY(_ y:Float) -> () {
        UIView.beginAnimations("registerScroll", context:nil)
        UIView.setAnimationCurve(.easeInOut)
        UIView.setAnimationDuration(0.4)
        transform = CGAffineTransform(translationX: 0, y: CGFloat(y))
        UIView.commitAnimations()
    }

    public func scrollToView(_ view:UIView) -> () {
        let OFFSET_Y = CGFloat(70.0)

        let theFrame = view.frame
        var y = theFrame.origin.y - 15
        y -= (y/1.7) - 60

        if (-y+OFFSET_Y < 0) {
            scrollToY(Float(-y+OFFSET_Y))
        } else {
            scrollToY(Float(-y))
        }
    }

    public func scrollElement(_ view:UIView, toPoint y:Float) -> () {
        let theFrame = view.frame
        let orig_y = theFrame.origin.y
        let diff = y - Float(orig_y)
        if (diff < 0) {
            scrollToY(diff)
        }
        else {
            scrollToY(0)
        }
    }
}
