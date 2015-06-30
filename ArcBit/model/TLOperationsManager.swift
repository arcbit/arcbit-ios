//
//  TLOperationsManager.swift
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

class PendingOperations {
    private lazy var downloadQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.qualityOfService = NSQualityOfService.UserInteractive
        queue.name = "Fetch addresses data queue"
        return queue
        }()
    
    func addSetUpImportedAddressesOperation(importedAddresses: TLImportedAddresses, fetchDataAgain :Bool, success: TLWalletUtils.Success) -> Bool {
        if importedAddresses.downloadState == .QueuedForDownloading || importedAddresses.downloadState == .Downloading
            || (!fetchDataAgain && importedAddresses.downloadState == .Downloaded)  {
            return false
        }
        importedAddresses.downloadState = .QueuedForDownloading
        
        let downloader = SetUpImportedAddressesOperation(importedAddresses: importedAddresses, fetchDataAgain: fetchDataAgain)
        downloader.completionBlock = {
            if downloader.cancelled {
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                success()
            })
        }
        self.downloadQueue.addOperation(downloader)
        return true
    }
    
    func addSetUpImportedAddressOperation(importedAddress: TLImportedAddress, fetchDataAgain :Bool, success: TLWalletUtils.Success) -> Bool {
        if importedAddress.downloadState == .QueuedForDownloading || importedAddress.downloadState == .Downloading
            || (!fetchDataAgain && importedAddress.downloadState == .Downloaded)  {
            return false
        }
        importedAddress.downloadState = .QueuedForDownloading
        
        let downloader = SetUpImportedAddressOperation(importedAddress: importedAddress, fetchDataAgain: fetchDataAgain)
        downloader.completionBlock = {
            if downloader.cancelled {
                dispatch_async(dispatch_get_main_queue(), {
                    success()
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                success()
            })
        }
        self.downloadQueue.addOperation(downloader)
        return true
    }
    
    func addSetUpAccountOperation(accountObject: TLAccountObject, fetchDataAgain :Bool, success: TLWalletUtils.Success) -> Bool {
        if accountObject.downloadState == .QueuedForDownloading || accountObject.downloadState == .Downloading
            || (!fetchDataAgain && accountObject.downloadState == .Downloaded)  {
            return false
        }
        accountObject.downloadState = .QueuedForDownloading
        

        let downloader = SetUpAccountOperation(accountObject: accountObject)
        downloader.completionBlock = {
            if downloader.cancelled {
                dispatch_async(dispatch_get_main_queue(), {
                    success()
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                success()
            })
        }
        self.downloadQueue.addOperation(downloader)
        return true
    }
}

enum TLDownloadState:Int {
    case NotDownloading=0, QueuedForDownloading, Downloading, Downloaded, Failed
}

class SetUpImportedAddressOperation: NSOperation {
    let importedAddress: TLImportedAddress
    let fetchDataAgain: Bool
    init(importedAddress: TLImportedAddress, fetchDataAgain:Bool) {
        self.importedAddress = importedAddress
        self.fetchDataAgain = fetchDataAgain
        
    }
    
    override func main () {
        if self.cancelled {
            return
        }
        
        self.importedAddress.downloadState = .Downloading
        self.importedAddress.getSingleAddressDataO(self.fetchDataAgain)
    }
}

class SetUpImportedAddressesOperation: NSOperation {
    let importedAddresses: TLImportedAddresses
    let fetchDataAgain: Bool
    
    init(importedAddresses: TLImportedAddresses, fetchDataAgain:Bool) {
        self.importedAddresses = importedAddresses
        self.fetchDataAgain = fetchDataAgain
    }
    
    override func main () {
        if self.cancelled {
            return
        }

        self.importedAddresses.downloadState = .Downloading
        self.importedAddresses.checkToGetAndSetAddressesDataO(self.fetchDataAgain)
    }
}

class SetUpAccountOperation: NSOperation {
    let accountObject: TLAccountObject
    
    init(accountObject: TLAccountObject) {
        self.accountObject = accountObject
    }
    
    override func main () {
        if self.cancelled {
            return
        }
        
        self.accountObject.downloadState = .Downloading        
        self.accountObject.getAccountDataO()
    }
}