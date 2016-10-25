//
//  TLNetworking.swift
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

enum TLDOMAINREACHABLE:Int {
    case wwan           = 0
    case wifi           = 1
    case notreachable   = 2
}

class TLNetworking {
    
    typealias ReachableHandler = (TLDOMAINREACHABLE) -> ()
    typealias SuccessHandler = (AnyObject!) -> ()
    typealias FailureHandler = (Int, String?) -> ()
    
    struct STATIC_MEMBERS {
        static var _instance:TLNetworking? = nil
        static let HTTP_ERROR_CODE = "HTTPErrorCode"
        static let HTTP_ERROR_MSG = "HTTPErrorMsg"
    }
    
    let getManager:AFHTTPRequestOperationManager
    let postManager:AFHTTPRequestOperationManager
    let getSynchronousManager:AFHTTPRequestOperationManager
    let postSynchronousManager:AFHTTPRequestOperationManager
    let getManagerBackground:AFHTTPRequestOperationManager
    
    init(certificateData: Data? = nil) {
        let ua = "Mozilla/5.0 (Macintosh Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.57 Safari/537.36"

        self.getManager = AFHTTPRequestOperationManager()
        var requestSerializer = AFHTTPRequestSerializer()
        requestSerializer.setValue(ua, forHTTPHeaderField:"User-Agent")
        requestSerializer.setValue("utf-8", forHTTPHeaderField:"charset")
        self.getManager.requestSerializer = requestSerializer
        
        self.getManagerBackground = AFHTTPRequestOperationManager()
        requestSerializer = AFHTTPRequestSerializer()
        requestSerializer.setValue(ua, forHTTPHeaderField:"User-Agent")
        requestSerializer.setValue("utf-8", forHTTPHeaderField:"charset")
        self.getManagerBackground.requestSerializer = requestSerializer
        self.getManagerBackground.completionQueue  = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        

        self.getSynchronousManager = AFHTTPRequestOperationManager()
        requestSerializer = AFHTTPRequestSerializer()
        requestSerializer.setValue(ua, forHTTPHeaderField:"User-Agent")
        requestSerializer.setValue("utf-8", forHTTPHeaderField:"charset")
        self.getSynchronousManager.requestSerializer = requestSerializer
        self.getSynchronousManager.completionQueue  = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        
        
        self.postManager = AFHTTPRequestOperationManager()
        var postRequestSerializer = AFHTTPRequestSerializer()
        postRequestSerializer.setValue(ua, forHTTPHeaderField:"User-Agent")
        postRequestSerializer.setValue("utf-8", forHTTPHeaderField:"charset")
        self.postManager.requestSerializer = postRequestSerializer

        
        self.postSynchronousManager = AFHTTPRequestOperationManager()
        postRequestSerializer = AFHTTPRequestSerializer()
        postRequestSerializer.setValue(ua, forHTTPHeaderField:"User-Agent")
        postRequestSerializer.setValue("utf-8", forHTTPHeaderField:"charset")
        self.postSynchronousManager.requestSerializer = postRequestSerializer
        self.postSynchronousManager.completionQueue  = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        
        if certificateData != nil {
            let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.certificate)
            securityPolicy?.allowInvalidCertificates = true
            securityPolicy?.validatesCertificateChain = false
            securityPolicy?.validatesDomainName = false
            securityPolicy?.pinnedCertificates = [certificateData!]

            self.getManager.securityPolicy = securityPolicy
            self.getManagerBackground.securityPolicy = securityPolicy
            self.getSynchronousManager.securityPolicy = securityPolicy
            self.postManager.securityPolicy = securityPolicy
            self.postSynchronousManager.securityPolicy = securityPolicy
        }
    }
    
    class func isReachable(_ url: URL, reachable: @escaping ReachableHandler) -> () {
        let manager = AFHTTPRequestOperationManager(baseURL:url)
        
        let operationQueue = manager?.operationQueue
        manager?.reachabilityManager.setReachabilityStatusChange({(status: AFNetworkReachabilityStatus) in
            switch (status) {
            case AFNetworkReachabilityStatus.reachableViaWWAN:
                DLog("AFNetworkReachabilityStatusReachableViaWWAN")
                operationQueue?.isSuspended = false
                reachable(TLDOMAINREACHABLE.wwan)
                break
            case AFNetworkReachabilityStatus.reachableViaWiFi:
                DLog("AFNetworkReachabilityStatusReachableViaWiFi")
                operationQueue?.isSuspended = false
                
                reachable(TLDOMAINREACHABLE.wifi)
                break
            case AFNetworkReachabilityStatus.notReachable:
                reachable(TLDOMAINREACHABLE.notreachable)
                DLog("AFNetworkReachabilityStatusNotReachable")
            default:
                operationQueue?.isSuspended = true
                break
            }
        })
        
        manager?.reachabilityManager.startMonitoring()
    }
    
    func httpGETSynchronous(_ url: URL, parameters: NSDictionary) -> AnyObject? {
        var response:AnyObject? = nil
        let semaphore = DispatchSemaphore(value: 0)

        DLog("httpGETSynchronous: url %@", function: url.absoluteString)
        _ = self.getSynchronousManager.get(url.absoluteString,
            parameters: parameters,
            success:{(operation:AFHTTPRequestOperation!, responseObject:AnyObject!) in
                response = responseObject
                semaphore.signal()
            },
            failure:{(operation:AFHTTPRequestOperation!, error:NSError!) in
                DLog("httpGETSynchronous: requestFailed url %@", function: url.absoluteString)
                if operation.response != nil {
                    response = [STATIC_MEMBERS.HTTP_ERROR_CODE: operation.response.statusCode, STATIC_MEMBERS.HTTP_ERROR_MSG:operation.responseString]
                } else {
                    response = [STATIC_MEMBERS.HTTP_ERROR_CODE: "499", STATIC_MEMBERS.HTTP_ERROR_MSG:"No Response"]
                }
                semaphore.signal()
        })
        
        
        semaphore.wait(timeout: DispatchTime.distantFuture)
        return response
    }
    
    func httpGET(_ url: URL, parameters: NSDictionary,
        success: SuccessHandler?, failure: FailureHandler?) -> () {
            
            DLog("httpGET: url %@", function: url.absoluteString)
            self.getManager.get(url.absoluteString,
                parameters:parameters,
                success:{(operation:AFHTTPRequestOperation!, responseObject:AnyObject!) in
                    if success != nil {
                        success!(responseObject)
                    }
                } ,
                failure:{(operation:AFHTTPRequestOperation!, error:NSError!) in
                    DLog("httpGET: requestFailed url %@", function: url.absoluteString)
                    if (failure != nil) {
                        failure!(operation.response == nil ? 0 : operation.response.statusCode, operation.response == nil ? "" : operation.responseString)
                    }
            })
    }
    
    func httpGETBackground(_ url: URL, parameters: NSDictionary,
        success: SuccessHandler?, failure: FailureHandler?) -> () {
            
            DLog("httpGETBackground: url %@", function: url.absoluteString)
            self.getManagerBackground.get(url.absoluteString,
                parameters:parameters,
                success:{(operation:AFHTTPRequestOperation!, responseObject:AnyObject!) in
                    if success != nil {
                        success!(responseObject)
                    }
                } ,
                failure:{(operation:AFHTTPRequestOperation!, error:NSError!) in
                    DLog("httpGETBackground: requestFailed url %@", function: url.absoluteString)
                    if (failure != nil) {
                        failure!(operation.response == nil ? 0 : operation.response.statusCode, operation.response == nil ? "" : operation.responseString)
                    }
            })
    }
    
    func httpPOST(_ url: URL, parameters: NSDictionary,
        success: SuccessHandler?, failure: FailureHandler?) -> () {
            
            DLog("httpPOST:function:  url %@", function: url.absoluteString)
            self.postManager.post(url.absoluteString,
                parameters:parameters,
                success:{(operation:AFHTTPRequestOperation!, responseObject:AnyObject!) in
                    if success != nil {
                        success!(responseObject)
                    }
                },
                failure:{(operation:AFHTTPRequestOperation!, error:NSError!) in
                    DLog("httpPOST: requestFailed url %@", function: url.absoluteString)
                    if (failure != nil) {
                        failure!(operation.response == nil ? 0 : operation.response.statusCode,  operation.response == nil ? "" : operation.responseString)
                    }
            })
    }
    
    func httpPOSTSynchronous(_ url: URL, parameters: NSDictionary) -> AnyObject? {
        var response:AnyObject?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        DLog("httpPOSTSynchronous: url %@", function: url.absoluteString)
        _ = self.postSynchronousManager.post(url.absoluteString,
            parameters: parameters,
            success:{(operation:AFHTTPRequestOperation!, responseObject:AnyObject!) in
                response = responseObject
                semaphore.signal()
            },
            failure:{(operation:AFHTTPRequestOperation!, error:NSError!) in
                DLog("httpPOSTSynchronous: requestFailed url %@", function: url.absoluteString)
                if operation.response != nil {
                    response = [STATIC_MEMBERS.HTTP_ERROR_CODE: operation.response.statusCode, STATIC_MEMBERS.HTTP_ERROR_MSG:operation.responseString]
                } else {
                    response = [STATIC_MEMBERS.HTTP_ERROR_CODE: "499", STATIC_MEMBERS.HTTP_ERROR_MSG:"No Response"]
                }
                semaphore.signal()
        })
        
        
        semaphore.wait(timeout: DispatchTime.distantFuture)
        return response
    }
}
