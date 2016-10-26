//
//  TLPrompts.swift
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

class TLPrompts {
    
    typealias EnterPINSuccess = () -> ()
    typealias EnterPINFailure = (Bool) -> ()
    typealias Failure = (Bool) -> ()
    typealias UserInputCallback = (String!) -> ()
    
    class func promptAlertController(_ vc: UIViewController, title: String, message: String, okText: String, cancelTx: String,
        success: @escaping TLWalletUtils.Success
        , failure: @escaping Failure) -> () {
            UIAlertController.showAlert(in: vc,
                withTitle: title,
                message: message,
                cancelButtonTitle: cancelTx,
                destructiveButtonTitle: nil,
                otherButtonTitles: [okText],
                
                tap: {(alertView, action, buttonIndex) in
                    if (buttonIndex == alertView?.firstOtherButtonIndex) {
                        success()
                    } else if (buttonIndex == alertView?.cancelButtonIndex) {
                        failure(true)
                    }
            })
    }
    
    class func promtForInputText(_ vc:UIViewController, title: String, message: String,
        textFieldPlaceholder: String?,
        success: @escaping UserInputCallback
        , failure: @escaping Failure) -> () {
            UIAlertController.showAlert(in: vc,
                withTitle: title,
                message: message,
                preferredStyle: .alert,
                cancelButtonTitle: "Cancel".localized,
                destructiveButtonTitle: nil,
                otherButtonTitles: ["OK".localized],
                preShow: {(controller) in
                    func addPromptTextField(_ textField: UITextField!){
                        textField.placeholder = textFieldPlaceholder
                    }
                    controller!.addTextField(configurationHandler: addPromptTextField)
                }
                ,
                tap: {(alertView, action, buttonIndex) in
                    if (buttonIndex == alertView!.firstOtherButtonIndex) {
                        let inputedText = (alertView!.textFields![0] ).text
                        success(inputedText)
                    } else if (buttonIndex == alertView!.cancelButtonIndex) {
                        failure(true)
                    }
            })
            
    }
    
