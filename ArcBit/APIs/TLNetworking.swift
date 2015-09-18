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
    case WWAN           = 0
    case WIFI           = 1
    case NOTREACHABLE   = 2
}

class TLNetworking {
    
    typealias ReachableHandler = (TLDOMAINREACHABLE) -> ()
    typealias SuccessHandler = (AnyObject!) -> ()
    typealias FailureHandler = (Int, String!) -> ()
    
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
    
    init(certificateData: NSData? = nil) {
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
        self.getManagerBackground.completionQueue  = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        

        self.getSynchronousManager = AFHTTPRequestOperationManager()
        requestSerializer = AFHTTPRequestSerializer()
        requestSerializer.setValue(ua, forHTTPHeaderField:"User-Agent")
        requestSerializer.setValue("utf-8", forHTTPHeaderField:"charset")
        self.getSynchronousManager.requestSerializer = requestSerializer
        self.getSynchronousManager.completionQueue  = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        
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
        self.postSynchronousManager.completionQueue  = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        if certificateData != nil {
            let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.Certificate)
            securityPolicy.allowInvalidCertificates = true
            securityPolicy.validatesCertificateChain = false
            securityPolicy.validatesDomainName = false
            securityPolicy.pinnedCertificates = [certificateData!]

            self.getManager.securityPolicy = securityPolicy
            self.getManagerBackground.securityPolicy = securityPolicy
            self.getSynchronousManager.securityPolicy = securityPolicy
            self.postManager.securityPolicy = securityPolicy
            self.postSynchronousManager.securityPolicy = securityPolicy
        }
    }
    
    class func isReachable(url: NSURL, reachable: ReachableHandler) -> () {
        let manager = AFHTTPRequestOperationManager(baseURL:url)
        
        let operationQueue = manager.operationQueue
        manager.reachabilityManager.setReachabilityStatusChangeBlock({(status: AFNetworkReachabilityStatus) in
            switch (status) {
            case AFNetworkReachabilityStatus.ReachableViaWWAN:
                DLog("AFNetworkReachabilityStatusReachableViaWWAN")
                operationQueue.suspended = false
                reachable(TLDOMAINREACHABLE.WWAN)
                break
            case AFNetworkReachabilityStatus.ReachableViaWiFi:
                DLog("AFNetworkReachabilityStatusReachableViaWiFi")
                operationQueue.suspended = false
                
                reachable(TLDOMAINREACHABLE.WIFI)
                break
            case AFNetworkReachabilityStatus.NotReachable:
                reachable(TLDOMAINREACHABLE.NOTREACHABLE)
                DLog("AFNetworkReachabilityStatusNotReachable")
            default:
                operationQueue.suspended = true
                break
            }
        })
        
        manager.reachabilityManager.startMonitoring()
    }
    
    func httpGETSynchronous(url: NSURL, parameters: NSDictionary) -> AnyObject? {
        var response:AnyObject? = nil
        let semaphore = dispatch_semaphore_create(0)

        var success = false
        DLog("httpGETSynchronous: url %@", function: url.absoluteString)
        var operation = self.getSynchronousManager.GET(url.absoluteString,
            parameters: parameters,
            success:{(operation:AFHTTPRequestOperation!, responseObject:AnyObject!) in
                response = responseObject
                dispatch_semaphore_signal(semaphore)
                success = true
            },
            failure:{(operation:AFHTTPRequestOperation!, error:NSError!) in
                DLog("httpGETSynchronous: requestFailed url %@", function: url.absoluteString)
                if operation.response != nil {
                    response = [STATIC_MEMBERS.HTTP_ERROR_CODE: operation.response.statusCode, STATIC_MEMBERS.HTTP_ERROR_MSG:operation.responseString]
                } else {
                    response = [STATIC_MEMBERS.HTTP_ERROR_CODE: "499", STATIC_MEMBERS.HTTP_ERROR_MSG:"No Response"]
                }
                dispatch_semaphore_signal(semaphore)
        })
        
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return response
    }
    
    func httpGET(url: NSURL, parameters: NSDictionary,
        success: SuccessHandler?, failure: FailureHandler?) -> () {
            
            DLog("httpGET: url %@", function: url.absoluteString)
            self.getManager.GET(url.absoluteString,
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
    
    func httpGETBackground(url: NSURL, parameters: NSDictionary,
        success: SuccessHandler?, failure: FailureHandler?) -> () {
            
            DLog("httpGETBackground: url %@", function: url.absoluteString)
            self.getManagerBackground.GET(url.absoluteString,
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
    
    func httpPOST(url: NSURL, parameters: NSDictionary,
        success: SuccessHandler?, failure: FailureHandler?) -> () {
            
            DLog("httpPOST:function:  url %@", function: url.absoluteString)
            self.postManager.POST(url.absoluteString,
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
    
    func httpPOSTSynchronous(url: NSURL, parameters: NSDictionary) -> AnyObject? {
        var response:AnyObject?
        
        let semaphore = dispatch_semaphore_create(0)
        
        DLog("httpPOSTSynchronous: url %@", function: url.absoluteString)
        var operation = self.postSynchronousManager.POST(url.absoluteString,
            parameters: parameters,
            success:{(operation:AFHTTPRequestOperation!, responseObject:AnyObject!) in
                response = responseObject
                dispatch_semaphore_signal(semaphore)
            },
            failure:{(operation:AFHTTPRequestOperation!, error:NSError!) in
                DLog("httpPOSTSynchronous: requestFailed url %@", function: url.absoluteString)
                if operation.response != nil {
                    response = [STATIC_MEMBERS.HTTP_ERROR_CODE: operation.response.statusCode, STATIC_MEMBERS.HTTP_ERROR_MSG:operation.responseString]
                } else {
                    response = [STATIC_MEMBERS.HTTP_ERROR_CODE: "499", STATIC_MEMBERS.HTTP_ERROR_MSG:"No Response"]
                }
                dispatch_semaphore_signal(semaphore)
        })
        
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return response
    }
}