//
//  TLAchievements.swift
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

class TLAchievements {
    struct STATIC_MEMBERS {
        static var _instance:TLAchievements? = nil
    }
    
    class func instance() -> (TLAchievements) {
        if(STATIC_MEMBERS._instance == nil) {
            STATIC_MEMBERS._instance = TLAchievements()
        }
        return STATIC_MEMBERS._instance!
    }
    
    func hasDoneAction(_ action:String) -> (Bool) {
        let userAnalyticsDict = NSMutableDictionary(dictionary:TLPreferences.getAnalyticsDict() ?? NSDictionary())
        if userAnalyticsDict.value(forKey: action) == nil {
            return false
        }
        let eventCount = (userAnalyticsDict.value(forKey: action) as! NSNumber).intValue
        return eventCount > 0
    }
}
