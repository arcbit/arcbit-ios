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
    @IBOutlet fileprivate var addressQRCodeImageView: UIImageView?
    @IBOutlet fileprivate var addressLabel: UILabel?
    @IBOutlet fileprivate var accountNameLabel: UILabel?
    @IBOutlet fileprivate var receiveAddressesScrollView: UIScrollView?
    @IBOutlet fileprivate var receiveAddressesPageControl: UIPageControl?
    @IBOutlet fileprivate var fromViewContainerButton: UIButton?
    @IBOutlet fileprivate var scrollContentView: UIView?
    @IBOutlet fileprivate var selectAccountImageView: UIImageView?
    @IBOutlet fileprivate var balanceActivityIndicatorView: UIActivityIndicatorView?
    @IBOutlet fileprivate var accountBalanceLabel: UILabel?
    @IBOutlet fileprivate var fromViewContainer: UIButton?
    @IBOutlet fileprivate var pageControlViewContainer: UIView?
    @IBOutlet fileprivate var receivingAddressPageControl: UIPageControl?
    @IBOutlet fileprivate var tabBar: UITabBar?
    @IBOutlet weak var receiveLabel: UILabel!
    
    fileprivate var pageControlBeingUsed = false
    fileprivate var receiveAddresses: NSMutableArray?
    let newAddressInfoText = TLDisplayStrings.NEW_ADDRESSES_WILL_BE_AUTOMATICALLY_GENERATED_DESC_STRING()
    let importedWatchAccountStealthAddressInfoText = TLDisplayStrings.IMPORTED_WATCH_ONLY_ACCOUNTS_REUSABLE_ADDRESS_INFO_DESC_STRING()
    let coldWalletAccountStealthAddressInfoText = TLDisplayStrings.IMPORTED_COLD_WALLET_ACCOUNTS_REUSABLE_ADDRESS_INFO_DESC_STRING()
    
    func setupLabels() {
        let sendTabBarItem = self.tabBar?.items?[0]
        sendTabBarItem?.title = TLDisplayStrings.SEND_STRING()
        let receiveTabBarItem = self.tabBar?.items?[1]
        receiveTabBarItem?.title = TLDisplayStrings.RECEIVE_STRING()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        
        self.setLogoImageView()
        self.setupLabels()

        self.receiveLabel.text = TLDisplayStrings.FROM_COLON_STRING()
        self.fromViewContainer!.backgroundColor = TLColors.mainAppColor()
        self.accountNameLabel!.textColor = TLColors.mainAppOppositeColor()
        self.accountBalanceLabel!.textColor = TLColors.mainAppOppositeColor()
        self.pageControlViewContainer!.backgroundColor = TLColors.mainAppColor()
        self.receivingAddressPageControl!.backgroundColor = TLColors.mainAppColor()
        self.receiveAddressesScrollView!.backgroundColor = TLColors.mainAppColor()
        self.balanceActivityIndicatorView!.color = TLColors.mainAppOppositeColor()

        self.navigationController!.setToolbarHidden(false, animated: false)
        self.navigationController!.isToolbarHidden = true

        self.tabBar!.selectedItem = ((self.tabBar!.items as NSArray!).object(at: 1)) as? UITabBarItem
        if UIScreen.main.bounds.size.height <= 480.0 { // is 3.5 inch screen
            self.tabBar!.isHidden = true
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(TLReceiveViewController.refreshSelectedAccountAgain))
        
        self.navigationController!.view.addGestureRecognizer(self.slidingViewController().panGesture)

        NotificationCenter.default.addObserver(self, selector: #selector(TLReceiveViewController.updateReceiveViewController(_:)),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_ADVANCE_MODE_TOGGLED()), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TLReceiveViewController.updateViewToNewSelectedObject),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_UPDATED_RECEIVING_ADDRESSES()), object: nil)
        NotificationCenter.default.addObserver(self
            , selector: #selector(TLReceiveViewController.updateViewToNewSelectedObjectAndAlertNewText),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_MODEL_UPDATED_NEW_UNCONFIRMED_TRANSACTION()), object: nil)
        NotificationCenter.default.addObserver(self
            , selector: #selector(TLReceiveViewController.updateViewToNewSelectedObject),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED()), object: nil)
        NotificationCenter.default.addObserver(self
            , selector: #selector(TLReceiveViewController.updateViewToNewSelectedObject),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_FETCHED_ADDRESSES_DATA()), object: nil)
        NotificationCenter.default.addObserver(self
            , selector: #selector(TLReceiveViewController.updateViewToNewSelectedObject),
            name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED()), object: nil)
        NotificationCenter.default.addObserver(self
            , selector: #selector(TLReceiveViewController.updateViewToNewSelectedObject),
              name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_EXCHANGE_RATE_UPDATED()), object: nil)
        
        
        self.receiveAddressesScrollView!.delegate = self
        
        let singleFingerTap = UITapGestureRecognizer(target: self, action: #selector(TLReceiveViewController.singleFingerTap))
        self.receiveAddressesScrollView!.addGestureRecognizer(singleFingerTap)
        
        if (AppDelegate.instance().justSetupHDWallet) {
            AppDelegate.instance().justSetupHDWallet = false
            TLPrompts.promptSuccessMessage(TLDisplayStrings.WELCOME_EXCLAMATION_STRING(), message: TLDisplayStrings.WELCOME_DESC_STRING())
        }
        
        self.refreshSelectedAccount(false)
    }
    
    override func viewWillAppear(_ animated: Bool) -> () {
        self.updateViewToNewSelectedObject()
    }
    
    override func viewDidAppear(_ animated: Bool) -> () {
        NotificationCenter.default.post(name: Notification.Name(rawValue: TLNotificationEvents.EVENT_VIEW_RECEIVE_SCREEN()), object: nil, userInfo: nil)
        
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
    
    fileprivate func refreshSelectedAccount(_ fetchDataAgain: Bool) {
        if (!AppDelegate.instance().receiveSelectedObject!.hasFetchedCurrentFromData() || fetchDataAgain) {
            if (AppDelegate.instance().receiveSelectedObject!.getSelectedObjectType() == .account) {
                let accountObject = AppDelegate.instance().receiveSelectedObject!.getSelectedObject() as! TLAccountObject
                self.balanceActivityIndicatorView!.isHidden = false
                self.accountBalanceLabel!.isHidden = true
                self.balanceActivityIndicatorView!.startAnimating()
                AppDelegate.instance().pendingOperations.addSetUpAccountOperation(accountObject, fetchDataAgain: fetchDataAgain, success: {
                    self.accountBalanceLabel!.isHidden = false
                    self.balanceActivityIndicatorView!.stopAnimating()
                    self.balanceActivityIndicatorView!.isHidden = true
                    if accountObject.downloadState != .downloaded {
                        self.updateAccountBalance()
                    }
                })
                
            } else if (AppDelegate.instance().receiveSelectedObject!.getSelectedObjectType() == .address) {
                let importedAddress = AppDelegate.instance().receiveSelectedObject!.getSelectedObject() as! TLImportedAddress
                self.balanceActivityIndicatorView!.isHidden = false
                self.accountBalanceLabel!.isHidden = true
                self.balanceActivityIndicatorView!.startAnimating()
                AppDelegate.instance().pendingOperations.addSetUpImportedAddressOperation(importedAddress, fetchDataAgain: fetchDataAgain, success: {
                    self.accountBalanceLabel!.isHidden = false
                    self.balanceActivityIndicatorView!.stopAnimating()
                    self.balanceActivityIndicatorView!.isHidden = true
                    if importedAddress.downloadState != .downloaded {
                        self.updateAccountBalance()
                    }
                })
            }
        } else {
            let balance = TLCurrencyFormat.getProperAmount(AppDelegate.instance().historySelectedObject!.getBalanceForSelectedObject()!)
            accountBalanceLabel!.text = balance as String
            self.balanceActivityIndicatorView!.isHidden = true
        }
    }
    
    override func showSendView() {
        self.slidingViewController().topViewController = self.storyboard!.instantiateViewController(withIdentifier: "SendNav") 
    }
    
    func singleFingerTap() {
        if self.receiveAddresses == nil {
            // receiveAddresses not loaded yet
            return
        }
        let address = self.receiveAddresses!.object(at: self.receiveAddressesPageControl!.currentPage) as! String
        let pasteboard = UIPasteboard.general
        pasteboard.string = address
        iToast.makeText(TLDisplayStrings.COPIED_TO_CLIPBOARD_STRING()).setGravity(iToastGravityCenter).setDuration(1000).show()
    }
    
    @IBAction fileprivate func scrollViewClicked(_ sender: AnyObject) {
        if self.receiveAddresses == nil {
            // receiveAddresses not loaded yet
            return
        }
        let address = self.receiveAddresses!.object(at: self.receiveAddressesPageControl!.currentPage) as! String
        let pasteboard = UIPasteboard.general
        pasteboard.string = address
        iToast.makeText(TLDisplayStrings.COPIED_TO_CLIPBOARD_STRING()).setGravity(iToastGravityCenter).setDuration(1000).show()
    }
    
    fileprivate func getAddressInfoLabel(_ frame: CGRect, text: String) -> UILabel {
        let addressInfoLabel = UILabel(frame: frame)
        addressInfoLabel.textAlignment = .center
        addressInfoLabel.text = text
        addressInfoLabel.textColor = TLColors.mainAppOppositeColor()
        addressInfoLabel.numberOfLines = 0
        return addressInfoLabel
    }
    
    fileprivate func getPageWidth() -> CGFloat {
        if (UIScreen.main.bounds.size.width > 414) {
            //is iPad
            return UIScreen.main.bounds.size.width - 16
        }
        if (UIScreen.main.bounds.size.width == 414) {
            //is iPhone6+
            return UIScreen.main.bounds.size.width - 16 - 8
        }
        
        return UIScreen.main.bounds.size.width - 16
    }
    
    fileprivate func getLastPageView(_ lastPageCount: Int, text: String) -> UIView {
        let pageWidth = self.getPageWidth()
        
        var frame = CGRect()
        frame.origin.x = CGFloat(pageWidth * CGFloat(lastPageCount))
        frame.origin.y = 0
        frame.size = self.receiveAddressesScrollView!.frame.size
        let pageView = UIView(frame: frame)
        
        let QRCodeImageWidth = pageWidth - 40
        
        let xToBeInCenter = (pageWidth - QRCodeImageWidth) / 2
        let imageViewFrame = CGRect(x: xToBeInCenter,
            y: 0,
            width: QRCodeImageWidth,
            height: QRCodeImageWidth)
        
        pageView.addSubview(self.getAddressInfoLabel(imageViewFrame, text: text))
        
        pageView.backgroundColor = TLColors.mainAppColor()
        
        return pageView
    }
    
    fileprivate func updateReceiveAddressesView() {
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
        
        let pageWidth = self.getPageWidth()
        let pageHeight:CGFloat
        if UIScreen.main.bounds.size.height > 480.0 {
            pageHeight = pageWidth
        } else { // is 3.5 inch screen
            pageHeight = pageWidth - 100
        }
        
        var pageCount = 0

        for i in stride(from: 0, to: self.receiveAddresses!.count, by: 1) {
            pageCount += 1
            
            var frame = CGRect()
            frame.origin.x = pageWidth * CGFloat(i)
            frame.origin.y = 0
            frame.size = self.receiveAddressesScrollView!.frame.size
            let pageView = UIView(frame: frame)
            
            let QRCodeImageWidth:CGFloat
            if UIScreen.main.bounds.size.height > 480.0 {
                QRCodeImageWidth = pageWidth - 30
            } else { // is 3.5 inch screen
                QRCodeImageWidth = pageWidth - 110
            }
            
            let xToBeInCenter = (pageWidth - QRCodeImageWidth) / 2.0
            let imageViewFrame = CGRect(x: xToBeInCenter,
                y: 0,
                width: QRCodeImageWidth,
                height: QRCodeImageWidth)
            
            if (i < self.receiveAddresses!.count - 1 || AppDelegate.instance().receiveSelectedObject!.getSelectedObjectType() == .address) {
                    
                    
                let address = self.receiveAddresses!.object(at: i) as! String
                let QRCodeImage = getQRCodeImage(address, size: QRCodeImageWidth - 5)
                    
                let QRCodeImageView = UIImageView(frame: imageViewFrame)
                QRCodeImageView.image = QRCodeImage
                pageView.addSubview(QRCodeImageView)
                    
                let addressLabelY: CGFloat
                let infoLabelY: CGFloat
                if (UIScreen.main.bounds.size.width <= 320) {
                    //is <= iPhone5s
                    addressLabelY = QRCodeImageWidth + 5
                    infoLabelY = QRCodeImageWidth - 15
                } else {
                    addressLabelY = QRCodeImageWidth + 21
                    infoLabelY = QRCodeImageWidth
                }
                    
                let addressLabelFrame = CGRect(x: xToBeInCenter,
                    y: addressLabelY,
                    width: QRCodeImageWidth,
                    height: 21)
                let labelEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5)
                    
                let addressLabel = UILabel(frame: UIEdgeInsetsInsetRect(addressLabelFrame, labelEdgeInsets))
                addressLabel.textColor = TLColors.mainAppOppositeColor()
                addressLabel.adjustsFontSizeToFitWidth = true
                addressLabel.textAlignment = .center
                addressLabel.font = UIFont.boldSystemFont(ofSize: addressLabel.font.pointSize)
                addressLabel.text = address
                if address.characters.count > 35 { // is stealth address
                    addressLabel.numberOfLines = 2
                } else {
                    addressLabel.numberOfLines = 1
                }
                pageView.addSubview(addressLabel)
                    
                if (TLStealthAddress.isStealthAddress(address, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)) {
                    let infoLabelFrame = CGRect(x: xToBeInCenter,
                        y: infoLabelY,
                        width: QRCodeImageWidth,
                        height: 21)
                        
                    let infoLabel = UILabel(frame: UIEdgeInsetsInsetRect(infoLabelFrame, labelEdgeInsets))
                    infoLabel.textColor = TLColors.mainAppOppositeColor()
                    infoLabel.font = UIFont.boldSystemFont(ofSize: addressLabel.font.pointSize - 5)
                    infoLabel.text = TLDisplayStrings.REUSABLE_ADDRESS_COLON_STRING()
                    pageView.addSubview(infoLabel)
                    //QRCodeImageView.backgroundColor = UIColor.orangeColor()
                }
            } else {
                if AppDelegate.instance().receiveSelectedObject!.getAccountType() == .coldWallet {
                    pageView.addSubview(self.getAddressInfoLabel(imageViewFrame, text: coldWalletAccountStealthAddressInfoText))
                } else if AppDelegate.instance().receiveSelectedObject!.getAccountType() == .importedWatch {
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
            pageCount += 1
        }
        
        self.receiveAddressesScrollView!.contentSize = CGSize(width: pageWidth * CGFloat(numPages),
            height: CGFloat(pageHeight))
        
        self.receiveAddressesPageControl!.currentPage = 0
        self.receiveAddressesPageControl!.numberOfPages = numPages
        
        if (self.receiveAddressesPageControl!.numberOfPages > 1) {
            self.receiveAddressesPageControl!.isHidden = false
            self.pageControlViewContainer!.isHidden = false
        } else {
            self.receiveAddressesPageControl!.isHidden = true
            self.pageControlViewContainer!.isHidden = true
        }
    }

    fileprivate func updateReceiveAddressArray() {
        let receivingAddressesCount = AppDelegate.instance().receiveSelectedObject!.getReceivingAddressesCount()
        self.receiveAddresses = NSMutableArray(capacity: Int(receivingAddressesCount))
        for i in stride(from: 0, to: Int(receivingAddressesCount), by: 1) {
            let address = AppDelegate.instance().receiveSelectedObject!.getReceivingAddressForSelectedObject(i)
            self.receiveAddresses!.add(address!)
        }

        if (TLWalletUtils.ENABLE_STEALTH_ADDRESS()) {
            if (AppDelegate.instance().receiveSelectedObject!.getSelectedObjectType() == .account) {
                if let stealthAddress = AppDelegate.instance().receiveSelectedObject!.getStealthAddress() {
                    if (TLPreferences.enabledStealthAddressDefault()) {
                        self.receiveAddresses!.insert(stealthAddress, at: 0)
                    } else {
                        self.receiveAddresses!.add(stealthAddress)
                    }                    
                }
            }
        }

        if (AppDelegate.instance().receiveSelectedObject!.getSelectedObjectType() == .account) {
            self.receiveAddresses!.add("End")
        }
    }

    func updateViewToNewSelectedObjectAndAlertNewText() {
        updateViewToNewSelectedObject()
    }
    
    func updateViewToNewSelectedObject() {
        DispatchQueue.main.async {
            self.updateAccountBalance()
            let receivingAddressesCount = AppDelegate.instance().receiveSelectedObject!.getReceivingAddressesCount()
            if (receivingAddressesCount == 0) {
                // this happens if receiving addresses have not been computed yet (cuz it requires look ups), thus don't update UI yet
                // EVENT_UPDATED_RECEIVING_ADDRESSES will fire and this method be called
                return
            }
            let label = AppDelegate.instance().receiveSelectedObject!.getLabelForSelectedObject()
            self.accountNameLabel!.text = label
            self.updateReceiveAddressArray()
            self.updateReceiveAddressesView()
            self.scrollToPage(0)
        }
    }

    fileprivate func updateAccountBalance() {
        let balance = AppDelegate.instance().receiveSelectedObject!.getBalanceForSelectedObject()
        let balanceString = TLCurrencyFormat.getProperAmount(balance!)
        
        if AppDelegate.instance().receiveSelectedObject!.getDownloadState() == .downloaded {
            self.balanceActivityIndicatorView!.stopAnimating()
            self.balanceActivityIndicatorView!.isHidden = true
            self.accountBalanceLabel!.text = balanceString as String
            self.accountBalanceLabel!.isHidden = false
        }
    }

    fileprivate func getQRCodeImage(_ address: String, size: CGFloat) -> UIImage {
        //let QRCodeData = TLWalletUtils.getBitcoinURI(address, amount: TLCoin.zero(), label: nil, message: nil)
        let QRCodeData = address
        let QRCodeImage = TLWalletUtils.getQRCodeImage(QRCodeData,
                imageDimension: Int(size))

        return QRCodeImage
    }

    func updateReceiveViewController(_ notification: Notification) {
        if (TLPreferences.enabledAdvancedMode()) {
            //self.addressLabel!.hidden = false
        } else {
            //self.addressLabel!.hidden = true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) -> () {
        if(segue.identifier == "selectAccount") {
            let vc = segue.destination 
            vc.navigationItem.title = TLDisplayStrings.SELECT_ACCOUNT_STRING()
            NotificationCenter.default.addObserver(self, selector: #selector(TLReceiveViewController.onAccountSelected(_:)), name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_ACCOUNT_SELECTED()), object: nil)
        }
    }

    func onAccountSelected(_ note: Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TLNotificationEvents.EVENT_ACCOUNT_SELECTED()), object: nil)
        let selectedDict = note.object as! NSDictionary
        let sendFromType = TLSendFromType(rawValue: selectedDict.object(forKey: "sendFromType") as! Int)

        let sendFromIndex = selectedDict.object(forKey: "sendFromIndex") as! Int
        AppDelegate.instance().updateReceiveSelectedObject(sendFromType!, sendFromIndex: sendFromIndex)

        self.updateViewToNewSelectedObject()
    }

    fileprivate func scrollToPage(_ page: NSInteger) {
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

    @IBAction fileprivate func changePage(_ sender: AnyObject) {
        self.scrollToPage(self.receiveAddressesPageControl!.currentPage)
    }

    @IBAction fileprivate func menuButtonClicked(_ sender: AnyObject) {
        self.slidingViewController().anchorTopViewToRight(animated: true)
    }

    func scrollViewDidScroll(_ sender: UIScrollView) {
        if (!pageControlBeingUsed) {
            // change page when more than 50% of the previous/next page is visible
            let pageWidth = self.receiveAddressesScrollView!.frame.size.width
            let page = floor((self.receiveAddressesScrollView!.contentOffset.x - pageWidth / 2) / pageWidth) + 1
            self.receiveAddressesPageControl!.currentPage = Int(page)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pageControlBeingUsed = false
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControlBeingUsed = false
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if (item.tag == 0) {
            self.showSendView()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

