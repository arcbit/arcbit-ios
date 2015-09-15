//
//  TLReceiveViewController.swift
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

import UIKit

@objc(TLReceiveViewController) class TLReceiveViewController: UIViewController, UIScrollViewDelegate, UITabBarDelegate {
    @IBOutlet private var addressQRCodeImageView: UIImageView?
    @IBOutlet private var addressLabel: UILabel?
    @IBOutlet private var accountNameLabel: UILabel?
    @IBOutlet private var receiveAddressesScrollView: UIScrollView?
    @IBOutlet private var receiveAddressesPageControl: UIPageControl?
    @IBOutlet private var fromViewContainerButton: UIButton?
    @IBOutlet private var scrollContentView: UIView?
    @IBOutlet private var selectAccountImageView: UIImageView?
    @IBOutlet private var balanceActivityIndicatorView: UIActivityIndicatorView?
    @IBOutlet private var accountBalanceLabel: UILabel?
    @IBOutlet private var fromViewContainer: UIButton?
    @IBOutlet private var pageControlViewContainer: UIView?
    @IBOutlet private var receivingAddressPageControl: UIPageControl?
    @IBOutlet private var tabBar: UITabBar?
    
    private var pageControlBeingUsed = false
    private var receiveAddresses: NSMutableArray?
    let newAddressInfoText = "New addresses will be automatically generated and cycled for you as you use your current available addresses.".localized
    let importedWatchAccountStealthAddressInfoText = "Imported Watch Only Accounts can't see forward address payments, thus this accounts' forward address is not available. If you want see the forward address for this account import the account private key that corresponds to this accounts public key.".localized
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        
        self.setLogoImageView()
        
        self.fromViewContainer!.backgroundColor = TLColors.mainAppColor()
        self.accountNameLabel!.textColor = TLColors.mainAppOppositeColor()
        self.accountBalanceLabel!.textColor = TLColors.mainAppOppositeColor()
        self.pageControlViewContainer!.backgroundColor = TLColors.mainAppColor()
        self.receivingAddressPageControl!.backgroundColor = TLColors.mainAppColor()
        self.receiveAddressesScrollView!.backgroundColor = TLColors.mainAppColor()
        self.balanceActivityIndicatorView!.color = TLColors.mainAppOppositeColor()

        self.navigationController!.setToolbarHidden(false, animated: false)
        self.navigationController!.toolbarHidden = true

        self.tabBar!.selectedItem = ((self.tabBar!.items as NSArray!).objectAtIndex(1)) as? UITabBarItem
        if UIScreen.mainScreen().bounds.size.height <= 480.0 { // is 3.5 inch screen
            self.tabBar!.hidden = true
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshSelectedAccountAgain")
        
        self.navigationController!.view.addGestureRecognizer(self.slidingViewController().panGesture)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateReceiveViewController:",
            name: TLNotificationEvents.EVENT_ADVANCE_MODE_TOGGLED(), object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateViewToNewSelectedObject",
            name: TLNotificationEvents.EVENT_UPDATED_RECEIVING_ADDRESSES(), object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self
            , selector: "updateViewToNewSelectedObjectAndAlertNewText",
            name: TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_UNCONFIRMED_TRANSACTION(), object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self
            , selector: "updateViewToNewSelectedObject",
            name: TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED(), object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self
            , selector: "updateViewToNewSelectedObject",
            name: TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA(), object: nil)

        
        NSNotificationCenter.defaultCenter().addObserver(self
            , selector: "updateViewToNewSelectedObject",
            name: TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED(), object: nil)
        
        self.receiveAddressesScrollView!.delegate = self
        
        let singleFingerTap = UITapGestureRecognizer(target: self, action: "singleFingerTap")
        self.receiveAddressesScrollView!.addGestureRecognizer(singleFingerTap)
        
        if (AppDelegate.instance().justSetupHDWallet) {
            AppDelegate.instance().justSetupHDWallet = false
            TLPrompts.promptSuccessMessage("Welcome!".localized, message: "Start using the app now by depositing your Bitcoins here.".localized)
        }
        
