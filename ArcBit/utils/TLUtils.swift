//
//  TLUtils.swift
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

class TLUtils {

    class func getiOSVersion() -> Int {
        let versionArray = UIDevice.currentDevice().systemVersion.componentsSeparatedByString(".")
        return (versionArray[0] as NSString).integerValue
    }
    
    //TODO: better way
    class func isIPhone5() -> Bool {
        return UIScreen.mainScreen().bounds.size.height == 568
    }
    class func isIPhone4() -> Bool {
        return UIScreen.mainScreen().bounds.size.height == 480
    }
    
    class func defaultAppName() -> String {
        return "ArcBit"
    }
    
    class func dictionaryToJSONString(prettyPrint: Bool, dict: NSDictionary) -> String {
        var error: NSError? = nil
        let jsonData: NSData?
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(dict,
                        options: (prettyPrint ? NSJSONWritingOptions.PrettyPrinted : NSJSONWritingOptions(rawValue: 0)) as NSJSONWritingOptions)
        } catch let error1 as NSError {
            error = error1
            jsonData = nil
        }
        assert(jsonData != nil, "jsonData not valid")
        return NSString(data: jsonData!, encoding: NSUTF8StringEncoding)! as String
    }
    
    class func JSONStringToDictionary(jsonString: String) -> NSDictionary {
        var error: NSError? = nil
        let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        let jsonDict:AnyObject?
        do {
            jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData!,
                        options: NSJSONReadingOptions.MutableContainers)
        } catch let error1 as NSError {
            error = error1
            jsonDict = nil
        }
        assert(error == nil, "Invalid JSON string")
        return jsonDict as! NSDictionary
    }
}