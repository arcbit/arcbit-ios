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

@objc class TLUtils {

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
        let jsonData = NSJSONSerialization.dataWithJSONObject(dict,
            options: (prettyPrint ? NSJSONWritingOptions.PrettyPrinted : NSJSONWritingOptions(rawValue: 0)) as NSJSONWritingOptions,
            error: &error)
        assert(jsonData != nil, "jsonData not valid")
        return NSString(data: jsonData!, encoding: NSUTF8StringEncoding)! as String
    }
    
    class func JSONStringToDictionary(jsonString: String) -> NSDictionary {
        var error: NSError? = nil
        let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        let jsonDict:AnyObject? = NSJSONSerialization.JSONObjectWithData(jsonData!,
            options: NSJSONReadingOptions.MutableContainers,
            error: &error)
        assert(error == nil, "Invalid JSON string")
        return jsonDict as! NSDictionary
    }
    
    class func SHA256HashFor(input: NSString) -> String {
        let str = input.UTF8String
        
        let result = [CUnsignedChar](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
        let resultBytes: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer(result)
        
        CC_SHA256(str, CC_LONG(strlen(str)), resultBytes)
        
        let ret = NSMutableString(capacity:Int(CC_SHA256_DIGEST_LENGTH)*2)
        for(var i = 0; i < Int(CC_SHA256_DIGEST_LENGTH); i++) {
            ret.appendFormat("%02x",result[i])
        }
        return ret as String
    }
    
    class func doubleSHA256HashFor(input: NSString) -> String {
        let str = input.UTF8String
        let result = [CUnsignedChar](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
        let resultBytes: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer(result)
        
        CC_SHA256(str, CC_LONG(strlen(str)), resultBytes)
        let result2 = [CUnsignedChar](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
        let result2Bytes: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer(result2)
        
        CC_SHA256(result, CC_LONG(CC_SHA256_DIGEST_LENGTH), result2Bytes)
        
        let ret = NSMutableString(capacity:Int(CC_SHA256_DIGEST_LENGTH*2))
        for(var i = 0; i<Int(CC_SHA256_DIGEST_LENGTH); i++) {
            ret.appendFormat("%02x",result2[i])
        }
        return ret as String
    }
}