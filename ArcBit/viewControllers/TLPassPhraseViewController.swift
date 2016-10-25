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
        if (!TLPreferences.enabledAdvancedMode()) {
            self.backupPassphraseExplanation!.text = "Write down the 12 word passphrase below and keep it safe. You can restore your entire wallets' bitcoins with this single passphrase. The passphrase is also known as the seed or mnemonic.".localized
            self.masterSeedHexTitleLabel!.isHidden = true
            self.masterSeedHexTitleExplanation!.isHidden = true
            self.masterSeedHexTextView!.isHidden = true
            self.masterSeedHexTextView!.text = ("")
        } else {
            self.backupPassphraseExplanation!.text = "Write down the 12 word passphrase below and keep it safe. You can restore your entire wallets' bitcoins (excluding imports) with this single passphrase. The passphrase is also known as the seed or mnemonic.".localized
            self.masterSeedHexTitleLabel!.isHidden = false
            self.masterSeedHexTitleExplanation!.isHidden = false
            self.masterSeedHexTextView!.isHidden = false
            let masterHex = TLHDWalletWrapper.getMasterHex(passphrase ?? "")
            self.masterSeedHexTextView!.text = (masterHex)
        }
    }
    
    func passPhraseTextViewTapped(_ sender:AnyObject) {
        TLPrompts.promptSuccessMessage("", message:"The backup passphrase is not selectable on purpose, It is not recommended that you copy it to your clipboard or paste it anywhere on a device that connects to the internet. Instead the backup passphrase should be memorized or written down on a piece of paper.".localized)
    }
    
    func masterSeedHexTextViewTapped(_ sender:AnyObject) {
        TLPrompts.promptSuccessMessage("", message:"The master seed hex is not selectable on purpose, It is not recommended that you copy it to your clipboard or paste it anywhere on a device that connects to the internet.".localized)
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
