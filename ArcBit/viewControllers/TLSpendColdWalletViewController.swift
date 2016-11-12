//
//  TLSpendColdWalletViewController.swift
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

@objc(TLSpendColdWalletViewController) class  TLSpendColdWalletViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, TLScanUnsignedTxTableViewCellDelegate, TLInputColdWalletKeyTableViewCellDelegate, TLPassSignedTxTableViewCellDelegate, CustomIOS7AlertViewDelegate {
    
    struct STATIC_MEMBERS {
        static let kInstuctionsSection = "kInstuctionsSection"
        static let kSpendColdWalletSection = "kSpendColdWalletSection"
        
        static let kScanUnsignedTxRow = "kScanUnsignedTxRow"
        static let kInputKeyRow = "kInputKeyRow"
        static let kPassSignedTxRow = "kPassSignedTxRow"
    }
    
    @IBOutlet fileprivate var tableView: UITableView?
    fileprivate var QRImageModal: TLQRImageModal?
    fileprivate var sectionArray: Array<String>?
    fileprivate var instructionsRowArray: Array<String>?
    fileprivate var spendColdWalletRowArray: Array<String>?
    fileprivate var tapGesture: UITapGestureRecognizer?
    fileprivate var scanUnsignedTxTableViewCell: TLScanUnsignedTxTableViewCell?
    fileprivate var inputColdWalletKeyTableViewCell: TLInputColdWalletKeyTableViewCell?
    fileprivate var passSignedTxTableViewCell: TLPassSignedTxTableViewCell?

    private var scannedUnsignedTxAirGapDataPartsDict = [Int:String]()
    private var totalExpectedParts:Int = 0
    private var scannedUnsignedTxAirGapData:String? = nil
    private var airGapDataBase64PartsArray: Array<String>?
    private var savedAirGapDataBase64PartsArray: Array<String>?

    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        
        NotificationCenter.default.addObserver(self ,selector:#selector(TLCreateColdWalletViewController.keyboardWillShow(_:)),
                                                         name:NSNotification.Name.UIKeyboardWillShow, object:nil)
        NotificationCenter.default.addObserver(self ,selector:#selector(TLCreateColdWalletViewController.keyboardWillHide(_:)),
                                                         name:NSNotification.Name.UIKeyboardWillHide, object:nil)
        
        self.tapGesture = UITapGestureRecognizer(target: self,
                                                 action: #selector(dismissKeyboard))
        
        self.view.addGestureRecognizer(self.tapGesture!)
        
        self.sectionArray = [STATIC_MEMBERS.kInstuctionsSection, STATIC_MEMBERS.kSpendColdWalletSection]
        self.instructionsRowArray = []
        
        self.spendColdWalletRowArray = [STATIC_MEMBERS.kScanUnsignedTxRow, STATIC_MEMBERS.kInputKeyRow, STATIC_MEMBERS.kPassSignedTxRow]
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.tableFooterView = UIView(frame:CGRect.zero)
    }
    
    func dismissKeyboard() {
        self.inputColdWalletKeyTableViewCell?.keyInputTextView.resignFirstResponder()
    }
    
    func didClickScanUnsignedTxInfoButton(_ cell: TLScanUnsignedTxTableViewCell) {
        dismissKeyboard()
        let msg = "On your primary online device, when you want to make a payment from a cold wallet account, simply do it as would normally would on a normal account. When you click 'Send' on the Review Payment screen, instead of the payment going out immediately, you will be prompt to pass the unauthorized transaction data. Then on your secondary offline device, within this screen click 'Scan' to import the transaction so it can be authorized.".localized
        TLPrompts.promtForOK(self, title:"", message: msg, success: {
            () in
        })
    }

    func didClickInputColdWalletKeyInfoButton(_ cell: TLInputColdWalletKeyTableViewCell) {
        dismissKeyboard()
        let msg = "Input the 12 word passphrase/mnemonic that belongs to the cold wallet account that you want to make a payment from. This is the passphrase that was used to generate your account public key that was generated in the 'Create Cold Wallet' section found in the previous screen.".localized
        TLPrompts.promtForOK(self, title:"", message: msg, success: {
            () in
        })
    }
    
    func didClickPassSignedTxInfoButton(_ cell: TLPassSignedTxTableViewCell) {
        dismissKeyboard()
        let msg = "Once the transaction has been authorized by completing the above two steps, pass the authorized transaction back to your primary online device to finalize your payment.".localized
        TLPrompts.promtForOK(self, title:"", message: msg, success: {
            () in
        })
    }
    