        self.refreshSelectedAccount(false)
    }
    
    override func viewWillAppear(animated: Bool) -> () {
        self.updateViewToNewSelectedObject()
    }
    
    override func viewDidAppear(animated: Bool) -> () {
        NSNotificationCenter.defaultCenter().postNotificationName(TLNotificationEvents.EVENT_VIEW_RECEIVE_SCREEN(), object: nil, userInfo: nil)
        
        if (TLSuggestions.instance().conditionToPromptToSuggestedBackUpWalletPassphraseSatisfied()) {
            TLSuggestions.instance().promptToSuggestBackUpWalletPassphrase(self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refreshSelectedAccountAgain() {
        self.refreshSelectedAccount(true)
    }
    
    private func refreshSelectedAccount(fetchDataAgain: Bool) {
        if (!AppDelegate.instance().receiveSelectedObject!.hasFetchedCurrentFromData() || fetchDataAgain) {
            self.balanceActivityIndicatorView!.hidden = false
            self.accountBalanceLabel!.hidden = true
            self.balanceActivityIndicatorView!.startAnimating()

            if (AppDelegate.instance().receiveSelectedObject!.getSelectedObjectType() == .Account) {
                let accountObject = AppDelegate.instance().receiveSelectedObject!.getSelectedObject() as! TLAccountObject

                AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: fetchDataAgain, success: {
                    self.accountBalanceLabel!.hidden = false
                    self.balanceActivityIndicatorView!.stopAnimating()
                    self.balanceActivityIndicatorView!.hidden = true
                    if accountObject.downloadState != .Downloaded {
                        self.updateAccountBalance()
                    }
                })
                
            } else if (AppDelegate.instance().receiveSelectedObject!.getSelectedObjectType() == .Address) {
                let importedAddress = AppDelegate.instance().receiveSelectedObject!.getSelectedObject() as! TLImportedAddress
                
                AppDelegate.instance().pendingOperations.addSetUpImportedAddressOperation(importedAddress, fetchDataAgain: fetchDataAgain, success: {
                    self.accountBalanceLabel!.hidden = false
                    self.balanceActivityIndicatorView!.stopAnimating()
                    self.balanceActivityIndicatorView!.hidden = true
                    if importedAddress.downloadState != .Downloaded {
                        self.updateAccountBalance()
                    }
                })
            }
        } else {
            let balance = TLWalletUtils.getProperAmount(AppDelegate.instance().historySelectedObject!.getBalanceForSelectedObject()!)
            accountBalanceLabel!.text = balance as String
            self.balanceActivityIndicatorView!.hidden = true
        }
    }
    
    override func showSendView() {
        self.slidingViewController().topViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SendNav") as! UIViewController
    }
    
    func singleFingerTap() {
        if self.receiveAddresses == nil {
            // receiveAddresses not loaded yet
            return
        }
        let address = self.receiveAddresses!.objectAtIndex(self.receiveAddressesPageControl!.currentPage) as! String
        let pasteboard = UIPasteboard.generalPasteboard()
        pasteboard.string = address
        iToast.makeText("Copied To clipboard".localized).setGravity(iToastGravityCenter).setDuration(1000).show()
    }
    
    @IBAction private func scrollViewClicked(sender: AnyObject) {
        if self.receiveAddresses == nil {
            // receiveAddresses not loaded yet
            return
        }
        let address = self.receiveAddresses!.objectAtIndex(self.receiveAddressesPageControl!.currentPage) as! String
        let pasteboard = UIPasteboard.generalPasteboard()
        pasteboard.string = address
        iToast.makeText("Copied To clipboard".localized).setGravity(iToastGravityCenter).setDuration(1000).show()
    }
    
    private func getAddressInfoLabel(frame: CGRect, text: String) -> UILabel {
        let addressInfoLabel = UILabel(frame: frame)
        addressInfoLabel.textAlignment = .Center
        addressInfoLabel.text = text
        addressInfoLabel.textColor = TLColors.mainAppOppositeColor()
        addressInfoLabel.numberOfLines = 0
        return addressInfoLabel
    }
    
    private func getPageWidth() -> CGFloat {
        if (UIScreen.mainScreen().bounds.size.width > 414) {
            //is iPad
            return UIScreen.mainScreen().bounds.size.width - 16
        }
        if (UIScreen.mainScreen().bounds.size.width == 414) {
            //is iPhone6+
            return UIScreen.mainScreen().bounds.size.width - 16 - 8
        }
        
        return UIScreen.mainScreen().bounds.size.width - 16
    }
    
    private func getLastPageView(lastPageCount: Int, text: String) -> UIView {
        let pageWidth = self.getPageWidth()
        
        var frame = CGRect()
        frame.origin.x = CGFloat(pageWidth * CGFloat(lastPageCount))
        frame.origin.y = 0
        frame.size = self.receiveAddressesScrollView!.frame.size
        let pageView = UIView(frame: frame)
        
        let QRCodeImageWidth = pageWidth - 40
        
        let xToBeInCenter = (pageWidth - QRCodeImageWidth) / 2
        let imageViewFrame = CGRectMake(xToBeInCenter,
            0,
            QRCodeImageWidth,
            QRCodeImageWidth)
        
        pageView.addSubview(self.getAddressInfoLabel(imageViewFrame, text: text))
        
        pageView.backgroundColor = TLColors.mainAppColor()
        
        return pageView
    }
    
    private func updateReceiveAddressesView() {
        self.scrollContentView!.autoresizesSubviews = false
        
        var numPages = 0
        if (self.receiveAddresses!.count != 1) {
            if (TLWalletUtils.ENABLE_STEALTH_ADDRESS()) {
                numPages = TLAccountObject.MAX_ACCOUNT_WAIT_TO_RECEIVE_ADDRESS() + TLAccountObject.NUM_ACCOUNT_STEALTH_ADDRESSES() + 1
            } else {
                numPages = TLAccountObject.MAX_ACCOUNT_WAIT_TO_RECEIVE_ADDRESS() + 1
            }
        } else {
            numPages = 1
        }
        
        var pageControlBeingUsed = false
        
        var pageWidth = self.getPageWidth()
        let pageHeight:CGFloat
        if UIScreen.mainScreen().bounds.size.height > 480.0 {
            pageHeight = pageWidth
        } else { // is 3.5 inch screen
            pageHeight = pageWidth - 100
        }
        
        var pageCount = 0

        for (var i = 0; i < self.receiveAddresses!.count; i++) {
            pageCount++
            
            var frame = CGRect()
            frame.origin.x = pageWidth * CGFloat(i)
            frame.origin.y = 0
            frame.size = self.receiveAddressesScrollView!.frame.size
            let pageView = UIView(frame: frame)
            
            let QRCodeImageWidth:CGFloat
            if UIScreen.mainScreen().bounds.size.height > 480.0 {
                QRCodeImageWidth = pageWidth - 30
            } else { // is 3.5 inch screen
                QRCodeImageWidth = pageWidth - 110
            }
            
            let xToBeInCenter = (pageWidth - QRCodeImageWidth) / 2.0
            let imageViewFrame = CGRectMake(xToBeInCenter,
                0,
                QRCodeImageWidth,
                QRCodeImageWidth)
            
            if (i < self.receiveAddresses!.count - 1 || AppDelegate.instance().receiveSelectedObject!.getSelectedObjectType() == .Address) {
                    
                    
                let address = self.receiveAddresses!.objectAtIndex(i) as! String
                let QRCodeImage = getQRCodeImage(address, size: QRCodeImageWidth - 5)
                    
                let QRCodeImageView = UIImageView(frame: imageViewFrame)
                QRCodeImageView.image = QRCodeImage
                pageView.addSubview(QRCodeImageView)
                    
                let addressLabelY: CGFloat
                let infoLabelY: CGFloat
                if (UIScreen.mainScreen().bounds.size.width <= 320) {
                    //is <= iPhone5s
                    addressLabelY = QRCodeImageWidth + 5
                    infoLabelY = QRCodeImageWidth - 15
                } else {
                    addressLabelY = QRCodeImageWidth + 21
                    infoLabelY = QRCodeImageWidth
                }
                    
                let addressLabelFrame = CGRectMake(xToBeInCenter,
                    addressLabelY,
                    QRCodeImageWidth,
                    21)
                let labelEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5)
                    
                let addressLabel = UILabel(frame: UIEdgeInsetsInsetRect(addressLabelFrame, labelEdgeInsets))
                addressLabel.textColor = TLColors.mainAppOppositeColor()
                addressLabel.adjustsFontSizeToFitWidth = true
                addressLabel.textAlignment = .Center
                addressLabel.font = UIFont.boldSystemFontOfSize(addressLabel.font.pointSize)
                addressLabel.text = address
                if count(address) > 35 { // is stealth address
                    addressLabel.numberOfLines = 2
                } else {
                    addressLabel.numberOfLines = 1
                }
                pageView.addSubview(addressLabel)
                    
                if (TLStealthAddress.isStealthAddress(address, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)) {
                    let infoLabelFrame = CGRectMake(xToBeInCenter,
                        infoLabelY,
                        QRCodeImageWidth,
                        21)
                        
                    let infoLabel = UILabel(frame: UIEdgeInsetsInsetRect(infoLabelFrame, labelEdgeInsets))
                    infoLabel.textColor = TLColors.mainAppOppositeColor()
                    infoLabel.font = UIFont.boldSystemFontOfSize(addressLabel.font.pointSize - 5)
                    infoLabel.text = "Forward Address:".localized
                    pageView.addSubview(infoLabel)
                    //QRCodeImageView.backgroundColor = UIColor.orangeColor()
                }
            } else {
                if AppDelegate.instance().receiveSelectedObject!.getAccountType() == .ImportedWatch {
                    pageView.addSubview(self.getAddressInfoLabel(imageViewFrame, text: importedWatchAccountStealthAddressInfoText))
                } else {
                    pageView.addSubview(self.getAddressInfoLabel(imageViewFrame, text: newAddressInfoText))
                }
            }
            
            pageView.backgroundColor = TLColors.mainAppColor()
            //if (i % 2 == 0) {pageView.backgroundColor = UIColor.yellowColor()}
            
            self.scrollContentView!.addSubview(pageView)
        }
        
        while (pageCount < numPages) {
            self.scrollContentView!.addSubview(self.getLastPageView(pageCount, text: newAddressInfoText))
            pageCount++
        }
        
        self.receiveAddressesScrollView!.contentSize = CGSizeMake(pageWidth * CGFloat(numPages),
            CGFloat(pageHeight))
        
        self.receiveAddressesPageControl!.currentPage = 0
        self.receiveAddressesPageControl!.numberOfPages = numPages
        
        if (self.receiveAddressesPageControl!.numberOfPages > 1) {
            self.receiveAddressesPageControl!.hidden = false
            self.pageControlViewContainer!.hidden = false
        } else {
            self.receiveAddressesPageControl!.hidden = true
            self.pageControlViewContainer!.hidden = true
        }
    }

    private func updateReceiveAddressArray() {
        let receivingAddressesCount = AppDelegate.instance().receiveSelectedObject!.getReceivingAddressesCount()
        self.receiveAddresses = NSMutableArray(capacity: Int(receivingAddressesCount))
        for (var i = 0; i < Int(receivingAddressesCount); i++) {
            let address = AppDelegate.instance().receiveSelectedObject!.getReceivingAddressForSelectedObject(i)
            self.receiveAddresses!.addObject(address!)
        }

        if (TLWalletUtils.ENABLE_STEALTH_ADDRESS()) {
            if (AppDelegate.instance().receiveSelectedObject!.getSelectedObjectType() == .Account) {
                if let stealthAddress = AppDelegate.instance().receiveSelectedObject!.getStealthAddress() {
                    if (TLPreferences.enabledStealthAddressDefault()) {
                        self.receiveAddresses!.insertObject(stealthAddress, atIndex: 0)
                    } else {
                        self.receiveAddresses!.addObject(stealthAddress)
                    }                    
                }
            }
        }

        if (AppDelegate.instance().receiveSelectedObject!.getSelectedObjectType() == .Account) {
            self.receiveAddresses!.addObject("End")
        }
    }

    func updateViewToNewSelectedObjectAndAlertNewText() {
        let oldBalance = self.accountBalanceLabel!.text
        updateViewToNewSelectedObject()
    }
    
    func updateViewToNewSelectedObject() {
        self.updateAccountBalance()
        let receivingAddressesCount = AppDelegate.instance().receiveSelectedObject!.getReceivingAddressesCount()
        if (receivingAddressesCount == 0) {
            // this happens if receiving addresses have not been computed yet (cuz it requires look ups), thus don't update UI yet
            // EVENT_UPDATED_RECEIVING_ADDRESSES will fire and this method be called
            return
        }
        let address = AppDelegate.instance().receiveSelectedObject!.getReceivingAddressForSelectedObject(0)
        let label = AppDelegate.instance().receiveSelectedObject!.getLabelForSelectedObject()
        self.accountNameLabel!.text = label
        self.updateReceiveAddressArray()
        self.updateReceiveAddressesView()
        self.scrollToPage(0)
    }

    private func updateAccountBalance() {
        let balance = AppDelegate.instance().receiveSelectedObject!.getBalanceForSelectedObject()
        let balanceString = TLWalletUtils.getProperAmount(balance!)
        
        if AppDelegate.instance().receiveSelectedObject!.getDownloadState() == .Downloaded {
            self.balanceActivityIndicatorView!.stopAnimating()
            self.balanceActivityIndicatorView!.hidden = true
            self.accountBalanceLabel!.text = balanceString as String
            self.accountBalanceLabel!.hidden = false
        }
    }

    private func getQRCodeImage(address: String, size: CGFloat) -> UIImage {
        //let QRCodeData = TLWalletUtils.getBitcoinURI(address, amount: TLCoin.zero(), label: nil, message: nil)
        let QRCodeData = address
        let QRCodeImage = TLWalletUtils.getQRCodeImage(QRCodeData,
                imageDimension: Int(size))

        return QRCodeImage
    }

    func updateReceiveViewController(notification: NSNotification) {
        if (TLPreferences.enabledAdvanceMode()) {
            //self.addressLabel!.hidden = false
        } else {
            //self.addressLabel!.hidden = true
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> () {
        if(segue.identifier == "selectAccount") {
            let vc = segue.destinationViewController as! UIViewController
            vc.navigationItem.title = "Select Account".localized
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "onAccountSelected:", name: TLNotificationEvents.EVENT_ACCOUNT_SELECTED(), object: nil)
        }
    }

    func onAccountSelected(note: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: TLNotificationEvents.EVENT_ACCOUNT_SELECTED(), object: nil)
        let selectedDict = note.object as! NSDictionary
        let sendFromType = TLSendFromType(rawValue: selectedDict.objectForKey("sendFromType") as! Int)

        let sendFromIndex = selectedDict.objectForKey("sendFromIndex") as! Int
        AppDelegate.instance().updateReceiveSelectedObject(sendFromType!, sendFromIndex: sendFromIndex)

        self.updateViewToNewSelectedObject()
    }

    private func scrollToPage(page: NSInteger) {
        // Update the scroll view to the appropriate page
        var frame = CGRect()
        frame.origin.x = self.receiveAddressesScrollView!.frame.size.width * CGFloat(page)
        frame.origin.y = 0
        frame.size = self.receiveAddressesScrollView!.frame.size
        self.receiveAddressesScrollView!.scrollRectToVisible(frame, animated: true)

        // Keep track of when scrolls happen in response to the page control
        // value changing. If we don't do this, a noticeable "flashing" occurs
        // as the the scroll delegate will temporarily switch back the page
        // number.
        pageControlBeingUsed = true
    }

    @IBAction private func changePage(sender: AnyObject) {
        self.scrollToPage(self.receiveAddressesPageControl!.currentPage)
    }

    @IBAction private func menuButtonClicked(sender: AnyObject) {
        self.slidingViewController().anchorTopViewToRightAnimated(true)
    }

    func scrollViewDidScroll(sender: UIScrollView) {
        if (!pageControlBeingUsed) {
            // change page when more than 50% of the previous/next page is visible
            let pageWidth = self.receiveAddressesScrollView!.frame.size.width
            let page = floor((self.receiveAddressesScrollView!.contentOffset.x - pageWidth / 2) / pageWidth) + 1
            self.receiveAddressesPageControl!.currentPage = Int(page)
        }
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        pageControlBeingUsed = false
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControlBeingUsed = false
    }

    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if (item.tag == 0) {
            self.showSendView()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

