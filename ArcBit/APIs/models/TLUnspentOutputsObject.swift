//
//  UnspentOutputsObject.swift
//  ArcBit
//
//  Created by Timothy Lee on 1/16/18.
//  Copyright © 2018 ArcBit. All rights reserved.
//

import Foundation

class TLUnspentOutputObject {
    let txHash:String
    let txHashBigEndian:String
    let txOutputN:UInt64
    let script:String
    let value:UInt64
    let confirmations:UInt64

    init(_ jsonDict: NSDictionary) {
        self.txHash = jsonDict["tx_hash"] as! String
        self.txHashBigEndian = jsonDict["tx_hash_big_endian"] as! String
        self.txOutputN = jsonDict["tx_output_n"] as! UInt64
        self.script = jsonDict["script"] as! String
        self.value = jsonDict["value"] as! UInt64
        self.confirmations = jsonDict["confirmations"] as! UInt64
    }
}

class TLUnspentOutputsObject {
    
    lazy var unspentOutputs = Array<TLUnspentOutputObject>()

    init(_ jsonDict: AnyObject, blockExplorerJSONType: TLBlockExplorer) {
        switch blockExplorerJSONType {
        case .blockchain:
            let unspent_outputs = (jsonDict as! NSDictionary).object(forKey: "unspent_outputs") as! NSArray
            for _unspentOutput in unspent_outputs {
                let unspentOutput = _unspentOutput as! NSDictionary
                self.unspentOutputs.append(TLUnspentOutputObject(unspentOutput))
            }
        case .insight:
//            let transansformedJsonData = insightUnspentOutputsToBlockchainUnspentOutputs(jsonDict as! NSArray) as NSDictionary
//            let unspent_outputs = transansformedJsonData.object(forKey: "unspent_outputs") as! NSArray
//            for _unspentOutput in unspent_outputs {
//                let unspentOutput = _unspentOutput as! NSDictionary
//                self.unspentOutputs.append(UnspentOutputObject(unspentOutput))
//            }
            
            let unspent_outputs = (jsonDict as! NSDictionary).object(forKey: "unspent_outputs") as! NSArray
            for _unspentOutput in unspent_outputs {
                let unspentOutput = _unspentOutput as! NSDictionary
                self.unspentOutputs.append(TLUnspentOutputObject(unspentOutput))
            }
        }
    }
    
//    class func insightUnspentOutputsToBlockchainUnspentOutputs(_ unspentOutputs: NSArray) -> NSDictionary {
//        let transansformedUnspentOutputs = NSMutableArray(capacity: unspentOutputs.count)
//
//        for _unspentOutput in unspentOutputs {
//            let unspentOutput = _unspentOutput as! NSDictionary
//            if let dict = TLInsightAPI.insightToBlockchainUnspentOutput(unspentOutput) {
//                transansformedUnspentOutputs.add(dict)
//            }
//        }
//
//        let transansformedJsonData = NSMutableDictionary()
//        transansformedJsonData.setObject(transansformedUnspentOutputs, forKey: "unspent_outputs" as NSCopying)
//
//        return transansformedJsonData
//    }
}
