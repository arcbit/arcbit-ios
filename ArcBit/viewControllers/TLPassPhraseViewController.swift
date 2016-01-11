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
    
    @IBOutlet private var navigationBar:UINavigationBar?
    @IBOutlet private var  backupPassphraseExplanation:UILabel?
    @IBOutlet private var passPhraseTextView:UITextView?
    @IBOutlet private var masterSeedHexTitleLabel:UILabel?
    @IBOutlet private var masterSeedHexTitleExplanation:UILabel?
    @IBOutlet private var masterSeedHexTextView:UITextView?
    
    override func preferredStatusBarStyle() -> (UIStatusBarStyle) {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarColors(self.navigationBar!)
        
        self.passPhraseTextView!.selectable = false
        self.masterSeedHexTextView!.selectable = false
        let passPhraseTextViewGestureRecognizer = UITapGestureRecognizer(target: self, action:"passPhraseTextViewTapped:")
        self.passPhraseTextView!.addGestureRecognizer(passPhraseTextViewGestureRecognizer)
        let masterSeedHexGestureRecognizer = UITapGestureRecognizer(target:self, action:"masterSeedHexTextViewTapped:")
        self.masterSeedHexTextView!.addGestureRecognizer(masterSeedHexGestureRecognizer)
        
        self.passPhraseTextView!.backgroundColor = TLColors.mainAppColor()
        self.passPhraseTextView!.textColor = (TLColors.mainAppOppositeColor())
        self.masterSeedHexTextView!.backgroundColor = TLColors.mainAppColor()
        self.masterSeedHexTextView!.textColor = TLColors.mainAppOppositeColor()
        
        let passphrase = TLWalletPassphrase.getDecryptedWalletPassphrase()
        self.passPhraseTextView!.text = (passphrase)
        if (!TLPreferences.enabledAdvancedMode()) {
            self.backupPassphraseExplanation!.text = "Write down the 12 word passphrase below and keep it safe. You can restore your entire wallets' bitcoins with this single passphrase. The passphrase is also known as the seed or mnemonic.".localized
            self.masterSeedHexTitleLabel!.hidden = true
            self.masterSeedHexTitleExplanation!.hidden = true
            self.masterSeedHexTextView!.hidden = true
            self.masterSeedHexTextView!.text = ("")
        } else {
            self.backupPassphraseExplanation!.text = "Write down the 12 word passphrase below and keep it safe. You can restore your entire wallets' bitcoins (excluding imports) with this single passphrase. The passphrase is also known as the seed or mnemonic.".localized
            self.masterSeedHexTitleLabel!.hidden = false
            self.masterSeedHexTitleExplanation!.hidden = false
            self.masterSeedHexTextView!.hidden = false
            let masterHex = TLHDWalletWrapper.getMasterHex(passphrase ?? "")
            self.masterSeedHexTextView!.text = (masterHex)
        }
    }
    
    func passPhraseTextViewTapped(sender:AnyObject) {
        TLPrompts.promptSuccessMessage("", message:"The backup passphrase is not selectable on purpose, It is not recommended that you copy it to your clipboard or paste it anywhere on a device that connects to the internet. Instead the backup passphrase should be memorized or written down on a piece of paper.".localized)
    }
    
    func masterSeedHexTextViewTapped(sender:AnyObject) {
        TLPrompts.promptSuccessMessage("", message:"The master seed hex is not selectable on purpose, It is not recommended that you copy it to your clipboard or paste it anywhere on a device that connects to the internet.".localized)
    }
    
    override func viewDidAppear(animated:Bool) -> () {
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_BACKUP_PASSPHRASE(),
            object:nil, userInfo:nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction private func cancel(sender:AnyObject) {
        self.passPhraseTextView!.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion:nil)
    }
}
