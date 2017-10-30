//
//  TLPassPhraseViewController.swift
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
import UIKit

@objc(TLPassPhraseViewController) class TLPassPhraseViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet fileprivate var navigationBar:UINavigationBar?
    @IBOutlet weak var walletBackupPassphraseLabel: UILabel!
    @IBOutlet fileprivate var  backupPassphraseExplanation:UILabel?
    @IBOutlet fileprivate var passPhraseTextView:UITextView?
    @IBOutlet fileprivate var masterSeedHexTitleLabel:UILabel?
    @IBOutlet fileprivate var masterSeedHexTitleExplanation:UILabel?
    @IBOutlet fileprivate var masterSeedHexTextView:UITextView?
    
    override var preferredStatusBarStyle : (UIStatusBarStyle) {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarColors(self.navigationBar!)
        self.navigationBar?.topItem?.title = TLDisplayStrings.PASSPHRASE_STRING()
        self.walletBackupPassphraseLabel?.text = TLDisplayStrings.WALLET_BACKUP_PASSPHRASE_STRING()

        self.passPhraseTextView!.isSelectable = false
        self.masterSeedHexTextView!.isSelectable = false
        let passPhraseTextViewGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(TLPassPhraseViewController.passPhraseTextViewTapped(_:)))
        self.passPhraseTextView!.addGestureRecognizer(passPhraseTextViewGestureRecognizer)
        let masterSeedHexGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(TLPassPhraseViewController.masterSeedHexTextViewTapped(_:)))
        self.masterSeedHexTextView!.addGestureRecognizer(masterSeedHexGestureRecognizer)
        
        self.passPhraseTextView!.backgroundColor = TLColors.mainAppColor()
        self.passPhraseTextView!.textColor = (TLColors.mainAppOppositeColor())
        self.masterSeedHexTextView!.backgroundColor = TLColors.mainAppColor()
        self.masterSeedHexTextView!.textColor = TLColors.mainAppOppositeColor()
        
        let passphrase = TLWalletPassphrase.getDecryptedWalletPassphrase()
        self.passPhraseTextView!.text = (passphrase)
//        if (!TLPreferences.enabledAdvancedMode()) {
            self.backupPassphraseExplanation!.text = TLDisplayStrings.BACKUP_PASSPHRASE_EXPLANATION_STRING()
            self.masterSeedHexTitleLabel!.isHidden = true
            self.masterSeedHexTitleExplanation!.isHidden = true
            self.masterSeedHexTextView!.isHidden = true
            self.masterSeedHexTextView!.text = ("")
//        } else {
//            self.backupPassphraseExplanation!.text = TLDisplayStrings.BACKUP_PASSPHRASE_ADVANCED_EXPLANATION_STRING()
//            self.masterSeedHexTitleLabel!.isHidden = false
//            self.masterSeedHexTitleExplanation!.isHidden = false
//            self.masterSeedHexTextView!.isHidden = false
//            let masterHex = TLHDWalletWrapper.getMasterHex(passphrase ?? "")
//            self.masterSeedHexTextView!.text = (masterHex)
//        }
    }
    
    func passPhraseTextViewTapped(_ sender:AnyObject) {
    }
    
    func masterSeedHexTextViewTapped(_ sender:AnyObject) {
    }
    
    override func viewDidAppear(_ animated:Bool) -> () {
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_BACKUP_PASSPHRASE()),
            object:nil, userInfo:nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction fileprivate func cancel(_ sender:AnyObject) {
        self.passPhraseTextView!.resignFirstResponder()
        self.dismiss(animated: true, completion:nil)
    }
}