    func checkToCreateSignedTx() {
        let keyText = self.inputColdWalletKeyTableViewCell?.keyInputTextView.text
        if keyText == nil || keyText!.isEmpty {
            self.inputColdWalletKeyTableViewCell?.statusLabel.text = "Incomplete".localized
            self.inputColdWalletKeyTableViewCell?.setstatusLabel(false)
            self.passSignedTxTableViewCell?.passButtonButton.isEnabled = false
            self.passSignedTxTableViewCell?.passButtonButton.alpha = 0.5
            return
        }
        if !TLHDWalletWrapper.phraseIsValid(keyText!) && !TLHDWalletWrapper.isValidExtendedPrivateKey(keyText!) {
            self.inputColdWalletKeyTableViewCell?.statusLabel.text = "Invalid passphrase".localized
            self.inputColdWalletKeyTableViewCell?.setstatusLabel(false)
            self.passSignedTxTableViewCell?.passButtonButton.isEnabled = false
            self.passSignedTxTableViewCell?.passButtonButton.alpha = 0.5
            return
        }
        if self.scannedUnsignedTxAirGapData == nil {
            self.inputColdWalletKeyTableViewCell?.statusLabel.text = "Complete step 1".localized
            self.inputColdWalletKeyTableViewCell?.setstatusLabel(false)
            self.passSignedTxTableViewCell?.passButtonButton.isEnabled = false
            self.passSignedTxTableViewCell?.passButtonButton.alpha = 0.5
            return
        }
        
        do {
            let serializedSignedAipGapData = try TLColdWallet.createSerializedSignedTxAipGapData(self.scannedUnsignedTxAirGapData!,
                                                                                               mnemonicOrExtendedPrivateKey: keyText!,
                                                                                               isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)
            self.airGapDataBase64PartsArray = TLColdWallet.splitStringToAray(serializedSignedAipGapData!)
            self.savedAirGapDataBase64PartsArray = TLColdWallet.splitStringToAray(serializedSignedAipGapData!)
            self.inputColdWalletKeyTableViewCell?.statusLabel.text = "Complete".localized
            self.inputColdWalletKeyTableViewCell?.setstatusLabel(true)
            self.passSignedTxTableViewCell?.passButtonButton.isEnabled = true
            self.passSignedTxTableViewCell?.passButtonButton.alpha = 1.0
        } catch TLColdWallet.TLColdWalletError.InvalidScannedData(let error) { //shouldn't happen, if user scanned correct QR codes
            DLog("TLColdWallet InvalidScannedData \(error)");
            self.airGapDataBase64PartsArray = nil
            self.savedAirGapDataBase64PartsArray = nil
            self.scanUnsignedTxTableViewCell?.setInvalidScannedData()
            self.passSignedTxTableViewCell?.passButtonButton.isEnabled = false
            self.passSignedTxTableViewCell?.passButtonButton.alpha = 0.5
        } catch TLColdWallet.TLColdWalletError.InvalidKey(let error) {
            DLog("TLColdWallet InvalidKey \(error)");
            self.airGapDataBase64PartsArray = nil
            self.savedAirGapDataBase64PartsArray = nil
            self.inputColdWalletKeyTableViewCell?.statusLabel.text = "Invalid passphrase".localized
            self.inputColdWalletKeyTableViewCell?.setstatusLabel(false)
            self.passSignedTxTableViewCell?.passButtonButton.isEnabled = false
            self.passSignedTxTableViewCell?.passButtonButton.alpha = 0.5
        } catch TLColdWallet.TLColdWalletError.MisMatchExtendedPublicKey(let error) {
            DLog("TLColdWallet MisMatchExtendedPublicKey \(error)");
            self.airGapDataBase64PartsArray = nil
            self.savedAirGapDataBase64PartsArray = nil
            self.inputColdWalletKeyTableViewCell?.statusLabel.text = "Passphrase does not match the transaction".localized
            self.inputColdWalletKeyTableViewCell?.setstatusLabel(false)
            self.passSignedTxTableViewCell?.passButtonButton.isEnabled = false
            self.passSignedTxTableViewCell?.passButtonButton.alpha = 0.5
        } catch {
            DLog("TLColdWallet error \(error)");
        }
    }

