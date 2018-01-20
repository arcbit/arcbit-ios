//
//  AddressesObject.swift
//  ArcBit
//
//  Created by Timothy Lee on 1/17/18.
//  Copyright © 2018 ArcBit. All rights reserved.
//

import Foundation

class TLAddressObject {
    
    let address:String
    let nTx:Int
    let finalBalance:UInt64

    init(_ jsonDict: NSDictionary) {
        self.address = jsonDict["address"] as! String
        self.nTx = jsonDict["n_tx"] as! Int
        self.finalBalance = jsonDict["final_balance"] as! UInt64
    }
}

class TLAddressesObject {
    
    lazy var addresses = Array<TLAddressObject>()
    lazy var txs = Array<TLTxObject>()

    init(_ jsonDict: NSDictionary) {
        
        let addressesArray = jsonDict.object(forKey: "addresses") as! NSArray
        var balance:UInt64 = 0
        for _addressDict in addressesArray {
            let addressDict = _addressDict as! NSDictionary
            let addressObject = TLAddressObject(addressDict)
            addresses.append(addressObject)
            balance += addressObject.finalBalance
        }

        let txArray = jsonDict.object(forKey: "txs") as! NSArray
        for _tx in txArray {
            let tx = _tx as! NSDictionary
            let txObject = TLTxObject(tx)
            txs.append(txObject)
        }
    }
}
