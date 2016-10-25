//
//  TLQRCodeScannerViewController.swift
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
import AVFoundation

@objc(TLQRCodeScannerViewController) class TLQRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    fileprivate let n = 66
    fileprivate let DEFAULT_HEADER_HEIGHT = 66
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate var success: ((String?) -> ())?
    fileprivate var error: ((String?) -> ())?
    fileprivate var captureSession: AVCaptureSession?
    fileprivate var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    fileprivate var isReadingQRCode: Bool = false
    
    override var preferredStatusBarStyle : (UIStatusBarStyle) {
        return UIStatusBarStyle.lightContent
    }
    
    init(success __success: ((String?) -> ())?, error __error: ((String?) -> ())?) {
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.success = __success
        self.error = __error
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let app = AppDelegate.instance()
        self.view.frame = CGRect(x: 0, y: 0, width: app.window!.frame.size.width, height: app.window!.frame.size.height - CGFloat(DEFAULT_HEADER_HEIGHT))
        
        let topBarView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: CGFloat(DEFAULT_HEADER_HEIGHT)))
        topBarView.backgroundColor = TLColors.mainAppColor()
        self.view.addSubview(topBarView)
        
        let logo = UIImageView(image: UIImage(named: "top_menu_logo.png"))
        logo.frame = CGRect(x: 88, y: 22, width: 143, height: 40)
        topBarView.addSubview(logo)
        
        let closeButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 70, y: 15, width: 80, height: 51))
        closeButton.setTitle("Close".localized, for: UIControlState())
        closeButton.setTitleColor(UIColor(white:0.56, alpha: 1.0), for: UIControlState.highlighted)
        closeButton.titleLabel!.font = UIFont.systemFont(ofSize: 15)
        closeButton.addTarget(self, action: #selector(TLQRCodeScannerViewController.closeButtonClicked(_:)), for: .touchUpInside)
        topBarView.addSubview(closeButton)
        
        self.startReadingQRCode()
    }
    
    func closeButtonClicked(_ sender: UIButton) -> () {
        self.stopReadingQRCode()
    }
    
    func startReadingQRCode() -> () {
        var error: NSError?
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        var input: AnyObject!
        do {
            input = try AVCaptureDeviceInput(device: captureDevice) as AVCaptureDeviceInput
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        if (input == nil) {
            // This should not happen - all devices we support have cameras
            DLog("QR code scanner problem: %@", function: error!.localizedDescription)
            return
        }
        
        captureSession = AVCaptureSession()
        captureSession!.addInput(input as! AVCaptureInput!)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession!.addOutput(captureMetadataOutput)
        
        let dispatchQueue = DispatchQueue(label: "myQueue", attributes: [])
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatchQueue)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = (AVLayerVideoGravityResizeAspectFill)
        
        let app = AppDelegate.instance()
        let frame = CGRect(x: 0, y: CGFloat(DEFAULT_HEADER_HEIGHT), width: app.window!.frame.size.width, height: app.window!.frame.size.height - CGFloat(DEFAULT_HEADER_HEIGHT))
        
        videoPreviewLayer!.frame = frame
        
        self.view.layer.addSublayer(videoPreviewLayer!)
        
        captureSession!.startRunning()
    }
    
    func stopReadingQRCode() -> () {
        if(captureSession != nil)
        {
            captureSession!.stopRunning()
            captureSession = nil
        }
        
        if(videoPreviewLayer != nil)
        {
            videoPreviewLayer!.removeFromSuperlayer()
        }
        
        self.dismiss(animated: true, completion: nil)
        
        if (self.error != nil) {
            self.error!(nil)
        }
    }
    
     func captureOutput(_ captureOutput: AVCaptureOutput!,
        didOutputMetadataObjects metadataObjects: [Any]!,
        from connection: AVCaptureConnection!) -> () {
        if (metadataObjects != nil && metadataObjects!.count > 0) {
            let metadataObj: AnyObject = metadataObjects![0] as AnyObject
            if (metadataObj.type == AVMetadataObjectTypeQRCode) {
                // do something useful with results
                DispatchQueue.main.sync {
                    let data:String = metadataObj.stringValue
                    
                    if (self.success != nil) {
                        self.success!(data)
                        self.stopReadingQRCode()
                    }
                }
            }
        }
    }
}
