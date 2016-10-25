//
//  SwiftRegex.swift
//  SwiftRegex
//
//  Created by John Holdsworth on 26/06/2014.
//  Copyright (c) 2014 John Holdsworth.
//
//  $Id: //depot/SwiftRegex/SwiftRegex.swift#37 $
//
//  This code is in the public domain from:
//  https://github.com/johnno1962/SwiftRegex
//

import Foundation

infix operator <~ { associativity none precedence 130 }

private let lock = DispatchSemaphore(value: 1)
private var swiftRegexCache = [String: NSRegularExpression]()

internal final class SwiftRegex : NSObject {
    var target: String
    var regex: NSRegularExpression
    
    init(target:String, pattern:String, options:NSRegularExpression.Options?) {
        self.target = target
        
        if lock.wait(timeout: DispatchTime.now() + Double(Int64(10 * NSEC_PER_MSEC)) / Double(NSEC_PER_SEC)) != 0 {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options:
                    NSRegularExpression.Options.dotMatchesLineSeparators)
                self.regex = regex
            } catch let error as NSError {
                SwiftRegex.failure("Error in pattern: \(pattern) - \(error)")
                self.regex = NSRegularExpression()
            }
            
            super.init()
            return
        }
        
        if let regex = swiftRegexCache[pattern] {
            self.regex = regex
        } else {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options:
                    NSRegularExpression.Options.dotMatchesLineSeparators)
                swiftRegexCache[pattern] = regex
                self.regex = regex
            } catch let error as NSError {
                SwiftRegex.failure("Error in pattern: \(pattern) - \(error)")
                self.regex = NSRegularExpression()
            }
        }
        lock.signal()
        super.init()
    }

    fileprivate static func failure(_ message: String) {
        fatalError("SwiftRegex: \(message)")
    }

    fileprivate var targetRange: NSRange {
        return NSRange(location: 0,length: target.utf16.count)
    }
    
    fileprivate func substring(_ range: NSRange) -> String? {
        if range.location != NSNotFound {
            return (target as NSString).substring(with: range)
        } else {
            return nil
        }
    }
    
    func doesMatch(_ options: NSRegularExpression.MatchingOptions!) -> Bool {
        return range(options).location != NSNotFound
    }
    
    func range(_ options: NSRegularExpression.MatchingOptions) -> NSRange {
        return regex.rangeOfFirstMatch(in: target as String, options: [], range: targetRange)
    }
    
    func match(_ options: NSRegularExpression.MatchingOptions) -> String? {
        return substring(range(options))
    }
    
    func groups() -> [String]? {
        return groupsForMatch(regex.firstMatch(in: target as String, options:
            NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: targetRange))
    }
    
    fileprivate func groupsForMatch(_ match: NSTextCheckingResult?) -> [String]? {
        guard let match = match else {
            return nil
        }
        var groups = [String]()
        for groupno in 0...regex.numberOfCaptureGroups {
            if let group = substring(match.rangeAt(groupno)) {
                groups += [group]
            } else {
                groups += ["_"] // avoids bridging problems
            }
        }
        return groups
    }
    
    subscript(groupno: Int) -> String? {
        get {
            return groups()?[groupno]
        }
        
        set(newValue) {
            if newValue == nil {
                return
            }
            
            for match in Array(matchResults().reversed()) {
                let replacement = regex.replacementString(for: match,
                    in: target as String, offset: 0, template: newValue!)
                let mut = NSMutableString(string: target)
                mut.replaceCharacters(in: match.rangeAt(groupno), with: replacement)
                
                target = mut as String
            }
        }
    }
    
    func matchResults() -> [NSTextCheckingResult] {
        let matches = regex.matches(in: target as String, options:
            NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: targetRange)
            as [NSTextCheckingResult]
        
        return matches
    }
    
    func ranges() -> [NSRange] {
        return matchResults().map { $0.range }
    }
    
    func matches() -> [String] {
        return matchResults().map( { self.substring($0.range)!})
    }
    
    func allGroups() -> [[String]?] {
        return matchResults().map { self.groupsForMatch($0) }
    }
    
    func dictionary(_ options: NSRegularExpression.MatchingOptions!) -> Dictionary<String,String> {
        var out = Dictionary<String,String>()
        for match in matchResults() {
            out[substring(match.rangeAt(1))!] = substring(match.rangeAt(2))!
        }
        return out
    }
    
    func substituteMatches(_ substitution: ((NSTextCheckingResult, UnsafeMutablePointer<ObjCBool>) -> String),
        options:NSRegularExpression.MatchingOptions) -> String {
            let out = NSMutableString()
            var pos = 0
            
            regex.enumerateMatches(in: target as String, options: options, range: targetRange ) {match, flags, stop in
                let matchRange = match!.range
                out.append( self.substring(NSRange(location:pos, length:matchRange.location-pos))!)
                out.append( substitution(match!, stop) )
                pos = matchRange.location + matchRange.length
            }
            
            out.append(substring(NSRange(location:pos, length:targetRange.length-pos))!)
            
            return out as String
    }
    
    var boolValue: Bool {
        return doesMatch(nil)
    }
}

extension String {
    subscript(pattern: String, options: NSRegularExpression.Options) -> SwiftRegex {
        return SwiftRegex(target: self, pattern: pattern, options: options)
    }
}

extension String {
    subscript(pattern: String) -> SwiftRegex {
        return SwiftRegex(target: self, pattern: pattern, options: nil)
    }
}

func <~ (left: SwiftRegex, right: String) -> String {
    return left.substituteMatches({match, stop in
        return left.regex.replacementString( for: match,
            in: left.target as String, offset: 0, template: right )
        }, options: [])
}
