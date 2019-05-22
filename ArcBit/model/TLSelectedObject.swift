//
//  TLSelectedObject.swift
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

protocol TLSelectedObject {
    func getSelectedObjectCoinType() -> TLCoinType
    func getDownloadState() -> TLDownloadState
    func getBalanceForSelectedObject() -> TLCoin?
    func getLabelForSelectedObject() -> String?
    func getReceivingAddressesCount() -> Int
    func getReceivingAddressForSelectedObject(_ idx:Int) -> String?
    func hasFetchedCurrentFromData() -> Bool
    func isAddressPartOfAccount(_ address: String) -> Bool
    func getTxObjectCount() -> Int
    func getTxObject(_ txIdx:Int) -> TLTxObject?
    func getAccountAmountChangeForTx(_ txHash: String) -> TLCoin?
    func getAccountAmountChangeTypeForTx(_ txHash: String) -> TLAccountTxType
    func getSelectedObjectType() -> TLSelectObjectType
    func getSelectedObject() -> AnyObject?
    func getAccountType() -> TLAccountType

    func isPaymentToOwnAccount(_ address: String) -> Bool
    func haveUpDatedUnspentOutputs() -> Bool
    func getCurrentFromLabel() -> String?
    func isColdWalletAccount() -> Bool
    func needWatchOnlyAccountPrivateKey() -> Bool
    func needWatchOnlyAddressPrivateKey() -> Bool
    func needEncryptedPrivateKeyPassword() -> Bool
    func setCurrentFromBalance(_ balance: TLCoin)
    func getCurrentFromBalance() -> TLCoin
    func getCurrentFromUnspentOutputsSum() -> TLCoin
    func getAndSetUnspentOutputs(_ success:@escaping TLWalletUtils.Success, failure:@escaping TLWalletUtils.Error)
}