    func didClickScanButton(_ cell: TLScanUnsignedTxTableViewCell) {
        dismissKeyboard()
    
        scanUnsignedTx(success: { () in
            DLog("didClickScanButton success");
            
            if self.totalExpectedParts != 0 && self.scannedUnsignedTxAirGapDataPartsDict.count == self.totalExpectedParts {
                self.scannedUnsignedTxAirGapData = ""
                for i in stride(from: 1, through: self.totalExpectedParts, by: 1) {
                    let dataPart = self.scannedUnsignedTxAirGapDataPartsDict[i]
                    self.scannedUnsignedTxAirGapData = self.scannedUnsignedTxAirGapData! + dataPart!
                }
                self.scannedUnsignedTxAirGapDataPartsDict = [Int:String]()
                DLog("didClickScanButton self.scannedUnsignedTxAirGapData \(self.scannedUnsignedTxAirGapData)");
                self.checkToCreateSignedTx()
            }
            }, error: {
                () in
                DLog("didClickScanButton error");
        })
    }
    
    func scanUnsignedTx(success: @escaping (TLWalletUtils.Success), error: @escaping (TLWalletUtils.Error)) {
        AppDelegate.instance().showColdWalletSpendReaderControllerFromViewController(self, success: {
            (data: String!) in
            let ret = TLColdWallet.parseScannedPart(data)
            let dataPart = ret.0
            let partNumber = ret.1
            let totalParts = ret.2
            
            self.totalExpectedParts = totalParts
            self.scannedUnsignedTxAirGapDataPartsDict[partNumber] = dataPart
            
            self.scanUnsignedTxTableViewCell?.setstatusLabel(self.scannedUnsignedTxAirGapDataPartsDict.count, totalParts: totalParts)
            DLog("scanUnsignedTx \(dataPart) \(partNumber) \(totalParts)");
            success()
            }, error: {
                (data: String?) in
                error()
        })
    }
    
    func showNextSignedTxPartQRCode() {
        if self.airGapDataBase64PartsArray == nil {
            return
        }
        let nextAipGapDataPart = self.airGapDataBase64PartsArray![0]
        self.airGapDataBase64PartsArray!.remove(at: 0)
        self.QRImageModal = TLQRImageModal(data: nextAipGapDataPart as NSString, buttonCopyText: "Next".localized, vc: self)
        self.QRImageModal!.show()
    }

