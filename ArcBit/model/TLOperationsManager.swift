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
    fileprivate lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.qualityOfService = QualityOfService.userInteractive
        queue.name = "Fetch addresses data queue"
        return queue
        }()
    
    func addSetUpImportedAddressesOperation(_ importedAddresses: TLImportedAddresses, fetchDataAgain :Bool, success: @escaping TLWalletUtils.Success) -> Bool {
        if importedAddresses.downloadState == .queuedForDownloading || importedAddresses.downloadState == .downloading
            || (!fetchDataAgain && importedAddresses.downloadState == .downloaded)  {
            return false
        }
        importedAddresses.downloadState = .queuedForDownloading
        
        let downloader = SetUpImportedAddressesOperation(importedAddresses: importedAddresses, fetchDataAgain: fetchDataAgain)
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            DispatchQueue.main.async(execute: {
                success()
            })
        }
        self.downloadQueue.addOperation(downloader)
        return true
    }
    
    func addSetUpImportedAddressOperation(_ importedAddress: TLImportedAddress, fetchDataAgain :Bool, success: @escaping TLWalletUtils.Success) -> Bool {
        if importedAddress.downloadState == .queuedForDownloading || importedAddress.downloadState == .downloading
            || (!fetchDataAgain && importedAddress.downloadState == .downloaded)  {
            return false
        }
        importedAddress.downloadState = .queuedForDownloading
        
        let downloader = SetUpImportedAddressOperation(importedAddress: importedAddress, fetchDataAgain: fetchDataAgain)
        downloader.completionBlock = {
            if downloader.isCancelled {
                DispatchQueue.main.async(execute: {
                    success()
                })
                return
            }
            DispatchQueue.main.async(execute: {
                success()
            })
        }
        self.downloadQueue.addOperation(downloader)
        return true
    }
    
    func addSetUpAccountOperation(_ accountObject: TLAccountObject, fetchDataAgain :Bool, success: @escaping TLWalletUtils.Success) -> Bool {
        if accountObject.downloadState == .queuedForDownloading || accountObject.downloadState == .downloading
            || (!fetchDataAgain && accountObject.downloadState == .downloaded)  {
            return false
        }
        accountObject.downloadState = .queuedForDownloading
        

        let downloader = SetUpAccountOperation(accountObject: accountObject)
        downloader.completionBlock = {
            if downloader.isCancelled {
                DispatchQueue.main.async(execute: {
                    success()
                })
                return
            }
            DispatchQueue.main.async(execute: {
                success()
            })
        }
        self.downloadQueue.addOperation(downloader)
        return true
    }
}

enum TLDownloadState:Int {
    case notDownloading=0, queuedForDownloading, downloading, downloaded, failed
}

class SetUpImportedAddressOperation: Operation {
    let importedAddress: TLImportedAddress
    let fetchDataAgain: Bool
    init(importedAddress: TLImportedAddress, fetchDataAgain:Bool) {
        self.importedAddress = importedAddress
        self.fetchDataAgain = fetchDataAgain
        
    }
    
    override func main () {
        if self.isCancelled {
            return
        }
        
        self.importedAddress.downloadState = .downloading
        self.importedAddress.getSingleAddressDataO(self.fetchDataAgain)
    }
}

class SetUpImportedAddressesOperation: Operation {
    let importedAddresses: TLImportedAddresses
    let fetchDataAgain: Bool
    
    init(importedAddresses: TLImportedAddresses, fetchDataAgain:Bool) {
        self.importedAddresses = importedAddresses
        self.fetchDataAgain = fetchDataAgain
    }
    
    override func main () {
        if self.isCancelled {
            return
        }

        self.importedAddresses.downloadState = .downloading
        self.importedAddresses.checkToGetAndSetAddressesDataO(self.fetchDataAgain)
    }
}

class SetUpAccountOperation: Operation {
    let accountObject: TLAccountObject
    
    init(accountObject: TLAccountObject) {
        self.accountObject = accountObject
    }
    
    override func main () {
        if self.isCancelled {
            return
        }
        
        self.accountObject.downloadState = .downloading        
        self.accountObject.getAccountDataO()
    }
}
