//
//  TLSelectCryptoCoinViewController.swift
//  ArcBit
//
//  Created by Timothy Lee on 1/7/18.
//  Copyright © 2018 ArcBit. All rights reserved.
//

import Foundation
import UIKit

protocol TLSelectCryptoCoinViewControllerDelegate {
    func didSelectCryptoCoin(_ coinType: TLCoinType)
}

@objc(TLSelectCryptoCoinViewController) class TLSelectCryptoCoinViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: TLSelectCryptoCoinViewControllerDelegate?
    @IBOutlet fileprivate var tableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var preferredStatusBarStyle : (UIStatusBarStyle) {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func numberOfSections(in tableView: UITableView) -> (Int) {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TLWalletUtils.SUPPORT_COIN_TYPES().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let MyIdentifier = "SelectCryptoCoinCellIdentifier"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default,
                                   reuseIdentifier: MyIdentifier)
        }
        
        let coinType = TLWalletUtils.SUPPORT_COIN_TYPES()[(indexPath as NSIndexPath).row]
        cell!.textLabel!.text = "\(TLWalletUtils.GET_CRYPTO_COIN_FULL_NAME(coinType)) (\(coinType.rawValue))"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.navigationController!.popViewController(animated: true)
        let coinType = TLWalletUtils.SUPPORT_COIN_TYPES()[(indexPath as NSIndexPath).row]
        self.delegate?.didSelectCryptoCoin(coinType)
        return nil
    }
}