    class func promtForOKCancel(_ vc: UIViewController, title: String, message: String,
        success: @escaping TLWalletUtils.Success
        , failure: @escaping Failure) -> () {
            UIAlertController.showAlert(in: vc,
                withTitle: title,
                message: message,
                cancelButtonTitle: "Cancel".localized,
                destructiveButtonTitle: nil,
                otherButtonTitles: ["OK".localized],
                
                tap: {(alertView, action, buttonIndex) in
                    if (buttonIndex == alertView!.firstOtherButtonIndex) {
                        success()
                    } else if (buttonIndex == alertView!.cancelButtonIndex) {
                        failure(true)
                    }
            })
    }
    
    
    class func promtForOK(_ vc:UIViewController, title: String, message: String,
        success: @escaping TLWalletUtils.Success) -> () {
            UIAlertController.showAlert(in: vc,
                withTitle: title,
                message: message,
                cancelButtonTitle: nil,
                destructiveButtonTitle: nil,
                otherButtonTitles: ["OK".localized],
                
                tap: {(alertView, action, buttonIndex) in
                    success()
            })
    }
    
    
    class func promptForTempararyImportPrivateKey(_ viewController: UIViewController, success: @escaping TLWalletUtils.SuccessWithString, error: @escaping TLWalletUtils.ErrorWithString) -> () {
        UIAlertController.showAlert(in: viewController,
            withTitle: "Private key missing".localized,
            message: "Do you want to temporary import your private key?".localized,
            cancelButtonTitle: "NO".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["YES".localized],
            tap: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView?.firstOtherButtonIndex) {
                    UIAlertController.showAlert(in: viewController,
                        withTitle: "Temporary import via text or QR code?".localized,
                        message: "",
                        cancelButtonTitle: nil,
                        destructiveButtonTitle: nil,
                        otherButtonTitles:["text".localized, "QR code".localized],
                        
                        tap: {(alertView, action, buttonIndex) in
                            if (buttonIndex == alertView?.firstOtherButtonIndex) {
                                TLPrompts.promtForInputText(viewController, title: "Temporary import private key".localized, message: "Input private key".localized, textFieldPlaceholder: nil, success: {
                                    (inputText: String!) in
                                    success(inputText)
                                    }, failure: {
                                        (cancelled: Bool) in
                                })
                            } else {
                                AppDelegate.instance().showPrivateKeyReaderController(viewController, success: {
                                    (data: NSDictionary) in
                                    let encryptedPrivateKey = data.object(forKey: "encryptedPrivateKey") as? String
                                    if encryptedPrivateKey == nil {
                                        success(data.object(forKey: "privateKey") as? String)
                                    }
                                    }, error: {
                                        (data: String?) in
                                        error(data)
                                })
                            }
                    })
                } else if (buttonIndex == alertView?.cancelButtonIndex) {
                    error("")
                }
        })
    }
    
    class func promptForTempararyImportExtendedPrivateKey(_ viewController: UIViewController, success: @escaping TLWalletUtils.SuccessWithString, error: @escaping TLWalletUtils.ErrorWithString) -> () {
        UIAlertController.showAlert(in: viewController,
            withTitle:  "Account private key missing".localized,
            message: "Do you want to temporary import your account private key?".localized,
            cancelButtonTitle: "NO".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["YES".localized],
            tap: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView?.firstOtherButtonIndex) {
                    UIAlertController.showAlert(in: viewController,
                        withTitle: "Temporary import via text or QR code?".localized,
                        message: "",
                        cancelButtonTitle: nil,
                        destructiveButtonTitle: nil,
                        otherButtonTitles: ["text".localized, "QR code".localized],
                        
                        tap: {(alertView, action, buttonIndex) in
                            if (buttonIndex == alertView?.firstOtherButtonIndex) {
                                TLPrompts.promtForInputText(viewController, title:"Temporary import account private key".localized, message: "Input account private key".localized, textFieldPlaceholder: nil, success: {
                                    (inputText: String!) in
                                    success(inputText)
                                    }, failure: {
                                        (cancelled: Bool) in
                                })
                            } else {
                                AppDelegate.instance().showExtendedPrivateKeyReaderController(viewController, success: {
                                    (data: String!) in
                                    success(data)
                                    }, error: {
                                        (data: String?) in
                                        error(data)
                                })
                            }
                    })
                } else if (buttonIndex == alertView?.cancelButtonIndex) {
                    error("")
                }
        })
    }
    
    class func promptForEncryptedPrivKeyPassword(_ vc:UIViewController, view: UIView, encryptedPrivKey: String, success: @escaping UserInputCallback, failure: @escaping Failure) -> () {
        UIAlertController.showAlert(in: vc,
            withTitle: "Enter password for encrypted private key".localized,
            message: "",
            preferredStyle: .alert,
            cancelButtonTitle: "Cancel".localized,
            destructiveButtonTitle: nil,
            otherButtonTitles: ["Enter".localized],
            preShow: {(controller) in
                func addPromptTextField(_ textField: UITextField!){
                    textField.placeholder = "password".localized
                }
                controller!.addTextField(configurationHandler: addPromptTextField)
            },
            tap: {(alertView, action, buttonIndex) in
                if (buttonIndex == alertView!.firstOtherButtonIndex) {
                    TLHUDWrapper.showHUDAddedTo(view, labelText: "Decrypting Private Key".localized, animated: true)
                    
                    let password = (alertView!.textFields![0] ).text
                    
                    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
                        let privKey = TLCoreBitcoinWrapper.privateKeyFromEncryptedPrivateKey(encryptedPrivKey, password: password!, isTestnet: AppDelegate.instance().appWallet.walletConfig.isTestnet)
                        DispatchQueue.main.async {
                            TLHUDWrapper.hideHUDForView(view, animated: true)
                            
                            if (privKey != nil) {
                                success(privKey)
                            } else {
                                UIAlertController.showAlert(in: vc,
                                    withTitle: "Passphrase is invalid".localized,
                                    message: "",
                                    cancelButtonTitle: "Cancel".localized,
                                    destructiveButtonTitle: nil,
                                    
                                    otherButtonTitles: ["Retry".localized],
                                    
                                    tap: {(alertView, action, buttonIndex) in
                                        if (buttonIndex == alertView!.firstOtherButtonIndex) {
                                            self.promptForEncryptedPrivKeyPassword(vc, view:view, encryptedPrivKey: encryptedPrivKey, success: success, failure: failure)
                                        } else if (buttonIndex == alertView!.cancelButtonIndex) {
                                            failure(true)
                                        }
                                })
                            }
                        }
                    }
                } else if (buttonIndex == alertView!.cancelButtonIndex) {
                    failure(true)
                }
        })
    }
    
    class func promptSuccessMessage(_ title: String?, message: String) -> () {
        let av = UIAlertView(title: title ?? "",
            message: message,
            delegate: nil,
            cancelButtonTitle: nil,
            otherButtonTitles: "OK".localized)
        
        av.show()
    }
    
    class func promptErrorMessage(_ title: String, message: String) -> () {
        let av = UIAlertView(title: title,
            message: message,
            delegate: nil,
            cancelButtonTitle: nil,
            otherButtonTitles: "OK".localized)
        
        av.show()
    }
}
