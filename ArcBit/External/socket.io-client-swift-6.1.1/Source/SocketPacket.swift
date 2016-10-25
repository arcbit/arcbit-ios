//
//  SocketPacket.swift
//  Socket.IO-Client-Swift
//
//  Created by Erik Little on 1/18/15.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

struct SocketPacket {
    fileprivate let placeholders: Int
    
    fileprivate static let logType = "SocketPacket"

    let nsp: String
    let id: Int
    let type: PacketType
    
    enum PacketType: Int {
        case connect, disconnect, event, ack, error, binaryEvent, binaryAck
    }
    
    var args: [AnyObject] {
        if type == .event || type == .binaryEvent && data.count != 0 {
            return Array(data.dropFirst())
        } else {
            return data
        }
    }
    
    var binary: [Data]
    var data: [AnyObject]
    var description: String {
        return "SocketPacket {type: \(String(type.rawValue)); data: " +
            "\(String(describing: data)); id: \(id); placeholders: \(placeholders); nsp: \(nsp)}"
    }
    
    var event: String {
        return String(describing: data[0])
    }
    
    var packetString: String {
        return createPacketString()
    }
    
    init(type: SocketPacket.PacketType, data: [AnyObject] = [AnyObject](), id: Int = -1,
        nsp: String, placeholders: Int = 0, binary: [Data] = [Data]()) {
        self.data = data
        self.id = id
        self.nsp = nsp
        self.type = type
        self.placeholders = placeholders
        self.binary = binary
    }
    
    mutating func addData(_ data: Data) -> Bool {
        if placeholders == binary.count {
            return true
        }
        
        binary.append(data)
        
        if placeholders == binary.count {
            fillInPlaceholders()
            return true
        } else {
            return false
        }
    }
    
    fileprivate func completeMessage(_ message: String) -> String {
        let restOfMessage: String
        
        if data.count == 0 {
            return message + "[]"
        }
        
        do {
            let jsonSend = try JSONSerialization.data(withJSONObject: data,
                options: JSONSerialization.WritingOptions(rawValue: 0))
            guard let jsonString = String(data: jsonSend, encoding: String.Encoding.utf8) else {
                return "[]"
            }
            
            restOfMessage = jsonString
        } catch {
            DefaultSocketLogger.Logger.error("Error creating JSON object in SocketPacket.completeMessage",
                type: SocketPacket.logType)
            
            restOfMessage = "[]"
        }
        
        return message + restOfMessage
    }
    
    fileprivate func createAck() -> String {
        let message: String
        
        if type == .ack {
            if nsp == "/" {
                message = "3\(id)"
            } else {
                message = "3\(nsp),\(id)"
            }
        } else {
            if nsp == "/" {
                message = "6\(binary.count)-\(id)"
            } else {
                message = "6\(binary.count)-\(nsp),\(id)"
            }
        }
        
        return completeMessage(message)
    }

    
    fileprivate func createMessageForEvent() -> String {
        let message: String
        
        if type == .event {
            if nsp == "/" {
                if id == -1 {
                    message = "2"
                } else {
                    message = "2\(id)"
                }
            } else {
                if id == -1 {
                    message = "2\(nsp),"
                } else {
                    message = "2\(nsp),\(id)"
                }
            }
        } else {
            if nsp == "/" {
                if id == -1 {
                    message = "5\(binary.count)-"
                } else {
                    message = "5\(binary.count)-\(id)"
                }
            } else {
                if id == -1 {
                    message = "5\(binary.count)-\(nsp),"
                } else {
                    message = "5\(binary.count)-\(nsp),\(id)"
                }
            }
        }
        
        return completeMessage(message)
    }
    
    fileprivate func createPacketString() -> String {
        let str: String
        
        if type == .event || type == .binaryEvent {
            str = createMessageForEvent()
        } else {
            str = createAck()
        }
        
        return str
    }
    
    // Called when we have all the binary data for a packet
    // calls _fillInPlaceholders, which replaces placeholders with the
    // corresponding binary
    fileprivate mutating func fillInPlaceholders() {
        data = data.map(_fillInPlaceholders)
    }
    
    // Helper method that looks for placeholder strings
    // If object is a collection it will recurse
    // Returns the object if it is not a placeholder string or the corresponding
    // binary data
    fileprivate func _fillInPlaceholders(_ object: AnyObject) -> AnyObject {
        switch object {
        case let string as String where string["~~(\\d)"].groups() != nil:
            return binary[Int(string["~~(\\d)"].groups()![1])!]
        case let dict as NSDictionary:
            return dict.reduce(NSMutableDictionary(), {cur, keyValue in
                cur[keyValue.0 as! NSCopying] = _fillInPlaceholders(keyValue.1 as AnyObject)
                return cur
            })
        case let arr as [AnyObject]:
            return arr.map(_fillInPlaceholders)
        default:
            return object
        }
    }
}

extension SocketPacket {
    fileprivate static func findType(_ binCount: Int, ack: Bool) -> PacketType {
        switch binCount {
        case 0 where !ack:
            return .event
        case 0 where ack:
            return .ack
        case _ where !ack:
            return .binaryEvent
        case _ where ack:
            return .binaryAck
        default:
            return .error
        }
    }
    
    static func packetFromEmit(_ items: [AnyObject], id: Int, nsp: String, ack: Bool) -> SocketPacket {
        let (parsedData, binary) = deconstructData(items)
        let packet = SocketPacket(type: findType(binary.count, ack: ack), data: parsedData,
            id: id, nsp: nsp, placeholders: -1, binary: binary)
        
        return packet
    }
}

private extension SocketPacket {
    // Recursive function that looks for NSData in collections
    static func shred(_ data: AnyObject, binary: inout [Data]) -> AnyObject {
        let placeholder = ["_placeholder": true, "num": binary.count] as [String : Any]
        
        switch data {
        case let bin as Data:
            binary.append(bin)
            return placeholder as AnyObject
        case let arr as [AnyObject]:
            return arr.map({shred($0, binary: &binary)})
        case let dict as NSDictionary:
            return dict.reduce(NSMutableDictionary(), {cur, keyValue in
                cur[keyValue.0 as! NSCopying] = shred(keyValue.1 as AnyObject, binary: &binary)
                return cur
            })
        default:
            return data
        }
    }
    
    // Removes binary data from emit data
    // Returns a type containing the de-binaryed data and the binary
    static func deconstructData(_ data: [AnyObject]) -> ([AnyObject], [Data]) {
        var binary = [Data]()
        
        return (data.map({shred($0, binary: &binary)}), binary)
    }
}
