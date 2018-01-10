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
        let versionArray = UIDevice.current.systemVersion.components(separatedBy: ".")
        return (versionArray[0] as NSString).integerValue
    }
    
    //TODO: better way
    class func isIPhone5() -> Bool {
        return UIScreen.main.bounds.size.height == 568
    }
    class func isIPhone4() -> Bool {
        return UIScreen.main.bounds.size.height == 480
    }
    
    class func defaultAppName() -> String {
        return "ArcBit"
    }
    
    class func daysSinceDate(_ date: Date) -> Int {
        let nowDate:Date = Date()
        let calendar: Calendar = Calendar.current
        let dateComponents = calendar.dateComponents([Calendar.Component.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: nowDate))
        return dateComponents.day!
    }
    
    class func dictionaryToJSONString(_ prettyPrint: Bool, dict: NSDictionary) -> String {
        let jsonData: Data?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: dict,
                        options: (prettyPrint ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)) as JSONSerialization.WritingOptions)
        } catch _ as NSError {
            jsonData = nil
        }
        assert(jsonData != nil, "jsonData not valid")
        return NSString(data: jsonData!, encoding: String.Encoding.utf8.rawValue)! as String
    }
    
    class func JSONStringToDictionary(_ jsonString: String) -> NSDictionary {
        var error: NSError? = nil
        let jsonData = jsonString.data(using: String.Encoding.utf8)
        let jsonDict:Any?
        do {
            jsonDict = try JSONSerialization.jsonObject(with: jsonData!,
                        options: JSONSerialization.ReadingOptions.mutableContainers)
        } catch let error1 as NSError {
            error = error1
            jsonDict = nil
        }
        assert(error == nil, "Invalid JSON string")
        return jsonDict as! NSDictionary
    }
    
    class func printOutDictionaryAsJSON(_ json: NSDictionary) {
        func JSONStringify(value: AnyObject, prettyPrinted: Bool = true) -> String {
            let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : nil
            if JSONSerialization.isValidJSONObject(value) {
                do {
                    let data = try JSONSerialization.data(withJSONObject: value, options: options!)
                    if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        return string as String
                    }
                } catch let error as NSError {
                    // If the encryption key was not accepted, the error will state that the database was invalid
                    fatalError("Error opening Realm: \(error)")
                }
            }
            return ""
        }
        let jsonString = JSONStringify(value: json)
        //set breakpoint and in console do "po jsonString as NSString"
        DLog("printOutDictionaryAsJSON:\n\(jsonString)")
    }
}
