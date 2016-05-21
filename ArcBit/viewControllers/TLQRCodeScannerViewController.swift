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
    
    private let n = 66
    private let DEFAULT_HEADER_HEIGHT = 66
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var success: ((String?) -> ())?
    private var error: ((String?) -> ())?
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var isReadingQRCode: Bool = false
    
    override func preferredStatusBarStyle() -> (UIStatusBarStyle) {
        return UIStatusBarStyle.LightContent
    }
    
    init(success __success: ((String?) -> ())?, error __error: ((String?) -> ())?) {
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.success = __success
        self.error = __error
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let app = AppDelegate.instance()
        self.view.frame = CGRectMake(0, 0, app.window!.frame.size.width, app.window!.frame.size.height - CGFloat(DEFAULT_HEADER_HEIGHT))
        
        let topBarView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, CGFloat(DEFAULT_HEADER_HEIGHT)))
        topBarView.backgroundColor = TLColors.mainAppColor()
        self.view.addSubview(topBarView)
        
        let logo = UIImageView(image: UIImage(named: "top_menu_logo.png"))
        logo.frame = CGRectMake(88, 22, 143, 40)
        topBarView.addSubview(logo)
        
        let closeButton = UIButton(frame: CGRectMake(self.view.frame.size.width - 70, 15, 80, 51))
        closeButton.setTitle("Close".localized, forState: UIControlState.Normal)
        closeButton.setTitleColor(UIColor(white:0.56, alpha: 1.0), forState: UIControlState.Highlighted)
        closeButton.titleLabel!.font = UIFont.systemFontOfSize(15)
        closeButton.addTarget(self, action: "closeButtonClicked:", forControlEvents: .TouchUpInside)
        topBarView.addSubview(closeButton)
        
        self.startReadingQRCode()
    }
    
    func closeButtonClicked(sender: UIButton) -> () {
        self.stopReadingQRCode()
    }
    
    func startReadingQRCode() -> () {
        var error: NSError?
        
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
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
        
        let dispatchQueue = dispatch_queue_create("myQueue", nil)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatchQueue)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = (AVLayerVideoGravityResizeAspectFill)
        
        let app = AppDelegate.instance()
        let frame = CGRectMake(0, CGFloat(DEFAULT_HEADER_HEIGHT), app.window!.frame.size.width, app.window!.frame.size.height - CGFloat(DEFAULT_HEADER_HEIGHT))
        
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
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if (self.error != nil) {
            self.error!(nil)
        }
    }
    
     func captureOutput(captureOutput: AVCaptureOutput!,
        didOutputMetadataObjects metadataObjects: [AnyObject]!,
        fromConnection connection: AVCaptureConnection!) -> () {
        if (metadataObjects != nil && metadataObjects!.count > 0) {
            let metadataObj: AnyObject = metadataObjects![0]
            if (metadataObj.type == AVMetadataObjectTypeQRCode) {
                // do something useful with results
                dispatch_sync(dispatch_get_main_queue()) {
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