    func didClickPassButton(_ cell: TLPassSignedTxTableViewCell) {
        dismissKeyboard()
        if self.airGapDataBase64PartsArray == nil {
            return
        }
        TLPrompts.promtForOKCancel(self, title: "Transaction authorized".localized, message: "Transaction needs to be passed back to your online device in order for the payment to be sent", success: {
            () in
                self.showNextSignedTxPartQRCode()
            
            }, failure: {
                (isCancelled: Bool) in
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.inputColdWalletKeyTableViewCell?.keyInputTextView {
            self.checkToCreateSignedTx()
        }
    }
    
    func numberOfSections(in tableView:UITableView) -> Int {
        return self.sectionArray!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = self.sectionArray![(indexPath as NSIndexPath).section]
        if(section == STATIC_MEMBERS.kInstuctionsSection) {
            return 100
        } else if(section == STATIC_MEMBERS.kSpendColdWalletSection) {
            let row = self.spendColdWalletRowArray![(indexPath as NSIndexPath).row]
            if row == STATIC_MEMBERS.kScanUnsignedTxRow {
                return TLScanUnsignedTxTableViewCell.cellHeight()
            } else if row == STATIC_MEMBERS.kInputKeyRow {
                return TLInputColdWalletKeyTableViewCell.cellHeight()
            } else if row == STATIC_MEMBERS.kPassSignedTxRow {
                return TLPassSignedTxTableViewCell.cellHeight()
            }
        }
        return 0
    }
    
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        let section = self.sectionArray![section]
        if(section == STATIC_MEMBERS.kInstuctionsSection) {
            return "".localized
        } else if(section == STATIC_MEMBERS.kSpendColdWalletSection) {
            return "".localized
        }
        return "".localized
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        let section = self.sectionArray![section]
        if (section == STATIC_MEMBERS.kInstuctionsSection) {
            return self.instructionsRowArray!.count
        } else if(section == STATIC_MEMBERS.kSpendColdWalletSection) {
            return self.spendColdWalletRowArray!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        let section = self.sectionArray![(indexPath as NSIndexPath).section];
        if (section == STATIC_MEMBERS.kInstuctionsSection) {
            let MyIdentifier = "InstructionsCellIdentifier"
            
            var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier)
            if (cell == nil) {
                cell = UITableViewCell(style:UITableViewCellStyle.default,
                                       reuseIdentifier:MyIdentifier)
            }
            return cell!
        } else if(section == STATIC_MEMBERS.kSpendColdWalletSection) {
            let row = self.spendColdWalletRowArray![(indexPath as NSIndexPath).row];
            self.spendColdWalletRowArray = [STATIC_MEMBERS.kScanUnsignedTxRow, STATIC_MEMBERS.kInputKeyRow, STATIC_MEMBERS.kPassSignedTxRow]

            if row == STATIC_MEMBERS.kScanUnsignedTxRow {
                let MyIdentifier = "ScanUnsignedTxCellIdentifier"
                var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) as! TLScanUnsignedTxTableViewCell?
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.default,
                                           reuseIdentifier: MyIdentifier) as? TLScanUnsignedTxTableViewCell
                }
                
                cell?.delegate = self
                self.scanUnsignedTxTableViewCell = cell
                return cell!
            } else if row == STATIC_MEMBERS.kInputKeyRow {
                let MyIdentifier = "InputColdWalletKeyCellIdentifier"
                var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) as! TLInputColdWalletKeyTableViewCell?
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.default,
                                           reuseIdentifier: MyIdentifier) as? TLInputColdWalletKeyTableViewCell
                }
                
                cell?.delegate = self
                cell?.keyInputTextView.delegate = self
                self.inputColdWalletKeyTableViewCell = cell
                return cell!
            } else if row == STATIC_MEMBERS.kPassSignedTxRow {
                let MyIdentifier = "PassSignedTxCellIdentifier"
                var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier) as! TLPassSignedTxTableViewCell?
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.default,
                                           reuseIdentifier: MyIdentifier) as? TLPassSignedTxTableViewCell
                }
                
                cell?.delegate = self
                self.passSignedTxTableViewCell = cell
                return cell!
            }
        }
        
        return UITableViewCell(style:UITableViewCellStyle.default,
                               reuseIdentifier:"DefaultCellIdentifier")
    }
    
    func keyboardWillShow(_ sender: Notification) {
        let kbSize = ((sender as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue!.size
        
        let duration = ((sender as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue!
        
        let height = UIDeviceOrientationIsPortrait(UIDevice.current.orientation) ? kbSize.height : kbSize.width;
        UIView.animate(withDuration: duration, delay: 1.0, options: UIViewAnimationOptions(), animations: {
            var edgeInsets = self.tableView!.contentInset;
            edgeInsets.bottom = height;
            self.tableView!.contentInset = edgeInsets;
            edgeInsets = self.tableView!.scrollIndicatorInsets;
            edgeInsets.bottom = height;
            self.tableView!.scrollIndicatorInsets = edgeInsets;
            }, completion: { finished in
        })
    }
    
    func keyboardWillHide(_ sender: Notification) {
        let duration = ((sender as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue!
        UIView.animate(withDuration: duration, delay: 1.0, options: UIViewAnimationOptions(), animations: {
            var edgeInsets = self.tableView!.contentInset;
            edgeInsets.bottom = 0;
            self.tableView!.contentInset = edgeInsets;
            edgeInsets = self.tableView!.scrollIndicatorInsets;
            edgeInsets.bottom = 0;
            self.tableView!.scrollIndicatorInsets = edgeInsets;
            }, completion: { finished in
        })
    }
    
    func customIOS7dialogButtonTouchUp(inside alertView: CustomIOS7AlertView, clickedButtonAt buttonIndex: Int) {
        if (buttonIndex == 0) {
            if self.airGapDataBase64PartsArray == nil {
                return
            }
            if self.airGapDataBase64PartsArray!.count > 0 {
                self.showNextSignedTxPartQRCode()
            } else {
                TLPrompts.promtForOK(self, title: "Finished Passing Transaction Data".localized,
                                     message: "Now authorize the transaction on your air gap device. When you have done so click continue on this device to scan the authorized transaction data and make your payment.".localized, success: {
                                        () in
                                        self.airGapDataBase64PartsArray = self.savedAirGapDataBase64PartsArray
                                        //for part in self.savedAirGapDataBase64PartsArray! {
                                        //    self.airGapDataBase64PartsArray!.append(part.copy() as! String)
                                        //}
                                        
                })
            }
        } else {
            self.airGapDataBase64PartsArray = self.savedAirGapDataBase64PartsArray
        }
        
        alertView.close()
    }
}
